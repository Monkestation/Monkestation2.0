/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger"
	base_icon_state = "recharger"
	desc = "A charging dock for energy based weaponry, PDAs, and other devices."
	circuit = /obj/item/circuitboard/machine/recharger
	pass_flags = PASSTABLE
	/// The item currently inserted into the charger
	var/obj/item/charging = null
	/// How good the capacitor is at charging the item
	var/recharge_coeff = 1
	/// Did we put power into "charging" last process()?
	var/using_power = FALSE
	/// Did we finish recharging the currently inserted item?
	var/finished_recharging = FALSE
	/// List of items that can be recharged
	var/static/list/allowed_devices = typecacheof(list(
		/obj/item/gun/energy,
		/obj/item/melee/baton/security,
		/obj/item/ammo_box/magazine/recharge,
		/obj/item/modular_computer,
		///obj/item/gun/ballistic/automatic/battle_rifle,
		/obj/item/gun/microfusion, //monkestation edit
		/obj/item/stock_parts/cell/microfusion, //monkestation edit
	))

/obj/machinery/recharger/RefreshParts()
	. = ..()
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		recharge_coeff = capacitor.tier

/obj/machinery/recharger/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return

	if(charging)
		. += {"[span_notice("\The [src] contains:")]
		[span_notice("- \A [charging].")]"}

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += span_notice("The status display reads:")
		. += span_notice("- Recharging <b>[recharge_coeff*10]%</b> cell charge per cycle.")
		if(charging)
			var/obj/item/stock_parts/cell/C = charging.get_cell()
			. += span_notice("- \The [charging]'s cell is at <b>[C.percent()]%</b>.")

/obj/machinery/recharger/proc/setCharging(new_charging)
	charging = new_charging
	if(new_charging)
		START_PROCESSING(SSmachines, src)
		update_use_power(ACTIVE_POWER_USE)
		finished_recharging = FALSE
		using_power = TRUE
		update_appearance()
	else
		update_use_power(IDLE_POWER_USE)
		using_power = FALSE
		update_appearance()

/obj/machinery/recharger/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_type_in_typecache(tool, allowed_devices))
		return NONE

	if(!anchored)
		to_chat(user, span_notice("[src] isn't connected to anything!"))
		return ITEM_INTERACT_BLOCKING
	if(charging || panel_open)
		return ITEM_INTERACT_BLOCKING

	var/area/our_area = get_area(src) //Check to make sure user's not in space doing it, and that the area got proper power.
	if(!isarea(our_area) || our_area.power_equip == 0)
		to_chat(user, span_notice("[src] blinks red as you try to insert [tool]."))
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/energy_gun = tool
		if(!energy_gun.can_charge)
			to_chat(user, span_notice("Your gun has no external power connector."))
			return ITEM_INTERACT_BLOCKING

	//MONKESTATION EDIT ADDITION
	if(istype(tool, /obj/item/gun/microfusion))
		var/obj/item/gun/microfusion/microfusion_gun = tool
		if(microfusion_gun.cell?.chargerate <= 0)
			to_chat(user, span_notice("[microfusion_gun] cannot be recharged!"))
			return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/stock_parts/cell/microfusion))
		var/obj/item/stock_parts/cell/microfusion/inserting_cell = tool
		if(inserting_cell.chargerate <= 0)
			to_chat(user, span_notice("[inserting_cell] cannot be recharged!"))
			return ITEM_INTERACT_BLOCKING
	//MONKESTATION EDIT END
	user.transferItemToLoc(tool, src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/recharger/wrench_act(mob/living/user, obj/item/tool)
	if(charging)
		to_chat(user, span_notice("Remove the charging item first!"))
		return ITEM_INTERACT_BLOCKING
	set_anchored(!anchored)
	power_change()
	to_chat(user, span_notice("You [anchored ? "attached" : "detached"] [src]."))
	tool.play_tool_sound(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/recharger/screwdriver_act(mob/living/user, obj/item/tool)
	if(!anchored || charging)
		return ITEM_INTERACT_BLOCKING
	. = default_deconstruction_screwdriver(user, base_icon_state, base_icon_state, tool)
	if(.)
		update_appearance()

/obj/machinery/recharger/crowbar_act(mob/living/user, obj/item/tool)
	return (!anchored || charging) ? ITEM_INTERACT_BLOCKING : default_deconstruction_crowbar(tool)

/obj/machinery/recharger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	add_fingerprint(user)
	if(charging)
		charging.update_appearance()
		charging.forceMove(drop_location())
		user.put_in_hands(charging)
		setCharging(null)

/obj/machinery/recharger/attack_tk(mob/user)
	if(!charging)
		return
	charging.update_appearance()
	charging.forceMove(drop_location())
	setCharging(null)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/recharger/process(seconds_per_tick)
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return PROCESS_KILL

	using_power = FALSE
	if(charging)
		var/obj/item/stock_parts/cell/C = charging.get_cell()
		if(C)
			if(C.charge < C.maxcharge)
				C.give(C.chargerate * recharge_coeff * seconds_per_tick / 2)
				use_power(active_power_usage * recharge_coeff * seconds_per_tick)
				using_power = TRUE
			update_appearance()

		if(istype(charging, /obj/item/ammo_box/magazine/recharge))
			var/obj/item/ammo_box/magazine/recharge/R = charging
			if(R.stored_ammo.len < R.max_ammo)
				R.stored_ammo += new R.ammo_type(R)
				use_power(active_power_usage * recharge_coeff * seconds_per_tick)
				using_power = TRUE
			update_appearance()
			return
		if(!using_power && !finished_recharging) //Inserted thing is at max charge/ammo, notify those around us
			finished_recharging = TRUE
			playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
			say("[charging] has finished recharging!")

	else
		return PROCESS_KILL

/obj/machinery/recharger/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	if(!(machine_stat & (NOPOWER|BROKEN)) && anchored)
		if(istype(charging,  /obj/item/gun/energy))
			var/obj/item/gun/energy/E = charging
			if(E.cell)
				E.cell.emp_act(severity)

		else if(istype(charging, /obj/item/melee/baton/security))
			var/obj/item/melee/baton/security/batong = charging
			if(batong.cell)
				batong.cell.charge = 0

/obj/machinery/recharger/update_appearance(updates)
	. = ..()
	if((machine_stat & (NOPOWER|BROKEN)) || panel_open || !anchored)
		luminosity = 0
		return
	luminosity = 1

/obj/machinery/recharger/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]-open", alpha = src.alpha)
		return

	if(!charging)
		. += mutable_appearance(icon, "[base_icon_state]-empty", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]-empty", src, alpha = src.alpha)
		return

	if(using_power)
		. += mutable_appearance(icon, "[base_icon_state]-charging", alpha = src.alpha)
		. += emissive_appearance(icon, "[base_icon_state]-charging", src, alpha = src.alpha)
		return

	. += mutable_appearance(icon, "[base_icon_state]-full", alpha = src.alpha)
	. += emissive_appearance(icon, "[base_icon_state]-full", src, alpha = src.alpha)
