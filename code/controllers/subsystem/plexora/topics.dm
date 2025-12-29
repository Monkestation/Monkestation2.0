

#define TOPIC_EMITTER \
	if (input["emitter_token"]) { \
		INVOKE_ASYNC(SSplexora, TYPE_PROC_REF(/datum/controller/subsystem/plexora, topic_listener_response), input["emitter_token"], returning); \
		return; \
	};

/datum/world_topic/plx_announce
	keyword = "PLX_announce"
	require_comms_key = TRUE

/datum/world_topic/plx_announce/Run(list/input)
	var/message = input["message"]
	var/from = input["from"]

	send_formatted_announcement(message, "From [from]")

/datum/world_topic/plx_restartcontroller
	keyword = "PLX_restartcontroller"
	require_comms_key = TRUE

/datum/world_topic/plx_restartcontroller/Run(list/input)
	var/controller = input["controller"]
	var/username = input["username"]
	var/userid = input["userid"]

	if (!controller)
		return

	switch(LOWER_TEXT(controller))
		if("master")
			Recreate_MC()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "PLX: Restart Master Controller")
		if("failsafe")
			new /datum/controller/failsafe()
			SSblackbox.record_feedback("tally", "admin_verb", 1, "PLX: Restart Failsafe Controller")
	message_admins("PLEXORA: @[username] ([userid]) has restarted the [controller] controller from the Discord.")


/datum/world_topic/plx_globalnarrate
	keyword = "PLX_globalnarrate"
	require_comms_key = TRUE

/datum/world_topic/plx_globalnarrate/Run(list/input)
	var/message = input["contents"]

	for(var/mob/player as anything in GLOB.player_list)
		to_chat(player, message)

/datum/world_topic/plx_who
	keyword = "PLX_who"
	require_comms_key = TRUE

/datum/world_topic/plx_who/Run(list/input)
	. = list()
	for(var/client/client as anything in GLOB.clients)
		if(QDELETED(client))
			continue
		. += list(list("key" = client.holder?.fakekey || client.key, "avgping" = "[round(client.avgping, 1)]ms"))

/datum/world_topic/plx_adminwho
	keyword = "PLX_adminwho"
	require_comms_key = TRUE

/datum/world_topic/plx_adminwho/Run(list/input)
	. = list()
	for (var/client/admin as anything in GLOB.admins)
		if(QDELETED(admin))
			continue
		var/admin_info = list(
			"name" = admin,
			"ckey" = admin.ckey,
			"rank" = admin.holder.rank_names(),
			"afk" = admin.is_afk(),
			"stealth" = !!admin.holder.fakekey,
			"stealthkey" = admin.holder.fakekey,
		)

		if(isobserver(admin.mob))
			admin_info["state"] = "observing"
		else if(isnewplayer(admin.mob))
			admin_info["state"] = "lobby"
		else
			admin_info["state"] = "playing"

		. += LIST_VALUE_WRAP_LISTS(admin_info)

/datum/world_topic/plx_mentorwho
	keyword = "PLX_mentorwho"
	require_comms_key = TRUE

/datum/world_topic/plx_mentorwho/Run(list/input)
	. = list()
	for (var/client/mentor as anything in GLOB.mentors)
		if(QDELETED(mentor))
			continue
		var/list/mentor_info = list(
			"name" = mentor,
			"ckey" = mentor.ckey,
			"rank" = mentor.holder?.rank_names(),
			"afk" = mentor.is_afk(),
			"stealth" = !!mentor.holder?.fakekey,
			"stealthkey" = mentor.holder?.fakekey,
		)

		if(isobserver(mentor.mob))
			mentor_info["state"] = "observing"
		else if(isnewplayer(mentor.mob))
			mentor_info["state"] = "lobby"
		else
			mentor_info["state"] = "playing"

		. += LIST_VALUE_WRAP_LISTS(mentor_info)

/datum/world_topic/plx_getloadoutrewards
	keyword = "PLX_getloadoutrewards"
	require_comms_key = TRUE

/datum/world_topic/plx_getloadoutrewards/Run(list/input)
	var/list/typelist = list()
	for(var/datum/store_item/store_item as anything in subtypesof(/datum/store_item) - typesof(/datum/store_item/roundstart))
		if(!store_item::name || !store_item::item_path)
			continue
		typelist += store_item

	return typelist

/datum/world_topic/plx_getunusualitems
	keyword = "PLX_getunusualitems"
	require_comms_key = TRUE

/datum/world_topic/plx_getunusualitems/Run(list/input)
	return GLOB.possible_lootbox_clothing

/datum/world_topic/get_unusualeffects
	keyword = "PLX_getunusualeffects"
	require_comms_key = TRUE

/datum/world_topic/get_unusualeffects/Run(list/input)
	return subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement

/datum/world_topic/plx_getsmites
	keyword = "PLX_getsmites"
	require_comms_key = TRUE

/datum/world_topic/plx_getsmites/Run(list/input)
	. = list()
	for (var/datum/smite/smite_path as anything in subtypesof(/datum/smite))
		var/smite_name = smite_path::name
		if(!smite_name)
			continue
		try
			var/datum/smite/smite_instance = new smite_path
			if (smite_instance.configure(new /datum/client_interface("fake_player")) == "NO_CONFIG")
				.[smite_name] = smite_path
			QDEL_NULL(smite_instance)
		catch
			pass()

/datum/world_topic/plx_gettwitchevents
	keyword = "PLX_gettwitchevents"
	require_comms_key = TRUE

/datum/world_topic/plx_gettwitchevents/Run(list/input)
	. = list()
	for (var/datum/twitch_event/event_path as anything in subtypesof(/datum/twitch_event))
		.[event_path::event_name] = event_path::id_tag

/datum/world_topic/plx_getbasicplayerdetails
	keyword = "PLX_getbasicplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getbasicplayerdetails/Run(list/input)
	var/ckey = input["ckey"]

	if (!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/list/returning = list(
		"ckey" = ckey
	)

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		returning["present"] = FALSE
	else
		returning["present"] = TRUE
		returning["key"] = client.key

	var/datum/persistent_client/details = GLOB.persistent_clients_by_ckey[ckey]

	if (details)
		returning["byond_version"] = details.byond_version

	if (QDELETED(client))
		var/datum/client_interface/mock_player = new(ckey)
		mock_player.prefs = new /datum/preferences(mock_player)
		returning["playtime"] = mock_player.get_exp_living(FALSE)
	else
		returning["playtime"] = client.get_exp_living(FALSE)

	return returning

/datum/world_topic/plx_getplayerdetails
	keyword = "PLX_getplayerdetails"
	require_comms_key = TRUE

/datum/world_topic/plx_getplayerdetails/Run(list/input)
	var/ckey = input["ckey"]
	var/omit_logs = input["omit_logs"]

	if (!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/datum/persistent_client/details = GLOB.persistent_clients_by_ckey[ckey]

	if (QDELETED(details))
		return list("error" = PLEXORA_ERROR_DETAILSNOTEXIST)

	var/client/client = disambiguate_client(ckey)

	var/list/returning = list(
		"ckey" = ckey,
		"present" = !QDELETED(client),
		"admin_datum" = null,
		"logging" = details.logging,
		"played_names" = details.played_names,
		"byond_version" = details.byond_version,
		"achievements" = details.achievements.data,
	)

	var/mob/clientmob
	if (!QDELETED(client))
		returning["playtime"] = client.get_exp_living(FALSE)
		returning["key"] = client.key
		clientmob = client.mob
	else
		for (var/mob/mob as anything in GLOB.mob_list)
			if (!QDELETED(mob) && mob.ckey == ckey)
				clientmob = mob
				break

	if (!omit_logs)
		returning["logging"] = details.logging

	if (GLOB.admin_datums[ckey])
		var/datum/admins/ckeyadatum = GLOB.admin_datums[ckey]
		returning["admin_datum"] = list(
			"name" = ckeyadatum.name,
			"ranks" = ckeyadatum.get_ranks(),
			"fakekey" = ckeyadatum.fakekey,
			"deadmined" = ckeyadatum.deadmined,
			"bypass_2fa" = ckeyadatum.bypass_2fa,
			"admin_signature" = ckeyadatum.admin_signature,
		)

	if (!QDELETED(clientmob))
		returning["mob"] = list(
			"name" = clientmob.name,
			"real_name" = clientmob.real_name,
			"type" = clientmob.type,
			"gender" = clientmob.gender,
			"stat" = clientmob.stat,
		)

	if (!QDELETED(client) && isliving(clientmob))
		var/mob/living/livingmob = clientmob
		returning["health"] = livingmob.health
		returning["maxHealth"] = livingmob.maxHealth
		returning["bruteloss"] = livingmob.bruteloss
		returning["fireloss"] = livingmob.fireloss
		returning["toxloss"] = livingmob.toxloss
		returning["oxyloss"] = livingmob.oxyloss

	TOPIC_EMITTER

	return returning

/datum/world_topic/plx_mobpicture
	keyword = "PLX_mobpicture"
	require_comms_key = TRUE

/datum/world_topic/plx_mobpicture/Run(list/input)
	var/ckey = input["ckey"]

	if (!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/returning = list(
		"icon_b64" = icon2base64(getFlatIcon(client.mob, no_anim = TRUE))
	)

	TOPIC_EMITTER

	return returning

/datum/world_topic/plx_generategiveawaycodes
	keyword = "PLX_generategiveawaycodes"
	require_comms_key = TRUE

/datum/world_topic/plx_generategiveawaycodes/Run(list/input)
	var/type = input["type"]
	var/codeamount = input["limit"]

	. = list()

	if (type == "loadout" && !input["loadout"])
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "loadout", "reason" = "loadout type codes require a loadout parameter")

	for (var/i in 1 to codeamount)
		var/returning = list("type" = type)

		switch(type)
			if ("coin")
				var/amount = input["coins"]
				if (isnull(amount))
					amount = 5000
				returning["coins"] = amount
				returning["code"] = generate_coin_code(amount, TRUE)
			if ("loadout")
				var/loadout = input["loadout"]
				//we are not chosing a random one for this, you MUST specify
				if (!loadout) return
				returning["loadout"] = loadout
				returning["code"] = generate_loadout_code(loadout, TRUE)
			if ("antagtoken")
				var/tokentype = input["antagtoken"]
				if (!tokentype)
					tokentype = LOW_THREAT
				returning["antagtoken"] = tokentype
				returning["code"] = generate_antag_token_code(tokentype, TRUE)
			if ("unusual")
				var/item = input["unusual_item"]
				var/effect = input["unusual_effect"]
				if (!item)
					item = pick(GLOB.possible_lootbox_clothing)
				if (!effect)
					var/static/list/possible_effects = subtypesof(/datum/component/particle_spewer) - /datum/component/particle_spewer/movement
					effect = pick(possible_effects)
				returning["item"] = item
				returning["effect"] = effect
				returning["code"] = generate_unusual_code(item, effect, TRUE)

		. += list(returning)

/datum/world_topic/plx_givecoins
	keyword = "PLX_givecoins"
	require_comms_key = TRUE

/datum/world_topic/plx_givecoins/Run(list/input)
	var/ckey = input["ckey"]
	var/amount = input["amount"]
	var/reason = input["reason"]

	amount = text2num(amount)
	if (!amount)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "amount", "reason" = "parameter must be a number greater than 0")

	if(!ckey)
		return list("error" = PLEXORA_ERROR_MISSING_CKEY)

	var/client/userclient = disambiguate_client(ckey)

	var/datum/preferences/prefs
	if (QDELETED(userclient))
		var/datum/client_interface/mock_player = new(ckey)
		mock_player.prefs = new /datum/preferences(mock_player)

		prefs = mock_player.prefs
	else
		prefs = userclient.prefs

	prefs.adjust_metacoins(ckey, amount, reason, donator_multiplier = FALSE, respects_roundcap = FALSE, announces = FALSE)

	return list("totalcoins" = prefs.metacoins)


/datum/world_topic/plx_forceemote
	keyword = "PLX_forceemote"
	require_comms_key = TRUE

/datum/world_topic/plx_forceemote/Run(list/input)
	var/target_ckey = input["ckey"]
	var/emote = input["emote"]
	var/emote_args = input["emote_args"]

	if(!target_ckey || !emote)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/emote", "reason" = "missing required parameter")

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = PLEXORA_ERROR_CLIENTNOMOB)

	return list(
		"success" = client_mob.emote(emote, message = emote_args, intentional = FALSE)
	)

/datum/world_topic/plx_forcesay
	keyword = "PLX_forcesay"
	require_comms_key = TRUE

/datum/world_topic/plx_forcesay/Run(list/input)
	var/target_ckey = input["ckey"]
	var/message = input["message"]

	if(!target_ckey || !message)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/message", "reason" = "missing required parameter")

	var/client/client = disambiguate_client(ckey(target_ckey))

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = PLEXORA_ERROR_CLIENTNOMOB)

	client_mob.say(message, forced = TRUE)

/datum/world_topic/plx_runtwitchevent
	keyword = "plx_runtwitchevent"
	require_comms_key = TRUE

/datum/world_topic/plx_runtwitchevent/Run(list/input)
	var/event = input["event"]
	// TODO: do something with the executor input
	//var/executor = input["executor"]


	if (!CONFIG_GET(string/twitch_key))
		return list("error" = PLEXORA_ERROR_NOTWITCHKEY)

	if(!event)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "event", "reason" = "missing required parameter")

	// cant be bothered, lets just call the topic.
	var/outgoing = list("TWITCH-API", CONFIG_GET(string/twitch_key), event,)
	SStwitch.handle_topic(outgoing)

/datum/world_topic/plx_smite
	keyword = "PLX_smite"
	require_comms_key = TRUE

/datum/world_topic/plx_smite/Run(list/input)
	var/target_ckey = input["ckey"]
	var/selected_smite = input["smite"]
	var/smited_by = input["smited_by_ckey"]

	if(!target_ckey || !selected_smite || !smited_by)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/smite/smited_by_ckey", "reason" = "missing required parameter")

	if (!GLOB.smites[selected_smite])
		return list("error" = PLEXORA_ERROR_INVALIDSMITE)

	var/client/client = disambiguate_client(target_ckey)

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	// DIVINE SMITING!
	var/smite_path = GLOB.smites[selected_smite]
	var/datum/smite/picking_smite = new smite_path
	var/configuration_success = picking_smite.configure(client)
	if (configuration_success == FALSE)
		return

	// Mock admin
	var/datum/client_interface/mockadmin = new(key = smited_by)

	usr = mockadmin
	picking_smite.effect(client, client.mob)

/datum/world_topic/plx_jailmob
	keyword = "PLX_jailmob"
	require_comms_key = TRUE

/datum/world_topic/plx_jailmob/Run(list/input)
	var/ckey = input["ckey"]
	var/jailer = input["admin_ckey"]

	if(!ckey || !jailer)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/admin_ckey", "reason" = "missing required parameter")

	var/client/client = disambiguate_client(ckey)

	if (QDELETED(client))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/mob/client_mob = client.mob

	if (QDELETED(client_mob))
		return list("error" = PLEXORA_ERROR_CLIENTNOMOB)

	// Mock admin
	var/datum/client_interface/mockadmin = new(
		key = jailer,
	)

	usr = mockadmin

	client_mob.forceMove(pick(GLOB.prisonwarp))
	to_chat(client_mob, span_adminnotice("You have been sent to Prison!"), confidential = TRUE)

	log_admin("Discord: [key_name(usr)] has sent [key_name(client_mob)] to Prison!")
	message_admins("Discord: [key_name_admin(usr)] has sent [key_name_admin(client_mob)] to Prison!")

/datum/world_topic/plx_ticketaction
	keyword = "PLX_ticketaction"
	require_comms_key = TRUE

/datum/world_topic/plx_ticketaction/Run(list/input)
	var/ticketid = input["id"]
	var/action_by_ckey = input["action_by"]
	var/action = input["action"]

	if(!ticketid || !action_by_ckey || !action)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "id/action_by/action", "reason" = "missing required parameter")

	var/datum/client_interface/mockadmin = new(key = action_by_ckey)

	usr = mockadmin

	var/datum/admin_help/ticket = GLOB.ahelp_tickets.TicketByID(ticketid)
	if (QDELETED(ticket)) return list("error" = PLEXORA_ERROR_TICKETNOTEXIST)

	if (action != "reopen" && ticket.state != AHELP_ACTIVE)
		return

	switch(action)
		if("reopen")
			if (ticket.state == AHELP_ACTIVE) return
			SSplexora.aticket_reopened(ticket, action_by_ckey)
			ticket.Reopen()
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
	var/ticketid = text2num(input["ticket_id"])
	var/input_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/stealth = input["stealth"]
	var/message = input["message"]

	if(!input_ckey || !sender || !message)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/sender_ckey/message", "reason" = "missing required parameter")

	var/requested_ckey = ckey(input_ckey)
	var/client/recipient = disambiguate_client(requested_ckey)

	if (QDELETED(recipient))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	var/datum/admin_help/ticket = ticketid ? GLOB.ahelp_tickets.TicketByID(ticketid) : GLOB.ahelp_tickets.CKey2ActiveTicket(requested_ckey)

	if (QDELETED(ticket))
		return list("error" = PLEXORA_ERROR_TICKETNOTEXIST)

	var/plx_tagged = "[sender]"

	var/adminname = stealth ? "Administrator" : plx_tagged
	var/stealthkey = GetTgsStealthKey()

	message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
	message = emoji_parse(message)

	if (!message)
		return list("error" = PLEXORA_ERROR_SANITIZATION_FAILED)

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
		"<a href='byond://?priv_msg=[stealthkey]'>[adminname]</a>",
		message,
	)

	to_chat(recipient,
		type = MESSAGE_TYPE_ADMINPM,
		html = span_adminsay("<i>Click on the administrator's name to reply.</i>"),
		confidential = TRUE)

	ticket.AddInteraction(message, ckey=sender)

	window_flash(recipient, ignorepref = TRUE)
	// Nullcheck because we run a winset in window flash and I do not trust byond
	if(!QDELETED(recipient))
		//always play non-admin recipients the adminhelp sound
		SEND_SOUND(recipient, 'sound/effects/adminhelp.ogg')

		recipient.externalreplyamount = EXTERNALREPLYCOUNT

/datum/world_topic/plx_sendmticketpm
	keyword = "PLX_sendmticketpm"
	require_comms_key = TRUE

/datum/world_topic/plx_sendmticketpm/Run(list/input)
	//var/ticketid = input["ticket_id"]
	var/target_ckey = input["ckey"]
	var/sender = input["sender_ckey"]
	var/message = input["message"]

	if(!target_ckey || !sender || !message)
		return list("error" = PLEXORA_ERROR_BAD_PARAM, "param" = "ckey/sender_ckey/message", "reason" = "missing required parameter")

	var/client/recipient = disambiguate_client(ckey(target_ckey))

	if (QDELETED(recipient))
		return list("error" = PLEXORA_ERROR_CLIENTNOTEXIST)

	// var/datum/request/request = GLOB.mentor_requests.requests_by_id[num2text(ticketid)]

	SEND_SOUND(recipient, 'sound/items/bikehorn.ogg')
	to_chat(recipient, "<font color='purple'>Mentor PM from-<b>[key_name_mentor(sender, recipient, TRUE, FALSE, FALSE)]</b>: [message]</font>")
	for(var/client/honked_client as anything in GLOB.mentors | GLOB.admins)
		if(QDELETED(honked_client) || honked_client == recipient)
			continue
		to_chat(honked_client,
			type = MESSAGE_TYPE_MODCHAT,
			html = "<B><font color='green'>Mentor PM: [key_name_mentor(sender, honked_client, FALSE, FALSE)]-&gt;[key_name_mentor(recipient, honked_client, FALSE, FALSE)]:</B> <font color = #5c00e6> <span class='message linkify'>[message]</span></font>",
			confidential = TRUE)

/datum/world_topic/plx_relayadminsay
	keyword = "PLX_relayadminsay"
	require_comms_key = TRUE

/datum/world_topic/plx_relayadminsay/Run(list/input)
	var/sender = input["sender"]
	var/msg = input["message"]

	if (!sender || !msg)
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	if(findtext(msg, "@") || findtext(msg, "#"))
		var/list/link_results = check_asay_links(msg)
		if(length(link_results))
			msg = link_results[ASAY_LINK_NEW_MESSAGE_INDEX]
			link_results[ASAY_LINK_NEW_MESSAGE_INDEX] = null
			var/list/pinged_admin_clients = link_results[ASAY_LINK_PINGED_ADMINS_INDEX]
			for(var/iter_ckey in pinged_admin_clients)
				var/client/iter_admin_client = pinged_admin_clients[iter_ckey]
				if(!iter_admin_client?.holder)
					continue
				window_flash(iter_admin_client)
				SEND_SOUND(iter_admin_client.mob, sound('sound/misc/asay_ping.ogg'))

	msg = keywords_lookup(msg)

	// TODO: Load sender's color prefs? idk
	msg = span_adminsay("[span_prefix("ADMIN (DISCORD):")] <EM>[sender]</EM>: <span class='message linkify'>[msg]</span>")

	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = msg,
		confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_say_relay", 1, "Asay external") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/world_topic/plx_relaymentorsay
	keyword = "PLX_relaymentorsay"
	require_comms_key = TRUE

/datum/world_topic/plx_relaymentorsay/Run(list/input)
	var/sender = input["sender"]
	var/msg = input["message"]

	if (!sender || !msg)
		return

	msg = emoji_parse(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	var/list/pinged_mentor_clients = check_mentor_pings(msg)
	if(length(pinged_mentor_clients) && pinged_mentor_clients[ASAY_LINK_PINGED_ADMINS_INDEX])
		msg = pinged_mentor_clients[ASAY_LINK_PINGED_ADMINS_INDEX]
		pinged_mentor_clients -= ASAY_LINK_PINGED_ADMINS_INDEX

	for(var/iter_ckey in pinged_mentor_clients)
		var/client/iter_mentor_client = pinged_mentor_clients[iter_ckey]
		if(!iter_mentor_client?.mentor_datum)
			continue
		window_flash(iter_mentor_client)
		SEND_SOUND(iter_mentor_client.mob, sound('sound/misc/bloop.ogg'))

	log_mentor("MSAY(DISCORD): [sender] : [msg]")
	msg = "<b><font color='#7544F0'><span class='prefix'>DISCORD:</span> <EM>[sender]</EM>: <span class='message linkify'>[msg]</span></font></b>"

	to_chat(GLOB.admins | GLOB.mentors,
		type = MESSAGE_TYPE_MODCHAT,
		html = msg,
		confidential = TRUE)

	SSblackbox.record_feedback("tally", "mentor_say_relay", 1, "Msay external") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef TOPIC_EMITTER
