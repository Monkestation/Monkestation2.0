#define RBMK_PROCESSOR_FABRICATE_URANIUM "fabricate_uranium"
#define RBMK_PROCESSOR_EXTRACT_THORIUM "extract_thorium"
#define RBMK_PROCESSOR_FABRICATE_THORIUM "fabricate_thorium"
#define RBMK_PROCESSOR_EXTRACT_PLUTONIUM "extract_plutonium"
#define RBMK_PROCESSOR_FABRICATE_PLUTONIUM "fabricate_plutonium"
#define RBMK_PROCESSOR_FABRICATE_PLASMA_MODERATOR "fabricate_plasma_moderator"
#define RBMK_PROCESSOR_FABRICATE_BLUESPACE_MODERATOR "fabricate_bluespace_moderator"
#define RBMK_PROCESSOR_FABRICATE_DIAMOND_MODERATOR "fabricate_diamond_moderator"

#define RBMK_PROCESSOR_IRON_COST (3 * SHEET_MATERIAL_AMOUNT)
#define RBMK_PROCESSOR_FUEL_COST (10 * SHEET_MATERIAL_AMOUNT)
#define RBMK_PROCESSOR_MODERATOR_COST (5 * SHEET_MATERIAL_AMOUNT)
#define RBMK_PROCESSOR_RECOVERED_SHEETS 5
#define RBMK_PROCESSOR_PROCESS_TIME (5 SECONDS)
#define RBMK_PROCESSOR_ADDITIONAL_ITEM_TIME (1 SECONDS)
#define RBMK_PROCESSOR_MAX_BATCH 12

/obj/item/rbmk/spent_fuel_casing
	name = "spent fuel casing"
	desc = "A contaminated fuel rod casing stripped of useful fissile material. It is not reusable and should be stored as radioactive waste."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "empty"
	w_class = WEIGHT_CLASS_NORMAL

/obj/machinery/rbmk/fuel_processor
	name = "RBMK fuel processor"
	desc = "A shielded machine used to fabricate RBMK fuel rods and extract useful isotope material from depleted fuel rods."
	icon = 'icons/obj/machines/rbmk_fuel_assembly_press.dmi'
	icon_state = "rod_press"
	base_icon_state = "rod_press"
	density = TRUE
	anchored = TRUE
	bound_width = 64
	bound_height = 32
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 1800

	var/datum/component/remote_materials/materials
	var/link_on_init = TRUE
	var/list/inserted_rods = list()
	var/list/output_items = list()
	var/processing = FALSE
	var/current_process
	var/current_batch_size = 0
	var/process_started_at = 0
	var/process_ends_at = 0

/obj/machinery/rbmk/fuel_processor/Initialize(mapload)
	inserted_rods = list()
	output_items = list()

	materials = AddComponent(/datum/component/remote_materials, mapload && link_on_init)

	. = ..()

	RegisterSignal(src, COMSIG_SILO_ITEM_CONSUMED, PROC_REF(silo_material_insert))

	update_appearance(UPDATE_ICON)
	return .

/obj/machinery/rbmk/fuel_processor/Destroy()
	UnregisterSignal(src, COMSIG_SILO_ITEM_CONSUMED)

	for(var/obj/item/rbmk/fuel_rod/inserted_rod as anything in inserted_rods)
		if(!QDELETED(inserted_rod))
			inserted_rod.forceMove(get_processor_output_location())

	inserted_rods.Cut()

	for(var/atom/movable/output_item as anything in output_items)
		if(!QDELETED(output_item))
			output_item.forceMove(get_processor_output_location())

	output_items.Cut()
	materials = null
	return ..()

/obj/machinery/rbmk/fuel_processor/proc/silo_material_insert(obj/machinery/rnd/machine, container, obj/item/item_inserted, last_inserted_id, list/mats_consumed, amount_inserted)
	SIGNAL_HANDLER

	process_material_insert(item_inserted, mats_consumed, amount_inserted)

/obj/machinery/rbmk/fuel_processor/proc/process_material_insert(obj/item/item_inserted, list/mats_consumed, amount_inserted)
	if(directly_use_energy(ROUND_UP((amount_inserted / (MAX_STACK_SIZE * SHEET_MATERIAL_AMOUNT)) * 0.4 * initial(active_power_usage))))
		if(!processing && !has_output_items() && !length(inserted_rods) && !panel_open)
			flick("rod_press_load", src)

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	SStgui.update_uis(src)

/obj/machinery/rbmk/fuel_processor/update_icon_state()
	. = ..()

	if(panel_open)
		icon_state = "rod_press_t"
		return

	if(processing)
		icon_state = "rod_press_loop"
		return

	if(has_output_items())
		icon_state = "rod_press_leave"
		return

	if(length(inserted_rods))
		icon_state = "rod_press_load"
		return

	icon_state = base_icon_state

/obj/machinery/rbmk/fuel_processor/screwdriver_act(mob/living/user, obj/item/tool)
	if(processing)
		balloon_alert(user, "processing")
		return ITEM_INTERACT_BLOCKING

	if(default_deconstruction_screwdriver(user, "rod_press_t", base_icon_state, tool))
		update_appearance(UPDATE_ICON)
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS

	return ..()

/obj/machinery/rbmk/fuel_processor/proc/prune_output_items()
	var/index = length(output_items)
	var/turf/output_turf = get_processor_output_location()

	while(index >= 1)
		var/atom/movable/output_item = output_items[index]

		if(!output_item || QDELETED(output_item))
			output_items.Cut(index, index + 1)
		else if(output_item.loc != output_turf)
			output_items.Cut(index, index + 1)

		index--

/obj/machinery/rbmk/fuel_processor/proc/has_output_items()
	prune_output_items()
	return length(output_items) > 0

/obj/machinery/rbmk/fuel_processor/proc/get_process_progress()
	if(!processing)
		return 0

	var/total_time = max(process_ends_at - process_started_at, 1)
	var/elapsed = clamp(world.time - process_started_at, 0, total_time)
	return round((elapsed / total_time) * 100, 0.1)

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_name(recipe_id)
	switch(recipe_id)
		if(RBMK_PROCESSOR_FABRICATE_URANIUM)
			return "Fabricate uranium fuel rod"

		if(RBMK_PROCESSOR_EXTRACT_THORIUM)
			return "Extract thorium"

		if(RBMK_PROCESSOR_FABRICATE_THORIUM)
			return "Fabricate thorium fuel rod"

		if(RBMK_PROCESSOR_EXTRACT_PLUTONIUM)
			return "Extract plutonium"

		if(RBMK_PROCESSOR_FABRICATE_PLUTONIUM)
			return "Fabricate plutonium fuel rod"

		if(RBMK_PROCESSOR_FABRICATE_PLASMA_MODERATOR)
			return "Fabricate plasma moderator rod"

		if(RBMK_PROCESSOR_FABRICATE_BLUESPACE_MODERATOR)
			return "Fabricate bluespace moderator rod"

		if(RBMK_PROCESSOR_FABRICATE_DIAMOND_MODERATOR)
			return "Fabricate diamond moderator rod"

	return "Unknown process"

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_description(recipe_id)
	switch(recipe_id)
		if(RBMK_PROCESSOR_FABRICATE_URANIUM)
			return "Presses uranium and iron into a fresh starter fuel rod."

		if(RBMK_PROCESSOR_EXTRACT_THORIUM)
			return "Extracts thorium from a depleted uranium rod and stores the ruined casing."

		if(RBMK_PROCESSOR_FABRICATE_THORIUM)
			return "Presses thorium and iron into a fresh thorium fuel rod."

		if(RBMK_PROCESSOR_EXTRACT_PLUTONIUM)
			return "Extracts plutonium from a depleted thorium rod and stores the ruined casing."

		if(RBMK_PROCESSOR_FABRICATE_PLUTONIUM)
			return "Presses plutonium and iron into a fresh plutonium fuel rod."

		if(RBMK_PROCESSOR_FABRICATE_PLASMA_MODERATOR)
			return "Presses stabilized plasma and iron into a plasma moderator rod."

		if(RBMK_PROCESSOR_FABRICATE_BLUESPACE_MODERATOR)
			return "Presses bluespace crystal and iron into a bluespace moderator rod."

		if(RBMK_PROCESSOR_FABRICATE_DIAMOND_MODERATOR)
			return "Presses diamond and iron into a diamond moderator rod."

	return "No description."

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_material_cost(recipe_id)
	switch(recipe_id)
		if(RBMK_PROCESSOR_FABRICATE_URANIUM)
			return list(
				/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
				/datum/material/uranium = RBMK_PROCESSOR_FUEL_COST,
			)

		if(RBMK_PROCESSOR_FABRICATE_THORIUM)
			return list(
				/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
				/datum/material/thorium = RBMK_PROCESSOR_FUEL_COST,
			)

		if(RBMK_PROCESSOR_FABRICATE_PLUTONIUM)
			return list(
				/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
				/datum/material/plutonium = RBMK_PROCESSOR_FUEL_COST,
			)

		if(RBMK_PROCESSOR_FABRICATE_PLASMA_MODERATOR)
			return list(
				/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
				/datum/material/plasma = RBMK_PROCESSOR_MODERATOR_COST,
			)

		if(RBMK_PROCESSOR_FABRICATE_BLUESPACE_MODERATOR)
			return list(
				/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
				/datum/material/bluespace = RBMK_PROCESSOR_MODERATOR_COST,
			)

		if(RBMK_PROCESSOR_FABRICATE_DIAMOND_MODERATOR)
			return list(
				/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
				/datum/material/diamond = RBMK_PROCESSOR_MODERATOR_COST,
			)

	return list()

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_cost_map(recipe_id)
	var/list/cost_map = list()
	var/list/material_cost = get_recipe_material_cost(recipe_id)

	for(var/material_type as anything in material_cost)
		var/datum/material/material = GET_MATERIAL_REF(material_type)
		cost_map[material.name] = material_cost[material_type]

	return cost_map

/obj/machinery/rbmk/fuel_processor/proc/recipe_needs_inserted_rod(recipe_id)
	return recipe_id == RBMK_PROCESSOR_EXTRACT_THORIUM || recipe_id == RBMK_PROCESSOR_EXTRACT_PLUTONIUM

/obj/machinery/rbmk/fuel_processor/proc/recipe_uses_silo_materials(recipe_id)
	return length(get_recipe_material_cost(recipe_id)) > 0

/obj/machinery/rbmk/fuel_processor/proc/rod_matches_recipe(obj/item/rbmk/fuel_rod/fuel_rod, recipe_id)
	if(!fuel_rod?.is_depleted())
		return FALSE

	switch(recipe_id)
		if(RBMK_PROCESSOR_EXTRACT_THORIUM)
			return fuel_rod.rod_type == "uranium"

		if(RBMK_PROCESSOR_EXTRACT_PLUTONIUM)
			return fuel_rod.rod_type == "thorium"

	return FALSE

/obj/machinery/rbmk/fuel_processor/proc/count_matching_inserted_rods(recipe_id)
	var/matching_rods = 0
	for(var/obj/item/rbmk/fuel_rod/fuel_rod as anything in inserted_rods)
		if(rod_matches_recipe(fuel_rod, recipe_id))
			matching_rods++
	return matching_rods

/obj/machinery/rbmk/fuel_processor/proc/inserted_rod_matches_recipe(recipe_id)
	return !recipe_needs_inserted_rod(recipe_id) || count_matching_inserted_rods(recipe_id) > 0

/obj/machinery/rbmk/fuel_processor/proc/recipe_materials_available(recipe_id)
	var/list/material_cost = get_recipe_material_cost(recipe_id)

	if(!length(material_cost))
		return FALSE

	if(!materials || !materials.mat_container)
		return FALSE

	if(!materials.can_use_resource())
		return FALSE

	return materials.mat_container.has_materials(material_cost, 1, 1)

/obj/machinery/rbmk/fuel_processor/proc/recipe_visible_by_default(recipe_id)
	if(current_process == recipe_id)
		return TRUE

	if(recipe_needs_inserted_rod(recipe_id))
		return inserted_rod_matches_recipe(recipe_id)

	if(recipe_uses_silo_materials(recipe_id))
		return recipe_materials_available(recipe_id)

	return FALSE

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_output_type(recipe_id)
	switch(recipe_id)
		if(RBMK_PROCESSOR_FABRICATE_URANIUM)
			return /obj/item/rbmk/fuel_rod/uranium

		if(RBMK_PROCESSOR_FABRICATE_THORIUM)
			return /obj/item/rbmk/fuel_rod/thorium

		if(RBMK_PROCESSOR_FABRICATE_PLUTONIUM)
			return /obj/item/rbmk/fuel_rod/plutonium

		if(RBMK_PROCESSOR_FABRICATE_PLASMA_MODERATOR)
			return /obj/item/rbmk/fuel_rod/plasma

		if(RBMK_PROCESSOR_FABRICATE_BLUESPACE_MODERATOR)
			return /obj/item/rbmk/fuel_rod/bluespace

		if(RBMK_PROCESSOR_FABRICATE_DIAMOND_MODERATOR)
			return /obj/item/rbmk/fuel_rod/diamond

	return null

/obj/machinery/rbmk/fuel_processor/proc/get_extracted_sheet_type(recipe_id)
	switch(recipe_id)
		if(RBMK_PROCESSOR_EXTRACT_THORIUM)
			return /obj/item/stack/sheet/mineral/thorium

		if(RBMK_PROCESSOR_EXTRACT_PLUTONIUM)
			return /obj/item/stack/sheet/mineral/plutonium

	return null

/obj/machinery/rbmk/fuel_processor/proc/recipe_creates_spent_casing(recipe_id)
	return recipe_id == RBMK_PROCESSOR_EXTRACT_THORIUM || recipe_id == RBMK_PROCESSOR_EXTRACT_PLUTONIUM

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_block_reason(recipe_id, check_power = TRUE, batch_size = 1)
	batch_size = clamp(round(batch_size), 1, RBMK_PROCESSOR_MAX_BATCH)

	if(processing)
		return "Machine is already processing."

	if(machine_stat & BROKEN)
		return "Machine is broken."

	if(check_power && (machine_stat & NOPOWER))
		return "Machine has no power."

	if(panel_open)
		return "Maintenance panel is open."

	if(has_output_items())
		return "Output tray is occupied."

	if(length(inserted_rods) && !recipe_needs_inserted_rod(recipe_id))
		return "Depleted fuel rods are loaded."

	if(recipe_needs_inserted_rod(recipe_id) && !length(inserted_rods))
		return "Requires a depleted fuel rod."

	if(recipe_needs_inserted_rod(recipe_id) && count_matching_inserted_rods(recipe_id) < batch_size)
		switch(recipe_id)
			if(RBMK_PROCESSOR_EXTRACT_THORIUM)
				return "Requires [batch_size] depleted uranium fuel rod\s."

			if(RBMK_PROCESSOR_EXTRACT_PLUTONIUM)
				return "Requires [batch_size] depleted thorium fuel rod\s."

	if(recipe_uses_silo_materials(recipe_id))
		if(!materials || !materials.mat_container)
			return "No linked material storage."

		if(!materials.can_use_resource())
			return "Linked material storage is unavailable."

		var/list/material_cost = get_recipe_material_cost(recipe_id)

		if(!materials.mat_container.has_materials(material_cost, 1, batch_size))
			return "Insufficient linked materials."

	return null

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_max_batch(recipe_id)
	for(var/batch_size in RBMK_PROCESSOR_MAX_BATCH to 1 step -1)
		if(isnull(get_recipe_block_reason(recipe_id, TRUE, batch_size)))
			return batch_size
	return 0

/obj/machinery/rbmk/fuel_processor/proc/start_recipe(recipe_id, mob/user, batch_size = 1)
	batch_size = clamp(round(text2num("[batch_size]")), 1, RBMK_PROCESSOR_MAX_BATCH)
	var/block_reason = get_recipe_block_reason(recipe_id, TRUE, batch_size)

	if(block_reason)
		if(user)
			to_chat(user, span_warning(block_reason))

		return FALSE

	processing = TRUE
	current_process = recipe_id
	current_batch_size = batch_size
	process_started_at = world.time
	var/process_time = RBMK_PROCESSOR_PROCESS_TIME + (RBMK_PROCESSOR_ADDITIONAL_ITEM_TIME * (batch_size - 1))
	process_ends_at = world.time + process_time

	update_use_power(ACTIVE_POWER_USE)
	update_appearance(UPDATE_ICON)
	SStgui.update_uis(src)

	playsound(src, 'sound/rbmk/rod_machine.ogg', 60, TRUE)

	if(user)
		user.visible_message(
			span_notice("[user] starts [src]."),
			span_notice("You start [get_recipe_name(recipe_id)] for a batch of [batch_size].")
		)

	addtimer(CALLBACK(src, PROC_REF(finish_recipe), recipe_id, batch_size), process_time)
	return TRUE

/obj/machinery/rbmk/fuel_processor/proc/finish_recipe(recipe_id, batch_size)
	if(QDELETED(src))
		return

	processing = FALSE
	current_process = null
	current_batch_size = 0
	process_started_at = 0
	process_ends_at = 0
	update_use_power(IDLE_POWER_USE)

	var/block_reason = get_recipe_block_reason(recipe_id, FALSE, batch_size)

	if(block_reason)
		update_appearance(UPDATE_ICON)
		SStgui.update_uis(src)
		return

	var/list/material_cost = get_recipe_material_cost(recipe_id)

	if(length(material_cost))
		materials.use_materials(material_cost, 1, batch_size, "fabricated", get_recipe_name(recipe_id))

	var/output_type = get_recipe_output_type(recipe_id)

	if(output_type)
		for(var/index in 1 to batch_size)
			create_output(output_type)

	var/extracted_sheet_type = get_extracted_sheet_type(recipe_id)

	if(extracted_sheet_type)
		create_sheet_output(extracted_sheet_type, RBMK_PROCESSOR_RECOVERED_SHEETS * batch_size)

	if(recipe_creates_spent_casing(recipe_id))
		for(var/index in 1 to batch_size)
			create_output(/obj/item/rbmk/spent_fuel_casing)

	if(recipe_needs_inserted_rod(recipe_id))
		var/rods_consumed = 0
		for(var/obj/item/rbmk/fuel_rod/inserted_rod as anything in inserted_rods.Copy())
			if(!rod_matches_recipe(inserted_rod, recipe_id))
				continue
			inserted_rods -= inserted_rod
			qdel(inserted_rod)
			rods_consumed++
			if(rods_consumed >= batch_size)
				break

	update_appearance(UPDATE_ICON)
	SStgui.update_uis(src)

/obj/machinery/rbmk/fuel_processor/proc/create_output(output_type)
	if(!output_type)
		return null

	var/atom/movable/created = new output_type(get_processor_output_location())
	output_items += created
	return created

/obj/machinery/rbmk/fuel_processor/proc/create_sheet_output(output_type, amount)
	if(!output_type || amount <= 0)
		return null

	var/list/created_stacks = list()
	while(amount > 0)
		var/stack_amount = min(amount, MAX_STACK_SIZE)
		var/obj/item/stack/created = new output_type(get_processor_output_location(), stack_amount)
		output_items += created
		created_stacks += created
		amount -= stack_amount

	return created_stacks

/obj/machinery/rbmk/fuel_processor/proc/get_processor_output_location()
	var/turf/output_turf = get_step(src, EAST)
	if(output_turf && !isclosedturf(output_turf))
		return output_turf

	return drop_location()

/obj/machinery/rbmk/fuel_processor/proc/can_accept_rod(obj/item/rbmk/fuel_rod/fuel_rod, mob/user)
	if(!fuel_rod)
		return FALSE

	if(processing)
		if(user)
			balloon_alert(user, "processing")

		return FALSE

	if(panel_open)
		if(user)
			balloon_alert(user, "panel open")

		return FALSE

	if(length(inserted_rods) >= RBMK_PROCESSOR_MAX_BATCH)
		if(user)
			balloon_alert(user, "rod bay full")

		return FALSE

	if(has_output_items())
		if(user)
			balloon_alert(user, "output full")
			to_chat(user, span_warning("Clear the output tray before loading another rod."))

		return FALSE

	if(!fuel_rod.is_depleted())
		if(user)
			to_chat(user, span_warning("Fresh fuel rods do not need processing."))

		return FALSE

	if(fuel_rod.rod_type != "uranium" && fuel_rod.rod_type != "thorium")
		if(user)
			to_chat(user, span_warning("[fuel_rod] has no viable processing path. Treat it as radioactive waste."))

		return FALSE

	return TRUE

/obj/machinery/rbmk/fuel_processor/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/rbmk/fuel_rod))
		var/obj/item/rbmk/fuel_rod/fuel_rod = item

		if(!can_accept_rod(fuel_rod, user))
			return TRUE

		if(!user.transferItemToLoc(fuel_rod, src))
			return TRUE

		inserted_rods += fuel_rod

		user.visible_message(
			span_notice("[user] loads [fuel_rod] into [src]."),
			span_notice("You load [fuel_rod] into [src].")
		)

		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		update_appearance(UPDATE_ICON)
		SStgui.update_uis(src)
		return TRUE

	return ..()

/obj/machinery/rbmk/fuel_processor/proc/eject_inserted_rod(rod_index, mob/user)
	if(processing)
		if(user)
			balloon_alert(user, "processing")

		return FALSE

	rod_index = round(text2num("[rod_index]"))
	if(rod_index < 1 || rod_index > length(inserted_rods))
		return FALSE

	var/obj/item/rbmk/fuel_rod/ejected_rod = inserted_rods[rod_index]
	inserted_rods.Cut(rod_index, rod_index + 1)
	ejected_rod.forceMove(get_processor_output_location())

	if(user)
		to_chat(user, span_notice("You eject [ejected_rod] from [src]."))

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	update_appearance(UPDATE_ICON)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/rbmk/fuel_processor/proc/eject_output(output_index, mob/user)
	if(processing)
		if(user)
			balloon_alert(user, "processing")

		return FALSE

	output_index = text2num("[output_index]")

	if(!output_index)
		return FALSE

	output_index = round(output_index)

	if(output_index < 1 || output_index > length(output_items))
		return FALSE

	var/atom/movable/output_item = output_items[output_index]

	if(!output_item || QDELETED(output_item))
		output_items.Cut(output_index, output_index + 1)
		SStgui.update_uis(src)
		return TRUE

	output_items.Cut(output_index, output_index + 1)
	output_item.forceMove(get_processor_output_location())

	if(user)
		to_chat(user, span_notice("You eject [output_item] from [src]."))

	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	update_appearance(UPDATE_ICON)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/rbmk/fuel_processor/proc/get_inserted_rods_data()
	var/list/rod_data = list()
	for(var/index in 1 to length(inserted_rods))
		var/obj/item/rbmk/fuel_rod/inserted_rod = inserted_rods[index]
		rod_data += list(list(
			"index" = index,
			"name" = inserted_rod.name,
			"desc" = inserted_rod.desc,
			"rod_type" = inserted_rod.rod_type,
			"depleted" = inserted_rod.is_depleted(),
		))
	return rod_data

/obj/machinery/rbmk/fuel_processor/proc/get_output_items_data()
	prune_output_items()

	var/list/output_data = list()

	for(var/index in 1 to length(output_items))
		var/atom/movable/output_item = output_items[index]

		if(!output_item || QDELETED(output_item))
			continue

		output_data += list(list(
			"index" = index,
			"name" = output_item.name,
			"desc" = output_item.desc,
		))

	return output_data

/obj/machinery/rbmk/fuel_processor/proc/get_recipe_data(recipe_id)
	var/block_reason = get_recipe_block_reason(recipe_id)

	return list(
		"id" = recipe_id,
		"name" = get_recipe_name(recipe_id),
		"description" = get_recipe_description(recipe_id),
		"cost" = get_recipe_cost_map(recipe_id),
		"requires_inserted_rod" = recipe_needs_inserted_rod(recipe_id),
		"creates_spent_casing" = recipe_creates_spent_casing(recipe_id),
		"visible" = recipe_visible_by_default(recipe_id),
		"can_start" = isnull(block_reason),
		"block_reason" = block_reason,
		"max_batch" = get_recipe_max_batch(recipe_id),
	)

/obj/machinery/rbmk/fuel_processor/proc/get_all_recipe_data()
	return list(
		get_recipe_data(RBMK_PROCESSOR_FABRICATE_URANIUM),
		get_recipe_data(RBMK_PROCESSOR_EXTRACT_THORIUM),
		get_recipe_data(RBMK_PROCESSOR_FABRICATE_THORIUM),
		get_recipe_data(RBMK_PROCESSOR_EXTRACT_PLUTONIUM),
		get_recipe_data(RBMK_PROCESSOR_FABRICATE_PLUTONIUM),
		get_recipe_data(RBMK_PROCESSOR_FABRICATE_PLASMA_MODERATOR),
		get_recipe_data(RBMK_PROCESSOR_FABRICATE_BLUESPACE_MODERATOR),
		get_recipe_data(RBMK_PROCESSOR_FABRICATE_DIAMOND_MODERATOR),
	)

/obj/machinery/rbmk/fuel_processor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials)
	)

/obj/machinery/rbmk/fuel_processor/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/rbmk/fuel_processor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	if(.)
		return .

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "RBMKFuelProcessor", name)
		ui.open()

	return ui

/obj/machinery/rbmk/fuel_processor/ui_static_data(mob/user)
	var/list/data = list()

	if(materials?.mat_container)
		data += materials.mat_container.ui_static_data()
	else
		data["SHEET_MATERIAL_AMOUNT"] = SHEET_MATERIAL_AMOUNT

	return data

/obj/machinery/rbmk/fuel_processor/ui_data(mob/user)
	var/list/data = list()

	data["processing"] = processing
	data["current_process"] = current_process ? get_recipe_name(current_process) : null
	data["current_batch_size"] = current_batch_size
	data["process_progress"] = get_process_progress()
	data["inserted_rods"] = get_inserted_rods_data()
	data["max_batch_size"] = RBMK_PROCESSOR_MAX_BATCH
	data["output_items"] = get_output_items_data()
	data["recipes"] = get_all_recipe_data()
	data["materials"] = materials?.mat_container ? materials.mat_container.ui_data() : list()
	data["onHold"] = materials ? materials.on_hold() : FALSE

	return data

/obj/machinery/rbmk/fuel_processor/ui_act(action, list/params, datum/tgui/ui)
	. = ..()

	if(.)
		return .

	var/mob/user = ui.user

	switch(action)
		if("start")
			var/recipe_id = params["recipe"]

			if(!istext(recipe_id))
				return FALSE

			return start_recipe(recipe_id, user, params["quantity"])

		if("eject_inserted_rod")
			return eject_inserted_rod(params["index"], user)

		if("eject_output")
			return eject_output(params["index"], user)

		if("remove_mat")
			if(!materials?.mat_container)
				return FALSE

			var/datum/material/material = locate(params["ref"])

			if(!istype(material))
				return FALSE

			var/amount = params["amount"]

			if(isnull(amount))
				return FALSE

			amount = text2num("[amount]")

			if(isnull(amount) || amount <= 0)
				return FALSE

			materials.eject_sheets(material, amount, get_processor_output_location())
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			update_appearance(UPDATE_ICON)
			SStgui.update_uis(src)
			return TRUE

	return FALSE

#undef RBMK_PROCESSOR_FABRICATE_URANIUM
#undef RBMK_PROCESSOR_EXTRACT_THORIUM
#undef RBMK_PROCESSOR_FABRICATE_THORIUM
#undef RBMK_PROCESSOR_EXTRACT_PLUTONIUM
#undef RBMK_PROCESSOR_FABRICATE_PLUTONIUM
#undef RBMK_PROCESSOR_FABRICATE_PLASMA_MODERATOR
#undef RBMK_PROCESSOR_FABRICATE_BLUESPACE_MODERATOR
#undef RBMK_PROCESSOR_FABRICATE_DIAMOND_MODERATOR
#undef RBMK_PROCESSOR_IRON_COST
#undef RBMK_PROCESSOR_FUEL_COST
#undef RBMK_PROCESSOR_MODERATOR_COST
#undef RBMK_PROCESSOR_RECOVERED_SHEETS
#undef RBMK_PROCESSOR_PROCESS_TIME
#undef RBMK_PROCESSOR_ADDITIONAL_ITEM_TIME
#undef RBMK_PROCESSOR_MAX_BATCH
