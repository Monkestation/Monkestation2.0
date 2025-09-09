#define REMOTE_MODE_OFF "Off"
#define REMOTE_MODE_SELF "Local"
#define REMOTE_MODE_TARGET "Targeted"
#define REMOTE_MODE_AOE "Area"
#define REMOTE_MODE_RELAY "Relay"

/datum/action/innate/internal_nanite_menu
	name = "Open Nanite Remote Menu"
	desc = "Configures your nanite remote"
	
	button_icon = 'icons/mob/actions/actions_AI.dmi'	//PLACEHOLDER
	button_icon_state = "modules_menu"
	var/datum/nanite_remote_settings/remote_settings

/datum/action/innate/internal_nanite_menu/New(nanite_menu)
	. = ..()
	if(istype(nanite_menu, /datum/nanite_remote_settings))
		remote_settings = nanite_menu
	else
		CRASH("nanite_remote_settings action created with non nanite settings")

/datum/action/innate/internal_nanite_menu/Activate()
	remote_settings.ui_interact(owner)

/datum/nanite_remote_settings
	var/name = "Nanite Remote Settings"
	var/mode = REMOTE_MODE_OFF
	var/list/saved_settings = list()
	var/last_id = 0
	var/code = 0
	var/relay_code = 0
	var/current_program_name = "Program"

/datum/nanite_remote_settings/ui_state(mob/user)
	return GLOB.always_state

/datum/nanite_remote_settings/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteRemote", name)
		ui.open()

/datum/nanite_remote_settings/ui_data(mob/user)
	var/list/data = list()
	data["can_lock"] = FALSE
	data["code"] = code
	data["relay_code"] = relay_code
	data["mode"] = mode
	data["locked"] = FALSE
	data["saved_settings"] = saved_settings
	data["program_name"] = current_program_name
	return data

// /datum/action/innate/internal_nanite_menu/ui_act(action, params)
/datum/nanite_remote_settings/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!isAI(usr))
		return
	switch(action)
		if("set_code")
			var/new_code = text2num(params["code"])
			if(!isnull(new_code))
				new_code = clamp(round(new_code, 1),0,9999)
				code = new_code
			. = TRUE
		if("set_relay_code")
			var/new_code = text2num(params["code"])
			if(!isnull(new_code))
				new_code = clamp(round(new_code, 1),0,9999)
				relay_code = new_code
			. = TRUE
		if("update_name")
			current_program_name = params["name"]
			. = TRUE
		if("save")
			var/new_save = list()
			new_save["id"] = last_id + 1
			last_id++
			new_save["name"] = current_program_name
			new_save["code"] = code
			new_save["mode"] = mode
			new_save["relay_code"] = relay_code

			saved_settings += list(new_save)
			. = TRUE
		if("load")
			var/code_id = params["save_id"]
			var/list/setting
			for(var/list/X in saved_settings)
				if(X["id"] == text2num(code_id))
					setting = X
					break
			if(setting)
				code = setting["code"]
				mode = setting["mode"]
				relay_code = setting["relay_code"]
			. = TRUE
		if("remove_save")
			var/code_id = params["save_id"]
			for(var/list/setting in saved_settings)
				if(setting["id"] == text2num(code_id))
					saved_settings -= list(setting)
					break
			. = TRUE
		if("select_mode")
			mode = params["mode"]
			. = TRUE

#undef REMOTE_MODE_OFF
#undef REMOTE_MODE_SELF
#undef REMOTE_MODE_TARGET
#undef REMOTE_MODE_AOE
#undef REMOTE_MODE_RELAY
