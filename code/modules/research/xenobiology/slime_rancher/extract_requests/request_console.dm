/// Where the crew orders slime extracts and crossbreeds from xenobiology, and collects them once they're ready.
/obj/machinery/computer/extract_requests
	name = "extract request console"
	desc = "Orders slime extracts and crossbreeds from xenobiology. Hold your ID to place an order or collect one."
	icon_state = "market"
	icon_screen = "market_screen"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/extract_requests

/obj/machinery/computer/extract_requests/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExtractRequests", name)
		ui.open()

/obj/machinery/computer/extract_requests/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/slimepedia),
		get_asset_datum(/datum/asset/spritesheet_batched/slimepedia),
	)

/obj/machinery/computer/extract_requests/ui_data(mob/user)
	return extract_request_public_data(extract_request_get_id(user))

/obj/machinery/computer/extract_requests/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	var/obj/item/card/id/id_card = extract_request_get_id(user)
	if(action == "pickup")
		return pick_up(user, id_card, params["id"])
	return extract_request_public_act(action, params, user, id_card)

/// Hands the requester everything loaded for their finished order, and pays whoever filled it.
/obj/machinery/computer/extract_requests/proc/pick_up(mob/user, obj/item/card/id/id_card, request_id)
	var/datum/extract_request/request = find_extract_request(request_id)
	if(!request || request.status != EXTRACT_REQUEST_READY || !id_card || request.requester_account != id_card.registered_account)
		return FALSE
	request.status = EXTRACT_REQUEST_PICKED_UP
	for(var/obj/item/item as anything in request.loaded)
		user.put_in_hands(item)
	request.pay_claimer()
	user.log_message("picked up [request.describe()], filled by [request.claimer_name]", LOG_GAME)
	return TRUE
