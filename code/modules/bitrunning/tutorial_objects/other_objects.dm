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

/obj/machinery/power/smes/tutorial
	name = "tutorial SMES"
	desc = "Power and interact with this SMES machine to completely in order to finish this tutorial."
	var/list/players_that_completed = list()

//may allah, the most merciful. forgive me for this act of violation against nature.
/obj/machinery/power/smes/tutorial/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(total_capacity > total_charge() || !can_interact(user) || (user.ckey in players_that_completed))
		return

	reward_tutorial_completion(user, TUTORIAL_REWARD_LOW)
	playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50)
	visible_message(span_notice("[user] has completed the tutorial!"))
	players_that_completed += user.ckey

/obj/item/analyzer/tutorial
	name = "Tutorial Analyzer"
	desc = "Scan me in a normal pressured breathable environment on a non-space or shuttle area!"
	var/list/players_that_completed = list()

/obj/item/analyzer/tutorial/attack_self(mob/user, modifiers)
	. = ..()
	var/area/scanned_area = get_area(src)
	if(istype(scanned_area, /area/space/) || istype(scanned_area, /area/virtual_domain))
		to_chat(user, span_notice("You need to 'make an area'!"))
		return
	if(user.ckey in players_that_completed)
		to_chat(user, span_warning("You have already completed this tutorial!"))
		return

	playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50)
	to_chat(user, span_greenannounce("You've made an area! Good job, Just make it breathable and make (and then power) an APC!"))
	reward_tutorial_completion(user, TUTORIAL_REWARD_LOW)
