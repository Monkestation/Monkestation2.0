/obj/vehicle/sealed/mecha/percutio
	desc = "A variant of the Xiphos armored car, fitted with a 20mm anti tank rifle."
	name = "T5 Percutio"
	icon = 'icons/mecha/tanks.dmi'
	icon_state = "percutio_0_0"
	base_icon_state = "percutio"
	SET_BASE_PIXEL(-9, 0)
	max_integrity = 220 // its flimsy since armored car
	force = 18 // low damage, but fast af
	movedelay = 1
	step_energy_drain = 40 // still armored vehicle.
	bumpsmash = FALSE
	stepsound = 'sound/vehicles/carrev.ogg'
	turnsound = 'sound/vehicles/carrev.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/percutio //its uhhh well it does have some armor.
	internal_damage_threshold = 35 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/percutio
//	max_occupants = 2 // gunner + Driver otherwise it would be OP
	mech_type = EXOSUIT_MODULE_TANK
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/typhon,
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

/datum/armor/percutio
	melee = -10
	bullet = 35
	laser = 25
	energy = 25
	bomb = -10 // its weak, dont need -30 vals for melee and bomb
	fire = 90
	acid = 0

/obj/vehicle/sealed/mecha/percutio/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)

/obj/vehicle/sealed/mecha/percutio/add_cell()
	cell = new /obj/item/stock_parts/cell/super(src)

/obj/vehicle/sealed/mecha/percutio/add_capacitor()
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)

// trying to add multi crew 2, deisel boogaloo
// yes I am just ripping this from the savannah ivanov how did you know?

/obj/vehicle/sealed/mecha/percutio/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	return "[base_icon_state]_[gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/percutio/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/percutio/generate_actions()
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

// armored car cant bumpsmash, but I want it to run over people, ripped from the speedwagon / argonaut code
/obj/vehicle/sealed/mecha/percutio/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return

	if(!ishuman(A))
		return
	var/mob/living/carbon/human/rammed = A
	rammed.Paralyze(30)
	rammed.stamina.adjust(-30)
	rammed.apply_damage(rand(10,25), BRUTE)
	rammed.throw_at(get_edge_target_turf(A, dir), 1, 1)
	visible_message(span_danger("[src] crashes into [rammed]!"))
	playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/sealed/mecha/percutio/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(0, src))
		if(!(A in buckled_mobs))
			Bump(A)
