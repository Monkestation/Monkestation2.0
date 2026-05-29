/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.2 SECONDS // We gotta check unfortunately often because we're in a race condition with nextmove
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	///do we finish this action after hitting once?
	var/terminate_after_action = FALSE
	var/melee_attacks = TRUE

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!controller.blackboard[targeting_strategy_key])
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	//Hiding location is priority
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/basic_melee_attack/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (world.time < pawn.next_move)
			return

	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	//targeting strategy will kill the action if not real anymore
	var/atom/target = controller.blackboard[target_key]
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy.can_attack(basic_mob, target))
		finish_action(controller, FALSE, target_key)
		return

	var/hiding_target = targeting_strategy.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!

	controller.set_blackboard_key(hiding_location_key, hiding_target)

	if(melee_attacks || !ismob(target))
		if(hiding_target) //Slap it!
			basic_mob.melee_attack(hiding_target)
		else
			basic_mob.melee_attack(target)

	if(terminate_after_action)
		finish_action(controller, TRUE, target_key)

/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_melee_attack/interact_once
	terminate_after_action = TRUE

/datum/ai_behavior/basic_melee_attack/interact_once/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_ranged_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3
	/// range we will try chasing the target before giving up
	var/chase_range = 9
	///do we care about avoiding friendly fire?
	var/avoid_friendly_fire =  FALSE

/datum/ai_behavior/basic_ranged_attack/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/basic_ranged_attack/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/basic/basic_mob = controller.pawn
	//targeting strategy will kill the action if not real anymore
	var/atom/target = controller.blackboard[target_key]
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy.can_attack(basic_mob, target, chase_range))
		finish_action(controller, FALSE, target_key)
		return

	var/atom/hiding_target = targeting_strategy.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!
	var/atom/final_target = hiding_target ? hiding_target : target

	if(!can_see(basic_mob, final_target, required_distance))
		return

	if(avoid_friendly_fire && check_friendly_in_path(basic_mob, target, targeting_strategy))
		adjust_position(basic_mob, target)
		return ..()

	controller.set_blackboard_key(hiding_location_key, hiding_target)
	basic_mob.RangedAttack(final_target)
	return ..() //only start the cooldown when the shot is shot

/datum/ai_behavior/basic_ranged_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_ranged_attack/proc/check_friendly_in_path(mob/living/source, atom/target, datum/targeting_strategy/targeting_strategy)



/datum/ai_behavior/basic_ranged_attack/proc/adjust_position(mob/living/living_pawn, atom/target)



/datum/ai_behavior/basic_ranged_attack/proc/calculate_trajectory(mob/living/source , atom/target)




/datum/ai_behavior/basic_ranged_attack/avoid_friendly_fire
	avoid_friendly_fire = TRUE
