/obj/vehicle/sealed/mecha/devitt
	desc = "A multi hundred year old tank. Armed with a 40mm cannon, extremely energy hungry."
	name = "Devitt Mk.III"
	icon = 'icons/mecha/tanks.dmi'
	icon_state = "devitt_0_0"
	base_icon_state = "devitt"
	SET_BASE_PIXEL(-12, 0)
	max_integrity = 470 // its a hunk of steel that didnt need to be limited by mecha legs
	force = 25 // only 4 shot but since its fast it can get a bunch of hits off
	movedelay = 1.3
	step_energy_drain = 40
	bumpsmash = TRUE
	stepsound = 'sound/vehicles/driving-noise.ogg'
	turnsound = 'sound/vehicles/driving-noise.ogg'
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/devitt //its neigh on immune to bullets, but explosives and melee will ruin it.
	internal_damage_threshold = 35 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/devitt
//	max_occupants = 2 // gunner + Driver otherwise it would be OP
	mech_type = EXOSUIT_MODULE_TANK
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/light_tank_cannon,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lighttankmg,
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

/datum/armor/devitt
	melee = -30
	bullet = 65
	laser = 65
	energy = 65
	bomb = -30
	fire = 90
	acid = 0

/obj/vehicle/sealed/mecha/devitt/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		for(var/mob/living/carbon/human/future_pancake in loc)
			run_over(future_pancake)

/obj/vehicle/sealed/mecha/devitt/proc/run_over(mob/living/carbon/human/crushed)
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


/obj/vehicle/sealed/mecha/devitt/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)

// better parts since TC
/obj/vehicle/sealed/mecha/devitt/add_cell()
	cell = new /obj/item/stock_parts/cell/super(src)

/obj/vehicle/sealed/mecha/devitt/add_capacitor()
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)

// trying to add multi crew 2, deisel boogaloo
// yes I am just ripping this from the savannah ivanov how did you know?

/obj/vehicle/sealed/mecha/devitt/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	return "[base_icon_state]_[gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/devitt/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/devitt/generate_actions()
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

/obj/vehicle/sealed/mecha/devitt/caine
	desc = "Modified with a Caine mortar, this tank can comitt indirect strikes."
	name = "Devitt-Caine Mk.IV MMR"
	icon = 'icons/mecha/tanks.dmi'
	icon_state = "devittcaine_0_0"
	base_icon_state = "devittcaine"
	SET_BASE_PIXEL(-12, 0)
	max_integrity = 370 // you took the indirect variant, better not get into a fight
	force = 25 // only 4 shot but since its fast it can get a bunch of hits off
	movedelay = 1.45 // slightly slower, mortar turret bigger and heavier
	step_energy_drain = 40
	bumpsmash = TRUE
	wreckage = /obj/structure/mecha_wreckage/devittcaine
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lighttankmg,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(/obj/item/mecha_parts/mecha_equipment/generator),
		MECHA_ARMOR = list(),
	)
/obj/vehicle/sealed/mecha/devitt/caine/generate_actions()
		initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/mortar, VEHICLE_CONTROL_EQUIPMENT)
		. = ..()
// also ripped from savannah ivanov, bless the person who made that thing.
/datum/action/vehicle/sealed/mecha/mortar
	name = "Caine Mortar"
	button_icon_state = "mech_ivanov"
	///cooldown time between strike uses
	var/strike_cooldown_time = 5 SECONDS
	///how many rockets can we send with ivanov strike
	var/rockets_left = 0
	var/aiming_missile = FALSE

/datum/action/vehicle/sealed/mecha/mortar/Destroy()
	if(aiming_missile)
		end_missile_targeting()
	return ..()

/datum/action/vehicle/sealed/mecha/mortar/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(TIMER_COOLDOWN_CHECK(chassis, COOLDOWN_MECHA_MISSILE_STRIKE))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_MISSILE_STRIKE)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before firing mortar shell."))
		return
	if(aiming_missile)
		end_missile_targeting()
	else
		start_missile_targeting()

/**
 * ## reset_button_icon
 *
 * called after an addtimer when the cooldown is finished with the ivanov strike, resets the icon
 */
/datum/action/vehicle/sealed/mecha/mortar/proc/reset_button_icon()
	button_icon_state = "mech_ivanov"
	build_all_button_icons()

/**
 * ## start_missile_targeting
 *
 * Called by the ivanov strike datum action, hooks signals into clicking to call drop_missile
 * Plus other flavor like the overlay
 */
/datum/action/vehicle/sealed/mecha/mortar/proc/start_missile_targeting()
	chassis.balloon_alert(owner, "mortar sights enabled (click to target)")
	aiming_missile = TRUE
	rockets_left = 1
	RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, PROC_REF(on_melee_click))
	RegisterSignal(chassis, COMSIG_MECHA_EQUIPMENT_CLICK, PROC_REF(on_equipment_click))
	owner.client.mouse_override_icon = 'icons/effects/mouse_pointers/supplypod_down_target.dmi'
	owner.update_mouse_pointer()
	SEND_SOUND(owner, 'sound/machines/terminal_on.ogg') //spammable so I don't want to make it audible to anyone else

/**
 * ## end_missile_targeting
 *
 * Called by the ivanov strike datum action or other actions that would end targeting
 * Unhooks signals into clicking to call drop_missile plus other flavor like the overlay
 */
/datum/action/vehicle/sealed/mecha/mortar/proc/end_missile_targeting()
	aiming_missile = FALSE
	rockets_left = 0
	UnregisterSignal(chassis, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK))
	owner.client.mouse_override_icon = null
	owner.update_mouse_pointer()

///signal called from clicking with no equipment
/datum/action/vehicle/sealed/mecha/mortar/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(get_turf(target))

///signal called from clicking with equipment
/datum/action/vehicle/sealed/mecha/mortar/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(get_turf(target))

/**
 * ## drop_missile
 *
 * Called via intercepted clicks when the missile ability is active
 * Spawns a droppod and starts the cooldown of the missile strike ability
 * arguments:
 * * target_turf: turf of the atom that was clicked on
 */
/datum/action/vehicle/sealed/mecha/mortar/proc/drop_missile(turf/target_turf)
	rockets_left--
	if(rockets_left <= 0)
		end_missile_targeting()
	SEND_SOUND(owner, 'sound/machines/triple_beep.ogg')
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MISSILE_STRIKE, strike_cooldown_time)
	podspawn(list(
		"target" = target_turf,
		"style" = STYLE_MORTAR,
		"effectMissile" = TRUE,
		"explosionSize" = list(0,1,2,2)
	))
	button_icon_state = "mech_ivanov_cooldown"
	build_all_button_icons()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/action/vehicle/sealed/mecha/mortar, reset_button_icon)), strike_cooldown_time)
