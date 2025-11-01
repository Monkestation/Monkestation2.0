// This might be compatible with sentry, I'm not sure, my trial period expired so I can't test lol
// Configuration options are in entries/general.dm

/proc/send_to_glitchtip(exception/E, list/extra_data = null)
	#ifndef SPACEMAN_DMM
	#ifndef OPENDREAM
	if(!CONFIG_GET(string/glitchtip_dsn))
		return
	var/glitchtip_dsn = CONFIG_GET(string/glitchtip_dsn)

	// parse DSN to get the key, host and project id
	// Format: https://key@host/project_id
	var/dsn_clean = replacetext(replacetext(glitchtip_dsn, "http://", ""), "https://", "")
	var/at_pos = findtext(dsn_clean, "@")
	var/slash_pos = findtext(dsn_clean, "/", at_pos)
	if(!at_pos || !slash_pos)
		log_runtime("Invalid Glitchtip DSN format")
		return
	var/key = copytext(dsn_clean, 1, at_pos)
	var/host = copytext(dsn_clean, at_pos + 1, slash_pos)
	var/project_id = copytext(dsn_clean, slash_pos + 1)

	// Build Glitchtip/Sentry event payload
	var/list/event_data = list()
	event_data["event_id"] = rustg_generate_uuid_v4()
	event_data["timestamp"] = time_stamp_metric()
	event_data["level"] = "error"
	event_data["platform"] = world.system_type
	event_data["server_name"] = world.name
	event_data["environment"] = CONFIG_GET(string/glitchtip_environment)

	//! SDK information
	event_data["sdk"] = list(
		"name" = "byond-glitchtip",
		"version" = "1.0.0"
	)

	//! Exception data - Glitchtip expects this format
	var/list/exception_data = list()
	exception_data["type"] = "BYOND Runtime Error"
	exception_data["value"] = E.name
	exception_data["module"] = E.file

	// Build stack trace using caller/callee chain
	var/list/frames = list()

	// Add the error location as the first frame
	var/list/error_frame = list()
	error_frame["filename"] = E.file || "unknown"
	error_frame["lineno"] = E.line || 0
	error_frame["function"] = "runtime_error"
	error_frame["in_app"] = TRUE
	frames += list(error_frame)

	// Walk the call stack using callee objects
	var/frame_count = 0
	var/max_frames = 50 // Prevent infinite loops or excessive data
	for(var/callee/p = caller; p && frame_count < max_frames; p = p.caller)
		frame_count++
		var/proc_name = "unknown"
		var/file_name = "unknown"
		var/line_num = 0

		if(p.proc)
			proc_name = "[p.proc.type]"
			// Clean up the proc name if it has path separators
			var/slash_pos_inner = findtext(proc_name, "/", -1)
			if(slash_pos_inner && slash_pos_inner < length(proc_name))
				proc_name = copytext(proc_name, slash_pos_inner + 1)

		// Get file and line information if available
		if(p.file)
			file_name = p.file
			line_num = p.line || 0

		if(findtext(file_name, "master.dm") && (proc_name == "Loop" || proc_name == "StartProcessing"))
			break

		var/list/frame = list()
		frame["filename"] = file_name
		frame["lineno"] = line_num
		frame["function"] = proc_name
		frame["in_app"] = TRUE

		// Collect all available variables for this frame
		var/list/frame_vars = list()

		// Add context variables
		if(p.src)
			frame_vars["src"] = "[p.src]"
		if(p.usr)
			frame_vars["usr"] = "[p.usr]"

		// Add procedure arguments
		if(p.args && length(p.args))
			for(var/i = 1; i <= length(p.args); i++)
				var/datum/arg_value = p.args[i]
				var/arg_string = "null"

				// Not so sanely convert argument to string representation
				try
					if(arg_value == null)
						arg_string = "null"
					else if(isnum(arg_value))
						arg_string = "[arg_value]"
					else if(istext(arg_value))
						// URL decode if it looks like URL-encoded data
						var/decoded_value = arg_value
						if(findtext(arg_value, "%") || findtext(arg_value, "&") || findtext(arg_value, "="))
							decoded_value = url_decode(arg_value)

						if(length(decoded_value) > 200)
							arg_string = "\"[copytext(decoded_value, 1, 198)]...\""
						else
							arg_string = "\"[decoded_value]\""
					else if(islist(arg_value))
						// Handle lists by showing summary and contents
						var/list/L = arg_value
						if(length(L) == 0)
							arg_string = "list(empty)"
						else
							arg_string = "list([length(L)] items)"

							// Build contents string
							var/list/content_items = list()
							var/max_list_items = 20 // Prevent too long contents
							var/items_to_show = min(length(L), max_list_items)

							for(var/j = 1; j <= items_to_show; j++)
								var/datum/item = L[j]
								var/item_string = "null"

								try
									if(item == null)
										item_string = "null"
									else if(isnum(item))
										item_string = "[item]"
									else if(istext(item))
										// URL decode as a treat
										var/decoded_item = item
										if(findtext(item, "%") || findtext(item, "&") || findtext(item, "="))
											decoded_item = url_decode(item)

										if(length(decoded_item) > 50)
											item_string = "\"[copytext(decoded_item, 1, 48)]...\""
										else
											item_string = "\"[decoded_item]\""
									else if(istype(item))
										var/item_type_name = "[item.type]"
										var/slash_pos_item = findtext(item_type_name, "/", -1)
										if(slash_pos_item && slash_pos_item < length(item_type_name))
											item_type_name = copytext(item_type_name, slash_pos_item + 1)
										item_string = "[item_type_name]([item])"
									else
										item_string = "[item]"
								catch
									item_string = "<error>"

								content_items += item_string

							var/contents_string = jointext(content_items, ", ")
							if(length(L) > max_list_items)
								contents_string += ", ... and [length(L) - max_list_items] more"

							frame_vars["arg[i]_contents"] = contents_string
					else if(istype(arg_value))
						var/type_name = "[arg_value.type]"
						var/slash_pos_obj = findtext(type_name, "/", -1)
						if(slash_pos_obj && slash_pos_obj < length(type_name))
							type_name = copytext(type_name, slash_pos_obj + 1)
						arg_string = "[type_name]: [arg_value]"
					else
						arg_string = "[arg_value]"
				catch
					arg_string = "<error converting arg>"

				frame_vars["arg[i]"] = arg_string

		if(length(frame_vars))
			frame["vars"] = frame_vars


		frames += list(frame)

	exception_data["stacktrace"] = list("frames" = frames)
	event_data["exception"] = list("values" = list(exception_data))

	// User context
	if(istype(usr))
		var/list/user_data = list()
		user_data["key"] = usr.key
		user_data["character_name"] = usr.name
		user_data["character_realname"] = usr.real_name
		user_data["character_mobtype"] = usr.type
		user_data["character_job"] = usr.job
		if(usr.client)
			user_data["byond_version"] = usr.client.byond_version
			user_data["byond_build"] = usr.client.byond_build
			// user_data["ip_address"] = usr.client.address
			// user_data["computer_id"] = usr.client.computer_id
			user_data["holder"] = usr.client.holder?.name
		event_data["user"] = user_data

		// Add location context
		var/locinfo = loc_name(usr)
		if(locinfo)
			if(!extra_data)
				extra_data = list()
			extra_data["user_location"] = locinfo

	if(extra_data)
		event_data["extra"] = extra_data

	// Tags for filtering in Glitchtip
	event_data["tags"] = list(
		"round_id" = GLOB.round_id,
		"file" = E.file,
		"line" = "[E.line]",
		"byond_version" = DM_VERSION,
		"byond_build" = DM_BUILD,
	)

	event_data["fingerprint"] = list("[E.file]:[E.line]", E.name)

	send_glitchtip_request(event_data, host, project_id, key)
	#endif
	#endif

/proc/send_glitchtip_request(list/event_data, host, project_id, key)
	var/glitchtip_url = "https://[host]/api/[project_id]/store/"
	var/json_payload = json_encode(event_data)

	// Glitchtip/Sentry auth header - According to docs this needs to be like this
	var/auth_header = "Sentry sentry_version=7, sentry_client=byond-glitchtip/1.0.0, sentry_key=[key], sentry_timestamp=[time_stamp_metric()]"

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, glitchtip_url, json_payload, list(
		"X-Sentry-Auth" = auth_header,
		"Content-Type" = "application/json",
		"User-Agent" = get_useragent("Glitchtip-Implementation")
	))
	request.fire_and_forget()
