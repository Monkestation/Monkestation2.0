/datum/bark_screen
	var/datum/preference_middleware/bark/owner

/datum/bark_screen/New(datum/preference_middleware/bark/user)
	// owner = CLIENT_FROM_VAR(user)
	owner = user
	// owner.bark_screen = src
	// custom_loadout = new()

/datum/bark_screen/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BarkScreen")
		ui.open()

/datum/bark_screen/ui_state(mob/user)
	return GLOB.always_state

/datum/bark_screen/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/bark_voice/bark
	bark = GLOB.bark_list[params["selected"]]
	if(!bark)
		stack_trace("Failed to locate desired loadout item (path: [params["selected"]]) in the global list of loadout datums!")
		return

	switch(action)
		if("select")
			owner.preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/bark_voice], bark.id)
			SStgui.update_uis(owner.preferences)
			return TRUE

		// Rotates the dummy left or right depending on params["dir"]
		if("play")
			usr.playsound_local(get_turf(usr), bark.talk, 300, FALSE, 1, 7, falloff_exponent = BARK_SOUND_FALLOFF_EXPONENT(7), pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_MOB_SOUNDS)

/datum/bark_screen/ui_data(mob/user)
	var/list/data = list()

	data["selected"] = owner.preferences.read_preference(/datum/preference/choiced/bark_voice)
	return data

/datum/bark_screen/ui_static_data()
	var/list/data = list()

	data["bark_groups"] = list()
	for (var/group in GLOB.bark_groups_visible)
		var/list/bark_names = list()
		for (var/datum/bark_voice/bark in GLOB.bark_groups_visible[group])
			bark_names += list(list(bark.name, bark.id))
		data["bark_groups"][group] = bark_names

	return data
