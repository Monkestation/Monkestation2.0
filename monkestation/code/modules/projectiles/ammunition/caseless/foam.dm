/obj/item/ammo_casing/caseless/foam_dart/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/edible, \
		initial_reagents = list( \
			/datum/reagent/consumable/nutriment = 1, \
			/datum/reagent/consumable/nutriment/protein = 0.5, \
		), \
		food_flags = FOOD_FINGER_FOOD, \
		tastes = list("foam" = 2, "action" = 2, "meat" = 1), \
		eatverbs = list("swallow" = 1), \
		eat_time = 0, \
		foodtypes = JUNKFOOD, \
		bite_consumption = 99999, \
	)
	ADD_TRAIT(src, TRAIT_FISHING_BAIT, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_FOOD_EATEN, PROC_REF(bite))

/obj/item/ammo_casing/caseless/foam_dart/proc/bite(atom/used_in, mob/living/target, mob/living/user, bitecount, bitesize)
	SIGNAL_HANDLER
	if (HAS_TRAIT(target, TRAIT_CLUMSY))
		target.AddComponent(/datum/status_effect/choke, new src.type, flaming = FALSE, vomit_delay = 10 SECONDS)
		return DESTROY_FOOD
