/// Material sheets recovered from each valid extraction recipe.
#define RBMK_PROCESSOR_RECOVERED_SHEETS 5
/// Base processing duration for one item.
#define RBMK_PROCESSOR_PROCESS_TIME (5 SECONDS)
/// Additional processing duration per item beyond the first.
#define RBMK_PROCESSOR_ADDITIONAL_ITEM_TIME (1 SECONDS)
/// Largest recipe batch accepted by the processor.
#define RBMK_PROCESSOR_MAX_BATCH 12

/// Radioactive waste left behind after extracting fissile material from a spent rod.
/obj/item/rbmk/spent_fuel_casing
	name = "spent fuel casing"
	desc = "A contaminated fuel rod casing stripped of useful fissile material. It is not reusable and should be stored as radioactive waste."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "empty"
	w_class = WEIGHT_CLASS_NORMAL

/// Fabricates RBMK rods and recovers fissile material from depleted rods.
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
	/// Remote material-store component used to charge recipe costs.
	var/datum/component/remote_materials/materials
	/// Fuel rods currently held by the processor.
	var/list/inserted_rods
	/// Completed items waiting on the processor's output tile.
	var/list/output_items
	/// Recipe datum for the active job.
	var/datum/rbmk_fuel_recipe/current_recipe
	/// Number of items requested by the active job.
	var/current_batch_size = 0
	/// World time when the active job began.
	var/process_started_at = 0
	/// World time when the active job is due to finish.
	var/process_ends_at = 0
/obj/machinery/rbmk/fuel_processor/Initialize(mapload)
	. = ..()
	inserted_rods = list()
	output_items = list()
	materials = AddComponent(/datum/component/remote_materials, mapload)
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
/// Handles material-insertion signals from the linked ore silo.
/obj/machinery/rbmk/fuel_processor/proc/silo_material_insert(obj/machinery/rnd/machine, container, obj/item/item_inserted, last_inserted_id, list/mats_consumed, amount_inserted)
	SIGNAL_HANDLER
	process_material_insert(item_inserted, mats_consumed, amount_inserted)
/// Applies power, animation, sound, and UI feedback for a silo material deposit.
/obj/machinery/rbmk/fuel_processor/proc/process_material_insert(obj/item/item_inserted, list/mats_consumed, amount_inserted)
	if(directly_use_energy(ROUND_UP((amount_inserted / (MAX_STACK_SIZE * SHEET_MATERIAL_AMOUNT)) * 0.4 * initial(active_power_usage))))
		if(!current_recipe && !has_output_items() && !length(inserted_rods) && !panel_open)
			flick("rod_press_load", src)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	SStgui.update_uis(src)
/obj/machinery/rbmk/fuel_processor/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "rod_press_t"
		return
	if(current_recipe)
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
	if(current_recipe)
		balloon_alert(user, "processing")
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "rod_press_t", base_icon_state, tool))
		update_appearance(UPDATE_ICON)
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS
	return ..()
/// Removes deleted or externally moved items from the tracked output tray.
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
/// Returns whether the processor's output tray still contains tracked output.
/obj/machinery/rbmk/fuel_processor/proc/has_output_items()
	prune_output_items()
	return length(output_items) > 0
/// Returns completion progress for the active recipe as a percentage.
/obj/machinery/rbmk/fuel_processor/proc/get_process_progress()
	if(!current_recipe)
		return 0
	var/total_time = max(process_ends_at - process_started_at, 1)
	var/elapsed = clamp(world.time - process_started_at, 0, total_time)
	return round((elapsed / total_time) * 100, 0.1)
/// Resolves a server-validated recipe datum from a datum, type path, or TGUI string.
/obj/machinery/rbmk/fuel_processor/proc/get_recipe(recipe_reference)
	if(istype(recipe_reference, /datum/rbmk_fuel_recipe))
		var/datum/rbmk_fuel_recipe/recipe = recipe_reference
		return GLOB.rbmk_fuel_recipes[recipe.type]
	var/recipe_type = recipe_reference
	if(!ispath(recipe_type))
		recipe_type = text2path("[recipe_reference]")
	if(!ispath(recipe_type, /datum/rbmk_fuel_recipe))
		return null
	return GLOB.rbmk_fuel_recipes[recipe_type]

/// Converts a recipe's material costs into the named records consumed by TGUI.
/obj/machinery/rbmk/fuel_processor/proc/get_recipe_cost_map(datum/rbmk_fuel_recipe/recipe)
	var/list/cost_map = list()
	for(var/material_type in recipe.material_cost)
		var/datum/material/material = GET_MATERIAL_REF(material_type)
		cost_map[material.name] = recipe.material_cost[material_type]
	return cost_map

/// Returns whether a depleted rod satisfies an extraction recipe.
/obj/machinery/rbmk/fuel_processor/proc/rod_matches_recipe(obj/item/rbmk/fuel_rod/fuel_rod, datum/rbmk_fuel_recipe/recipe)
	if(!fuel_rod?.is_depleted() || !recipe?.input_rod_type)
		return FALSE
	return istype(fuel_rod, recipe.input_rod_type)

/// Counts held rods that satisfy an extraction recipe.
/obj/machinery/rbmk/fuel_processor/proc/count_matching_inserted_rods(datum/rbmk_fuel_recipe/recipe)
	var/matching_rods = 0
	for(var/obj/item/rbmk/fuel_rod/fuel_rod as anything in inserted_rods)
		if(rod_matches_recipe(fuel_rod, recipe))
			matching_rods++
	return matching_rods

/// Returns whether the linked material container can pay a recipe's base cost.
/obj/machinery/rbmk/fuel_processor/proc/recipe_materials_available(datum/rbmk_fuel_recipe/recipe)
	if(!length(recipe?.material_cost))
		return FALSE
	if(!materials?.mat_container || !materials.can_use_resource())
		return FALSE
	return materials.mat_container.has_materials(recipe.material_cost, 1, 1)

/// Returns whether a recipe should be expanded in the initial TGUI view.
/obj/machinery/rbmk/fuel_processor/proc/recipe_visible_by_default(datum/rbmk_fuel_recipe/recipe)
	if(current_recipe == recipe)
		return TRUE
	if(recipe.input_rod_type)
		return count_matching_inserted_rods(recipe) > 0
	return recipe_materials_available(recipe)

/// Returns the extraction recipe that accepts a depleted rod.
/obj/machinery/rbmk/fuel_processor/proc/get_extraction_recipe_for_rod(obj/item/rbmk/fuel_rod/fuel_rod)
	if(!fuel_rod?.is_depleted())
		return null
	for(var/recipe_type in GLOB.rbmk_fuel_recipes)
		var/datum/rbmk_fuel_recipe/recipe = GLOB.rbmk_fuel_recipes[recipe_type]
		if(recipe.input_rod_type && istype(fuel_rod, recipe.input_rod_type))
			return recipe
	return null

/// Returns a player-facing reason a recipe cannot start, or null when it is ready.
/obj/machinery/rbmk/fuel_processor/proc/get_recipe_block_reason(datum/rbmk_fuel_recipe/recipe, check_power = TRUE, batch_size = 1)
	if(!recipe)
		return "Unknown recipe."
	batch_size = clamp(round(batch_size), 1, RBMK_PROCESSOR_MAX_BATCH)
	if(current_recipe)
		return "Machine is already processing."
	if(machine_stat & BROKEN)
		return "Machine is broken."
	if(check_power && (machine_stat & NOPOWER))
		return "Machine has no power."
	if(panel_open)
		return "Maintenance panel is open."
	if(has_output_items())
		return "Output tray is occupied."
	if(length(inserted_rods) && !recipe.input_rod_type)
		return "Depleted fuel rods are loaded."
	if(recipe.input_rod_type && !length(inserted_rods))
		return "Requires a depleted fuel rod."
	if(recipe.input_rod_type && count_matching_inserted_rods(recipe) < batch_size)
		var/obj/item/rbmk/fuel_rod/input_rod = recipe.input_rod_type
		return "Requires [batch_size] depleted [lowertext(initial(input_rod.name))]\s."
	if(length(recipe.material_cost))
		if(!materials?.mat_container)
			return "No linked material storage."
		if(!materials.can_use_resource())
			return "Linked material storage is unavailable."
		if(!materials.mat_container.has_materials(recipe.material_cost, 1, batch_size))
			return "Insufficient linked materials."
	return null

/// Finds the largest currently valid batch for a recipe, up to the configured cap.
/obj/machinery/rbmk/fuel_processor/proc/get_recipe_max_batch(datum/rbmk_fuel_recipe/recipe)
	for(var/batch_size in RBMK_PROCESSOR_MAX_BATCH to 1 step -1)
		if(isnull(get_recipe_block_reason(recipe, TRUE, batch_size)))
			return batch_size
	return 0

/// Starts a validated recipe and schedules its completion.
/obj/machinery/rbmk/fuel_processor/proc/start_recipe(recipe_reference, mob/user, batch_size = 1)
	var/datum/rbmk_fuel_recipe/recipe = get_recipe(recipe_reference)
	batch_size = text2num("[batch_size]")
	if(!isnum(batch_size))
		return FALSE
	batch_size = clamp(round(batch_size), 1, RBMK_PROCESSOR_MAX_BATCH)
	var/block_reason = get_recipe_block_reason(recipe, TRUE, batch_size)
	if(block_reason)
		if(user)
			to_chat(user, span_warning(block_reason))
		return FALSE
	current_recipe = recipe
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
			span_notice("You start [recipe.name] for a batch of [batch_size]."),
		)
	addtimer(CALLBACK(src, PROC_REF(finish_recipe), recipe, batch_size), process_time)
	return TRUE

/// Revalidates and completes an active recipe, consuming inputs and creating output.
/obj/machinery/rbmk/fuel_processor/proc/finish_recipe(datum/rbmk_fuel_recipe/recipe, batch_size)
	if(QDELETED(src))
		return
	if(current_recipe != recipe || current_batch_size != batch_size)
		return
	current_recipe = null
	current_batch_size = 0
	process_started_at = 0
	process_ends_at = 0
	update_use_power(IDLE_POWER_USE)
	var/block_reason = get_recipe_block_reason(recipe, FALSE, batch_size)
	if(block_reason)
		update_appearance(UPDATE_ICON)
		SStgui.update_uis(src)
		return
	if(length(recipe.material_cost))
		materials.use_materials(recipe.material_cost, 1, batch_size, "fabricated", recipe.name)
	if(recipe.output_type)
		for(var/index in 1 to batch_size)
			create_output(recipe.output_type)
	if(recipe.extracted_sheet_type)
		create_sheet_output(recipe.extracted_sheet_type, RBMK_PROCESSOR_RECOVERED_SHEETS * batch_size)
	if(recipe.input_rod_type)
		for(var/index in 1 to batch_size)
			create_output(/obj/item/rbmk/spent_fuel_casing)
	if(recipe.input_rod_type)
		var/rods_consumed = 0
		for(var/obj/item/rbmk/fuel_rod/inserted_rod as anything in inserted_rods.Copy())
			if(!rod_matches_recipe(inserted_rod, recipe))
				continue
			inserted_rods -= inserted_rod
			qdel(inserted_rod)
			rods_consumed++
			if(rods_consumed >= batch_size)
				break
	update_appearance(UPDATE_ICON)
	SStgui.update_uis(src)

/// Creates and tracks one output atom on the processor's output tile.
/obj/machinery/rbmk/fuel_processor/proc/create_output(output_type)
	if(!output_type)
		return null
	var/atom/movable/created = new output_type(get_processor_output_location())
	output_items += created
	return created

/// Creates and tracks an isotope sheet stack on the processor's output tile.
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

/// Returns the turf immediately in front of the processor, falling back to its own turf.
/obj/machinery/rbmk/fuel_processor/proc/get_processor_output_location()
	var/turf/output_turf = get_step(src, EAST)
	if(output_turf && !isclosedturf(output_turf))
		return output_turf
	return drop_location()

/// Validates whether a rod can be transferred into the processor.
/obj/machinery/rbmk/fuel_processor/proc/can_accept_rod(obj/item/rbmk/fuel_rod/fuel_rod, mob/user)
	if(!fuel_rod)
		return FALSE
	if(current_recipe)
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
	if(!get_extraction_recipe_for_rod(fuel_rod))
		if(user)
			to_chat(user, span_warning("[fuel_rod] has no viable processing path. Treat it as radioactive waste."))
		return FALSE
	return TRUE

/obj/machinery/rbmk/fuel_processor/item_interaction(mob/living/user, obj/item/used_item, list/modifiers)
	if(istype(used_item, /obj/item/rbmk/fuel_rod))
		var/obj/item/rbmk/fuel_rod/fuel_rod = used_item
		if(!can_accept_rod(fuel_rod, user))
			return ITEM_INTERACT_FAILURE
		if(!user.transferItemToLoc(fuel_rod, src))
			return ITEM_INTERACT_FAILURE
		inserted_rods += fuel_rod
		user.visible_message(
			span_notice("[user] loads [fuel_rod] into [src]."),
			span_notice("You load [fuel_rod] into [src]."),
		)
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		update_appearance(UPDATE_ICON)
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/// Ejects one held fuel rod selected by its server-validated list index.
/obj/machinery/rbmk/fuel_processor/proc/eject_inserted_rod(rod_index, mob/user)
	if(current_recipe)
		if(user)
			balloon_alert(user, "processing")
		return FALSE
	rod_index = text2num("[rod_index]")
	if(!isnum(rod_index))
		return FALSE
	rod_index = round(rod_index)
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

/// Ejects one completed output selected by its server-validated list index.
/obj/machinery/rbmk/fuel_processor/proc/eject_output(output_index, mob/user)
	if(current_recipe)
		if(user)
			balloon_alert(user, "processing")
		return FALSE
	output_index = text2num("[output_index]")
	if(!isnum(output_index))
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

/// Builds the inserted-rod records displayed by TGUI.
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

/// Builds the completed-output records displayed by TGUI.
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

/// Builds one recipe record with costs, availability, and batch limits for TGUI.
/obj/machinery/rbmk/fuel_processor/proc/get_recipe_data(datum/rbmk_fuel_recipe/recipe)
	var/block_reason = get_recipe_block_reason(recipe)
	return list(
		"id" = "[recipe.type]",
		"name" = recipe.name,
		"description" = recipe.description,
		"cost" = get_recipe_cost_map(recipe),
		"requires_inserted_rod" = !isnull(recipe.input_rod_type),
		"visible" = recipe_visible_by_default(recipe),
		"can_start" = isnull(block_reason),
		"block_reason" = block_reason,
		"max_batch" = get_recipe_max_batch(recipe),
	)

/// Builds the ordered recipe list exposed to TGUI.
/obj/machinery/rbmk/fuel_processor/proc/get_all_recipe_data()
	var/list/recipe_data = list()
	for(var/recipe_type in GLOB.rbmk_fuel_recipes)
		var/datum/rbmk_fuel_recipe/recipe = GLOB.rbmk_fuel_recipes[recipe_type]
		recipe_data += list(get_recipe_data(recipe))
	return recipe_data

/obj/machinery/rbmk/fuel_processor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials),
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
	data["processing"] = !isnull(current_recipe)
	data["current_process"] = current_recipe?.name
	data["current_batch_size"] = current_batch_size
	data["process_progress"] = get_process_progress()
	data["inserted_rods"] = get_inserted_rods_data()
	data["max_batch_size"] = RBMK_PROCESSOR_MAX_BATCH
	data["output_items"] = get_output_items_data()
	data["recipes"] = get_all_recipe_data()
	data["materials"] = materials?.mat_container ? materials.mat_container.ui_data() : list()
	data["onHold"] = materials ? materials.on_hold() : FALSE
	return data

/obj/machinery/rbmk/fuel_processor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .
	var/mob/user = ui.user
	switch(action)
		if("start")
			var/recipe_reference = params["recipe"]
			if(!istext(recipe_reference))
				return FALSE
			return start_recipe(recipe_reference, user, params["quantity"])
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
			if(!isnum(amount) || amount <= 0)
				return FALSE
			materials.eject_sheets(material, amount, get_processor_output_location())
			playsound(src, 'sound/machines/click.ogg', 50, TRUE)
			update_appearance(UPDATE_ICON)
			SStgui.update_uis(src)
			return TRUE
	return FALSE

#undef RBMK_PROCESSOR_RECOVERED_SHEETS
#undef RBMK_PROCESSOR_PROCESS_TIME
#undef RBMK_PROCESSOR_ADDITIONAL_ITEM_TIME
#undef RBMK_PROCESSOR_MAX_BATCH
