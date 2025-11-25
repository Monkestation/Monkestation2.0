/obj/item/magazine_shuffler
	desc = "A peculiar device that somehow worms its way into any magazine in or outside a gun and shuffles the bullets within."
	name = "magazine shuffler"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "musicaltuner"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE

/obj/item/magazine_shuffler/interact_with_atom(obj/item/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/ammo_box))
		var/obj/item/ammo_box/item = interacting_with
		balloon_alert(user, "shuffling...")
		playsound(src, 'sound/items/rped.ogg', 50, TRUE)
		if(do_after(user, 3 SECONDS, item))
			shuffle_inplace(item?.stored_ammo)
			balloon_alert(user, "magazine shuffled")
		else
			balloon_alert(user, "aborted!")
	else if(istype(interacting_with, /obj/item/gun/ballistic)) // this could probably be better.
		var/obj/item/gun/ballistic/gun = interacting_with
		if(!gun.magazine)
			balloon_alert(user, "no magazine!")
			return
		balloon_alert(user, "shuffling...")
		playsound(src, 'sound/items/rped.ogg', 50, TRUE)
		if(do_after(user, 3 SECONDS, gun))
			shuffle_inplace(gun?.magazine.stored_ammo)
			balloon_alert(user, "magazine shuffled")
		else
			balloon_alert(user, "aborted!")

