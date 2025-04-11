/// This should match the interface of /client wherever necessary.
/datum/client_interface
	/// Player preferences datum for the client
	var/datum/preferences/prefs

	/// The view of the client, similar to /client/var/view.
	var/view = "15x15"

	/// View data of the client, similar to /client/var/view_size.
	var/datum/view_data/view_size

	/// Objects on the screen of the client
	var/list/screen = list()

	/// The mob the client controls
	var/mob/mob

	/// The ckey for this mock interface
	var/ckey = "mockclient"

	/// The key for this mock interface
	var/key = "mockclient"

	/// client prefs
	var/fps
	var/hotkeys
	var/tgui_say
	var/typing_indicators
	var/datum/interaction_mode/imode
	var/context_menu_requires_shift = FALSE

	///these persist between logins/logouts during the same round.
	var/datum/persistent_client/persistent_client
	var/reconnecting = FALSE

/datum/client_interface/proc/IsByondMember()
	return FALSE

/datum/client_interface/New(key)
	..()
	if(key)
		src.key = key
		ckey = ckey(key)
		if(GLOB.persistent_clients_by_ckey[ckey])
			reconnecting = TRUE
			persistent_client = GLOB.persistent_clients_by_ckey[ckey]
		else
			persistent_client = new(ckey)
			persistent_client.byond_version = world.byond_version
			persistent_client.byond_build = world.byond_build
			GLOB.persistent_clients_by_ckey[ckey] = persistent_client

/datum/client_interface/proc/set_macros()
	return

/datum/client_interface/proc/set_right_click_menu_mode()
	return

/datum/client_interface/proc/is_afk(duration)
	return FALSE
