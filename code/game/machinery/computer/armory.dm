/obj/machinery/computer/armory
	name = "armory authorization computer"
	desc = "Used to manage access to the station's armory."
	icon_screen = "commsyndie"
	icon_keyboard = "security_key"
	light_color = COLOR_SOFT_RED

	circuit = /obj/item/circuitboard/computer/armory

	///The linked ID for the integrated controller to be set to. Mappers should ensure that all armory shutters are connected to this.
	var/linked_ID = "armory"
	///The integrated controller that actually opens and closes the armory shutters.
	var/obj/item/assembly/control/door_controller
	///TRUE if the armory is currently open, FALSE if not.
	var/armory_open = FALSE
	///How many secoff-level authorizations are needed to open the armory.
	var/auth_need = 3
	///What IDs have currently authorized the armory.
	var/list/current_authorizations = list()
	///TRUE if the authorization has been met, FALSE if not. This enables the section of the UI to input a reason and actually open the armory.
	var/is_authorized = FALSE
	///The current selected reason (as a string) for why the armory is being opened. "NONE" if none selected.
	var/selected_reason = "NONE"
	///The current saved input for extra comments on why the armory is being opened.
	var/extra_details = ""

	///List of acceptable reasons to open the armory under space law.
	var/list/valid_reasons = list(
		"CODE RED/SEVERE EMERGENCY",
		"NON-LETHALS INEFFECTIVE",
		"SEVERE PERSONAL RISK",
		"ARMED AND DANGEROUS HOSTILES",
		"MULTIPLE HOSTILES",
		"OTHER/UNSPECIFIED"
	)

/obj/machinery/computer/armory/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	door_controller = new /obj/item/assembly/control
	door_controller.id = linked_ID

/obj/machinery/computer/armory/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/machinery/computer/armory/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArmoryAuthorizationComputer", name)
		ui.open()

/obj/machinery/computer/armory/ui_data(mob/user)
	var/list/data = list()

	data["is_authorized"] = is_authorized
	data["authorizations_remaining"] = max((auth_need - current_authorizations.len), 0)
	data["selected_reason"] = selected_reason
	data["extra_details"] = extra_details
	data["armory_open"] = armory_open

	var/list/A = list()
	for(var/obj/item/card/id/ID in current_authorizations)
		var/name = ID.registered_name
		var/job = ID.assignment

		A += list(list("name" = name, "job" = job))
	data["current_authorizations"] = A

	data["valid_reasons"] = valid_reasons

	return data

/obj/machinery/computer/armory/ui_act(action, params, datum/tgui/ui)
	. = ..()

	if(.)
		return
	if(!isliving(ui.user))
		return

	var/mob/living/user = ui.user

	var/obj/item/card/id/ID = user.get_idcard(TRUE)

	if (action == "authorize" || action == "repeal")
		if(!ID)
			to_chat(user, span_warning("You don't have an ID."))
			return FALSE

		if(!(ACCESS_BRIG in ID.access) && !(ACCESS_ARMORY in ID.access))
			to_chat(user, span_warning("The access level of your card is not high enough."))
			return FALSE

	switch(action)
		if("authorize")
			if (current_authorizations.len == auth_need)
				return FALSE
			if (ID in current_authorizations)
				return FALSE
			else
				current_authorizations += ID

			check_authorization()

		if("repeal")
			current_authorizations -= ID

			check_authorization()

		if("open_armory")
			open_armory(user)

		if("close_armory")
			close_armory()

		if("reason_select")
			selected_reason = params["reason"]

		if("edit_field")
			if (params["field"] == "note")
				extra_details = params["value"]
			else
				return FALSE

	ui_interact(user)
	return TRUE

/obj/machinery/computer/armory/proc/check_authorization()
	. = FALSE

	for(var/obj/item/card/id/ID in current_authorizations)
		if (ACCESS_ARMORY in ID.access)
			. = TRUE

	if (current_authorizations.len == auth_need)
		. = TRUE

	is_authorized = .
	return

/obj/machinery/computer/armory/proc/reset_console()
	current_authorizations.Cut()
	is_authorized = FALSE
	selected_reason = initial(selected_reason)
	extra_details = initial(extra_details)

/obj/machinery/computer/armory/proc/open_armory(mob/living/user)
	if (!is_authorized || armory_open)
		return FALSE

	if (selected_reason == initial(selected_reason))
		to_chat(user, span_warning("You must select a reason before you can open the armory."))
		return FALSE

	var/should_play_sound = TRUE

	if (SSsecurity_level.current_security_level.number_level == SEC_LEVEL_GREEN)
		SSsecurity_level.set_level(SEC_LEVEL_BLUE)
		should_play_sound = FALSE

	var/title
	var/message

	title = "Armory Authorization Announcement"
	message = "Attention! The station's security force has authorized the use of the on-board armory under the following provision of Space Law: "
	message += "\n\n[selected_reason].\n"

	if (extra_details != initial(extra_details))
		message += "\nExtra details: [extra_details]\n"

	message += "\nAuthorized by: "

	var/i
	for(i = 1, i <= current_authorizations.len, i++)
		var/obj/item/card/id/ID = current_authorizations[i]
		message += "[ID.assignment] [ID.registered_name]"

		if (i != current_authorizations.len)
			message += ", "

	message += "\nStation personnel are advised to stay cautious, follow lawful orders, and report all known threats."

	minor_announce(message, title, TRUE, TRUE, GLOB.player_list, 'sound/misc/notice1.ogg', should_play_sound, "purple")

	door_controller.activate()
	armory_open = TRUE
	reset_console()

	balloon_alert_to_viewers("The armory has been opened!")
	return TRUE

/obj/machinery/computer/armory/proc/close_armory()
	if (!is_authorized || !armory_open)
		return FALSE

	door_controller.activate()
	armory_open = FALSE
	reset_console()

	balloon_alert_to_viewers("The armory has been closed.")
	return TRUE
