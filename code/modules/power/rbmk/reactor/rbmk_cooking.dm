/// Returns whether the reactor lid is currently hot enough to work as a griddle.
/obj/machinery/rbmk/reactor/proc/is_reactor_griddle_hot()
	return temperature >= RBMK_TEMP_RUNNING


/// Places an edible item on top of the reactor using the standard griddle interaction model.
/obj/machinery/rbmk/reactor/proc/try_add_griddled_item(obj/item/item_to_grill, mob/living/user, list/modifiers)
	if(length(griddled_objects) >= max_griddled_items)
		balloon_alert(user, "reactor top is full!")
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(item_to_grill, src, silent = FALSE))
		return ITEM_INTERACT_BLOCKING

	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		item_to_grill.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 48, -32, 32)
		item_to_grill.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 48, -32, 32)

	to_chat(user, span_notice("You place [item_to_grill] on top of [src]."))
	add_to_reactor_griddle(item_to_grill, user)
	return ITEM_INTERACT_SUCCESS


/// Registers and displays an item on the reactor lid.
/obj/machinery/rbmk/reactor/proc/add_to_reactor_griddle(obj/item/item_to_grill, mob/user)
	vis_contents += item_to_grill
	griddled_objects += item_to_grill
	item_to_grill.flags_1 |= IS_ONTOP_1
	item_to_grill.vis_flags |= VIS_INHERIT_PLANE

	SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_PLACED_ON, user)
	if(is_reactor_griddle_hot())
		SEND_SIGNAL(item_to_grill, COMSIG_ITEM_GRILL_TURNED_ON)

	RegisterSignal(item_to_grill, COMSIG_MOVABLE_MOVED, PROC_REF(on_reactor_griddle_item_moved))
	RegisterSignal(item_to_grill, COMSIG_ITEM_GRILLED, PROC_REF(on_reactor_grill_completed))
	RegisterSignal(item_to_grill, COMSIG_QDELETING, PROC_REF(remove_from_reactor_griddle))
	update_reactor_grill_audio()


/// Cleans up an item that was removed from or deleted on the reactor lid.
/obj/machinery/rbmk/reactor/proc/remove_from_reactor_griddle(obj/item/item_to_remove)
	SIGNAL_HANDLER

	item_to_remove.flags_1 &= ~IS_ONTOP_1
	item_to_remove.vis_flags &= ~VIS_INHERIT_PLANE
	griddled_objects -= item_to_remove
	vis_contents -= item_to_remove
	UnregisterSignal(item_to_remove, list(COMSIG_ITEM_GRILLED, COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	update_reactor_grill_audio()


/obj/machinery/rbmk/reactor/proc/on_reactor_griddle_item_moved(obj/item/moved_item, atom/old_loc, direction, forced)
	SIGNAL_HANDLER
	remove_from_reactor_griddle(moved_item)


/// Keeps transformed grill results on top of the reactor, matching griddle behavior.
/obj/machinery/rbmk/reactor/proc/on_reactor_grill_completed(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	add_to_reactor_griddle(grilled_result)


/obj/machinery/rbmk/reactor/proc/update_reactor_grill_audio()
	if(QDELETED(src) || !grill_loop)
		return

	if(is_reactor_griddle_hot() && length(griddled_objects))
		grill_loop.start()
	else
		grill_loop.stop()


/// Runs standard griddle processing while scaling fallback heat to the reactor core.
/obj/machinery/rbmk/reactor/proc/process_reactor_griddle(seconds_per_tick)
	var/griddle_is_hot = is_reactor_griddle_hot()

	if(griddle_is_hot != reactor_griddle_active)
		reactor_griddle_active = griddle_is_hot
		for(var/obj/item/griddled_item as anything in griddled_objects)
			SEND_SIGNAL(griddled_item, griddle_is_hot ? COMSIG_ITEM_GRILL_TURNED_ON : COMSIG_ITEM_GRILL_TURNED_OFF)
		update_reactor_grill_audio()

	if(!griddle_is_hot)
		return

	for(var/obj/item/griddled_item as anything in griddled_objects)
		if(SEND_SIGNAL(griddled_item, COMSIG_ITEM_GRILL_PROCESS, src, seconds_per_tick) & COMPONENT_HANDLED_GRILLING)
			continue

		griddled_item.fire_act(max(temperature, 1000))
		if(prob(10))
			visible_message(span_danger("[griddled_item] doesn't seem to be doing too great on [src]!"))
