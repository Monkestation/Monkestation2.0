/obj/vehicle/sealed/mecha/firebrand
	desc = "A modification of the Noble Widow, it was built to counter Colonial Legion advances by laying waste to any defense, will turn anything to ash with proper escort."
	name = "Noble Firebrand Mk.XVII"
	icon = 'icons/mecha/tanks.dmi'
	icon_state = "firebrand_0_0"
	base_icon_state = "firebrand"
	SET_BASE_PIXEL(-14, 0)
	max_integrity = 300 // relatively weak, armor saves it
	force = 15 // too slow to really hurt, why isnt it flaming?
	movedelay = 4.5
	step_energy_drain = 40
	bumpsmash = TRUE
	stepsound = 'sound/vehicles/driving-noise.ogg'
	turnsound = 'sound/vehicles/driving-noise.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/firebrand //its neigh on immune to bullets, but explosives and melee will ruin it.
	internal_damage_threshold = 35 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/firebrand
//	max_occupants = 2 // gunner + Driver otherwise it would be OP
	mech_type = EXOSUIT_MODULE_FLAMETANK
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/flamer,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(/obj/item/mecha_parts/mecha_equipment/generator),
		MECHA_ARMOR = list(),
	)
	max_occupants = 2 //driver+gunner, otherwise this thing would be gods OP
	max_equip_by_category = list(
		MECHA_UTILITY = 0,
		MECHA_POWER = 1, // you can put an engine in it, wow!
		MECHA_ARMOR = 0,
	)

/obj/vehicle/sealed/mecha/firebrand/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		for(var/mob/living/carbon/human/future_pancake in loc)
			run_over(future_pancake)

/obj/vehicle/sealed/mecha/firebrand/proc/run_over(mob/living/carbon/human/crushed)
	log_combat(src, crushed, "run over", addition = "(DAMTYPE: [uppertext(BRUTE)])")
	crushed.visible_message(
		span_danger("[src] drives over [crushed]!"),
		span_userdanger("[src] drives over you!"),
	)

	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	var/damage = rand(10, 15)
	crushed.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_HEAD)
	crushed.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_CHEST)
	crushed.apply_damage(0.25 * damage, BRUTE, BODY_ZONE_L_LEG)
	crushed.apply_damage(0.25 * damage, BRUTE, BODY_ZONE_R_LEG)
	crushed.apply_damage(0.25 * damage, BRUTE, BODY_ZONE_L_ARM)
	crushed.apply_damage(0.25 * damage, BRUTE, BODY_ZONE_R_ARM)

	add_mob_blood(crushed)

	var/turf/below_us = get_turf(src)
	below_us.add_mob_blood(crushed)


/datum/armor/firebrand
	melee = -30
	bullet = 83 // hp low, dies quick to a maniac that charges it
	laser = 95 // flame tank is heat proof, wow.
	energy = 95
	bomb = -30
	fire = 100
	acid = 20

/obj/vehicle/sealed/mecha/firebrand/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)

// better parts since TC
/obj/vehicle/sealed/mecha/firebrand/add_cell()
	cell = new /obj/item/stock_parts/cell/super(src)

/obj/vehicle/sealed/mecha/firebrand/add_capacitor()
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)

// trying to add multi crew 2, deisel boogaloo
// yes I am just ripping this from the savannah ivanov how did you know?

/obj/vehicle/sealed/mecha/firebrand/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	return "[base_icon_state]_[gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/firebrand/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/firebrand/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	. = ..()

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/Trigger(trigger_flags) // stolen from the marauder, give the tank a tank sight.
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	chassis.zoom_mode = !chassis.zoom_mode
	button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
	chassis.log_message("Toggled zoom mode.", LOG_MECHA)
	to_chat(owner, "[icon2html(chassis, owner)]<font color='[chassis.zoom_mode?"blue":"red"]'>Zoom mode [chassis.zoom_mode?"en":"dis"]abled.</font>")
	if(chassis.zoom_mode)
		owner.client.view_size.setTo(4.5)
		SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg', volume=50))
	else
		owner.client.view_size.resetToDefault()
	build_all_button_icons()
