/obj/vehicle/sealed/mecha/semple
	desc = "A very old tank prototype from the ancient country of 'new zealand' this one appears to be a original production.. very rare.. seems to function still.."
	name = "\improper Ancient Bob Semple"
	icon = 'icons/mecha/tanks.dmi'                      // traitor one.
	icon_state = "semple_0_0"
	base_icon_state = "semple"
	max_integrity = 220 // its a hunk of steel that didnt need to be limited by mecha legs... its a bob semple..
	force = 10 // ... did i mention its a bob semple?.... its max speed was 10km an hour...
	movedelay = 5
	step_energy_drain = 30 // hey i mean... an old caterpillar tractor with steel plating shouldnt use that much energy...
	SET_BASE_PIXEL(-12, 0)
	bumpsmash = FALSE
	stepsound = 'sound/vehicles/driving-noise.ogg'
	turnsound = 'sound/vehicles/driving-noise.ogg'
	mecha_flags = IS_ENCLOSED //can't strafe bruv.. dont think you can plug a brain into a 1940's tank..
	armor_type = /datum/armor/semple //it eh... its a bob semple..
	internal_damage_threshold = 35 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/semple
	var/crushdmglower = 3
	var/crushdmgupper = 7
//	max_occupants = 2 // gunner + Driver... i mean thats just how tanks work...
	mech_type = EXOSUIT_MODULE_TANK
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/bobsemplemg,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_occupants = 2 //driver+gunner, bob semple :)
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 0,
		MECHA_POWER = 1, // you can put an engine in it, wow!
		MECHA_ARMOR = 0,
	)

/datum/armor/semple
	melee = -20
	bullet = 60
	laser = 40
	energy = 40
	bomb = -40
	fire = 60
	acid = 0

/obj/vehicle/sealed/mecha/semple/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		for(var/mob/living/carbon/human/future_pancake in loc)
			run_over(future_pancake)

/obj/vehicle/sealed/mecha/semple/proc/run_over(mob/living/carbon/human/crushed)
	log_combat(src, crushed, "run over", addition = "(DAMTYPE: [uppertext(BRUTE)])")
	crushed.visible_message(
		span_danger("[src] drives over [crushed]!"),
		span_userdanger("[src] drives over you!"),
	)

	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	var/damage = rand(crushdmglower, crushdmgupper)
	crushed.apply_damage(1 * damage, BRUTE, BODY_ZONE_HEAD)
	crushed.apply_damage(1 * damage, BRUTE, BODY_ZONE_CHEST)
	crushed.apply_damage(0.2 * damage, BRUTE, BODY_ZONE_L_LEG)
	crushed.apply_damage(0.2 * damage, BRUTE, BODY_ZONE_R_LEG)
	crushed.apply_damage(0.2 * damage, BRUTE, BODY_ZONE_L_ARM)
	crushed.apply_damage(0.2 * damage, BRUTE, BODY_ZONE_R_ARM)

	add_mob_blood(crushed)

	var/turf/below_us = get_turf(src)
	below_us.add_mob_blood(crushed)

	AddComponent(/datum/component/blood_walk, \
		blood_type = /obj/effect/decal/cleanable/blood/tracks, \
		target_dir_change = TRUE, \
		transfer_blood_dna = TRUE, \
		max_blood = 4)

// trying to add multi crew 2, deisel boogaloo
// yes I am just ripping this from the savannah ivanov how did you know?.. yes im ripping this from the devitt.. how did you know?

/obj/vehicle/sealed/mecha/semple/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	return "[base_icon_state]_[gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/semple/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/semple/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	. = ..()

/obj/vehicle/sealed/mecha/semple/maintchance
	desc = "an ancient bob semple abandoned in maintenance, most likely left here from cleaning up an attack... looks discontinued."
	name = "\improper Rusted Security Bob Semple"
	icon = 'icons/mecha/tanks.dmi'              //,maint one
	icon_state = "ntsemple_0_0"
	base_icon_state = "ntsemple"
	max_integrity = 220 // its a hunk of steel that didnt need to be limited by mecha legs... its a bob semple..
	force = 15 // ... did i mention its a bob semple?.... its max speed was 10km an hour...
	movedelay = 3
	step_energy_drain = 40 // hey i mean... an old caterpillar tractor with steel plating shouldnt use that much energy...
	mecha_flags = IS_ENCLOSED //can't strafe bruv..
	armor_type = /datum/armor/semple/maintchance //it eh... its a bob semple..
	internal_damage_threshold = 55 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/semple
//	max_occupants = 2 // gunner + Driver... i mean thats just how tanks work...
	mech_type = EXOSUIT_MODULE_TANK
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rustedbobsemplemg,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rubberbobsemplemg,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/datum/armor/semple/maintchance
	melee = -40
	bullet = 30
	laser = 50
	energy = 40
	bomb = -50
	fire = 70
	acid = 5

/obj/vehicle/sealed/mecha/semple/syndie
	desc = "a modified bob semple, featuring a non explosive 30mm cannon and modified syndicate produced quickshot machine gun."
	name = "\improper Syndicate Bob Semple"
	icon = 'icons/mecha/tanks.dmi'
	icon_state = "syndie_semple_0_0"            //special nukie one.
	base_icon_state = "syndie_semple"
	max_integrity = 420 // its a hunk of steel that didnt need to be limited by mecha legs... its a bob semple..modified by the syndicate
	force = 18 // ... did i mention its a bob semple?.... its max speed was 10km an hour...
	movedelay = 2.0
	step_energy_drain = 24 // hey i mean... an old caterpillar tractor with steel plating shouldnt use that much energy...
	mecha_flags = IS_ENCLOSED | MMI_COMPATIBLE //can't strafe bruv..the syndicate added an mmi slot..
	armor_type = /datum/armor/semple //it eh... its a bob semple..
	internal_damage_threshold = 40 //Its old.. and due to sydnicate meddling takes more damage..
	wreckage = /obj/structure/mecha_wreckage/semple/syndie
//	max_occupants = 2
	mech_type = EXOSUIT_MODULE_TANK
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/syndie_bobsemplemg,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/semple_tank_cannon,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(/obj/item/mecha_parts/mecha_equipment/generator),
		MECHA_ARMOR = list(),
	)
	max_occupants = 6 //driver+gunner, bob semple :).... very cramped!... the true nuclear experience is with the full team onboard
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 2, // the syndicate have grafted some utility port onto it.
		MECHA_POWER = 1, // you can put an engine on it.. yeah!
		MECHA_ARMOR = 1, // the syndicate modified it.
	)
