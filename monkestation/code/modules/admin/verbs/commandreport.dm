/datum/command_report_menu
	var/append_update_name = TRUE
	var/sanitize_content = TRUE
	var/custom_played_sound

/datum/command_report_menu/ui_data(mob/user)
	. = ..()
	.["append_update_name"] = append_update_name
	.["sanitize_content"] = sanitize_content

/datum/command_report_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("toggle_update_append")
			append_update_name = !append_update_name
		if("toggle_sanitization")
			sanitize_content = !sanitize_content
		if("preview_sound")
			preview_sound()
		if("preview_report")
			send_announcement(preview = TRUE)

	. = ..()

/datum/command_report_menu/proc/preview_sound()
	var/volume_pref = ui_user.client.prefs.channel_volume["[CHANNEL_VOX]"]
	switch(played_sound)
		if(DEFAULT_COMMANDREPORT_SOUND)
			playsound(ui_user, SSstation.announcer.get_rand_report_sound(), volume_pref)
		if(DEFAULT_ALERT_SOUND)
			playsound(ui_user, SSstation.announcer.get_rand_alert_sound(), volume_pref)
		if(CUSTOM_ALERT_SOUND)
			if (isnull(custom_played_sound))
				to_chat(ui_user, span_danger("There's no custom alert loaded! Cannot preview."))
				return
			playsound(ui_user, custom_played_sound, volume_pref)
		else
			if(SSstation.announcer.event_sounds[played_sound])
				playsound(ui_user, SSstation.announcer.event_sounds[played_sound], volume_pref)
			else
				to_chat(ui_user, span_danger("No announcer sound available for [played_sound]"))
