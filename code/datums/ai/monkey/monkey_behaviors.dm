/datum/ai_behavior/battle_screech/monkey
	screeches = list("roar","screech")

/datum/ai_behavior/monkey_equip
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/monkey_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		controller.set_blackboard_key_assoc(BB_MONKEY_BLACKLISTITEMS, controller.blackboard[BB_MONKEY_PICKUPTARGET], TRUE)

	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/datum/ai_behavior/monkey_equip/proc/equip_item(datum/ai_controller/controller)





	// Strong weapon


	// EVERYTHING ELSE


/datum/ai_behavior/monkey_equip/ground
	required_distance = 0

/datum/ai_behavior/monkey_equip/ground/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	equip_item(controller)

/datum/ai_behavior/monkey_equip/pickpocket

/datum/ai_behavior/monkey_equip/pickpocket/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard[BB_MONKEY_PICKPOCKETING]) //We are pickpocketing, don't do ANYTHING!!!!
		return
	INVOKE_ASYNC(src, PROC_REF(attempt_pickpocket), controller)

/datum/ai_behavior/monkey_equip/pickpocket/proc/attempt_pickpocket(datum/ai_controller/controller)










/datum/ai_behavior/monkey_equip/pickpocket/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, FALSE)
	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/datum/ai_behavior/monkey_flee

/datum/ai_behavior/monkey_flee/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()

	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.health >= MONKEY_FLEE_HEALTH)
		finish_action(controller, TRUE) //we're back in bussiness
		return

	var/mob/living/target = null

	// flee from anyone who attacked us and we didn't beat down
	for(var/mob/living/L in view(living_pawn, MONKEY_FLEE_VISION))
		if(controller.blackboard[BB_MONKEY_ENEMIES][L] && L.stat == CONSCIOUS)
			target = L
			break

	if(target)
		SSmove_manager.move_away(living_pawn, target, max_dist=MONKEY_ENEMY_VISION, delay=5)
	else
		finish_action(controller, TRUE)

/datum/ai_behavior/monkey_attack_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/monkey_attack_mob/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/monkey_attack_mob/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(!target || target.stat != CONSCIOUS)
		finish_action(controller, TRUE) //Target == owned
		return

	if(isturf(target.loc) && !IS_DEAD_OR_INCAP(living_pawn)) // Check if they're a valid target
		// check if target has a weapon
		var/obj/item/W
		for(var/obj/item/I in target.held_items)
			if(!(I.item_flags & ABSTRACT))
				W = I
				break

		// if the target has a weapon, chance to disarm them
		if(W && SPT_PROB(MONKEY_ATTACK_DISARM_PROB, seconds_per_tick))
			monkey_attack(controller, target, seconds_per_tick, TRUE)
		else
			monkey_attack(controller, target, seconds_per_tick, FALSE)


/datum/ai_behavior/monkey_attack_mob/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	controller.clear_blackboard_key(target_key)
	if(QDELETED(living_pawn)) // pawn can be null at this point
		return
	SSmove_manager.stop_looping(living_pawn)

/// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/datum/ai_behavior/monkey_attack_mob/proc/monkey_attack(datum/ai_controller/controller, mob/living/target, seconds_per_tick, disarm)







	// attack with weapon if we have one

			// We attempt to attack even if we can't shoot so we get the effects of pulling the trigger

	// no de-aggro

	// we've queued up a monkey attack on a mob which isn't already an enemy, so give them 1 threat to start
	// note they might immediately reduce threat and drop from the list.
	// this is fine, we're just giving them a love tap then leaving them alone.
	// unless they fight back, then we retaliate

	// Some mobs delete on death. If the target is no longer alive, go back to idle


	/// mob refs are uids, so this is safe

	// if we are not angry at our target, go back to idle

/datum/ai_behavior/disposal_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/disposal_mob/setup(datum/ai_controller/controller, attack_target_key, disposal_target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[attack_target_key])

/datum/ai_behavior/disposal_mob/finish_action(datum/ai_controller/controller, succeeded, attack_target_key, disposal_target_key)
	. = ..()
	controller.clear_blackboard_key(attack_target_key) //Reset attack target
	controller.set_blackboard_key(BB_MONKEY_DISPOSING, FALSE) //No longer disposing
	controller.clear_blackboard_key(disposal_target_key) //No target disposal

/datum/ai_behavior/disposal_mob/perform(seconds_per_tick, datum/ai_controller/controller, attack_target_key, disposal_target_key)
	. = ..()

	if(controller.blackboard[BB_MONKEY_DISPOSING]) //We are disposing, don't do ANYTHING!!!!
		return

	var/mob/living/target = controller.blackboard[attack_target_key]
	var/mob/living/living_pawn = controller.pawn

	set_movement_target(controller, target)

	if(!target)
		finish_action(controller, FALSE)
		return

	if(target.pulledby != living_pawn && !HAS_AI_CONTROLLER_TYPE(target.pulledby, /datum/ai_controller/monkey)) //Dont steal from my fellow monkeys.
		if(living_pawn.Adjacent(target) && isturf(target.loc))
			target.grabbedby(living_pawn)
		return //Do the rest next turn

	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]
	set_movement_target(controller, disposal)

	if(!disposal)
		finish_action(controller, FALSE)
		return

	if(living_pawn.Adjacent(disposal))
		INVOKE_ASYNC(src, PROC_REF(try_disposal_mob), controller, attack_target_key, disposal_target_key) //put him in!
	else //This means we might be getting pissed!
		return

/datum/ai_behavior/disposal_mob/proc/try_disposal_mob(datum/ai_controller/controller, attack_target_key, disposal_target_key)




/datum/ai_behavior/recruit_monkeys/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()

	controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/nearby_monkey in view(living_pawn, MONKEY_ENEMY_VISION))
		if(QDELETED(nearby_monkey) || !HAS_AI_CONTROLLER_TYPE(nearby_monkey, /datum/ai_controller/monkey))
			continue
		if(!SPT_PROB(MONKEY_RECRUIT_PROB, seconds_per_tick))
			continue
		// Recruited a monkey to our side
		controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
		// Other monkeys now also hate the guy we're currently targeting
		nearby_monkey.ai_controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET], MONKEY_RECRUIT_HATED_AMOUNT)

	finish_action(controller, TRUE)

/datum/ai_behavior/monkey_set_combat_target/perform(seconds_per_tick, datum/ai_controller/controller, set_key, enemies_key)
	var/list/enemies = controller.blackboard[enemies_key]
	var/list/valids = list()
	for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, controller.pawn))
		if(possible_enemy == controller.pawn)
			continue // don't target ourselves
		if(!enemies[possible_enemy]) //We don't hate this creature! But we might still attack it!
			if(faction_check(possible_enemy.faction, list(FACTION_MONKEY, FACTION_JUNGLE), exact_match = FALSE) && !controller.blackboard[BB_MONKEY_TARGET_MONKEYS]) // do not target your team. includes monkys gorillas etc.
				continue
			if(HAS_AI_CONTROLLER_TYPE(possible_enemy, /datum/ai_controller/monkey) && !controller.blackboard[BB_MONKEY_TARGET_MONKEYS]) //Do not target poor monkes
				continue
		// Weighted list, so the closer they are the more likely they are to be chosen as the enemy
		valids[possible_enemy] = CEILING(100 / (get_dist(controller.pawn, possible_enemy) || 1), 1)

	if(!length(valids))
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(set_key, pick_weight(valids))
	finish_action(controller, TRUE)
