#define MAXIMUM_CONTAINER_SIZE 1000
#define REQUIRED_MOL 25

/obj/machinery/bouldertech/flatpack/chemical_injector
	name = "chemical injector"
	desc = "Splits shards and boulders when infused with brine."
	icon_state = "chemical_injection"

	machine = /obj/item/flatpacked_machine/ore_processing/chemical_injector
	refining_efficiency = 4
	action = "injecting"
	var/crystal_inside = FALSE

/obj/machinery/bouldertech/flatpack/chemical_injector/Initialize(mapload)
	. = ..()
	create_reagents(MAXIMUM_CONTAINER_SIZE, TRANSPARENT)
	AddComponent(/datum/component/plumbing/chemical_injector_brine)

/obj/machinery/bouldertech/flatpack/chemical_injector/update_icon_state()
	. = ..()
	if(crystal_inside)
		icon_state = "chemical_injection-inject"
	else
		icon_state = "chemical_injection"

/obj/machinery/bouldertech/flatpack/chemical_injector/update_overlays()
	. = ..()
	if(crystal_inside)
		. += mutable_appearance(icon, "chemical_injection-crystal")

/obj/machinery/bouldertech/flatpack/chemical_injector/can_process_resource(obj/item/res, return_typecache = FALSE)
	var/static/list/processable_resources
	if(!length(processable_resources))
		processable_resources = typecacheof(list(
			/obj/item/boulder,
			/obj/item/boulder/artifact,
			/obj/item/processing/crystals,
			),
			only_root_path = TRUE
		)
	return return_typecache ? processable_resources : is_type_in_typecache(res, processable_resources)

//obj/machinery/bouldertech/flatpack/chemical_injector/multitool_act(mob/living/user, obj/item/multitool/multitool)
//	if(!panel_open)
//		balloon_alert(user, "open panel!")
//		return TOOL_ACT_TOOLTYPE_SUCCESS

	//var/list/possible_pipes = src.GetComponents(/datum/component/plumbing/chemical_injector_brine)

	//piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
	//to_chat(user, span_notice("You change the circuitboard to layer [piping_layer]."))
	//update_appearance()
	//return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/bouldertech/flatpack/chemical_injector/CanAllowThrough(atom/movable/mover, border_dir)
	if(border_dir != turn_cardinal(src.dir, 90))
		return FALSE
	return ..()

/obj/machinery/bouldertech/flatpack/chemical_injector/breakdown_boulder(obj/item/boulder/chosen_boulder)

	if(QDELETED(chosen_boulder))
		return FALSE
	if(chosen_boulder.loc != src)
		return FALSE

	if(crystal_inside)
		return TRUE
	if(!reagents.has_reagent(/datum/reagent/brine, REQUIRED_MOL))
		return TRUE

	if(chosen_boulder.durability > 0)
		chosen_boulder.durability -= 1
		reagents.remove_reagent(/datum/reagent/brine, REQUIRED_MOL)
		if(chosen_boulder.durability > 0)
			return FALSE

	//if boulders are kept inside because there is no space to eject them, then they could be reprocessed, lets avoid that
	if(!chosen_boulder.processed_by)
		check_for_boosts()
		var/obj/item/processing/shards/shards  = new(src)
		shards.custom_materials = list()
		for(var/datum/material/material as anything in chosen_boulder.custom_materials)
			if(!can_process_material(material))
				continue
			var/quantity = chosen_boulder.custom_materials[material]
			shards.custom_materials += material
			shards.custom_materials[material] = quantity * refining_efficiency
			chosen_boulder.custom_materials -= material

		if(!isnull(shards) && !length(shards.custom_materials))
			qdel(shards)

		shards.set_colors()
		src.remove_resource(shards)
		if(!length(chosen_boulder.custom_materials))
			chosen_boulder.break_apart()
		else
			src.remove_resource(chosen_boulder)
		reagents.remove_reagent(/datum/reagent/brine, REQUIRED_MOL)
		return TRUE
	return FALSE

/obj/machinery/bouldertech/flatpack/chemical_injector/breakdown_exotic(obj/item/chosen_exotic)

	if(QDELETED(chosen_exotic))
		return FALSE
	if(chosen_exotic.loc != src)
		return FALSE

	if(crystal_inside)
		return TRUE
	if(!reagents.has_reagent(/datum/reagent/brine, REQUIRED_MOL))
		return TRUE

	if(istype(chosen_exotic, /obj/item/processing/crystals))
		crystal_inside = TRUE
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(process_crystal), chosen_exotic), 2.6 SECONDS)
		return TRUE

/obj/machinery/bouldertech/flatpack/chemical_injector/proc/process_crystal(obj/item/processing/crystals/crystal)
	if(QDELETED(crystal) || !crystal.processed_by)
		check_for_boosts()
		for(var/datum/material/material as anything in crystal.custom_materials)
			if(!can_process_material(material))
				continue
			var/quantity = crystal.custom_materials[material]
			var/obj/item/processing/shards/shards  = new(src)
			shards.custom_materials = list()
			shards.custom_materials += material
			shards.custom_materials[material] = quantity
			crystal.custom_materials -= material

			if(!isnull(shards) && !length(shards.custom_materials))
				qdel(shards)
				continue
			shards.set_colors()
			src.remove_resource(shards)
		if(!length(crystal.custom_materials))
			qdel(crystal)
		else
			crystal.set_colors()
			src.remove_resource(crystal)
		reagents.remove_reagent(/datum/reagent/brine, REQUIRED_MOL)
		crystal_inside = FALSE
		update_appearance()
	return

#undef MAXIMUM_CONTAINER_SIZE
#undef REQUIRED_MOL

/datum/component/plumbing/chemical_injector_brine
	demand_connects = SOUTH
	demand_color = COLOR_YELLOW
	ducting_layer = SECOND_DUCT_LAYER

/datum/component/plumbing/chemical_injector_brine/send_request(dir)
	process_request(amount = MACHINE_REAGENT_TRANSFER, reagent = /datum/reagent/brine, dir = dir)
