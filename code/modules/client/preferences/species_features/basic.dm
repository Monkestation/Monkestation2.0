/proc/generate_icon_with_head_accessory(datum/sprite_accessory/sprite_accessory)
	var/static/icon/head_icon
	if (isnull(head_icon))
		head_icon = icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_head_m")
		head_icon.Blend(skintone2hex("caucasian1"), ICON_MULTIPLY)

	var/icon/final_icon = new(head_icon)
	if (!isnull(sprite_accessory))
		ASSERT(istype(sprite_accessory))

		var/icon/head_accessory_icon = icon(sprite_accessory.icon, sprite_accessory.icon_state)
		head_accessory_icon.Blend(COLOR_DARK_BROWN, ICON_MULTIPLY)
		final_icon.Blend(head_accessory_icon, ICON_OVERLAY)

	final_icon.Crop(10, 19, 22, 31)
	final_icon.Scale(32, 32)

	return final_icon

/datum/preference/color/eye_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "eye_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_head_flag = HEAD_EYECOLOR

/datum/preference/color/eye_color/apply_to_human(mob/living/carbon/human/target, value)
	var/hetero = target.eye_color_heterochromatic
	target.eye_color_left = value
	if(!hetero)
		target.eye_color_right = value

	var/obj/item/organ/internal/eyes/eyes_organ = target.get_organ_by_type(/obj/item/organ/internal/eyes)
	if (!eyes_organ || !istype(eyes_organ))
		return

	if (!initial(eyes_organ.eye_color_left))
		eyes_organ.eye_color_left = value
	eyes_organ.old_eye_color_left = value

	if(hetero) // Don't override the snowflakes please
		return

	if (!initial(eyes_organ.eye_color_right))
		eyes_organ.eye_color_right = value
	eyes_organ.old_eye_color_right = value
	eyes_organ.refresh()

/datum/preference/color/eye_color/create_default_value()
	return random_eye_color()

/datum/preference/choiced/facial_hairstyle
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "facial_style_name"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Facial hair"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_FACIAL_HAIR

/datum/preference/choiced/facial_hairstyle/init_possible_values()
	return assoc_to_keys_features(GLOB.facial_hairstyles_list)

/datum/preference/choiced/facial_hairstyle/icon_for(value)
	return generate_icon_with_head_accessory(GLOB.facial_hairstyles_list[value])

/datum/preference/choiced/facial_hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_hairstyle(value, update = FALSE)

/datum/preference/choiced/facial_hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "facial_hair_color"

	return data

/datum/preference/color/facial_hair_color
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "facial_hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_FACIAL_HAIR

/datum/preference/color/facial_hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_haircolor(value, update = FALSE)

/datum/preference/choiced/facial_hair_gradient
	priority = PREFERENCE_PRIORITY_BODYPARTS
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "facial_hair_gradient"
	main_feature_name = "Facial hair Gradient"
	relevant_head_flag = HEAD_FACIAL_HAIR
	should_generate_icons = TRUE

/datum/preference/choiced/facial_hair_gradient/init_possible_values()
	return assoc_to_keys_features(GLOB.facial_hair_gradients_list)

/datum/preference/choiced/facial_hair_gradient/icon_for(value)
	var/datum/sprite_accessory/accessory = GLOB.facial_hair_gradients_list[value]

	if(accessory.icon_state == null || accessory.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon

	var/static/icon/head_icon
	if(isnull(head_icon))
		head_icon = icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_head_m")
		head_icon.Blend(skintone2hex("caucasian1"), ICON_MULTIPLY)

	var/datum/sprite_accessory/hair_accessory = GLOB.facial_hairstyles_list["Beard (Very Long)"]

	var/static/icon/hair_icon
	if(isnull(hair_icon))
		hair_icon = icon(hair_accessory.icon, hair_accessory.icon_state, dir = SOUTH)
		hair_icon.Blend("#080501", ICON_MULTIPLY)

	var/icon/final_icon = new(head_icon)
	var/icon/base_hair_icon = new(hair_icon)
	var/icon/gradient_hair_icon = icon(hair_accessory.icon, hair_accessory.icon_state, dir = SOUTH)

	var/icon/gradient_icon = icon(accessory.icon, accessory.icon_state)
	gradient_icon.Blend(gradient_hair_icon, ICON_ADD)
	gradient_icon.Blend("#42250a", ICON_MULTIPLY)
	base_hair_icon.Blend(gradient_icon, ICON_OVERLAY)

	final_icon.Blend(base_hair_icon, ICON_OVERLAY)

	final_icon.Crop(10, 19, 22, 31)
	final_icon.Scale(32, 32)



	return final_icon

/datum/preference/choiced/facial_hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_hair_gradient_style(new_style = value, update = FALSE)

/datum/preference/choiced/facial_hair_gradient/create_default_value()
	return "None"

/datum/preference/color/facial_hair_gradient
	priority = PREFERENCE_PRIORITY_BODYPARTS
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "facial_hair_gradient_color"
	relevant_head_flag = HEAD_FACIAL_HAIR

/datum/preference/color/facial_hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_facial_hair_gradient_color(new_color = value, update = FALSE)

/datum/preference/color/facial_hair_gradient/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/facial_hair_gradient) != "None"

/datum/preference/color/hair_color
	savefile_key = "hair_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_head_flag = HEAD_HAIR

/datum/preference/color/hair_color/apply_to_human(mob/living/carbon/human/target, value)
	target.set_haircolor(value, update = FALSE)

/datum/preference/choiced/hairstyle
	priority = PREFERENCE_PRIORITY_BODYPARTS
	savefile_key = "hairstyle_name"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Hairstyle"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_HAIR

/datum/preference/choiced/hairstyle/init_possible_values()
	return assoc_to_keys_features(GLOB.hairstyles_list)

/datum/preference/choiced/hairstyle/icon_for(value)
	return generate_icon_with_head_accessory(GLOB.hairstyles_list[value])

/datum/preference/choiced/hairstyle/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hairstyle(value, update = FALSE)

/datum/preference/choiced/hairstyle/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "hair_color"

	return data

/datum/preference/choiced/hair_gradient
	priority = PREFERENCE_PRIORITY_BODYPARTS
	category = PREFERENCE_CATEGORY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "hair_gradient"
	main_feature_name = "Hairstyle Gradient"
	should_generate_icons = TRUE
	relevant_head_flag = HEAD_HAIR

/datum/preference/choiced/hair_gradient/init_possible_values()
	return assoc_to_keys_features(GLOB.hair_gradients_list)

/datum/preference/choiced/hair_gradient/icon_for(value)
	var/datum/sprite_accessory/accessory = GLOB.hair_gradients_list[value]

	if(accessory.icon_state == null || accessory.icon_state == "none")
		var/icon/invalid_icon = icon('icons/mob/landmarks.dmi', "x")
		return invalid_icon

	var/static/list/body_parts = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)

	var/static/icon/body_icon
	if(isnull(body_icon))
		body_icon = icon('icons/effects/effects.dmi', "nothing")
		for (var/body_part in body_parts)
			var/gender = body_part == BODY_ZONE_CHEST || body_part == BODY_ZONE_HEAD ? "_m" : ""
			body_icon.Blend(icon('icons/mob/species/human/bodyparts_greyscale.dmi', "human_[body_part][gender]", dir = NORTH), ICON_OVERLAY)
		body_icon.Blend(skintone2hex("caucasian1"), ICON_MULTIPLY)
		var/icon/jumpsuit_icon = icon('icons/mob/clothing/under/civilian.dmi', "barman", dir = NORTH)
		jumpsuit_icon.Blend("#b3b3b3", ICON_MULTIPLY)
		body_icon.Blend(jumpsuit_icon, ICON_OVERLAY)

	var/datum/sprite_accessory/hair_accessory = GLOB.hairstyles_list["Very Long Hair 2"]

	var/static/icon/hair_icon
	if(isnull(hair_icon))
		hair_icon = icon(hair_accessory.icon, hair_accessory.icon_state, dir = NORTH)
		hair_icon.Blend("#080501", ICON_MULTIPLY)



	var/icon/final_icon = new(body_icon)
	var/icon/base_hair_icon = new(hair_icon)
	var/icon/gradient_hair_icon = icon(hair_accessory.icon, hair_accessory.icon_state, dir = NORTH)

	var/icon/gradient_icon = icon(accessory.icon, accessory.icon_state)
	gradient_icon.Blend(gradient_hair_icon, ICON_ADD)
	gradient_icon.Blend("#42250a", ICON_MULTIPLY)
	base_hair_icon.Blend(gradient_icon, ICON_OVERLAY)

	final_icon.Blend(base_hair_icon, ICON_OVERLAY)

	return final_icon

/datum/preference/choiced/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hair_gradient_style(new_style = value, update = FALSE)

/datum/preference/choiced/hair_gradient/create_default_value()
	return "None"

/datum/preference/color/hair_gradient
	priority = PREFERENCE_PRIORITY_BODYPARTS
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "hair_gradient_color"
	relevant_head_flag = HEAD_HAIR

/datum/preference/color/hair_gradient/apply_to_human(mob/living/carbon/human/target, value)
	target.set_hair_gradient_color(new_color = value, update = FALSE)

/datum/preference/color/hair_gradient/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE
	return preferences.read_preference(/datum/preference/choiced/hair_gradient) != "None"
