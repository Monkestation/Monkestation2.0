/// Accepts visible hydroponics trays a bee can currently pollinate.
/datum/targeting_strategy/pollinatable_hydro

/datum/targeting_strategy/pollinatable_hydro/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!target.GetComponent(/datum/component/plant_growing) || SEND_SIGNAL(target, COMSIG_GROWER_CHECK_POLLINATED))
		return FALSE
	return can_see(living_mob, target, vision_range)
