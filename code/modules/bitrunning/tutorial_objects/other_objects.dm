/obj/item/autopsy_scanner/tutorial
	name = "tutorial autopsy scanner"
	desc = "Scan a cadaver with an autopsy scanner to complete this tutorial."
	var/list/players_that_completed = list()

/obj/item/autopsy_scanner/tutorial/scan_cadaver(mob/living/carbon/human/user, mob/living/carbon/scanned)
	. = ..()
	if(user.ckey in players_that_completed)
		to_chat(user, span_warning("You have already completed this tutorial!"))
		return

	reward_tutorial_completion(user, TUTORIAL_REWARD_LOW)
	playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50)
	visible_message(span_notice("[user] has completed the tutorial!"))
	players_that_completed += user.ckey
