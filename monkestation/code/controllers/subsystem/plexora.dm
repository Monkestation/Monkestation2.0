/**
 * # Plexora Subsystem
 *
 * This subsystem is for the Plexora Discord bot bridge.
 *
 * The repo for this can be found at https://github.com/monkestation/plexora
 *
 * The distinction between Plexora (the bot) and Plexora (the subsystem)
 * will be plexora (the bot) and SSplexora (the subsystem)
 *
 * NOTES:
 * * SSplexora makes heavy use of topics, and rust_g HTTP requests
 * * Lets hope to god plexora is configured properly and DOESNT CRASh,
 *   -because i seriously do not want to put error catchers in
 *   -EVERY FUNCTION THAT MAKES AN HTTP REQUEST
 */

#define AUTH_HEADER ("Basic " + CONFIG_GET(string/comms_key))

#define HTTP_DEFAULT_HEADERS(...) \
	var/list/headers = list(); \
	headers["Content-Type"] = "application/json"; \
	headers["Authorization"] = AUTH_HEADER;

SUBSYSTEM_DEF(plexora)
	name = "Plexora"
	wait = 30 SECONDS
	init_order = INIT_ORDER_PLEXORA
	priority = FIRE_PRIORITY_PLEXORA
	runlevels = ALL

	var/version_increment_counter = 1
	var/configuration_path = "config/plexora.json"
	var/plexora_is_alive = FALSE
	var/http_root = ""
	var/http_port = 0
	var/enabled = TRUE

/datum/controller/subsystem/plexora/Initialize()
	. = ..()

	if (!rustg_file_exists(configuration_path))
		stack_trace("SSplexora has no configuration file! (missing: [configuration_path])")
		enabled = FALSE
		return SS_INIT_FAILURE

	// Get config
	var/list/config = json_decode(rustg_file_read(configuration_path))

	if (!config["enabled"])
		enabled = FALSE
		return SS_INIT_NO_NEED

	var/comms_key = CONFIG_GET(string/comms_key)
	if (!comms_key)
		stack_trace("SSplexora is enabled BUT there is no configured comms key! Please make sure to set one and update Plexora's server config.")
		enabled = FALSE
		return SS_INIT_FAILURE

	http_root = config["ip"]
	http_port = config["port"]

	// Do a ping test to check if Plexora is actually running
	if (!isPlexoraAlive())
		stack_trace("SSplexora is enabled BUT plexora is not alive or running! SS has not been aborted, subsequent fires will take place.")

	return SS_INIT_SUCCESS


/datum/controller/subsystem/plexora/proc/isPlexoraAlive()
	if (!enabled) return;
	HTTP_DEFAULT_HEADERS()

	var/datum/http_request/request = new()
	request.prepare(
		RUSTG_HTTP_METHOD_GET,
		"http://[http_root]:[http_port]/alive",
		null,
		headers,
		"tmp/response.json",
	)
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if (response.errored)
		stack_trace("Failed to check if Plexora is alive! She probably isn't. Check config on both sides")
		plexora_is_alive = FALSE
		return FALSE
	else
		plexora_is_alive = TRUE
		return TRUE

/datum/controller/subsystem/plexora/fire()
	if (!enabled) return;
	isPlexoraAlive()
	// Send current status to Plexora
	var/datum/world_topic/status/status_handler = new()
	var/list/status = status_handler.Run()

	HTTP_DEFAULT_HEADERS()

	var/datum/http_request/request = new()
	request.prepare(
		RUSTG_HTTP_METHOD_POST,
		"http://[http_root]:[http_port]/status",
		json_encode(status),
		headers,
		"tmp/response.json"
	)
	request.begin_async()

	// UNTIL(request.is_complete())
	// var/datum/http_response/response = new()


// Maybe we should consider that, if theres no admin_ckey when creating a new ticket,
// This isnt a bwoink. Other wise if it does exist, it is a bwoink.
/datum/controller/subsystem/plexora/proc/aticket_new(datum/admin_help/ticket, msg_raw, is_bwoink, urgent, admin_ckey = null)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["round_timer"] = ROUND_TIME()
	body["world_time"] = world.time
	body["name"] = ticket.name
	body["ckey"] = ticket.initiator_ckey
	body["key_name"] = ticket.initiator_key_name
	body["is_bwoink"] = is_bwoink
	body["urgent"] = urgent
	body["msg_raw"] = msg_raw
	body["opened_at"] = rustg_unix_timestamp()
	body["replay_pass"] = CONFIG_GET(string/replay_password)
	body["icon_b64"] = icon2base64(getFlatIcon(ticket.initiator))

	if (admin_ckey)	body["admin_ckey"] = admin_ckey

	http_basicasync("atickets/new", body)

/datum/controller/subsystem/plexora/proc/aticket_closed(datum/admin_help/ticket, closed_by, close_type = AHELP_CLOSETYPE_CLOSE, close_reason = AHELP_CLOSEREASON_NONE)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["closed_by"] = closed_by
	// Make sure the defines in __DEFINES/admin.dm match up with Plexora's code
	body["close_reason"] = close_reason
	body["close_type"] = close_type

	body["time_closed"] = rustg_unix_timestamp()

	http_basicasync("atickets/close", body)

/datum/controller/subsystem/plexora/proc/aticket_reopened(datum/admin_help/ticket, reopened_by)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["time_reopened"] = rustg_unix_timestamp()
	body["reopened_by"] = reopened_by // ckey

	http_basicasync("atickets/reopen", body)

/datum/controller/subsystem/plexora/proc/aticket_pm(datum/admin_help/ticket, message, admin_ckey = null)
	if (!enabled) return;
	var/list/body = list();
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["message"] = message

	// We are just.. going to assume that if there is no admin_ckey param,
	// that the person sending the message is not an admin.
	// no admin_ckey = user is the initiator

	if (admin_ckey)	body["admin_ckey"] = admin_ckey

	http_basicasync("atickets/pm", body)

/datum/controller/subsystem/plexora/proc/aticket_connection(datum/admin_help/ticket, is_disconnect = TRUE)
	if (!enabled) return;
	var/list/body = list()
	body["id"] = ticket.id
	body["roundid"] = GLOB.round_id
	body["is_disconnect"] = is_disconnect
	body["time_of_connection"] = rustg_unix_timestamp()

	http_basicasync("atickets/connection_notice", body)

/datum/controller/subsystem/plexora/proc/http_basicasync(path, list/body)
	if (!enabled) return;
	HTTP_DEFAULT_HEADERS()

	var/datum/http_request/request = new()
	request.prepare(
		RUSTG_HTTP_METHOD_POST,
		"http://[http_root]:[http_port]/[path]",
		json_encode(body),
		headers,
		"tmp/response.json"
	)
	request.begin_async()


// /datum/controller/subsystem/plexora/proc/topic_fowarder(list/input)
//   if (!input["plexora"])
// 		return "failed=goober"

// /datum/world_topic/plexora


/datum/world_topic/plx_getsmites
	keyword = "PLX_getsmites"
	require_comms_key = TRUE

/datum/world_topic/plx_getsmites/Run(list/input)
	. = GLOB.smites

/datum/world_topic/plx_smite
	keyword = "PLX_smite"
	require_comms_key = TRUE

/datum/world_topic/plx_smite/Run(list/input)
	var/target_ckey = input["target"]
	var/selected_smite = input["smite"]
	var/smited_by = input["smited_by_ckey"]

	if (!GLOB.smites[selected_smite])
		return "error=invalidsmite"

	// DIVINE SMITING!
	var/client/client = disambiguate_client(target_ckey)

	if (!client)
		return "error=clientnotexist"

	var/smite_path = GLOB.smites[selected_smite]
	var/datum/smite/picking_smite = new smite_path
	var/configuration_success = picking_smite.configure(client)
	if (configuration_success == FALSE)
		return

	// Mock admin
	var/datum/client_interface/mockadmin = new(
		key = smited_by,
	)

	src = mockadmin
	picking_smite.effect(client, client.mob)

/datum/world_topic/plx_ticketaction
	keyword = "PLX_ticketaction"
	require_comms_key = TRUE

/datum/world_topic/plx_ticketaction/Run(list/input)
	var/ticketid = text2num(input["id"])
	var/action_by_ckey = input["action_by"]
	var/action = input["action"]


	var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(ticketid)
	if (!ticket) return "error=couldntfetchticket"

	if (action != "reopen" && ticket.state != AHELP_ACTIVE)
		return

	switch(action)
		if("reopen")
			if (ticket.state == AHELP_ACTIVE) return
			SSplexora.aticket_reopened(ticket, action_by_ckey)
			ticket.Reopen(action_by_ckey)
		if("reject")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_REJECT)
			ticket.Reject(action_by_ckey)
		if("icissue")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE, AHELP_CLOSEREASON_IC)
			ticket.ICIssue(action_by_ckey)
		if("close")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE)
			ticket.Close(action_by_ckey)
		if("resolve")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_RESOLVE)
			ticket.Resolve(action_by_ckey)
		if("mhelp")
			SSplexora.aticket_closed(ticket, action_by_ckey, AHELP_CLOSETYPE_CLOSE, AHELP_CLOSEREASON_MENTOR)
			ticket.MHelpThis(action_by_ckey)

/datum/world_topic/plx_sendaticketpm
	keyword = "PLX_sendaticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendaticketpm/Run(list/input)
  // We're kind of copying /proc/TgsPm here...
	var/ticketid = text2num(input["id"])
	var/input_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/stealth = input["stealh"]
	var/message = input["message"]

	var/requested_ckey = ckey(input_ckey)
	var/ambiguious_target = disambiguate_client(requested_ckey)

	var/client/recipient

	if(istype(ambiguious_target, /client))
		recipient = ambiguious_target

	var/datum/admin_help/ticket
	if (ticketid)
		ticket = GLOB.ahelp_tickets.TicketByID(ticketid)
	else
		ticket = GLOB.ahelp_tickets.CKey2ActiveTicket(requested_ckey)

	if (!ticket)
		return "error=couldntfetchticket"

	var/plx_tagged = "[sender](Plexora/External)"

	var/adminname
	var/stealthkey = sender
	if(stealth)
		adminname = "Administrator"
	else
		adminname = plx_tagged
	stealthkey = GetTgsStealthKey()

	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	message = emoji_parse(message)

	if (!message)
		return "error=messagedidntpasssanitization"

	// I have no idea what this does honestly.


	// The ckey of our recipient, with a reply link, and their mob if one exists
	var/recipient_name_linked = key_name_admin(recipient)
	// The ckey of our recipient, with their mob if one exists. No link
	var/recipient_name = key_name_admin(recipient)

	message_admins("External message from [sender] to [recipient_name_linked] : [message]")
	log_admin_private("External PM: [sender] -> [recipient_name] : [message]")

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>",
		confidential = TRUE)

	recipient.receive_ahelp(
		"<a href='?priv_msg=[stealthkey]'>[adminname]</a>",
		message,
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)


	admin_ticket_log(recipient, "<font color='purple'>PM From [adminname]: [message]</font>", log_in_blackbox = FALSE)

	window_flash(recipient, ignorepref = TRUE)
	// Nullcheck because we run a winset in window flash and I do not trust byond
	if(recipient)
		//always play non-admin recipients the adminhelp sound
		SEND_SOUND(recipient, 'sound/effects/adminhelp.ogg')

		recipient.externalreplyamount = EXTERNALREPLYCOUNT


#undef AUTH_HEADER
#undef HTTP_DEFAULT_HEADERS
