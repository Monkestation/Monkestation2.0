/// Orders slime extracts and crossbreeds from xenobiology. Collecting them still takes a trip to an extract request console.
/datum/computer_file/program/extract_requests
	filename = "extractrequests"
	filedesc = "Extract Requests"
	downloader_category = PROGRAM_CATEGORY_SCIENCE
	program_open_overlay = "research"
	extended_desc = "Order slime extracts and crossbreeds from xenobiology, and follow your orders until they're ready to collect from an extract request console."
	size = 1
	tgui_id = "NtosExtractRequests"
	program_icon = "box-open"

/datum/computer_file/program/extract_requests/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/slimepedia),
		get_asset_datum(/datum/asset/spritesheet_batched/slimepedia),
	)

/datum/computer_file/program/extract_requests/ui_data(mob/user)
	return extract_request_public_data(computer.computer_id_slot)

/datum/computer_file/program/extract_requests/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	return extract_request_public_act(action, params, ui.user, computer.computer_id_slot)
