/datum/ai_movement/astar/slime
	maximum_length = SLIME_SEEK_PATH_LENGTH

/// Cleaners with no mess in reach go wander somewhere else to look for one
/datum/ai_planning_subtree/slime_target/roam
	target_key = BB_SLIME_ROAM_TARGET
	finding_behavior = /datum/ai_behavior/slime_find_target/roam
	acting_behavior = /datum/ai_behavior/slime_chase/roam

/datum/ai_planning_subtree/slime_target/roam/should_scan(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return slime_pawn.cleaner_slime && isnull(slime_pawn.pen) && !slime_pawn.is_latched() && slime_pawn.stat == CONSCIOUS

/// Picks the next spot to wander to. Usually somewhere we haven't been lately, now and then towards a player.
/datum/ai_behavior/slime_find_target/roam
	action_cooldown = 4 SECONDS
	scan_range = 40
	must_be_reachable = TRUE

/datum/ai_behavior/slime_find_target/roam/perform(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, target_key)
	if(!controller.blackboard_key_exists(target_key))
		update_player_seek(controller)
	return ..()

/// Starts, keeps or drops the player we're drifting towards.
/datum/ai_behavior/slime_find_target/roam/proc/update_player_seek(datum/ai_controller/basic_controller/slime/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/mob/living/sought = controller.blackboard[BB_SLIME_ROAM_PLAYER]
	if(sought)
		if(sought.stat == DEAD || !are_zs_connected(slime_pawn, sought) || COOLDOWN_FINISHED(slime_pawn, player_seek_timeout))
			controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)
		return
	if(!COOLDOWN_FINISHED(slime_pawn, player_seek_cooldown) || !prob(20))
		return
	COOLDOWN_START(slime_pawn, player_seek_cooldown, 3 MINUTES)
	var/list/players = list()
	for(var/mob/living/player in GLOB.alive_player_list)
		if(are_zs_connected(slime_pawn, player))
			players += player
	if(!length(players))
		return
	controller.set_blackboard_key(BB_SLIME_ROAM_PLAYER, pick(players))
	// we give up after a minute, or straight away if there's no path to them
	COOLDOWN_START(slime_pawn, player_seek_timeout, 1 MINUTES)

// the AI shuts off on floors with no living players, but someone we're out looking for is somewhere else by definition.
// roaming cleaners hop floors on their own too, and would get stuck on any floor nobody's on
/datum/ai_controller/basic_controller/slime/get_expected_ai_status()
	. = ..()
	if(. != AI_STATUS_OFF)
		return
	var/mob/living/basic/slime/slime_pawn = pawn
	if(!isnull(slime_pawn.client) || slime_pawn.stat == DEAD)
		return
	if(blackboard_key_exists(BB_SLIME_ROAM_PLAYER))
		return AI_STATUS_ON
	if(!slime_pawn.cleaner_slime || !isnull(slime_pawn.pen))
		return
	for(var/z_level in SSmapping.get_connected_levels(get_turf(slime_pawn)))
		if(length(SSmobs.clients_by_zlevel[z_level]))
			return AI_STATUS_ON

/mob/living/basic/slime/proc/on_seek_changed(datum/source)
	SIGNAL_HANDLER
	// shutting the AI off cancels every action, and this can fire from inside one of them
	addtimer(CALLBACK(ai_controller, TYPE_PROC_REF(/datum/ai_controller, reset_ai_status)), 0.1 SECONDS, TIMER_UNIQUE)

/datum/ai_behavior/slime_find_target/roam/get_candidates(datum/ai_controller/controller)
	. = list()
	var/turf/sought_turf = get_turf(controller.blackboard[BB_SLIME_ROAM_PLAYER])
	if(sought_turf)
		for(var/direction in GLOB.cardinals)
			var/turf/next_to_them = get_step(sought_turf, direction)
			if(next_to_them)
				. += next_to_them
		return

	var/turf/here = get_turf(controller.pawn)
	for(var/i in 1 to 20)
		var/turf/candidate = locate(here.x + rand(-scan_range, scan_range), here.y + rand(-scan_range, scan_range), here.z)
		if(isnull(candidate) || get_dist(here, candidate) < 8)
			continue
		if(prob(33))
			candidate = pick(GET_TURF_ABOVE(candidate), GET_TURF_BELOW(candidate)) || candidate
		. += candidate

/datum/ai_behavior/slime_find_target/roam/is_valid_target(datum/ai_controller/basic_controller/slime/controller, atom/target)
	var/turf/open/destination = target
	if(!isopenturf(destination) || destination.is_blocked_turf(exclude_mobs = TRUE) || !destination.can_cross_safely(controller.pawn))
		return FALSE
	// heading for someone means doubling back through places we've already been
	if(controller.blackboard_key_exists(BB_SLIME_ROAM_PLAYER))
		return TRUE
	return !controller.is_ignoring(get_area(destination))

/datum/ai_behavior/slime_find_target/roam/request_path(datum/ai_controller/basic_controller/slime/controller, target_key, atom/candidate)
	if(SSpathfinder.astar_pathfind(controller.pawn, candidate, max_distance = SLIME_SEEK_PATH_LENGTH, access = controller.get_access(), on_finish = list(CALLBACK(src, PROC_REF(on_path_found), controller, target_key, candidate))))
		return
	controller.ignore_target(candidate, SLIME_CHASE_GIVE_UP_TIME)
	// refused before searching means they're too far off, same as on_path_found finding nothing
	controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)

/datum/ai_behavior/slime_find_target/roam/on_path_found(datum/ai_controller/basic_controller/slime/controller, target_key, atom/candidate, list/path)
	// no path means they're out of reach, so we stop looking instead of standing around for the rest of the minute
	if(!length(path) && !QDELETED(controller))
		controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)
	return ..()

/// Walks to the spot, then remembers the area for a bit so the next few hops go somewhere new
/datum/ai_behavior/slime_chase/roam
	// the spot's next to whoever we're after, and anywhere within 1 of it includes their own tile, since calm slimes can slip under people
	required_distance = 0

/datum/ai_behavior/slime_chase/roam/perform(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, target_key)
	. = ..()
	var/turf/destination = controller.blackboard[target_key]
	controller.ignore_target(get_area(destination), 2 MINUTES)
	controller.clear_blackboard_key(target_key)
	finish_action(controller, TRUE, target_key)

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/mob/living/sought = controller.blackboard[BB_SLIME_ROAM_PLAYER]
	if(isnull(sought) || !slime_pawn.Adjacent(sought))
		return
	controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)
	slime_pawn.set_temporary_mood(SLIME_MOOD_SMILE)
	slime_pawn.manual_emote(pick(
		"flumps against [sought]. found you!",
		"wobbles up to [sought] and flumps right into [sought.p_them()].",
		"boops into [sought] and jiggles proudly.",
	))
	slime_pawn.flump_against(sought)
