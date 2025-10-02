#define DEFAULT_SHELF_CAPACITY 3 // Default capacity of the shelf
#define DEFAULT_SHELF_USE_DELAY 1 SECONDS // Default interaction delay of the shelf
#define DEFAULT_SHELF_VERTICAL_OFFSET 10 // Vertical pixel offset of shelving-related things. Set to 10 by default due to this leaving more of the crate on-screen to be clicked.

/obj/structure/cargo_shelf //Crate shelf port from Shiptest: https://github.com/shiptest-ss13/Shiptest/pull/2374
	name = "Cargo shelf"
	desc = "It's a shelf! For storing crates!"
	icon = 'monkestation/icons/obj/structures/shelf.dmi'
	icon_state = "shelf_base"
	density = TRUE
	anchored = TRUE
	max_integrity = 50 // Not hard to break

	var/capacity = DEFAULT_SHELF_CAPACITY
	var/use_delay = DEFAULT_SHELF_USE_DELAY
	var/list/shelf_contents

/obj/structure/cargo_shelf/debug
	capacity = 12

/obj/structure/cargo_shelf/Initialize()
	. = ..()
	shelf_contents = new/list(capacity) // Initialize our shelf's contents list, this will be used later.
	var/stack_layer // This is used to generate the sprite layering of the shelf pieces.
	var/stack_offset // This is used to generate the vertical offset of the shelf pieces.
	for(var/i in 1 to (capacity - 1))
		if(i >= 3) // If we're at or above three, we'll be on the way to going off the tile we're on. This allows mobs to be below the shelf when this happens.
			stack_layer = ABOVE_MOB_LAYER + (0.02 * i) - 0.01
		else
			stack_layer  = BELOW_OBJ_LAYER + (0.02 * i) - 0.01 // Make each shelf piece render above the last, but below the crate that should be on it.
		stack_offset = DEFAULT_SHELF_VERTICAL_OFFSET * i // Make each shelf piece physically above the last.
		overlays += image(icon = 'monkestation/icons/obj/structures/shelf.dmi', icon_state = "shelf_stack", layer = stack_layer, pixel_y = stack_offset)
	return

/obj/structure/cargo_shelf/Destroy()
	QDEL_LIST(shelf_contents)
	return ..()

/obj/structure/cargo_shelf/examine(mob/user)
	. = ..()
	. += span_notice("There are some <b>bolts</b> holding [src] together.")
	if(shelf_contents.Find(null)) // If there's an empty space in the shelf, let the examiner know.
		. += span_notice("You could <b>drag and drop</b> a crate into [src].")
	if(contents.len) // If there are any crates in the shelf, let the examiner know.
		. += span_notice("You could <b>drag and drop</b> a crate out of [src].")
		. += span_notice("[src] contains:")
		for(var/obj/structure/closet/crate/crate in shelf_contents)
			. += "	[icon2html(crate, user)] [crate]"

/obj/structure/cargo_shelf/attackby(obj/item/item, mob/living/user, params)
	if (item.tool_behaviour == TOOL_WRENCH && !(flags_1 & NODECONSTRUCT_1))
		item.play_tool_sound(src)
		if(do_after(user, 3 SECONDS, target = src))
			deconstruct(TRUE)
			return TRUE
	return ..()

/obj/structure/cargo_shelf/relay_container_resist_act(mob/living/user, obj/structure/closet/crate)
	to_chat(user, span_notice("You begin attempting to knock [crate] out of [src]"))
	if(do_after(user, 30 SECONDS, target = crate))
		if(!user || user.stat != CONSCIOUS || user.loc != crate || crate.loc != src)
			return // If the user is in a strange condition, return early.
		visible_message(span_warning("[crate] falls off of [src]!"),
						span_notice("You manage to knock [crate] free of [src]"),
						span_notice("You hear a thud."))
		crate.forceMove(drop_location()) // Drop the crate onto the shelf,
		step_rand(crate, 1) // Then try to push it somewhere.
		crate.layer = initial(crate.layer) // Reset the crate back to having the default layer, otherwise we might get strange interactions.
		crate.pixel_y = initial(crate.pixel_y) // Reset the crate back to having no offset, otherwise it will be floating.
		shelf_contents[shelf_contents.Find(crate)] = null // Remove the reference to the crate from the list.
		handle_visuals()

/obj/structure/cargo_shelf/proc/handle_visuals()
	vis_contents = contents // It really do be that shrimple.
	return

/obj/structure/cargo_shelf/proc/load(obj/structure/closet/crate/crate, mob/user)
	var/next_free = shelf_contents.Find(null) // Find the first empty slot in the shelf.
	if(!next_free) // If we don't find an empty slot, return early.
		balloon_alert(user, "shelf full!")
		return FALSE
	if(!do_after(user, use_delay, target = crate))
		return FALSE
	if(shelf_contents[next_free] != null) // If something was added during our do_after, check again if there's another slot
		next_free = shelf_contents.Find(null)
		if(shelf_contents[next_free] != null)
			return FALSE // No empty slot was found
	if(crate.opened) // If the crate is open, try to close it.
		if(!crate.close())
			return FALSE // If we fail to close it, don't load it into the shelf.
	shelf_contents[next_free] = crate // Insert a reference to the crate into the free slot.
	crate.forceMove(src) // Insert the crate into the shelf.
	crate.pixel_y = DEFAULT_SHELF_VERTICAL_OFFSET * (next_free - 1) // Adjust the vertical offset of the crate to look like it's on the shelf.
	if(next_free >= 3) // If we're at or above three, we'll be on the way to going off the tile we're on. This allows mobs to be below the crate when this happens.
		crate.layer = ABOVE_MOB_LAYER + 0.02 * (next_free - 1)
	else
		crate.layer = BELOW_OBJ_LAYER + 0.02 * (next_free - 1) // Adjust the layer of the crate to look like it's in the shelf.
	handle_visuals()
	return TRUE

/obj/structure/cargo_shelf/proc/unload(obj/structure/closet/crate/crate, mob/user, turf/unload_turf)
	if(!unload_turf)
		unload_turf = get_turf(user) // If a turf somehow isn't passed into the proc, put it at the user's feet.
	if(!unload_turf.Enter(crate)) // If moving the crate from the shelf to the desired turf would bump, don't do it! Thanks Kapu1178 for the help here. - Generic DM
		unload_turf.balloon_alert(user, "no room!")
		return FALSE
	if(do_after(user, use_delay, target = crate))
		if(!shelf_contents.Find(crate))
			return FALSE // If something has happened to the crate while we were waiting, abort!
		crate.layer = initial(crate.layer) // Reset the crate back to having the default layer, otherwise we might get strange interactions.
		crate.pixel_y = initial(crate.pixel_y) // Reset the crate back to having no offset, otherwise it will be floating.
		crate.forceMove(unload_turf)
		shelf_contents[shelf_contents.Find(crate)] = null // We do this instead of removing it from the list to preserve the order of the shelf.
		handle_visuals()
		return TRUE
	return FALSE  // If the do_after() is interrupted, return FALSE!

/obj/structure/cargo_shelf/deconstruct(disassembled = TRUE)
	var/turf/dump_turf = drop_location()
	for(var/obj/structure/closet/crate/crate in shelf_contents)
		crate.layer = initial(crate.layer) // Reset the crates back to default visual state
		crate.pixel_y = initial(crate.pixel_y)
		crate.forceMove(dump_turf)
		step(crate, pick(GLOB.alldirs)) // Shuffle the crates around as though they've fallen down.
		crate.SpinAnimation(rand(4,7), 1) // Spin the crates around a little as they fall. Randomness is applied so it doesn't look weird.
		switch(pick(1, 1, 1, 1, 2, 2, 3)) // Randomly pick whether to do nothing, open the crate, or break it open.
			if(1) // Believe it or not, this does nothing.
				EMPTY_BLOCK_GUARD
			if(2) // Open the crate!
				if(crate.open()) // Break some open, cause a little chaos.
					crate.visible_message(span_warning("[crate]'s lid falls open!"))
				else // If we somehow fail to open the crate, just break it instead!
					crate.visible_message(span_warning("[crate] falls apart!"))
					crate.deconstruct()
			if(3) // Break that crate!
				crate.visible_message(span_warning("[crate] falls apart!"))
				crate.deconstruct()
		shelf_contents[shelf_contents.Find(crate)] = null
	if(!(flags_1 & NODECONSTRUCT_1))
		density = FALSE
		var/obj/item/rack_parts/cargo_shelf/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	return ..()

/obj/structure/cargo_shelf/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!istype(arrived, /obj/structure/closet/crate))
		return
	RegisterSignal(arrived, COMSIG_MOUSEDROP_ONTO, PROC_REF(crate_unload))

/// Signal registered to the crate so we can unload it from the shelf by click dragging it, rather than being forced to click drag the shelf
/obj/structure/cargo_shelf/proc/crate_unload(atom/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || !istype(over, /turf/open))
		return
	INVOKE_ASYNC(src, PROC_REF(unload), source, user, over)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO

/obj/structure/cargo_shelf/Exited(atom/movable/gone, direction)
	UnregisterSignal(gone, COMSIG_MOUSEDROP_ONTO)
	return ..()

/obj/structure/cargo_shelf/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!length(shelf_contents) || !istype(over, /turf/open))
		return
	unload(shelf_contents[1], user, over)

/obj/structure/cargo_shelf/mouse_drop_receive(atom/movable/dropped, mob/living/user, params)
	if(!istype(dropped, /obj/structure/closet/crate))
		return
	load(dropped, user)

/obj/item/rack_parts/cargo_shelf
	name = "Cargo shelf parts"
	icon = 'monkestation/icons/obj/structures/shelf.dmi'
	icon_state = "rack_parts"
	desc = "Parts of a cargo shelf, for storing crates."

/obj/item/rack_parts/cargo_shelf/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, span_notice("You start constructing a cargo shelf..."))
	if(do_after(user, 5 SECONDS, target = user, progress=TRUE))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		var/obj/structure/cargo_shelf/R = new /obj/structure/cargo_shelf(get_turf(src))
		user.visible_message("<span class='notice'>[user] assembles \a [R].\
			</span>", span_notice("You assemble \a [R]."))
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE
