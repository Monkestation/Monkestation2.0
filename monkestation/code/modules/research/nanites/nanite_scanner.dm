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

/obj/item/nanite_scanner/attack(mob/living/target_mob, mob/living/user, params)
	add_fingerprint(user)
	user.visible_message(span_notice("[user] analyzes [target_mob]'s nanites."))
	balloon_alert(user, "analyzing nanites")
	playsound(user.loc, 'monkestation/sound/nanites/nanite_scan.mp3', 50)
	var/response = SEND_SIGNAL(target_mob, COMSIG_NANITE_SCAN, user, TRUE)
	if(!response)
		to_chat(user, span_info("No nanites detected in the subject."))
