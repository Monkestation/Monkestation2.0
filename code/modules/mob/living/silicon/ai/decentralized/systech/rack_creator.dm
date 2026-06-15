/obj/machinery/rack_creator
	name = "rack creator"
	desc = "Combines RAM modules and CPUs to create a stand-alone rack for usage in artificial intelligence systems."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "circuit_imprinter"
	base_icon_state = "circuit_imprinter"
	layer = BELOW_OBJ_LAYER

	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/rack_creator

	var/list/inserted_cpus = list()

	var/list/ram_expansions = list() //List containing numbers corresponding to the amount of RAM that stick adds.

	var/datum/component/material_container/materials
	var/efficiency_coeff = 1


/obj/machinery/rack_creator/Initialize(mapload)
	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_RACK_CREATOR], \
		0, \
		MATCONTAINER_EXAMINE, \
	)
	. = ..()
	RefreshParts()
	register_context()


/obj/machinery/rack_creator/RefreshParts()
	. = ..()
	var/mat_capacity = 0
	for(var/datum/stock_part/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.tier * 25 * SHEET_MATERIAL_AMOUNT
	materials.max_amount = mat_capacity

	var/total_rating = 1.2
	for(var/datum/stock_part/manipulator/M in component_parts)
		total_rating = clamp(total_rating - (M.tier * 0.1), 0, 1)
	efficiency_coeff = round(total_rating, 0.1)
	update_static_data_for_all_viewers()

/obj/machinery/rack_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiRackCreator", name)
		ui.open()

/obj/machinery/rack_creator/ui_static_data(mob/user)
	var/list/data = list()
	data["SHEET_MATERIAL_AMOUNT"] = SHEET_MATERIAL_AMOUNT
	return data

/obj/machinery/rack_creator/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["materials"] = materials.ui_data()
	data["can_print"] = check_resources()

	data["cpus"] = list()
	data["total_cpu"] = 0
	data["power_usage"] = 0
	var/power_usage_unweighted = list()
	for(var/obj/item/ai_cpu/CPU in inserted_cpus)
		var/cpu_power_usage = CPU.get_power_usage()
		var/cpu_efficiency = CPU.get_efficiency()
		var/cpu_list = list(list(
			"speed" = CPU.speed,
			"efficiency" = cpu_efficiency,
			"power_usage" = cpu_power_usage,
		))
		data["cpus"] += cpu_list
		data["total_cpu"] += CPU.speed
		data["power_usage"] += cpu_power_usage
		power_usage_unweighted += list(list(
			"usage" = cpu_power_usage,
			"efficiency" = cpu_efficiency,
		))

	var/total_efficiency = 1
	if(data["power_usage"])
		total_efficiency = 0
		for(var/usage in power_usage_unweighted)
			var/weight = usage["usage"] / data["power_usage"]
			total_efficiency += (usage["efficiency"] / 100) * weight

	data["efficiency"] = total_efficiency

	data["ram"] = list()
	data["total_ram"] = 0
	for(var/RAM in ram_expansions)
		var/materials_string
		for(var/mat in RAM["cost"])
			var/datum/material/M = mat
			if(!materials_string)
				materials_string += "[M.name]: [RAM["cost"][mat] * efficiency_coeff]"
			else
				materials_string += ", [M.name]: [RAM["cost"][mat] * efficiency_coeff]"

		var/ram_list = list(list("capacity" = RAM["capacity"], "name" = RAM["name"], "cost" = materials_string))
		data["ram"] += ram_list
		data["total_ram"] += RAM["capacity"]


	data["power_usage"] += length(ram_expansions) * AI_POWER_PER_CARD

	data["possible_ram"] = list()
	for(var/datum/design/ram/D as anything in subtypesof(/datum/design/ram))
		D = SSresearch.techweb_design_by_id(initial(D.id))
		var/materials_string
		for(var/mat in D.ram_materials)
			var/datum/material/M = mat
			if(!materials_string)
				materials_string += "[M.name]: [D.ram_materials[mat] * efficiency_coeff]"
			else
				materials_string += ", [M.name]: [D.ram_materials[mat] * efficiency_coeff]"
		data["possible_ram"] += list(list(
			"name" = D.name,
			"capacity" = D.capacity,
			"cost" = materials_string,
			"id" = D.id,
			"unlocked" = SSresearch.science_tech.isDesignResearchedID(D.id) ? TRUE : FALSE,
		))

	data["unlocked_ram"] = 1
	data["unlocked_cpu"] = 1
	for(var/i in 2 to 4)
		if(slotUnlockedRAM(i))
			data["unlocked_ram"] = i
		if(slotUnlockedCPU(i))
			data["unlocked_cpu"] = i


	return data

/obj/machinery/rack_creator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials),
	)

/obj/machinery/rack_creator/proc/check_resources()
	var/list/total_cost = list()
	for(var/RAM in ram_expansions)
		for(var/mat in RAM["cost"])
			var/datum/material/M = mat
			total_cost[M] += RAM["cost"][M] * efficiency_coeff

	if(!length(total_cost))
		return -1
	if(materials.has_materials(total_cost))
		return total_cost
	return FALSE

/obj/machinery/rack_creator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/ai_cpu))
		return

	if(length(inserted_cpus) >= AI_MAX_CPUS_PER_RACK)
		to_chat(user, span_warning("This rack cannot fit anymore CPUs!"))
		return ITEM_INTERACT_BLOCKING
	if(!slotUnlockedCPU(length(inserted_cpus) + 1))
		to_chat(user, span_warning("This socket has not been researched!"))
		return ITEM_INTERACT_BLOCKING
	inserted_cpus += tool
	tool.forceMove(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/rack_creator/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_t", base_icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/rack_creator/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/rack_creator/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[(panel_open ? "Close" : "Open")] Panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/ai_cpu))
		context[SCREENTIP_CONTEXT_LMB] = "Insert CPU"
		return CONTEXTUAL_SCREENTIP_SET
	if(panel_open && (held_item.tool_behaviour == TOOL_CROWBAR))
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/rack_creator/proc/slotUnlockedCPU(slot_number)
	switch(slot_number)
		if(1)
			. = TRUE
		if(2)
			. = SSresearch.science_tech.isNodeResearchedID("ai_cpu_2")
		if(3)
			. = SSresearch.science_tech.isNodeResearchedID("ai_cpu_3")
		if(4)
			. = SSresearch.science_tech.isNodeResearchedID("ai_cpu_4")

/obj/machinery/rack_creator/proc/slotUnlockedRAM(slot_number)
	switch(slot_number)
		if(1)
			. = TRUE
		if(2)
			. = SSresearch.science_tech.isNodeResearchedID("ai_ram_2")
		if(3)
			. = SSresearch.science_tech.isNodeResearchedID("ai_ram_3")
		if(4)
			. = SSresearch.science_tech.isNodeResearchedID("ai_ram_4")


/obj/machinery/rack_creator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("insert_cpu")
			if(length(inserted_cpus) >= AI_MAX_CPUS_PER_RACK)
				to_chat(user, span_warning("This rack cannot fit anymore CPUs!"))
				return
			var/atom/I = user.get_active_held_item()
			if(!I)
				to_chat(user, span_warning("You're not currently holding a CPU!"))
				return
			if(!istype(I, /obj/item/ai_cpu))
				to_chat(user, span_warning("You're not currently holding a CPU!"))
				return
			var/obj/item/ai_cpu/cpu = I
			if(slotUnlockedCPU(length(inserted_cpus) + 1))
				inserted_cpus += cpu
				cpu.forceMove(src)
			else
				to_chat(user, span_warning("This socket has not been researched!"))
				return
			. = TRUE
		if("remove_cpu")
			var/index = params["cpu_index"]
			if(!index)
				return
			if(index > length(inserted_cpus) || index < 1)
				return
			var/obj/item/ai_cpu/cpu = inserted_cpus[index]
			inserted_cpus -= cpu
			cpu.forceMove(get_turf(src))
			. = TRUE
		if("insert_ram")
			if(length(ram_expansions) >= AI_MAX_RAM_PER_RACK)
				to_chat(user, span_warning("This rack cannot fit anymore RAM expansions!"))
				return
			var/ram_type = params["ram_type"]
			if(!ram_type)
				return
			var/datum/design/ram/D = SSresearch.science_tech.isDesignResearchedID(ram_type)
			if(!D)
				return
			if(slotUnlockedRAM(length(ram_expansions) + 1))
				var/list/stats = list(list(
					"name" = D.name,
					"capacity" = D.capacity,
					"cost" = D.ram_materials,
				))
				ram_expansions += stats
			else
				to_chat(user, span_warning("This socket has not been researched!"))
				return

			. = TRUE
		if("remove_ram")
			var/index = params["ram_index"]
			if(!index)
				return
			if(index > length(ram_expansions) || index < 1)
				return
			ram_expansions.Cut(index, index + 1)
			. = TRUE

		if("finalize")
			if(!length(ram_expansions) && !length(inserted_cpus))
				say("No RAM nor CPUs inserted. Process aborted.")
				return
			if (!materials)
				stack_trace("[src] somehow does not have an internal material storage.")
				return FALSE
			var/total_cost = check_resources()
			if(!total_cost)
				say("Not enough resources to finalize.")
				return FALSE
			if(islist(total_cost))
				materials.use_materials(total_cost)

			var/obj/item/server_rack/new_rack = new(src)
			for(var/obj/item/ai_cpu/CPU in inserted_cpus)
				CPU.forceMove(new_rack)
				new_rack.contained_cpus += CPU
			inserted_cpus = list()

			var/total_ram = 0
			for(var/RAM in ram_expansions)
				for(var/mat in RAM["cost"])
					new_rack.custom_materials[mat] += RAM["cost"][mat]

				total_ram += RAM["capacity"]

			new_rack.contained_ram = total_ram
			ram_expansions = list()

			flick("circuit_imprinter_ani", src)
			addtimer(CALLBACK(src, PROC_REF(finalize_post), new_rack), 1.5 SECONDS)
			. = TRUE

/obj/machinery/rack_creator/proc/finalize_post(obj/item/server_rack/rack)
	if(!rack)
		return
	rack.forceMove(drop_location())
