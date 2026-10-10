/// zMove flags that carry pulled and buckled things along.
#define WARPED_ROOM_MOVE_FLAGS (ZMOVE_CHECK_PULLEDBY | ZMOVE_ALLOW_BUCKLED | ZMOVE_INCLUDE_PULLED)

/// Lazylist of key color -> /datum/warped_room
GLOBAL_LIST(warped_rooms)

/// One pocket room. Every rainbow warping rune with the same key color is a door to the same room.
/datum/warped_room
	/// Slime color of the runes that open into this room.
	var/key_color
	/// The reserved block of turfs the room is loaded into.
	var/datum/turf_reservation/reservation
	/// The rune inside that leads back out.
	var/obj/effect/warped_room_exit/exit_door
	/// The doorway picture shown on the runes.
	var/obj/effect/abstract/warped_window/window
	/// Runes that open into this room.
	var/list/obj/effect/warped_rune/rainbowspace/runes = list()
	/// Weakref of everything that came in, to a weakref of the rune it came in by.
	var/list/entry_runes = list()
	/// [strength] -> /obj/effect/abstract/visual_effect
	var/alist/textures = alist()

/datum/warped_room/New(key_color)
	src.key_color = key_color
	LAZYSET(GLOB.warped_rooms, key_color, src)
	INVOKE_ASYNC(src, PROC_REF(build))

/// Loads the room template, paints it, and places the exit.
/datum/warped_room/proc/build()
	var/datum/map_template/warped_room/template = new
	reservation = SSmapping.request_turf_block_reservation(template.width, template.height, 1)
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	template.load(bottom_left)
	var/datum/slime_type/key_type = GLOB.slime_colors_to_types[key_color]
	var/turf/top_right = locate(bottom_left.x + template.width - 1, bottom_left.y + template.height - 1, bottom_left.z)
	for(var/turf/room_turf as anything in block(bottom_left, top_right))
		if(!isclosedturf(room_turf))
			paint(room_turf, 0.1)
			for(var/obj/furniture in room_turf)
				if(!iseffect(furniture) && !istype(furniture, /obj/machinery/light))
					paint(furniture, 0.5)
		else if(key_type::visual_effect)
			paint(room_turf, 1)
		else
			room_turf.add_atom_colour(color_transition_filter(key_type::rgb_code, SATURATION_OVERRIDE), FIXED_COLOUR_PRIORITY)
	// tile (4, 7) of warped_room.dmm
	var/turf/exit_turf = locate(bottom_left.x + 3, bottom_left.y + 6, bottom_left.z)
	exit_door = new(exit_turf, src)
	window = new(exit_door)
	window.show(exit_turf)
	window.show(exit_door)
	window.add_filter("rune_shape", 1, alpha_mask_filter(icon = icon('icons/obj/xenobiology/slime_rancher/warped_portal.dmi', "window_mask")))
	for(var/obj/effect/warped_rune/rainbowspace/rune as anything in runes)
		rune.open_window()

/// Tints the target toward the room's color. Strength is 0 to 1.
/datum/warped_room/proc/paint(atom/target, strength = 1)
	var/datum/slime_type/key_type = GLOB.slime_colors_to_types[key_color]
	var/effect_type = key_type::visual_effect
	if(effect_type)
		var/obj/effect/abstract/visual_effect/texture = textures[strength]
		if(!texture)
			texture = new effect_type
			texture.icon = 'icons/obj/xenobiology/slime_rancher/warped_walls.dmi'
			texture.alpha *= strength
			textures[strength] = texture
		ADD_KEEP_TOGETHER(target, REF(src))
		if(isturf(target))
			var/turf/painted_turf = target
			painted_turf.vis_contents += texture
		else
			var/atom/movable/painted_movable = target
			painted_movable.vis_contents += texture
		return
	var/list/key_rgb = rgb2num(key_type::rgb_code)
	var/list/brightness_weights = list(0.299, 0.587, 0.114)
	var/list/tint = list()
	for(var/from_channel in 1 to 3)
		for(var/to_channel in 1 to 3)
			tint += strength * brightness_weights[from_channel] * key_rgb[to_channel] / 255 + (from_channel == to_channel ? 1 - strength : 0)
	target.add_atom_colour(tint, FIXED_COLOUR_PRIORITY)

/// Returns the swirl overlay drawn on the exit rune.
/datum/warped_room/proc/swirl()
	var/datum/slime_type/key_type = GLOB.slime_colors_to_types[key_color]
	var/mutable_appearance/swirl = mutable_appearance('icons/obj/xenobiology/slime_rancher/warped_portal.dmi', key_type::visual_effect ? "swirl_[key_color]" : "swirl")
	if(!key_type::visual_effect)
		swirl.color = key_type::rgb_code
	swirl.pixel_w = -8
	swirl.pixel_z = -8
	return swirl

/// Whether this arrival on the exit rune should be sent back out.
/datum/warped_room/proc/lets_through(atom/movable/arrived, atom/old_loc, turf/door_turf)
	if(!isliving(arrived))
		return FALSE
	// only a real step in counts, or a door would yank back everyone it just spat out. get_dist counts z too, hence the z check
	if(!isturf(old_loc) || old_loc.z != door_turf.z || get_dist(old_loc, door_turf) != 1)
		return FALSE
	var/mob/living/traveler = arrived
	if((isslime(traveler) || ismonkeybasic(traveler)) && !traveler.client && !traveler.pulledby && !traveler.buckled)
		return FALSE
	return TRUE

/// Moves the traveler and anyone pulled or buckled with them into the room.
/datum/warped_room/proc/send_in(mob/living/traveler, obj/effect/warped_rune/rainbowspace/entry_rune)
	if(!exit_door || QDELETED(traveler) || QDELETED(entry_rune) || traveler.loc != entry_rune.rune_turf)
		return
	var/datum/weakref/entry_rune_ref = WEAKREF(entry_rune)
	var/atom/movable/lead = traveler.buckled || traveler
	for(var/atom/movable/party_member as anything in lead.get_z_move_affected(WARPED_ROOM_MOVE_FLAGS))
		entry_runes[WEAKREF(party_member)] = entry_rune_ref
	playsound(entry_rune, entry_rune.dir_sound, 20, TRUE)
	lead.zMove(target = get_turf(exit_door), z_move_flags = WARPED_ROOM_MOVE_FLAGS)

/// Moves the traveler out through the rune they came in by.
/datum/warped_room/proc/send_out(mob/living/traveler)
	if(!exit_door || QDELETED(traveler) || traveler.loc != exit_door.loc)
		return
	var/datum/weakref/entry_rune_ref = entry_runes[WEAKREF(traveler)]
	var/obj/effect/warped_rune/rainbowspace/way_back = entry_rune_ref?.resolve()
	if(!way_back && length(runes))
		way_back = runes[1]
	var/turf/destination = way_back?.rune_turf || get_safe_random_station_turf()
	playsound(exit_door, 'sound/effects/phasein.ogg', 20, TRUE)
	var/atom/movable/lead = traveler.buckled || traveler
	lead.zMove(target = destination, z_move_flags = WARPED_ROOM_MOVE_FLAGS)

/// Z levels this room's runes are on. If a rune is inside another room, that room's runes count too.
/datum/warped_room/proc/rune_levels(list/seen_rooms = list()) as /list
	var/list/levels = list()
	seen_rooms += src
	for(var/obj/effect/warped_rune/rainbowspace/rune as anything in runes)
		var/datum/warped_room/outer_room = get_warped_room(rune.rune_turf)
		if(!outer_room)
			levels |= rune.rune_turf.z
		else if(!(outer_room in seen_rooms))
			levels |= outer_room.rune_levels(seen_rooms)
	return levels

/// The warped room this turf is inside, or null.
/proc/get_warped_room(turf/inside) as /datum/warped_room
	var/datum/turf_reservation/reservation = SSmapping.get_reservation_from_turf(inside)
	if(!reservation)
		return null
	for(var/key_color, value in GLOB.warped_rooms)
		var/datum/warped_room/room = value
		if(room.reservation == reservation)
			return room
	return null

/datum/map_template/warped_room
	name = "Warped Room"
	mappath = "_maps/templates/warped_room.dmm"

/area/misc/warped_room
	name = "warped room"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = NOTELEPORT
	static_lighting = FALSE
	base_lighting_alpha = 255

// here be slime-dragons: nightmare rendering code below, solely bc i wanted cool masking
/obj/effect/warped_room_exit
	name = "warped rune"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "rune_rainbow"
	desc = "Walk onto this rune if you want to leave this place. You will have to leave eventually."
	move_resist = INFINITY
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The room this rune leads out of.
	var/datum/warped_room/room

/obj/effect/warped_room_exit/Initialize(mapload, datum/warped_room/room)
	. = ..()
	src.room = room
	update_appearance(UPDATE_OVERLAYS)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/warped_room_exit/update_overlays()
	. = ..()
	if(room)
		. += room.swirl()

/obj/effect/warped_room_exit/Destroy(force)
	if(room?.exit_door == src)
		room.exit_door = null
		room.window = null
	room = null
	return ..()

/obj/effect/warped_room_exit/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER
	room?.window?.show(arrived)
	if(room?.lets_through(arrived, old_loc, loc))
		addtimer(CALLBACK(room, TYPE_PROC_REF(/datum/warped_room, send_out), arrived), 0)

/obj/effect/warped_room_exit/proc/on_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	room?.window?.hide(gone)

/// The picture of a room's doorway that its rainbow runes show. One per room, shared by every rune.
/obj/effect/abstract/warped_window
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_TOGETHER
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	/// Original atom -> the copy of it shown in the window.
	var/list/copies = list()
	/// If the original sends any of these signals, we redraw its copy.
	var/static/list/refresh_signals = list(
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_ATOM_UPDATED_ICON,
		COMSIG_CARBON_APPLY_OVERLAY,
		COMSIG_CARBON_REMOVE_OVERLAY,
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
	)

/obj/effect/abstract/warped_window/Destroy(force)
	for(var/atom/original as anything in copies)
		hide(original)
	return ..()

// mask workaround bs, otherwise turfs and some mobs and such ignore the mask entirely
/obj/effect/abstract/warped_window/proc/show(atom/original)
	var/obj/effect/abstract/copy = new(src)
	copies[original] = copy
	vis_contents += copy
	RegisterSignals(original, refresh_signals, PROC_REF(refresh))
	RegisterSignal(original, COMSIG_QDELETING, PROC_REF(hide))
	refresh(original)

/// Redraws the original's copy from its current look.
/obj/effect/abstract/warped_window/proc/refresh(atom/original)
	SIGNAL_HANDLER
	var/obj/effect/abstract/copy = copies[original]
	copy.appearance = copy_appearance_filter_overlays(original.appearance, recursion = 1)
	copy.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE

/// Removes the original's copy and stops watching it.
/obj/effect/abstract/warped_window/proc/hide(atom/original)
	SIGNAL_HANDLER
	var/obj/effect/abstract/copy = copies[original]
	if(!copy)
		return
	copies -= original
	UnregisterSignal(original, refresh_signals + COMSIG_QDELETING)
	if(!QDELING(copy))
		qdel(copy)

#undef WARPED_ROOM_MOVE_FLAGS
