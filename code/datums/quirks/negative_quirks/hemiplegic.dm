/datum/quirk/hemiplegic
	name = "Hemiplegic"
	desc = "Half of your body doesn't work. Nothing will ever fix this."
	icon = FA_ICON_CIRCLE_HALF_STROKE
	quirk_flags = QUIRK_CHANGES_APPEARANCE // monkestation addition
	value = -10 // slightly more bearable than paraplegic but not by much
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function on half of their body."
	hardcore_value = 10
	mail_goodies = list(
		/obj/item/stack/sheet/mineral/uranium/half, //half a stack of a material that has a half life
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/half_full,
	)

/datum/quirk/hemiplegic/add(client/client_source)
	// MONKESTATION EDIT START
	var/side = client_source?.prefs?.read_preference(/datum/preference/choiced/hemiplegic_side)
	var/trauma_type
	if(side == "Left")
		trauma_type = /datum/brain_trauma/severe/paralysis/hemiplegic/left
	if(side == "Right")
		trauma_type = /datum/brain_trauma/severe/paralysis/hemiplegic/right
	if(isnull(trauma_type))
		trauma_type = pick(/datum/brain_trauma/severe/paralysis/hemiplegic/left, /datum/brain_trauma/severe/paralysis/hemiplegic/right)

	var/mob/living/carbon/human/human_holder = quirk_holder
	// 	var/trauma_type = pick(/datum/brain_trauma/severe/paralysis/hemiplegic/left, /datum/brain_trauma/severe/paralysis/hemiplegic/right) - original
	human_holder.gain_trauma(trauma_type, TRAUMA_RESILIENCE_ABSOLUTE)

	if(client_source?.prefs?.read_preference(/datum/preference/toggle/limb_missing/hemiplegic))
		switch(trauma_type)
			if(/datum/brain_trauma/severe/paralysis/hemiplegic/left)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_L_ARM)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_L_LEG)
			if(/datum/brain_trauma/severe/paralysis/hemiplegic/right)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_R_ARM)
				human_holder.remove_bodypart_painlessly(BODY_ZONE_R_LEG)
	// MONKESTATION EDIT END

/datum/quirk/hemiplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/hemiplegic, TRAUMA_RESILIENCE_ABSOLUTE)

