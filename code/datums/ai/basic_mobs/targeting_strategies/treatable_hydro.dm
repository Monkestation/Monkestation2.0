/datum/targeting_strategy/treatable_hydro

/datum/targeting_strategy/treatable_hydro/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/datum/component/plant_growing/growing = target.GetComponent(/datum/component/plant_growing)
	if(!growing || !controller || !(locate(/obj/item/seeds) in target.contents))
		return FALSE
	if(growing.water_precent < controller.blackboard[BB_WATERLEVEL_THRESHOLD])
		if(locate(/obj/item/reagent_containers/cup/watering_can) in living_mob)
			return TRUE
	if(growing.weed_level > controller.blackboard[BB_WEEDLEVEL_THRESHOLD])
		return TRUE
	for(var/slot in growing.managed_seeds)
		var/obj/item/seeds/seed = growing.managed_seeds[slot]
		var/datum/component/growth_information/info = seed?.GetComponent(/datum/component/growth_information)
		if(info?.plant_state == HYDROTRAY_PLANT_DEAD)
			return TRUE
	return FALSE
