/datum/preference/choiced/floran_leaves
	savefile_key = "feature_floran_leaves"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Floran Leaves"
	should_generate_icons = TRUE

/datum/preference/choiced/floran_leaves/init_possible_values()
	return possible_values_for_sprite_accessory_list_for_body_part(
		GLOB.floran_leaves_list,
		"floran_leaves",
		list("ADJ"),
	)
/datum/preference/numeric/hiss_length
	savefile_key = "hiss_length"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	priority = PREFERENCE_PRIORITY_NAMES
	can_randomize = FALSE
	minimum = 2
	maximum = 6

/datum/preference/numeric/hiss_length/create_default_value()
	return 3

/datum/preference/numeric/hiss_length/is_accessible(datum/preferences/preferences)
	return ..() && ispath(preferences.read_preference(/datum/preference/choiced/species), /datum/species/floran)

/datum/preference/numeric/hiss_length/apply_to_human(mob/living/carbon/human/target, value)
	var/obj/item/organ/internal/tongue/floran/tongue = target.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!istype(tongue))
		return
	tongue.draw_length = value

/datum/preference/choiced/floran_leaves/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["floran_leaves"] = value
