/// Where xenobiology claims, fills and answers the crew's extract requests. Loaded items wait inside until the requester collects them.
/obj/machinery/computer/extract_orders
	name = "extract order console"
	desc = "Lists what the crew has asked xenobiology for. Load extracts or crossbreeds into it to fill an order."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "xenobio_order_off"
	icon_screen = "xenobio_order_on"
	icon_keyboard = null
	density = FALSE
	circuit = null
	req_access = list(ACCESS_XENOBIOLOGY)
	light_color = LIGHT_COLOR_PURPLE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/extract_orders, 30)

/obj/machinery/computer/extract_orders/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()

/obj/machinery/computer/extract_orders/Destroy()
	drop_loaded()
	return ..()

/obj/machinery/computer/extract_orders/deconstruct(disassembled = TRUE, mob/user)
	// computer/deconstruct dumps our contents with no log, so get them out first
	drop_loaded()
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/wallframe/extract_orders(loc)
	return ..()

/// Drops everything loaded into this console onto the floor.
/obj/machinery/computer/extract_orders/proc/drop_loaded()
	for(var/datum/extract_request/request as anything in GLOB.extract_requests)
		var/dropped = 0
		for(var/obj/item/item as anything in request.loaded)
			if(item.loc == src)
				item.forceMove(drop_location())
				dropped++
		if(dropped)
			log_game("[src] was taken down, dropping [dropped] item\s loaded for [request.describe()]")

/obj/machinery/computer/extract_orders/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/datum/extract_request/request as anything in GLOB.extract_requests)
		if(!(gone in request.loaded))
			continue
		request.loaded -= gone
		if(request.status == EXTRACT_REQUEST_READY)
			request.status = EXTRACT_REQUEST_CLAIMED

/// Says a new request out loud, so nobody in xenobiology can claim they didn't hear it.
/obj/machinery/computer/extract_orders/proc/chime(message)
	if(!is_operational)
		return
	say(message)
	playsound(src, 'sound/machines/chime.ogg', 40, TRUE)

/obj/machinery/computer/extract_orders/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExtractOrders", name)
		ui.open()

/obj/machinery/computer/extract_orders/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/slimepedia),
		get_asset_datum(/datum/asset/spritesheet_batched/slimepedia),
	)

/obj/machinery/computer/extract_orders/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. > UI_UPDATE && isliving(user) && !allowed(user))
		return UI_UPDATE

/obj/machinery/computer/extract_orders/ui_data(mob/user)
	var/datum/bank_account/viewer = extract_request_get_id(user)?.registered_account
	var/list/requests = list()
	for(var/datum/extract_request/request as anything in GLOB.extract_requests)
		requests += list(request.to_list(viewer))
	var/list/stock = list()
	for(var/obj/machinery/smartfridge/extract/fridge in range(COMPRESSOR_LINK_RANGE, src))
		for(var/obj/item/slime_extract/extract in fridge.contents)
			var/datum/slime_type/slime_type = GLOB.slime_types_by_extract[extract.type]
			if(slime_type)
				stock[slime_icon_prefix(slime_type)]++
	return list(
		"requests" = requests,
		"stock" = stock,
		"bred" = extract_request_bred_colors(),
	)

/obj/machinery/computer/extract_orders/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(!allowed(user))
		return FALSE
	var/datum/extract_request/request = find_extract_request(params["id"])
	if(!request)
		return FALSE
	var/obj/item/card/id/id_card = extract_request_get_id(user)
	var/datum/bank_account/account = id_card?.registered_account
	var/is_claimer = !isnull(account) && request.claimer_account == account
	switch(action)
		if("see")
			request.seen = TRUE
			return TRUE
		if("claim")
			if(request.status != EXTRACT_REQUEST_WAITING)
				return FALSE
			if(!account)
				balloon_alert(user, "hold your ID")
				return FALSE
			request.status = EXTRACT_REQUEST_CLAIMED
			request.claimer_name = id_card.registered_name
			request.claimer_account = account
			request.seen = TRUE
			user.log_message("claimed [request.describe()]", LOG_GAME)
			return TRUE
		if("unclaim")
			if(request.status != EXTRACT_REQUEST_CLAIMED || !is_claimer)
				return FALSE
			request.status = EXTRACT_REQUEST_WAITING
			request.claimer_name = null
			request.claimer_account = null
			user.log_message("gave up [request.describe()]", LOG_GAME)
			return TRUE
		if("ready")
			if(request.status != EXTRACT_REQUEST_CLAIMED || !is_claimer)
				return FALSE
			var/needed = request.count - length(request.loaded)
			var/list/obj/item/slime_extract/found = take_from_fridges(request.item_type, needed)
			if(length(found) < needed)
				balloon_alert(user, "short by [needed - length(found)]")
				return FALSE
			for(var/obj/item/slime_extract/extract as anything in found)
				extract.forceMove(src)
				request.add_loaded(extract, user)
			return TRUE
		if("decline")
			if(!request.is_open() || (request.status != EXTRACT_REQUEST_WAITING && !is_claimer))
				return FALSE
			for(var/obj/item/item as anything in request.loaded)
				item.forceMove(item.drop_location())
			request.status = EXTRACT_REQUEST_DECLINED
			request.decline_reason = trim(STRIP_HTML_SIMPLE("[params["reason"]]", EXTRACT_REQUEST_REASON_LENGTH + 1))
			request.refund_offer()
			user.log_message("declined [request.describe()], reason: \"[request.decline_reason]\"", LOG_GAME)
			return TRUE
	return FALSE

/// Up to amount extracts of the given type from the extract fridges in range.
/obj/machinery/computer/extract_orders/proc/take_from_fridges(obj/item/slime_extract/extract_type, amount)
	. = list()
	for(var/obj/machinery/smartfridge/extract/fridge in range(COMPRESSOR_LINK_RANGE, src))
		for(var/obj/item/slime_extract/extract in fridge.contents)
			if(extract.type != extract_type)
				continue
			. += extract
			if(length(.) >= amount)
				return

/obj/machinery/computer/extract_orders/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/is_bag = istype(tool, /obj/item/storage/bag/xeno)
	if(!is_bag && !istype(tool, /obj/item/slime_extract) && !istype(tool, /obj/item/slimecross))
		return ..()
	if(!allowed(user))
		balloon_alert(user, "access denied")
		return ITEM_INTERACT_BLOCKING
	var/datum/bank_account/account = extract_request_get_id(user)?.registered_account
	if(!account)
		balloon_alert(user, "hold your ID")
		return ITEM_INTERACT_BLOCKING
	var/loaded = 0
	for(var/obj/item/item as anything in (is_bag ? tool.contents : list(tool)))
		if(load_for_claimer(item, user, account))
			loaded++
	if(!loaded)
		balloon_alert(user, "nothing you claimed needs that")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "loaded [loaded] item\s")
	return ITEM_INTERACT_SUCCESS

/// Counts the item toward the oldest request this claimer still has open for it. Returns whether any took it.
/obj/machinery/computer/extract_orders/proc/load_for_claimer(obj/item/item, mob/user, datum/bank_account/claimer)
	for(var/datum/extract_request/request as anything in GLOB.extract_requests)
		if(request.status != EXTRACT_REQUEST_CLAIMED || request.claimer_account != claimer)
			continue
		if(item.type != request.item_type || length(request.loaded) >= request.count)
			continue
		item.forceMove(src)
		request.add_loaded(item, user)
		return TRUE
	return FALSE

/obj/item/wallframe/extract_orders
	name = "extract order console frame"
	desc = "An unmounted extract order console. Attach it to a wall to use."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "xenobio_order_off"
	result_path = /obj/machinery/computer/extract_orders
	pixel_shift = 30

/obj/item/wallframe/extract_orders/after_attach(obj/attached_to)
	. = ..()
	qdel(attached_to.GetComponent(/datum/component/wall_mounted))
	attached_to.find_and_hang_on_wall()

/datum/design/extract_orders_console
	name = "Extract Order Console Frame"
	id = "extract_orders_console"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/wallframe/extract_orders
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MOUNTS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
