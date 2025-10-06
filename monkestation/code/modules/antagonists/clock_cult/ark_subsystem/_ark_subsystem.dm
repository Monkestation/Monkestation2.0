///A subsystem to manage the global effects of clock cult
//#define SERVANT_CAPACITY_TO_GIVE 2 //how many extra servant slots do we give on first charged crystal
PROCESSING_SUBSYSTEM_DEF(the_ark)
	name = "The Clockwork Ark"
	wait = 1 SECOND
	flags = SS_KEEP_TIMING | SS_NO_INIT | SS_HIBERNATE
	runlevels = RUNLEVEL_GAME

	///The list of anchoring crystals, value is 0 is uncharged and 1 if charged
#ifdef UNIT_TESTS
	var/list/anchoring_crystals = list()
	var/datum/dimension_theme/clockwork/clock_dimension_theme = new(is_cult = TRUE)
#else
	///The list of anchoring crystals, value is 0 is uncharged and 1 if charged
	var/list/anchoring_crystals
	///Dimension theme used for transforming turfs
	var/datum/dimension_theme/clockwork/clock_dimension_theme
#endif
	///How many charged anchoring crystals are there
	var/charged_anchoring_crystals = 0
	///Assoc list of the original names of areas that are valid to summon anchoring crystals keyed to its area
	var/list/valid_crystal_areas
	///The pool of hallucinations we can trigger
	var/list/hallucination_pool
	///How many clockwork airlocks have been created on reebe, used for limiting airlock spam
	var/reebe_clockwork_airlock_count = 0
	///How much power does the cult have stored
	var/clock_power = STANDARD_CELL_CHARGE * 0.25
	///What is the maximum amount of power the cult can have stored
	var/max_clock_power = STANDARD_CELL_CHARGE * 0.25
	///How much passive power does the cult have access to, this gets used for things like turning on structures
	var/passive_power = 15
	///The list of areas that has been marked by the cult, formatted as a filled with 1s for anti duplication
	var/list/marked_areas = list()
	///A list of all cogscarabs
	var/list/cogscarabs = list()
	///A list of all clockwork marauders
	var/list/clockwork_marauders = list()
	///A list of all the areas on reebe
	var/list/reebe_areas = list()

/datum/controller/subsystem/processing/the_ark/Initialize()
	initialized = TRUE
	anchoring_crystals = list()
	clock_dimension_theme = new(is_cult = TRUE)
	hallucination_pool = list(
		/datum/hallucination/fake_item/clockwork_slab = 2,
		/datum/hallucination/nearby_fake_item/clockwork_slab = 2,
		/datum/hallucination/hazard/clockwork_skewer = 1,
		/datum/hallucination/delusion/preset/clock_cultists = 1,
		/datum/hallucination/fake_sound/weird/clockcult_kindle = 2,
		/datum/hallucination/fake_sound/weird/clockcult_warp = 2,
	)

/datum/controller/subsystem/processing/the_ark/fire(resumed)
	if(!initialized) //we are not currently being used so just return
		return

	if(charged_anchoring_crystals)
		handle_charged_crystals()
	return ..()

///try and adjust our clock_power, returns FALSE if it would put us above our max_clock_power or below 0, set always_adjust to TRUE to make us instead just adjust to be within bounds
/datum/controller/subsystem/processing/the_ark/proc/adjust_clock_power(amount, always_adjust = FALSE)
	var/new_total = clock_power + amount
	if(always_adjust)
		clock_power = clamp(new_total, 0, max_clock_power)
		return TRUE

	if(new_total > max_clock_power || new_total < 0)
		return FALSE
	clock_power = new_total
	return TRUE

///same as adjust_clock_power() but much simpler as this does not have a max amount and is somewhat static, set only_check to TRUE to skip the actual adjustment step
/datum/controller/subsystem/processing/the_ark/proc/adjust_passive_power(amount, only_check = FALSE)
	var/new_total = passive_power + amount
	if(new_total < 0)
		return FALSE

	if(!only_check)
		passive_power = new_total
	return TRUE

///set up timed do_turf_conversion calls for the turfs in an area
/datum/controller/subsystem/processing/the_ark/proc/convert_area_turfs(area/converted_area, conversion_percent = 100, counter_override)
	var/timer_counter = counter_override || 1 //used by the addtimer()
	var/list/turfs_to_transform = list()
	for(var/i in 1 to length(converted_area.turfs_by_zlevel))
		turfs_to_transform += converted_area.turfs_by_zlevel[i]

	var/transformed_length = length(turfs_to_transform)
	var/converted_amount = round(transformed_length * (conversion_percent * 0.01))
	while(transformed_length && transformed_length > converted_amount)
		pick_n_take(turfs_to_transform)
		transformed_length = length(turfs_to_transform)

	shuffle_inplace(turfs_to_transform)
	for(var/turf/turf_to_transform in turfs_to_transform)
		if(!clock_dimension_theme.can_convert(turf_to_transform))
			continue
		addtimer(CALLBACK(src, PROC_REF(do_turf_conversion), turf_to_transform), 3 * timer_counter)
		timer_counter++
	return timer_counter //so you can do stuff once the conversion ends

///convert a turf to our dimension theme
/datum/controller/subsystem/processing/the_ark/proc/do_turf_conversion(turf/converted_turf)
	if(QDELETED(src) || !clock_dimension_theme.can_convert(converted_turf))
		return

	clock_dimension_theme.apply_theme(converted_turf)
	new /obj/effect/temp_visual/ratvar/beam(converted_turf)
	if(istype(converted_turf, /turf/closed/wall))
		new /obj/effect/temp_visual/ratvar/wall(converted_turf)
	else if(istype(converted_turf, /turf/open/floor))
		new /obj/effect/temp_visual/ratvar/floor(converted_turf)

///called when an anchoring crystal is charged
/datum/controller/subsystem/processing/the_ark/proc/on_crystal_charged(obj/structure/destructible/clockwork/anchoring_crystal/charged_crystal)
	charged_anchoring_crystals++
	anchoring_crystals[charged_crystal] = 1
	SEND_SIGNAL(src, COMSIG_ANCHORING_CRYSTAL_CHARGED, charged_crystal)
	passive_power += 5 * CLOCK_PASSIVE_POWER_PER_COG //5 APCs worth of passive power
	max_clock_power += CLOCK_MAX_POWER_PER_COG * 5
	var/datum/scripture/create_structure/anchoring_crystal/crystal_script
	addtimer(CALLBACK(src, PROC_REF(clear_shuttle_interference), charged_crystal), \
			(ANCHORING_CRYSTAL_COOLDOWN - ANCHORING_CRYSTAL_CHARGE_DURATION) + initial(crystal_script.invocation_time))

	/*if(1) //add 2 more max servants and increase replica fabricator build speed
		GLOB.main_clock_cult.max_human_servants += SERVANT_CAPACITY_TO_GIVE*/
	if(charged_anchoring_crystals == ANCHORING_CRYSTALS_TO_SUMMON + 1) //create a steam helios on reebe
		if(length(GLOB.abscond_markers))
			var/turf/created_at = get_turf(pick(GLOB.abscond_markers))
			new /obj/vehicle/sealed/mecha/steam_helios(created_at)
			new /obj/effect/temp_visual/steam(created_at)
		else if(GLOB.clock_ark)
			new /obj/vehicle/sealed/mecha/steam_helios(get_turf(GLOB.clock_ark))
		else
			message_admins("No valid location for Steam Helios creation.")

///fully disables the shuttle similar to the admin verb
/datum/controller/subsystem/processing/the_ark/proc/block_shuttle(datum/blocker)
	if(SSshuttle.admin_emergency_disabled || SSshuttle.emergency.mode == SHUTTLE_DISABLED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		return

	SSshuttle.last_mode = SSshuttle.emergency.mode
	SSshuttle.last_call_time = SSshuttle.emergency.timeLeft(1)
	SSshuttle.emergency_no_recall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED

///renables the shuttle
/datum/controller/subsystem/processing/the_ark/proc/clear_shuttle_interference(datum/unblocker)
	if(SSshuttle.admin_emergency_disabled || SSshuttle.emergency.mode != SHUTTLE_DISABLED || \
		(unblocker && GLOB.clock_ark && GLOB.clock_ark.current_state >= ARK_STATE_CHARGING && istype(unblocker, /obj/structure/destructible/clockwork/anchoring_crystal)))
		return

	SSshuttle.emergency_no_recall = FALSE
	if(SSshuttle.last_mode == SHUTTLE_DISABLED)
		SSshuttle.last_mode = SHUTTLE_IDLE

	SSshuttle.emergency.mode = SSshuttle.last_mode
	if(SSshuttle.last_call_time < 10 SECONDS && SSshuttle.last_mode != SHUTTLE_IDLE)
		SSshuttle.last_call_time = 10 SECONDS //Make sure no insta departures.
	SSshuttle.emergency.setTimer(SSshuttle.last_call_time)
	priority_announce("Emergency shuttle uplink connection regained.", "Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)

///returns how many charged anchor crystals there are
/datum/controller/subsystem/processing/the_ark/proc/get_charged_anchor_crystals()
	var/charged_count = 0
	for(var/crystal in SSthe_ark.anchoring_crystals)
		charged_count += SSthe_ark.anchoring_crystals[crystal]
	return charged_count

//#undef SERVANT_CAPACITY_TO_GIVE

/datum/action/cooldown/spell/spacetime_dist
	///The type of effect we actually spawn
	var/obj/effect/cross_action/spacetime_dist/spawned_effect_type = /obj/effect/cross_action/spacetime_dist

/datum/action/cooldown/spell/spacetime_dist/clock_ark
	name = "Clockwork Spacetime Dist"
	cooldown_time = 0
	scramble_radius = 2
	duration = 1 MINUTE
	spawned_effect_type = /obj/effect/cross_action/spacetime_dist/clock_ark

/obj/effect/cross_action/spacetime_dist/clock_ark

/obj/effect/cross_action/spacetime_dist/clock_ark/walk_link(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/living_mob = AM
		if(IS_CLOCK(living_mob))
			return
	return ..()

/obj/effect/timestop/magic/clock_ark
	icon_state = ""
	hidden = TRUE
