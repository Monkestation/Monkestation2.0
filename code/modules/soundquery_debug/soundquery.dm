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

/datum/soundquery_debug/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

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
		for(var/client/C)
			if(C.ckey == ckey)
				selected_client = C
				return TRUE
	return FALSE

/datum/soundquery_debug/proc/get_clients()
	var/list/L = list()
	for(var/client/C)
		L += list(list(
			"ckey" = C.ckey,
			"key" = C.key,
			"name" = C.mob?.real_name || C.ckey,
		))
	return L

/datum/soundquery_debug/ui_status(mob/user, datum/ui_state/state)
	if(!user.client?.holder?.check_for_rights(R_SERVER|R_DEBUG))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/soundquery_debug/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new /datum/tgui(user, src, "SoundQueryDebug")
		ui.open()
