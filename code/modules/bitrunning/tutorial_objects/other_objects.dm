/obj/item/autopsy_scanner/tutorial
	name = "tutorial autopsy scanner"
	desc = "Scan a cadaver with an autopsy scanner to complete this tutorial."
	var/list/players_that_completed = list()

/obj/item/autopsy_scanner/tutorial/scan_cadaver(mob/living/carbon/human/user, mob/living/carbon/scanned)
	. = ..()
	if(user.ckey in players_that_completed)
		to_chat(src, span_warning("You have already completed this tutorial!"))
		return

	reward_tutorial_completion(user, TUTORIAL_REWARD_LOW)
	playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50)
	visible_message(span_notice("[user] has completed the tutorial!"))
	players_that_completed += user.ckey

/obj/machinery/quantum_server/tutorial_coop
	bitrunning_id = "tutorial_coop"
	bitrunning_network = BITRUNNER_DOMAIN_TUTORIAL

/obj/machinery/quantum_server/tutorial_solo
	bitrunning_id = "tutorial_solo"
	bitrunning_network = BITRUNNER_DOMAIN_TUTORIAL

/obj/machinery/computer/quantum_console/tutorial_coop
	bitrunning_id = "tutorial_coop"

/obj/machinery/computer/quantum_console/tutorial_solo
	bitrunning_id = "tutorial_solo"

/obj/machinery/netpod/tutorial_coop
	bitrunning_id = "tutorial_coop"


/obj/machinery/netpod/tutorial_solo
	bitrunning_id = "tutorial_solo"

/area/virtual_domain/powered/nonfullbright
	static_lighting = TRUE
