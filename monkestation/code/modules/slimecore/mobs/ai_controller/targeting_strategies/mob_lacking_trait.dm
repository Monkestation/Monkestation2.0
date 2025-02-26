/datum/targeting_strategy/basic/mob_lacking_trait
	var/target_trait_key = BB_BASIC_MOB_TARGETED_TRAIT
	/// Only select from mobs that are equal or smaller in size to us.
	var/checks_size = FALSE

/datum/targeting_strategy/basic/mob_lacking_trait/can_attack(mob/living/living_mob, atom/target, vision_range)
	var/datum/ai_controller/controller = living_mob.ai_controller
	var/mob/living/living_target = target
	var/targeted_trait = controller.blackboard[target_trait_key]

	if(!istype(living_target))
		return FALSE
	if (targeted_trait == null)
		return FALSE // no nop

	// Check if our parent behaviour agrees we can attack this target (we ignore faction by default)
	var/can_attack = ..()
	if(can_attack && !HAS_TRAIT(living_target, targeted_trait))
		if(checks_size)
			if(living_target.mob_size < living_mob.mob_size)
				return TRUE
		else
			return TRUE // they have the trait
	// No valid target
	return FALSE

/datum/targeting_strategy/basic/mob_lacking_trait/smaller
	checks_size = TRUE
