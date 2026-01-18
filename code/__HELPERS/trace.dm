/proc/capture_call_stack() as /list
	. = list()

	// Walk the call stack using callee objects
	var/frame_count = 0
	var/max_frames = 50 // Prevent infinite loops or excessive data
	for(var/callee/p = caller; p && frame_count < max_frames; p = p.caller)
		frame_count++
		var/proc_name = "unknown"
		var/file_name = "unknown"
		var/line_num = 0

		if(p.proc)
			#ifndef OPENDREAM
			proc_name = "[p.proc.type]"
			#endif
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

		// Collect all available variables for this frame
		var/list/frame_vars = list()

		// Add context variables
		if(p.src)
			frame_vars["src"] = "[p.src]"
		if(p.usr)
			frame_vars["usr"] = "[p.usr]"

		// Add procedure arguments
		if(p.args && length(p.args))
			for(var/i = 1 to length(p.args))
				var/datum/arg_value = p.args[i]
				var/arg_string = "null"

				// Not so sanely convert argument to string representation
				try
					if(isnull(arg_value))
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

							for(var/j = 1 to items_to_show)
								var/datum/item = L[j]
								var/item_string = "null"

								try
									if(isnull(item))
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


		. += list(frame)
