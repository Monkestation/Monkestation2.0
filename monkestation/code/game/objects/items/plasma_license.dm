/obj/item/card/plasma_license
	name = "License to Plasmaflood"
	desc = "A charred license letting the holder plasmaflood the halls. Not offically recognized by Nanotrasen."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	icon_state = "license"
	resistance_flags = FIRE_PROOF

/obj/item/card/plasma_license/attack_self(mob/user)
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [src.name]."), span_notice("You show \the [src.name]."))
	add_fingerprint(user)

/obj/item/card/plasma_license/Initialize(mapload)
	. = ..()
	message_admins("A plasmaflood license has been created.")
