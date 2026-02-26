/obj/item/implantpad
	name = "implant pad"
	desc = "Used to modify implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "implantpad-0"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	interaction_flags_click = FORBID_TELEKINESIS_REACH|ALLOW_RESTING
	///The implant case currently inserted into the pad.
	var/obj/item/implantcase/inserted_case = null

/obj/item/implantpad/update_icon_state()
	icon_state = "implantpad-[!QDELETED(inserted_case)]"
	return ..()

/obj/item/implantpad/examine(mob/user)
	. = ..()
	if(!inserted_case)
		. += span_info("It is currently empty.")
		return

	if(Adjacent(user))
		. += span_info("It contains \a [inserted_case].")
	else
		. += span_warning("There seems to be something inside it, but you can't quite tell what from here...")
	. += span_info("Alt-click to remove [inserted_case].")

/obj/item/implantpad/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_case)
		inserted_case = null
		update_appearance(UPDATE_ICON)

/obj/item/implantpad/handle_atom_del(atom/A)
	if(A == inserted_case)
		inserted_case = null
	update_appearance()
	updateSelfDialog()
	. = ..()

/obj/item/implantpad/click_alt(mob/user)
	remove_implant(user)
	return CLICK_ACTION_SUCCESS

/obj/item/implantpad/attackby(obj/item/implantcase/C, mob/user, params)
	if(istype(C, /obj/item/implantcase) && !inserted_case)
		if(!user.transferItemToLoc(C, src))
			return
		inserted_case = C
		updateSelfDialog()
		update_appearance()
	else
		return ..()

/obj/item/implantpad/ui_interact(mob/user)
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		user.unset_machine(src)
		user << browse(null, "window=implantpad")
		return

	user.set_machine(src)
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if(inserted_case)
		if(inserted_case.imp)
			if(istype(inserted_case.imp, /obj/item/implant))
				dat += inserted_case.imp.get_data()
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	onclose(user, "implantpad")

///Removes the implant from the pad and puts it in the user's hands if possible.
/obj/item/implantpad/proc/remove_implant(mob/user)
	if(!inserted_case)
		user.balloon_alert(user, "no inserted_case inside!")
		return FALSE
	add_fingerprint(user)
	inserted_case.add_fingerprint(user)
	user.put_in_hands(inserted_case)
	user.balloon_alert(user, "inserted_case removed")
	update_appearance(UPDATE_ICON)
	updateSelfDialog()
	return TRUE
