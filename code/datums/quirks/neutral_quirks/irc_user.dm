/datum/quirk/irc_user
	name = "IRC User"
	desc = "You love chatting with friends, despite how unused your method of doing so is. You spawn with Chat Client preinstalled on your PDA."
	icon = FA_ICON_LANGUAGE
	value = 0
	gain_text = span_notice("You installed Chat Client on your PDA before coming aboard.")
	lose_text = span_danger("Other, simpler methods of talking to people far away start seeming more reasonable.")
	medical_record_text = "Patient is a fucking neeeeerd!"
	mail_goodies = list(/obj/item/modular_computer/laptop)

/datum/quirk/irc_user/add_unique(client/client_source)
	. = ..()
	message_admins("quirk added")
	var/mob/living/carbon/human/human_holder = quirk_holder
	for(var/obj/item/modular_computer/pda/devices in human_holder.contents)
		message_admins("pda [devices]")
		devices.store_file(new /datum/computer_file/program/chatclient)
		to_chat(
			human_holder,
			span_notice("Chat Client was installed on [devices]."),
			MESSAGE_TYPE_INFO
		)

// monkestation edit end
