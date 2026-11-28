/datum/round_event/antagonist
	fakeable = FALSE
	end_when = 6000 //This is so prompted picking events have time to run //TODO: refactor events so they can be the masters of themselves, instead of relying on some weirdly timed vars

	// ALL of these variables are internal. Check the control event to change them
	/// The antag flag passed from control
	var/antag_flag
	/// The antag datum passed from control
	var/datum/antagonist/antag_datum
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
	/// If set, setup() only considers these mobs instead of everyone who's eligible. Cleared once setup() is done with it.
	var/list/candidate_pool

/datum/round_event/antagonist/New(my_processing, datum/round_event_control/antagonist/event_controller)
	. = ..()
	if(istype(event_controller))
		candidate_pool = event_controller.next_candidate_pool
		if(event_controller.extra_spawned_events)
			extra_spawned_events = fill_with_ones(event_controller.extra_spawned_events)
		if(event_controller.preferred_events)
			preferred_events = fill_with_ones(event_controller.preferred_events)

/datum/round_event/antagonist/setup()
	var/datum/round_event_control/antagonist/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/pool_was_handed_in = !isnull(candidate_pool)
	var/list/possible_candidates = cast_control.get_candidates(candidate_pool)
	candidate_pool = null
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

	// the roll before spawn can pick more than the post-spawn count wants, those picks are already committed
	antag_count = max(antag_count, length(candidates))
	possible_candidates -= candidates
	var/inherited_count = length(candidates)

	if(prompted_picking)
		possible_candidates = SSgamemode.remove_recent_decliners(possible_candidates)
	var/list/weighted_candidates = get_antag_roll_weights(possible_candidates)
	var/list/pool_ckeys = assoc_to_keys(weighted_candidates)

	while(length(weighted_candidates) && length(candidates) < antag_count) //both of these pick_n_take from weighted_candidates so this should be fine
		if(prompted_picking)
			var/picked_ckey = pick_n_take_weighted(weighted_candidates)
			var/client/picked_client = GLOB.directory[picked_ckey]
			if(QDELETED(picked_client))
				continue
			var/mob/picked_mob = picked_client.mob
			log_storyteller("Prompted antag event mob: [key_name(picked_mob)], special role: [picked_mob.mind?.special_role ? picked_mob.mind.special_role : "none"]")
			if(picked_mob)
				var/list/accepted = SSpolling.poll_candidates(
					question = "Would you like to be a [cast_control.name]?",
					check_jobban = antag_flag,
					role = antag_flag,
					poll_time = 20 SECONDS,
					group = list(picked_mob),
					alert_pic = antag_datum,
					role_name_text = LOWER_TEXT(cast_control.name),
					chat_text_border_icon = antag_datum,
					show_candidate_amount = FALSE,
				)
				if(picked_mob in accepted)
					candidates |= picked_mob
				else
					LAZYORASSOCLIST(SSgamemode.unanswered_antag_prompts, picked_ckey, antag_flag)
					SSgamemode.antag_poll_declines[picked_ckey] = world.time
		else
			var/picked_ckey = pick_n_take_weighted(weighted_candidates)
			var/client/picked_client = GLOB.directory[picked_ckey]
			if(QDELETED(picked_client))
				continue
			var/mob/picked_mob = picked_client.mob
			picked_mob?.mind?.picking = TRUE
			log_storyteller("Picked antag event mob: [key_name(picked_mob)], special role: [picked_mob.mind?.special_role ? picked_mob.mind.special_role : "none"]")
			candidates |= picked_mob

	// a pool handed in is a latejoiner alone, 1/1 would cancel out the cost of being picked
	if(!pool_was_handed_in)
		credit_antag_roll(pool_ckeys, (length(candidates) - inherited_count) * cast_control.antag_debt_cost)

	var/list/picked_mobs = list()
	for(var/i in 1 to antag_count)
		if(!length(candidates))
			message_admins("A roleset event got fewer antags then its antag_count and may not function correctly.")
			break

		var/mob/candidate = pick_n_take(candidates)
		log_storyteller("Antag event spawned mob: [key_name(candidate)], special role: [candidate.mind?.special_role ? candidate.mind.special_role : "none"]")

		candidate.client?.prefs.adjust_antag_debt(-cast_control.antag_debt_cost)

		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)

		setup_minds += candidate.mind
		candidate.mind.special_role = antag_flag
		candidate.mind.restricted_roles = restricted_roles
		picked_mobs += WEAKREF(candidate.client)

	setup = TRUE
	control.generate_image(picked_mobs)

/datum/round_event/antagonist/start()
	for(var/datum/mind/antag_mind as anything in setup_minds)
		add_datum_to_mind(antag_mind, antag_mind.current)
	spawn_extra_events()

/datum/round_event/antagonist/proc/add_datum_to_mind(datum/mind/antag_mind)
	return antag_mind.add_antag_datum(antag_datum)

/datum/round_event/antagonist/proc/spawn_extra_events()
	if(!length(extra_spawned_events))
		return

	var/list/spawned_copy = extra_spawned_events.Copy()
	var/player_count = SSgamemode.get_correct_popcount()
	var/datum/round_event_control/event
	while(!event && length(spawned_copy))
		event = pick_n_take_weighted(spawned_copy)
		event = SSevents.control_by_type[event]
		if(!event.can_spawn_event(player_count))
			event = null

	if(!event)
		return

	event.run_event(random = FALSE, event_cause = "storyteller")

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
		SEND_GLOBAL_SIGNAL(COMSIG_RULESET_BODY_GENERATED_FROM_GHOSTS, antag_mind.current)

/datum/round_event/antagonist/ghost/setup()
	var/datum/round_event_control/antagonist/cast_control = control
	antag_count = cast_control.get_antag_amount()
	antag_flag = cast_control.antag_flag
	antag_datum = cast_control.antag_datum
	restricted_roles = cast_control.restricted_roles
	prompted_picking = cast_control.prompted_picking
	var/list/candidates = cast_control.get_candidates()

	if(prompted_picking)
		candidates = SSpolling.poll_candidates(
			question = "Would you like to be a [cast_control.name]?",
			check_jobban = antag_flag,
			role = antag_flag,
			poll_time = 20 SECONDS,
			group = candidates,
			alert_pic = antag_datum,
			role_name_text = LOWER_TEXT(cast_control.name),
			chat_text_border_icon = antag_datum,
		)

	for(var/mob/candidate as anything in pick_ghost_antags(candidates, antag_count))
		if(!candidate.mind)
			candidate.mind = new /datum/mind(candidate.key)
		var/mob/living/carbon/human/new_human = make_body(candidate)
		new_human.mind.special_role = antag_flag
		new_human.mind.restricted_roles = restricted_roles
		setup_minds += new_human.mind
	setup = TRUE
