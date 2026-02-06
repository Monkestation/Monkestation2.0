/obj/machinery/mail_collector
	name = "mail collector"
	icon = 'icons/obj/machines/mail_machine.dmi'
	icon_state = "clockmachine"
	base_icon_state = "clockmachine"
	desc = "Automatically collects credits that would otherwise be done through mail tokens."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	density = FALSE

	///Amount of money stored in the mail collector.
	var/money_collected = 0

/obj/machinery/mail_collector/Initialize(mapload)
	. = ..()
	register_context()
	for(var/turf/closed/wall/hung_on in dview(1, get_turf(src)))
		var/direction_to_place = get_dir(hung_on, src)
		switch(direction_to_place)
			if(NORTH)
				pixel_y -= 32
			if(SOUTH)
				pixel_y += 32
			if(WEST)
				pixel_x += 32
			if(EAST)
				pixel_x -= 32
			else
				continue
		break

/obj/machinery/mail_collector/examine(mob/user)
	. = ..()
	. += span_notice("It has [money_collected][MONEY_SYMBOL] saved currently.")

/obj/machinery/mail_collector/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	obj_flags |= EMAGGED

/obj/machinery/mail_collector/update_overlays()
	. = ..()
	if(money_collected)
		. += mutable_appearance(icon, "[base_icon_state]_on")
	. += emissive_appearance(icon, "[base_icon_state]_hacked_e", src, alpha = src.alpha)

/obj/machinery/mail_collector/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(istype(held_item, /obj/item/card/id) && money_collected > 0)
		context[SCREENTIP_CONTEXT_LMB] = "Claim [MONEY_NAME]"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

//yes, this is all taken from bouldertech.
/obj/machinery/mail_collector/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/cargo/mail_token))
		flick_overlay_view("[base_icon_state]_accept", 1 SECONDS)
		adjust_money(/datum/export/mail_token::cost / 2)
		qdel(tool)
		return ITEM_INTERACT_SUCCESS
	var/obj/item/card/id/id_card = tool.GetID()
	if(isnull(id_card))
		return NONE

	if(money_collected <= 0)
		return ITEM_INTERACT_BLOCKING

	var/amount = tgui_input_number(user, "How much money do you wish to claim? ID Balance: \
		[id_card.registered_account.account_balance], stored [MONEY_NAME]: [money_collected]", "Transfer [MONEY_NAME]", \
		max_value = money_collected, min_value = 0, round_value = 1)

	if(!Adjacent(user) || user.incapacitated())
		return ITEM_INTERACT_BLOCKING

	if(!amount)
		playsound(src, 'sound/machines/buzz-two.ogg', 30, TRUE)
		flick_overlay_view("[base_icon_state]_deny", 1 SECONDS)
		return ITEM_INTERACT_BLOCKING
	if(amount > money_collected)
		amount = money_collected

	if(obj_flags & EMAGGED)
		amount = -amount
		flick_overlay_view("[base_icon_state]_hacked", 1 SECONDS)
	else
		flick_overlay_view("[base_icon_state]_accept", 1 SECONDS)

	id_card.registered_account.adjust_money(amount, "Mail: Collections")
	adjust_money(-amount)
	playsound(src, 'sound/machines/machine_vend.ogg', 30, TRUE)
	to_chat(user, span_notice("You claim [amount][MONEY_SYMBOL] from \the [src] to [id_card]. Now has [id_card.registered_account.account_balance][MONEY_SYMBOL]."))
	flick_overlay_view("[base_icon_state]_accept", 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

///Use this to update the amount of money stored as to ensure overlays is updated.
/obj/machinery/mail_collector/proc/adjust_money(money_to_adjust)
	money_collected += money_to_adjust
	update_appearance(UPDATE_ICON)

//will not update by the station as it uses get_machines_by_type, not including subtypes.
//good as a credit reward for players if you so wish.
/obj/machinery/mail_collector/ruin
	name = "ancient mail collector"

/obj/machinery/mail_collector/ruin/Initialize(mapload)
	. = ..()
	adjust_money(rand(200, 2000))
	if(prob(5)) //he he he ha
		emag_act()
