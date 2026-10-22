/// Global list tracking how many times each ckey has bought their own cassettes this round
GLOBAL_LIST_EMPTY(self_cassette_purchases)

/obj/machinery/cassette_library
	name = "Cassette Library Terminal"
	desc = "A terminal that sells cassettes approved by the Space Board of Music."
	icon = 'icons/obj/cassettes/cassette_library.dmi'
	icon_state = "cassette_library"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

	// amount of credits currently inserted into the terminal
	var/stored_credits = 0
	var/cassette_cost = 100
	var/busy = FALSE

	// purchase history tracking
	var/list/purchase_history = list() // all purchases made from this terminal

/obj/machinery/cassette_library/Initialize(mapload)
	. = ..()
	base_icon_state = icon_state
	register_context()
	set_light(l_outer_range = 1.5, l_power = 1, l_color = "#BEF1BE")

/obj/machinery/cassette_library/update_appearance(updates=ALL)
	. = ..()
	set_light(powered() ? 1.5 : 0)

/obj/machinery/cassette_library/update_icon_state()
	icon_state = "[base_icon_state][powered() ? null : "-off"]"
	return ..()

/obj/machinery/cassette_library/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(istype(held_item, /obj/item/holochip))
		context[SCREENTIP_CONTEXT_LMB] = "Insert credits"
		return CONTEXTUAL_SCREENTIP_SET
	else if(isidcard(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Pay with ID"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/machinery/cassette_library/examine(mob/user)
	. = ..()
	. += span_notice("Each cassette costs [cassette_cost] credits.")
	if(stored_credits > 0)
		. += span_notice("Currently has [stored_credits] credits inserted.")

/obj/machinery/cassette_library/attackby(obj/item/attacking_item, mob/user, params)
	// cant insert holochips if terminal is unpowered
	if(machine_stat & NOPOWER)
		return ..()

	// holochip payment
	if(istype(attacking_item, /obj/item/holochip))
		var/obj/item/holochip/chip = attacking_item
		if(!chip.credits)
			balloon_alert(user, "holochip is empty!")
			return
		stored_credits += chip.credits
		balloon_alert(user, "inserted [chip.credits] credits")
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE)
		qdel(chip)
		return

	// direct ID payment
	if(isidcard(attacking_item))
		var/obj/item/card/id/id_card = attacking_item
		var/datum/bank_account/account = id_card.registered_account
		if(!account)
			balloon_alert(user, "no account linked!")
			return

		var/amount = tgui_input_number(user, "How many credits do you want to add?", "Add Credits", max_value = account.account_balance)
		if(!amount || amount <= 0)
			return
		if(QDELETED(src) || QDELETED(user) || !user.Adjacent(src))
			return

		if(!account.adjust_money(-amount, "Cassette Library: Credit Deposit"))
			balloon_alert(user, "insufficient funds!")
			return

		stored_credits += amount
		balloon_alert(user, "added [amount] credits")
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE)
		return

	return ..()

/obj/machinery/cassette_library/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	ui_interact(user)

/obj/machinery/cassette_library/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteLibrary", name)
		ui.open()

/obj/machinery/cassette_library/ui_static_data(mob/user)
	var/list/data = list()

	var/list/cassette_list = list()
	var/list/approved_cassettes = SScassettes.filtered_cassettes(status = CASSETTE_STATUS_APPROVED)

	for(var/datum/cassette/cassette as anything in approved_cassettes)
		var/icon_state = cassette.front?.design || "cassette_flip"
		cassette_list += list(list(
			"id" = cassette.id,
			"name" = html_decode(cassette.name),
			"desc" = html_decode(cassette.desc),
			"author_name" = cassette.author.name,
			"author_ckey" = cassette.author.ckey,
			"submitted_time" = cassette.submitted_time,
			"approved_time" = cassette.approved_time,
			"icon" = 'icons/obj/cassettes/walkman.dmi',
			"icon_state" = icon_state
		))

	data["cassettes"] = cassette_list

	// get most bought for the TOP CASSETTES tab
	data["top_cassettes"] = get_top_cassettes(20)

	return data

/obj/machinery/cassette_library/ui_data(mob/user)
	var/list/data = list()
	data["stored_credits"] = stored_credits
	data["cassette_cost"] = cassette_cost
	data["busy"] = busy

	// get user's ID for personal history filtering
	var/user_id = null
	if(isliving(user))
		var/mob/living/living_user = user
		var/obj/item/card/id/id_card = living_user.get_idcard(TRUE)
		if(id_card)
			user_id = id_card.registered_name
	data["user_id"] = user_id

	// send purchase history
	data["purchase_history"] = purchase_history

	return data

/obj/machinery/cassette_library/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase_cassette")
			var/cassette_id = params["cassette_id"]
			if(!cassette_id)
				return FALSE

			if(busy)
				balloon_alert(ui.user, "busy!")
				return TRUE

			// do you have enough creds to make this purchase, my kind sir?
			if(stored_credits < cassette_cost)
				balloon_alert(ui.user, "insufficient credits!")
				to_chat(ui.user, span_warning("You need [cassette_cost] credits to purchase a cassette. You have [stored_credits] credits."))
				return TRUE

			var/datum/cassette/selected_cassette = SScassettes.cassettes[cassette_id]
			if(selected_cassette?.status != CASSETTE_STATUS_APPROVED)
				balloon_alert(ui.user, "cassette not found!")
				return TRUE

			return process_purchase(selected_cassette, ui.user)

		if("repurchase_cassette")
			var/cassette_name = params["cassette_name"]
			if(!cassette_name)
				return FALSE

			if(busy)
				balloon_alert(ui.user, "busy!")
				return TRUE

			// do you have enough creds to make this purchase, my kind sir?
			if(stored_credits < cassette_cost)
				balloon_alert(ui.user, "insufficient credits!")
				to_chat(ui.user, span_warning("You need [cassette_cost] credits to purchase a cassette. You have [stored_credits] credits."))
				return TRUE

			// find the cassette by name in approved cassettes
			var/list/approved_cassettes = SScassettes.filtered_cassettes(status = CASSETTE_STATUS_APPROVED)
			var/datum/cassette/selected_cassette = null
			for(var/datum/cassette/cassette as anything in approved_cassettes)
				if(cassette.name == cassette_name)
					selected_cassette = cassette
					break

			if(!selected_cassette)
				balloon_alert(ui.user, "cassette not found!")
				return TRUE

			return process_purchase(selected_cassette, ui.user)

	return FALSE

/obj/machinery/cassette_library/proc/process_purchase(datum/cassette/selected_cassette, mob/user)
	stored_credits -= cassette_cost

	// record purchase in history
	var/buyer_name = "Unknown"
	if(isliving(user))
		var/mob/living/living_user = user
		var/obj/item/card/id/id_card = living_user.get_idcard(TRUE)
		if(id_card)
			buyer_name = id_card.registered_name

	var/icon_state = selected_cassette.front?.design || "cassette_flip"
	var/list/purchase_record = list(
		"buyer" = buyer_name,
		"cassette_id" = selected_cassette.id,
		"cassette_name" = selected_cassette.name,
		"cassette_author" = selected_cassette.author.name,
		"cassette_author_ckey" = selected_cassette.author.ckey,
		"cassette_icon" = 'icons/obj/cassettes/walkman.dmi',
		"cassette_icon_state" = icon_state,
		"time" = world.time
	)
	purchase_history += list(purchase_record)

	// record purchase for top cassettes tracking (only counts first purchase per user)
	var/buyer_ckey = null
	if(user?.ckey)
		buyer_ckey = user.ckey
		record_cassette_purchase(selected_cassette.id, selected_cassette.name, buyer_ckey)

		// check if user is buying their own cassette
		if(buyer_ckey == ckey(selected_cassette.author.ckey))
			if(!GLOB.self_cassette_purchases[buyer_ckey])
				GLOB.self_cassette_purchases[buyer_ckey] = 0
			GLOB.self_cassette_purchases[buyer_ckey]++

			var/purchase_count = GLOB.self_cassette_purchases[buyer_ckey]
			if(purchase_count == 5)
				message_admins("[key_name_admin(user)] has bought their own cassette tape five times! Although manipulating the rankings is very unlikely, looking into it may be necessary if user is actively attempting to mess with the filters.")
			else if(purchase_count == 10)
				message_admins("[key_name_admin(user)] might be attempting to mess with the cassette rankings. They've purchased their own cassette ten times!")

	busy = TRUE
	balloon_alert(user, "printing cassette...")
	playsound(src, 'sound/machines/terminal_processing.ogg', 50, TRUE)

	addtimer(CALLBACK(src, PROC_REF(finish_printing), selected_cassette, user), 2 SECONDS)

	return TRUE

/obj/machinery/cassette_library/proc/finish_printing(datum/cassette/cassette, mob/user)
	busy = FALSE

	var/obj/item/cassette_tape/new_tape = new(drop_location(), cassette.id)

	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE)
	balloon_alert(user, "cassette printed!")

	// try to put in user's hands if they're still nearby. if not, cassette will be dropped on top of the terminal
	if(isliving(user) && user.Adjacent(src))
		var/mob/living/living_user = user
		living_user.put_in_hands(new_tape)

/// soul-crushing global proc for sorting cassettes by ID descending
/proc/cmp_cassette_id_dsc(datum/cassette/a, datum/cassette/b)
	return sorttext(b.id, a.id)
