/obj/machinery/bouldertech/flatpack/enricher
	name = "enrichment chamber"
	desc = "Enriches boulders and dirty dust into dust which can then be smelted at a smelter for double the materials."
	icon_state = "enricher"

	machine = /obj/item/flatpacked_machine/ore_processing/enricher
	refining_efficiency = 2
	action = "enriching"

/obj/machinery/bouldertech/flatpack/enricher/can_process_resource(obj/item/res, return_typecache = FALSE)
	var/static/list/processable_resources
	if(!length(processable_resources))
		processable_resources = typecacheof(list(
			/obj/item/boulder,
			),
			only_root_path = TRUE
		)
	return return_typecache ? processable_resources : is_type_in_typecache(res, processable_resources)

/obj/machinery/bouldertech/flatpack/enricher/breakdown_boulder(obj/item/boulder/chosen_boulder)
	if(QDELETED(chosen_boulder))
		return FALSE
	if(chosen_boulder.loc != src)
		return FALSE

	if(chosen_boulder.durability > 0)
		chosen_boulder.durability -= 1
		if(chosen_boulder.durability > 0)
			return FALSE

	//if boulders are kept inside because there is no space to eject them, then they could be reprocessed, lets avoid that
	if(!chosen_boulder.processed_by)
		check_for_boosts()
		var/obj/item/processing/refined_dust/dust  = new(src)
		dust.custom_materials = list()
		for(var/datum/material/material as anything in chosen_boulder.custom_materials)
			var/quantity = chosen_boulder.custom_materials[material]
			dust.custom_materials += material
			dust.custom_materials[material] = quantity

		if(!isnull(dust) && !length(dust.custom_materials))
			qdel(dust)

		dust.set_colors()
		src.remove_resource(dust)
		chosen_boulder.break_apart()
		return TRUE
	return FALSE

/obj/machinery/bouldertech/flatpack/enricher/breakdown_exotic(obj/item/chosen_exotic)
	if(QDELETED(chosen_exotic))
		return FALSE
	if(chosen_exotic.loc != src)
		return FALSE
