/datum/round_event/antagonist
	fakeable = FALSE
	end_when = 6000 //This is so prompted picking events have time to run //TODO: refactor events so they can be the masters of themselves, instead of relying on some weirdly timed vars

	// ALL of these variables are internal. Check the control event to change them
	/// The antag flag passed from control
	var/antag_flag
	/// The antag datum passed from control
	var/antag_datum
	/// The antag count passed from control
	var/antag_count
	/// The restricted roles (jobs) passed from control
	var/list/restricted_roles
	/// The minds we've setup in setup() and need to finalize in start()
	var/list/setup_minds = list()
	/// Whether we prompt the players before picking them.
	var/prompted_picking = FALSE
	/// DO NOT SET THIS MANUALLY, THIS IS INHERITED FROM THE EVENT CONTROLLER ON NEW
	var/list/extra_spawned_events
	// Same as above
	var/list/preferred_events

/datum/round_event/antagonist/New(my_processing, datum/round_event_control/event_controller)
	. = ..()
	if(istype(event_controller, /datum/round_event_control/antagonist))
		var/datum/round_event_control/antagonist/antag_event_controller = event_controller
		if(antag_event_controller)
			if(antag_event_controller.extra_spawned_events)
				extra_spawned_events = fill_with_ones(antag_event_controller.extra_spawned_events)
			if(antag_event_controller.preferred_events)
				preferred_events = fill_with_ones(antag_event_controller.preferred_events)

/datum/round_event/antagonist/setup()
	var/datum/round_event_control/antagonist/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/possible_candidates = cast_control.get_candidates()
	var/list/candidates = list()
	if(cast_control == SSgamemode.current_roundstart_event && length(SSgamemode.roundstart_antag_minds))
		log_storyteller("Running roundstart antagonist assignment, event type: [src.type], roundstart_antag_minds: [english_list(SSgamemode.roundstart_antag_minds)]")
		for(var/datum/mind/antag_mind in SSgamemode.roundstart_antag_minds)
			if(!antag_mind.current)
				log_storyteller("Roundstart antagonist setup error: antag_mind([key_name(antag_mind)]) in roundstart_antag_minds without a set mob")
				continue
			candidates += antag_mind.current
			SSgamemode.roundstart_antag_minds -= antag_mind
			log_storyteller("Roundstart antag_mind, [key_name(antag_mind)]")

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in possible_candidates)
		cliented_list += mob.client

	if(length(cliented_list))
		mass_adjust_antag_rep(cliented_list, 1)

	var/list/weighted_candidates = return_antag_rep_weight(possible_candidates)

	while(length(weighted_candidates) && length(candidates) < antag_count) //both of these pick_n_take from weighted_candidates so this should be fine
		if(prompted_picking)
			var/picked_ckey = pick_n_take_weighted(weighted_candidates)
			var/client/picked_client = GLOB.directory[picked_ckey]
			if(QDELETED(picked_client))
				continue
			var/mob/picked_mob = picked_client.mob
			log_storyteller("Prompted antag event mob: [key_name(picked_mob)], special role: [picked_mob.mind?.special_role ? picked_mob.mind.special_role : "none"]")
			if(picked_mob)
				candidates |= SSpolling.poll_candidates(
					question = "Would you like to be a [cast_control.name]?",
					check_jobban = antag_flag,
					role = antag_flag,
					poll_time = 20 SECONDS,
					group = list(picked_mob),
					alert_pic = antag_datum,
					role_name_text = lowertext(cast_control.name),
					chat_text_border_icon = antag_datum,
					show_candidate_amount = FALSE,
				)
		else
			var/picked_ckey = pick_n_take_weighted(weighted_candidates)
			var/client/picked_client = GLOB.directory[picked_ckey]
			if(QDELETED(picked_client))
				continue
			var/mob/picked_mob = picked_client.mob
			picked_mob?.mind?.picking = TRUE
			log_storyteller("Picked antag event mob: [key_name(picked_mob)], special role: [picked_mob.mind?.special_role ? picked_mob.mind.special_role : "none"]")
			candidates |= picked_mob

	var/list/picked_mobs = list()
	for(var/i in 1 to antag_count)
		if(!length(candidates))
			message_admins("A roleset event got fewer antags then its antag_count and may not function correctly.")
			break

		var/mob/candidate = pick_n_take(candidates)
		log_storyteller("Antag event spawned mob: [key_name(candidate)], special role: [candidate.mind?.special_role ? candidate.mind.special_role : "none"]")

		candidate.client?.prefs.reset_antag_rep()

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		setup_minds += candidate.mind
		candidate.mind.special_role = antag_flag
		candidate.mind.restricted_roles = restricted_roles
		picked_mobs += WEAKREF(candidate.client)

	setup = TRUE
	control.generate_image(picked_mobs)
	spawn_extra_events()

/datum/round_event/antagonist/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind, antag_mind.current)

/datum/round_event/antagonist/proc/add_datum_to_mind(datum/mind/antag_mind)
	return antag_mind.add_antag_datum(antag_datum)

/datum/round_event/antagonist/proc/spawn_extra_events(wait = 1 SECONDS)
	if(!LAZYLEN(extra_spawned_events))
		return
	var/datum/round_event_control/event_type = pick_weight(extra_spawned_events)
	if(!event_type)
		return
	var/datum/round_event_control/triggered_event = SSevents.control_by_type[event_type]
	if(wait)
		log_storyteller("[src] queued extra event [triggered_event] (running in [DisplayTimeText(wait)])")
		//wait a second to avoid any potential omnitraitor bs (it will happen anyways)
		addtimer(CALLBACK(triggered_event, TYPE_PROC_REF(/datum/round_event_control, run_event), FALSE, null, FALSE, "storyteller"), wait)
	else
		log_storyteller("[src] triggered extra event [triggered_event]")
		triggered_event.run_event(random = FALSE, event_cause = "storyteller")

/datum/round_event/antagonist/proc/create_human_mob_copy(turf/create_at, mob/living/carbon/human/old_mob, qdel_old_mob = TRUE)
	if(!old_mob?.client)
		return

	var/mob/living/carbon/human/new_character = new(create_at)
	if(!create_at)
		SSjob.SendToLateJoin(new_character)

	old_mob.client.prefs.safe_transfer_prefs_to(new_character)
	new_character.dna.update_dna_identity()
	old_mob.mind.transfer_to(new_character)
	if(old_mob.has_quirk(/datum/quirk/anime)) // stupid special case bc this quirk is basically janky wrapper shitcode around some optional appearance prefs
		new_character.add_quirk(/datum/quirk/anime)
	if(qdel_old_mob)
		qdel(old_mob)
	return new_character


/datum/round_event/antagonist/ghost/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind)

/datum/round_event/antagonist/ghost/setup()
	var/datum/round_event_control/antagonist/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	//guh
	var/list/cliented_list = list()
	for(var/mob/living/mob as anything in candidates)
		cliented_list += mob.client
	if(length(cliented_list))
		mass_adjust_antag_rep(cliented_list, 1)

	if(prompted_picking)
		candidates = SSpolling.poll_candidates(
			question = "Would you like to be a [cast_control.name]?",
			check_jobban = antag_flag,
			role = antag_flag,
			poll_time = 20 SECONDS,
			group = candidates,
			alert_pic = antag_datum,
			role_name_text = lowertext(cast_control.name),
			chat_text_border_icon = antag_datum,
		)

	var/list/weighted_candidates = return_antag_rep_weight(candidates)
	var/selected_count = 0
	while(length(weighted_candidates) && selected_count < antag_count)
		var/candidate_ckey = pick_n_take_weighted(weighted_candidates)
		var/client/candidate_client = GLOB.directory[candidate_ckey]
		if(QDELETED(candidate_client) || QDELETED(candidate_client.mob))
			continue
		var/mob/candidate = candidate_client.mob

		candidate_client.prefs?.reset_antag_rep()

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)
		var/mob/living/carbon/human/new_human = make_body(candidate)
		new_human.mind.special_role = antag_flag
		new_human.mind.restricted_roles = restricted_roles
		setup_minds += new_human.mind
		selected_count++
	setup = TRUE
