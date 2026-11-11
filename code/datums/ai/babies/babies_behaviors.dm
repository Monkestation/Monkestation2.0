#define FIND_PARTNER_COOLDOWN 1 MINUTES

/// Find someone to erp with
/datum/bt_node/ai_behavior/find_partner
	var/target_key
	var/partner_types_key
	var/child_types_key
	time_between_perform = 5 SECONDS
	var/range = 7
	var/max_nearby_pop = 3

/datum/bt_node/ai_behavior/find_partner/setup(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.gender == FEMALE)
		return FALSE
	if(!controller.blackboard[partner_types_key] || !controller.blackboard[child_types_key])
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/find_partner/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/pawn_mob = controller.pawn
	var/mob/living/living_pawn = controller.pawn
	var/maximum_pop = controller.blackboard[BB_MAX_CHILDREN] || max_nearby_pop
	var/list/similar_species_types = controller.blackboard[partner_types_key] + controller.blackboard[child_types_key]
	var/list/possible_partners = list()
	var/nearby_pop = 0

	for(var/mob/living/other in oview(range, pawn_mob))
		if(!pawn_mob.faction_check_atom(other))
			finish_action(controller, FALSE)
			return

		if(children >= max_children)
			finish_action(controller, FALSE)
			return

		if(other.stat != CONSCIOUS) //Check if it's conscious FIRST.
			continue

		if(is_type_in_list(other, child_types)) //Check for children SECOND.
			children++
			continue

		if(!is_type_in_list(other, partner_types) || !HAS_TRAIT(other, TRAIT_MOB_BREEDER))
			continue

		if(other.stat != CONSCIOUS)
			continue

		if(other.gender != living_pawn.gender && !(other.flags_1 & HOLOGRAM_1))
			possible_partners += other

	finish_action(controller, FALSE)


/// I'm not saying what this behavior does :flushed:
/datum/bt_node/ai_behavior/make_babies
	var/target_key
	var/child_types_key

/datum/bt_node/ai_behavior/make_babies/setup(datum/ai_controller/controller)
	var/mob/target = controller.blackboard[target_key]
	return !QDELETED(target) && target.stat == CONSCIOUS

/datum/bt_node/ai_behavior/make_babies/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.stat != CONSCIOUS)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), target, FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/make_babies/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)


#undef FIND_PARTNER_COOLDOWN
