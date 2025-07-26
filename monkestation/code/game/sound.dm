///sound volume handling here

/datum/verbs/menu/Preferences/verb/open_volume_mixer()
	set category = "OOC"
	set name = "Volume Mixer"
	set desc = "Open Volume Mixer"

	var/datum/preferences/prefs = usr?.client?.prefs
	if(QDELETED(prefs))
		return
	if(!prefs.pref_mixer)
		prefs.pref_mixer = new
	prefs.pref_mixer.open_ui(usr)

/datum/ui_module/volume_mixer/proc/open_ui(mob/user)
	var/needs_save = FALSE
	var/datum/preferences/prefs = user?.client?.prefs
	if(QDELETED(prefs))
		return
	for(var/channel in GLOB.used_sound_channels)
		if(isnull(prefs.channel_volume["[channel]"]))
			prefs.channel_volume["[channel]"] = 50
			needs_save = TRUE
	if(needs_save)
		prefs.save_preferences()
	ui_interact(user)

/datum/ui_module/volume_mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VolumeMixer", "Volume Mixer")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/volume_mixer/ui_data(mob/user)
	var/list/channels = list()
	var/list/channel_volume = user.client.prefs.channel_volume
	for(var/channel in GLOB.used_sound_channels)
		channels += list(list(
			"num" = channel,
			"name" = get_channel_name(channel),
			"volume" = channel_volume["[channel]"]
		))
	return list("channels" = channels)


/datum/ui_module/volume_mixer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	var/mob/user = ui.user
	. = TRUE
	switch(action)
		if("volume")
			var/channel = text2num(params["channel"])
			var/volume = text2num(params["volume"])
			if(isnull(channel))
				return FALSE
			var/datum/preferences/prefs = user.client?.prefs
			if(QDELETED(prefs))
				return FALSE
			prefs.channel_volume["[channel]"] = volume
			prefs.save_preferences()
			var/static/list/instrument_channels = list(
				CHANNEL_INSTRUMENTS,
				CHANNEL_INSTRUMENTS_ROBOT,
			)
			if(!(channel in GLOB.proxy_sound_channels)) //if its a proxy we are just wasting time
				set_channel_volume(channel, volume, user)

			else if((channel in instrument_channels))
				var/datum/song/holder_song = new
				for(var/used_channel in holder_song.channels_playing)
					set_channel_volume(used_channel, volume, user)
		else
			return FALSE

/datum/ui_module/volume_mixer/ui_state()
	return GLOB.always_state

/datum/ui_module/volume_mixer/proc/set_channel_volume(channel, vol, mob/user)
	user.update_media_volume(channel)

	var/sound/S = sound(null, channel = channel, volume = vol)
	S.status = SOUND_UPDATE
	SEND_SOUND(usr, S)

/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_MASTER_VOLUME)
			return "Master Volume"
		if(CHANNEL_LOBBYMUSIC)
			return "Lobby Music"
		if(CHANNEL_ADMIN)
			return "Admin MIDIs"
		if(CHANNEL_VOX)
			return "Announcements / AI Noise"
		if(CHANNEL_JUKEBOX)
			return "Dance Machines"
		if(CHANNEL_HEARTBEAT)
			return "Heartbeat"
		if(CHANNEL_BUZZ)
			return "White Noise"
		if(CHANNEL_CHARGED_SPELL)
			return "Charged Spells"
		if(CHANNEL_TRAITOR)
			return "Traitor Sounds"
		if(CHANNEL_AMBIENCE)
			return "Ambience"
		if(CHANNEL_SOUND_EFFECTS)
			return "Sound Effects"
		if(CHANNEL_SOUND_FOOTSTEPS)
			return "Footsteps"
		if(CHANNEL_WEATHER)
			return "Weather"
		if(CHANNEL_MACHINERY)
			return "Machinery"
		if(CHANNEL_INSTRUMENTS)
			return "Player Instruments"
		if(CHANNEL_INSTRUMENTS_ROBOT)
			return "Robot Instruments" //you caused this DONGLE
		if(CHANNEL_MOB_SOUNDS)
			return "Mob Sounds"
		if(CHANNEL_PRUDE)
			return "Prude Sounds"
		if(CHANNEL_SQUEAK)
			return "Squeaks / Plushies"
		if(CHANNEL_MOB_EMOTES)
			return "Mob Emotes"
		if(CHANNEL_SILICON_EMOTES)
			return "Silicon Emotes"
