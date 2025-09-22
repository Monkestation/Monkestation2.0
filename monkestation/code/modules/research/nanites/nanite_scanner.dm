/obj/item/nanite_scanner
	name = "nanite scanner"
	icon = 'monkestation/icons/obj/machines/nanites/nanite_device.dmi'
	icon_state = "nanite_scanner"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to detect nanites and their programming."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT * 2)

/obj/item/nanite_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	add_fingerprint(user)
	user.visible_message(span_notice("[user] analyzes [interacting_with]'s nanites."))
	playsound(user.loc, 'monkestation/sound/nanites/nanite_scan.mp3', 50)
	var/response = SEND_SIGNAL(interacting_with, COMSIG_NANITE_SCAN, user, TRUE)
	if(response)
		balloon_alert(user, "analyzing nanites")
	else
		balloon_alert(user, "no nanites detected")
	return ITEM_INTERACT_SUCCESS
