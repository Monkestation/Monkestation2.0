/datum/ai_behavior/find_potential_targets/with_item

/datum/ai_behavior/find_potential_targets/with_item/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	for(var/atom/filtered_target in filtered_targets)
		if(!ishuman(filtered_target))
			continue

		var/mob/living/carbon/human/human = filtered_target
		for(var/obj/item/item as anything in human.held_items)
			if(!item)
				continue
			if(item.type != controller.blackboard[BB_BASIC_MOB_SCARED_ITEM])
				continue

			return filtered_target
	// Otherwise we will return `null`
