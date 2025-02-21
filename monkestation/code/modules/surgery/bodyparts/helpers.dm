/mob/living/carbon/proc/remove_bodypart_painlessly(body_zone)
	var/obj/item/bodypart/limb = get_bodypart(body_zone)
	if (!QDELETED(limb))
		limb.drop_limb(painless=TRUE)
		qdel(limb)

/proc/body_zone_as_plaintext(body_zone)
	switch (body_zone)
		if (BODY_ZONE_L_ARM)
			return "left arm"
		if (BODY_ZONE_R_ARM)
			return "right arm"
		if (BODY_ZONE_L_LEG)
			return "left leg"
		if (BODY_ZONE_R_LEG)
			return "right leg"
		if (BODY_ZONE_PRECISE_L_HAND)
			return "left hand"
		if (BODY_ZONE_PRECISE_R_HAND)
			return "right hand"
		if (BODY_ZONE_PRECISE_L_FOOT)
			return "left foot"
		if (BODY_ZONE_PRECISE_R_FOOT)
			return "right foot"
	return body_zone
