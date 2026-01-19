/obj/item/magazine_shuffler
	desc = "A clunky device that sucks up the bullets of a magazine, shuffles them about, and then returns them in a random order. Works on guns as well."
	name = "magazine shuffler"
	icon = 'icons/obj/device.dmi'
	icon_state = "magazine_shuffler"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/magazine_shuffler/interact_with_atom(obj/item/interacting_with, mob/living/user, list/modifiers)
	var/obj/item/ammo_box/target = null
	if(istype(interacting_with, /obj/item/ammo_box))
		target = interacting_with
	else if(istype(interacting_with, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/gun = interacting_with
		if(!gun.magazine)
			balloon_alert(user, "no magazine!")
			return ITEM_INTERACT_BLOCKING
		target = gun?.magazine
	else
		return NONE
	balloon_alert(user, "shuffling...")
	playsound(src, 'sound/items/rped.ogg', 50, TRUE)
	if(do_after(user, 3 SECONDS, interacting_with))
		shuffle_inplace(target.stored_ammo)
		balloon_alert(user, "magazine shuffled")
	else
		balloon_alert(user, "aborted!")
	return ITEM_INTERACT_SUCCESS

