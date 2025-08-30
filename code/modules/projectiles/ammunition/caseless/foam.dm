/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	desc = "It's Donk or Don't! Ages 8 and up."
	projectile_type = /obj/projectile/bullet/reusable/foam_dart
	caliber = CALIBER_FOAM
	icon = 'icons/obj/weapons/guns/toy.dmi'
	icon_state = "foamdart"
	base_icon_state = "foamdart"
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.1125)
	harmful = FALSE
	var/modified = FALSE
	var/min_choke_duration = 5 SECONDS
	var/max_choke_duration = 12 SECONDS

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
	RegisterSignal(src, COMSIG_FOOD_EATEN, PROC_REF(on_bite))

/obj/item/ammo_casing/caseless/foam_dart/proc/on_bite(atom/used_in, mob/living/target, mob/living/user, bitecount, bitesize)
	SIGNAL_HANDLER
	if (HAS_TRAIT(target, TRAIT_CLUMSY))
		inhale(target)
		return DESTROY_FOOD

/obj/item/ammo_casing/caseless/foam_dart/proc/inhale(mob/living/target)
	visible_message(span_danger("[target] inhales [src]!"), \
		span_userdanger("You inhale [src]!"))
	target.AddComponent(/datum/status_effect/choke, new src.type, flaming = FALSE, vomit_delay = rand(min_choke_duration, max_choke_duration))

/obj/item/ammo_casing/caseless/foam_dart/update_icon_state()
	. = ..()
	if(modified)
		icon_state = "[base_icon_state]_empty"
		loaded_projectile?.icon_state = "[base_icon_state]_empty"
		return
	icon_state = "[base_icon_state]"
	loaded_projectile?.icon_state = "[loaded_projectile.base_icon_state]"

/obj/item/ammo_casing/caseless/foam_dart/update_desc()
	. = ..()
	desc = "It's Donk or Don't! [modified ? "... Although, this one doesn't look too safe." : "Ages 8 and up."]"

/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/A, mob/user, params)
	var/obj/projectile/bullet/reusable/foam_dart/FD = loaded_projectile
	if (A.tool_behaviour == TOOL_SCREWDRIVER && !modified)
		modified = TRUE
		FD.modified = TRUE
		FD.damage_type = BRUTE
		to_chat(user, span_notice("You pop the safety cap off [src]."))
		update_appearance()
	else if (istype(A, /obj/item/pen))
		if(modified)
			if(!FD.pen)
				harmful = TRUE
				if(!user.transferItemToLoc(A, FD))
					return
				FD.pen = A
				FD.damage = 5
				to_chat(user, span_notice("You insert [A] into [src]."))
			else
				to_chat(user, span_warning("There's already something in [src]."))
		else
			to_chat(user, span_warning("The safety cap prevents you from inserting [A] into [src]."))
	else
		return ..()

/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/projectile/bullet/reusable/foam_dart/FD = loaded_projectile
	if(FD.pen)
		FD.damage = initial(FD.damage)
		user.put_in_hands(FD.pen)
		to_chat(user, span_notice("You remove [FD.pen] from [src]."))
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "riot foam dart"
	desc = "Whose smart idea was it to use toys as crowd control? Ages 18 and up."
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/riot
	icon_state = "foamdart_riot"
	base_icon_state = "foamdart_riot"
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT* 1.125)
	min_choke_duration = 12 SECONDS
	max_choke_duration = 20 SECONDS
