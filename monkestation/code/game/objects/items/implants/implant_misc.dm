/obj/item/implant/radio/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(.)
		ADD_TRAIT(target, TRAIT_CAN_HEAR_MUSIC, REF(src))

/obj/item/implant/radio/removed(mob/living/source, silent, special)
	. = ..()
	if(.)
		REMOVE_TRAIT(source, TRAIT_CAN_HEAR_MUSIC, REF(src))
