/datum/round_event_control/bingle
	name = "Spawn Bingle"
	typepath = /datum/round_event/ghost_role/bingle
	weight = 14
	max_occurrences = 1
	track = EVENT_TRACK_MODERATE
	description = "Spawns a pesky little blue fella."
	tags = list(TAG_COMBAT, TAG_EXTERNAL, TAG_OUTSIDER_ANTAG)
	checks_antag_cap = TRUE
	dont_spawn_near_roundend = TRUE

/datum/job/bingle
 	title = ROLE_BINGLE

/datum/round_event/ghost_role/bingle
	minimum_required = 1
	role_name = "Bingle"
	fakeable = FALSE
	var/turf/spawn_loc

/datum/round_event/ghost_role/bingle/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		question = "Do you want to play as a Bingle?",
		role = ROLE_BINGLE,
		check_jobban = ROLE_BINGLE,
		poll_time = 20 SECONDS,
		alert_pic = /mob/living/basic/bingle,
		role_name_text = "bingle"
	)
	spawn_loc = find_safe_turf_in_maintenance()//Used for the Drop Pod type of spawn for maints only

	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	if(isnull(spawn_loc))
		return MAP_ERROR
	var/mob/living/basic/bingle/lord/bingle = new(spawn_loc) //This is to catch errors by just giving them a location in general.
	player_mind.transfer_to(bingle)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/bingle))
	player_mind.special_role = ROLE_BINGLE
	player_mind.add_antag_datum(/datum/antagonist/bingle)
	message_admins("[ADMIN_LOOKUPFLW(bingle)] has been made into Bingle.")
	log_game("[key_name(bingle)] was spawned as Bingle by an event.")
	spawned_mobs += bingle
	return SUCCESSFUL_SPAWN

