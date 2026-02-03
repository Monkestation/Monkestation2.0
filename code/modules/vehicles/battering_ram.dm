#define TIME_BETWEEN_HITS (3 SECONDS)
#define ANIMATION_DURATION (2.5 SECONDS)
#define DAMAGE_PER_HIT 55

/obj/vehicle/ridden/battering_ram
	name = "big red key"
	desc = "IT'S THE POLICE, OPEN UP! With two officers you will bust down doors to enter unwilling departments by simply walking into them."
	icon = 'icons/obj/red_key.dmi'
	icon_state = "key"
	max_integrity = 60
	armor_type = /datum/armor/battering_ram
	density = FALSE
	max_drivers = 1
	max_occupants = 2
	max_buckled_mobs = 2
	integrity_failure = 0.5
	cover_amount = 40
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
	)

	///Callback we use to reset pixel shifting for the "ramming" animation players go through.
	var/datum/callback/undo_shift_callback

/datum/armor/battering_ram
	melee = 10
	laser = 10
	fire = 60
	acid = 60

/obj/vehicle/ridden/battering_ram/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/red_key)

/obj/vehicle/ridden/battering_ram/Destroy(force)
	undo_shift_callback = null
	return ..()

/obj/vehicle/ridden/battering_ram/Bump(atom/bumped)
	. = ..()
	if(!istype(bumped, /obj/machinery/door))
		return
	var/list/current_occupants = return_occupants().Copy()
	for(var/mob/living/current_occupant as anything in current_occupants)
		if(isnull(current_occupant.ckey))
			return

	var/mob/living/driver = return_drivers()[1]
	if(length(current_occupants) < max_occupants)
		driver.balloon_alert(driver, "needs second person!")
		return

	var/obj/machinery/door/opening_door = bumped
	if(opening_door.allowed(driver) && !opening_door.locked) //you're opening it anyways.
		return

	playsound(src, 'sound/effects/bang.ogg', 30, vary = TRUE)
	if(!has_gravity())
		visible_message(span_warning("[driver] drives head first into [src], being sent back by the lack of gravity!"))
		var/user_throwtarget = get_step(driver, get_dir(bumped, driver))
		driver.throw_at(user_throwtarget, 1, 1, force = MOVE_FORCE_STRONG)
		unbuckle_all_mobs()
		return

	//save turf for after
	var/turf/bumped_loc = bumped.loc
	while(!QDELETED(bumped) && !QDELETED(driver) && driver.Adjacent(bumped))
		move_away_from_door(bumped, current_occupants)
		if(!do_after(
			driver,
			TIME_BETWEEN_HITS,
			opening_door,
			timed_action_flags = IGNORE_HELD_ITEM,
			extra_checks = CALLBACK(src, PROC_REF(occupants_are_same), current_occupants),
			icon = 'icons/obj/vehicles.dmi',
			iconstate = "redkey",
		))
			undo_shift_callback?.Invoke(current_occupants)
			return
		playsound(src, 'sound/weapons/blastcannon.ogg', 20, vary = TRUE)
		opening_door.take_damage(DAMAGE_PER_HIT)
		opening_door.Shake(3, 3, 2 SECONDS)
		undo_shift_callback?.Invoke(current_occupants)

	undo_shift_callback?.Invoke(current_occupants)
	var/obj/structure/door_assembly/after_assembly = locate() in bumped_loc
	if(after_assembly)
		after_assembly.deconstruct(TRUE)

/obj/vehicle/ridden/battering_ram/proc/occupants_are_same(list/compared_occupants)
	var/list/current_occupants = return_occupants()
	if(length(current_occupants) < 2)
		return FALSE
	return (current_occupants[1] == compared_occupants[1] && current_occupants[2] == compared_occupants[2])

/obj/vehicle/ridden/battering_ram/proc/move_away_from_door(atom/door_moving_away_from, list/current_occupants)
	var/list/things_to_move = list(src) + current_occupants
	var/direction_to_move_towards = get_dir(door_moving_away_from, return_drivers()[1])
	switch(direction_to_move_towards)
		if(NORTH)
			for(var/atom/movable/moved as anything in things_to_move)
				animate(moved, pixel_y = moved.pixel_y + 12, ANIMATION_DURATION, LINEAR_EASING)
			undo_shift_callback = CALLBACK(src, PROC_REF(set_pixel_shift), -12, 0)
		if(SOUTH)
			for(var/atom/movable/moved as anything in things_to_move)
				animate(moved, pixel_y = moved.pixel_y - 12, ANIMATION_DURATION, LINEAR_EASING)
			undo_shift_callback = CALLBACK(src, PROC_REF(set_pixel_shift), 12, 0)
		if(EAST)
			for(var/atom/movable/moved as anything in things_to_move)
				animate(moved, pixel_x = moved.pixel_x + 12, ANIMATION_DURATION, LINEAR_EASING)
			undo_shift_callback = CALLBACK(src, PROC_REF(set_pixel_shift), 0, -12)
		if(WEST)
			for(var/atom/movable/moved as anything in things_to_move)
				animate(moved, pixel_x = moved.pixel_x - 12, ANIMATION_DURATION, LINEAR_EASING)
			undo_shift_callback = CALLBACK(src, PROC_REF(set_pixel_shift), 0, 12)
	return TRUE

/obj/vehicle/ridden/battering_ram/proc/set_pixel_shift(y_amount = 0, x_amount = 0, list/current_occupants)
	var/list/things_to_move = list(src) + current_occupants
	for(var/atom/movable/moved as anything in things_to_move)
		animate(moved, flags = ANIMATION_END_NOW)
		if(y_amount)
			moved.pixel_y = moved.pixel_y + y_amount
		if(x_amount)
			moved.pixel_x = moved.pixel_x + x_amount
	undo_shift_callback = null

#undef TIME_BETWEEN_HITS
#undef ANIMATION_DURATION
#undef DAMAGE_PER_HIT
