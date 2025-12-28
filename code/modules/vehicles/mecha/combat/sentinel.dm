/obj/vehicle/sealed/mecha/sentinel
	desc = "A super-heavy seige walker, the Sentinel renders defenses to rubble."
	name = "\improper Sentinel"
	icon = 'icons/mecha/largetanks.dmi'
	icon_state = "sentinel"
	base_icon_state = "sentinel"
	movedelay = 5
	SET_BASE_PIXEL(-24, 0)
	max_integrity = 400
	armor_type = /datum/armor/mecha_sentinel
	max_temperature = 60000
	destruction_sleep_duration = 40
	exit_delay = 40
	encumbrance_gap = 3
	internal_damage_threshold = 25
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	wreckage = /obj/structure/mecha_wreckage/sentinel
	mecha_flags = CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE
	mech_type = EXOSUIT_MODULE_SENTINEL
	force = 45
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 0,
		MECHA_UTILITY = 5,
		MECHA_POWER = 1,
		MECHA_ARMOR = 3,
	)
	bumpsmash = TRUE

/datum/armor/mecha_sentinel
	melee = 10
	bullet = 35
	laser = 35
	energy = 35
	bomb = 55
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/sentinel/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)

// better parts since big boi
/obj/vehicle/sealed/mecha/sentinel/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/super(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	scanmod = new /obj/item/stock_parts/scanning_module/phasic(src)
	manipulator = new /obj/item/stock_parts/manipulator/pico(src)
	update_part_values()

/obj/vehicle/sealed/mecha/sentinel/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/sentinellascannon,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/sentinel/loaded/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	manipulator = new /obj/item/stock_parts/manipulator/femto(src)
	update_part_values()


/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/Trigger(trigger_flags)
	if(!..())
		return
	if(!owner.client || !chassis || !(owner in chassis.occupants))
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

/obj/vehicle/sealed/mecha/sentinel/syntinel
	desc = "A super-heavy seige walker, painted red and black, with its laser cannon swaped for a conventional one."
	name = "\improper Syndicate Sentinel"
	icon_state = "syntinel"
	base_icon_state = "syntinel"
	wreckage = /obj/structure/mecha_wreckage/syntinel
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/sentinelcannon,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
