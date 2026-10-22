/**
 * Setup the final version of accessory_overlay given custom species options.
 */
/obj/item/clothing/under/proc/modify_accessory_overlay()
	if(!ishuman(loc))
		return accessory_overlay

	var/mob/living/carbon/human/human_wearer = loc
	var/obj/item/bodypart/chest/my_chest = human_wearer.get_bodypart(BODY_ZONE_CHEST)
	my_chest?.worn_accessory_offset?.apply_offset(accessory_overlay)

	return accessory_overlay
