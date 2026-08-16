/datum/round_event_control/abandoned_ipc
	name = "Abandoned IPC"
	tags = list(TAG_OUTSIDER_ANTAG, TAG_TARGETED)
	typepath = /datum/round_event/ghost_role/abandoned_ipc
	track = EVENT_TRACK_MODERATE
	weight = 10

/datum/round_event/ghost_role/abandoned_ipc
	minimum_required = 1
	role_name = "Abandoned IPC"

/datum/round_event/ghost_role/abandoned_ipc/spawn_role()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as an abandoned IPC?",
		check_jobban = ROLE_ABANDONED_IPC,
		role = ROLE_ABANDONED_IPC,
		poll_time = 20 SECONDS,
		alert_pic = /datum/antagonist/abandoned_ipc,
		role_name_text = "abandoned IPC"
	)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/turf/spawn_loc = find_safe_turf_in_maintenance()
	if(isnull(spawn_loc))
		return MAP_ERROR

	var/mob/living/carbon/human/abandoned_ipc = new(spawn_loc)
	abandoned_ipc.PossessByPlayer(selected.key)
	abandoned_ipc.mind.add_antag_datum(/datum/antagonist/abandoned_ipc)
	abandoned_ipc.mind.special_role = ROLE_ABANDONED_IPC

	message_admins("[ADMIN_LOOKUPFLW(abandoned_ipc)] has been made into a [src] by an event.")
	log_game("[key_name(abandoned_ipc)] was spawned as a [src] by an event.")
	spawned_mobs += abandoned_ipc
	return SUCCESSFUL_SPAWN
