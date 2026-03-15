///Chance for a ruin mail collector to start off emagged (aka eat your money)
#define RUIN_EMAG_CHANCE 5

/obj/machinery/mail_collector
	name = "mail collector"
	icon = 'icons/obj/machines/mail_machine.dmi'
	icon_state = "clockmachine"
	base_icon_state = "clockmachine"
	desc = "Automatically collects credits that would otherwise be done through mail tokens."
	max_integrity = 400
	integrity_failure = 0.75
	anchored = TRUE
	density = FALSE

	///Whether the machine's ID wire is intact, allowing you to swipe to collect money.
	var/can_collect = TRUE
	/// How long the mail collector is electrified for.
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	///Amount of money stored in the mail collector.
	var/money_collected = 0
	/// What kind of sign do we drop upon being disassembled?
	var/disassemble_result = null

/obj/machinery/mail_collector/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/mail_collector(src))
	register_context()
	if(isclosedturf(loc)) //being placed as a disassembler
		return .
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

/obj/machinery/mail_collector/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/mail_collector/examine(mob/user)
	. = ..()
	. += span_notice("It has [money_collected][MONEY_SYMBOL] saved currently.")

/obj/machinery/mail_collector/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(istype(held_item, /obj/item/card/id) && money_collected > 0)
		context[SCREENTIP_CONTEXT_LMB] = "Claim [MONEY_NAME]"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/machinery/mail_collector/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	flick_overlay_view("[base_icon_state]_hacked", 1 SECONDS)
	obj_flags |= EMAGGED

/obj/machinery/mail_collector/update_icon_state()
	. = ..()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]_broken"
		return .
	icon_state = base_icon_state
	return .

/obj/machinery/mail_collector/update_overlays()
	. = ..()
	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]_panel")
		return .
	if(machine_stat & (BROKEN|NOPOWER))
		return .
	if(money_collected)
		. += mutable_appearance(icon, "[base_icon_state]_on")
	. += emissive_appearance(icon, "[base_icon_state]_e", src, alpha = src.alpha)

/obj/machinery/mail_collector/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, money_collected))
		update_appearance(UPDATE_ICON)


/obj/machinery/mail_collector/on_set_is_operational(old_value)
	if (old_value == FALSE)
		end_processing()
		return
	begin_processing()

/obj/machinery/mail_collector/process(seconds_per_tick)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified -= seconds_per_tick

//yes, this is all taken from bouldertech.
/obj/machinery/mail_collector/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(seconds_electrified && shock(user))
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/cargo/mail_token))
		if(machine_stat & BROKEN)
			return NONE
		balloon_alert(user, "token recycled")
		flick_overlay_view("[base_icon_state]_accept", 1 SECONDS)
		adjust_money(/datum/export/mail_token::cost / 2)
		qdel(tool)
		return ITEM_INTERACT_SUCCESS
	var/obj/item/card/id/id_card = tool.GetID()
	if(isnull(id_card) || (machine_stat & BROKEN))
		return NONE

	if(money_collected <= 0)
		return ITEM_INTERACT_BLOCKING

	if(!can_collect)
		balloon_alert(user, "id card jams!")
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

/obj/machinery/mail_collector/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!is_wire_tool(attacking_item))
		return ..()
	if(!panel_open)
		balloon_alert(user, "open panel first!")
		return TRUE
	wires.interact(user)
	return TRUE

/obj/machinery/mail_collector/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, base_icon_state, base_icon_state, tool))
		update_appearance(UPDATE_ICON)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/mail_collector/welder_act(mob/living/user, obj/item/tool)
	if(user.istate & ISTATE_HARM)
		return
	if(atom_integrity >= max_integrity)
		return TRUE
	balloon_alert(user, "repairing...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume=50))
		return TRUE
	balloon_alert(user, "repaired")
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/obj/machinery/mail_collector/on_deconstruction(disassembled)
	if(disassemble_result)
		new disassemble_result(drop_location())

///Use this to update the amount of money stored as to ensure overlays is updated.
/obj/machinery/mail_collector/proc/adjust_money(money_to_adjust)
	money_collected += money_to_adjust
	update_appearance(UPDATE_ICON)

///Shocks the user, incredible!
/obj/machinery/mail_collector/proc/shock(mob/living/user)
	if(!istype(user) || machine_stat & (BROKEN|NOPOWER))
		return FALSE
	do_sparks(5, TRUE, src)
	return electrocute_mob(user, get_area(src), src, 0.7, dist_check = TRUE)

//will not update by the station as it uses get_machines_by_type, not including subtypes.
//good as a credit reward for players if you so wish.
/obj/machinery/mail_collector/ruin
	name = "ancient mail collector"
	disassemble_result = null

/obj/machinery/mail_collector/ruin/Initialize(mapload)
	. = ..()
	adjust_money(rand(200, 2000))
	if(prob(RUIN_EMAG_CHANCE)) //he he he ha
		emag_act()

/obj/machinery/mail_collector/cargo
	disassemble_result = /obj/item/wallframe/mail_collector

/obj/machinery/mail_collector/cargo/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!GLOB.cargo_union.demand_is_implemented(/datum/union_demand/automatic_mail))
		return ITEM_INTERACT_BLOCKING
	return ..()


#undef RUIN_EMAG_CHANCE

/obj/item/wallframe/mail_collector
	name = "mail collector frame"
	desc = "Used to automatically collect money from opening mail."
	icon = 'icons/obj/machines/mail_machine.dmi'
	icon_state = "clockmachine_frame"
	result_path = /obj/machinery/mail_collector/cargo
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
