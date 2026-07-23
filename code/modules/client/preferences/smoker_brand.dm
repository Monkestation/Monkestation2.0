/datum/preference/choiced/smoker_brand
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "smoker_brand"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	should_update_preview = FALSE

/datum/preference/choiced/smoker_brand/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.smoker_cigarette_brands)

/datum/preference/choiced/smoker_brand/create_default_value()
	return "Random"

/datum/preference/choiced/smoker_brand/is_accessible(datum/preferences/preferences)
	return ..() && (/datum/quirk/item_quirk/junkie/smoker::name in preferences.all_quirks)

/datum/preference/choiced/smoker_brand/apply_to_human(mob/living/carbon/human/target, value)
	return
