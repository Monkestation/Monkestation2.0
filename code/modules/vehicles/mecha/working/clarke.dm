///Lavaproof, fireproof, fast mech with low armor and higher energy consumption, cannot strafe and has an internal ore box.
/obj/vehicle/sealed/mecha/clarke
	desc = "Combining man and machine for a better, stronger engineer. Can even resist lava!"
	name = "\improper Clarke"
	icon_state = "clarke"
	base_icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 200
	movedelay = 1.25
	encumbrance_gap = 1.6
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	step_energy_drain = 15 //slightly higher energy drain since you movin those wheels FAST
	armor_type = /datum/armor/mecha_clarke
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/orebox_manager),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	wreckage = /obj/structure/mecha_wreckage/clarke
	mech_type = EXOSUIT_MODULE_CLARKE
	enter_delay = 40
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | OMNIDIRECTIONAL_ATTACKS
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	allow_diagonal_movement = FALSE
	pivot_step = TRUE

/datum/armor/mecha_clarke
	melee = 20
	bullet = 10
	laser = 20
	energy = 10
	bomb = 60
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/clarke/Initialize(mapload)
	. = ..()
	ore_box = new(src)

/obj/vehicle/sealed/mecha/clarke/atom_destruction()
	if(ore_box)
		INVOKE_ASYNC(ore_box, TYPE_PROC_REF(/obj/structure/ore_box, dump_box_contents))
	return ..()

/obj/vehicle/sealed/mecha/clarke/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_search_ruins)

//Ore Box Controls

///Special equipment for the Clarke mech, handles moving ore without giving the mech a hydraulic clamp and cargo compartment.
/obj/item/mecha_parts/mecha_equipment/orebox_manager
	name = "ore storage module"
	desc = "An automated ore box management device."
	icon = 'icons/obj/mining.dmi'
	icon_state = "bin"
	equipment_slot = MECHA_UTILITY
	detachable = FALSE

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/vehicle/sealed/mecha/mecha, attach_right = FALSE)
	. = ..()
	ADD_TRAIT(chassis, TRAIT_OREBOX_FUNCTIONAL, TRAIT_MECH_EQUIPMENT(type))

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach(atom/moveto)
	REMOVE_TRAIT(chassis, TRAIT_OREBOX_FUNCTIONAL, TRAIT_MECH_EQUIPMENT(type))
	return ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/get_snowflake_data()
	var/list/data = list("snowflake_id" = MECHA_SNOWFLAKE_ID_OREBOX_MANAGER)
	data["cargo"] = length(chassis.ore_box?.contents)
	return data

/obj/item/mecha_parts/mecha_equipment/orebox_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	if(action == "dump")
		var/obj/structure/ore_box/cached_ore_box = chassis.ore_box
		if(isnull(cached_ore_box))
			return FALSE
		cached_ore_box.dump_box_contents()
		log_message("Dumped [cached_ore_box].", LOG_MECHA)
		return TRUE

#define SEARCH_COOLDOWN (1 MINUTES)

/datum/action/vehicle/sealed/mecha/mech_search_ruins
	name = "Search for Ruins"
	button_icon_state = "mech_search_ruins"
	COOLDOWN_DECLARE(search_cooldown)

/datum/action/vehicle/sealed/mecha/mech_search_ruins/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		chassis.balloon_alert(owner, "on cooldown!")
		return
	if(!isliving(owner))
		return
	var/mob/living/living_owner = owner
	button_icon_state = "mech_search_ruins_cooldown"
	build_all_button_icons()
	COOLDOWN_START(src, search_cooldown, SEARCH_COOLDOWN)
	addtimer(VARSET_CALLBACK(src, button_icon_state, "mech_search_ruins"), SEARCH_COOLDOWN)
	addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), SEARCH_COOLDOWN)
	var/obj/pinpointed_ruin
	for(var/obj/effect/landmark/ruin/ruin_landmark as anything in GLOB.ruin_landmarks)
		if(ruin_landmark.z != chassis.z)
			continue
		if(!pinpointed_ruin || get_dist(ruin_landmark, chassis) < get_dist(pinpointed_ruin, chassis))
			pinpointed_ruin = ruin_landmark
	if(!pinpointed_ruin)
		chassis.balloon_alert(living_owner, "no ruins!")
		return
	var/datum/status_effect/agent_pinpointer/ruin_pinpointer = living_owner.apply_status_effect(/datum/status_effect/agent_pinpointer/ruin)
	ruin_pinpointer.RegisterSignal(living_owner, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/status_effect/agent_pinpointer/ruin, cancel_self))
	ruin_pinpointer.scan_target = pinpointed_ruin
	chassis.balloon_alert(living_owner, "pinpointing nearest ruin")

/datum/status_effect/agent_pinpointer/ruin
	duration = SEARCH_COOLDOWN * 0.5
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	tick_interval = 3 SECONDS
	range_fuzz_factor = 0
	minimum_range = 5
	range_mid = 20
	range_far = 50

/datum/status_effect/agent_pinpointer/ruin/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/ruin/proc/cancel_self(datum/source, atom/old_loc)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	name = "Ruin Target"
	desc = "Searching for valuables..."

#undef SEARCH_COOLDOWN
