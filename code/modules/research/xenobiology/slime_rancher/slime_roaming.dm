/datum/ai_movement/navmap_astar/slime
	maximum_length = SLIME_SEEK_PATH_LENGTH
	allow_multiz = TRUE
	update_movement_for_moving_target = TRUE
	nav_cost_modifiers = alist(NAV_COST_LAVA = 99999)

/// Cleaners with no mess in reach go wander somewhere else to look for one
/datum/bt_node/decorator/slime_should_roam

/datum/bt_node/decorator/slime_should_roam/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return istype(slime_pawn) && slime_pawn.cleaner_slime && isnull(slime_pawn.pen) && !slime_pawn.is_latched() && !IS_UNCONSCIOUS_OR_CRIT(slime_pawn)

/// Picks the next spot to wander to. Usually somewhere we haven't been lately, now and then towards a player.
/datum/bt_node/ai_behavior/find_slime_roam_spot
	time_between_perform = 4 SECONDS
	/// How far away a random spot can be
	var/scan_range = 40
	/// The spot the async path search is checking
	VAR_PRIVATE/turf/picked_spot

/datum/bt_node/ai_behavior/find_slime_roam_spot/perform(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags
	if(controller.blackboard_key_exists(BB_SLIME_ROAM_TARGET))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	// setting the roam key replans the whole tree, which would restart whatever chase we're on
	for(var/busy_key in list(BB_SLIME_EAT_TARGET, BB_CURRENT_TARGET, BB_SLIME_ITEM_TARGET, BB_SLIME_CLEAN_TARGET, BB_SLIME_NUZZLE_TARGET, BB_SLIME_BOUNCE_TARGET, BB_SLIME_STACK_TARGET))
		if(controller.blackboard_key_exists(busy_key))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	update_player_seek(controller)
	var/list/candidates = list()
	for(var/turf/candidate as anything in get_candidates(controller))
		if(is_valid_spot(controller, candidate))
			candidates += candidate
	if(!length(candidates))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	picked_spot = pick(candidates)
	return start_async()

/datum/bt_node/ai_behavior/find_slime_roam_spot/perform_async(datum/ai_controller/basic_controller/slime/controller)
	var/turf/spot = picked_spot
	picked_spot = null
	// every way this can fail still ends up in on_path_found(), with an empty path
	SSpathfinder.pathfind(controller.pawn, spot, max_distance = SLIME_SEEK_PATH_LENGTH, access = controller.get_access(), on_finish = list(CALLBACK(src, PROC_REF(on_path_found), controller, spot)), allow_multiz = TRUE, max_path_cost = SLIME_SEEK_PATH_LENGTH * 10, allow_nav_links = TRUE, nav_cost_modifiers = alist(NAV_COST_LAVA = 99999))

/// our pathfinder is async, so the rest of the old synchronous search lives here
/datum/bt_node/ai_behavior/find_slime_roam_spot/proc/on_path_found(datum/ai_controller/basic_controller/slime/controller, turf/spot, list/path, list/actions)
	if(QDELETED(controller) || !async_still_valid())
		return
	if(!length(path))
		controller.ignore_target(spot, SLIME_CHASE_GIVE_UP_TIME)
		// a failed search goes through every tile in reach, so don't keep picking spots in the same locked room
		if(!controller.blackboard_key_exists(BB_SLIME_ROAM_PLAYER))
			controller.ignore_target(get_area(spot), 1 MINUTES)
		// no path means they're out of reach, so we stop looking instead of standing around for the rest of the minute
		controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)
		finish_async(AI_BEHAVIOR_FAILED)
		return
	controller.override_blackboard_key(BB_PATH_TO_USE, path)
	controller.override_blackboard_key(BB_PATH_ACTIONS_TO_USE, actions)
	controller.set_blackboard_key(BB_SLIME_ROAM_TARGET, spot)
	finish_async(AI_BEHAVIOR_SUCCEEDED)

/datum/bt_node/ai_behavior/find_slime_roam_spot/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	picked_spot = null

/// Starts, keeps or drops the player we're drifting towards.
/datum/bt_node/ai_behavior/find_slime_roam_spot/proc/update_player_seek(datum/ai_controller/basic_controller/slime/controller)
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

/datum/bt_node/ai_behavior/find_slime_roam_spot/proc/get_candidates(datum/ai_controller/controller)
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

/datum/bt_node/ai_behavior/find_slime_roam_spot/proc/is_valid_spot(datum/ai_controller/controller, turf/open/destination)
	var/list/ignored = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	if(LAZYACCESS(ignored, destination))
		return FALSE
	if(!isopenturf(destination) || destination.is_blocked_turf(exclude_mobs = TRUE) || !destination.can_cross_safely(controller.pawn))
		return FALSE
	// heading for someone means doubling back through places we've already been
	if(controller.blackboard_key_exists(BB_SLIME_ROAM_PLAYER))
		return TRUE
	return !LAZYACCESS(ignored, get_area(destination))

/// Remembers the area for a bit so the next few hops go somewhere new, and flumps whoever we were out looking for
/datum/bt_node/ai_behavior/arrive_at_roam_spot

/datum/bt_node/ai_behavior/arrive_at_roam_spot/perform(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller)
	var/turf/destination = controller.blackboard[BB_SLIME_ROAM_TARGET]
	controller.clear_blackboard_key(BB_SLIME_ROAM_TARGET)
	if(destination)
		controller.ignore_target(get_area(destination), 2 MINUTES)

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/mob/living/sought = controller.blackboard[BB_SLIME_ROAM_PLAYER]
	if(isnull(sought) || !slime_pawn.Adjacent(sought))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)
	slime_pawn.set_temporary_mood(SLIME_MOOD_SMILE)
	slime_pawn.manual_emote(pick(
		"flumps against [sought]. found you!",
		"wobbles up to [sought] and flumps right into [sought.p_them()].",
		"boops into [sought] and jiggles proudly.",
	))
	slime_pawn.flump_against(sought)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

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
