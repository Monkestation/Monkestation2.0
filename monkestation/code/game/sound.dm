///sound volume handling here

GLOBAL_LIST_INIT(used_sound_channels, list(
	CHANNEL_MASTER_VOLUME,
	CHANNEL_LOBBYMUSIC,
	CHANNEL_ADMIN,
	CHANNEL_VOX,
	CHANNEL_JUKEBOX,
	CHANNEL_HEARTBEAT,
	CHANNEL_AMBIENCE,
	CHANNEL_BUZZ,
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_SOUND_FOOTSTEPS,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_INSTRUMENTS,
	CHANNEL_INSTRUMENTS_ROBOT,
	CHANNEL_MOB_SOUNDS,
	CHANNEL_PRUDE,
	CHANNEL_SQUEAK,
	CHANNEL_MOB_EMOTES,
	CHANNEL_SILICON_EMOTES,
))

GLOBAL_LIST_INIT(proxy_sound_channels, list(
	CHANNEL_SOUND_EFFECTS,
	CHANNEL_SOUND_FOOTSTEPS,
	CHANNEL_WEATHER,
	CHANNEL_MACHINERY,
	CHANNEL_INSTRUMENTS,
	CHANNEL_INSTRUMENTS_ROBOT,
	CHANNEL_MOB_SOUNDS,
	CHANNEL_PRUDE,
	CHANNEL_SQUEAK,
	CHANNEL_MOB_EMOTES,
	CHANNEL_SILICON_EMOTES,
))

GLOBAL_LIST_EMPTY(cached_mixer_channels)


/proc/guess_mixer_channel(soundin)
	var/sound_text_string
	if(istype(soundin, /sound))
		var/sound/bleh = soundin
		sound_text_string = "[bleh.file]"
	else
		sound_text_string = "[soundin]"
	if(GLOB.cached_mixer_channels[sound_text_string])
		return GLOB.cached_mixer_channels[sound_text_string]
	else if(findtext(sound_text_string, "effects/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else if(findtext(sound_text_string, "machines/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MACHINERY
	else if(findtext(sound_text_string, "creatures/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MOB_SOUNDS
	else if(findtext(sound_text_string, "/ai/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_VOX
	else if(findtext(sound_text_string, "chatter/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_MOB_SOUNDS
	else if(findtext(sound_text_string, "items/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else if(findtext(sound_text_string, "weapons/"))
		. = GLOB.cached_mixer_channels[sound_text_string] = CHANNEL_SOUND_EFFECTS
	else
		return FALSE

/client/verb/open_volume_mixer()
	set category = "OOC"
	set name = "Volume Mixer"
	set desc = "Opens the volume mixer UI"

	if(!prefs.pref_mixer)
		prefs.pref_mixer = new
	prefs.pref_mixer.open_ui(src.mob)

/datum/ui_module/volume_mixer/proc/open_ui(mob/user)
	ui_interact(user)

/datum/ui_module/volume_mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VolumeMixer", "Volume Mixer")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/volume_mixer/ui_data(mob/user)
	var/list/data = list()

	var/list/channels = list()
	for(var/channel in GLOB.used_sound_channels)
		if(!user.client.prefs.channel_volume["[channel]"])
			user.client.prefs.channel_volume["[channel]"] = 50
			user.client.prefs.save_preferences()
		channels += list(list(
			"num" = channel,
			"name" = get_channel_name(channel),
			"volume" = user.client.prefs.channel_volume["[channel]"]
		))
	data["channels"] = channels

	return data


/datum/ui_module/volume_mixer/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("volume")
			var/channel = text2num(params["channel"])
			var/volume = text2num(params["volume"])
			if(isnull(channel))
				return FALSE
			usr.client.prefs.channel_volume["[channel]"] = volume
			usr.client.prefs.save_preferences()
			var/list/instrument_channels = list(
				CHANNEL_INSTRUMENTS,
				CHANNEL_INSTRUMENTS_ROBOT,)
			if(!(channel in GLOB.proxy_sound_channels)) //if its a proxy we are just wasting time
				set_channel_volume(channel, volume, usr)

			else if((channel in instrument_channels))
				var/datum/song/holder_song = new
				for(var/used_channel in holder_song.channels_playing)
					set_channel_volume(used_channel, volume, usr)
		else
			return FALSE

/datum/ui_module/volume_mixer/ui_state()
	return GLOB.always_state

/datum/ui_module/volume_mixer/proc/set_channel_volume(channel, vol, mob/user)
	if((channel == CHANNEL_LOBBYMUSIC) || (channel == CHANNEL_MASTER_VOLUME))
		if(isnewplayer(user))
			user.client.media.update_volume((vol))

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
