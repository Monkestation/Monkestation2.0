//gun that shoots paintballs
//the powercell of the gun is simply linked to the inserted paint container, players should never see the actual cell
/obj/item/gun/energy/paint_gun
	name = "Paintball Pistol"
	desc = "A gun designed to compress paint into small orbs and shoot them out at high speeds."
	can_charge = FALSE
	dead_cell = TRUE //we manage cell charge ourselves
	ammo_type = list(/obj/item/ammo_casing/energy/paint)
	///The canister currently inserted into us, effectively our magazine
	var/obj/item/paint_gun_canister/canister
	///Is our canister internal
	var/internal_canister = FALSE
	///Bitfield of what canister types we accept
	var/accepted_canisters = STANDARD_PAINT_GUN_CANISTER

/obj/item/gun/energy/paint_gun/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS) //buh
	if(internal_canister && !isdatum(canister))
		canister = (canister ? new canister(src) : new /obj/item/paint_gun_canister(src))
		canister.set_gun(src)
		set_canister(canister)
		update_appearance()

/obj/item/gun/energy/paint_gun/get_cell(atom/movable/interface, mob/user)
	return //from an outside perspective we dont have a cell

//now time for the ballistic gun magazine insertion copypasta, yay
/obj/item/gun/energy/paint_gun/attackby(obj/item/tool, mob/user, params)
	. = ..()
	if(.)
		return

	if(internal_canister || !istype(tool, /obj/item/paint_gun_canister) || !canister_checks(tool, user))
		return

	if(!canister)
		insert_canister(user, tool)
		return

	eject_canister(user, FALSE, tool)

/obj/item/gun/energy/paint_gun/proc/canister_checks(obj/item/paint_gun_canister/checked, mob/user)
	return (accepted_canisters & checked.canister_flags)

///Set our currently inserted canister and sync cell values
/obj/item/gun/energy/paint_gun/proc/set_canister(obj/item/paint_gun_canister/new_canister)
	canister = new_canister
	if(new_canister)
		cell.maxcharge = new_canister.max_paint
		cell.charge = new_canister.paint
	else
		cell.maxcharge = 0
		cell.charge = 0

///insert a canister into us
/obj/item/gun/energy/paint_gun/proc/insert_canister(mob/user, obj/item/paint_gun_canister/inserted, display_message = TRUE)
	if(user.transferItemToLoc(inserted, src))
		set_canister(inserted)
		if(display_message)
			balloon_alert(user, "canister loaded")
		//playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
		update_appearance()
		return TRUE
	else
		to_chat(user, span_warning("You cannot seem to get [src] out of your hands!"))
		return FALSE

///remove a canister from us
/obj/item/gun/energy/paint_gun/proc/eject_canister(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load)
	//playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	canister.forceMove(drop_location())
	var/obj/item/paint_gun_canister/old_canister = canister
	if(tac_load)
		if(insert_canister(user, tac_load, FALSE))
			balloon_alert(user, "canister swapped")
		else
			to_chat(user, span_warning("You dropped the old canister, but the new one doesn't fit. How embarassing."))
			set_canister(null)
	else
		set_canister(null)
	user.put_in_hands(old_canister)
	canister.update_appearance()
	if(display_message)
		balloon_alert(user, "canister unloaded")
	update_appearance()

/obj/item/gun/energy/paint_gun/shotgun
	can_select = FALSE


//need to put this somewhere else, idk where, maybe magazines
/obj/item/paint_gun_canister
	name = "Paint Canister"
	desc = "A container of pressurized paint, dont know what else you would expect."
	w_class = WEIGHT_CLASS_SMALL
	///The color of paint stored within us
	var/stored_paint_color
	///How much paint is stored within us
	var/paint = 0
	///The maximum amount of paint we can have stored
	var/max_paint = 32
	///What canister flags we have
	var/canister_flags = STANDARD_PAINT_GUN_CANISTER
	///Ref to the gun we are inserted into
	var/obj/item/gun/energy/paint_gun/gun

/obj/item/paint_gun_canister/Initialize(mapload, paint_color = COLOR_WHITE)
	stored_paint_color = paint_color
	paint = max_paint
	return ..()

/obj/item/paint_gun_canister/examine(mob/user)
	. = ..()
	. += "It currently contains [paint == 1 ? "1 unit" : "[paint] units"] of paint and has a maximum capacity of [max_paint]."

/obj/item/paint_gun_canister/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(try_fill(user, tool))
		return ITEM_INTERACT_SUCCESS

/obj/item/paint_gun_canister/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(istype(old_loc, /obj/item/gun/energy/paint_gun))
		set_gun(null)

	//we can never normally transfer from one gun to another but ill leave both here just to be safe
	if(gun != loc && istype(loc, /obj/item/gun/energy/paint_gun)) //in case something else already set
		set_gun(loc)

///set our paintgun
/obj/item/paint_gun_canister/proc/set_gun(obj/item/gun/energy/paint_gun/new_gun)
	if(new_gun == gun)
		return

	if(gun)
		UnregisterSignal(gun.cell, COMSIG_CELL_CHANGE_POWER)
	gun = new_gun
	if(new_gun)
		RegisterSignal(new_gun.cell, COMSIG_CELL_CHANGE_POWER)

///Adjust how much paint is inside us, used to make sure we stay synced with any gun powercells
/obj/item/paint_gun_canister/proc/adjust_paint(adjust_by)
	paint = clamp(paint + adjust_by, 0, max_paint)
	if(gun)
		gun.cell?.charge = paint //manually set charge so we dont recurse with signals

/obj/item/paint_gun_canister/proc/try_fill(mob/living/user, obj/item/tool)
	var/paint_needed = max_paint - paint
	if(paint_needed <= 0)
		return

	//gets set to a pointer so we dont need to duplicate code between types
	var/tool_paint_left
	var/tool_paint_color
	if(istype(tool, /obj/item/paint))
		var/obj/item/paint/bucket = tool
		if(!bucket.paintleft)
			return

		tool_paint_color = bucket.paint_color
		tool_paint_left = &bucket.paintleft
	else if(istype(tool, /obj/item/paint_gun_canister))
		var/obj/item/paint_gun_canister/canister = tool
		if(!canister.paint)
			return

		tool_paint_color = canister.stored_paint_color
		tool_paint_left = &canister.paint
	else
		return

	var/loaded_amount = min(*tool_paint_left, paint_needed)
	if(tool_paint_color != stored_paint_color)
		stored_paint_color = gradient(tool_paint_color, stored_paint_color, (paint >= loaded_amount ? loaded_amount / paint : paint / loaded_amount))
	paint += loaded_amount
	*tool_paint_left -= loaded_amount
	return loaded_amount

/obj/item/paint_gun_canister/proc/cell_power_change(obj/item/stock_parts/power_store/cell/changed)
	SIGNAL_HANDLER
	paint = changed.charge

//direct upgrade of normal canisters, simply holds more paint
/obj/item/paint_gun_canister/expanded
	name = "Bluespace Paint Canister"
	max_paint = 48
	desc = "A container using bluespace technology to fit more paint into the same small package as a standard paint canister."

//holds more paint but doesnt fit in some guns and is more bulky
/obj/item/paint_gun_canister/large
	w_class = WEIGHT_CLASS_NORMAL
	max_paint = 64
	canister_flags = LARGE_PAINT_GUN_CANISTER

/*/obj/item/paint_gun_canister/empty_magazine()
	if(paint <= 0)
		return

	var/paint_left = paint - 1
	paint = 0
	var/turf/our_turf = get_turf(src)
	if(isspaceturf(our_turf))
		return

	our_turf.add_atom_colour(stored_paint_color, WASHABLE_COLOUR_PRIORITY)
	if(paint_left <= 0)
		return
	//if we have paint left then "spill" onto adjacent tiles
	for(var/cardinal_dir in GLOB.cardinals)
		var/turf/step_turf = get_step(src, cardinal_dir)
		if(isspaceturf(step_turf))
			continue

		paint_left--
		step_turf.add_atom_colour(stored_paint_color, WASHABLE_COLOUR_PRIORITY)
		if(paint_left <= 0)
			return*/
