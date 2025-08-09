#define REQUIRED_OXYGEN_MOLES 25

/obj/machinery/bouldertech/flatpack/purification_chamber
	name = "purification chamber"
	desc = "Uses a large amount of oxygen to purify ore boulders and shards into ore clumps. The high temperature oxygen rich process burns away impurities but they still need to be crushed."
	icon_state = "purification_chamber"

	refining_efficiency = 3
	machine = /obj/item/flatpacked_machine/ore_processing/purification_chamber
	var/obj/machinery/portable_atmospherics/purification_input/oxygen_input
	usage_sound = 'sound/machines/mining/smelter.ogg'
	action = "baking"

/obj/machinery/bouldertech/flatpack/purification_chamber/Destroy()
	disconnect(TRUE)
	return ..()

/obj/machinery/bouldertech/flatpack/purification_chamber/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(. == CONTEXTUAL_SCREENTIP_SET && !panel_open && anchored)
		if(isnull(oxygen_input))
			context[SCREENTIP_CONTEXT_ALT_LMB] = "Deploy oxygen port"
		else
			context[SCREENTIP_CONTEXT_ALT_LMB] = "Disconnect oxygen port"

/obj/machinery/bouldertech/flatpack/purification_chamber/AltClick(mob/user)
	. = ..()
	if(panel_open)
		return
	if(oxygen_input)
		disconnect(FALSE)

	var/list/options = list()
	switch(dir)
		if(NORTH, SOUTH)
			options = list("North", "South")
		if(EAST, WEST)
			options = list("East", "West")

	var/side = text2dir(tgui_input_list(user, "Choose a side to try and deploy the tank on", "[name]", options))
	if(!side)
		return

	if(!(locate(/obj/machinery/atmospherics/components/unary/portables_connector) in get_step(src, side)))
		balloon_alert_to_viewers("anchored connector port required")
		return

	oxygen_input = new(get_step(src, side))
	var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = \
	locate(/obj/machinery/atmospherics/components/unary/portables_connector) in oxygen_input.loc
	if(!oxygen_input.connect(possible_port))
		QDEL_NULL(oxygen_input)
		return
	RegisterSignal(oxygen_input, COMSIG_QDELETING, PROC_REF(disconnect))

/obj/machinery/bouldertech/flatpack/purification_chamber/can_process_resource(obj/item/res, return_typecache = FALSE)
	var/static/list/processable_resources
	if(!length(processable_resources))
		processable_resources = typecacheof(list(
				/obj/item/boulder,
				/obj/item/processing/shards,
				/datum/gas/oxygen,
			),
			only_root_path = TRUE
		)
	return return_typecache ? processable_resources : is_type_in_typecache(res, processable_resources)

/obj/machinery/bouldertech/flatpack/purification_chamber/proc/disconnect(destroyed = FALSE)
	if(!QDELETED(oxygen_input))
		UnregisterSignal(oxygen_input, COMSIG_QDELETING)
		oxygen_input.disconnect(destroyed)
		QDEL_NULL(oxygen_input)
	else
		oxygen_input = null

/obj/machinery/bouldertech/flatpack/purification_chamber/breakdown_boulder(obj/item/boulder/chosen_boulder)

	if(QDELETED(chosen_boulder))
		return FALSE
	if(chosen_boulder.loc != src)
		return FALSE

	var/oxygen_moles = 0
	if(oxygen_input)
		oxygen_input.air_contents.assert_gas(/datum/gas/oxygen, oxygen_input.air_contents)
		oxygen_moles = oxygen_input.air_contents.gases[/datum/gas/oxygen][MOLES]

	if(oxygen_moles < REQUIRED_OXYGEN_MOLES)
		return FALSE

	if(chosen_boulder.durability > 0)
		if(oxygen_input.air_contents.remove_specific(/datum/gas/oxygen, REQUIRED_OXYGEN_MOLES))
			chosen_boulder.durability -= 1
		else
			return FALSE
		if(chosen_boulder.durability > 0)
			return FALSE

	//if boulders are kept inside because there is no space to eject them, then they could be reprocessed, lets avoid that
	if(!chosen_boulder.processed_by)
		check_for_boosts()
		var/obj/item/processing/clumps/clump  = new(src)
		clump.custom_materials = list()
		for(var/datum/material/material as anything in chosen_boulder.custom_materials)
			if(!can_process_material(material))
				continue
			var/quantity = chosen_boulder.custom_materials[material]
			clump.custom_materials += material
			clump.custom_materials[material] = quantity * refining_efficiency
			chosen_boulder.custom_materials -= material

		if(!isnull(clump) && !length(clump.custom_materials))
			qdel(clump)

		clump.set_colors()
		src.remove_resource(clump)
		if(!length(chosen_boulder.custom_materials))
			chosen_boulder.break_apart()
		else
			src.remove_resource(chosen_boulder)
		return TRUE
	return FALSE

/obj/machinery/bouldertech/flatpack/purification_chamber/breakdown_exotic(obj/item/chosen_exotic)

	if(QDELETED(chosen_exotic))
		return FALSE
	if(chosen_exotic.loc != src)
		return FALSE

	var/oxygen_moles = 0
	if(oxygen_input)
		oxygen_input.air_contents.assert_gas(/datum/gas/oxygen, oxygen_input.air_contents)
		oxygen_moles = oxygen_input.air_contents.gases[/datum/gas/oxygen][MOLES]

	if(oxygen_moles < REQUIRED_OXYGEN_MOLES)
		return FALSE

	if(istype(chosen_exotic, /obj/item/processing/shards))
		if(!oxygen_input.air_contents.remove_specific(/datum/gas/oxygen, REQUIRED_OXYGEN_MOLES))
			return FALSE

		var/obj/item/processing/exotic = chosen_exotic
		if(!exotic.processed_by)
			check_for_boosts()
			for(var/datum/material/material as anything in exotic.custom_materials)
				if(!can_process_material(material))
					continue
				var/quantity = exotic.custom_materials[material]
				var/obj/item/processing/clumps/clump  = new(src)
				clump.custom_materials = list()
				clump.custom_materials += material
				clump.custom_materials[material] = quantity
				exotic.custom_materials -= material

				if(!isnull(clump) && !length(clump.custom_materials))
					qdel(clump)
					continue
				clump.set_colors()
				src.remove_resource(clump)
			if(!length(exotic.custom_materials))
				qdel(exotic)
			else
				exotic.set_colors()
				src.remove_resource(exotic)
			return TRUE
	return FALSE

#undef REQUIRED_OXYGEN_MOLES

/obj/machinery/portable_atmospherics/purification_input
	name = "external purification oxygen tank"
	desc = "Pumps pure oxygen into the purification chamber. Can take oxygen tanks but an atmos network is recommended."
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "air_pump"
	pressure_resistance = 7 * ONE_ATMOSPHERE
	volume = 2000
	density = TRUE
	max_integrity = 300
	integrity_failure = 0.4
	armor_type = /datum/armor/portable_atmospherics_canister

/obj/machinery/portable_atmospherics/purification_input/wrench_act(mob/living/user, obj/item/tool)
	return FALSE

/obj/machinery/portable_atmospherics/purification_input/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)
	AddElement(/datum/element/volatile_gas_storage)
	AddComponent(/datum/component/gas_leaker, leak_rate=0.01)

	SSair.start_processing_machine(src)
