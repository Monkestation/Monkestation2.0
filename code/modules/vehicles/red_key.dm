/obj/vehicle/ridden/red_key
	name = "red key"
	desc = "IT'S THE POLICE, OPEN UP! Requires two officers and allows you to bust down doors to enter unwilling departments."
	icon = 'icons/obj/red_key.dmi'
	icon_state = "key"
	max_integrity = 60
	armor_type = /datum/armor/red_key
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

/datum/armor/red_key
	melee = 10
	laser = 10
	fire = 60
	acid = 60

/obj/vehicle/ridden/red_key/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/red_key)

#define DAMAGE_PER_HIT 55

/obj/vehicle/ridden/red_key/Bump(atom/bumped)
	. = ..()
	if(!istype(bumped, /obj/machinery/door))
		return
	var/list/current_occupants = return_occupants()
	for(var/mob/living/current_occupant as anything in current_occupants)
		if(isnull(current_occupant.ckey))
			return
	if(length(current_occupants) < max_occupants)
		return

	var/obj/machinery/door/opening_door = bumped
	var/mob/living/driver = return_drivers()[1]
	if(opening_door.allowed(driver) && !opening_door.locked) //you're opening it anyways.
		return

	playsound(src, 'sound/effects/bang.ogg', 30, vary = TRUE)
	if(!has_gravity())
		visible_message("[driver] drives head first into [src], being sent back by the lack of gravity!")
		var/user_throwtarget = get_step(driver, get_dir(bumped, driver))
		driver.throw_at(user_throwtarget, 1, 1, force = MOVE_FORCE_STRONG)
		unbuckle_all_mobs()
		return

	//save turf for after
	var/turf/bumped_loc = bumped.loc
	while(!QDELETED(bumped) && driver.Adjacent(bumped))
		if(!do_after(driver, rand(2 SECONDS, 4 SECONDS), opening_door, timed_action_flags = IGNORE_HELD_ITEM, icon = 'icons/obj/vehicles.dmi', iconstate = "redkey"))
			return
		playsound(src, 'sound/weapons/blastcannon.ogg', 20, vary = TRUE)
		opening_door.take_damage(DAMAGE_PER_HIT)
		opening_door.Shake(3, 3, 2 SECONDS)

	var/obj/structure/door_assembly/after_assembly = locate() in bumped_loc
	if(after_assembly)
		after_assembly.deconstruct(TRUE)

#undef DAMAGE_PER_HIT
