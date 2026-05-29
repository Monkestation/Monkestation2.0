/datum/preference/toggle/obsession_target
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "obsession_target"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/toggle/obsession_target/apply_to_human(mob/living/carbon/human/target, value)
	target.obsession_target = value
