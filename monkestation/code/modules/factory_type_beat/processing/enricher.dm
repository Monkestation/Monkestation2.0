/obj/machinery/bouldertech/flatpack/enricher
	name = "enrichment chamber"
	desc = "Enriches boulders and dirty dust into dust which can then be smelted at a smelter for double the materials."
	icon_state = "enricher"

	machine = /obj/item/flatpacked_machine/ore_processing/enricher
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
