#define TANK_DISPENSER_CAPACITY 10

/obj/structure/tank_dispenser
	name = "tank dispenser"
	desc = "A simple yet bulky storage device for gas tanks. Holds up to 10 oxygen tanks and 10 plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	var/oxygentanks = TANK_DISPENSER_CAPACITY
	var/plasmatanks = TANK_DISPENSER_CAPACITY

/obj/structure/tank_dispenser/oxygen
	plasmatanks = 0

/obj/structure/tank_dispenser/plasma
	oxygentanks = 0

/obj/structure/tank_dispenser/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/tank_dispenser/update_overlays()
	. = ..()
	switch(oxygentanks)
		if(1 to 3)
			. += "oxygen-[oxygentanks]"
		if(4 to TANK_DISPENSER_CAPACITY)
			. += "oxygen-4"
	switch(plasmatanks)
		if(1 to 4)
			. += "plasma-[plasmatanks]"
		if(5 to TANK_DISPENSER_CAPACITY)
			. += "plasma-5"

/obj/structure/tank_dispenser/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/tank_dispenser/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	var/full
	if(istype(attacking_item, /obj/item/tank/internals/plasma))
		if(plasmatanks < TANK_DISPENSER_CAPACITY)
			plasmatanks++
		else
			full = TRUE
	else if(istype(attacking_item, /obj/item/tank/internals/oxygen))
		if(oxygentanks < TANK_DISPENSER_CAPACITY)
			oxygentanks++
		else
			full = TRUE
	else if(!(user.istate & ISTATE_HARM) || (attacking_item.item_flags & NOBLUDGEON))
		balloon_alert(user, "can't insert!")
		return
	else
		return ..()
	if(full)
		to_chat(user, span_notice("[src] can't hold any more of [attacking_item]."))
		return

	if(!user.transferItemToLoc(attacking_item, src))
		return
	to_chat(user, span_notice("You put [attacking_item] in [src]."))
	playsound(src.loc, 'sound/machines/gas_tanks/extin.ogg', 100, 1)
	update_appearance()

/obj/structure/tank_dispenser/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/tank_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TankDispenser", name)
		ui.open()

/obj/structure/tank_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["oxygen"] = oxygentanks
	data["plasma"] = plasmatanks

	return data

/obj/structure/tank_dispenser/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/item/tank/internals/dispensed_tank
	switch(action)
		if("plasma")
			if (plasmatanks == 0)
				return TRUE
			dispensed_tank = dispense(/obj/item/tank/internals/plasma, usr)
			plasmatanks--
		if("oxygen")
			if (oxygentanks == 0)
				return TRUE
			dispensed_tank = dispense(/obj/item/tank/internals/oxygen, usr)
			oxygentanks--

	to_chat(usr, span_notice("You take [dispensed_tank] out of [src]."))
	playsound(src.loc, 'sound/machines/gas_tanks/extout.ogg', 100, 1)

	update_appearance()
	return TRUE


/obj/structure/tank_dispenser/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		for(var/X in src)
			var/obj/item/I = X
			I.forceMove(loc)
		new /obj/item/stack/sheet/iron (loc, 2)
	qdel(src)

/obj/structure/tank_dispenser/proc/dispense(tank_type, mob/receiver)
	var/existing_tank = locate(tank_type) in src
	if (isnull(existing_tank))
		existing_tank = new tank_type
	receiver.put_in_hands(existing_tank)
	return existing_tank

#undef TANK_DISPENSER_CAPACITY
