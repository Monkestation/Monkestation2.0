/obj/item/clothing/head/chameleon
	///string which set_hairstyle() will read
	var/picked_hairstyle
	///storage for the original hairstyle string
	var/actual_hairstyle

/obj/item/clothing/head/chameleon/attack_self(mob/user)
	var/hair_id = tgui_input_list(user, "How should your hair look while its disguised?", "Pick!", GLOB.hairstyles_list)
	if(!hair_id || hair_id == "Bald")
		balloon_alert(user, "error!")
		return
	balloon_alert(user, "[hair_id]")
	picked_hairstyle = hair_id

/obj/item/clothing/head/chameleon/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!ishuman(user) || !(slot_flags & slot))
		return
	if(!picked_hairstyle)
		return
	user.visible_message(
		span_notice("[user.name] ties up [user.p_their()] hair."),
		span_notice("You tie up your hair!"),
	)
	actual_hairstyle = user.hairstyle
	user.hairstyle = picked_hairstyle
	user.update_body_parts()

/obj/item/clothing/head/chameleon/dropped(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return
	if(!picked_hairstyle || !actual_hairstyle)
		return
	user.visible_message(
		span_notice("[user.name] takes [src] out of [user.p_their()] hair."),
		span_notice("You let down your hair!"),
	)
	user.hairstyle = actual_hairstyle
	user.update_body_parts()
	actual_hairstyle = null
