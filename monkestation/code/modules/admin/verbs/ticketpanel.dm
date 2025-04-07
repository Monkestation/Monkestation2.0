/datum/admin_help_tickets/ui_state(mob/user)
	return GLOB.holder_state

/datum/admin_help_tickets/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketListPanel")
		ui.open()

/datum/admin_help_tickets/ui_data(mob/user)
	. = list()
	.["active_tickets"] = get_tickets_ui_data(active_tickets)
	.["resolved_tickets"] = get_tickets_ui_data(resolved_tickets)
	.["closed_tickets"] = get_tickets_ui_data(closed_tickets)
	.["user_key"] = user.ckey


/datum/admin_help_tickets/proc/get_tickets_ui_data(list/ticket_list)
	. = list()
	for(var/datum/admin_help/ahelp in ticket_list)
		if(!istype(ahelp)) return

		var/ticket_data = list()
		ticket_data["id"] = ahelp.id
		ticket_data["name"] = ahelp.name
		ticket_data["admin_key"] = ahelp.handling_admin_ckey
		ticket_data["initiator_key_name"] = ahelp.initiator_key_name
		ticket_data["initiator_ckey"] = ahelp.initiator_ckey
		ticket_data["has_client"] = !!ahelp.initiator
		ticket_data["has_mob"] = !!ahelp.initiator && !!ahelp.initiator.mob
		ticket_data["is_resolved"] = ahelp.state != AHELP_ACTIVE
		. += list(ticket_data)

/datum/admin_help_tickets/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/datum/admin_help/ticket = TicketByID(params["id"])
	if(!ticket)
		return FALSE

	. = TRUE
	if(ticket_ui_act(action, ticket))
		return
	switch(action)
		if("view")
			ticket.TicketPanel()
			return
		if("reply")
			usr.client.cmd_admin_pm(ticket.initiator)
			return
	return FALSE

/datum/admin_help/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_help/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketPanel")
		ui.open()

/datum/admin_help/proc/hide_key(key, is_admin)
	if(is_admin)
		return key
	var/datum/admins/holder = GLOB.admin_datums[ckey(key)]
	if(holder && holder.fakekey)
		return "Administrator"
	return key

/datum/admin_help/ui_data(mob/user)
	. = list()
	var/is_admin = !!user.client.holder
	.["is_admin"] = is_admin
	.["name"] = html_decode(name)
	.["id"] = id
	.["admin"] = hide_key(handling_admin_ckey, is_admin)
	.["is_resolved"] = state != AHELP_ACTIVE
	.["initiator_key_name"] = initiator_key_name
	.["opened_at"] = "Opened at: [gameTimestamp(wtime = opened_at)] (Approx [DisplayTimeText(world.time - opened_at)] ago)"

	var/mob/initiator_mob = initiator && initiator.mob
	var/datum/mind/initiator_mind = initiator_mob && initiator_mob.mind
	.["has_client"] = !!initiator
	.["has_mob"] = !!initiator_mob
	.["role"] = initiator_mind && initiator_mind.assigned_role
	.["antag"] = initiator_mind && initiator_mind.special_role

	var/location = ""
	if(is_admin && initiator_mob)
		var/turf/T = get_turf(initiator.mob)
		location = "([initiator.mob.loc == T ? "" : "in [initiator.mob.loc] at "][T.x], [T.y], [T.z]"
		if(isturf(T))
			if(isarea(T.loc))
				location += " in area [T.loc]"
		location += ")"
	.["location"] = location
	.["log"] = list()

	for(var/datum/ticket_log/log in _interactions)
		if(!is_admin && isnull(log.player_text))
			continue
		var/list/log_data = list()
		log_data["text"] = is_admin ? log.text : log.player_text
		log_data["time"] = log.gametime
		log_data["ckey"] = hide_key(log.user, is_admin)
		.["log"] += list(log_data)
	.["related_tickets"] = list()

	if(is_admin)
		var/list/related_tickets = GLOB.ahelp_tickets.TicketsByCKey(initiator_ckey)
		for(var/datum/admin_help/ahelp as anything in related_tickets)
			if(!istype(ahelp)) continue
			var/ticket_data = list()
			ticket_data["id"] = ahelp.id
			ticket_data["title"] = ahelp.name
			.["related_tickets"] += list(ticket_data)

/datum/admin_help/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	. = TRUE
	if(ticket_ui_act(action, src))
		return

	switch(action)
		if("send_message")
			var/message = params["message"]
			if(usr.client.holder)
				usr.client.cmd_admin_pm(initiator, message)
				return
			if(usr.client.current_ticket != src)
				to_chat(usr, span_warning("You are not able to reply to this ticket. To open a ticket, please use the adminhelp verb."))
			if(handling_admin_ckey)
				usr.client.cmd_admin_pm(handling_admin_ckey, message)
			else
				MessageNoRecipient(message)
			return
	return FALSE

/proc/ticket_ui_act(action, T)
	var/datum/admin_help/ticket = T
	if(!ticket)
		return
	if(!check_rights(NONE))
		return
	. = TRUE
	switch(action)
		if("adminmoreinfo")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.holder.adminmoreinfo(ticket.initiator.mob)
			return
		if("PP")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.VUAP_selected_mob = ticket.initiator.mob
			usr.client.selectedPlayerCkey = ticket.initiator_ckey
			usr.client.holder.vuap_open()
			return
		if("VV")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.debug_variables(ticket.initiator.mob)
			return
		if("SM")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.cmd_admin_subtle_message(ticket.initiator.mob)
			return
		if("FLW")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.admin_follow(ticket.initiator.mob)
			return
		if("CA")
			usr.client.check_antagonists()
			return
		if("Reopen")
			ticket.Reopen()
			return
		if("Resolve")
			SSplexora.aticket_closed(ticket, usr.ckey, AHELP_CLOSETYPE_RESOLVE)
			ticket.Resolve()
			return
		if("Reject")
			SSplexora.aticket_closed(ticket, usr.ckey, AHELP_CLOSETYPE_REJECT)
			ticket.Reject()
			return
		if("Close")
			SSplexora.aticket_closed(ticket, usr.ckey, AHELP_CLOSETYPE_CLOSE)
			ticket.Close()
			return
		if("IC")
			ticket.ICIssue()
			SSplexora.aticket_closed(ticket, usr.ckey, AHELP_CLOSETYPE_RESOLVE, AHELP_CLOSEREASON_IC)
			return
		if("MHelp")
			ticket.MHelpThis()
			return
		if("popup")
			if (!check_rights(R_ADMIN))
				return

			var/message = input(usr, "As well as a popup, they'll also be sent a message to reply to. What do you want that to be?", "Message") as text|null
			if (!message)
				to_chat(usr, span_notice("Popup cancelled."))
				return

			var/client/target = ticket.initiator
			if (!istype(target))
				to_chat(usr, span_notice("The mob doesn't exist anymore!"))
				return

			give_admin_popup(target, usr, message)
			return
		if("Administer")
			ticket.Administer(TRUE)
			return
		if("TP")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.holder.show_traitor_panel(ticket.initiator.mob)
			return
		if("Logs")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			show_individual_logging_panel(ticket.initiator.mob)
			return
		if("Smite")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.smite(ticket.initiator.mob)
			return
		if("Notes")
			browse_messages(target_ckey = ticket.initiator_ckey)
			return
		if("Replay")
			usr.client << link("[CONFIG_GET(string/replay_link)]?roundid=[GLOB.round_id]&password=[CONFIG_GET(string/replay_password)]#[world.time]") //opens current round at current time
			return

	return FALSE
