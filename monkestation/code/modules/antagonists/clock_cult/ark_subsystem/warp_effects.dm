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
