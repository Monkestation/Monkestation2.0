#define RESTART_COUNTER_PATH "data/round_counter.txt"
/// Load byond-tracy. If USE_BYOND_TRACY is defined, then this is ignored and byond-tracy is always loaded.
#define USE_TRACY_PARAMETER "tracy"
/// Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
/// Prevent the master controller from starting automatically
#define NO_INIT_PARAMETER "no-init"

GLOBAL_VAR(restart_counter)

/**
 * WORLD INITIALIZATION
 * THIS IS THE INIT ORDER:
 *
 * BYOND =>
 * - (secret init native) =>
 *   - world.Genesis() =>
 *     - world.init_byond_tracy()
 *     - (Start native profiling)
 *     - new /datum/debugger()
 *     - world.setup_external_cpu()
 *     - Master =>
 *       - config *unloaded
 *       - (all subsystems) PreInit()
 *       - GLOB =>
 *         - make_datum_reference_lists()
 *   - (/static variable inits, reverse declaration order)
 * - (all pre-mapped atoms) /atom/New()
 * - world.New() =>
 *   - config.Load()
 *   - world.InitTgs() =>
 *     - TgsNew() *may sleep
 *     - GLOB.rev_data.load_tgs_info()
 *   - world.ConfigLoaded() =>
 *     - SSdbcore.InitializeRound()
 *     - world.SetupLogs()
 *     - load_admins()
 *     - load_mentors()
 *     - MentorizeAdmins()
 *     - ...
 *   - Master.Initialize() =>
 *     - (all subsystems) Initialize()
 *     - Master.StartProcessing() =>
 *       - Master.Loop() =>
 *         - Failsafe
 *   - world.RunUnattendedFunctions()
 *
 * Now listen up because I want to make something clear:
 * If something is not in this list it should almost definitely be handled by a subsystem Initialize()ing
 * If whatever it is that needs doing doesn't fit in a subsystem you probably aren't trying hard enough tbhfam
 *
 * GOT IT MEMORIZED?
 * - Dominion/Cyberboss
 */

/**
 * THIS !!!SINGLE!!! PROC IS WHERE ANY FORM OF INIITIALIZATION THAT CAN'T BE PERFORMED IN MASTER/NEW() IS DONE
 * NOWHERE THE FUCK ELSE
 * I DON'T CARE HOW MANY LAYERS OF DEBUG/PROFILE/TRACE WE HAVE, YOU JUST HAVE TO DEAL WITH THIS PROC EXISTING
 * I'M NOT EVEN GOING TO TELL YOU WHERE IT'S CALLED FROM BECAUSE I'M DECLARING THAT FORBIDDEN KNOWLEDGE
 * SO HELP ME GOD IF I FIND ABSTRACTION LAYERS OVER THIS!
 */
/world/proc/Genesis(tracy_initialized = FALSE)
	RETURN_TYPE(/datum/controller/master)

	// monkestation edit: some tracy refactoring
	if(!tracy_initialized)
		Tracy = new
#ifdef USE_BYOND_TRACY
		if(Tracy.enable("USE_BYOND_TRACY defined"))
			Genesis(tracy_initialized = TRUE)
			return
#else
		var/tracy_enable_reason
		if(USE_TRACY_PARAMETER in params)
			tracy_enable_reason = "world.params"
		if(fexists(TRACY_ENABLE_PATH))
			tracy_enable_reason ||= "enabled for round"
			SEND_TEXT(world.log, "[TRACY_ENABLE_PATH] exists, initializing byond-tracy!")
			fdel(TRACY_ENABLE_PATH)
		if(!isnull(tracy_enable_reason) && Tracy.enable(tracy_enable_reason))
			Genesis(tracy_initialized = TRUE)
			return
#endif
	// monkestation end

	Profile(PROFILE_RESTART)
	Profile(PROFILE_RESTART, type = "sendmaps")

	// Write everything to this log file until we get to SetupLogs() later
	_initialize_log_files("data/logs/config_error.[GUID()].log")
	GLOB.demo_log = "[GLOB.log_directory]/demo.txt" //Guh //Monkestation Edit: REPLAYS

	// Init the debugger first so we can debug Master
	Debugger = new

	// Create the logger
	logger = new

	// Cpu tracking setup
	world.setup_external_cpu()

	// THAT'S IT, WE'RE DONE, THE. FUCKING. END.
	Master = new

/**
 * World creation
 *
 * Here is where a round itself is actually begun and setup.
 * * db connection setup
 * * config loaded from files
 * * loads admins
 * * Sets up the dynamic menu system
 * * and most importantly, calls initialize on the master subsystem, starting the game loop that causes the rest of the game to begin processing and setting up
 *
 *
 * Nothing happens until something moves. ~Albert Einstein
 *
 * For clarity, this proc gets triggered later in the initialization pipeline, it is not the first thing to happen, as it might seem.
 *
 * Initialization Pipeline:
 * Global vars are new()'ed, (including config, glob, and the master controller will also new and preinit all subsystems when it gets new()ed)
 * Compiled in maps are loaded (mainly centcom). all areas/turfs/objs/mobs(ATOMs) in these maps will be new()ed
 * world/New() (You are here)
 * Once world/New() returns, client's can connect.
 * 1 second sleep
 * Master Controller initialization.
 * Subsystem initialization.
 * Non-compiled-in maps are maploaded, all atoms are new()ed
 * All atoms in both compiled and uncompiled maps are initialized()
 */
/world/New()
	log_world("World loaded at [time_stamp()]!")

	// From a really fucking old commit (91d7150)
	// I wanted to move it but I think this needs to be after /world/New is called but before any sleeps?
	// - Dominion/Cyberboss
	GLOB.timezoneOffset = world.timezone * 36000

	// First possible sleep()
	InitTgs()
	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	ConfigLoaded()

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	RunUnattendedFunctions()

#define TICK_INFO_SIZE 30
#define FORMAT_CPU(cpu) round(cpu, 0.01)
#define TICK_INFO_TICK2INDEX(tick) ((round(tick, 1) % TICK_INFO_SIZE) + 1)
#define TICK_INFO_INDEX(...) TICK_INFO_TICK2INDEX(DS2TICKS(world.time))

// Should we intentionally consume cpu time to try to keep SendMaps deltas constant?
GLOBAL_VAR_INIT(attempt_corrective_cpu, TRUE)
// Should we NOT use the corrective cpu threshold to calculate the mc's target cpu?
GLOBAL_VAR_INIT(use_old_mc_limit, FALSE)
// What value are we attempting to correct cpu TO (autoaccounts for lag, ideally)
GLOBAL_VAR_INIT(corrective_cpu_threshold, 0)
// What cpu value are we trying to meet safely
// For reasons I do not yet understand 90 is too high for this on highpop. I think it has to do with
// maptick being averaged/spikey? unsure.
GLOBAL_VAR_INIT(corrective_cpu_target, 85)
GLOBAL_VAR_INIT(corrective_cpu_cost, 0)
// How far away from the average can we get before discarding a datapoint
GLOBAL_VAR_INIT(corrective_cpu_ratio, 30)
// How far away from the average can we get before discarding a datapoint
GLOBAL_VAR_INIT(glide_threshold_ratio, 10)
// Debug tool, lets us set the floor of cpu consumption
GLOBAL_VAR_INIT(floor_cpu, 0)
// Debug tool, lets us set a sometimes used floor for cpu consumption
GLOBAL_VAR_INIT(sustain_cpu, 0)
// Debug tool, sets the chance to use GLOB.sustain_cpu as a floor
GLOBAL_VAR_INIT(sustain_cpu_chance, 0)
// Debug tool, floors cpu to its value, then resets itself
GLOBAL_VAR_INIT(spike_cpu, 0)

/world/Tick()
	// this is for next tick so don't display it yet yeah?
	var/datum/tick_holder/tick_info = ____tick_info
	var/current_index = TICK_INFO_INDEX()
	if(tick_info)
		tick_info.pre_tick_cpu_usage[current_index] = TICK_USAGE

	refresh_cpu_values()
	if(GLOB.floor_cpu)
		// avoids byond sleeping the loop and causing the MC to infinistall
		// Run first to set a floor for sustain to spike up to
		CONSUME_UNTIL(min(GLOB.floor_cpu, 500))

	if(GLOB.sustain_cpu && prob(GLOB.sustain_cpu_chance))
		CONSUME_UNTIL(min(GLOB.sustain_cpu, 500))

	if(GLOB.spike_cpu)
		CONSUME_UNTIL(min(GLOB.spike_cpu, 10000))
		GLOB.spike_cpu = 0

	// attempt to correct cpu overrun
	var/cpu_corrected = FALSE
	// If we're supposed to be correcting cpu
	if(GLOB.attempt_corrective_cpu && GLOB.corrective_cpu_threshold > TICK_USAGE)
		cpu_corrected = TRUE
		CONSUME_UNTIL(GLOB.corrective_cpu_threshold)
	// or if we HAVE already corrected cpu with the MC (roughly, hard to be exact about this stuff)
	else if(!GLOB.use_old_mc_limit && GLOB.corrective_cpu_threshold + GLOB.corrective_cpu_threshold * 0.05 > TICK_USAGE)
		cpu_corrected = TRUE
	if(tick_info)
		tick_info.corrected_ticks[current_index] = cpu_corrected

	GLOB.cpu_tracker.update_display()

	if(tick_info)
		tick_info.tick_cpu_usage[current_index] = TICK_USAGE

INITIALIZE_IMMEDIATE(/atom/movable/screen/usage_display)
GLOBAL_DATUM_INIT(cpu_tracker, /atom/movable/screen/usage_display, new())
/atom/movable/screen/usage_display
	screen_loc = "LEFT:8, CENTER-4:20"
	plane = CPU_DEBUG_PLANE
	layer = CPU_DISPLAY_LAYER
	maptext_width = 512
	maptext_height = 512
	alpha = 220
	clear_with_screen = FALSE
	// how many people are looking at us right now?
	var/viewer_count = 0
	/// What modes CAN the graph display?
	var/list/graph_options = list(
		USAGE_DISPLAY_CPU,
		USAGE_DISPLAY_MC,
		USAGE_DISPLAY_POST_TICK,
	)
	var/atom/movable/screen/graph_display/bars/cpu_display/graph_display
	var/display_graph = TRUE

/atom/movable/screen/usage_display/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	graph_display = new(null, null)
	graph_display.setup()
	graph_display.set_display_mode(USAGE_DISPLAY_CPU)

/atom/movable/screen/usage_display/Destroy()
	QDEL_NULL(graph_display)
	return ..()

/atom/movable/screen/usage_display/proc/update_display()
	if(viewer_count <= 0)
		return
	graph_display.refresh_thresholds()

	var/datum/tick_holder/tick_info = GLOB.tick_info
	var/list/cpu_values = tick_info.cpu_values
	var/list/verb_cost = tick_info.verb_cost
	var/list/pre_tick_cpu_usage = tick_info.pre_tick_cpu_usage
	var/last_index = TICK_INFO_TICK2INDEX(world.time - 1)
	var/full_time = TICKS2DS(TICK_INFO_SIZE) / 10 // convert from ticks to seconds

	maptext = "<div style=\"background-color:#FFFFFF; color:#000000;\">\
		Toggles: \
			<a href='byond://?src=[REF(src)];act=toggle_movement'>New Glide [GLOB.use_new_glide]</a> \
			<a href='byond://?src=[REF(src)];act=toggle_compensation'>CPU Compensation [GLOB.attempt_corrective_cpu]</a> \
			<a href='byond://?src=[REF(src)];act=toggle_mc_limit'>Dynamic MC Limit [GLOB.use_old_mc_limit]</a> \
			<a href='byond://?src=[REF(src)];act=toggle_graph'>CPU Graphing [display_graph]</a>\n\
		Glide: New ([GLOB.glide_size_multiplier]) Old ([GLOB.old_glide_size_multiplier])\n\
		Graph: \
			Displaying \[<a href='byond://?src=[REF(src)];act=set_graph_mode'>[graph_display.display_mode]</a>\] \
			<a href='byond://?src=[REF(src)];act=freeze_graph'>[graph_display.freeze ? "Thaw" : "Freeze"]</a> \
			Max Displayable Value \[<a href='byond://?src=[REF(src)];act=set_graph_scale'>[graph_display.max_displayable_cpu]</a>\]\n\
		Floor: <a href='byond://?src=[REF(src)];act=set_floor'>[GLOB.floor_cpu]</a>\n\
		Sustain: <a href='byond://?src=[REF(src)];act=set_sustain_cpu'>[GLOB.sustain_cpu]</a> \
			<a href='byond://?src=[REF(src)];act=set_sustain_chance'>[GLOB.sustain_cpu_chance]%</a>\n\
		Spike: <a href='byond://?src=[REF(src)];act=set_spike'>[GLOB.spike_cpu]</a>\n\
		Tick: [FORMAT_CPU(world.time / world.tick_lag)]\n\
		Glide Ratio: <a href='byond://?src=[REF(src)];act=set_glide_ratio'>[GLOB.glide_threshold_ratio]</a>%\n\
		Correction Ideal: <a href='byond://?src=[REF(src)];act=set_corrective_target'>[FORMAT_CPU(GLOB.corrective_cpu_target)]</a>\n\
		Correction Ratio: <a href='byond://?src=[REF(src)];act=set_corrective_ratio'>[GLOB.corrective_cpu_ratio]</a>%\n\
		Correction Target: [FORMAT_CPU(GLOB.corrective_cpu_threshold)]\n\
		Correction Distance: [FORMAT_CPU(GLOB.corrective_cpu_target - cpu_values[last_index])]\n\
		Correction Cost: [FORMAT_CPU(GLOB.corrective_cpu_cost)]\n\
		Frame Behind CPU: [FORMAT_CPU(cpu_values[last_index])]\n\
		Frame Behind Pre Tick: [FORMAT_CPU(pre_tick_cpu_usage[last_index])]\n\
		Frame Behind Tick: [FORMAT_CPU(tick_info.tick_cpu_usage[last_index])]\n\
		Frame Behind ~Map Cpu: [FORMAT_CPU(world.map_cpu)]\n\
		Frame Behind ~Verb: [FORMAT_CPU(verb_cost[last_index])]\n\
		<div style=\"color:#FF0000;\">\
			Max CPU [full_time]s: [FORMAT_CPU(max(cpu_values))]\n\
			Max Pre Tick [full_time]s: [FORMAT_CPU(max(pre_tick_cpu_usage))]\n\
			Max Tick [full_time]s: [FORMAT_CPU(max(tick_info.tick_cpu_usage))]\n\
			Max ~Map [full_time]s: [FORMAT_CPU(max(tick_info.map_cpu_usage))]\n\
			Max ~Verb [full_time]s: [FORMAT_CPU(max(verb_cost))]\n\
		</div>\
		<div style=\"color:#0096FF;\">\
			Min CPU [full_time]s: [FORMAT_CPU(min(cpu_values))]\n\
			Min Pre Tick [full_time]: [FORMAT_CPU(min(pre_tick_cpu_usage))]\n\
			Min Tick [full_time]s: [FORMAT_CPU(min(tick_info.tick_cpu_usage))]\n\
			Min ~Map [full_time]s: [FORMAT_CPU(min(tick_info.map_cpu_usage))]\n\
			Min ~Verb [full_time]s: [FORMAT_CPU(min(verb_cost))]\
		</div>\n\
		CPU Drift Max: [FORMAT_CPU(max(tick_info.cpu_error))]\n\
		CPU Drift Min: [FORMAT_CPU(min(tick_info.cpu_error))]\
	</div>"

/atom/movable/screen/usage_display/proc/toggle_cpu_debug(client/modify)
	if(modify?.displaying_cpu_debug) // I am lazy and this is a cold path
		viewer_count -= 1
		modify.screen -= src
		modify.screen -= graph_display
		UnregisterSignal(modify, COMSIG_QDELETING)
		modify?.displaying_cpu_debug = FALSE
	else
		viewer_count += 1
		modify.screen += src
		modify.screen += graph_display
		RegisterSignal(modify, COMSIG_QDELETING, PROC_REF(client_disconnected))
		modify?.displaying_cpu_debug = TRUE
		if(viewer_count == 1)
			graph_display.clear_values()
			update_display()

	for(var/atom/movable/screen/plane_master/cpu_debug/debuggin as anything in modify.mob?.hud_used?.get_true_plane_masters(CPU_DEBUG_PLANE))
		debuggin.update_visibility(modify.mob)

/atom/movable/screen/usage_display/proc/client_disconnected(client/disconnected)
	SIGNAL_HANDLER
	toggle_cpu_debug(disconnected)

/atom/movable/screen/usage_display/Topic(href, list/href_list)
	if (..())
		return
	if(usr.ckey != "lemoninthedark" && (!check_rights(R_DEBUG) || !check_rights(R_SERVER)))
		return FALSE
	switch(href_list["act"])
		if("toggle_movement")
			GLOB.use_new_glide = !GLOB.use_new_glide
			return TRUE
		if("toggle_compensation")
			GLOB.attempt_corrective_cpu = !GLOB.attempt_corrective_cpu
			return TRUE
		if("toggle_mc_limit")
			GLOB.use_old_mc_limit = !GLOB.use_old_mc_limit
			return TRUE
		if("toggle_graph")
			display_graph = !display_graph
			if(display_graph)
				graph_display.alpha = 255
			else
				graph_display.alpha = 0
			return TRUE
		if("set_graph_mode")
			var/mode = tgui_input_list(usr, "What kind of info should we graph?", "Graph Mode?", graph_options)
			if(!(mode in graph_options))
				return
			graph_display.set_display_mode(mode)
			return TRUE
		if("set_graph_scale")
			var/current_value = graph_display.max_displayable_cpu
			var/max_cpu = tgui_input_number(usr, "What should be the highest displayable cpu value?", "Max CPU", max_value = INFINITY, min_value = 0, default = current_value) || 0
			graph_display.set_max_display(max_cpu)
			return TRUE
		if("freeze_graph")
			graph_display.freeze = !graph_display.freeze
			if(!graph_display.freeze) // Clear display on thaw
				graph_display.clear_values()
			return TRUE
		if("set_corrective_target")
			var/target_cpu = tgui_input_number(usr, "What should we attempt to correct up to?", "Correct CPU", max_value = INFINITY, min_value = 0, default = GLOB.corrective_cpu_target) || 0
			GLOB.corrective_cpu_target = target_cpu
			return TRUE
		if("set_corrective_ratio")
			var/target_ratio = tgui_input_number(usr, "How tolerant of distance from the average should we be?", "Correct CPU Ratio", max_value = INFINITY, min_value = 0, default = GLOB.corrective_cpu_ratio) || 0
			GLOB.corrective_cpu_ratio = target_ratio
			return TRUE
		if("set_glide_ratio")
			var/target_ratio = tgui_input_number(usr, "How tolerant of distance from the average should we be?", "Glide Ratio", max_value = INFINITY, min_value = 0, default = GLOB.glide_threshold_ratio) || 0
			GLOB.glide_threshold_ratio = target_ratio
			return TRUE
		if("set_floor")
			var/floor_cpu = tgui_input_number(usr, "How low should we allow the cpu to go?", "Floor CPU", max_value = INFINITY, min_value = 0, default = 0) || 0
			GLOB.floor_cpu = floor_cpu
			return TRUE
		if("set_sustain_cpu")
			var/sustain_cpu = tgui_input_number(usr, "What should we randomly set our cpu to?", "Sustain CPU", max_value = INFINITY, min_value = 0, default = 0) || 0
			GLOB.sustain_cpu = sustain_cpu
			return TRUE
		if("set_sustain_chance")
			var/sustain_cpu_chance = tgui_input_number(usr, "What % of the time should we floor at Sustain CPU", "Sustain CPU %", max_value = 100, min_value = 0, default = 0) || 0
			GLOB.sustain_cpu_chance = sustain_cpu_chance
			return TRUE
		if("set_spike")
			var/spike_cpu = tgui_input_number(usr, "How high should we spike cpu usage", "Spike CPU", max_value = INFINITY, min_value = 0, default = 0) || 0
			GLOB.spike_cpu = spike_cpu
			return TRUE

/// Holds and tracks information about our current tick
/// Global datum, for real, I am so sorry
/datum/tick_holder
	var/list/cpu_values = new /list(TICK_INFO_SIZE)
	var/list/avg_cpu_values = new /list(TICK_INFO_SIZE)
	var/list/tick_cpu_usage = new /list(TICK_INFO_SIZE)
	var/list/pre_tick_cpu_usage = new /list(TICK_INFO_SIZE)
	var/list/map_cpu_usage = new /list(TICK_INFO_SIZE)
	var/list/verb_cost = new /list(TICK_INFO_SIZE)
	var/list/cpu_error = new /list(TICK_INFO_SIZE)
	var/list/corrected_ticks = new /list(TICK_INFO_SIZE)
	var/cpu_index = 1
	var/last_cpu_update = -1

// Not initialized, because we have to do that manually
// That's how fucked we are
GLOBAL_REAL(____tick_info, /datum/tick_holder)
GLOBAL_DATUM(tick_info, /datum/tick_holder)
/// Inserts our current world.cpu value into our rolling lists
/// Its job is to pull the actual usage last tick instead of the moving average
/world/proc/refresh_cpu_values()
	if(!____tick_info)
		____tick_info = new()
	if(GLOB)
		GLOB.tick_info = ____tick_info

	var/datum/tick_holder/tick_info = ____tick_info
	if(tick_info.last_cpu_update == world.time)
		return

	tick_info.last_cpu_update = world.time
	// info about the last game tick so it should be logged as the last game tick
	var/cpu_index = TICK_INFO_TICK2INDEX(world.time - 1)
	tick_info.cpu_index = cpu_index
	// cache for sonic speed
	var/list/cpu_values = tick_info.cpu_values
	var/avg_cpu = world.cpu

	// ok so world.cpu is a 16 entry wide moving average of the actual cpu value
	// because fuck you
	// I want the ACTUAL unrolled value, so I need to deaverage it. this is possible because we have access to ALL values and also math
	// yes byond does average against a constant window size, it doesn't account for a lack of values initially it just sorta assumes they exist.
	// ♪ it ain't me, it ain't me ♪

	var/real_cpu = current_true_cpu()

	var/calculated_avg = real_cpu
	for(var/i in 1 to INTERNAL_CPU_SIZE - 1)
		calculated_avg += cpu_values[WRAP(cpu_index - i, 1, TICK_INFO_SIZE + 1)]
	var/inbuilt_error = world.cpu * INTERNAL_CPU_SIZE - calculated_avg
	// (95.7994 * 16) - 1536.35 == -3.3
	// (a+b+c+d...) / 16 * 16 - (a+b+c+d...) == -g
	var/tick_and_map = tick_info.tick_cpu_usage[cpu_index] + world.map_cpu

	cpu_values[cpu_index] = real_cpu
	tick_info.avg_cpu_values[cpu_index] = avg_cpu
	tick_info.map_cpu_usage[cpu_index] = world.map_cpu
	tick_info.verb_cost[cpu_index] = real_cpu - tick_and_map
	tick_info.cpu_error[cpu_index] = inbuilt_error
	GLOB?.cpu_tracker.update_display()

/proc/update_glide_compensation()
	world.refresh_cpu_values()
	var/datum/tick_holder/tick_info = ____tick_info
	var/list/cpu_values = tick_info.cpu_values
	var/list/corrected_ticks = tick_info.corrected_ticks

	var/capped_sum = 0
	var/non_zero = 0
	var/corrected_sum = 0
	var/non_zero_corrected = 0
	for(var/i in 1 to length(cpu_values))
		var/value = cpu_values[i]
		capped_sum += max(value, 100)
		if(corrected_ticks[i])
			corrected_sum += value
			if(value != 0)
				non_zero_corrected += 1
		if(value != 0)
			non_zero += 1

	var/first_capped_average = non_zero ? capped_sum / non_zero : 1
	var/trimmed_capped_sum = 0
	var/cap_used = 0
	var/first_corrected_average = non_zero_corrected ? corrected_sum / non_zero_corrected : 1
	var/trimmed_max_value = 0
	for(var/i in 1 to length(cpu_values))
		var/value = cpu_values[i]
		// If we deviate more then 30% above the average (since we care about filtering spikes), skip us over
		if(value && max(value, 100) / first_capped_average - 1 <= GLOB.glide_threshold_ratio / 100)
			trimmed_capped_sum += max(value, 100)
			cap_used += 1
		if(corrected_ticks[i] && value / first_corrected_average - 1 <= GLOB.corrective_cpu_ratio / 100)
			trimmed_max_value = max(value, trimmed_max_value)

	var/final_capped_average = trimmed_capped_sum ? trimmed_capped_sum / cap_used : first_capped_average
	GLOB.glide_size_multiplier = min(100 / final_capped_average, 1)

	var/final_corrected_value = trimmed_max_value ? trimmed_max_value : first_corrected_average
	if(final_corrected_value > GLOB.corrective_cpu_target)
		GLOB.corrective_cpu_threshold = GLOB.corrective_cpu_target - (final_corrected_value - GLOB.corrective_cpu_target)
		GLOB.corrective_cpu_cost = final_corrected_value
	else
		GLOB.corrective_cpu_threshold = GLOB.corrective_cpu_target
		GLOB.corrective_cpu_cost = 0

#undef TICK_INFO_INDEX
#undef TICK_INFO_TICK2INDEX
#undef FORMAT_CPU
#undef TICK_INFO_SIZE

/// Initializes TGS and loads the returned revising info into GLOB.revdata
/world/proc/InitTgs()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	GLOB.revdata.load_tgs_info()

/// Runs after config is loaded but before Master is initialized
/world/proc/ConfigLoaded()
	// Everything in here is prioritized in a very specific way.
	// If you need to add to it, ask yourself hard if what your adding is in the right spot
	// (i.e. basically nothing should be added before load_admins() in here)

	// Try to set round ID
	SSdbcore.InitializeRound()

	SetupLogs()

	load_admins()
	load_mentors()
	MentorizeAdmins()

	load_poll_data()

	LoadVerbs(/datum/verbs/menu)

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

/// Runs after the call to Master.Initialize, but before the delay kicks in. Used to turn the world execution into some single function then exit
/world/proc/RunUnattendedFunctions()
	#ifdef UNIT_TESTS
	HandleTestRun()
	#endif

	#ifdef AUTOWIKI
	setup_autowiki()
	#endif

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	CONFIG_SET(number/round_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(RunUnitTests))
#else
	cb = VARSET_CALLBACK(SSticker, force_ending, ADMIN_FORCE_END_ROUND)
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/// Returns a list of data about the world state, don't clutter
/world/proc/get_world_state_for_logging()
	var/data = list()
	data["tick_usage"] = world.tick_usage
	data["tick_lag"] = world.tick_lag
	data["time"] = world.time
	data["timestamp"] = rustg_unix_timestamp()
	return data

/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD")
		GLOB.log_directory = "data/logs/[texttime]/round-"
		GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD")]_"
		GLOB.demo_directory = "data/replays"
		GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			GLOB.picture_log_directory += "[timestamp]"
			GLOB.picture_logging_prefix += "T_[timestamp]_"
	else
		GLOB.log_directory = "data/logs/[override_dir]"
		GLOB.picture_logging_prefix = "O_[override_dir]_"
		GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	GLOB.demo_log = "[GLOB.demo_directory]/[GLOB.round_id]_demo.txt" //Guh //Monkestation Edit: REPLAYS
	logger.init_logging()

	if(Tracy.trace_path)
		rustg_file_write("[Tracy.trace_path]", "[GLOB.log_directory]/tracy.loc")

	var/latest_changelog = file("[global.config.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM") + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : 0 //for telling if the changelog has changed recently

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#else
	if (TgsAvailable()) // why
		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.
#endif

/world/Topic(T, addr, master, key)
	TGS_TOPIC //redirect to server tools if necessary

	/// This is kinda wonky but we first split the topic
	var/static/list/topic_handlers = TopicHandlers()

	var/list/input = params2list(T)
	if(input[1] == "TWITCH-API")
		SStwitch.handle_topic(input)

	var/datum/world_topic/handler
	for(var/I in topic_handlers)
		if(I in input)
			handler = topic_handlers[I]
			break

	if((!handler || initial(handler.log)) && config && CONFIG_GET(flag/log_world_topic))
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/AnnouncePR(announcement, list/payload)
	var/static/list/PRcounts = list() //PR id -> number of times announced this round
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > CONFIG_GET(number/pr_announcements_per_round))
			return

	var/final_composed = span_announce("PR: [announcement]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "[GLOB.log_directory]/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0) //yes, 0, this'll let Reboot finish and prevent byond memes
	del(src) //shut it down

/world/Reboot(reason = 0, fast_track = FALSE)
	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, span_boldannounce("Rebooting World immediately due to host request."))
	else
		to_chat(world, span_boldannounce("Rebooting world..."))
		Master.Shutdown() //run SS shutdowns

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#endif

	if(TgsAvailable())
		var/do_hard_reboot
		// check the hard reboot counter
		var/ruhr = CONFIG_GET(number/rounds_until_hard_restart)
		switch(ruhr)
			if(-1)
				do_hard_reboot = FALSE
			if(0)
				do_hard_reboot = TRUE
			else
				if(GLOB.restart_counter >= ruhr)
					do_hard_reboot = TRUE
				else
					text2file("[++GLOB.restart_counter]", RESTART_COUNTER_PATH)
					do_hard_reboot = FALSE

		if(do_hard_reboot)
			log_world("World hard rebooted at [time_stamp()]")
			shutdown_logging() // See comment below.
			world.cleanup_external_cpu()
			QDEL_NULL(Tracy)
			QDEL_NULL(Debugger)
			SSplexora.notify_shutdown(PLEXORA_SHUTDOWN_KILLDD)
			TgsEndProcess()
			return ..()

	SSplexora.notify_shutdown()
	log_world("World rebooted at [time_stamp()]")

	shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
	world.cleanup_external_cpu()
	QDEL_NULL(Tracy)
	QDEL_NULL(Debugger)

	TgsReboot() // TGS can decide to kill us right here, so it's important to do it last

	..()

/world/Del()
	world.cleanup_external_cpu()
	QDEL_NULL(Tracy)
	QDEL_NULL(Debugger)
	. = ..()

/world/proc/update_status()

	var/list/features = list()

	if(LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS))
		features += "closed"

	var/new_status = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if (server_name)
			new_status += "<b>[server_name]</b> "
		if(!CONFIG_GET(flag/norespawn))
			features += "respawn"
		if(!CONFIG_GET(flag/allow_ai))
			features += "AI disabled"
		hostedby = CONFIG_GET(string/hostedby)

	if (CONFIG_GET(flag/station_name_in_hub_entry))
		new_status += " &#8212; <b>[station_name()]</b>"

	var/players = GLOB.clients.len

	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full

	if (!host && hostedby)
		features += "hosted by <b>[hostedby]</b>"

	if(length(features))
		new_status += ": [jointext(features, ", ")]"

	new_status += "<br>Beginner Friendly: <b>Learn to play SS13!</b>"
	new_status += "<br>Roleplay: \[<b>Medium-Rare</b>\]"

	new_status += "<br>Time: <b>[gameTimestamp("hh:mm")]</b>"
	if(SSmapping.current_map)
		new_status += "<br>Map: <b>[SSmapping.current_map.map_path == CUSTOM_MAP_PATH ? "Uncharted Territory" : SSmapping.current_map.map_name]</b>"
	var/alert_text = SSsecurity_level.get_current_level_as_text()
	if(alert_text)
		new_status += "<br>Alert: <b>[capitalize(alert_text)]</b>"

	status = new_status

/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"

/**
 * Handles incresing the world's maxx var and intializing the new turfs and assigning them to the global area.
 * If map_load_z_cutoff is passed in, it will only load turfs up to that z level, inclusive.
 * This is because maploading will handle the turfs it loads itself.
 */
/world/proc/increase_max_x(new_maxx, map_load_z_cutoff = maxz)
	if(new_maxx <= maxx)
		return
	var/old_max = world.maxx
	maxx = new_maxx
	if(!map_load_z_cutoff)
		return
	var/area/global_area = GLOB.areas_by_type[world.area] // We're guaranteed to be touching the global area, so we'll just do this
	LISTASSERTLEN(global_area.turfs_by_zlevel, map_load_z_cutoff, list())
	for (var/zlevel in 1 to map_load_z_cutoff)
		var/list/to_add = block(
			locate(old_max + 1, 1, zlevel),
			locate(maxx, maxy, zlevel))

		global_area.turfs_by_zlevel[zlevel] += to_add

/world/proc/increase_max_y(new_maxy, map_load_z_cutoff = maxz)
	if(new_maxy <= maxy)
		return
	var/old_maxy = maxy
	maxy = new_maxy
	if(!map_load_z_cutoff)
		return
	var/area/global_area = GLOB.areas_by_type[world.area] // We're guarenteed to be touching the global area, so we'll just do this
	LISTASSERTLEN(global_area.turfs_by_zlevel, map_load_z_cutoff, list())
	for (var/zlevel in 1 to map_load_z_cutoff)
		var/list/to_add = block(
			locate(1, old_maxy + 1, 1),
			locate(maxx, maxy, map_load_z_cutoff))
		global_area.turfs_by_zlevel[zlevel] += to_add

/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()
	SSai_controllers.on_max_z_changed()

/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()


/world/proc/change_tick_lag(new_value = 0.5)
	if(new_value <= 0)
		CRASH("change_tick_lag() called with [new_value] new_value.")
	if(tick_lag == new_value)
		return //No change required.

	tick_lag = new_value
	on_tickrate_change()


/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()
#ifndef DISABLE_DREAMLUAU
	DREAMLUAU_SET_EXECUTION_LIMIT_MILLIS(tick_lag * 100)
#endif

/world/Profile(command, type, format)
	if((command & PROFILE_STOP) || !global.config?.loaded || !CONFIG_GET(flag/forbid_all_profiling))
		. = ..()

#undef NO_INIT_PARAMETER
#undef OVERRIDE_LOG_DIRECTORY_PARAMETER
#undef USE_TRACY_PARAMETER
#undef RESTART_COUNTER_PATH
