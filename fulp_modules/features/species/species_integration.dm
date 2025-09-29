/**
 * CARBON INTEGRATION
 *
 * All overrides of mob/living and mob/living/carbon
 */
/// Brute
/mob/living/proc/getBruteLoss_nonProsthetic()
	return getBruteLoss()

/mob/living/carbon/getBruteLoss_nonProsthetic()
	var/amount = 0
	for(var/obj/item/bodypart/chosen_bodypart as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(chosen_bodypart))
			continue
		amount += chosen_bodypart.brute_dam
	return amount

/// Burn
/mob/living/proc/getFireLoss_nonProsthetic()
	return getFireLoss()

/mob/living/carbon/getFireLoss_nonProsthetic()
	var/amount = 0
	for(var/obj/item/bodypart/chosen_bodypart as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(chosen_bodypart))
			continue
		amount += chosen_bodypart.burn_dam
	return amount

/**
 * Adds our species' prefs to consistent dummies for unit tests
 */
/mob/living/carbon/human/dummy/consistent/setup_human_dna()
	. = ..()
	fulp_consistent_human_dna()

/mob/living/carbon/human/consistent/setup_human_dna()
	. = ..()
	fulp_consistent_human_dna()

///Adds fulp-only features to human DNA
/mob/living/carbon/human/proc/fulp_consistent_human_dna()
	dna.features["beef_color"] = "#e73f4e"
	dna.features["beef_eyes"] = BEEF_EYES_OLIVES
	dna.features["beef_mouth"] = BEEF_MOUTH_SMILE
	dna.features["tail_protogen"] = "Synthliz"
	dna.features["snout_protogen"] = "Regular"
	dna.features["antennae_protogen"] = "Default"
