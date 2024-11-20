///A subsystem to manage the global effects of clock cult
//#define SERVANT_CAPACITY_TO_GIVE 2 //how many extra servant slots do we give on first charged crystal
SUBSYSTEM_DEF(the_ark)
	name = "The Clockwork Ark"
	wait = 1 SECOND
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME

	///The list of anchoring crystals, value is 0 is uncharged and 1 if charged
	var/list/anchoring_crystals
	///How many charged anchoring crystals are there
	var/charged_anchoring_crystals = 0
	///Dimension theme used for transforming turfs
	var/datum/dimension_theme/clockwork/clock_dimension_theme
	///Assoc list of the original names of areas that are valid to summon anchoring crystals keyed to its area
	var/list/valid_crystal_areas
	///The pool of hallucinations we can trigger
	var/list/hallucination_pool
	///How many clockwork airlocks have been created on reebe, used for limiting airlock spam
	var/reebe_clockwork_airlock_count = 0
	///How much power does the cult have stored
	var/clock_power = 2500
	///What is the maximum amount of power the cult can have stored
	var/max_clock_power = 2500
	///The list of areas that has been marked by the cult
	var/list/marked_areas

/datum/controller/subsystem/the_ark/Initialize()
	anchoring_crystals = list()
	marked_areas = list()
	clock_dimension_theme = new(is_cult = TRUE)
	hallucination_pool = list(
		/datum/hallucination/fake_item/clockwork_slab = 2,
		/datum/hallucination/nearby_fake_item/clockwork_slab = 2,
		/datum/hallucination/hazard/clockwork_skewer = 1,
		/datum/hallucination/delusion/preset/clock_cultists = 1,
		/datum/hallucination/fake_sound/weird/clockcult_kindle = 2,
		/datum/hallucination/fake_sound/weird/clockcult_warp = 2,
	)
	initialized = TRUE

/datum/controller/subsystem/the_ark/fire(resumed)
	if(charged_anchoring_crystals)
		handle_charged_crystals()

//boy this sure is some fun code
/datum/controller/subsystem/the_ark/proc/handle_charged_crystals()
	if(prob(charged_anchoring_crystals))
		crystal_warp_minds()

	if(charged_anchoring_crystals >= 2 && prob(charged_anchoring_crystals))
		crystal_warp_machines()

	if(charged_anchoring_crystals >= 3 && prob(charged_anchoring_crystals))
		crystal_warp_space()

/datum/controller/subsystem/the_ark/proc/crystal_warp_minds()
	var/list/players = GLOB.alive_player_list.Copy()
	var/mob/living/selected_player = pick_n_take(players)
	var/sanity = 0
	if(!selected_player)
		return

	while(sanity < 100 && (IS_CLOCK(selected_player) || !is_station_level(selected_player.z)))
		if(!length(players))
			return
		sanity++
		selected_player = pick_n_take(players)

	if(prob(50))
		selected_player.cause_hallucination(pick_weight(hallucination_pool), "The Clockwork Ark")
	else
		to_chat(selected_player, span_warning(pick(list("You hear a faint ticking in the back of your mind", "You smell something metallic", \
			"You see a flash of light out of the corner of your eye", "You feel an otherworldly presence", "You feel like your forgetting something"))))

//making these their own procs for eaiser to read code
/datum/controller/subsystem/the_ark/proc/crystal_warp_machines()
	switch(rand(1, 3))
		if(1) //randomly mess with the settings of an APC with a low chance to emag it
			var/list/apcs = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc, /obj/machinery/power/apc/worn_out)
			var/obj/machinery/power/apc/picked_apc = pick_n_take(apcs) //pick_n_take() handles length checking
			if(!picked_apc)
				return
			var/sanity = 0
			while(sanity < 100 && length(apcs) && !is_station_level(picked_apc.z))
				picked_apc = pick_n_take(apcs)
				sanity++
			if(picked_apc)
				if(prob(30))
					picked_apc.overload_lighting()
				else
					picked_apc.lighting = picked_apc.setsubsystem(1)
				if(prob(30))
					picked_apc.equipment = picked_apc.setsubsystem(1)
				if(prob(30))
					picked_apc.environ = picked_apc.setsubsystem(1)
					addtimer(CALLBACK(picked_apc, TYPE_PROC_REF(/obj/machinery/power/apc, setsubsystem), rand(2, 3)), 1 MINUTE)
				if(!(picked_apc.obj_flags & EMAGGED) && prob(10))
					playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
					picked_apc.obj_flags |= EMAGGED
					picked_apc.locked = FALSE
					picked_apc.update_appearance()
		if(2) //force open an airlock and bolt it
			var/list/airlocks = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock, \
								typesof(/obj/machinery/door/airlock/maintenance) + typesof(/obj/machinery/door/airlock/bronze/clock) + /obj/machinery/door/airlock/maintenance_hatch)
			var/obj/machinery/door/airlock/picked_airlock = pick_n_take(airlocks)
			if(!picked_airlock)
				return
			var/sanity = 0
			while(sanity < 100 && length(airlocks) && (!picked_airlock.hasPower() || !is_station_level(picked_airlock.z) || picked_airlock.is_probably_external_airlock()))
				picked_airlock = pick_n_take(airlocks)
				sanity++
			if(picked_airlock)
				picked_airlock.unbolt()
				picked_airlock.open(FORCING_DOOR_CHECKS)
				picked_airlock.bolt()
		if(3) //emag a random atom from our list of valid types
			var/list/valid_emag_targets = list(
				/mob/living/simple_animal/bot,
				/mob/living/basic/bot,
				/obj/machinery/announcement_system,
				/obj/machinery/barsign,
				/obj/machinery/computer/communications,
				/obj/machinery/medical_kiosk,
				/obj/machinery/sleeper,
				/obj/machinery/computer/slot_machine,
				/obj/machinery/computer/cargo/express,
				/obj/machinery/computer/cargo,
				/obj/machinery/destructive_scanner,
				/obj/machinery/fishing_portal_generator,
				/obj/machinery/computer/holodeck,
				/obj/machinery/elevator_control_panel,
				/obj/machinery/crossing_signal,
				/obj/machinery/fax,
				/obj/machinery/chem_dispenser,
				/obj/machinery/research/anomaly_refinery,
				/obj/machinery/plumbing/growing_vat,
				/obj/machinery/computer/bsa_control,
				/obj/machinery/vending,
				/obj/machinery/clonepod,
				/obj/machinery/clonepod/experimental,
				/obj/machinery/artifact_xray,
				/obj/machinery/artifact_zapper,
				/obj/machinery/computer/operating,
				/obj/machinery/composters,
			)
			var/atom/selected_type = pick_n_take(valid_emag_targets)
			var/list/valid_type_instances = get_emag_target_type_instances(selected_type)
			var/sanity = 0
			var/obj/machinery/selected_atom
			while(!selected_atom && sanity < 10)
				sanity++
				while(!length(valid_type_instances))
					if(!length(valid_emag_targets))
						return
					selected_type = pick_n_take(valid_emag_targets)
					valid_type_instances = get_emag_target_type_instances(selected_type)
				while(!selected_atom || bot_v_machine_check(selected_atom) || !is_station_level(selected_atom.z))
					if(!length(valid_type_instances))
						selected_atom = null
						break
					selected_atom = pick_n_take(valid_type_instances)
			if(!selected_atom)
				return
			if(isbasicbot(selected_atom))
				var/mob/living/basic/bot/basic_bot = selected_atom
				basic_bot.bot_access_flags &= ~BOT_CONTROL_PANEL_OPEN | ~BOT_MAINTS_PANEL_OPEN
			else if(isbot(selected_atom))
				var/mob/living/simple_animal/bot/simple_bot = selected_atom
				simple_bot.bot_cover_flags &= BOT_COVER_OPEN | ~BOT_COVER_LOCKED
			selected_atom.emag_act()

/datum/controller/subsystem/the_ark/proc/crystal_warp_space()
	switch(rand(1, 2))
		if(1)
			var/datum/action/cooldown/spell/spacetime_dist/clock_ark/dist_spell = new
			var/turf/turf = get_random_station_turf()
			dist_spell.cast(turf)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), dist_spell), dist_spell.duration)
		if(2)
			var/list/servants = list() //technically we could adjust this everytime someone joins or leaves the cult but these last for 30 seconds so eh
			if(GLOB.main_clock_cult)
				for(var/datum/mind/servant_mind in GLOB.main_clock_cult.members)
					servants += servant_mind.current
			new /obj/effect/timestop/magic/clock_ark(get_random_station_turf(), 1, 30 SECONDS, servants)
			return

/datum/controller/subsystem/the_ark/proc/get_emag_target_type_instances(input_path)
	if(ispath(input_path, /obj/machinery))
		return SSmachines.get_machines_by_type(input_path)
	if(ispath(input_path, /mob/living/simple_animal/bot) || ispath(input_path, /mob/living/basic/bot))
		return GLOB.bots_list.Copy()

//OH YEAH I LOVE GOOD CODE
/datum/controller/subsystem/the_ark/proc/bot_v_machine_check(atom/checked_atom)
	if(ismachinery(checked_atom))
		var/obj/machinery/checked_machine = checked_atom
		return checked_machine.obj_flags & EMAGGED
	if(isbasicbot(checked_atom))
		var/mob/living/basic/bot/checked_basic_bot = checked_atom
		return checked_basic_bot.bot_access_flags & BOT_COVER_EMAGGED
	if(istype(checked_atom, /mob/living/simple_animal/bot))
		var/mob/living/simple_animal/bot/checked_bot = checked_atom
		return checked_bot.bot_cover_flags & BOT_COVER_EMAGGED

/datum/controller/subsystem/the_ark/proc/convert_area_turfs(area/converted_area)
	var/timer_counter = 1 //used by the addtimer()
	var/list/turfs_to_transform = list()
	for(var/turf/transformed_turf in converted_area)
		turfs_to_transform += transformed_turf

	shuffle_inplace(turfs_to_transform)
	for(var/turf/turf_to_transform in turfs_to_transform)
		if(!clock_dimension_theme.can_convert(turf_to_transform))
			continue
		addtimer(CALLBACK(src, PROC_REF(do_turf_conversion), turf_to_transform), 3 * timer_counter)
		timer_counter++

/datum/controller/subsystem/the_ark/proc/do_turf_conversion(turf/converted_turf)
	if(QDELETED(src) || !clock_dimension_theme.can_convert(converted_turf))
		return

	clock_dimension_theme.apply_theme(converted_turf)
	new /obj/effect/temp_visual/ratvar/beam(converted_turf)
	if(istype(converted_turf, /turf/closed/wall))
		new /obj/effect/temp_visual/ratvar/wall(converted_turf)
	else if(istype(converted_turf, /turf/open/floor))
		new /obj/effect/temp_visual/ratvar/floor(converted_turf)

/datum/controller/subsystem/the_ark/proc/on_crystal_charged(obj/structure/destructible/clockwork/anchoring_crystal/charged_crystal)
	charged_anchoring_crystals++
	anchoring_crystals[charged_crystal] = 1
	SEND_SIGNAL(src, COMSIG_ANCHORING_CRYSTAL_CHARGED, charged_crystal)
	var/datum/scripture/create_structure/anchoring_crystal/crystal_script
	addtimer(CALLBACK(src, PROC_REF(clear_shuttle_interference), charged_crystal), \
			(ANCHORING_CRYSTAL_COOLDOWN - (ANCHORING_CRYSTAL_CHARGE_DURATION SECONDS)) + initial(crystal_script.invocation_time))

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
/datum/controller/subsystem/the_ark/proc/block_shuttle(datum/blocker)
	if(SSshuttle.admin_emergency_disabled || SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		return

	SSshuttle.last_mode = SSshuttle.emergency.mode
	SSshuttle.last_call_time = SSshuttle.emergency.timeLeft(1)
	SSshuttle.emergency_no_recall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED

///renables the shuttle
/datum/controller/subsystem/the_ark/proc/clear_shuttle_interference(datum/unblocker)
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
/datum/controller/subsystem/the_ark/proc/get_charged_anchor_crystals()
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
