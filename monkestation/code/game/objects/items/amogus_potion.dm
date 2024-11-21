/obj/item/amogus_potion
	name = "strange flask"
	desc = "A strange flask with red liquid inside of it, looks like a potion. Drinking this is probably not a good idea."
	icon = 'monkestation/icons/obj/misc.dmi'
	icon_state	= "amogus_potion"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/amogus_potion/attack_self(mob/user, modifiers)
	. = ..()
	if(!ishuman)
		to_chat(user, span_userdanger("You know better than to drink it..."))
		return

	if(!ismonkey(user) && !isgoblin(user))
		to_chat(user, span_userdanger("You have a strange feeling as the world seems to grow around you!"))
		user.apply_displacement_icon(/obj/effect/distortion/large/amogus)
	else
		to_chat(user, span_userdanger("You feel strange..."))

	user.AddElement(/datum/element/waddling)
	user.can_be_held = TRUE
	to_chat(user, span_notice("You can now be picked up by other people."))
	qdel(src)
