/// Rolls to turn someone who just latejoined into one of the latejoin antags they've opted into.
/datum/controller/subsystem/gamemode/proc/try_latejoin_antag(mob/living/carbon/human/latejoiner)
	if(CONFIG_GET(flag/disable_storyteller) || halted_storyteller || current_storyteller.disable_distribution)
		return

	var/list/candidate_pool = list(latejoiner)
	var/datum/round_event_control/antagonist/picked_event
	var/datum/round_event_control/antagonist/forced_event = forced_next_events[EVENT_TRACK_LATEJOIN]
	if(istype(forced_event))
		if(!(latejoiner in forced_event.get_candidates(candidate_pool)))
			return
		// ban checks can sleep on a cold ban cache, so another latejoiner might've taken it while we waited
		if(forced_next_events[EVENT_TRACK_LATEJOIN] != forced_event)
			return
		forced_next_events -= EVENT_TRACK_LATEJOIN
		picked_event = forced_event
	else
		if(!COOLDOWN_FINISHED(src, latejoin_antag_cooldown))
			return
		var/latejoin_chance = get_latejoin_antag_chance()
		if(!prob(latejoin_chance))
			log_storyteller("Latejoin: chance failed for [key_name(latejoiner)] ([latejoin_chance]% chance)")
			return

		var/list/valid_events = list()
		var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
		for(var/datum/round_event_control/antagonist/event in event_pools[EVENT_TRACK_LATEJOIN])
			if(event.can_spawn_event(players_amt, candidate_pool = candidate_pool) && current_storyteller.calculate_single_weight(event) > 0)
				valid_events[event] = round(event.calculated_weight * 10)
		// same deal as above, someone else could've been rolled while we were asleep
		if(!length(valid_events) || !COOLDOWN_FINISHED(src, latejoin_antag_cooldown))
			return
		picked_event = pick_weight(valid_events)
		COOLDOWN_START(src, latejoin_antag_cooldown, rand(LATEJOIN_ANTAG_COOLDOWN_LOW, LATEJOIN_ANTAG_COOLDOWN_HIGH))

	var/datum/round_event/antagonist/running_event = picked_event.run_event(random = TRUE, event_cause = "storyteller", candidate_pool = candidate_pool)
	if(!length(running_event.setup_minds))
		log_storyteller("Latejoin: [picked_event.name] ran for [key_name(latejoiner)], but they weren't picked for it")
		if(picked_event == forced_event)
			forced_next_events[EVENT_TRACK_LATEJOIN] = forced_event
		return

	triggered_round_events |= picked_event.type
	picked_event.calculated_weight = null
	message_admins("Latejoin: [ADMIN_LOOKUPFLW(latejoiner)] has been selected for [picked_event.name].")
	log_storyteller("Latejoin: [key_name(latejoiner)] has been selected for [picked_event.name]")

/// The percent chance that a latejoiner gets rolled for a latejoin antag right now.
/datum/controller/subsystem/gamemode/proc/get_latejoin_antag_chance()
	var/num_dead = length(GLOB.dead_player_list)
	var/num_alive = get_active_player_count(alive_check = TRUE, afk_check = TRUE)
	if(num_dead + num_alive <= 0)
		return 0

	var/chance = 100 - (200 * (num_dead / (num_alive + num_dead)))
	if(world.time - SSticker.round_start_time < BASE_MIDROUND_SPAWN_TIME)
		chance *= LATEJOIN_ANTAG_EARLY_MULTIPLIER

	var/storyteller_gain = current_storyteller.point_gains_multipliers[EVENT_TRACK_ROLESET]
	if(isnum(storyteller_gain))
		chance *= storyteller_gain
	var/mode_gain = point_gain_multipliers[EVENT_TRACK_ROLESET]
	if(isnum(mode_gain))
		chance *= mode_gain
	return clamp(chance, 0, 100)
