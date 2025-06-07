/obj/vehicle/sealed/mecha/spatha
	desc = "The Counterpart to the 85k-b Falcion, the Kraunian built Spatha features a complicated turret with a high velocity 40mm cannon, able to wreck destruction."
	name = "85K-a Spatha"
	icon = 'icons/mecha/largetanks.dmi'
	icon_state = "spatha_0_0"
	base_icon_state = "spatha"
	SET_BASE_PIXEL(-24, 0)
	max_integrity = 700 // doom incarnate.
	force = 40 // big and fast
	movedelay = 1.8 // not slow by a longshot
	step_energy_drain = 40 // 4x normal drain
	bumpsmash = TRUE
	stepsound = 'sound/vehicles/driving-noise.ogg'
	turnsound = 'sound/vehicles/driving-noise.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/spatha //its neigh on immune to bullets, but explosives and melee will ruin it. rivetts mean even more melee vun
	internal_damage_threshold = 35 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/spatha
//	max_occupants = 2 // gunner + Driver otherwise it would be OP
	mech_type = EXOSUIT_MODULE_TANK
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/hv_tank_cannon,
		MECHA_R_ARM =  /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lighttankmg,
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

/datum/armor/spatha
	melee = -40 // 1.5x susceptability to devitt
	bullet = 65
	laser = 65
	energy = 65
	bomb = -30
	fire = 90
	acid = 0

/obj/vehicle/sealed/mecha/spatha/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)

/obj/vehicle/sealed/mecha/spatha/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/vehicle/sealed/mecha/spatha/add_capacitor()
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)

// trying to add multi crew 2, deisel boogaloo
// yes I am just ripping this from the savannah ivanov how did you know?

/obj/vehicle/sealed/mecha/spatha/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	return "[base_icon_state]_[gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/spatha/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/spatha/generate_actions()
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
