GLOBAL_LIST_INIT(baneable_materials, list("Iron", "Glass", "Silver", "Gold", "Plastic", "Uranium", "Diamond", "Bluespace Crystal", "Titanium", "Wood", "Plasma"))

/datum/preference/choiced/material_bane
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "material_bane_material"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/material_bane/init_possible_values()
	return GLOB.baneable_materials

/datum/preference/choiced/material_bane/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Material Allergy" in preferences.all_quirks

/datum/preference/choiced/material_bane/apply_to_human(mob/living/carbon/human/target, value)
	return
