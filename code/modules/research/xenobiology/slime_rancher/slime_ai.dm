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
	ai_movement = /datum/ai_movement/basic_avoidance/adaptive

/datum/ai_controller/basic_controller/slime/get_access()
	var/mob/living/basic/slime/slime_pawn = pawn
	return slime_pawn.get_access()

/// remove_thing_from_blackboard_key() crashes on things that aren't there, this doesn't
/datum/ai_controller/basic_controller/slime/proc/forget(key, atom/thing)
	if(!(thing in blackboard[key]))
		return
	remove_thing_from_blackboard_key(key, thing)

/// Ignores a target until duration runs out. Never shortens an existing, longer ignore.
/datum/ai_controller/basic_controller/slime/proc/ignore_target(atom/target, duration)
	var/expires_at = world.time + duration
	if(LAZYACCESS(blackboard[BB_TEMPORARY_IGNORE_LIST], target) >= expires_at)
		return
	set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, expires_at)
	addtimer(CALLBACK(src, PROC_REF(expire_chase_exclusion), target, expires_at), duration)

/// Drops a chase exclusion we set, unless something longer-lived (a friend peeling us off) overwrote it since.
/datum/ai_controller/basic_controller/slime/proc/expire_chase_exclusion(atom/target, expires_at)
	if(LAZYACCESS(blackboard[BB_TEMPORARY_IGNORE_LIST], target) != expires_at)
		return
	remove_from_blackboard_lazylist_key(BB_TEMPORARY_IGNORE_LIST, target)

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


/datum/bt_node/subtree/pet_command/attack/slime
	behavior_tree_json = "code/modules/research/xenobiology/slime_rancher/pet_command_attack_slime.bt.json"

/datum/pet_command/follow/slime
	follow_subtree = /datum/bt_node/subtree/pet_command/follow/slime

/// The stock follow tree, except we only count as caught up on their floor, so we follow people up and down stairs
/datum/bt_node/subtree/pet_command/follow/slime
	behavior_tree_json = "code/modules/research/xenobiology/slime_rancher/pet_command_follow_slime.bt.json"

/// items the slime wants to eat, from BB_SLIME_WANTED_ITEMS, if it is set
/datum/target_source/slime_wanted_items

/datum/target_source/slime_wanted_items/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	if(!length(wanted_types))
		return list()
	var/list/candidates = typecache_filter_list(oview(range, pawn), wanted_types)
	for(var/obj/item/slime_extract/extract in candidates)
		if(extract.fresh_from_slime)
			candidates -= extract
	return candidates


/**
 * Gate for slime food searching: passes only when the slime is unbuckled and is
 * hungryor rabid.
 */
/datum/bt_node/decorator/slime_wants_to_eat

/datum/bt_node/decorator/slime_wants_to_eat/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.is_latched())
		return FALSE
	// slime_food turns down everyone but grudges for cleaners, so don't scan for meals we'd never eat
	if(slime_pawn.cleaner_slime && !length(controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]))
		return FALSE
	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] != SLIME_HUNGER_NONE)
		return TRUE
	if(controller.blackboard[BB_SLIME_RABID])
		return TRUE
	return TRUE


///im about to eat this guy up
/datum/bt_node/ai_behavior/feed_on_slime_target
	var/target_key

/datum/bt_node/ai_behavior/feed_on_slime_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn)) //bro lmao comeon
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(slime_pawn.buckled)
		if(slime_pawn.buckled == target) //we got em boys
			return AI_BEHAVIOR_DELAY
		else
			slime_pawn.stop_feeding()
			return AI_BEHAVIOR_FAILED //epic fail; try again

	if(!slime_pawn.can_feed_on(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if((target.body_position != STANDING_UP) || prob(20))
		slime_pawn.start_feeding(target)
		return AI_BEHAVIOR_DELAY

	if(target.client && target.health >= 20)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	slime_pawn.start_feeding(target)
	return AI_BEHAVIOR_DELAY


/datum/bt_node/ai_behavior/feed_on_slime_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	slime_pawn.stop_feeding()

/// the fence is see-through, but nothing outside it is ever reachable
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/slime
	/// goes for the closest candidate first, instead of a random one
	var/nearest_first = FALSE

/// Whether we're in a pen and this thing isn't.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/slime/proc/outside_our_pen(datum/ai_controller/controller, atom/thing)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/datum/slime_pen/pen = slime_pawn.pen
	return pen && !pen.turfs[get_turf(thing)]

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/slime/should_keep_target(datum/ai_controller/controller, datum/targeting_strategy/strategy, atom/current_target)
	if(current_target && outside_our_pen(controller, current_target))
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/slime/filter_candidates(datum/ai_controller/controller, list/candidates, datum/targeting_strategy/strategy, atom/current_target)
	var/list/penned_candidates = list()
	for(var/atom/candidate as anything in candidates)
		if(!outside_our_pen(controller, candidate))
			penned_candidates += candidate
	. = ..(controller, penned_candidates, strategy, current_target)
	if(!nearest_first || length(.) < 2)
		return .
	// our acquire_target has no priority strategies, so sort here. the reachable search tries them in order
	var/turf/our_turf = get_turf(controller.pawn)
	var/list/distances = list()
	for(var/atom/candidate as anything in .)
		distances[candidate] = get_dist(our_turf, candidate)
	sortTim(distances, GLOBAL_PROC_REF(cmp_numeric_asc), associative = TRUE)
	return distances.Copy()

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/slime/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	if(nearest_first)
		return filtered_targets[1]
	return ..()

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/slime/meal

// stagger it out a bit so it feels more natural
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/slime/meal/get_cooldown(datum/ai_controller/cooldown_for)
	return rand(1 SECONDS, 4 SECONDS)

/datum/bt_node/decorator/slime_is_wild

/datum/bt_node/decorator/slime_is_wild/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return FALSE
	return !slime_pawn.is_ranched()

/// Chases like the generic leaf, except it sits still (and stays running) while latched onto or standing next to its target.
/datum/bt_node/ai_behavior/move_to_target/slime_chase

/datum/bt_node/ai_behavior/move_to_target/slime_chase/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(!QDELETED(target) && (pawn.buckled == target || pawn.Adjacent(target)))
		// the moveloop counts every step it doesn't take as a pathing failure, and 10 of those kills the chase
		if(controller.ai_movement.moving_controllers[controller])
			controller.ai_movement.stop_moving_towards(controller)
		movement_failed = FALSE
		return AI_BEHAVIOR_INSTANT
	return ..()

/// these branches only butt in when their key gets freshly set. if one bails partway (pathing gave up,
/// say) the key is still sitting there perfectly valid, so nothing ever re-sets it and the slime
/// wanders right past its target forever. dropping the target on the way out puts that edge back,
/// and the target sits in the ignore list for a few seconds so we pick something else meanwhile.
/datum/bt_node/decorator/bb_key_set/slime_target

/datum/bt_node/decorator/bb_key_set/slime_target/on_child_complete(datum/ai_controller/controller, result)
	var/atom/failed_target = controller.blackboard[key]
	// the parallel bails without resetting its primary, so the feed or melee leaf would sit there "running"
	child.reset_subtree_tick_states()
	if(!QDELETED(failed_target))
		astype(controller, /datum/ai_controller/basic_controller/slime)?.ignore_target(failed_target, SLIME_CHASE_GIVE_UP_TIME)
	controller.clear_blackboard_key(key)

/// for the branches right above random_walk, which loops forever and never lets the selector look back up here on its own
/datum/bt_node/decorator/bb_key_set/slime_target/idle
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/bb_key_set/slime_target/idle/on_observed_change(datum/ai_controller/controller, key)
	// the stock check trusts active_execution_index, which is junk inside our big parallel
	if(child_active || !evaluate_for_observer(controller))
		return
	EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] [type]: [src.key] got set while idling, replanning")
	controller.cancel_current_plan()

/// check to see if we're free to go eat items laying around
/datum/bt_node/decorator/bb_key_set/slime_target/forage
	polling_rate = 1 SECONDS

/// buckled/unconscious have no blackboard signal to hang off of, so poll the whole thing instead of
/// trusting the parent's key signals. otherwise we miss the moment the slime gets back up
/datum/bt_node/decorator/bb_key_set/slime_target/forage/register_observe_signals(atom/pawn)
	return FALSE

/datum/bt_node/decorator/bb_key_set/slime_target/forage/unregister_observe_signals(atom/pawn)
	return

/datum/bt_node/decorator/bb_key_set/slime_target/forage/check_condition(datum/ai_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.is_latched() || IS_UNCONSCIOUS_OR_CRIT(slime_pawn))
		return FALSE
	return TRUE

/// small chance per tick for a slime to yoink a wanted item right out of an adjacent mob's hands
/// they don't chase people down, to be clear
/datum/bt_node/ai_behavior/snatch_held_item

/datum/bt_node/ai_behavior/snatch_held_item/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(15, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/list/wanted_types = controller.blackboard[BB_SLIME_WANTED_ITEMS]
	if(!istype(slime_pawn) || !length(wanted_types))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	for(var/mob/living/neighbor in oview(1, slime_pawn))
		for(var/obj/item/held in neighbor.get_held_items())
			if(!wanted_types[held.type])
				continue
			var/held_name = "\the [held]" // get this bc eating it might delete the item
			if(!slime_pawn.eat_wanted_item(held, silent = TRUE))
				continue
			slime_pawn.visible_message(
				span_notice("[slime_pawn] snatches [held_name] right out of [neighbor]'s hands!"),
				span_notice("You snatch [held_name] right out of [neighbor]'s hands!")
			)
			slime_pawn.balloon_alert_to_viewers("snatches item out of hand!")
			slime_pawn.set_temporary_mood(SLIME_MOOD_MISCHIEVOUS)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/// move_to_target that only counts as arrived on the target's own floor.
/// get_dist() calls a tile one floor up 1 away, so without the z check we'd "arrive" on the top step and never climb
/datum/bt_node/ai_behavior/move_to_target/same_z

/datum/bt_node/ai_behavior/move_to_target/same_z/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(!(. & AI_BEHAVIOR_SUCCEEDED))
		return .
	var/turf/pawn_turf = get_turf(controller.pawn)
	var/turf/target_turf = get_turf(controller.blackboard[target_key])
	if(pawn_turf?.z == target_turf?.z)
		return .
	return AI_BEHAVIOR_INSTANT

/// Slime pet command attack: chases BB_CURRENT_PET_TARGET down and latches on
/// Attack command that also lets slimes latch on and eat
/datum/pet_command/attack/slime
	speech_commands = list("attack", "sic", "kill", "eat", "feed")
	command_feedback = "blorbles"
	pointed_reaction = "and blorbles"
	refuse_reaction = "jiggles sadly"

/datum/pet_command/attack/slime/execute_action(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(isslime(slime_pawn) && slime_pawn.can_feed_on(controller.blackboard[BB_CURRENT_PET_TARGET], check_friendship = TRUE))
		controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, /datum/bt_node/subtree/pet_command/attack/slime)
		return
	return ..()
