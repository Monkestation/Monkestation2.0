///Applies BROKEN flag to the first found machine on a tile
/obj/effect/mapping_helpers/broken_machine
	name = "broken machine helper"
	icon_state = "broken_machine"
	late = TRUE

/obj/effect/mapping_helpers/broken_machine/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL

	var/obj/machinery/target = locate(/obj/machinery) in loc
	if(isnull(target))
		var/area/target_area = get_area(src)
		log_mapping("[src] failed to find a machine at [AREACOORD(src)] ([target_area.type]).")
	else
		payload(target)

	return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/broken_machine/LateInitialize()
	. = ..()
	var/obj/machinery/target = locate(/obj/machinery) in loc

	if(isnull(target))
		qdel(src)
		return

	target.update_appearance()
	qdel(src)

/obj/effect/mapping_helpers/broken_machine/proc/payload(obj/machinery/airalarm/target)
	if(target.machine_stat & BROKEN)
		var/area/area = get_area(target)
		log_mapping("[src] at [AREACOORD(src)] [(area.type)] tried to break [target] but it's already broken!")
	target.set_machine_stat(target.machine_stat | BROKEN)

//Used to turn off lights with lightswitch in areas.
/obj/effect/mapping_helpers/turn_off_lights_with_lightswitch
	name = "area turned off lights helper"
	icon_state = "blocker"

/obj/effect/mapping_helpers/turn_off_lights_with_lightswitch/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
		return INITIALIZE_HINT_QDEL
	check_validity()
	return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/turn_off_lights_with_lightswitch/proc/check_validity()
	var/area/needed_area = get_area(src)
	if(!needed_area.lightswitch)
		stack_trace("[src] at [AREACOORD(src)] [(needed_area.type)] tried to turn lights off but they are already off!")
	var/obj/machinery/light_switch/light_switch = locate(/obj/machinery/light_switch) in needed_area
	if(!light_switch)
		stack_trace("Trying to turn off lights with lightswitch in area without lightswitches. In [(needed_area.type)] to be precise.")
	needed_area.lightswitch = FALSE
