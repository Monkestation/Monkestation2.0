/obj/machinery/button/shieldwallgen
	name = "holofield switch"
	desc = "A remote switch for a holofield generator"
	icon_state= "button-warning"
	skin = "-warning"
	device_type = /obj/item/assembly/control/shieldwallgen
	req_access = list()
	id = 1

/obj/item/assembly/control/shieldwallgen
	name = "holofield controller"
	desc = "A small device used to remotely operate holofield generators."

/obj/item/assembly/control/shieldwallgen/activate()
	if(!COOLDOWN_FINISHED(src, cooldown))
		return
	COOLDOWN_START(src, cooldown, 3 SECONDS)
	for(var/obj/machinery/power/shieldwallgen/machine as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/shieldwallgen))
		if(machine.id == src.id)
			INVOKE_ASYNC(machine, TYPE_PROC_REF(/obj/machinery/power/shieldwallgen, toggle))

/obj/machinery/power/shieldwallgen/atmos
	name = "holofield generator"
	desc = "A holofield generator designed for use in ship loading bays, long since replaced by hand-held versions alongside other machinery."
	icon_state = "shield_wall_gen_atmos"
	base_icon_state = "shield_wall_gen_atmos"
	anchored = TRUE
	density = FALSE
	req_access = list()
	layer = WALL_OBJ_LAYER
	shield_type = /obj/machinery/shieldwall/atmos
	extra_range = 1

/obj/machinery/power/shieldwallgen/atmos/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)
	activate()

/obj/machinery/power/shieldwallgen/atmos/setup_field(direction)
	if(direction != dir) // Bit jank, but replacing all GLOB.cardinals stuff with a var aswell is even more jank
		return FALSE
	return ..()

/obj/machinery/power/shieldwallgen/atmos/cleanup_field(direction)
	if(direction != dir)
		return FALSE
	return ..()

/obj/machinery/power/shieldwallgen/atmos/can_connect(obj/machinery/power/shieldwallgen/gen)
	if(gen.dir != REVERSE_DIR(dir))
		return FALSE
	return ..()

/obj/machinery/shieldwall/atmos
	name = "holofield wall"
	desc = "An energy shield capable of blocking gas movement."
	icon_state = "shieldwall_atmos"
	density = FALSE
	can_atmos_pass = ATMOS_PASS_NO
	rad_insulation = RAD_LIGHT_INSULATION

/obj/machinery/shieldwall/atmos/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)
