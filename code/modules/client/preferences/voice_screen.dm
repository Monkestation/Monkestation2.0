/datum/voice_screen
	var/datum/preference_middleware/bark/owner

/datum/voice_screen/New(datum/preference_middleware/bark/owner)
	src.owner = owner

/datum/voice_screen/Destroy(force)
	owner = null
	return ..()

/datum/voice_screen/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VoiceScreen")
		ui.open()

/datum/voice_screen/ui_state(mob/user)
	return GLOB.always_state

/datum/voice_screen/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/datum/voice_pack/voicepack
	voicepack = GLOB.voice_pack_list[params["selected"]]
	if (!voicepack)
		stack_trace("Failed to locate desired bark sound (path: [params["selected"]]) in the global list of bark sounds!")
		return

	if (voicepack.hidden)
		return

	switch(action)
		if("select")
			owner.preferences.write_preference(GLOB.preference_entries[/datum/preference/choiced/voice_pack], voicepack.id)
			SStgui.update_uis(owner.preferences)
			return TRUE

		if("play")
			usr.playsound_local(get_turf(usr), voicepack.sounds[1], 300 * voicepack.volume, FALSE, 1, 7, pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_MOB_SOUNDS)

/datum/voice_screen/ui_data(mob/user)
	var/list/data = list()

	data["selected"] = owner.preferences.read_preference(/datum/preference/choiced/voice_pack)
	return data

/datum/voice_screen/ui_static_data()
	var/list/data = list()

	data["voice_pack_groups"] = list()
	for (var/group in GLOB.voice_pack_groups_visible)
		var/list/voicepack_names = list()
		for (var/datum/voice_pack/voicepack in GLOB.voice_pack_groups_visible[group])
			voicepack_names += list(list(voicepack.name, voicepack.id))
		data["voice_pack_groups"][group] = voicepack_names

	return data
