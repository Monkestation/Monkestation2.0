/* Police tape!
 */

/obj/item/barrier_tape
	name = "barrier tape roll"
	icon = 'icons/obj/structures/barriertape.dmi'
	icon_state = "tape"
	abstract_type = /obj/item/barrier_tape
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 50
	var/turf/start
	var/tape_type = /obj/structure/barrier_tape
	var/placing = FALSE
	var/datum/beam/tether
	var/place_distance = 5

/obj/item/barrier_tape/update_overlays()
	. = ..()
	if(ismob(loc))
		. += mutable_appearance(icon, placing ? "stop" : "start", appearance_flags = RESET_COLOR|KEEP_APART)

/obj/item/barrier_tape/Destroy(force)
	. = ..()
	QDEL_NULL(tether)

/obj/item/barrier_tape/dropped(mob/user, silent)
	. = ..()
	cancel_place()

/obj/item/barrier_tape/pickup(mob/user)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/barrier_tape/attack_hand(mob/user, list/modifiers)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/barrier_tape/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/machinery/door))
		var/turf/T = get_turf(interacting_with)
		var/obj/structure/barrier_tape/P = new tape_type(T)
		update_appearance(UPDATE_ICON)
		P.layer = ABOVE_ALL_MOB_LAYER + 0.1
		to_chat(user, span_notice("You finish placing [src]."))
		return ITEM_INTERACT_SUCCESS

/obj/item/barrier_tape/attack_self(mob/user, modifiers)
	. = ..()

	if(!placing)
		if(!do_after(user, 1 SECONDS, src))
			return FALSE

		start = get_turf(src)
		to_chat(user, span_notice("You place the first end of [src]."))
		placing = TRUE
		update_appearance(UPDATE_ICON)
		tether = start.Beam(
			user,
			icon_state = "tape_v_0",
			icon = 'icons/obj/structures/barriertape.dmi',
			maxdistance = place_distance,
			beam_color = color
		)
		RegisterSignal(tether, COMSIG_QDELETING, PROC_REF(cancel_place))
	else
		var/turf/end = get_turf(src)
		if(start == end)
			cancel_place()
			return TRUE

		if(start.y != end.y && start.x != end.x || start.z != end.z)
			to_chat(user, span_notice("[src] can only be laid horizontally or vertically."))
			return

		var/turf/current_turf = start
		var/midsection_dir = 0
		var/creation_dir = get_dir(start, end)
		if(start.x == end.x)
			var/d = end.y-start.y
			if(d)
				d = d/abs(d)
			midsection_dir = NORTH + SOUTH
		else
			var/d = end.x-start.x
			if(d)
				d = d/abs(d)
			midsection_dir = EAST + WEST

		var/can_place = TRUE
		while(can_place)
			if(current_turf.density || istype(current_turf, /turf/open/space))
				can_place = FALSE
			else
				for(var/obj/O in current_turf)
					if(!istype(O, /obj/structure/barrier_tape) && O.density)
						can_place = FALSE
						break
			if(current_turf == end)
				break
			current_turf = get_step_towards(current_turf,end)

		if(!can_place)
			to_chat(user, span_notice("You can't run \the [src] through that!"))
			return

		if(!do_after(user, 3 SECONDS, src))
			return FALSE

		current_turf = start
		var/existing_tape = FALSE
		while(TRUE)
			var/using_dir
			if(current_turf == start)
				using_dir = creation_dir
			else if(current_turf == end)
				using_dir = turn(creation_dir, 180)
			else
				using_dir = midsection_dir
			for(var/obj/structure/barrier_tape/tape_on_turf in current_turf)
				if(tape_on_turf.tape_dir == using_dir)
					existing_tape = TRUE
			if(!existing_tape)
				var/obj/structure/barrier_tape/P = new tape_type(current_turf)
				P.tape_dir = using_dir
				P.update_appearance(UPDATE_ICON)
			if(current_turf == end)
				break
			current_turf = get_step_towards(current_turf, end)
		to_chat(user, span_notice("You finish placing [src]."))

		cancel_place()

		return TRUE

/obj/item/barrier_tape/proc/cancel_place()
	if(QDELETED(tether))
		tether = null
	else
		QDEL_NULL(tether)

	start = null
	placing = FALSE
	update_appearance(UPDATE_ICON)

/obj/structure/barrier_tape
	name = "barrier tape"
	icon = 'icons/obj/structures/barriertape.dmi'
	icon_state = "tape"
	base_icon_state = "tape"
	abstract_type = /obj/structure/barrier_tape
	anchored = TRUE
	density = TRUE
	max_integrity = 1
	pass_flags_self = LETPASSTHROW
	projectile_cover = TRUE
	projectile_pass_rate = 100
	var/lifted = FALSE
	var/crumpled = FALSE
	var/tape_dir = 0
	var/detail_overlay
	var/detail_color

/obj/structure/barrier_tape/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Lift", lmb_text_combat_mode = "Tear")
	update_appearance()

/obj/structure/barrier_tape/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(density && isliving(mover)) // You Shall Not Pass!
		var/mob/living/living_mover = mover
		if(living_mover.body_position == STANDING_UP && living_mover.mob_size != MOB_SIZE_SMALL && !(HAS_TRAIT(living_mover, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(living_mover, TRAIT_VENTCRAWLER_NUDE)))
			return FALSE //If you're not laying down, or a small creature, or a ventcrawler, then no pass.
		return TRUE

/obj/structure/barrier_tape/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(density && pass_info.is_living)
		if(pass_info.can_ventcrawl && pass_info.mob_size != MOB_SIZE_SMALL)
			return FALSE
		return TRUE
	return ..()

/obj/structure/barrier_tape/update_icon_state()
	. = ..()
	//Possible directional bitflags: 0 (AIRLOCK), 1 (NORTH), 2 (SOUTH), 4 (EAST), 8 (WEST), 3 (VERTICAL), 12 (HORIZONTAL)
	var/new_state
	switch(tape_dir)
		if(0) // door
			new_state = "[base_icon_state]_door"
		if(3) // VERTICAL
			new_state = "[base_icon_state]_v"
		if(12) // HORIZONTAL
			new_state = "[base_icon_state]_h"
		else // END POINT (1|2|4|8)
			new_state = "[base_icon_state]_dir"
			dir = tape_dir
	icon_state = "[new_state]_[crumpled]"

/obj/structure/barrier_tape/update_overlays()
	. = ..()
	if(detail_overlay)
		var/new_state
		switch(tape_dir)
			if(0)
				new_state = "[base_icon_state]_door"
			if(3)
				new_state = "[base_icon_state]_v"
			if(12)
				new_state = "[base_icon_state]_h"
			else
				new_state = "[base_icon_state]_dir"
				dir = tape_dir
		var/image/detail = image(icon = src.icon, icon_state = "[new_state]_[detail_overlay]")
		detail.appearance_flags = RESET_COLOR
		detail.color = detail_color
		. += detail


/obj/structure/barrier_tape/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(user.istate & ISTATE_HARM)
		user.visible_message(span_notice("[user] tears down [src]!"))
		playsound(src, 'sound/items/poster/poster_ripped.ogg', 100, TRUE)
		atom_destruction(MELEE)
	else
		if(lifted)
			return
		user.visible_message(span_notice("[user] lifts [src], allowing passage."))
		for(var/obj/structure/barrier_tape/connected_tape in get_connected_tape())
			connected_tape.lift_tape()

/obj/structure/barrier_tape/deconstruct(disassembled)
	. = ..()
	if(prob(50))
		var/obj/effect/decal/cleanable/plastic/trash = new(drop_location())
		transfer_fingerprints_to(trash)

/obj/structure/barrier_tape/proc/lift_tape()
	lifted = TRUE
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	addtimer(CALLBACK(src, PROC_REF(drop_tape)), 2 SECONDS)

/obj/structure/barrier_tape/proc/drop_tape()
	lifted = FALSE
	density = TRUE
	layer = initial(layer)

/obj/structure/barrier_tape/proc/crumple()
	if(!crumpled)
		crumpled = TRUE
		update_appearance(UPDATE_ICON)
		name = "crumpled [name]"

// Returns a list of all tape objects connected to src, including itself.
/obj/structure/barrier_tape/proc/get_connected_tape()
	var/list/dirs = list()
	if(tape_dir & NORTH)
		dirs += NORTH
	if(tape_dir & SOUTH)
		dirs += SOUTH
	if(tape_dir & WEST)
		dirs += WEST
	if(tape_dir & EAST)
		dirs += EAST

	var/list/obj/structure/barrier_tape/tapeline = list()
	for (var/obj/structure/barrier_tape/T in get_turf(src))
		tapeline += T
	for(var/midsection_dir in dirs)
		var/turf/current_turf = get_step(src, midsection_dir)
		var/not_found = 0
		while (!not_found)
			not_found = 1
			for (var/obj/structure/barrier_tape/T in current_turf)
				tapeline += T
				not_found = 0
			current_turf = get_step(current_turf, midsection_dir)
	return tapeline

/obj/item/barrier_tape/security
	name = "security tape"
	desc = "A roll of security tape used to block off restricted areas."
	tape_type = /obj/structure/barrier_tape/security
	color = COLOR_YELLOW


/obj/structure/barrier_tape/security
	name = "security tape"
	desc = "A length of security tape. Do not cross."
	color = COLOR_YELLOW

