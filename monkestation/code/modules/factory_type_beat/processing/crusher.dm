/obj/machinery/bouldertech/flatpack/crusher
	name = "crusher"
	desc = "Crushes clumps of ore into dirty dust which needs to be enriched."
	icon_state = "crusher"

	machine = /obj/item/flatpacked_machine/ore_processing/crusher
	action = "crushing"

/obj/machinery/bouldertech/flatpack/crusher/can_process_resource(obj/item/res, return_typecache = FALSE)
	var/static/list/processable_resources
	if(!length(processable_resources))
		processable_resources = typecacheof(list(
				/obj/item/processing/clumps,
			),
			only_root_path = TRUE
		)
	return return_typecache ? processable_resources : is_type_in_typecache(res, processable_resources)

/obj/machinery/bouldertech/flatpack/crusher/check_processing_resource()
	return TRUE

/obj/machinery/bouldertech/flatpack/crusher/CanAllowThrough(atom/movable/mover, border_dir)
	if(border_dir != turn_cardinal(src.dir, 90))
		return FALSE
	return ..()

/obj/machinery/bouldertech/flatpack/crusher/breakdown_exotic(obj/item/chosen_exotic)

	if(QDELETED(chosen_exotic))
		return FALSE
	if(chosen_exotic.loc != src)
		return FALSE

	if(istype(chosen_exotic, /obj/item/processing/clumps))
		var/obj/item/processing/exotic = chosen_exotic
		if(!exotic.processed_by)
			check_for_boosts()
			var/list/rejected_mats = list()
			for(var/datum/material/material as anything in exotic.custom_materials)
				var/quantity = exotic.custom_materials[material]
				if(!can_process_material(material))
					rejected_mats[material] = quantity
					continue
				var/obj/item/processing/dirty_dust/dust  = new(src)
				var/list/dust_mats = list()
				dust_mats[material] = quantity
				dust.set_custom_materials(dust_mats)
				dust.set_colors()
				src.remove_resource(dust)
			exotic.set_custom_materials(rejected_mats)

			use_energy(active_power_usage)
			if(!length(exotic.custom_materials))
				qdel(exotic)
				return TRUE
			exotic.processed_by = src
			exotic.set_colors()
		src.remove_resource(exotic)
