/obj/item/circuitboard/computer/comm_traffic
	name = "Telecommunications Traffic Control"
	build_path = /obj/machinery/computer/telecomms/traffic

/datum/design/board/traffic
	name = "Computer Design (Traffic Console)"
	desc = "Allows for the construction of Traffic Control Console."
	id = "s_traffic"
	build_path = /obj/item/circuitboard/computer/comm_traffic
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/obj/machinery/computer/telecomms/traffic
	name = "traffic control computer"
	desc = "A computer used to interface with the programming of communication servers."

	var/emagged = FALSE
	var/list/servers = list() // the servers located by the computer
	var/list/viewingcode = list()

	var/network = "NULL" // the network to probe
	var/temp = "" // temporary feedback messages

	var/storedcode = "" // code stored
	var/obj/item/card/id/auth = null
	var/list/access_log = list()
	var/process = 0



	var/mob/code_editor
	var/obj/machinery/telecomms/server/SelectedServer

	var/code_errors
	var/code_warnings

	circuit = /obj/item/circuitboard/computer/comm_traffic

	req_access = list(ACCESS_TCOMMS_ADMIN)

// Confirm that the current user can use NTSL and its related functions
/obj/machinery/computer/telecomms/traffic/proc/isAuthorized(mob/user)
	if(!istype(user))
		return FALSE

	if(is_banned_from(user.ckey, "Signal Technician"))
		to_chat(user, span_warning("You are banned from using the NTSL console"))
		return FALSE

	if(!SelectedServer)
		to_chat(user, span_warning("No selected server detected"))
		return FALSE

	if(issilicon(user))
		return TRUE

	if((emagged || auth) && in_range(user, src))
		return TRUE

	return FALSE

/obj/machinery/computer/telecomms/traffic/Initialize(mapload)
	. = ..()
	GLOB.traffic_comps += src

/obj/machinery/computer/telecomms/traffic/Destroy()
	GLOB.traffic_comps -= src
	return ..()

/obj/machinery/computer/telecomms/traffic/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return

	ui = new(user, src, "NTSLCoding")
	ui.open()
	ui.set_autoupdate(TRUE)

/datum/asset/simple/telecomms
	assets = list(
		"server.png" = icon('icons/obj/machines/telecomms.dmi', "comm_server"),
	)

/obj/machinery/computer/telecomms/traffic/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/telecomms),
	)

/obj/machinery/computer/telecomms/traffic/ui_static_data(mob/user)
	var/list/data = list()

	var/list/detected_servers = list()
	for(var/obj/machinery/telecomms/server in servers)
		detected_servers += list(list(
			"name" = server.name,
			"frequency" = server.freq_listening.len == 1 ? server.freq_listening[1] : 1459,
		))
	data["detected_servers"] = detected_servers

	data["selected_server_name"] = SelectedServer ? SelectedServer.name : FALSE
	data["selected_server_autorun"] = SelectedServer ? SelectedServer.autoruncode : FALSE

	data["network"] = network

	data["Authenticated"] = !isnull(auth) ? TRUE : FALSE

	data["code"] = storedcode
	data["errors"] = code_errors ? code_errors : FALSE
	data["warnings"] = code_warnings ? code_warnings : FALSE

	data["temp"] = temp

	return data

/obj/machinery/computer/telecomms/traffic/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	playsound(src, "terminal_type", 15, FALSE)
	switch(action)
		if("Change Network")
			network = params["network"]
			servers = list()
			for(var/obj/machinery/telecomms/server/server in range(25, src))
				if(server.network == network)
					servers += server

			if(!servers.len)
				temp = "Minor Error: Failed to find servers in the network \"[network]\""
			else
				temp = "[servers.len] probed and buffered successfully!"

			update_static_data_for_all_viewers()

		if("Select Server")
			for(var/obj/machinery/telecomms/server/server in servers)
				if(server.name == params["server"])
					SelectedServer = server
					break

			update_static_data_for_all_viewers()

		if("Toggle Autorun")
			SelectedServer.autoruncode = !(SelectedServer.autoruncode)
			update_static_data_for_all_viewers()

		if("Save Code")
			if(!isAuthorized(usr))
				return

			if(!params["code"] || !istext(params["code"]))
				return

			storedcode = params["code"]
			SelectedServer.rawcode = params["code"]
			update_static_data_for_all_viewers()

		if("Compile Code")
			if(!isAuthorized(usr))
				return

			var/mob/player = usr


			var/list/compiling_errors = SelectedServer.compile(player)

			if(!compiling_errors)
				code_errors = "!!FATAL ERROR DETECTED!! Error could not be cached, please contact your local Signal Technician for immediate assistance"

			else if(istext(compiling_errors))
				code_errors = compiling_errors

			else if(length(compiling_errors))
				code_errors = ""
				for(var/datum/scriptError/error in compiling_errors)
					code_errors = "[code_errors]\n[error.message]"

			else // Returned a blank list, means no errors.
				code_errors = FALSE

			if(SelectedServer.compile_warnings.len)
				code_warnings = ""
				for(var/datum/scriptError/error in SelectedServer.compile_warnings)
					code_warnings = "[code_warnings]\n[error.message]"

			update_static_data_for_all_viewers()

/obj/machinery/computer/telecomms/traffic/proc/create_log(entry, mob/user)
	var/id = null
	if(issilicon(user) || isAI(user))
		id = "System Administrator"
	else if(ispAI(user))
		id = "[user.name] (pAI)"
	else
		if(auth)
			id = "[auth.registered_name] ([auth.assignment])"
		else
			return
	access_log += "\[[get_timestamp()]\] [id] [entry]"

/obj/machinery/computer/telecomms/traffic/attackby(obj/O, mob/user, params)
	src.updateUsrDialog()
	if(istype(O, /obj/item/card/id) && check_access(O) && user.transferItemToLoc(O, src))
		auth = O
		create_log("has logged in.", usr)
	else
		..()

	update_static_data_for_all_viewers()

/obj/machinery/computer/telecomms/traffic/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(emagged)
		return FALSE
	playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
	emagged = TRUE
	to_chat(user, span_notice("You you disable the security protocols."))
	update_static_data_for_all_viewers()

/obj/machinery/computer/telecomms/traffic/proc/canAccess(mob/user)
	if(issilicon(user) || in_range(user, src))
		return 1
	return 0

/obj/machinery/computer/telecomms/traffic/AltClick(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY) || !iscarbon(user))
		return

	var/mob/living/carbon/C = user
	if(!auth)
		var/obj/item/card/id/I = C.get_active_held_item()
		if(istype(I))
			if(check_access(I))
				if(!C.transferItemToLoc(I, src))
					return
				auth = I
				create_log("has logged in.", user)
	else
		create_log("has logged out.", user)
		auth.forceMove(drop_location())
		C.put_in_hands(auth)
		auth = null

	update_static_data_for_all_viewers()
