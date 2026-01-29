/**
 * Your new favorite industrial waste magnet!
 * Accepts resoures and produces sheets of non-metalic materials.
 * When upgraded, it can hold more resoures and process more at once.
 */
/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "BR for short. Accepts resoures and refines non-metallic ores into sheets using internal chemicals. Does more than boulders but the name stuck."
	icon_state = "stacker"
	circuit = /obj/item/circuitboard/machine/refinery
	usage_sound = 'sound/machines/mining/refinery.ogg'
	points_held = 0
	action = "crushing"

/obj/machinery/bouldertech/refinery/Initialize(mapload)
	. = ..()
	silo_materials = AddComponent(
		/datum/component/remote_materials, \
		mapload, \
		force_connect = TRUE, /*Attempt to auto connect the machine to a local ore silo if one is avaliable*/ \
		mat_container_flags = MATCONTAINER_NO_INSERT \
	)

/obj/machinery/bouldertech/refinery/can_process_material(datum/material/possible_mat)
	var/static/list/processable_materials
	if(!length(processable_materials))
		processable_materials = list(
			/datum/material/glass,
			/datum/material/plasma,
			/datum/material/diamond,
			/datum/material/bluespace,
			/datum/material/bananium,
			/datum/material/plastic,
		)
	return is_type_in_list(possible_mat, processable_materials)

/obj/machinery/bouldertech/refinery/check_processing_resource() // Smelter and refinery do not need extra resources to process
	return TRUE

/obj/machinery/bouldertech/refinery/update_icon_state()
	. = ..()
	var/suffix = ""
	if(!anchored || !is_operational || (machine_stat & (BROKEN | NOPOWER)) || panel_open)
		suffix = "-off"
	icon_state ="[initial(icon_state)][suffix]"

/obj/machinery/bouldertech/refinery/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-off", initial(icon_state), tool))
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/bouldertech/refinery/can_process_resource(obj/item/res, return_typecache = FALSE)
	var/static/list/processable_resources
	if(!length(processable_resources))
		processable_resources = typecacheof(list(
			/obj/item/boulder,
			/obj/item/boulder/artifact,
			/obj/item/processing/refined_dust,
			),
			only_root_path = TRUE
		)
	return return_typecache ? processable_resources : is_type_in_typecache(res, processable_resources)

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()
	resources_held_max = 0
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		resources_held_max += bin.tier

	resources_processing_count = 0
	for(var/datum/stock_part/manipulator/manip in component_parts)
		resources_processing_count += manip.tier
	resources_processing_count = ROUND_UP((resources_processing_count / 8) * resources_held_max)

/**
 * Your other new favorite industrial waste magnet!
 * Accepts resoures and produces sheets of metalic materials.
 * When upgraded, it can hold more resoures and process more at once.
 */
/obj/machinery/bouldertech/refinery/smelter
	name = "boulder smelter"
	desc = "BS for short. Accept resoures and refines metallic ores into sheets. Does more than boulders but the name stuck."
	icon_state = "smelter"
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 3
	light_color = "#ffaf55"
	circuit = /obj/item/circuitboard/machine/smelter
	usage_sound = 'sound/machines/mining/smelter.ogg'
	action = "smelting"

/obj/machinery/bouldertech/refinery/smelter/Initialize(mapload)
	. = ..()
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/smelter/can_process_material(datum/material/possible_mat)
	var/static/list/processable_materials
	if(!length(processable_materials))
		processable_materials = list(
			/datum/material/iron,
			/datum/material/titanium,
			/datum/material/silver,
			/datum/material/gold,
			/datum/material/uranium,
		)
	return is_type_in_list(possible_mat, processable_materials)

/obj/machinery/bouldertech/refinery/smelter/set_light_on(new_value)
	if(panel_open || !anchored || !is_operational || machine_stat & (BROKEN | NOPOWER))
		new_value = FALSE
	return ..()

/obj/machinery/bouldertech/refinery/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	. = ..()
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	set_light_on(TRUE)

/obj/machinery/bouldertech/refinery/smelter/on_set_is_operational(old_value)
	set_light_on(TRUE)
