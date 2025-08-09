/obj/machinery/bouldertech/flatpack/chemical_injector
	name = "chemical injector"
	desc = "Splits shards and boulders when infused with brine."
	icon_state = "chemical_injection"

	machine = /obj/item/flatpacked_machine/ore_processing/chemical_injector
	refining_efficiency = 4
	action = "injecting"

/obj/machinery/bouldertech/flatpack/chemical_injector/Initialize(mapload)
	 . = ..()

/obj/machinery/bouldertech/flatpack/enricher/can_process_resource(obj/item/res, return_typecache = FALSE)
	var/static/list/processable_resources
	if(!length(processable_resources))
		processable_resources = typecacheof(list(
			/obj/item/boulder,
			/obj/item/processing/crystals,
			),
			only_root_path = TRUE
		)
	return return_typecache ? processable_resources : is_type_in_typecache(res, processable_resources)

/datum/component/plumbing/chemical_injector_brine
