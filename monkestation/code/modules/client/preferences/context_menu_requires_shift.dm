/datum/preference/choiced/context_menu_requires_shift
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "context_menu_requires_shift"
	savefile_identifier = PREFERENCE_PLAYER

// Strings are also hardcoded, but again should only be changed once the inspect modifier is bindable.
/datum/preference/choiced/context_menu_requires_shift/init_possible_values()
	return list("Right Click", "Right Click + Shift", "Both")

/datum/preference/choiced/context_menu_requires_shift/create_default_value()
	return "Right Click + Shift"

/datum/preference/choiced/context_menu_requires_shift/apply_to_client(client/client, value)
	// should be switched to NOT use strings here but this works for now.
	switch(value)
		if("Right Click")
			client.context_menu_requires_shift = RIGHTCLICK_NOSHIFT
		if("Right Click + Shift")
			client.context_menu_requires_shift = RIGHTCLICK_SHIFT
		if("Both")
			client.context_menu_requires_shift = RIGHTCLICK_BOTH

	client.set_right_click_menu_mode()
