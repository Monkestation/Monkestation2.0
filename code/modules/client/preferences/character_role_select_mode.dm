/datum/preference/choiced/character_role_select_mode
	savefile_key = "character_role_select_mode"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/character_role_select_mode/create_default_value()
	return CHARACTER_ROLE_MODE_SIMPLE

/datum/preference/choiced/character_role_select_mode/init_possible_values()
	return list(CHARACTER_ROLE_MODE_SIMPLE, CHARACTER_ROLE_MODE_FILTER, CHARACTER_ROLE_MODE_PER_CHAR)

/datum/preference/choiced/character_role_select_mode/should_show_on_page(preference_tab)
	return TRUE
