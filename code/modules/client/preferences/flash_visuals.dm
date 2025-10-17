/datum/preference/choiced/flash_visuals
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "flash_visuals"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/flash_visuals/init_possible_values()
	return list("Light", "Dark", "Blur")

/datum/preference/choiced/flash_visuals/create_default_value()
	return "Blur"
