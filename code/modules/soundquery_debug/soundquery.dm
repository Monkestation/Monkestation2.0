ADMIN_VERB(cmd_soundquery_debug, R_SERVER|R_DEBUG, FALSE, "Sound Mixer Debug", "View the current states of sounds.", ADMIN_CATEGORY_DEBUG)
	var/datum/soundquery_debug/tgui = new(user)
	tgui.ui_interact(user.mob)


/datum/soundquery_debug
	var/client/selected_client
	var/list/results = list()

/datum/soundquery_debug/New(client/user)
	selected_client = user
	START_PROCESSING(SSfastprocess, src)
	return ..()

/datum/soundquery_debug/ui_close(mob/user)
	qdel(src)

/datum/soundquery_debug/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/*
	If you're coming here because you thought "oh i wanna add more things!"
	your journey here was wasted. the vars listed in the
	proc below are the only ones	that BYOND will give you.
	in case you're curious, heres the decomp of what soundquery returns from 516.1675

	struct SoundChannelInfo& __thiscall SoundChannelInfo::operator=(SoundChannelInfo* this, struct SoundChannelInfo&& arg2) {
		*this = *arg2
		int32_t eax
		eax.w = *(arg2 + 4)
		*(this + 4) = eax.w
		*(this + 8) = *(arg2 + 8)
		int32_t eax_1
		eax_1.b = *(arg2 + 0xc)
		*(this + 0xc) = eax_1.b
		*(this + 0x10) = *(arg2 + 0x10)
		*(this + 0x14) = *(arg2 + 0x14)
		*(this + 0x18) = *(arg2 + 0x18)
		return this
	}

	struct SoundChannelInfo {
		uint32_t unknown0;  // Offset 0x00					- file (string pointer)
		uint16_t unknown4;  // Offset 0x04 (eax.w)  - channel
		// 2 bytes padding
		uint32_t unknown8;  // Offset 0x08					- repeat ()
		uint8_t  unknownC;  // Offset 0x0C (eax_1.b)- status
		// 3 bytes padding
		uint32_t unknown10; // Offset 0x10					- offset
		uint32_t unknown14; // Offset 0x14					- len
		uint32_t unknown18; // Offset 0x18					- wait
	};

	this pretty much lines up with the documentation for client.SoundQuery:
	"""
		This proc is used to ask a client about sounds that are playing. The /sound datums in the returned list have the following vars set:

		file: Sound/music file, or null if none
		channel: Channel of sound, if one was set when the sound was played
		repeat: The repeat value of the sound
		status: Status flags active for this channel; currently only SOUND_PAUSED is supported
		offset: Current time index, in seconds, of the sound at the current frequency
		len: Total duration, in seconds, of the sound at the current frequency
		wait: Total duration of sounds queued to play later on this channel (does not apply to channel 0)
	"""
*/

/datum/soundquery_debug/ui_data(mob/user)
	results = list()

	if(selected_client)
		for(var/sound/S as anything in selected_client.SoundQuery())
			results += list(list(
				"file" = S.file,
				"channel" = S.channel,
				"repeat" = S.repeat,
				"status" = S.status,
				"offset" = S.offset,
				"len" = S.len,
				"wait" = S.wait,
			))

	return list(
		"clients" = get_clients(),
		"selected" = selected_client?.ckey,
		"results" = results,
	)

/datum/soundquery_debug/ui_act(action, params)
	if (..())
		return TRUE
	if(action == "select_client")
		var/ckey = params["ckey"]
		if(ckey in GLOB.directory)
			selected_client = GLOB.directory[ckey]
			return TRUE
	return FALSE

/datum/soundquery_debug/proc/get_clients()
	. = list()
	for(var/client/client as anything in GLOB.clients)
		. += list(list(
			"ckey" = client.ckey,
			"key" = client.key,
			"name" = client.mob?.real_name || client.ckey,
		))

/datum/soundquery_debug/ui_state(mob/user)
	return ADMIN_STATE(R_SERVER|R_DEBUG)

/datum/soundquery_debug/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new /datum/tgui(user, src, "SoundQueryDebug")
		ui.open()
