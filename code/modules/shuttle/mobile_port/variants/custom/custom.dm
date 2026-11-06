/obj/docking_port/mobile/custom
	name = "custom shuttle"
	shuttle_id = "custom"
	launch_status = UNLAUNCHED
	/// The blueprints that created this shuttle, the only ones allowed to rechristen it
	var/datum/weakref/master_blueprint
	/// The area turfs added to the shuttle go in when they are not part of any custom area
	var/area/default_area
	/// The flight control console linked to this shuttle
	var/datum/weakref/control_console
	/// The navigation console linked to this shuttle
	var/datum/weakref/navigation_console

/obj/docking_port/mobile/custom/Initialize(mapload, list/areas)
	. = ..()
	default_area = areas[1]

/obj/docking_port/mobile/custom/Destroy(force)
	. = ..()
	qdel(default_area)

/obj/docking_port/mobile/custom/canMove()
	return ..() && (current_engine_power > 0)

/obj/docking_port/mobile/custom/get_engine_coeff(mod)
	var/thrust_ratio = ((current_engine_power + mod) * CUSTOM_ENGINE_POWER_MULTIPLIER)/(turf_count + CUSTOM_ENGINE_POWER_TURF_COUNT_OFFSET)
	var/calculated_multiplier = 2*(1-(NUM_E ** -thrust_ratio))
	return calculated_multiplier ? clamp(1/calculated_multiplier, CUSTOM_ENGINE_COEFF_MIN, CUSTOM_ENGINE_COEFF_MAX) : CUSTOM_ENGINE_COEFF_MAX
