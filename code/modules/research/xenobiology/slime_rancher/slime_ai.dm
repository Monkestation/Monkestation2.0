/// How far (in path steps) a slime will walk to reach something it spotted
#define SLIME_REACH_DISTANCE 10

/// Brain for slimes.
/datum/ai_controller/basic_controller/slime
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/slime_food,
		BB_SLIME_RABID = FALSE,
		BB_SLIME_HUNGER_DISABLED = FALSE,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	// first match wins, so this is also the priority order
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/slime,
		/datum/ai_planning_subtree/slime_escape_captivity,
		/datum/ai_planning_subtree/use_mob_ability/slime_evolve,
		/datum/ai_planning_subtree/slime_wild_split,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/slime_target/meal,
		/datum/ai_planning_subtree/slime_target/grudge,
		/datum/ai_planning_subtree/slime_target/forage,
		/datum/ai_planning_subtree/slime_target/clean,
		/datum/ai_planning_subtree/slime_target/nuzzle,
		/datum/ai_planning_subtree/slime_target/bounce,
	)
	// idling cancels every action, which would unlatch a whole pen the moment the xenobiologist walks off
	can_idle = FALSE

/// TRAIT_AI_PAUSED only stops process(), and we don't want to plan while paused either
/datum/ai_controller/basic_controller/slime/able_to_plan()
	if(HAS_TRAIT(pawn, TRAIT_AI_PAUSED))
		return FALSE
	return ..()

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

/// Pauses our AI for as long as any source holds it. Each source only lifts its own.
/mob/living/basic/slime/proc/pause_ai(source)
	ADD_TRAIT(src, TRAIT_AI_PAUSED, source)
	ai_controller?.CancelActions()

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
	if(buckled || !length(wanted_types))
		return FALSE
	for(var/mob/living/neighbor in oview(1, src))
		for(var/obj/item/held in neighbor.held_items)
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
	ai_controller.CancelActions()
	for(var/stale_key in list(
		BB_SLIME_EAT_TARGET,
		BB_BASIC_MOB_CURRENT_TARGET,
		BB_SLIME_ITEM_TARGET,
		BB_SLIME_NUZZLE_TARGET,
		BB_SLIME_BOUNCE_TARGET,
		BB_SLIME_CLEAN_TARGET,
		BB_ACTIVE_PET_COMMAND,
		BB_CURRENT_PET_TARGET,
		BB_TEMPORARY_IGNORE_LIST,
		BB_BASIC_MOB_RETALIATE_LIST,
	))
		ai_controller.clear_blackboard_key(stale_key)
	refresh_wanted_targets()
	balloon_alert_to_viewers("shakes [p_them()]self off")

/// What a slime will chase down and drain. Grudges count too, even inedible ones - those just get fought.
/datum/targeting_strategy/slime_food

/datum/targeting_strategy/slime_food/can_attack(mob/living/living_mob, atom/target, vision_range)
	var/mob/living/basic/slime/hunter = living_mob
	var/datum/ai_controller/controller = hunter.ai_controller
	if(!isslime(hunter) || isnull(controller) || !isliving(target) || QDELETED(target))
		return FALSE

	if(target in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		var/datum/targeting_strategy/grudge_strategy = GET_TARGETING_STRATEGY(/datum/targeting_strategy/basic/not_friends)
		return grudge_strategy.can_attack(living_mob, target, vision_range)

	var/mob/living/candidate = target
	// checked before the latched-meal line, so flipping either on mid-meal makes us let go
	if(hunter.cleaner_slime)
		return FALSE
	if(hunter.cat_slime && candidate.mob_size >= hunter.mob_size)
		return FALSE
	// don't invalidate the meal we're already latched onto
	if(hunter.buckled == candidate)
		return TRUE
	if((FACTION_SLIME in candidate.faction) || (REF(candidate) in hunter.faction))
		return FALSE
	if(!hunter.can_feed_on(candidate, silent = TRUE))
		return FALSE
	if(!can_see(hunter, candidate, vision_range))
		return FALSE

	if(candidate == controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return TRUE
	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_STARVING && controller.blackboard[BB_SLIME_RABID])
		return TRUE
	// monkeys are humans here, so they're always on the menu
	if(ishuman(candidate) || isalien(candidate))
		return TRUE
	// critters we still owe a mutation stay food even after their quota's done - a critter-only pen still has to feed us
	var/list/wanted_mobs = controller.blackboard[BB_SLIME_WANTED_MOBS]
	return !!wanted_mobs?[candidate.type]

/datum/ai_planning_subtree/random_speech/slime
	speech_chance = 1
	speak = list("Blorble...", "Bzzt...")
	emote_hear = list("blorbles.")
	emote_see = list("lights up for a bit, then stops.", "bounces in place.", "jiggles!", "vibrates!")

/// Break out of lockers, chairs, grabs and cuffs
/datum/ai_planning_subtree/slime_escape_captivity

/datum/ai_planning_subtree/slime_escape_captivity/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/slime/slime_pawn = controller.pawn

	if(isobj(slime_pawn.buckled))
		controller.queue_behavior(/datum/ai_behavior/resist)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/atom/contained_in = slime_pawn.loc
	if(!isturf(contained_in) && !ismob(contained_in) && !istype(contained_in, /obj/item/clothing/head/mob_holder))
		if(slime_pawn.obj_damage > contained_in.damage_deflection)
			controller.queue_behavior(/datum/ai_behavior/slime_break_out)
		else
			controller.queue_behavior(/datum/ai_behavior/resist)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/mob/puller = slime_pawn.pulledby
	if(puller && puller.grab_state > GRAB_PASSIVE && !(puller in controller.blackboard[BB_FRIENDS_LIST]))
		controller.queue_behavior(/datum/ai_behavior/resist)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(HAS_TRAIT(slime_pawn, TRAIT_RESTRAINED))
		controller.queue_behavior(/datum/ai_behavior/resist)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Keeps hitting whatever we're stuck inside of
/datum/ai_behavior/slime_break_out

/datum/ai_behavior/slime_break_out/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/atom/container = slime_pawn.loc
	if(isturf(container) || QDELETED(container))
		finish_action(controller, TRUE)
		return
	slime_pawn.melee_attack(container)
	finish_action(controller, TRUE)

/datum/ai_planning_subtree/use_mob_ability/slime_evolve
	ability_key = BB_SLIME_EVOLVE

/// Wild slimes split on their own. Ranched ones wait for a rancher to prime them.
/datum/ai_planning_subtree/slime_wild_split

/datum/ai_planning_subtree/slime_wild_split/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(slime_pawn.is_ranched())
		return
	var/datum/action/reproduce = controller.blackboard[BB_SLIME_REPRODUCE]
	if(!reproduce?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/slime_wild_split)

/datum/ai_behavior/slime_wild_split

/datum/ai_behavior/slime_wild_split/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	finish_action(controller, slime_pawn.reproduce(feedback = FALSE))

/**
 * Scans for a target now and then, and goes after it while there is one.
 * Scans run on the finding behavior's own cooldown, so an idle slime has an empty plan and wanders.
 */
/datum/ai_planning_subtree/slime_target
	/// Blackboard key the target lives in
	var/target_key
	/// Picks (or re-validates) the target
	var/finding_behavior
	/// Walks over and deals with it. Has to be a distinct type per subtree, behaviors are singletons.
	var/acting_behavior
	/// Whether we look for a new target while latched onto someone
	var/scans_while_latched = TRUE

/datum/ai_planning_subtree/slime_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!should_scan(controller))
		return
	var/mob/living/slime_pawn = controller.pawn
	if((scans_while_latched || !slime_pawn.buckled) && controller.behavior_cooldowns[GET_AI_BEHAVIOR(finding_behavior)] <= world.time)
		controller.queue_behavior(finding_behavior, target_key)

	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return

	// the chase only aims itself on setup, so a freshly swapped target needs a fresh chase
	var/datum/ai_behavior/acting = GET_AI_BEHAVIOR(acting_behavior)
	if(LAZYACCESS(controller.current_behaviors, acting) && controller.current_movement_target != target)
		acting.finish_action(controller, FALSE, target_key)
	controller.queue_behavior(acting_behavior, target_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/// Whether this subtree gets to look for (and chase) anything right now
/datum/ai_planning_subtree/slime_target/proc/should_scan(datum/ai_controller/controller)
	return TRUE

/datum/ai_planning_subtree/slime_target/meal
	target_key = BB_SLIME_EAT_TARGET
	finding_behavior = /datum/ai_behavior/slime_find_target/meal
	acting_behavior = /datum/ai_behavior/slime_chase/hunt/meal
	scans_while_latched = FALSE

/datum/ai_planning_subtree/slime_target/grudge
	target_key = BB_BASIC_MOB_CURRENT_TARGET
	finding_behavior = /datum/ai_behavior/slime_find_target/grudge
	acting_behavior = /datum/ai_behavior/slime_chase/hunt/grudge

/datum/ai_planning_subtree/slime_target/forage
	target_key = BB_SLIME_ITEM_TARGET
	finding_behavior = /datum/ai_behavior/slime_find_target/item
	acting_behavior = /datum/ai_behavior/slime_chase/eat_item

/datum/ai_planning_subtree/slime_target/forage/should_scan(datum/ai_controller/controller)
	var/mob/living/slime_pawn = controller.pawn
	return !slime_pawn.buckled && slime_pawn.stat == CONSCIOUS

/datum/ai_planning_subtree/slime_target/clean
	target_key = BB_SLIME_CLEAN_TARGET
	finding_behavior = /datum/ai_behavior/slime_find_target/mess
	acting_behavior = /datum/ai_behavior/slime_chase/clean

/datum/ai_planning_subtree/slime_target/clean/should_scan(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return slime_pawn.cleaner_slime && !slime_pawn.buckled && slime_pawn.stat == CONSCIOUS

/datum/ai_planning_subtree/slime_target/nuzzle
	target_key = BB_SLIME_NUZZLE_TARGET
	finding_behavior = /datum/ai_behavior/slime_find_target/friend
	acting_behavior = /datum/ai_behavior/slime_chase/nuzzle

/datum/ai_planning_subtree/slime_target/nuzzle/should_scan(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(slime_pawn.wants_to_nuzzle())
		return TRUE
	controller.clear_blackboard_key(target_key)
	return FALSE

/datum/ai_planning_subtree/slime_target/bounce
	target_key = BB_SLIME_BOUNCE_TARGET
	finding_behavior = /datum/ai_behavior/slime_find_target/person
	acting_behavior = /datum/ai_behavior/slime_chase/bounce

/datum/ai_planning_subtree/slime_target/bounce/should_scan(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(slime_pawn.wants_to_bounce())
		return TRUE
	controller.clear_blackboard_key(target_key)
	return FALSE

/// Keeps our target if it's still good, otherwise picks a random good one in range
/datum/ai_behavior/slime_find_target
	action_cooldown = 2 SECONDS
	/// How far we look
	var/scan_range = 7
	/// If set, a candidate only becomes our target once we've found a walkable path to it
	var/must_be_reachable = FALSE

/datum/ai_behavior/slime_find_target/perform(seconds_per_tick, datum/ai_controller/basic_controller/slime/controller, target_key)
	. = ..()
	var/atom/current = controller.blackboard[target_key]
	if(!QDELETED(current) && !controller.is_ignoring(current) && is_valid_target(controller, current))
		finish_action(controller, TRUE)
		return
	controller.clear_blackboard_key(target_key)

	var/list/candidates = list()
	for(var/atom/candidate as anything in get_candidates(controller))
		if(controller.is_ignoring(candidate) || !is_valid_target(controller, candidate))
			continue
		candidates += candidate
	if(!length(candidates))
		finish_action(controller, FALSE)
		return

	var/atom/picked = pick_target(controller, candidates)
	var/mob/living/slime_pawn = controller.pawn
	if(!must_be_reachable || slime_pawn.Adjacent(picked))
		controller.set_blackboard_key(target_key, picked)
	else if(get_dist(slime_pawn, picked) > 1)
		// the path search is async, so the target only lands once it comes back
		SSpathfinder.pathfind(slime_pawn, picked, max_distance = SLIME_REACH_DISTANCE, mintargetdist = 1, access = controller.get_access(), on_finish = list(CALLBACK(src, PROC_REF(on_path_found), controller, target_key, picked)))
	else
		// right next to it, but a pen fence is in the way
		controller.ignore_target(picked, SLIME_CHASE_GIVE_UP_TIME)
	finish_action(controller, TRUE)

/// Runs when pathfinding finishes. We go for the target if the path actually gets us next to it.
/datum/ai_behavior/slime_find_target/proc/on_path_found(datum/ai_controller/basic_controller/slime/controller, target_key, atom/candidate, list/path)
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

/// Everything nearby that could be a target.
/datum/ai_behavior/slime_find_target/proc/get_candidates(datum/ai_controller/controller)
	return list()

/// Can this be our target? Also decides if we keep the one we've got.
/datum/ai_behavior/slime_find_target/proc/is_valid_target(datum/ai_controller/controller, atom/target)
	return FALSE

/// Picks one of the possible targets. Random, unless a subtype says otherwise.
/datum/ai_behavior/slime_find_target/proc/pick_target(datum/ai_controller/controller, list/candidates)
	return pick(candidates)

/datum/ai_behavior/slime_find_target/meal
	must_be_reachable = TRUE

/datum/ai_behavior/slime_find_target/meal/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/candidate in oview(scan_range, controller.pawn))
		if(!isslime(candidate))
			. += candidate

/datum/ai_behavior/slime_find_target/meal/is_valid_target(datum/ai_controller/controller, atom/target)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	return strategy.can_attack(controller.pawn, target, scan_range)

/datum/ai_behavior/slime_find_target/grudge
	scan_range = 9

/datum/ai_behavior/slime_find_target/grudge/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/atom/attacker as anything in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		if(get_dist(controller.pawn, attacker) <= scan_range)
			. += attacker

/datum/ai_behavior/slime_find_target/grudge/is_valid_target(datum/ai_controller/controller, atom/target)
	if(!(target in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]) || !can_see(controller.pawn, target, scan_range))
		return FALSE
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	return strategy.can_attack(controller.pawn, target, scan_range)

/datum/ai_behavior/slime_find_target/item
	must_be_reachable = TRUE

/datum/ai_behavior/slime_find_target/item/get_candidates(datum/ai_controller/controller)
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	if(!length(wanted_types))
		return list()
	return typecache_filter_list(oview(scan_range, controller.pawn), wanted_types)

/datum/ai_behavior/slime_find_target/item/is_valid_target(datum/ai_controller/controller, atom/target)
	var/obj/item/item_target = target
	if(!isitem(item_target) || !isturf(item_target.loc))
		return FALSE
	if(astype(item_target, /obj/item/slime_extract)?.fresh_from_slime)
		return FALSE
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	return !!wanted_types?[item_target.type]

/datum/ai_behavior/slime_find_target/mess
	action_cooldown = 0.5 SECONDS
	must_be_reachable = TRUE

/datum/ai_behavior/slime_find_target/mess/get_candidates(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	. = list()
	for(var/atom/movable/candidate in oview(scan_range, slime_pawn))
		if(slime_pawn.can_dissolve(candidate))
			. += candidate

/datum/ai_behavior/slime_find_target/mess/pick_target(datum/ai_controller/controller, list/candidates)
	return get_closest_atom(/atom/movable, candidates, controller.pawn)

/datum/ai_behavior/slime_find_target/mess/is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	return ismovable(target) && slime_pawn.can_dissolve(target)

/datum/ai_behavior/slime_find_target/friend
	must_be_reachable = TRUE

/datum/ai_behavior/slime_find_target/friend/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/friend as anything in controller.blackboard[BB_FRIENDS_LIST])
		if(get_dist(controller.pawn, friend) <= scan_range)
			. += friend

/// players only. slimes befriend each other constantly, and a whole pen of them nuzzling in a circle is just noise
/datum/ai_behavior/slime_find_target/friend/is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/friend = target
	if(!isliving(friend) || !friend.client || friend.stat != CONSCIOUS || friend.incapacitated())
		return FALSE
	return (friend in controller.blackboard[BB_FRIENDS_LIST]) && can_see(controller.pawn, friend, scan_range)

/// anyone on their feet who's actually playing, friend or not. grudges are left alone, those get dealt with elsewhere
/datum/ai_behavior/slime_find_target/person
	must_be_reachable = TRUE

/datum/ai_behavior/slime_find_target/person/get_candidates(datum/ai_controller/controller)
	. = list()
	for(var/mob/living/person in oview(scan_range, controller.pawn))
		if(person.client)
			. += person

/datum/ai_behavior/slime_find_target/person/is_valid_target(datum/ai_controller/controller, atom/target)
	var/mob/living/person = target
	if(!isliving(person) || isslime(person) || !person.client || person.stat != CONSCIOUS || person.body_position != STANDING_UP)
		return FALSE
	if(person in controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		return FALSE
	return can_see(controller.pawn, person, scan_range)

/**
 * Walks up to a target and does something to it once adjacent.
 * These get re-queued every plan while their target holds, so anything higher up can butt in just by winning a plan.
 */
/datum/ai_behavior/slime_chase
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// Whether a chase that pathing gave up on puts the target on a short ignore
	var/gives_up = TRUE

/datum/ai_behavior/slime_chase/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/slime_chase/finish_action(datum/ai_controller/basic_controller/slime/controller, succeeded, target_key)
	// the chases only restart when a target gets set, so one that pathing gave up on would sit there forever.
	// dropping it (and ignoring it for a few seconds so we pick something else meanwhile) fixes that
	if(!succeeded && gives_up && controller.consecutive_pathing_attempts >= controller.ai_movement.max_pathing_attempts)
		var/atom/failed_target = controller.blackboard[target_key]
		if(!QDELETED(failed_target))
			controller.ignore_target(failed_target, SLIME_CHASE_GIVE_UP_TIME)
		controller.clear_blackboard_key(target_key)
	return ..()

/// Latch on and drain, or fight when that's not on the cards
/datum/ai_behavior/slime_chase/hunt

/datum/ai_behavior/slime_chase/hunt/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(world.time < slime_pawn.next_move)
		return
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(!target_still_valid(controller, target, target_key))
		controller.clear_blackboard_key(target_key)
		finish_action(controller, FALSE, target_key)
		return

	if(slime_pawn.buckled == target) // we got em boys
		return
	if(slime_pawn.buckled)
		slime_pawn.stop_feeding()
	if(!slime_pawn.Adjacent(target))
		return

	if(!slime_pawn.can_feed_on(target, silent = TRUE, check_adjacent = TRUE))
		slime_pawn.melee_attack(target)
		return
	// a healthy player on their feet gets softened up a bit first
	if(target.body_position != STANDING_UP || prob(20) || !target.client || target.health < 20)
		slime_pawn.start_feeding(target)
		return
	slime_pawn.melee_attack(target)

/datum/ai_behavior/slime_chase/hunt/finish_action(datum/ai_controller/controller, succeeded, target_key)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(isliving(slime_pawn.buckled) && slime_pawn.buckled == controller.blackboard[target_key])
		slime_pawn.stop_feeding()
	return ..()

/// Whether the hunt should keep going after this target.
/datum/ai_behavior/slime_chase/hunt/proc/target_still_valid(datum/ai_controller/controller, mob/living/target, target_key)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[BB_TARGETING_STRATEGY])
	return strategy.can_attack(controller.pawn, target, controller.max_target_distance)

/datum/ai_behavior/slime_chase/hunt/meal

/datum/ai_behavior/slime_chase/hunt/grudge

/// A friend told us to go get em. Keeps at it through pathing trouble, but a corpse is done.
/datum/ai_behavior/slime_chase/hunt/pet
	gives_up = FALSE

/datum/ai_behavior/slime_chase/hunt/pet/target_still_valid(datum/ai_controller/controller, mob/living/target, target_key)
	return isliving(target) && !QDELETED(target) && target.stat != DEAD

/datum/ai_behavior/slime_chase/eat_item

/datum/ai_behavior/slime_chase/eat_item/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/obj/item/meal = controller.blackboard[target_key]
	if(QDELETED(meal) || !isturf(meal.loc) || !slime_pawn.Adjacent(meal))
		controller.clear_blackboard_key(target_key)
		finish_action(controller, FALSE, target_key)
		return
	finish_action(controller, slime_pawn.eat_wanted_item(meal), target_key)

/datum/ai_behavior/slime_chase/clean

/datum/ai_behavior/slime_chase/clean/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/atom/movable/mess = controller.blackboard[target_key]
	if(QDELETED(mess) || !slime_pawn.Adjacent(mess))
		controller.clear_blackboard_key(target_key)
		finish_action(controller, FALSE, target_key)
		return
	finish_action(controller, slime_pawn.try_dissolve(mess), target_key)

/datum/ai_behavior/slime_chase/nuzzle

/datum/ai_behavior/slime_chase/nuzzle/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/mob/living/friend = controller.blackboard[target_key]
	controller.clear_blackboard_key(target_key)
	if(QDELETED(friend) || !slime_pawn.Adjacent(friend))
		finish_action(controller, FALSE, target_key)
		return
	slime_pawn.nuzzle(friend)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/slime_chase/bounce

/datum/ai_behavior/slime_chase/bounce/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/mob/living/person = controller.blackboard[target_key]
	controller.clear_blackboard_key(target_key)
	if(QDELETED(person) || !slime_pawn.Adjacent(person))
		finish_action(controller, FALSE, target_key)
		return
	slime_pawn.bounce_off(person)
	finish_action(controller, TRUE, target_key)

/datum/pet_command/point_targeting/attack/slime
	speech_commands = list("attack", "sic", "kill", "eat", "feed")
	command_feedback = "blorbles"
	pointed_reaction = "and blorbles"
	refuse_reaction = "jiggles sadly"

/datum/pet_command/point_targeting/attack/slime/execute_action(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/atom/target = controller.blackboard[BB_CURRENT_PET_TARGET]
	// "eat" matches half the english language (great, heat, death...), so with nothing pointed at we just carry on as usual
	if(isnull(target))
		return
	if(slime_pawn.buckled == target || slime_pawn.can_feed_on(target, silent = TRUE, check_friendship = TRUE))
		controller.queue_behavior(/datum/ai_behavior/slime_chase/hunt/pet, BB_CURRENT_PET_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	..()
	return SUBTREE_RETURN_FINISH_PLANNING

#undef SLIME_REACH_DISTANCE
