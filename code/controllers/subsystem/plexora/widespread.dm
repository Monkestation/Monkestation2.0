// I really didn't know what to name this file since this contains procs that are
// thrown in a few corners of the codebase for server status. Kinda similar to the blackbox
// - Chen

/datum/controller/subsystem/plexora/proc/notify_shutdown(restart_type_override)
	var/static/server_restart_sent = FALSE

	if(server_restart_sent)
		return

	server_restart_sent = TRUE
	http_fireandforget("serverupdates", list(
		"type" = "servershutdown",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"map" = SSmapping.current_map?.map_name,
		"playercount" = length(GLOB.clients),
		"restart_type" = isnull(restart_type_override) ? restart_type : restart_type_override,
		"requestedby" = usr?.ckey,
		"requestedby_stealthed" = usr?.client?.holder?.fakekey,
	))

/datum/controller/subsystem/plexora/proc/serverstarted()
	http_fireandforget("serverupdates", list(
		"type" = "serverstart",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"map" = SSmapping.current_map?.map_name,
		"playercount" = length(GLOB.clients),
	))

/datum/controller/subsystem/plexora/proc/serverinitdone(time)
	http_fireandforget("serverupdates", list(
		"type" = "serverinitdone",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"map" = SSmapping.current_map?.map_name,
		"playercount" = length(GLOB.clients),
		"init_time" = time,
	))

/datum/controller/subsystem/plexora/proc/roundstarted()
	http_fireandforget("serverupdates", list(
		"type" = "roundstart",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"map" = SSmapping.current_map?.map_name,
		"playercount" = length(GLOB.clients),
	))

/datum/controller/subsystem/plexora/proc/roundended()
	http_fireandforget("serverupdates", list(
		"type" = "roundend",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"map" = SSmapping.current_map?.map_name,
		"nextmap" = SSmap_vote.next_map_config?.map_name,
		"playercount" = length(GLOB.clients),
		"playerstring" = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]",
	))

/datum/controller/subsystem/plexora/proc/interview(datum/interview/interview)
	http_fireandforget("interviewupdates", list(
		"id" = interview.id,
		"atomic_id" = interview.atomic_id,
		"owner_ckey" = interview.owner_ckey,
		"responses" = interview.responses,
		"read_only" = interview.read_only,
		"pos_in_queue" = interview.pos_in_queue,
		"status" = interview.status,
		"ip" = interview.owner?.address,
		"computer_id" = interview.owner?.computer_id,
	))

/datum/controller/subsystem/plexora/proc/check_byondserver_status(id)
	if (isnull(id)) return

	var/list/body = list(
		"id" = id
	)

	var/datum/http_request/request = new(RUSTG_HTTP_METHOD_GET, "[base_url]/byondserver_alive", json_encode(body), default_headers)
	request.begin_async()
	UNTIL_OR_TIMEOUT(request.is_complete(), 5 SECONDS)
	var/datum/http_response/response = request.into_response()
	if (response.errored)
		stack_trace("check_byondserver_status failed, likely an bad id passed ([id]) aka id of a server that doesnt exist")
		return FALSE
	else
		var/list/json_body = json_decode(response.body)
		return json_body["alive_likely"]


/datum/controller/subsystem/plexora/proc/relay_mentor_say(client/user, message, prefix)
	http_fireandforget("relay_mentor_say", list(
		"prefix" = prefix,
		"key" = user.key,
		"message" = message,
//		"icon_b64" = icon2base64(getFlatIcon(user.mob, SOUTH, no_anim = TRUE)),
	))

/datum/controller/subsystem/plexora/proc/relay_admin_say(client/user, message)
	http_fireandforget("relay_admin_say", list(
		"key" = user.key,
		"message" = message,
//		"icon_b64" = icon2base64(getFlatIcon(user.mob, SOUTH, no_anim = TRUE)),
	))

// note: recover_all_SS_and_recreate_master to force mc shit

/datum/controller/subsystem/plexora/proc/mc_alert(alert, level = 5)
	http_fireandforget("serverupdates", list(
		"type" = "mcalert",
		"timestamp" = rustg_unix_timestamp(),
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"map" = SSmapping.current_map?.map_name,
		"playercount" = length(GLOB.clients),
		"playerstring" = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]",
		"defconstring" = alert,
		"defconlevel" = level,
	))

/datum/controller/subsystem/plexora/proc/new_note(list/note)
	http_fireandforget("noteupdates", note)

/datum/controller/subsystem/plexora/proc/new_ban(list/ban)
	// TODO: It might be easier to just send off a ban ID to Plexora, but oh well.
	// list values are in sql_ban_system.dm
	http_fireandforget("banupdates", ban)

// Maybe we should consider that, if theres no admin_ckey when creating a new ticket,
// This isnt a bwoink. Other wise if it does exist, it is a bwoink.
/datum/controller/subsystem/plexora/proc/aticket_new(datum/admin_help/ticket, msg_raw, is_bwoink, urgent, admin_ckey = null)
	if(!enabled)
		return

	http_fireandforget("atickets/new", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"world_time" = world.time,
		"name" = ticket.name,
		"ckey" = ticket.initiator_ckey,
		"key_name" = ticket.initiator_key_name,
		"is_bwoink" = is_bwoink,
		"urgent" = urgent,
		"msg_raw" = msg_raw,
		"opened_at" = rustg_unix_timestamp(),
//		"icon_b64" = icon2base64(getFlatIcon(ticket.initiator.mob, SOUTH, no_anim = TRUE)),
		"admin_ckey" = admin_ckey,
	))

/datum/controller/subsystem/plexora/proc/aticket_closed(datum/admin_help/ticket, closed_by, close_type = AHELP_CLOSETYPE_CLOSE, close_reason = AHELP_CLOSEREASON_NONE)
	if(!enabled)
		return

	http_fireandforget("atickets/close", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"closed_by" = closed_by,
		// Make sure the defines in __DEFINES/admin.dm match up with Plexora's code
		"close_reason" = close_reason,
		"close_type" = close_type,
		"time_closed" = rustg_unix_timestamp(),
	))

/datum/controller/subsystem/plexora/proc/aticket_reopened(datum/admin_help/ticket, reopened_by)
	if(!enabled)
		return

	http_fireandforget("atickets/reopen", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"time_reopened" = rustg_unix_timestamp(),
		"reopened_by" = reopened_by, // ckey
	))

/datum/controller/subsystem/plexora/proc/aticket_pm(datum/admin_help/ticket, message, admin_ckey = null)
	if(!enabled)
		return

	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["message"] = message

	// We are just.. going to assume that if there is no admin_ckey param,
	// that the person sending the message is not an admin.
	// no admin_ckey = user is the initiator

	if (admin_ckey)	body["admin_ckey"] = admin_ckey

	http_fireandforget("atickets/pm", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"message" = message,
		"admin_ckey" = admin_ckey,
	))

/datum/controller/subsystem/plexora/proc/aticket_connection(datum/admin_help/ticket, is_disconnect = TRUE)
	if(!enabled)
		return

	http_fireandforget("atickets/connection_notice", list(
		"id" = ticket.id,
		"roundid" = GLOB.round_id,
		"is_disconnect" = is_disconnect,
		"time_of_connection" = rustg_unix_timestamp(),
	))

// Begin Mentor tickets

/datum/controller/subsystem/plexora/proc/mticket_new(datum/request/ticket)
	if (!enabled) return
	http_fireandforget("mtickets/new", list(
		"id" = ticket.id,
		"ckey" = ticket.owner_ckey,
		"key_name" = ticket.owner_name,
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"world_time" = world.time,
		"opened_at" = rustg_unix_timestamp(),
//		"icon_b64" = icon2base64(getFlatIcon(ticket.owner.mob, SOUTH, no_anim = TRUE)),
		"message" = ticket.message,
	))

/datum/controller/subsystem/plexora/proc/mticket_pm(datum/request/ticket, mob/frommob, mob/tomob, msg,)
	http_fireandforget("mtickets/pm", list(
		"id" = ticket.id,
		"from_ckey" = frommob.ckey,
		"ckey" = tomob.ckey,
		"key_name" = tomob.key,
		"roundid" = GLOB.round_id,
		"round_timer" = ROUND_TIME(),
		"world_time" = world.time,
		"timestamp" = rustg_unix_timestamp(),
//		"icon_b64" = icon2base64(getFlatIcon(frommob, SOUTH, no_anim = TRUE)),
		"message" = msg,
	))

