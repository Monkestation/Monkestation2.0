/datum/ai_controller/basic_controller/slime
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/no_trait/slime,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/no_trait/slime,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_BASIC_MOB_SCARED_ITEM = /obj/item/extinguisher,
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_WONT_TARGET_CLIENTS = FALSE, //specifically to stop targetting clients
		BB_UNREACHABLE_LIST_COOLDOWN = 45 SECONDS, // how often we want to clear our unreachable list
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_slime_playful
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		//we try to flee first these flip flop based on flee state which is controlled by a componenet on the mob
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee_has_item,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/slime,
	)
	can_idle = FALSE // we want these to be running always


/datum/targeting_strategy/basic/no_trait/slime
	trait = TRAIT_LATCH_FEEDERED

/datum/targeting_strategy/basic/no_trait/slime/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if(isitem(the_target))
		return TRUE


/datum/targeting_strategy/basic/no_trait/slime/cat


/datum/targeting_strategy/basic/slime/cat/can_attack(mob/living/owner, atom/target, vision_range)
	. = ..()

	if(isitem(target))
		return .

	if(!.)
		return FALSE

	var/mob/living/mob_target = target
	return (owner.mob_size > mob_target.mob_size)


/datum/ai_movement/jps/slime_cleaner
	maximum_length = 80
