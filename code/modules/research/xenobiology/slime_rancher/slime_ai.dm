/// How far (in path steps) a slime will walk to reach something it spotted
#define SLIME_REACH_DISTANCE 10

/// Brain for slimes.
/datum/ai_controller/basic_controller/slime
	behavior_tree_json = "code/modules/research/xenobiology/slime_rancher/slime.bt.json"
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/slime_food,
		BB_SLIME_RABID = FALSE,
		BB_SLIME_HUNGER_DISABLED = FALSE,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Blorble...", "Bzzt..."),
			BB_EMOTE_HEAR = list("blorbles."),
			BB_EMOTE_SEE = list("lights up for a bit, then stops.", "bounces in place.", "jiggles!", "vibrates!"),
			BB_SPEAK_CHANCE = 1,
		),
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	/// Until this runs out, roaming and stacking reuse the last mess scan instead of doing their own
	COOLDOWN_DECLARE(mess_scan_reuse)
	/// Whether the last mess scan found any mess we'd go for
	var/mess_nearby = FALSE
	/// Our mess finder node, roaming and stacking ask it whether there's any mess around
	var/datum/bt_node/ai_behavior/slime_find_target/mess/mess_finder
	/// Whichever chase is running right now, so less important targets showing up don't interrupt it
	var/datum/bt_node/ai_behavior/slime_chase/active_chase

/datum/ai_controller/basic_controller/slime/Destroy(force)
	mess_finder = null
	active_chase = null
	return ..()

/datum/ai_controller/basic_controller/slime/get_access()
	var/mob/living/basic/slime/slime_pawn = pawn
	return slime_pawn.get_access()

/// Ignores a target until duration runs out. Never shortens an existing, longer ignore.
/datum/ai_controller/basic_controller/slime/proc/ignore_target(atom/target, duration)
	var/expires_at = world.time + duration
	if(LAZYACCESS(blackboard[BB_TEMPORARY_IGNORE_LIST], target) >= expires_at)
		return
	set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, expires_at)

/// Whether the target is still on the ignore list.
/datum/ai_controller/basic_controller/slime/proc/is_ignoring(atom/target)
	return LAZYACCESS(blackboard[BB_TEMPORARY_IGNORE_LIST], target) > world.time

/// remove_thing_from_blackboard_key() crashes on things that aren't there, this doesn't
/datum/ai_controller/basic_controller/slime/proc/forget(key, atom/thing)
	if(!(thing in blackboard[key]))
		return
	remove_thing_from_blackboard_key(key, thing)

/// Whether there's any mess around we'd go clean up.
/datum/ai_controller/basic_controller/slime/proc/has_mess_nearby()
	return mess_finder?.has_candidates(src)

/// Pauses our AI for as long as any source holds it. Each source only lifts its own.
/mob/living/basic/slime/proc/pause_ai(source)
	ADD_TRAIT(src, TRAIT_AI_PAUSED, source)
	ai_controller?.cancel_current_plan()

/// Removes this source's pause. The AI stays paused if anything else is still pausing it.
/mob/living/basic/slime/proc/unpause_ai(source)
	REMOVE_TRAIT(src, TRAIT_AI_PAUSED, source)

/// Runs every Life tick instead of in the AI, so a long chase can't starve it
/mob/living/basic/slime/proc/handle_slime_upkeep(seconds_per_tick)
	var/datum/ai_controller/basic_controller/slime/controller = ai_controller
	if(!istype(controller))
		return

	var/list/grudges = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	for(var/atom/attacker as anything in grudges)
		if(world.time - grudges[attacker] > SLIME_GRUDGE_DURATION)
			controller.forget(BB_BASIC_MOB_RETALIATE_LIST, attacker)

	var/list/ignored = controller.blackboard[BB_TEMPORARY_IGNORE_LIST]
	for(var/atom/target as anything in ignored)
		if(ignored[target] <= world.time)
			controller.forget(BB_TEMPORARY_IGNORE_LIST, target)

	if(stat != CONSCIOUS)
		return
	update_mood()
	if(controller.ai_status == AI_STATUS_ON && !HAS_TRAIT(src, TRAIT_AI_PAUSED) && SPT_PROB(15, seconds_per_tick))
		try_snatch_item()

/// yoinks a wanted item right out of an adjacent mob's hands. slimes don't chase people down for these, to be clear
/mob/living/basic/slime/proc/try_snatch_item()
	var/list/wanted_types = ai_controller.blackboard[BB_SLIME_WANTED_ITEMS]
	if(is_latched() || !length(wanted_types))
		return FALSE
	for(var/mob/living/neighbor in oview(1, src))
		for(var/obj/item/held as anything in neighbor.get_held_items())
			if(!wanted_types[held.type])
				continue
			var/held_name = "\the [held]" // get this bc eating it might delete the item
			if(!eat_wanted_item(held, silent = TRUE))
				continue
			visible_message(
				span_notice("[src] snatches [held_name] right out of [neighbor]'s hands!"),
				span_notice("You snatch [held_name] right out of [neighbor]'s hands!"),
			)
			balloon_alert_to_viewers("snatches item out of hand!")
			set_temporary_mood(SLIME_MOOD_MISCHIEVOUS)
			return TRUE
	return FALSE

/// resets a lot of AI stuff so like, it'll get unstuck if AI got softlocked or something. hopefully.
/mob/living/basic/slime/proc/reset_stuck_ai()
	COOLDOWN_RESET(src, ranch_retry_cooldown)
	if(isnull(ai_controller))
		return
	ai_controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, null)
	ai_controller.cancel_current_plan()
	for(var/stale_key in list(
		BB_SLIME_EAT_TARGET,
		BB_CURRENT_TARGET,
		BB_SLIME_ITEM_TARGET,
		BB_SLIME_NUZZLE_TARGET,
		BB_SLIME_BOUNCE_TARGET,
		BB_SLIME_CLEAN_TARGET,
		BB_SLIME_STACK_TARGET,
		BB_SLIME_ROAM_TARGET,
		BB_SLIME_ROAM_PLAYER,
		BB_ACTIVE_PET_COMMAND,
		BB_CURRENT_PET_TARGET,
		BB_TEMPORARY_IGNORE_LIST,
		BB_BASIC_MOB_RETALIATE_LIST,
	))
		ai_controller.clear_blackboard_key(stale_key)
	refresh_wanted_targets()
	balloon_alert_to_viewers("shakes [p_them()]self off")

/// Wild slimes split on their own. Ranched ones wait for a rancher to prime them.
/datum/bt_node/decorator/slime_wild_split
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/slime_wild_split/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(slime_pawn.is_ranched())
		return FALSE
	var/datum/action/reproduce = controller.blackboard[BB_SLIME_REPRODUCE]
	return reproduce?.IsAvailable()

/datum/bt_node/ai_behavior/slime_wild_split
	time_between_perform = 1 SECONDS

/datum/bt_node/ai_behavior/slime_wild_split/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(slime_pawn.reproduce(feedback = FALSE))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/**
 * Gates a chase behind its target key, like bb_key_set.
 * A target showing up only interrupts what we're doing if that's less important than this chase,
 * otherwise a nuzzle target turning up would make us let go of our meal.
 */
/datum/bt_node/decorator/bb_key_set/slime_chase
	observer_abort = BT_ABORT_BOTH

/datum/bt_node/decorator/bb_key_set/slime_chase/on_observed_change(datum/ai_controller/basic_controller/slime/controller, key)
	var/datum/bt_node/ai_behavior/slime_chase/chase = controller.active_chase
	if(chase && chase.execution_index < execution_index && evaluate_for_observer(controller))
		return
	return ..()

/**
 * Looks for a target now and then, and keeps the one we've got while it's still good.
 * These run in the background while the chases deal with whatever they find.
 */
/datum/bt_node/ai_behavior/slime_find_target
	time_between_perform = 2 SECONDS
	/// Blackboard key the target lives in
	var/target_key
	/// How far we look
	var/scan_range = 7
	/// If set, a candidate only becomes our target once we've found a walkable path to it
	var/must_be_reachable = FALSE
	/// Whether we look for a new target while latched onto someone
	var/scans_while_latched = TRUE

/datum/bt_node/ai_behavior/slime_find_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller)
	if(!should_scan(controller))
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!scans_while_latched && slime_pawn.is_latched())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	pre_scan(controller)

	// the fence is see-through, but nothing outside it is ever reachable
	var/datum/slime_pen/pen = must_be_reachable ? slime_pawn.pen : null
	var/atom/current = controller.blackboard[target_key]
	if(!QDELETED(current) && !controller.is_ignoring(current) && !(pen && !pen.turfs[get_turf(current)]) && is_valid_target(controller, current))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	controller.clear_blackboard_key(target_key)

	var/list/candidates = find_candidates(controller, pen)
	if(!length(candidates))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/picked = pick_target(controller, candidates)
	if(!must_be_reachable || slime_pawn.Adjacent(picked))
		controller.set_blackboard_key(target_key, picked)
	else if(get_dist(slime_pawn, picked) > 1 || slime_pawn.z != picked.z)
		// the path search is async, so the target only lands once it comes back
		request_path(controller, picked)
	else
		// right next to it, but a pen fence is in the way
		controller.ignore_target(picked, SLIME_CHASE_GIVE_UP_TIME)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Whether we get to look for (and keep) anything right now. A FALSE here drops our target too.
/datum/bt_node/ai_behavior/slime_find_target/proc/should_scan(datum/ai_controller/basic_controller/slime/controller)
	return TRUE

/// Anything to do before looking around, once we know we're going to.
/datum/bt_node/ai_behavior/slime_find_target/proc/pre_scan(datum/ai_controller/basic_controller/slime/controller)
	return

/// Starts the path search that decides whether a candidate is reachable. on_path_found() gets the result.
/datum/bt_node/ai_behavior/slime_find_target/proc/request_path(datum/ai_controller/basic_controller/slime/controller, atom/candidate)
	SSpathfinder.pathfind(controller.pawn, candidate, max_distance = SLIME_REACH_DISTANCE, mintargetdist = 1, access = controller.get_access(), on_finish = list(CALLBACK(src, PROC_REF(on_path_found), controller, candidate)))

/// Runs when pathfinding finishes. We go for the target if the path actually gets us next to it.
/datum/bt_node/ai_behavior/slime_find_target/proc/on_path_found(datum/ai_controller/basic_controller/slime/controller, atom/candidate, list/path)
	if(QDELETED(controller) || QDELETED(candidate) || controller.blackboard[target_key])
		return
	if(!length(path))
		controller.ignore_target(candidate, SLIME_CHASE_GIVE_UP_TIME)
		return
	// the path only has to end next to the target, which can still be the wrong side of a fence
	var/turf/path_end = path[length(path)]
	if(!path_end.Adjacent(candidate, candidate, controller.pawn))
		controller.ignore_target(candidate, SLIME_CHASE_GIVE_UP_TIME)
		return
	controller.set_blackboard_key(target_key, candidate)

/// Whether a candidate isn't ignored, isn't outside our pen, and passes is_valid_target().
/datum/bt_node/ai_behavior/slime_find_target/proc/is_candidate(datum/ai_controller/basic_controller/slime/controller, atom/candidate, datum/slime_pen/pen)
	if(controller.is_ignoring(candidate) || (pen && !pen.turfs[get_turf(candidate)]))
		return FALSE
	return is_valid_target(controller, candidate)

/// Everything from get_candidates() that passes is_candidate().
/datum/bt_node/ai_behavior/slime_find_target/proc/find_candidates(datum/ai_controller/basic_controller/slime/controller, datum/slime_pen/pen)
	. = list()
	for(var/atom/candidate as anything in get_candidates(controller))
		if(is_candidate(controller, candidate, pen))
			. += candidate

/// Whether there's anything around we'd go for, without actually picking it.
/datum/bt_node/ai_behavior/slime_find_target/proc/has_candidates(datum/ai_controller/basic_controller/slime/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return length(find_candidates(controller, must_be_reachable ? slime_pawn.pen : null)) > 0

/// Everything nearby that could be a target.
/datum/bt_node/ai_behavior/slime_find_target/proc/get_candidates(datum/ai_controller/controller)
	return list()

/// Can this be our target? Also decides if we keep the one we've got.
/datum/bt_node/ai_behavior/slime_find_target/proc/is_valid_target(datum/ai_controller/controller, atom/target)
	return FALSE

/// Picks one of the possible targets. Random, unless a subtype says otherwise.
/datum/bt_node/ai_behavior/slime_find_target/proc/pick_target(datum/ai_controller/controller, list/candidates)
	return pick(candidates)

/datum/bt_node/ai_behavior/slime_find_target/meal
	target_key = BB_SLIME_EAT_TARGET
	must_be_reachable = TRUE
	scans_while_latched = FALSE

// slime_food turns down everyone but grudges for cleaners, so don't scan for meals we'd never eat
/datum/bt_node/ai_behavior/slime_find_target/meal/should_scan(datum/ai_controller/basic_controller/slime/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return !slime_pawn.cleaner_slime || length(controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])

/datum/bt_node/ai_behavior/slime_find_target/meal/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/candidate in oview(scan_range, controller.pawn))
		if(!isslime(candidate))
			. += candidate

/datum/bt_node/ai_behavior/slime_find_target/meal/is_valid_target(datum/ai_controller/controller, atom/target)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	return strategy.is_valid_target(controller.pawn, target, scan_range, controller)

// stagger it out a bit so it feels more natural
/datum/bt_node/ai_behavior/slime_find_target/meal/get_cooldown(datum/ai_controller/cooldown_for)
	return rand(1 SECONDS, 4 SECONDS)

/datum/bt_node/ai_behavior/slime_find_target/grudge
	target_key = BB_CURRENT_TARGET
	scan_range = 9

/datum/bt_node/ai_behavior/slime_find_target/grudge/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/atom/attacker as anything in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		if(get_dist(controller.pawn, attacker) <= scan_range)
			. += attacker

/datum/bt_node/ai_behavior/slime_find_target/grudge/is_valid_target(datum/ai_controller/controller, atom/target)
	if(!(target in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]) || !can_see(controller.pawn, target, scan_range))
		return FALSE
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	return strategy.is_valid_target(controller.pawn, target, scan_range, controller)

/datum/bt_node/ai_behavior/slime_find_target/item
	target_key = BB_SLIME_ITEM_TARGET
	must_be_reachable = TRUE

/datum/bt_node/ai_behavior/slime_find_target/item/should_scan(datum/ai_controller/basic_controller/slime/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return !slime_pawn.is_latched() && slime_pawn.stat == CONSCIOUS

/datum/bt_node/ai_behavior/slime_find_target/item/get_candidates(datum/ai_controller/controller)
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	if(!length(wanted_types))
		return list()
	return typecache_filter_list(oview(scan_range, controller.pawn), wanted_types)

/datum/bt_node/ai_behavior/slime_find_target/item/is_valid_target(datum/ai_controller/controller, atom/target)
	var/obj/item/item_target = target
	if(!isitem(item_target) || !isturf(item_target.loc))
		return FALSE
	if(astype(item_target, /obj/item/slime_extract)?.fresh_from_slime)
		return FALSE
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	return !!wanted_types?[item_target.type]

/datum/bt_node/ai_behavior/slime_find_target/mess
	target_key = BB_SLIME_CLEAN_TARGET
	time_between_perform = 0.5 SECONDS
	must_be_reachable = TRUE

/datum/bt_node/ai_behavior/slime_find_target/mess/finalize_node(datum/ai_controller/basic_controller/slime/controller, list/to_visit)
	. = ..()
	if(istype(controller))
		controller.mess_finder = src

/datum/bt_node/ai_behavior/slime_find_target/mess/should_scan(datum/ai_controller/basic_controller/slime/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return slime_pawn.cleaner_slime && !slime_pawn.is_latched() && slime_pawn.stat == CONSCIOUS

/datum/bt_node/ai_behavior/slime_find_target/mess/get_candidates(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	. = list()
	var/list/messy_turfs = list()
	var/other_cleaner_around = FALSE
	for(var/atom/movable/candidate in oview(scan_range, slime_pawn))
		if(slime_pawn.can_dissolve(candidate))
			. += candidate
			messy_turfs[candidate.loc] = TRUE
		else if(isslime(candidate))
			var/mob/living/basic/slime/other_slime = candidate
			other_cleaner_around ||= other_slime.cleaner_slime

	if(!controller.blackboard_key_exists(BB_SLIME_ROAM_PLAYER))
		return
	// off to find someone, so we walk past messes unless it's a proper disaster nobody else is around to handle
	if(length(messy_turfs) < 15 || other_cleaner_around)
		return list()
	controller.clear_blackboard_key(BB_SLIME_ROAM_PLAYER)

/datum/bt_node/ai_behavior/slime_find_target/mess/find_candidates(datum/ai_controller/basic_controller/slime/controller, datum/slime_pen/pen)
	. = ..()
	controller.mess_nearby = length(.) > 0
	COOLDOWN_START(controller, mess_scan_reuse, 1 SECONDS)

/datum/bt_node/ai_behavior/slime_find_target/mess/has_candidates(datum/ai_controller/basic_controller/slime/controller)
	if(!COOLDOWN_FINISHED(controller, mess_scan_reuse))
		return controller.mess_nearby
	return ..()

/datum/bt_node/ai_behavior/slime_find_target/mess/pick_target(datum/ai_controller/controller, list/candidates)
	return get_closest_atom(/atom/movable, candidates, controller.pawn)

/datum/bt_node/ai_behavior/slime_find_target/mess/is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return ismovable(target) && slime_pawn.can_dissolve(target)

/datum/bt_node/ai_behavior/slime_find_target/friend
	target_key = BB_SLIME_NUZZLE_TARGET
	must_be_reachable = TRUE

/datum/bt_node/ai_behavior/slime_find_target/friend/should_scan(datum/ai_controller/basic_controller/slime/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return slime_pawn.wants_to_nuzzle()

/datum/bt_node/ai_behavior/slime_find_target/friend/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/friend as anything in controller.blackboard[BB_FRIENDS_LIST])
		if(get_dist(controller.pawn, friend) <= scan_range)
			. += friend

/// players only. slimes befriend each other constantly, and a whole pen of them nuzzling in a circle is just noise
/datum/bt_node/ai_behavior/slime_find_target/friend/is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/friend = target
	if(!isliving(friend) || !friend.client || friend.stat != CONSCIOUS || friend.incapacitated())
		return FALSE
	// roaming cleaners have a station to clean, they only say hi in passing
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(slime_pawn.cleaner_slime && isnull(slime_pawn.pen) && get_dist(slime_pawn, friend) > 1)
		return FALSE
	return (friend in controller.blackboard[BB_FRIENDS_LIST]) && can_see(controller.pawn, friend, scan_range)

/// anyone on their feet who's actually playing, friend or not. grudges are left alone, those get dealt with elsewhere
/datum/bt_node/ai_behavior/slime_find_target/person
	target_key = BB_SLIME_BOUNCE_TARGET
	must_be_reachable = TRUE

/datum/bt_node/ai_behavior/slime_find_target/person/should_scan(datum/ai_controller/basic_controller/slime/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return slime_pawn.wants_to_bounce()

/datum/bt_node/ai_behavior/slime_find_target/person/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/person in oview(scan_range, controller.pawn))
		if(person.client)
			. += person

/datum/bt_node/ai_behavior/slime_find_target/person/is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/person = target
	if(!isliving(person) || isslime(person) || !person.client || person.stat != CONSCIOUS || person.body_position != STANDING_UP)
		return FALSE
	if(person in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		return FALSE
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(slime_pawn.cleaner_slime && isnull(slime_pawn.pen) && get_dist(slime_pawn, person) > 1)
		return FALSE
	return can_see(controller.pawn, person, scan_range)

/**
 * Walks up to a target and does something to it once close enough.
 * Keeps running while its target holds, the decorator above it drops it when the target's gone.
 */
/datum/bt_node/ai_behavior/slime_chase
	/// Blackboard key holding what we're after
	var/target_key
	/// How close we have to get before act() kicks in
	var/required_distance = 1
	/// Whether act() runs while we're still on the way, instead of only once we're close enough
	var/act_from_afar = FALSE
	/// Whether a chase that pathing gave up on drops the target and ignores it for a bit
	var/gives_up = TRUE
	/// Set when the movement system gives up on the path
	VAR_PRIVATE/movement_failed = FALSE
	/// What we last started walking towards, so a swapped target gets a fresh walk
	VAR_PRIVATE/atom/tracked_target

/datum/bt_node/ai_behavior/slime_chase/setup(datum/ai_controller/basic_controller/slime/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	controller.active_chase = src
	return TRUE

/datum/bt_node/ai_behavior/slime_chase/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/datum/bt_node/ai_behavior/slime_chase/perform(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, target) <= required_distance)
		movement_failed = FALSE
		return act(seconds_per_tick, controller, target)

	if(movement_failed)
		movement_failed = FALSE
		if(gives_up)
			// dropping it (and ignoring it for a few seconds so we pick something else meanwhile) beats walking into a wall forever
			controller.ignore_target(target, SLIME_CHASE_GIVE_UP_TIME)
			controller.clear_blackboard_key(target_key)
			return AI_BEHAVIOR_FAILED
		tracked_target = null
	if(target != tracked_target || !controller.ai_movement.moving_controllers[controller])
		controller.ai_movement.start_moving_towards(controller, target, required_distance)
		tracked_target = target
	if(act_from_afar)
		return act(seconds_per_tick, controller, target)
	return AI_BEHAVIOR_INSTANT

/// Deals with the target. Returns AI_BEHAVIOR_* flags, AI_BEHAVIOR_INSTANT on its own keeps the chase going.
/datum/bt_node/ai_behavior/slime_chase/proc/act(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, atom/target)
	return AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/slime_chase/finish_action(datum/ai_controller/basic_controller/slime/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	movement_failed = FALSE
	tracked_target = null
	if(controller.active_chase == src)
		controller.active_chase = null
	controller.ai_movement.stop_moving_towards(controller)
	return ..()

/datum/bt_node/ai_behavior/slime_chase/Destroy()
	tracked_target = null
	return ..()

/// Latch on and drain, or fight when that's not on the cards
/datum/bt_node/ai_behavior/slime_chase/hunt
	act_from_afar = TRUE
	/// Who we were going after last, so we know who to let go of when we stop
	VAR_PRIVATE/mob/living/last_target

/datum/bt_node/ai_behavior/slime_chase/hunt/act(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, mob/living/target)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	last_target = target
	if(world.time < slime_pawn.next_move)
		return AI_BEHAVIOR_INSTANT
	if(!target_still_valid(controller, target))
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_FAILED

	if(slime_pawn.buckled == target) // we got em boys
		return AI_BEHAVIOR_INSTANT
	if(slime_pawn.buckled)
		slime_pawn.stop_feeding()
	if(!slime_pawn.Adjacent(target))
		return AI_BEHAVIOR_INSTANT

	if(!slime_pawn.can_feed_on(target, silent = TRUE, check_adjacent = TRUE))
		controller.ignore_target(target, SLIME_CHASE_GIVE_UP_TIME)
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_FAILED
	slime_pawn.start_feeding(target)
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/slime_chase/hunt/finish_action(datum/ai_controller/controller, succeeded)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(isliving(slime_pawn.buckled) && slime_pawn.buckled == last_target)
		slime_pawn.stop_feeding()
	last_target = null
	return ..()

/datum/bt_node/ai_behavior/slime_chase/hunt/Destroy()
	last_target = null
	return ..()

/// Whether the hunt should keep going after this target.
/datum/bt_node/ai_behavior/slime_chase/hunt/proc/target_still_valid(datum/ai_controller/controller, mob/living/target)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	return strategy.is_valid_target(controller.pawn, target, controller.max_target_distance, controller)

/datum/bt_node/ai_behavior/slime_chase/hunt/meal
	target_key = BB_SLIME_EAT_TARGET

/datum/bt_node/ai_behavior/slime_chase/hunt/grudge
	target_key = BB_CURRENT_TARGET

/// A friend told us to go get em. Keeps at it through pathing trouble, but a corpse is done.
/datum/bt_node/ai_behavior/slime_chase/hunt/pet
	target_key = BB_CURRENT_PET_TARGET
	gives_up = FALSE

/datum/bt_node/ai_behavior/slime_chase/hunt/pet/target_still_valid(datum/ai_controller/controller, mob/living/target)
	if(!isliving(target) || QDELETED(target) || target.stat == DEAD)
		return FALSE
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return slime_pawn.buckled == target || slime_pawn.can_feed_on(target, silent = TRUE, check_friendship = TRUE)

/datum/bt_node/ai_behavior/slime_chase/eat_item
	target_key = BB_SLIME_ITEM_TARGET

/datum/bt_node/ai_behavior/slime_chase/eat_item/act(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, obj/item/meal)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!isturf(meal.loc) || !slime_pawn.Adjacent(meal))
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_FAILED
	return slime_pawn.eat_wanted_item(meal) ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/slime_chase/clean
	target_key = BB_SLIME_CLEAN_TARGET

/datum/bt_node/ai_behavior/slime_chase/clean/act(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, atom/movable/mess)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!slime_pawn.Adjacent(mess))
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_FAILED
	return slime_pawn.try_dissolve(mess) ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/slime_chase/nuzzle
	target_key = BB_SLIME_NUZZLE_TARGET

/datum/bt_node/ai_behavior/slime_chase/nuzzle/act(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, mob/living/friend)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	controller.clear_blackboard_key(target_key)
	if(!slime_pawn.Adjacent(friend))
		return AI_BEHAVIOR_FAILED
	slime_pawn.nuzzle(friend)
	return AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/slime_chase/bounce
	target_key = BB_SLIME_BOUNCE_TARGET

/datum/bt_node/ai_behavior/slime_chase/bounce/act(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, mob/living/person)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	controller.clear_blackboard_key(target_key)
	if(!slime_pawn.Adjacent(person))
		return AI_BEHAVIOR_FAILED
	slime_pawn.bounce_off(person)
	return AI_BEHAVIOR_SUCCEEDED

/// Slime pet command attack: chases BB_CURRENT_PET_TARGET down and latches on
/datum/bt_node/subtree/pet_command/attack/slime
	behavior_tree_json = "code/modules/research/xenobiology/slime_rancher/pet_command_attack_slime.bt.json"

/datum/pet_command/attack/slime
	speech_commands = list("attack", "sic", "kill", "eat", "feed")
	command_feedback = "blorbles"
	pointed_reaction = "and blorbles"
	refuse_reaction = "jiggles sadly"
	attack_subtree = /datum/bt_node/subtree/pet_command/attack/slime

#undef SLIME_REACH_DISTANCE
