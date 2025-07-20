/datum/preference/color/fur_color
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "fur"
	relevant_inherent_trait = TRAIT_FUR_COLORS

/datum/preference/color/fur_color/create_default_value()
	return COLOR_MONKEY_BROWN

/datum/preference/choiced/monkey_tail
	main_feature_name = "Monkey Tail"
	savefile_key = "feature_monkey_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/monkey
	should_generate_icons = TRUE

/datum/preference/choiced/monkey_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_monkey)

/datum/preference/choiced/monkey_tail/icon_for(value)
	var/icon/monkey_chest = icon('monkestation/icons/mob/species/monkey/bodyparts.dmi', "monkey_chest")

	var/datum/sprite_accessory/tails/monkey/tail = GLOB.tails_list_monkey[value]

	var/icon/final_icon = icon(monkey_chest)
	if(tail.icon_state != "none")
		var/icon/tail_icon = icon(tail.icon, "m_tail_monkey_[tail.icon_state]_FRONT", NORTH)
		final_icon.Blend(tail_icon, ICON_OVERLAY)

	final_icon.Crop(8, 8, 30, 30)
	final_icon.Scale(32, 32)

	return final_icon

/datum/preference/choiced/monkey_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_monkey"] = value

/datum/preference/choiced/monkey_tail/create_default_value()
	var/datum/sprite_accessory/tails/monkey/tail = /datum/sprite_accessory/tails/monkey/default
	return initial(tail.name)

