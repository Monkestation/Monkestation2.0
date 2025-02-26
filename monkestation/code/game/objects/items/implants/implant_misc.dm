/obj/item/implanter/weapons_auth
	name = "implanter (Weapons Authorization)"
	imp_type = /obj/item/implant/weapons_auth

/obj/item/storage/box/syndie_kit/weapons_auth
	name = "Weapons Authorization kit"

/obj/item/storage/box/syndie_kit/weapons_auth/PopulateContents()
	new /obj/item/implanter/weapons_auth(src)

/obj/item/implant/radio/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(.)
		ADD_TRAIT(target, TRAIT_CAN_HEAR_MUSIC, REF(src))

/obj/item/implant/radio/removed(mob/living/source, silent, special)
	. = ..()
	if(.)
		REMOVE_TRAIT(source, TRAIT_CAN_HEAR_MUSIC, REF(src))
