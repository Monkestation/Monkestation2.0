#define REMOTE_MODE_OFF "Off"
#define REMOTE_MODE_SELF "Local"
#define REMOTE_MODE_TARGET "Targeted"
#define REMOTE_MODE_AOE "Area"
#define REMOTE_MODE_RELAY "Relay"

/datum/action/innate/internal_nanite_menu
	name = "Open Nanite Remote Menu"
	desc = "Configures your nanite remote"
	button_icon = 'monkestation/icons/obj/device.dmi'
	button_icon_state = "nanite_remote"
	var/datum/action/innate/ai/ranged/internal_nanite_remote/remote_settings

/datum/action/innate/internal_nanite_menu/New(nanite_menu)
	. = ..()
	if(istype(nanite_menu, /datum/action/innate/ai/ranged/internal_nanite_remote))
		remote_settings = nanite_menu
	else
		CRASH("nanite_remote_settings action created with non nanite remote")

/datum/action/innate/internal_nanite_menu/Activate()
	remote_settings.ui_interact(owner)

/datum/action/innate/ai/ranged/internal_nanite_remote
	name = "Nanite Remote"
	desc = "Remotely trigger nanite signals in nanite hosting crew."

	ranged_mousepointer = 'icons/effects/mouse_pointers/override_machine_target.dmi'	//Seems good enough?
	enable_text = span_notice("You access the nanite cloud, click to remotely trigger nanites. Click the button again or close the remote to disconnect from the cloud.")
	disable_text = span_notice("You disconnect from the nanite cloud.")
	owner_has_control = FALSE	//We use the remote UI to activate.

	/// Which mode the remote is on, is it on targeted mode? is it on AOE mode?
	var/mode = REMOTE_MODE_OFF
	/// Stores lists of settings.
	var/list/saved_settings = list()
	/// Believe this is for which point in list to save to.
	var/last_id = 0
	/// Which code is being targeted.
	var/code = 0
	/// Which relay is being targeted.
	var/relay_code = 0
	/// name of the program when you save it.
	var/current_program_name = "Program"

/datum/action/innate/ai/ranged/internal_nanite_remote/Destroy()
	owner_AI = null
	return ..()

/datum/action/innate/ai/ranged/internal_nanite_remote/ui_state(mob/user)
	return GLOB.always_state

/datum/action/innate/ai/ranged/internal_nanite_remote/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteRemote", "Nanite Remote Settings")
		ui.open()

/datum/action/innate/ai/ranged/internal_nanite_remote/ui_data(mob/user)
	var/list/data = list()
	data["code"] = code
	data["relay_code"] = relay_code
	data["mode"] = mode
	data["locked"] = FALSE
	data["saved_settings"] = saved_settings
	data["program_name"] = current_program_name
	data["silicon"] = TRUE
	data["AI"] = TRUE
	return data

/datum/action/innate/ai/ranged/internal_nanite_remote/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!isAI(usr))
		return
	switch(action)
		if("AItoggle")
			Trigger()
			. = TRUE
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

/datum/action/innate/ai/ranged/internal_nanite_remote/ui_close()
	unset_ranged_ability(owner_AI)

/datum/action/innate/ai/ranged/internal_nanite_remote/do_ability(mob/living/silicon/ai/user, atom/clicked_on)
	if(user.incapacitated() || user.control_disabled)
		unset_ranged_ability(user)
		return FALSE
	switch(mode)
		if(REMOTE_MODE_OFF)
			unset_ranged_ability(user, span_danger("Your nanite remote was off!"))
		if(REMOTE_MODE_TARGET)		//For now intentionally not unsetting ability in target and AOE mode in case you want to spam it.
			if(isliving(clicked_on))
				var/mob/living/L = clicked_on
				to_chat(user, span_notice("You signal the nanites inside [L]."))
				SEND_SIGNAL(L, COMSIG_NANITE_SIGNAL, code, src)
		if(REMOTE_MODE_AOE)
			to_chat(user, span_notice("You activate the nanites in a radius, signaling the nanites inside every host around the point."))
			for(var/mob/living/L in view(clicked_on, 7))
				SEND_SIGNAL(L, COMSIG_NANITE_SIGNAL, code, src)
		if(REMOTE_MODE_RELAY)
			to_chat(user, span_notice("You activate the relay, signaling all connected relay nanites."))
			for(var/X in SSnanites.nanite_relays)
				var/datum/nanite_program/relay/N = X
				N.relay_signal(code, relay_code, src)

	//user.playsound_local(user, 'sound/misc/interference.ogg', 50, FALSE, use_reverb = FALSE) Change to something?

	//unset_ranged_ability(user, span_danger("Sending nanite signal..."))
	return TRUE

#undef REMOTE_MODE_OFF
#undef REMOTE_MODE_SELF
#undef REMOTE_MODE_TARGET
#undef REMOTE_MODE_AOE
#undef REMOTE_MODE_RELAY
