/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using iron, glass, plastic and maybe some more."
	icon_state = "autolathe"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	circuit = /obj/item/circuitboard/machine/autolathe
	layer = BELOW_OBJ_LAYER
	processing_flags = NONE
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_MOUSEDROP_IGNORE_CHECKS

	var/hacked = FALSE
	var/disabled = FALSE
	var/shocked = FALSE
	var/busy = FALSE

	/// Coefficient applied to consumed materials. Lower values result in lower material consumption.
	var/creation_efficiency = 1.6

	var/datum/design/being_built
	var/datum/techweb/autounlocking/stored_research

	///Designs imported from technology disks that we can print.
	var/list/imported_designs = list()

	///The container to hold materials
	var/datum/component/material_container/materials

/obj/machinery/autolathe/Initialize(mapload)
	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_ITEM_MATERIAL], \
		0, \
		MATCONTAINER_EXAMINE, \
		container_signals = list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/autolathe, AfterMaterialInsert)) \
	)
	. = ..()

	set_wires(new /datum/wires/autolathe(src))
	if(!GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe])
		GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe] = new /datum/techweb/autounlocking/autolathe
	stored_research = GLOB.autounlock_techwebs[/datum/techweb/autounlocking/autolathe]

/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	materials = null
	return ..()

/obj/machinery/autolathe/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return

	if(shocked && !(machine_stat & NOPOWER))
		shock(user, 50)

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Autolathe")
		ui.open()

/obj/machinery/autolathe/ui_static_data(mob/user)
	var/list/data = materials.ui_static_data()

	data["designs"] = handle_designs(stored_research.researched_designs)
	if(imported_designs.len)
		data["designs"] += handle_designs(imported_designs)
	if(hacked)
		data["designs"] += handle_designs(stored_research.hacked_designs)

	return data

/obj/machinery/autolathe/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = list()

	data["materialtotal"] = materials.total_amount()
	data["materialsmax"] = materials.max_amount
	data["active"] = busy
	data["materials"] = materials.ui_data()

	return data

/obj/machinery/autolathe/proc/handle_designs(list/designs)
	var/list/output = list()

	var/datum/asset/spritesheet_batched/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet_batched/research_designs)
	var/size32x32 = "[spritesheet.name]32x32"

	var/max_multiplier = INFINITY
	for(var/design_id in designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(design.make_reagent)
			continue

		//compute cost & maximum number of printable items
		max_multiplier = INFINITY
		var/coeff = (ispath(design.build_path, /obj/item/stack) ? 1 : creation_efficiency)
		var/list/cost = list()
		for(var/i in design.materials)
			var/datum/material/mat = i

			var/design_cost = OPTIMAL_COST(design.materials[i] * coeff)
			if(istype(mat))
				cost[mat.name] = design_cost
			else
				cost[i] = design_cost

			max_multiplier = min(max_multiplier, 50, round((istype(mat) ? materials.get_material_amount(i) : 0) / design_cost))

		//create & send ui data
		var/icon_size = spritesheet.icon_size_id(design.id)

		var/list/design_data = list(
			"name" = design.name,
			"desc" = design.get_description(),
			"cost" = cost,
			"id" = design.id,
			"categories" = design.category,
			"icon" = "[icon_size == size32x32 ? "" : "[icon_size] "][design.id]",
			"constructionTime" = -1,
			"maxmult" = max_multiplier
		)

		output += list(design_data)

	return output

/obj/machinery/autolathe/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet_batched/research_designs),
	)

/obj/machinery/autolathe/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(action == "make")
		if(disabled)
			say("The autolathe wires are disabled.")
			return
		if(busy)
			say("The autolathe is busy. Please wait for completion of previous operation.")
			return

		var/design_id = params["id"]
		if(!istext(design_id))
			return
		if(!stored_research.researched_designs.Find(design_id) && !stored_research.hacked_designs.Find(design_id) && !imported_designs.Find(design_id))
			return
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(!(design.build_type & AUTOLATHE) || design.id != design_id)
			return

		being_built = design
		var/is_stack = ispath(being_built.build_path, /obj/item/stack)
		var/coeff = (is_stack ? 1 : creation_efficiency) // Stacks are unaffected by production coefficient

		var/multiplier = round(text2num(params["multiplier"]))
		if(!multiplier || !IS_FINITE(multiplier))
			return
		multiplier = clamp(multiplier, 1, 50)

		//check for materials
		var/list/materials_used = list()
		var/list/custom_materials = list() // These will apply their material effect, should usually only be one.
		for(var/mat in being_built.materials)
			var/datum/material/used_material = mat

			var/amount_needed = being_built.materials[mat]
			if(istext(used_material)) // This means its a category
				var/list/list_to_show = list()
				//list all materials in said category
				for(var/i in SSmaterials.materials_by_category[used_material])
					if(materials.materials[i] > 0)
						list_to_show += i
				//ask user to pick specific material from list
				used_material = tgui_input_list(
					usr,
					"Choose [used_material]",
					"Custom Material",
					sort_list(list_to_show, GLOBAL_PROC_REF(cmp_typepaths_asc))
				)
				if(isnull(used_material))
					// Didn't pick any material, so you can't build shit either.
					return
				custom_materials[used_material] += amount_needed
			materials_used[used_material] = amount_needed

		if(!materials.has_materials(materials_used, coeff, multiplier))
			say("Not enough materials for this operation!.")
			return

		//use power
		var/total_amount = 0
		for(var/material in being_built.materials)
			total_amount += being_built.materials[material]
		use_power(max(active_power_usage, (total_amount) * multiplier / 5))

		//use materials
		materials.use_materials(materials_used, coeff, multiplier)
		busy = TRUE
		to_chat(usr, span_notice("You print [multiplier] item(s) from the [src]"))
		update_static_data_for_all_viewers()
		//print item
		icon_state = "autolathe_n"
		var/time = is_stack ? 32 : (32 * coeff * multiplier) ** 0.8
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/autolathe, make_item), custom_materials, multiplier, is_stack, usr), time)

		return TRUE

/**
 * Callback for start_making, actually makes the item
 * Arguments
 *
 * * datum/design/design - the design we are trying to print
 * * items_remaining - the number of designs left out to print
 * * build_time_per_item - the time taken to print 1 item
 * * material_cost_coefficient - the cost efficiency to print 1 design
 * * charge_per_item - the amount of power to print 1 item
 * * list/materials_needed - the list of materials to print 1 item
 * * turf/target - the location to drop the printed item on
*/
/obj/machinery/autolathe/proc/do_make_item(datum/design/design, items_remaining, build_time_per_item, material_cost_coefficient, charge_per_item, list/materials_needed, turf/target)
	PROTECTED_PROC(TRUE)

	if(items_remaining <= 0) // how
		finalize_build()
		return

	if(!is_operational)
		say("Unable to continue production, power failure.")
		finalize_build()
		return

	if(!directly_use_energy(charge_per_item)) // provide the wait time until lathe is ready
		var/area/my_area = get_area(src)
		var/obj/machinery/power/apc/my_apc = my_area.apc
		if(!QDELETED(my_apc))
			var/charging_wait = my_apc.time_to_charge(charge_per_item)
			if(!isnull(charging_wait))
				say("Unable to continue production, APC overload. Wait [DisplayTimeText(charging_wait, round_seconds_to = 1)] and try again.")
			else
				say("Unable to continue production, power grid overload.")
		else
			say("Unable to continue production, no APC in area.")
		finalize_build()
		return

	var/is_stack = ispath(design.build_path, /obj/item/stack)
	if(!materials.has_materials(materials_needed, material_cost_coefficient, is_stack ? items_remaining : 1))
		say("Unable to continue production, missing materials.")
		finalize_build()
		return
	materials.use_materials(materials_needed, material_cost_coefficient, is_stack ? items_remaining : 1)

	var/atom/movable/created
	if(is_stack)
		created = new design.build_path(target, items_remaining)
	else
		created = new design.build_path(target)
		split_materials_uniformly(materials_needed, material_cost_coefficient, created)

	created.pixel_x = created.base_pixel_x + rand(-6, 6)
	created.pixel_y = created.base_pixel_y + rand(-6, 6)
	created.forceMove(target)
	SSblackbox.record_feedback("nested tally", "lathe_printed_items", 1, list("[type]", "[created.type]"))

	if(is_stack)
		items_remaining = 0
	else
		items_remaining -= 1

	if(items_remaining <= 0)
		finalize_build()
		return
	addtimer(CALLBACK(src, PROC_REF(do_make_item), design, items_remaining, build_time_per_item, material_cost_coefficient, charge_per_item, materials_needed, target), build_time_per_item)

/**
 * Resets the icon state and busy flag
 * Called at the end of do_make_item's timer loop
*/
/obj/machinery/autolathe/proc/finalize_build()
	PROTECTED_PROC(TRUE)

	icon_state = initial(icon_state)
	busy = FALSE
	SStgui.update_uis(src)

/obj/machinery/autolathe/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!can_interact(user) || (!HAS_SILICON_ACCESS(user) && !isAdminGhostAI(user)) && !Adjacent(user))
		return
	if(busy)
		balloon_alert(user, "printing started!")
		return
	var/direction = get_dir(src, over_location)
	if(!direction)
		return
	drop_direction = direction
	balloon_alert(user, "dropping [dir2text(drop_direction)]")

/obj/machinery/autolathe/click_alt(mob/user)
	if(!drop_direction)
		return CLICK_ACTION_BLOCKING
	if(busy)
		balloon_alert(user, "busy printing!")
		return CLICK_ACTION_SUCCESS
	balloon_alert(user, "drop direction reset")
	drop_direction = 0
	return CLICK_ACTION_SUCCESS

/obj/machinery/autolathe/attackby(obj/item/attacking_item, mob/living/user, params)
	if(busy)
		balloon_alert(user, "it's busy!")
		return TRUE

	if(default_deconstruction_crowbar(attacking_item))
		return TRUE

	if(panel_open && is_wire_tool(attacking_item))
		wires.interact(user)
		return TRUE

	if((user.istate & ISTATE_HARM)) //so we can hit the machine
		return ..()

	if(machine_stat)
		return TRUE

	if(istype(attacking_item, /obj/item/disk/design_disk))
		user.visible_message(span_notice("[user] begins to load \the [attacking_item] in \the [src]..."),
			balloon_alert(user, "uploading design..."),
			span_hear("You hear the chatter of a floppy drive."))
		busy = TRUE
		if(do_after(user, 14.4, target = src))
			var/obj/item/disk/design_disk/disky = attacking_item
			var/list/not_imported
			for(var/datum/design/blueprint as anything in disky.blueprints)
				if(!blueprint)
					continue
				if(blueprint.build_type & AUTOLATHE)
					imported_designs += blueprint.id
				else
					LAZYADD(not_imported, blueprint.name)
			if(not_imported)
				to_chat(user, span_warning("The following design[length(not_imported) > 1 ? "s" : ""] couldn't be imported: [english_list(not_imported)]"))
		busy = FALSE
		update_static_data_for_all_viewers()
		return TRUE

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return FALSE

	if(istype(attacking_item, /obj/item/storage/bag/trash))
		for(var/obj/item/content_item in attacking_item.contents)
			if(!do_after(user, 0.5 SECONDS, src))
				return FALSE
			attackby(content_item, user)
		return TRUE

	return ..()

/obj/machinery/autolathe/attackby_secondary(obj/item/weapon, mob/living/user, params)
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(busy)
		balloon_alert(user, "it's busy!")
		return

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", weapon))
		return

	if(machine_stat)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/machinery/autolathe/proc/AfterMaterialInsert(container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	if(ispath(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(SHEET_MATERIAL_AMOUNT / 10)
	else if(item_inserted.has_material_type(/datum/material/glass))
		flick("autolathe_r", src)//plays glass insertion animation by default otherwise
	else
		flick("autolathe_o", src)//plays metal insertion animation

		use_power(min(active_power_usage * 0.25, amount_inserted / 100))
		update_static_data_for_all_viewers()

/obj/machinery/autolathe/proc/make_item(list/picked_materials, multiplier, is_stack, mob/user)
	var/atom/A = drop_location()

	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier, FALSE)
		N.update_appearance()
	else
		for(var/i in 1 to multiplier)
			var/obj/item/new_item = new being_built.build_path(A)

			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials, 1 / multiplier) //Ensure we get the non multiplied amount
				for(var/x in picked_materials)
					var/datum/material/M = x
					if(!istype(M, /datum/material/glass) && !istype(M, /datum/material/iron))
						user.client.give_award(/datum/award/achievement/misc/getting_an_upgrade, user)

	icon_state = "autolathe"
	busy = FALSE
	SStgui.update_uis(src) // monkestation edit: try to ensure UI always updates

/obj/machinery/autolathe/RefreshParts()
	. = ..()
	var/mat_capacity = 0
	for(var/datum/stock_part/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.tier * (37.5*SHEET_MATERIAL_AMOUNT)
	materials.max_amount = mat_capacity

	var/efficiency=1.8
	for(var/datum/stock_part/manipulator/new_manipulator in component_parts)
		efficiency -= new_manipulator.tier * 0.2
	creation_efficiency = max(1,efficiency) // creation_efficiency goes 1.6 -> 1.4 -> 1.2 -> 1 per level of manipulator efficiency

/obj/machinery/autolathe/examine(mob/user)
	. += ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[creation_efficiency*100]%</b>.")

/obj/machinery/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER)) // unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/autolathe/proc/adjust_hacked(state)
	hacked = state
	update_static_data_for_all_viewers()

/obj/machinery/autolathe/hacked/Initialize(mapload)
	. = ..()
	adjust_hacked(TRUE)
