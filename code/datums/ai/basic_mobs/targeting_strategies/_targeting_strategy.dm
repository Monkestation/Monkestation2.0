///Datum for basic mobs to define what they can attack,
///Global, just like ai_behaviors
/datum/targeting_strategy

///Returns true or false depending on if the target can be attacked by the mob
/datum/targeting_strategy/proc/can_attack(mob/living/living_mob, atom/target, vision_range)
	return

///Returns something the target might be hiding inside of
/datum/targeting_strategy/proc/find_hidden_mobs(mob/living/living_mob, atom/target)
	var/atom/target_hiding_location
	var/atom/target_loc = target.loc
	if(istype(target_loc, /obj/structure/closet) || istype(target_loc, /obj/machinery/disposal) || istype(target_loc, /obj/machinery/sleeper))
		target_hiding_location = target_loc
	return target_hiding_location

///A very simple targeting strategy that checks that the target is a valid fishing spot.
/datum/targeting_strategy/fishing

/datum/targeting_strategy/fishing/can_attack(mob/living/living_mob, atom/target, vision_range)
	return HAS_TRAIT(target, TRAIT_FISHING_SPOT)
