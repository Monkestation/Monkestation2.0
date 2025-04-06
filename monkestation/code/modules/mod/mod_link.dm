/obj/item/mod/control/can_call()
	return ..() && !istype(wearer, /mob/living/carbon/human/ghost)

/obj/item/clothing/neck/link_scryer/can_call()
	return ..() && !istype(loc, /mob/living/carbon/human/ghost)
