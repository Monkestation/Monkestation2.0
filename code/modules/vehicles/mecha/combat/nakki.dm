/obj/vehicle/sealed/mecha/nakki
	desc = "The Nakki is armed with Moray Torpedeos, combined with her top secret new invention, sonar, she can rip apart any legion fleets. For some unknown reason, NT has used ultra advanced bluespace tech to shrink it to station size, and roboticized it to need only 1 crew. A torpedo wins the elder god matchup."
	name = "Nakki Class Submarine"
	icon = 'icons/mecha/callahan.dmi'
	icon_state = "nakki"
	base_icon_state = "nakki"
	SET_BASE_PIXEL(-125, 0)
	max_integrity = 1200 // still a ship.
	force = 100 // ship
	movedelay = 2.7
	phasing_energy_drain = 5
	step_energy_drain = 5 // .5x normal drain
	phase_state = "nakki-dived"
	stepsound = null
	turnsound = null
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/callahan //its neigh on immune to bullets, but explosives and melee will ruin it. rivetts mean even more melee vun
	internal_damage_threshold = 35 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/callahan
	move_resist = INFINITY
	mech_type = EXOSUIT_MODULE_BATTLESHIP
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/torpedos,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/light_tank_cannon,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 0,
		MECHA_POWER = 0,
		MECHA_ARMOR = 0,
	)
/datum/armor/callahan
	melee = -100 // boarders will win
	bullet = 65
	laser = 65
	energy = 65
	bomb = -100 // sea mines be scary
	fire = 90
	acid = 100 // they wash the poop deck regularly

/obj/vehicle/sealed/mecha/nakki/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_sonar)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_dive)

// better parts since TC
/obj/vehicle/sealed/mecha/nakki/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/vehicle/sealed/mecha/nakki/add_capacitor()
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_sonar
	name = "Ping the Sonar (just a sound)"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_dive
	name = "Dive Submarine"
	button_icon_state = "mech_zoom_off"


/datum/action/vehicle/sealed/mecha/mech_zoom/Trigger(trigger_flags) // stolen from the marauder, give the tank a tank sight.
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	chassis.zoom_mode = !chassis.zoom_mode
	button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
	chassis.log_message("Toggled zoom mode.", LOG_MECHA)
	to_chat(owner, "[icon2html(chassis, owner)]<font color='[chassis.zoom_mode?"blue":"red"]'>Zoom mode [chassis.zoom_mode?"en":"dis"]abled.</font>")
	if(chassis.zoom_mode)
		owner.client.view_size.setTo(6.5)
		SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg', volume=50))
	else
		owner.client.view_size.resetToDefault()


/datum/action/vehicle/sealed/mecha/mech_sonar/Trigger(trigger_flags) // ear rape. sonar ping
	playsound(chassis, 'sound/mecha/nakkisonar.ogg', 250)

// the diving

/datum/action/vehicle/sealed/mecha/mech_dive/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = chassis.phasing ? "" : "phasing"
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.balloon_alert(owner, "[chassis.phasing ? "enabled" : "disabled"] diving")
	if(chassis.phasing == "phasing")
		chassis.icon_state = "nakki_dived"
		chassis.movedelay = 3.7
	else
		chassis.icon_state = "nakki"
		chassis.movedelay = 2.7
	build_all_button_icons()
