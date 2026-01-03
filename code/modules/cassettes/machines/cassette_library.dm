/obj/machinery/cassette_library
	name = "cassette library"
	desc = "A vending machine that dispenses cassettes from the approved cassette database. Costs 100 credits per cassette."
	icon = 'icons/obj/cassettes/radio_station.dmi'
	icon_state = "postbox" // TODO: Replace with proper icon_state when available
	density = TRUE
	anchored = TRUE

	/// Currently inserted credits (holochips)
	var/stored_credits = 0
	/// Cost per cassette
	var/cassette_cost = 100
	/// Is the machine currently busy printing?
	var/busy = FALSE

/obj/machinery/cassette_library/Initialize(mapload)
	. = ..()
	register_context()

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
	// Handle holochip payment
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

	// Handle ID card payment
	if(isidcard(attacking_item))
		var/obj/item/card/id/id_card = attacking_item
		var/datum/bank_account/account = id_card.registered_account
		if(!account)
			balloon_alert(user, "no account linked!")
			return

		// Ask user how much they want to add
		var/amount = tgui_input_number(user, "How many credits do you want to add?", "Add Credits", max_value = account.account_balance)
		if(!amount || amount <= 0)
			return
		if(QDELETED(src) || QDELETED(user) || !user.Adjacent(src))
			return

		// Process the payment
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

/obj/machinery/cassette_library/ui_data(mob/user)
	var/list/data = list()
	data["stored_credits"] = stored_credits
	data["cassette_cost"] = cassette_cost
	data["busy"] = busy

	// Get all approved cassettes from the subsystem
	var/list/cassette_list = list()
	var/list/approved_cassettes = SScassettes.filtered_cassettes(status = CASSETTE_STATUS_APPROVED)

	// Sort by ID (newest first, assuming higher IDs are newer)
	var/list/sorted_cassettes = list()
	for(var/datum/cassette/cassette as anything in approved_cassettes)
		sorted_cassettes += cassette

	// Sort by ID in descending order (newest first)
	sorted_cassettes = sortTim(sorted_cassettes, GLOBAL_PROC_REF(cmp_cassette_id_dsc))

	// Convert to format for TGUI
	for(var/datum/cassette/cassette as anything in sorted_cassettes)
		cassette_list += list(list(
			"id" = cassette.id,
			"name" = cassette.name,
			"desc" = cassette.desc,
			"author_name" = cassette.author.name,
			"author_ckey" = cassette.author.ckey,
			"ref" = REF(cassette)
		))

	data["cassettes"] = cassette_list
	return data

/obj/machinery/cassette_library/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase_cassette")
			var/cassette_ref = params["cassette_ref"]
			if(!cassette_ref)
				return FALSE

			if(busy)
				balloon_alert(usr, "busy!")
				return TRUE

			// Check if user has enough credits
			if(stored_credits < cassette_cost)
				balloon_alert(usr, "insufficient credits!")
				to_chat(usr, span_warning("You need [cassette_cost] credits to purchase a cassette. You have [stored_credits] credits."))
				return TRUE

			// Find the cassette
			var/datum/cassette/selected_cassette = locate(cassette_ref)
			if(!selected_cassette || selected_cassette.status != CASSETTE_STATUS_APPROVED)
				balloon_alert(usr, "cassette not found!")
				return TRUE

			// Deduct credits
			stored_credits -= cassette_cost

			// Print the cassette
			busy = TRUE
			balloon_alert(usr, "printing cassette...")
			playsound(src, 'sound/machines/terminal_processing.ogg', 50, TRUE)

			addtimer(CALLBACK(src, PROC_REF(finish_printing), selected_cassette, usr), 2 SECONDS)

			return TRUE

	return FALSE

/obj/machinery/cassette_library/proc/finish_printing(datum/cassette/cassette, mob/user)
	busy = FALSE

	// Create the cassette tape
	var/obj/item/cassette_tape/new_tape = new(drop_location(), cassette.id)

	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE)
	balloon_alert(user, "cassette printed!")

	// Try to put in user's hands if they're still nearby
	if(user && isliving(user) && user.Adjacent(src))
		var/mob/living/living_user = user
		living_user.put_in_hands(new_tape)

/// Global proc for sorting cassettes by ID descending
/proc/cmp_cassette_id_dsc(datum/cassette/a, datum/cassette/b)
	return COMPARE_KEY(b, a, id)
