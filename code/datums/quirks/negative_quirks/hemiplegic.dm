/datum/quirk/hemiplegic
	name = "Hemiplegic"
	desc = "Half of your body doesn't work. Nothing will ever fix this."
	icon = FA_ICON_CIRCLE_HALF_STROKE
	value = QUIRK_COST_HEMIPLEGIC  // monkestation edit -10 -> QUIRK_COST_HEMIPLEGIC
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function on half of their body."
	hardcore_value = QUIRK_HARDCORE_HEMIPLEGIC  // monkestation edit 10 -> QUIRK_HARDCORE_HEMIPLEGIC
	mail_goodies = list(
		/obj/item/stack/sheet/mineral/uranium/half, //half a stack of a material that has a half life
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/half_full,
	)
	quirk_flags = QUIRK_CHANGES_APPEARANCE // monkestation addition

/datum/quirk/hemiplegic/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	// monkestation edit start
	/* original
	var/trauma_type = pick(/datum/brain_trauma/severe/paralysis/hemiplegic/left, /datum/brain_trauma/severe/paralysis/hemiplegic/right)
	human_holder.gain_trauma(trauma_type, TRAUMA_RESILIENCE_ABSOLUTE)
	*/

	var/side = client_source?.prefs?.read_preference(/datum/preference/choiced/hemiplegic_side)
	var/trauma_type
	if (side == "Left")
		trauma_type = /datum/brain_trauma/severe/paralysis/hemiplegic/left
	if (side == "Right")
		trauma_type = /datum/brain_trauma/severe/paralysis/hemiplegic/right
	if (isnull(trauma_type))
		trauma_type = pick(/datum/brain_trauma/severe/paralysis/hemiplegic/left, /datum/brain_trauma/severe/paralysis/hemiplegic/right)

	human_holder.gain_trauma(trauma_type, TRAUMA_RESILIENCE_ABSOLUTE)

	if (client_source?.prefs?.read_preference(/datum/preference/toggle/limb_missing/hemiplegic))
		switch (trauma_type)
			if (/datum/brain_trauma/severe/paralysis/hemiplegic/left)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_L_ARM)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_L_LEG)
			if (/datum/brain_trauma/severe/paralysis/hemiplegic/right)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_R_ARM)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_R_LEG)
	// monkestation edit end

/datum/quirk/hemiplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/hemiplegic, TRAUMA_RESILIENCE_ABSOLUTE)
