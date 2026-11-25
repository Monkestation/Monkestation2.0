/// Accepts hydroponics trays whose plant health is below the seed's endurance threshold.
/datum/targeting_strategy/beamable_hydro

/datum/targeting_strategy/beamable_hydro/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/datum/component/plant_growing/growing = target.GetComponent(/datum/component/plant_growing)
	if(!growing)
		return FALSE
	for(var/slot in growing.managed_seeds)
		var/obj/item/seeds/seed = growing.managed_seeds[slot]
		var/datum/component/growth_information/info = seed?.GetComponent(/datum/component/growth_information)
		if(info && info.health_value < seed.endurance)
			return TRUE
	return FALSE
