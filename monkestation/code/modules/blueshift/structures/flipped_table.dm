/// How long the cooldown for being able to try to flip a single table is. This is meant to be an antispam measure.
#define TABLE_FLIP_ANTISPAM_COOLDOWN (0.5 SECONDS)
/// Multiplier for how long it takes to flip a table. (time = max_integrity * TABLE_FLIP_TIME_MULTIPLIER)
#define TABLE_FLIP_TIME_MULTIPLIER 0.25
/// Velocity multiplier for the objects knocked off of tables by cats.
#define CAT_VELOCITY_MULTIPLIER 2
/// How many degrees the angle of an item being knocked off of a table by a cat can vary.
#define CAT_ANGLE_VARIANCE 15
/// How long it takes a cat to knock a single item off a table.
#define CAT_KNOCK_OFF_TIME (0.5 SECONDS)
/// The ID for the cat meow cooldown. This is so meows don't overlap when knocking things off of multiple tables.
#define COOLDOWN_CAT_MEOW "cat_meow_cooldown"
/// This should be slightly higher than the longest SFX_MEOW audio file, used for the aforementioned cooldown.
#define MAX_CAT_MEOW_LENGTH (2 SECONDS)

/obj/structure/flippedtable
	name = "flipped table"
	desc = "A flipped table."
	icon = 'monkestation/code/modules/blueshift/icons/flipped_tables.dmi'
	icon_state = "table"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	opacity = FALSE
	/// type of table that this becomes when unflipped
	var/table_type = /obj/structure/table

/obj/structure/flippedtable/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	register_context()

/obj/structure/flippedtable/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(can_right_table(user, check_incapacitated = FALSE))
		context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = "Flip table upright"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/flippedtable/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(table_type == /obj/structure/table/glass) //Glass table, jolly ranchers pass
		if(istype(mover) && (mover.pass_flags & PASSGLASS))
			return TRUE
	if(istype(mover, /obj/projectile))
		var/obj/projectile/projectile = mover
		//Lets through bullets shot from behind the cover of the table
		if(projectile.trajectory && angle2dir_cardinal(projectile.trajectory.angle) == dir)
			return TRUE
		return FALSE
	if(border_dir == dir)
		return FALSE
	return TRUE

/obj/structure/flippedtable/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(table_type == /obj/structure/table/glass) //Glass table, jolly ranchers pass
		if(istype(leaving) && (leaving.pass_flags & PASSGLASS))
			return

	if(istype(leaving, /obj/projectile))
		return

	if(direction == dir)
		return COMPONENT_ATOM_BLOCK_EXIT

//prevent ghosts from unflipping tables but still allows admins to fuck around
/obj/structure/flippedtable/proc/can_right_table(mob/user, check_incapacitated = TRUE)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(user.can_hold_items())
		return TRUE
	if(is_admin(user.client))
		return TRUE
	if(check_incapacitated && user.incapacitated())
		return FALSE
	return TRUE

/obj/structure/flippedtable/CtrlShiftClick(mob/user)
	if(!can_right_table(user) || DOING_INTERACTION_WITH_TARGET(user, src) || !user.CanReach(src))
		return
	user.balloon_alert_to_viewers("flipping table upright...")
	if(do_after(user, max_integrity * TABLE_FLIP_TIME_MULTIPLIER))
		var/obj/structure/table/unflipped_table = new table_type(loc)
		unflipped_table.update_integrity(get_integrity())
		if(flags_1 & HOLOGRAM_1) // no unflipping holographic tables into reality
			var/area/station/holodeck/holo_area = get_area(unflipped_table)
			if(!istype(holo_area))
				qdel(unflipped_table)
				return
			holo_area.linked.add_to_spawned(unflipped_table)
		if(custom_materials)
			unflipped_table.set_custom_materials(custom_materials)
		user.balloon_alert_to_viewers("table flipped upright")
		playsound(src, 'sound/items/trayhit2.ogg', vol = 100)
		qdel(src)

/mob/proc/can_flip_table(obj/structure/table/table, full_checks = TRUE)
	if(QDELETED(src) || QDELETED(table))
		return FALSE
	if(!isturf(table.loc))
		return FALSE
	if(!table.can_flip)
		return FALSE
	if(is_admin(client))
		return TRUE
	return FALSE

/mob/living/can_flip_table(obj/structure/table/table, full_checks = TRUE)
	if(QDELETED(src) || QDELETED(table))
		return FALSE
	if(!isturf(table.loc))
		return FALSE
	if(!iscat(src))
		if(!table.can_flip)
			return FALSE
		if(!can_hold_items())
			return FALSE
	if(full_checks)
		if(TIMER_COOLDOWN_CHECK(src, REF(table)))
			return FALSE
		if(DOING_INTERACTION_WITH_TARGET(src, table))
			return FALSE
		if(incapacitated())
			return FALSE
		if(!CanReach(table))
			return FALSE
	return TRUE

/obj/structure/table/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	if(user.can_flip_table(src, full_checks = FALSE))
		context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = iscat(user) ? "Knock things off table" : "Flip table"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/structure/table/CtrlShiftClick(mob/user)
	if(!user.can_flip_table(src))
		return
	TIMER_COOLDOWN_START(user, REF(src), TABLE_FLIP_ANTISPAM_COOLDOWN)
	if(iscat(user))
		cat_knock_stuff_off_table(user)
	else
		user.balloon_alert_to_viewers("flipping table...")
		if(do_after(user, round(max_integrity * TABLE_FLIP_TIME_MULTIPLIER, 0.5 SECONDS), src))
			flip_table(user)

/obj/structure/table/proc/flip_table(mob/user)
	var/obj/structure/flippedtable/flipped_table = new flipped_table_type(loc)
	flipped_table.name = "flipped [initial(name)]"
	flipped_table.desc = "[initial(desc)]<br>It's been flipped on its side!"
	flipped_table.icon_state = base_icon_state
	var/new_dir = get_dir(user, flipped_table)
	flipped_table.setDir(new_dir)
	if(new_dir == NORTH)
		flipped_table.layer = BELOW_MOB_LAYER
	flipped_table.max_integrity = max_integrity
	flipped_table.update_integrity(get_integrity())
	flipped_table.table_type = type
	if(istype(src, /obj/structure/table/greyscale)) //Greyscale tables need greyscale flags!
		flipped_table.material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	if(flags_1 & HOLOGRAM_1) // no flipping holographic tables into reality
		var/area/station/holodeck/holo_area = get_area(flipped_table)
		if(!istype(holo_area))
			qdel(flipped_table)
			return
		holo_area.linked.add_to_spawned(flipped_table)
	//Finally, add the custom materials, so the flags still apply to it
	flipped_table.set_custom_materials(custom_materials)

	var/sound_volume = 100
	var/balloon_message = "table flipped"
	var/user_pacifist = HAS_TRAIT(user, TRAIT_PACIFISM)

	if (user_pacifist)
		balloon_message = "table gently flipped"
		sound_volume = 40

	user.balloon_alert_to_viewers(balloon_message)
	playsound(src, 'sound/items/trayhit2.ogg', sound_volume)
	qdel(src)

	var/turf/throw_target = get_step(flipped_table, flipped_table.dir)
	if (!isnull(throw_target) && !user_pacifist)
		for (var/atom/movable/movable_entity in flipped_table.loc)
			if (movable_entity == flipped_table)
				continue
			if (movable_entity.anchored)
				continue
			if (movable_entity.invisibility > SEE_INVISIBLE_LIVING)
				continue
			if(!ismob(movable_entity) && !isobj(movable_entity))
				continue
			if(movable_entity.throwing || (movable_entity.movement_type & (FLOATING|FLYING)))
				continue
			movable_entity.safe_throw_at(throw_target, range = 1, speed = 1, force = MOVE_FORCE_NORMAL, gentle = TRUE)

/obj/structure/table
	var/flipped_table_type = /obj/structure/flippedtable
	var/can_flip = TRUE

/obj/structure/table/rolling
	can_flip = FALSE

/obj/structure/table/wood/shuttle_bar
	can_flip = FALSE

/obj/structure/table/reinforced //It's bolted to the ground mate
	can_flip = FALSE

/obj/structure/table/optable
	can_flip = FALSE

/obj/structure/table/survival_pod
	can_flip = FALSE

// This code is prolly way too complex for literally just cats knocking shit off tables, but I'm too hyperfocused now to turn back ~Lucy

/obj/structure/table/proc/can_cat_knock_off(mob/living/cat, atom/movable/thing)
	var/static/list/valid_target_typecache = zebra_typecacheof(list(
		/obj = TRUE,
		/obj/effect = FALSE,
		/obj/projectile = FALSE,
		/mob/living = TRUE,
	))
	if(QDELETED(thing))
		return FALSE
	if(thing.loc != loc)
		return FALSE
	if(!is_type_in_typecache(thing, valid_target_typecache))
		return FALSE
	if(thing.anchored || thing.move_resist > cat.move_force)
		return FALSE
	if(thing.invisibility > SEE_INVISIBLE_LIVING)
		return FALSE
	if(thing.throwing || (thing.movement_type & (FLOATING|FLYING)))
		return FALSE
	return TRUE

// silly thing so cats can dramatically knock things off of tables
/obj/structure/table/proc/get_things_for_cat_to_knock_off(mob/living/cat)
	. = list()
	for(var/atom/movable/thing as anything in loc.contents)
		if(can_cat_knock_off(cat, thing))
			. += thing
	shuffle_inplace(.) // ensure everything gets tossed off in a random order

/obj/structure/table/proc/cat_knock_thing_off_table(mob/living/cat, atom/movable/thing)
	if(QDELETED(thing) || QDELETED(cat) || thing.loc != loc)
		return
	var/fly_angle = get_angle(src, cat) + rand(-CAT_ANGLE_VARIANCE, CAT_ANGLE_VARIANCE)
	thing.AddComponent(/datum/component/movable_physics, \
		physics_flags = MPHYSICS_QDEL_WHEN_NO_MOVEMENT, \
		angle = fly_angle, \
		horizontal_velocity = rand(2.5 * 100, 6 * 100) * CAT_VELOCITY_MULTIPLIER * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * CAT_VELOCITY_MULTIPLIER * 0.01, \
		horizontal_friction = rand(0.24 * 100, 0.3 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		horizontal_conservation_of_momentum = 0.5, \
		vertical_conservation_of_momentum = 0.5, \
		z_floor = 0, \
	)

/obj/structure/table/proc/cat_knock_stuff_off_table(mob/living/cat)
	var/list/items = get_things_for_cat_to_knock_off(cat)
	var/total_items = length(items)
	if(!total_items)
		cat.balloon_alert_to_viewers("nothing to knock off!")
		return

	cat.balloon_alert_to_viewers("knocking things off table...")
	var/datum/progressbar/progress = new(cat, total_items, src)
	outer:
		while(length(items))
			// this looks overly complex, and prolly is tbh, but the point of this is to ensure we don't waste any time on anything that was moved/deleted/whatever while we were tossing something else
			var/atom/movable/thing
			while(QDELETED(thing) && !can_cat_knock_off(cat, thing))
				if(!length(items))
					break outer
				thing = items[length(items)]
				items.len--
			if(!do_after(cat, CAT_KNOCK_OFF_TIME, src, progress = FALSE))
				break
			if(!TIMER_COOLDOWN_CHECK(cat, COOLDOWN_CAT_MEOW))
				playsound(get_turf(cat), SFX_MEOW, vol = 20, vary = TRUE, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE, mixer_channel = CHANNEL_MOB_SOUNDS)
				TIMER_COOLDOWN_START(cat, COOLDOWN_CAT_MEOW, MAX_CAT_MEOW_LENGTH)
			cat_knock_thing_off_table(cat, thing)
			if(!QDELETED(thing))
				cat.visible_message(span_warning("[cat] knocks [thing] off [src]!"))
			progress.update(total_items - length(items))
	progress.end_progress()

#undef MAX_CAT_MEOW_LENGTH
#undef COOLDOWN_CAT_MEOW
#undef CAT_KNOCK_OFF_TIME
#undef CAT_ANGLE_VARIANCE
#undef CAT_VELOCITY_MULTIPLIER
#undef TABLE_FLIP_TIME_MULTIPLIER
#undef TABLE_FLIP_ANTISPAM_COOLDOWN
