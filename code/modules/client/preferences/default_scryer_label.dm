/datum/preference/text/default_scryer_label
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "default_scryer_label"
	savefile_identifier = PREFERENCE_CHARACTER
	maximum_value_length = MAX_NAME_LEN

/datum/preference/text/default_scryer_label/is_valid(value)
	if(!value)
		return TRUE
	if(!istext(value))
		return FALSE
	if(length_char(value) > maximum_value_length)
		return FALSE
	if(!reject_bad_text(value))
		return FALSE
	return TRUE

/datum/preference/text/default_scryer_label/apply_to_human(mob/living/carbon/human/target, value)
	return
