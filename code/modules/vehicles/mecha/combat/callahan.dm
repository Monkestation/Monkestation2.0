/obj/vehicle/sealed/mecha/callahan
	desc = "The pride of the Caovish navy, named after the first archon of the Warden empire. For some unknown reason, NT has used ultra advanced bluespace tech to shrink it to station size, and roboticized it to need only 1 crew. Doom incarnate, makes heretic worms look like earth worms."
	name = "Callahan class Battleship"
	icon = 'icons/mecha/callahan.dmi'
	icon_state = "callahan"
	base_icon_state = "callahan"
	SET_BASE_PIXEL(-141, 0)
	max_integrity = 7000 // doom incarnate.
	force = 100 // ship
	movedelay = 3.5
	step_energy_drain = 5 // .5x normal drain
	bumpsmash = TRUE
	stepsound = null
	turnsound = null
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | OMNIDIRECTIONAL_ATTACKS //can't strafe bruv
	armor_type = /datum/armor/callahan //its nigh on immune to bullets, but explosives and melee will ruin it. rivetts mean even more melee vun
	internal_damage_threshold = 35 //Its old but no electronics
	wreckage = /obj/structure/mecha_wreckage/callahan
	move_resist = INFINITY
	mech_type = EXOSUIT_MODULE_BATTLESHIP
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/callahan150s,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/callahansecondary,
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

/obj/vehicle/sealed/mecha/callahan/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_horn)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_reinforce)

// better parts since TC
/obj/vehicle/sealed/mecha/callahan/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/vehicle/sealed/mecha/callahan/add_capacitor()
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_horn
	name = "Sound the Horn"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_reinforce
	name = "Reinforcements have arrived"
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
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/mech_horn/Trigger(trigger_flags) // ear rape. But lets people know theyre dead
	playsound(chassis, 'sound/vehicles/dreadnaughthorn.ogg', 250)
/datum/action/vehicle/sealed/mecha/mech_reinforce/Trigger(trigger_flags)
	playsound(chassis, 'sound/vehicles/wearebeingreinforced.ogg', 175)
