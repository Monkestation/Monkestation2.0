/datum/quirk/irc_user
	name = "IRC User"
	desc = "You love chatting with friends. You spawn with Chat Client preinstalled on your PDA."
	icon = FA_ICON_LAPTOP_FILE
	value = 0
	gain_text = span_notice("You installed Chat Client on your PDA before coming aboard.")
	lose_text = span_danger("Other, simpler methods of talking to people far away start seeming more reasonable.")
	medical_record_text = "Patient is a fucking neeeeerd!"
	mail_goodies = list(/obj/item/modular_computer/laptop)

/datum/quirk/irc_user/add_unique(client/client_source)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/found_PDA = FALSE
	for(var/obj/item/modular_computer/pda/devices in human_holder.contents)
		devices.store_file(new /datum/computer_file/program/chatclient)
		to_chat(
			human_holder,
			span_notice("Chat Client was installed on [devices]."),
			MESSAGE_TYPE_INFO
		)
		found_PDA = TRUE
	if(!found_PDA) //okay chucklenuts, i guess you like to carry so much shit it forces your PDA into your backpack.
		for(var/obj/item/target in human_holder.get_storage_slots())
			for(var/obj/item/modular_computer/pda/devices in target.contents)
				devices.store_file(new /datum/computer_file/program/chatclient)
				to_chat(
					human_holder,
					span_notice("Chat Client was installed on [devices]."),
					MESSAGE_TYPE_INFO
				)
				found_PDA = TRUE
	if(!found_PDA)
		to_chat(
			human_holder,
			span_warning("A PDA couldnt be found on your person, and Chat Client was not installed."),
			MESSAGE_TYPE_INFO,
		)

// monkestation edit end
