/// How many extracts a rating 1 bin holds, doubles with each rating
#define VACUUM_BASE_EXTRACT_CAPACITY 10

/// How many extracts the pack can hold, depends on its bin
/obj/item/vacuum_pack/proc/extract_capacity()
	return VACUUM_BASE_EXTRACT_CAPACITY * 2 ** (extract_bin.rating - 1)

/// The extracts sitting in the pack rn
/obj/item/vacuum_pack/proc/stored_extracts()
	. = list()
	for(var/obj/item/slime_extract/extract in contents)
		. += extract

/// Swaps the pack's matter bin with the one in your hand
/obj/item/vacuum_pack/proc/swap_extract_bin(obj/item/stock_parts/matter_bin/new_bin, mob/living/user)
	if(!user.transferItemToLoc(new_bin, src))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stock_parts/matter_bin/old_bin = extract_bin
	extract_bin = new_bin
	user.put_in_hands(old_bin)
	playsound(src, 'sound/machines/click.ogg', vol = 30, vary = TRUE)
	balloon_alert(user, "holds [extract_capacity()] extracts")
	return ITEM_INTERACT_SUCCESS

/// Yeets every stored extract at an extract fridge
/obj/item/vacuum_pack/proc/fire_extracts(obj/machinery/smartfridge/extract/fridge, mob/living/user)
	if(!can_aim_at(fridge, user, feedback = TRUE))
		return FALSE
	var/list/extracts = stored_extracts()
	if(!length(extracts))
		balloon_alert(user, "no extracts!")
		return FALSE
	user.face_atom(fridge)
	var/turf/nozzle_turf = get_turf(nozzle)
	for(var/obj/item/slime_extract/extract as anything in extracts)
		extract.forceMove(nozzle_turf)
		extract.throw_at(fridge, VACUUM_LAUNCH_RANGE, VACUUM_LAUNCH_SPEED, user)
	playsound(nozzle, 'sound/misc/moist_impact.ogg', vol = 50, vary = TRUE)
	user.visible_message(
		span_notice("[user] fires a stream of slime extracts at [fridge]."),
		span_notice("You fire [length(extracts)] extract\s at [fridge].")
	)
	return TRUE

/// Dumps the extracts into a bag, a fridge, or just onto the floor
/obj/item/vacuum_pack/proc/dump_extracts(atom/target, mob/living/user)
	var/list/extracts = stored_extracts()
	if(!length(extracts))
		balloon_alert(user, "no extracts!")
		return
	var/moved = 0
	if(target.atom_storage)
		// they're all the same size, so the first one that won't fit means none will
		for(var/obj/item/slime_extract/extract as anything in extracts)
			if(!target.atom_storage.attempt_insert(extract, user, override = TRUE))
				break
			moved++
	else if(istype(target, /obj/machinery/smartfridge/extract))
		var/obj/machinery/smartfridge/extract/fridge = target
		for(var/obj/item/slime_extract/extract as anything in extracts)
			if(fridge.take(extract))
				moved++
	else
		var/atom/dump_loc = target.get_dumping_location()
		if(isnull(dump_loc))
			return
		for(var/obj/item/slime_extract/extract as anything in extracts)
			extract.forceMove(dump_loc)
			extract.pixel_x = extract.base_pixel_x + rand(-6, 6)
			extract.pixel_y = extract.base_pixel_y + rand(-6, 6)
		moved = length(extracts)
	if(!moved)
		balloon_alert(user, "no room!")
		return
	play_ploop(src)
	balloon_alert(user, "dumped [moved] extract\s")

/obj/item/vacuum_pack/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	INVOKE_ASYNC(src, PROC_REF(take_extract), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Radial menu to grab one stored extract
/obj/item/vacuum_pack/proc/take_extract(mob/living/user)
	var/list/extracts = stored_extracts()
	if(!length(extracts))
		balloon_alert(user, "no extracts!")
		return
	var/list/count_by_type = list()
	var/list/choices = list()
	var/list/type_by_label = list()
	for(var/obj/item/slime_extract/extract as anything in extracts)
		count_by_type[extract.type]++
	for(var/extract_type in count_by_type)
		var/obj/item/slime_extract/sample = locate(extract_type) in src
		var/label = "[sample.name] ([count_by_type[extract_type]])"
		choices[label] = copy_appearance_filter_overlays(sample.appearance)
		type_by_label[label] = extract_type
	var/selection = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	if(!selection || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	var/obj/item/slime_extract/taken = locate(type_by_label[selection]) in src
	if(taken)
		user.put_in_hands(taken)

// drag_pickup cancels every drop, so mouse_drop_dragged never gets a look in
/obj/item/vacuum_pack/proc/on_mousedrop_onto(datum/source, atom/over, mob/living/user)
	SIGNAL_HANDLER
	if(ismob(over) || istype(over, /atom/movable/screen))
		return
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || !user.CanReach(over))
		return
	INVOKE_ASYNC(src, PROC_REF(dump_extracts), over, user)

#undef VACUUM_BASE_EXTRACT_CAPACITY
