///Checks if a mob has enough sterile protection (RNG chance if less than 100%) on a specified body part.
///No provided arg will instead use total armor value of the mob.
///Returns TRUE if successfully sterile, so safe from disease.
/mob/living/proc/check_contact_sterility(body_part)
	return FALSE

/mob/living/carbon/human/check_contact_sterility(body_part)
	if(prob(getarmor(body_part, BIO)))
		return TRUE
	return FALSE

///Checks if a mob has open bleeding & no sterile protection (RNG chance if less than 100% bio protection) on a specified bodypart.
///No provided arg will instead use the total armor value of the mob.
///Returns TRUE if the mob is bleeding & unprotected, AKA able to be infected.
/mob/living/proc/check_bodypart_bleeding(body_part)
	return FALSE

/mob/living/carbon/human/check_bodypart_bleeding(body_part)
	if(HAS_TRAIT(src, TRAIT_NOBLOOD) || blood_volume <= 0)
		return FALSE

	var/obj/item/bodypart/bleeding_limb
	//If no limb is specified, let's look for any that's bleeding.
	if(isnull(body_part))
		for(var/obj/item/bodypart/all_limbs as anything in bodyparts)
			if(all_limbs.cached_bleed_rate)
				bleeding_limb = all_limbs
				break
	else
		bleeding_limb = get_bodypart(body_part)

	//no limb, what is there to infect?
	if(isnull(bleeding_limb))
		return FALSE
	//No bleeding, end here. Safe.
	if(!bleeding_limb.cached_bleed_rate)
		return FALSE
	//Bleeding? Let's check if you're at least protected-bleeding.
	if(prob(getarmor(bleeding_limb, BIO)))
		return FALSE
	return TRUE

///Checks if a mob is bleeding or is biologically protected on a specified body part.
///No provided arg will instead use total armor value of the mob.

/mob/living/proc/check_airborne_sterility()
	return FALSE

/mob/living/carbon/human/check_airborne_sterility()
	if (wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH) && prob(wear_mask.get_armor_rating(BIO)))
		return TRUE
	if (head && (head.flags_cover & HEADCOVERSMOUTH) && prob(head.get_armor_rating(BIO)))
		return TRUE
	return FALSE
