/obj/item/autopsy_scanner/tutorial
	name = "tutorial autopsy scanner"
	desc = "Scan a cadaver with an autopsy scanner to complete this tutorial."
	var/datum/tutorial_reward/reward

/obj/item/autopsy_scanner/tutorial/Initialize(mapload)
	. = ..()
	reward = new(TUTORIAL_REWARD_LOW)

/obj/item/autopsy_scanner/tutorial/scan_cadaver(mob/living/carbon/human/user, mob/living/carbon/scanned)
	. = ..()
	reward.award(user)

/obj/machinery/power/smes/tutorial
	name = "tutorial SMES"
	desc = "Power and interact with this SMES machine to completely in order to finish this tutorial."
	var/datum/tutorial_reward/reward

/obj/machinery/power/smes/tutorial/Initialize(mapload)
	. = ..()
	reward = new(TUTORIAL_REWARD_LOW)

//may allah, the most merciful. forgive me for this act of violation against nature.
/obj/machinery/power/smes/tutorial/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(total_capacity > total_charge() || !can_interact(user))
		return

	reward.award(user)

/obj/item/analyzer/tutorial
	name = "Tutorial Analyzer"
	desc = "Scan me in a normal pressured breathable environment on a non-space or shuttle area!"
	var/datum/tutorial_reward/reward

/obj/item/analyzer/tutorial/Initialize(mapload)
	. = ..()
	reward = new(TUTORIAL_REWARD_LOW)

/obj/item/analyzer/tutorial/attack_self(mob/user, modifiers)
	. = ..()
	var/area/scanned_area = get_area(src)
	if(istype(scanned_area, /area/space/) || istype(scanned_area, /area/virtual_domain))
		to_chat(user, span_notice("You need to 'make an area'!"))
		return
	reward.award(user)
