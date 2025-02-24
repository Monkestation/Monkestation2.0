/datum/ai_behavior/find_potential_targets/without_trait
	///our max size
	var/checks_size = FALSE

/datum/ai_behavior/find_potential_targets/without_trait/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/list/filtered_further = list()
	for(var/mob/living/filtered_target in filtered_targets)
		if(HAS_TRAIT(filtered_target, controller.blackboard[BB_BASIC_MOB_TARGETED_TRAIT]))
			continue

		if(filtered_target.client && controller.blackboard[BB_WONT_TARGET_CLIENTS])
			continue

		// `mob_size` only exists on `/mob/living` - anything else will ignore `checks_size`
		if(checks_size && isliving(controller.pawn))
			var/mob/living/us = controller.pawn
			if(filtered_target.mob_size >= us.mob_size)
				continue

		filtered_further += filtered_target

	if(filtered_further.len)
		return pick(filtered_further)
	// Otherwise we will return `null`

/datum/ai_behavior/find_potential_targets/without_trait/smaller
	/// Only select from targets that are equal or smaller in size to us. Has no effect if this ai
	/// behavior is ran by a non-`/mob/living`.
	checks_size = TRUE
