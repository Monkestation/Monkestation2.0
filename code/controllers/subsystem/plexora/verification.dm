/datum/controller/subsystem/plexora/proc/loaded_allowed_ckeys()
	LAZYINITLIST(allowed_ckeys)
	if (!enabled || !fexists("[global.config.directory]/allowed_ckeys.txt"))
		return
	allowed_ckeys.Cut()
	var/list/lines = world.file2list("[global.config.directory]/allowed_ckeys.txt")
	for(var/line in lines)
		if(!length(line))
			continue
		if(findtextEx(line, "#", 1, 2))
			continue
		LAZYADD(allowed_ckeys, ckey(line))

/**
 * Given a ckey, polls a ckey for verification.
 * Returns one of the values defined in __DEFINES/plexora.dm
 */
/datum/controller/subsystem/plexora/proc/poll_ckey_for_verification(ckey, required_roleid)
	if (!enabled || (ckey in allowed_ckeys))
		return list(
			"polling_response" = PLEXORA_CKEYPOLL_LINKED_ALLOWEDWHITELIST,
			"discord_id" = "0000000000000000000",
			"discord_username" = !enabled ? "PLEXORA_NOT_ENABLED" : "ckey_whitelisted",
			"discord_displayname" = !enabled ? "Plexora Not Enabled" : "Ckey Whitelisted",
			"has_requiredrole" = TRUE
		)

	var/list/request_body = list(
		"ckey" = ckey
	)
	if (required_roleid)
		request_body["required_roleid"] = required_roleid

	var/datum/http_request/request = new(
		RUSTG_HTTP_METHOD_POST,
		"[base_url]/lookupckey",
		json_encode(request_body),
		default_headers,
	)
	request.begin_async()
	UNTIL_OR_TIMEOUT(request.is_complete(), 5 SECONDS)
	var/datum/http_response/response = request.into_response()
	if (response.errored)
		stack_trace(response.body)
		plexora_is_alive = FALSE
		log_access("Plexora is down. Failed to poll ckey [ckey]")
		return list(
			"polling_response" = PLEXORA_DOWN
		)
	else
		plexora_is_alive = TRUE
		var/list/polling_response_body = json_decode(response.body)
		polling_response_body["polling_response"] = text2num(polling_response_body["polling_response"])
		return polling_response_body

/* Discord Verification Window */

/client/verb/verify_in_discord()
	set category = "OOC"
	set name = "Verify Discord Account"
	set desc = "Verify your discord account with your BYOND account"

	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(src, span_warning("This feature requires the SQL backend to be running."))
		return

	if(!CONFIG_GET(flag/plexora_enabled))
		to_chat(src, span_warning("This feature requires Plexora to be running."))
		return

	if(!SSplexora?.reverify_cache)
		to_chat(src, span_warning("Wait for the Discord subsystem to finish initialising"))
		return

	var/datum/discord_verification/tgui = new(src)
	tgui.ui_interact(usr)

/datum/discord_verification
	var/verification_code
	var/discord_invite

/datum/discord_verification/New(client/user)
	var/cached_one_time_token = SSplexora.reverify_cache[user.ckey]
	if(cached_one_time_token && cached_one_time_token != "")
		verification_code = cached_one_time_token
	else
		var/one_time_token = SSplexora.get_or_generate_one_time_token_for_ckey(user.ckey)
		SSplexora.reverify_cache[user.ckey] = one_time_token
		verification_code = one_time_token

	if (!user.persistent_client.discord_details)
		var/list/plexora_poll_result = SSplexora.poll_ckey_for_verification(user.ckey)
		user.persistent_client.discord_details = new /datum/discord_details(
			plexora_poll_result["discord_id"],
			plexora_poll_result["discord_username"],
			plexora_poll_result["discord_displayname"],
			plexora_poll_result["polling_response"]
		)

	discord_invite = CONFIG_GET(string/discordurl)

/datum/discord_verification/ui_state(mob/user)
	return GLOB.always_state

/datum/discord_verification/ui_close()
	qdel(src)

/datum/discord_verification/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/discord_verification),
	)

/datum/discord_verification/ui_static_data(mob/user)
	. = list()
	.["verification_code"] = verification_code
	.["discord_invite"] = discord_invite
	.["discord_details"] = user.persistent_client.discord_details.convert_to_list()

/datum/discord_verification/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DiscordVerification")
		ui.open()

/datum/asset/simple/discord_verification
	assets = list(
		"dverify_image1.png" = 'icons/ui_icons/tgui/dverify_image1.png',
		"dverify_image2.png" = 'icons/ui_icons/tgui/dverify_image2.png',
		"dverify_image3.png" = 'icons/ui_icons/tgui/dverify_image3.png',
		"dverify_image4.png" = 'icons/ui_icons/tgui/dverify_image4.png',
	)

/// Details are on /datum/persistent_client
/datum/discord_details
	var/id
	var/username
	var/displayname
	var/status
	var/has_requiredrole

/datum/discord_details/New(id, username, displayname, status = PLEXORA_DOWN)
	src.id = id
	src.username = username
	src.displayname = displayname
	src.status = status

/datum/discord_details/proc/convert_to_list()
	. = list()
	.["id"] = id
	.["username"] = username
	.["displayname"] = displayname
	.["status"] = status
