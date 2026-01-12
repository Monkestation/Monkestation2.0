/obj/machinery/mail_collector
	name = "mail collector"
	icon = 'monkestation/code/modules/blueshift/icons/punchcard.dmi'
	icon_state = "gbp_machine"
	desc = "Automatically collects money that would otherwise be done through mail tokens."
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

/obj/machinery/mail_collector/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(istype(held_item, /obj/item/card/id) && money_collected > 0)
		context[SCREENTIP_CONTEXT_LMB] = "Claim [MONEY_NAME]"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

//yes, this is all taken from bouldertech.
/obj/machinery/mail_collector/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/card/id/id_card = tool.GetID()
	if(isnull(id_card))
		return NONE

	if(money_collected <= 0)
		return ITEM_INTERACT_BLOCKING

	var/amount = tgui_input_number(user, "How much money do you wish to claim? ID Balance: \
		[id_card.registered_account.account_balance], stored [MONEY_NAME]: [money_collected]", "Transfer [MONEY_NAME]", \
		max_value = money_collected, min_value = 0, round_value = 1)

	if(!amount)
		return ITEM_INTERACT_BLOCKING
	if(amount > money_collected)
		amount = money_collected
	id_card.registered_account.adjust_money(amount, "Mail: Collections")
	money_collected = round(money_collected - amount)
	to_chat(user, span_notice("You claim [amount] mining points from \the [src] to [id_card]."))
	return ITEM_INTERACT_SUCCESS

//will not update by the station as it uses get_machines_by_type, not including subtypes.
//good as a credit reward for players if you so wish.
/obj/machinery/mail_collector/ruin
	name = "ancient mail collector"

/obj/machinery/mail_collector/ruin/Initialize(mapload)
	. = ..()
	money_collected = rand(200, 2000)
