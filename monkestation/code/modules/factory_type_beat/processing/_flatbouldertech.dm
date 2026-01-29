/obj/machinery/bouldertech/flatpack
	name = "unpacked machine"
	desc = "This is an unpacked processing machine. You shouldn't be seeing this."

	/// Pack to return when deconstructed with crowbar.
	var/obj/item/flatpacked_machine/ore_processing/machine
	var/datum/component/simple_rotation/rotation

/obj/machinery/bouldertech/flatpack/Destroy()
	QDEL_NULL(rotation)
	return ..()


/obj/machinery/bouldertech/flatpack/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), tool))
		update_appearance(UPDATE_ICON_STATE)
		if(panel_open)
			rotation = AddComponent(/datum/component/simple_rotation)
		else
			QDEL_NULL(rotation)

		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/bouldertech/flatpack/deconstruct(disassembled)
	if(disassembled && !isnull(machine))
		new machine(src.loc)

	return ..() /// Must be called last or machine won't spawn before src is qdel.

/obj/machinery/bouldertech/flatpack/can_process_material(datum/material/possible_mat)
	var/static/list/processable_materials
	if(!length(processable_materials))
		processable_materials = list(
			/datum/material/iron,
			/datum/material/titanium,
			/datum/material/silver,
			/datum/material/gold,
			/datum/material/uranium,
			/datum/material/mythril,
			/datum/material/adamantine,
			/datum/material/runite,
			/datum/material/glass,
			/datum/material/plasma,
			/datum/material/diamond,
			/datum/material/bluespace,
			/datum/material/bananium,
			/datum/material/plastic,
		)
	return is_type_in_list(possible_mat, processable_materials)

/obj/machinery/bouldertech/flatpack/breakdown_boulder(obj/item/boulder/chosen_boulder)
	return FALSE

/obj/machinery/bouldertech/flatpack/breakdown_exotic(obj/item/chosen_exotic)
	return FALSE
