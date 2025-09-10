/datum/bark_screen
	var/datum/preference_middleware/bark/owner

/datum/bark_screen/New(datum/preference_middleware/bark/owner)
	src.owner = owner

/datum/bark_screen/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VoiceScreen")
		ui.open()

/datum/bark_screen/ui_state(mob/user)
	return GLOB.always_state

/datum/bark_screen/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/datum/voice_pack/bark
	bark = GLOB.voice_pack_list[params["selected"]]
	if (!bark)
		stack_trace("Failed to locate desired bark sound (path: [params["selected"]]) in the global list of bark sounds!")
		return

	if (bark.hidden)
		return

	switch(action)
		if("select")
			owner.preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/voice_pack], bark.id)
			SStgui.update_uis(owner.preferences)
			return TRUE

		if("play")
			usr.playsound_local(get_turf(usr), bark.sounds[1], 300 * bark.volume, FALSE, 1, 7, pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_MOB_SOUNDS)

/datum/bark_screen/ui_data(mob/user)
	var/list/data = list()

	data["selected"] = owner.preferences.read_preference(/datum/preference/choiced/voice_pack)
	return data

/datum/bark_screen/ui_static_data()
	var/list/data = list()

	data["voice_pack_groups"] = list()
	for (var/group in GLOB.voice_pack_groups_visible)
		var/list/bark_names = list()
		for (var/datum/voice_pack/bark in GLOB.voice_pack_groups_visible[group])
			bark_names += list(list(bark.name, bark.id))
		data["voice_pack_groups"][group] = bark_names

	return data
