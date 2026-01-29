///how many storytellers can be voted for along with always_votable ones
#define DEFAULT_STORYTELLER_VOTE_OPTIONS 4
///amount of players we can have before no longer running votes for storyteller
#define MAX_POP_FOR_STORYTELLER_VOTE 25

SUBSYSTEM_DEF(gamemode)
	name = "Gamemode"
	init_order = INIT_ORDER_GAMEMODE
	runlevels = RUNLEVEL_GAME
	flags = SS_BACKGROUND | SS_KEEP_TIMING
	priority = 20
	wait = 1 SECOND

	/// List of our event tracks for fast access during for loops, key is the track ID
	var/list/datum/storyteller_track/event_tracks = list()
	/// Our storyteller. They progresses our trackboards and picks out events
	var/datum/storyteller/current_storyteller
	/// Result of the storyteller vote/pick. Defaults to the guide.
	var/selected_storyteller = /datum/storyteller/guide
	/// List of all the storytellers. Populated at init. Associative from type
	var/list/storytellers = list()
	/// Last point amount gained of each track. Those are recorded for purposes of estimating how long until next event.
	var/list/last_point_gains = list()

	/// Minimum population thresholds for the tracks to fire off events.
	var/list/min_pop_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_MIN_POP,
		EVENT_TRACK_MODERATE = MODERATE_MIN_POP,
		EVENT_TRACK_MAJOR = MAJOR_MIN_POP,
		EVENT_TRACK_ROLESET = ROLESET_MIN_POP,
		)

	/// Configurable multipliers for point gain over time, iterate over this if you only want to look at tracks that use points
	var/list/point_gain_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1,
		STORYTELLER_TRACK_BOOSTER = 1
		)

	var/roundstart_roleset_multiplier = 1

	/// Whether we allow pop scaling. This is configured by config, or the storyteller UI
	var/allow_pop_scaling = TRUE

	/// Associative list of pop scale thresholds.
	var/list/pop_scale_thresholds = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POP_SCALE_THRESHOLD,
		EVENT_TRACK_MODERATE = MODERATE_POP_SCALE_THRESHOLD,
		EVENT_TRACK_MAJOR = MAJOR_POP_SCALE_THRESHOLD,
		EVENT_TRACK_ROLESET = ROLESET_POP_SCALE_THRESHOLD,
		)

	/// Associative list of pop scale penalties.
	var/list/pop_scale_penalties = list(
		EVENT_TRACK_MUNDANE = MUNDANE_POP_SCALE_PENALTY,
		EVENT_TRACK_MODERATE = MODERATE_POP_SCALE_PENALTY,
		EVENT_TRACK_MAJOR = MAJOR_POP_SCALE_PENALTY,
		EVENT_TRACK_ROLESET = ROLESET_POP_SCALE_PENALTY,
		)

	/// Associative list of active multipliers from pop scale penalty.
	var/list/current_pop_scale_multipliers = list(
		EVENT_TRACK_MUNDANE = 1,
		EVENT_TRACK_MODERATE = 1,
		EVENT_TRACK_MAJOR = 1,
		EVENT_TRACK_ROLESET = 1,
		EVENT_TRACK_OBJECTIVES = 1,
		)

	/// Associative list of control events by their track category. Compiled in Init
	var/list/event_pools = list()

	/// Events that we have scheduled to run in the nearby future
	var/list/scheduled_events = list()

	/// Associative list of tracks to forced event controls. For admins to force events (though they can still invoke them freely outside of the track system)
	var/list/forced_next_events = list()

	var/list/round_end_data = list() //list of all reports that need to add round end reports

	/// List of all uncategorized events, because they were wizard or holiday events
	var/list/uncategorized = list()

	/// Event frequency multiplier, it exists because wizard, eugh.
	var/event_frequency_multiplier = 1

	/// Current preview page for the statistics UI.
	var/statistics_track_page = EVENT_TRACK_MUNDANE
	/// Page of the UI panel.
	var/panel_page = GAMEMODE_PANEL_MAIN
	/// Whether we are viewing the roundstart events or not
	var/roundstart_event_view = TRUE

	/// Whether the storyteller has been halted
	var/halted_storyteller = FALSE

	/// Ready players for roundstart events.
	var/active_players = 0
	var/head_crew = 0
	var/eng_crew = 0
	var/sec_crew = 0
	var/med_crew = 0

	/// Is storyteller secret or not
	var/secret_storyteller = FALSE

	/// List of new player minds we currently want to give our roundstart antag to
	var/list/roundstart_antag_minds = list()

	var/wizardmode = FALSE //refactor this into just being a unique storyteller

	/// What is our currently desired/selected roundstart event
	var/datum/round_event_control/antagonist/current_roundstart_event
	var/list/recent_storyteller_events = list()
	/// Has a roundstart event been run
	var/ran_roundstart = FALSE
	/// Are we able to run roundstart events
	var/can_run_roundstart = TRUE
	var/list/triggered_round_events = list()

/datum/controller/subsystem/gamemode/Initialize(time, zlevel)
#if defined(UNIT_TESTS) || defined(AUTOWIKI) // lazy way of doing this but idc
	CONFIG_SET(flag/disable_storyteller, TRUE)
#endif
	for(var/datum/storyteller_track/track as anything in subtypesof(/datum/storyteller_track))
		var/id = track::id
		if(!id)
			continue
		event_tracks[id] = new track()
		if(ispath(track, /datum/storyteller_track/event))
			event_pools[id] = list()

	// Populate storytellers
	for(var/type in subtypesof(/datum/storyteller))
		storytellers[type] = new type()

	load_config_vars()
	load_event_config_vars()

	for(var/point_track in point_gain_multipliers)
		last_point_gains[point_track] = 0

	///Seeding events into track event pools needs to happen after event config vars are loaded
	for(var/datum/round_event_control/event as anything in SSevents.control)
		if(event.holidayID || event.wizardevent || !event.track)
			uncategorized += event
			continue
		event_pools[event.track] += event //Add it to the categorized event pools

	load_roundstart_data()
	if(CONFIG_GET(flag/disable_storyteller)) // we're just gonna disable firing but still initialize, so we don't have any weird runtimes
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED
	return SS_INIT_SUCCESS

/datum/controller/subsystem/gamemode/fire(resumed = FALSE)
	if(can_run_roundstart)
		roundstart_fire()

	///Handle scheduled events
	for(var/datum/scheduled_event/sch_event in scheduled_events)
		if(world.time >= sch_event.start_time)
			INVOKE_ASYNC(sch_event, TYPE_PROC_REF(/datum/scheduled_event, try_fire))
		else if(!sch_event.alerted_admins && world.time >= sch_event.start_time - 1 MINUTES)
			///Alert admins 1 minute before running and allow them to cancel or refund the event, once again.
			sch_event.alerted_admins = TRUE
			message_admins("Scheduled Event: [sch_event.event] will run in [DisplayTimeText(sch_event.start_time - world.time)]. (<a href='byond://?src=[REF(sch_event)];action=cancel'>CANCEL</a>) (<a href='byond://?src=[REF(sch_event)];action=refund'>REFUND</a>)")

	if(!halted_storyteller && current_storyteller)
		// We update crew information here to adjust population scalling and event thresholds for the storyteller.
		update_crew_infos()
		current_storyteller.process()

/datum/controller/subsystem/gamemode/proc/roundstart_fire()
	if(SSticker.round_start_time && (world.time - SSticker.round_start_time) >= ROUNDSTART_VALID_TIMEFRAME)
		can_run_roundstart = FALSE
	else if(length(current_roundstart_event?.preferred_events)) //note that this implementation is made for preferred_events being other roundstart events
		var/list/preferred_copy = current_roundstart_event.preferred_events.Copy()
		var/datum/round_event_control/selected_event = pick_weight(current_roundstart_event.preferred_events)
		var/player_count = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
		if(ispath(selected_event)) //get the instances if we dont have them
			for(var/datum/round_event_control/e_control as anything in current_roundstart_event.preferred_events)
				current_roundstart_event.preferred_events[SSevents.control_by_type[e_control]] = current_roundstart_event.preferred_events[e_control]
				current_roundstart_event.preferred_events -= e_control
			preferred_copy = current_roundstart_event.preferred_events.Copy() - SSevents.control_by_type[selected_event] //need to update the copy to have paths correctly
			selected_event = null
		else if(!selected_event.can_spawn_event(player_count)) //if we have instances then just check the selected event
			preferred_copy -= selected_event
			selected_event = null

		while(!selected_event && length(preferred_copy)) //if we dont have a selected event then try and find a valid one
			selected_event = pick_n_take_weighted(preferred_copy)
			if(!selected_event.can_spawn_event(player_count))
				selected_event = null

		if(selected_event)
			return current_storyteller.try_buy_event(selected_event)

/// Gets the number of antagonists the antagonist injection events will stop rolling after.
/datum/controller/subsystem/gamemode/proc/get_antag_cap()
	var/points = current_storyteller?.base_antag_points || 0
	for(var/mob/living/player in get_active_players())
		var/datum/job/player_role = player.mind?.assigned_role
		if(player_role)
			points += player_role.antag_capacity_points
	return ANTAG_CAP_FLAT + max(points - (ANTAG_CAP_FLAT + 5), 1)

/// Return the total point value of active antags
/datum/controller/subsystem/gamemode/proc/get_antag_count()
	. = 0
	var/alist/already_counted = alist() //only count their highest point antag
	for(var/datum/antagonist/antag as anything in GLOB.antagonists)
		if(QDELETED(antag) || QDELETED(antag.owner))
			continue
		if(!antag.should_count_for_antag_cap())
			continue

		var/counted_value = already_counted[antag.owner]
		if(counted_value && counted_value > antag.get_antag_count_points())
			continue

		counted_value = antag.get_antag_count_points()
		already_counted[antag.owner] = counted_value

	for(var/datum/mind/owner, points in already_counted)
		. += points

/// Whether events can inject more antagonists into the round
/datum/controller/subsystem/gamemode/proc/can_inject_antags()
	return (get_antag_cap() > get_antag_count())

/// Gets candidates for antagonist roles.
/datum/controller/subsystem/gamemode/proc/get_candidates(role, job_ban, observers, ready_newplayers, living_players, required_time, inherit_required_time = TRUE, \
														midround_antag_pref, no_antags = TRUE, list/restricted_roles, list/required_roles)
	var/list/candidates = list()
	var/list/candidate_candidates = list() //lol

	for(var/mob/player as anything in GLOB.player_list)
		if(QDELETED(player) || player.mind?.picking)
			continue
		if(ready_newplayers && isnewplayer(player))
			var/mob/dead/new_player/new_player = player
			if(new_player.ready == PLAYER_READY_TO_PLAY && new_player.mind && new_player.check_preferences())
				candidate_candidates += player
		else if(observers && isobserver(player))
			candidate_candidates += player
		else if(living_players && isliving(player))
			if(!ishuman(player) && !isAI(player))
				continue
			// I split these checks up to make the code more readable ~Lucy
			var/is_on_station = is_station_level(player.z)
			if(!is_on_station && !is_late_arrival(player))
				continue
			candidate_candidates += player

	for(var/mob/candidate as anything in candidate_candidates)
		if(QDELETED(candidate) || !candidate.key || !candidate.client || (!observers && !candidate.mind))
			continue
		if(!observers)
			if(isliving(candidate) && !HAS_MIND_TRAIT(candidate, TRAIT_JOINED_AS_CREW))
				continue

			if(no_antags && !isnull(candidate.mind.antag_datums))
				var/real = FALSE
				for(var/datum/antagonist/antag_datum as anything in candidate.mind.antag_datums)
					if(antag_datum.count_against_dynamic_roll_chance && !(antag_datum.antag_flags & ANTAG_FAKE))
						real = TRUE
						break
				if(real)
					continue
			if(restricted_roles && (candidate.mind.assigned_role.title in restricted_roles))
				continue
			if(length(required_roles) && !(candidate.mind.assigned_role.title in required_roles))
				continue

		if(role)
			if(!candidate.client?.prefs || !(role in candidate.client.prefs.be_special))
				continue

			var/time_to_check
			if(required_time)
				time_to_check = required_time
			else if(inherit_required_time)
				time_to_check = GLOB.special_roles[role]

			if(time_to_check && candidate.client?.get_remaining_days(time_to_check) > 0)
				continue

		if(job_ban && is_banned_from(candidate.ckey, list(job_ban, ROLE_SYNDICATE)))
			continue
		candidates += candidate
	return candidates

/// Gets the correct popcount, returning READY people if roundstart, and active people if not.
/datum/controller/subsystem/gamemode/proc/get_correct_popcount()
	update_crew_infos()
	return active_players

/// Refunds and removes a scheduled event.
/datum/controller/subsystem/gamemode/proc/refund_scheduled_event(datum/scheduled_event/refunded)
	if(refunded.cost)
		event_tracks[refunded.event.track].points += refunded.cost
	remove_scheduled_event(refunded)

/// Removes a scheduled event.
/datum/controller/subsystem/gamemode/proc/remove_scheduled_event(datum/scheduled_event/removed, should_del = TRUE)
	scheduled_events -= removed
	if(should_del)
		qdel(removed)

/// We roll points to be spent for roundstart events, including antagonists.
/datum/controller/subsystem/gamemode/proc/roll_pre_setup_points()
	if(current_storyteller.disable_distribution || halted_storyteller)
		return

	var/non_ready_players = 0
	var/ready_players = 0
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(player.ready == PLAYER_READY_TO_PLAY)
			ready_players++
		else
			non_ready_players++

	//get our roleset points, non ready players count for 1/3rd
	var/calc_value = ROUNDSTART_ROLESET_BASE + round(ROUNDSTART_ROLESET_GAIN * ready_players) + round((ROUNDSTART_ROLESET_GAIN * non_ready_players) / 3)
	calc_value *= roundstart_roleset_multiplier
	calc_value *= current_storyteller.starting_point_multipliers[EVENT_TRACK_ROLESET]
	calc_value *= (rand(100 - current_storyteller.roundstart_points_variance, 100 + current_storyteller.roundstart_points_variance)/100)
	var/datum/storyteller_track/roleset_track = event_tracks[EVENT_TRACK_ROLESET]
	roleset_track.points = round(calc_value)

	/// If the storyteller guarantees an antagonist roll, add points to make it so.
	if(current_storyteller.guarantees_roundstart_roleset && roleset_track.points < roleset_track.threshold)
		roleset_track.points = roleset_track.threshold

	/// If we have any forced events, ensure we get enough points for them
	for(var/track_id, track in event_tracks)
		var/datum/storyteller_track/typed_track = track
		if(forced_next_events[track_id] && typed_track.points < typed_track.threshold)
			typed_track.points = typed_track.threshold

/// Schedules an event to run later.
/datum/controller/subsystem/gamemode/proc/schedule_event(datum/round_event_control/passed_event, passed_time, passed_cost, passed_ignore, passed_announce, _forced = FALSE)
	if(_forced)
		passed_ignore = TRUE
	var/datum/scheduled_event/scheduled = new (passed_event, world.time + passed_time, passed_cost, passed_ignore, passed_announce)
	var/round_started = SSticker.HasRoundStarted()
	if(round_started)
		message_admins("Event: [passed_event] has been scheduled to run in [DisplayTimeText(passed_time)]. (<a href='byond://?src=[REF(scheduled)];action=cancel'>CANCEL</a>) (<a href='byond://?src=[REF(scheduled)];action=refund'>REFUND</a>)")
	else //Only roundstart events can be scheduled before round start
		message_admins("Event: [passed_event] has been scheduled to run on roundstart. (<a href='byond://?src=[REF(scheduled)];action=cancel'>CANCEL</a>)")
	scheduled_events += scheduled

//simplified version of `get_active_player_count()`
/datum/controller/subsystem/gamemode/proc/get_active_players()
	. = list()
	for(var/mob/living/carbon/human/player_mob in GLOB.alive_player_list)
		if(player_mob.client?.is_afk())
			continue
		. += player_mob

/datum/controller/subsystem/gamemode/proc/update_crew_infos()
	active_players = 0
	head_crew = 0
	eng_crew = 0
	med_crew = 0
	sec_crew = 0
	for(var/mob/living/carbon/human/player_mob in get_active_players())
		active_players++
		if(player_mob.mind?.assigned_role)
			var/datum/job/player_role = player_mob.mind.assigned_role
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
				head_crew++
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING)
				eng_crew++
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
				med_crew++
			if(player_role.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
				sec_crew++
	update_pop_scaling()

/datum/controller/subsystem/gamemode/proc/update_pop_scaling()
	for(var/track in event_tracks)
		var/low_pop_bound = min_pop_thresholds[track]
		var/high_pop_bound = pop_scale_thresholds[track]
		var/scale_penalty = pop_scale_penalties[track]

		var/perceived_pop = min(max(low_pop_bound, active_players), high_pop_bound)

		var/divisor = high_pop_bound - low_pop_bound
		/// If the bounds are equal, we'd be dividing by zero or worse, if upper is smaller than lower, we'd be increasing the factor, just make it 1 and continue.
		/// this is only a problem for bad configs
		if(divisor <= 0)
			current_pop_scale_multipliers[track] = 1
			continue
		var/scalar = (perceived_pop - low_pop_bound) / divisor
		var/penalty = scale_penalty - (scale_penalty * scalar)
		var/calculated_multiplier = 1 - (penalty / 100)

		current_pop_scale_multipliers[track] = calculated_multiplier

/datum/controller/subsystem/gamemode/proc/TriggerEvent(datum/round_event_control/event, forced = FALSE)
	. = event.preRunEvent(forced)
	if(. == EVENT_CANT_RUN)//we couldn't run this event for some reason, set its max_occurrences to 0
		event.max_occurrences = 0
	else if(. == EVENT_READY)
		event.run_event(random = TRUE, admin_forced = forced) // fallback to dynamic

ADMIN_VERB(force_event, R_FUN, FALSE, "Trigger Event", "Forces an event to occur.", ADMIN_CATEGORY_EVENTS) // TG PORT
	SSgamemode.event_panel(user.mob)

ADMIN_VERB(forceGamemode, R_FUN, FALSE, "Open Gamemode Panel", "Opens the gamemode panel.", ADMIN_CATEGORY_EVENTS) // TG PORT
	SSgamemode.admin_panel(user.mob)

/datum/controller/subsystem/gamemode/proc/toggleWizardmode()
	wizardmode = !wizardmode //TODO: decide what to do with wiz events
	message_admins("Summon Events has been [wizardmode ? "enabled, events will occur [SSgamemode.event_frequency_multiplier] times as fast" : "disabled"]!")
	log_game("Summon Events was [wizardmode ? "enabled" : "disabled"]!")

///Attempts to select players for special roles the mode might have.
/datum/controller/subsystem/gamemode/proc/pre_setup()
	roll_pre_setup_points()
	return TRUE

/// Loads json event config values from events.txt
/datum/controller/subsystem/gamemode/proc/load_event_config_vars()
	var/json_file = file("[global.config.directory]/events.json")
	if(!fexists(json_file))
		return
	var/list/decoded = json_decode(file2text(json_file))
	for(var/event_text_path in decoded)
		var/event_path = text2path(event_text_path)
		var/datum/round_event_control/event
		for(var/datum/round_event_control/iterated_event as anything in SSevents.control)
			if(iterated_event.type == event_path)
				event = iterated_event
				break
		if(!event)
			continue
		var/list/var_list = decoded[event_text_path]
		for(var/variable in var_list)
			var/value = var_list[variable]
			switch(variable)
				if("weight")
					event.weight = value
				if("min_players")
					event.min_players = value
				if("max_occurrences")
					event.max_occurrences = value
				if("earliest_start")
					event.earliest_start = value * (1 MINUTES)
				if("track")
					if(value in event_tracks)
						event.track = value
				if("cost")
					event.cost = value
				if("reoccurence_penalty_multiplier")
					event.reoccurence_penalty_multiplier = value
				if("shared_occurence_type")
					if(!isnull(value))
						value = "[value]"
					event.shared_occurence_type = value
				if("repeated_mode_adjust")
					event.repeated_mode_adjust = value
				if("extra_spawned_events")
					if(!islist(value) && !isnull(value))
						stack_trace("extra_spawned_events must be a list or null (tried to set invalid for [event_path])")
						continue
					if(!istype(event, /datum/round_event_control/antagonist))
						stack_trace("tried to set extra_spawned_events for event that isn't a subtype of /datum/round_event_control/antagonist ([event_path])")
						continue
					var/datum/round_event_control/antagonist/antag_event = event
					LAZYNULL(antag_event.extra_spawned_events)
					var/list/extra_spawned_events = fill_with_ones(value)
					for(var/key in extra_spawned_events)
						var/extra_path = text2path(key)
						if(!extra_path)
							stack_trace("invalid event typepath '[key]' in extra_spawned_events for [event_path] in events.json")
							continue
						LAZYSET(antag_event.extra_spawned_events, extra_path, extra_spawned_events[key])

/// Loads config values from game_options.txt
/datum/controller/subsystem/gamemode/proc/load_config_vars()
	point_gain_multipliers[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_point_gain_multiplier)
	point_gain_multipliers[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_point_gain_multiplier)

	roundstart_roleset_multiplier = CONFIG_GET(number/roleset_roundstart_point_multiplier)

	min_pop_thresholds[EVENT_TRACK_MUNDANE] = CONFIG_GET(number/mundane_min_pop)
	min_pop_thresholds[EVENT_TRACK_MODERATE] = CONFIG_GET(number/moderate_min_pop)
	min_pop_thresholds[EVENT_TRACK_MAJOR] = CONFIG_GET(number/major_min_pop)
	min_pop_thresholds[EVENT_TRACK_ROLESET] = CONFIG_GET(number/roleset_min_pop)

	event_tracks[EVENT_TRACK_MUNDANE].threshold = CONFIG_GET(number/mundane_point_threshold)
	event_tracks[EVENT_TRACK_MODERATE].threshold = CONFIG_GET(number/moderate_point_threshold)
	event_tracks[EVENT_TRACK_MAJOR].threshold = CONFIG_GET(number/major_point_threshold)
	event_tracks[EVENT_TRACK_ROLESET].threshold = CONFIG_GET(number/roleset_point_threshold)

/datum/controller/subsystem/gamemode/proc/handle_picking_storyteller()
	if(CONFIG_GET(flag/disable_storyteller))
		return
	if(length(GLOB.clients) > MAX_POP_FOR_STORYTELLER_VOTE)
		secret_storyteller = TRUE
		selected_storyteller = pick_weight(get_valid_storytellers(TRUE))
		return
	SSvote.initiate_vote(/datum/vote/storyteller, "pick round storyteller", forced = TRUE)

/datum/controller/subsystem/gamemode/proc/storyteller_vote_choices()
	var/list/final_choices = list()
	var/list/pick_from = list()
	for(var/datum/storyteller/storyboy in get_valid_storytellers())
		if(storyboy.always_votable)
			final_choices[storyboy.name] = 0
		else
			pick_from[storyboy.name] = storyboy.weight //might be able to refactor this to be slightly better due to get_valid_storytellers returning a weighted list

	var/added_storytellers = 0
	while(added_storytellers < DEFAULT_STORYTELLER_VOTE_OPTIONS && length(pick_from))
		added_storytellers++
		var/picked_storyteller = pick_weight(pick_from)
		final_choices[picked_storyteller] = 0
		pick_from -= picked_storyteller
	return final_choices

/datum/controller/subsystem/gamemode/proc/storyteller_desc(storyteller_name)
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.name != storyteller_name)
			continue
		return storyboy.desc

/datum/controller/subsystem/gamemode/proc/storyteller_vote_result(winner_name)
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.name == winner_name)
			selected_storyteller = storyteller_type
			break

///return a weighted list of all storytellers that are currently valid to roll, if return_types is set then we will return types instead of instances
/datum/controller/subsystem/gamemode/proc/get_valid_storytellers(return_types = FALSE)
	var/client_amount = length(GLOB.clients)
	var/list/valid_storytellers = list()
	for(var/storyteller_type in storytellers)
		var/datum/storyteller/storyboy = storytellers[storyteller_type]
		if(storyboy.restricted || (storyboy.population_min && storyboy.population_min > client_amount) || (storyboy.population_max && storyboy.population_max < client_amount))
			continue

		valid_storytellers[return_types ? storyboy.type : storyboy] = storyboy.weight
	return valid_storytellers

/datum/controller/subsystem/gamemode/proc/init_storyteller()
	// Don't allow the storyteller to be set if an admin set the storyteller
	if(current_storyteller)
		return
	set_storyteller(selected_storyteller)

/datum/controller/subsystem/gamemode/proc/set_storyteller(passed_type)
	if(!storytellers[passed_type])
		message_admins("Attempted to set an invalid storyteller type: [passed_type], force setting to guide instead.")
		current_storyteller = storytellers[/datum/storyteller/guide] //if we dont have any then we brick, lets not do that
		CRASH("Attempted to set an invalid storyteller type: [passed_type].")
	current_storyteller = storytellers[passed_type]
	current_storyteller.round_started = SSticker.HasRoundStarted()
	for(var/track in event_tracks)
		current_storyteller.calculate_weights(track)

	if(!secret_storyteller)
		send_to_playing_players(span_notice("<b>Storyteller is [current_storyteller.name]!</b>"))
		send_to_playing_players(span_notice("[current_storyteller.welcome_text]"))
	else
		send_to_observers(span_boldbig("<b>Storyteller is [current_storyteller.name]!</b>")) //observers still get to know

/datum/controller/subsystem/gamemode/proc/store_roundend_data()
	var/max_history = length(CONFIG_GET(number_list/repeated_mode_adjust))
	recent_storyteller_events.Insert(1, list(triggered_round_events))
	if(length(recent_storyteller_events) > max_history)
		recent_storyteller_events.Cut(max_history + 1)
	rustg_file_write(json_encode(recent_storyteller_events, JSON_PRETTY_PRINT), "data/recent_storyteller_events.json") // pretty-print just to make manually looking at it easier

/datum/controller/subsystem/gamemode/proc/load_roundstart_data()
	if(!fexists("data/recent_storyteller_events.json"))
		return
	var/recent_json = rustg_file_read("data/recent_storyteller_events.json")
	if(!recent_json || !rustg_json_is_valid(recent_json))
		rustg_file_write("\[\]", "data/recent_storyteller_events.json")
		CRASH("recent_storyteller_events.json was invalid: [recent_json]")
	var/list/recent = json_decode(recent_json)
	recent_storyteller_events.Cut()
	for(var/round = 1 to length(recent))
		var/list/entries = list()
		for(var/event in recent[round])
			var/event_path = text2path(event)
			if(event_path)
				entries += event_path
		recent_storyteller_events += list(entries)

#undef DEFAULT_STORYTELLER_VOTE_OPTIONS
#undef MAX_POP_FOR_STORYTELLER_VOTE
#undef INIT_ORDER_GAMEMODE
