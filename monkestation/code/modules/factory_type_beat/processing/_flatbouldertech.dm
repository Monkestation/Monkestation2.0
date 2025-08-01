/obj/machinery/bouldertech/flatpack
	name = "unpacked machine"
	desc = "This is an unpacked processing machine. You shouldn't be seeing this."

	/// Pack to return when deconstructed with crowbar.
	var/obj/item/flatpacked_machine/ore_processing/machine

/obj/machinery/bouldertech/flatpack/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), tool))
		update_appearance(UPDATE_ICON_STATE)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return

/obj/machinery/bouldertech/flatpack/deconstruct(disassembled)
	if(disassembled && !isnull(machine))
		var/obj/item/flatpacked_machine/flatmachine = new machine(src.loc)
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
