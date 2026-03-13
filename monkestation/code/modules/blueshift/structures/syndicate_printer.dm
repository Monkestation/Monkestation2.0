/// A Syndicate-manufactured alternate rapid construction fabricator with its own recipe list.

/obj/machinery/rnd/production/colony_lathe/syndicate
	name = "Omnilathe"
	desc = "A sleek, unmarked fabrication unit of Cybersun industries. Capable of producing advanced munitions and hacked autolathe designs. It has drive slots for accepting techfab circuit boards to unlock additional design sets."
	allowed_buildtypes = AUTOLATHE
	ui_theme = "syndicate"
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 2
	link_on_init = FALSE
	repacked_type = /obj/item/storage/toolbox/emergency/omnilathe
	/// Current UI mode: lathe or ammo workbench.
	var/machine_mode = "lathe"
	/// Inserted ammo container to fill while in ammo mode.
	var/obj/item/ammo_box/loaded_magazine = null
	/// All ammo typepaths compatible with the loaded magazine.
	var/list/possible_ammo_types = list()
	/// Valid, printable casing typepaths for the current magazine.
	var/list/valid_casings = list()
	/// Material requirement strings matching the casing list.
	var/list/casing_mat_strings = list()
	/// Can print harmful ammo types.
	var/allowed_harmful = TRUE
	/// Can print advanced ammo types.
	var/allowed_advanced = TRUE
	/// Material cost multiplier per round in ammo mode.
	var/creation_efficiency = 1.0
	/// Time per round in ammo mode.
	var/time_per_round = 0.4 SECONDS
	/// Whether ammo fill loop is running.
	var/ammo_busy = FALSE
	/// Timer id for ammo fill loop.
	var/ammo_timer_id
	/// Ammo mode error message shown in UI.
	var/ammo_error_message = ""
	/// Ammo mode error color/type shown in UI.
	var/ammo_error_type = ""
	/// Designs imported from technology disks.
	var/list/imported_designs = list()
	/// Packed snapshot of local material amounts, keyed by material typepath.
	var/list/packed_materials = list()
	/// Which lathe recipe family is currently active in lathe mode.
	var/lathe_recipe_set = "autolathe"
	/// Additional recipe families unlocked by inserting matching machine boards.
	var/list/unlocked_techfab_departments = list()

/obj/machinery/rnd/production/colony_lathe/syndicate/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	AddElement(/datum/element/manufacturer_examine, COMPANY_CYBERSUN)
	if(soundloop)
		soundloop.volume = 50
	// This variant is intended to run on local storage and accept broader item inputs.
	if(materials?.mat_container)
		materials.mat_container.allowed_item_typecache = null
	update_ammotypes()

/obj/machinery/rnd/production/colony_lathe/syndicate/Destroy()
	if(ammo_timer_id)
		deltimer(ammo_timer_id)
		ammo_timer_id = null
	if(loaded_magazine)
		loaded_magazine.forceMove(drop_location())
		loaded_magazine = null
	return ..()

/obj/machinery/rnd/production/colony_lathe/syndicate/RefreshParts()
	. = ..()
	// Flatpacker original code is stupid and uses stock parts but doesnt have stock parts so I just hardcode ts
	if(materials && !materials.silo)
		materials.set_local_size(500 * SHEET_MATERIAL_AMOUNT)
	efficiency_coeff = 1
	creation_efficiency = 1.0
	time_per_round = 0.4 SECONDS
	update_ammotypes()


/obj/machinery/rnd/production/colony_lathe/syndicate/proc/rebuild_cached_designs()
	var/previous_design_count = cached_designs.len
	cached_designs.Cut()

	if(lathe_recipe_set == "autolathe")
		for(var/design_id in SSresearch.techweb_designs)
			var/datum/design/design = SSresearch.techweb_designs[design_id]
			if(!(design.build_type & AUTOLATHE))
				continue
			if(!(RND_CATEGORY_INITIAL in design.category) && !(RND_CATEGORY_HACKED in design.category))
				continue
			cached_designs |= design

		for(var/design_id in imported_designs)
			var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
			if(design && !(design in cached_designs))
				cached_designs |= design
	else if(findtext(lathe_recipe_set, "techfab_") == 1)
		var/department_flag = get_techfab_department_flag(lathe_recipe_set)
		if(!department_flag)
			lathe_recipe_set = "autolathe"
			return rebuild_cached_designs()
		var/datum/techweb/research_source = SSresearch.science_tech
		if(isnull(research_source))
			return

		for(var/design_id in research_source.researched_designs)
			var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
			if(!istype(design))
				continue
			if(!(design.build_type & (PROTOLATHE | IMPRINTER)))
				continue
			if(!(design.departmental_flags & department_flag))
				continue
			cached_designs |= design
	else
		var/datum/techweb/research_source = SSresearch.science_tech
		if(isnull(research_source))
			return

		var/buildtype_mask = NONE
		var/department_flag = null
		switch(lathe_recipe_set)
			if("mechfab")
				buildtype_mask = MECHFAB
			if("imprinter")
				buildtype_mask = IMPRINTER
			if("imprinter_away")
				buildtype_mask = AWAY_IMPRINTER
			if("imprinter_department")
				buildtype_mask = IMPRINTER
			if("imprinter_department_science")
				buildtype_mask = IMPRINTER
				department_flag = DEPARTMENT_BITFLAG_SCIENCE
			if("imprinter_department_engineering")
				buildtype_mask = IMPRINTER
				department_flag = DEPARTMENT_BITFLAG_ENGINEERING
		if(!buildtype_mask)
			lathe_recipe_set = "autolathe"
			return rebuild_cached_designs()

		for(var/design_id in research_source.researched_designs)
			var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
			if(!istype(design))
				continue
			if(!(design.build_type & buildtype_mask))
				continue
			if(!isnull(department_flag) && !(design.departmental_flags & department_flag))
				continue
			cached_designs |= design

	var/design_delta = cached_designs.len - previous_design_count
	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/twobeep_high.ogg', 25, TRUE)

	update_static_data_for_all_viewers()

/obj/machinery/rnd/production/colony_lathe/syndicate/update_designs()
	rebuild_cached_designs()

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/build_packed_material_cache()
	packed_materials = list()
	if(!materials?.mat_container)
		return

	for(var/datum/material/material_ref as anything in materials.mat_container.materials)
		var/amount = materials.mat_container.materials[material_ref]
		if(amount > 0)
			packed_materials[material_ref.type] = amount

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/prepare_for_packing()
	build_packed_material_cache()
	if(!materials?.mat_container)
		return

	for(var/datum/material/material_ref as anything in materials.mat_container.materials)
		materials.mat_container.materials[material_ref] = 0

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/transfer_contents_to_packed_item(obj/item/new_pack)
	if(!new_pack)
		return

	atom_storage?.remove_all(new_pack)
	for(var/obj/item/stored_item in contents)
		if(stored_item?.loc == src)
			stored_item.forceMove(new_pack)

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/restore_packed_material_cache()
	if(!packed_materials?.len || !materials?.mat_container)
		return

	for(var/material_type in packed_materials)
		var/amount = packed_materials[material_type]
		if(amount <= 0)
			continue
		var/datum/material/material_ref = GET_MATERIAL_REF(material_type)
		if(!material_ref)
			continue
		materials.mat_container.insert_amount_mat(amount, material_ref)

	packed_materials = list()

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/get_techfab_department_flag(recipe_set)
	switch(recipe_set)
		if("techfab_engineering")
			return DEPARTMENT_BITFLAG_ENGINEERING
		if("techfab_service")
			return DEPARTMENT_BITFLAG_SERVICE
		if("techfab_medical")
			return DEPARTMENT_BITFLAG_MEDICAL
		if("techfab_cargo")
			return DEPARTMENT_BITFLAG_CARGO
		if("techfab_science")
			return DEPARTMENT_BITFLAG_SCIENCE
		if("techfab_security")
			return DEPARTMENT_BITFLAG_SECURITY
	return null

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/get_recipe_set_name(recipe_set)
	switch(recipe_set)
		if("autolathe")
			return "Autolathe"
		if("techfab_engineering")
			return "Techfab - Engineering"
		if("techfab_service")
			return "Techfab - Service"
		if("techfab_medical")
			return "Techfab - Medical"
		if("techfab_cargo")
			return "Techfab - Cargo"
		if("techfab_science")
			return "Techfab - Science"
		if("techfab_security")
			return "Techfab - Security"
		if("mechfab")
			return "Exosuit Fabricator"
		if("imprinter")
			return "Circuit Imprinter"
		if("imprinter_away")
			return "Ancient Circuit Imprinter"
		if("imprinter_department")
			return "Department Circuit Imprinter"
		if("imprinter_department_science")
			return "Department Circuit Imprinter - Science"
		if("imprinter_department_engineering")
			return "Department Circuit Imprinter - Engineering"
	return "Autolathe"

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/get_available_recipe_sets()
	var/list/available_sets = list("autolathe")
	if(unlocked_techfab_departments["techfab_engineering"])
		available_sets += "techfab_engineering"
	if(unlocked_techfab_departments["techfab_service"])
		available_sets += "techfab_service"
	if(unlocked_techfab_departments["techfab_medical"])
		available_sets += "techfab_medical"
	if(unlocked_techfab_departments["techfab_cargo"])
		available_sets += "techfab_cargo"
	if(unlocked_techfab_departments["techfab_science"])
		available_sets += "techfab_science"
	if(unlocked_techfab_departments["techfab_security"])
		available_sets += "techfab_security"
	if(unlocked_techfab_departments["mechfab"])
		available_sets += "mechfab"
	if(unlocked_techfab_departments["imprinter"])
		available_sets += "imprinter"
	if(unlocked_techfab_departments["imprinter_away"])
		available_sets += "imprinter_away"
	if(unlocked_techfab_departments["imprinter_department"])
		available_sets += "imprinter_department"
	if(unlocked_techfab_departments["imprinter_department_science"])
		available_sets += "imprinter_department_science"
	if(unlocked_techfab_departments["imprinter_department_engineering"])
		available_sets += "imprinter_department_engineering"
	return available_sets

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/get_techfab_set_from_board(obj/item/circuitboard/machine/techfab/department/board)
	if(istype(board, /obj/item/circuitboard/machine/techfab/department/engineering))
		return "techfab_engineering"
	if(istype(board, /obj/item/circuitboard/machine/techfab/department/service))
		return "techfab_service"
	if(istype(board, /obj/item/circuitboard/machine/techfab/department/medical))
		return "techfab_medical"
	if(istype(board, /obj/item/circuitboard/machine/techfab/department/cargo))
		return "techfab_cargo"
	if(istype(board, /obj/item/circuitboard/machine/techfab/department/science))
		return "techfab_science"
	if(istype(board, /obj/item/circuitboard/machine/techfab/department/security))
		return "techfab_security"
	return null

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/get_recipe_set_from_board(obj/item/circuitboard/machine/board)
	if(istype(board, /obj/item/circuitboard/machine/techfab/department))
		return get_techfab_set_from_board(board)
	if(istype(board, /obj/item/circuitboard/machine/mechfab))
		return "mechfab"
	if(istype(board, /obj/item/circuitboard/machine/circuit_imprinter/offstation))
		return "imprinter_away"
	if(istype(board, /obj/item/circuitboard/machine/circuit_imprinter/department/science))
		return "imprinter_department_science"
	if(istype(board, /obj/item/circuitboard/machine/circuit_imprinter/department))
		return "imprinter_department"
	if(istype(board, /obj/item/circuitboard/machine/circuit_imprinter))
		return "imprinter"
	return null

/obj/machinery/rnd/production/colony_lathe/syndicate/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/circuitboard/machine) && istype(user, /mob/living))
		if(machine_stat)
			return ITEM_INTERACT_BLOCKING
		var/mob/living/living_user = user
		var/obj/item/circuitboard/machine/board = attacking_item
		var/recipe_set = get_recipe_set_from_board(board)
		if(isnull(recipe_set))
			return ITEM_INTERACT_BLOCKING
		if(unlocked_techfab_departments[recipe_set])
			balloon_alert(living_user, "department recipes already unlocked")
			return ITEM_INTERACT_BLOCKING
		if(!living_user.transferItemToLoc(attacking_item, src))
			return ITEM_INTERACT_BLOCKING
		living_user.visible_message(span_notice("[living_user] begins loading [attacking_item] into [src]..."),
			balloon_alert(living_user, "loading board..."),
			span_hear("You hear the chatter of a drive slot."))
		if(!do_after(living_user, 1.5 SECONDS, target = src))
			if(attacking_item?.loc == src)
				try_put_in_hand(attacking_item, living_user)
			balloon_alert(living_user, "interrupted!")
			return ITEM_INTERACT_BLOCKING
		qdel(attacking_item)
		unlocked_techfab_departments[recipe_set] = TRUE
		lathe_recipe_set = recipe_set
		rebuild_cached_designs()
		balloon_alert(living_user, "department recipes unlocked")
		return ITEM_INTERACT_SUCCESS

	if(istype(attacking_item, /obj/item/disk/design_disk) && istype(user, /mob/living))
		if(machine_stat)
			return ITEM_INTERACT_BLOCKING
		var/mob/living/living_user = user
		living_user.visible_message(span_notice("[living_user] begins to load [attacking_item] into [src]..."),
			balloon_alert(living_user, "uploading design..."),
			span_hear("You hear the chatter of a floppy drive."))
		if(!do_after(living_user, 1.5 SECONDS, target = src))
			balloon_alert(living_user, "interrupted!")
			return ITEM_INTERACT_BLOCKING
		var/obj/item/disk/design_disk/disky = attacking_item
		var/list/not_imported
		for(var/datum/design/blueprint as anything in disky.blueprints)
			if(!blueprint)
				continue
			if(blueprint.build_type & AUTOLATHE)
				imported_designs[blueprint.id] = TRUE
			else
				LAZYADD(not_imported, blueprint.name)
		if(not_imported)
			to_chat(living_user, span_warning("The following design[length(not_imported) > 1 ? "s" : ""] couldn't be imported: [english_list(not_imported)]"))
		rebuild_cached_designs()
		return ITEM_INTERACT_SUCCESS

	if(istype(attacking_item, /obj/item/ammo_box) && istype(user, /mob/living) && !(user.istate & ISTATE_HARM))
		var/mob/living/living_user = user
		if(!living_user.transferItemToLoc(attacking_item, src))
			return TRUE
		if(loaded_magazine)
			loaded_magazine.forceMove(drop_location())
			living_user.put_in_hands(loaded_magazine)
		loaded_magazine = attacking_item
		if(ammo_busy)
			ammo_fill_finish(FALSE)
		update_ammotypes()
		update_appearance()
		playsound(loc, 'sound/weapons/autoguninsert.ogg', 18, TRUE)
		return TRUE

	if(istype(user, /mob/living) && materials?.mat_container)
		var/mob/living/living_user = user
		materials.mat_container.user_insert(attacking_item, living_user, src)
		return TRUE

	return ..()

/obj/machinery/rnd/production/colony_lathe/syndicate/ui_data(mob/user)
	. = ..()

	.["machine_mode"] = machine_mode
	.["mode_toggle_label"] = machine_mode == "lathe" ? "Switch to Ammo Workbench" : "Switch to Lathe"
	var/list/available_sets = get_available_recipe_sets()
	var/list/set_options = list()
	for(var/set_id in available_sets)
		set_options += list(list(
			"displayText" = get_recipe_set_name(set_id),
			"value" = set_id,
		))
	.["lathe_recipe_label"] = get_recipe_set_name(lathe_recipe_set)
	.["lathe_recipe_set"] = lathe_recipe_set
	.["lathe_recipe_sets"] = set_options
	.["lathe_recipe_toggle_label"] = "Recipe Set"
	.["lathe_recipe_can_switch"] = length(available_sets) > 1
	.["mag_loaded"] = !!loaded_magazine
	.["system_busy"] = ammo_busy
	.["error"] = ammo_error_message
	.["error_type"] = ammo_error_type
	.["available_rounds"] = list()

	if(!loaded_magazine)
		if(machine_mode == "ammo" && !ammo_busy && !ammo_error_message)
			.["error"] = "NO MAGAZINE IS INSERTED"
		return

	.["mag_name"] = loaded_magazine.name
	.["current_rounds"] = length(loaded_magazine.stored_ammo)
	.["max_rounds"] = loaded_magazine.max_ammo

	for(var/casing_index in 1 to length(valid_casings))
		var/typepath = valid_casings[casing_index]
		.["available_rounds"] += list(list(
			"name" = valid_casings[typepath],
			"typepath" = typepath,
			"mats_list" = casing_mat_strings[casing_index]
		))

/obj/machinery/rnd/production/colony_lathe/syndicate/ui_act(action, list/params, datum/tgui/ui)
	if(action == "switch_mode")
		if(busy || ammo_busy)
			say("Warning: machine is busy!")
			return TRUE
		machine_mode = machine_mode == "lathe" ? "ammo" : "lathe"
		ammo_error_message = ""
		ammo_error_type = ""
		SStgui.update_uis(src)
		return TRUE

	if(action == "switch_recipe_set")
		if(machine_mode != "lathe" || busy || ammo_busy)
			return TRUE
		var/list/available_sets = get_available_recipe_sets()
		if(length(available_sets) <= 1)
			return TRUE
		var/current_index = available_sets.Find(lathe_recipe_set)
		if(!current_index)
			current_index = 1
		var/next_index = current_index + 1
		if(next_index > length(available_sets))
			next_index = 1
		lathe_recipe_set = available_sets[next_index]
		rebuild_cached_designs()
		SStgui.update_uis(src)
		return TRUE

	if(action == "set_recipe_set")
		if(machine_mode != "lathe" || busy || ammo_busy)
			return TRUE
		var/list/available_sets = get_available_recipe_sets()
		if(length(available_sets) <= 1)
			return TRUE
		var/selected_recipe_set = params["recipe_set"]
		if(!selected_recipe_set || !(selected_recipe_set in available_sets) || selected_recipe_set == lathe_recipe_set)
			return TRUE
		lathe_recipe_set = selected_recipe_set
		rebuild_cached_designs()
		SStgui.update_uis(src)
		return TRUE

	if(machine_mode == "lathe" && action == "build")
		if(busy)
			say("Warning: fabricator is busy!")
			return TRUE

		var/design_id = params["ref"]
		if(!design_id)
			return TRUE

		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(!istype(design) || !(design in cached_designs))
			return TRUE

		var/print_quantity = text2num(params["amount"])
		if(isnull(print_quantity))
			return TRUE
		print_quantity = clamp(print_quantity, 1, 50)

		var/coefficient = (ispath(design.build_path, /obj/item/stack/sheet) || ispath(design.build_path, /obj/item/stack/ore/bluespace_crystal)) ? 1 : efficiency_coeff
		if(!materials.can_use_resource())
			return TRUE
		if(!materials.mat_container.has_materials(design.materials, coefficient, print_quantity))
			say("Not enough materials to complete prototype[print_quantity > 1 ? "s" : ""].")
			return TRUE

		var/charge_per_item = 0
		for(var/material in design.materials)
			charge_per_item += design.materials[material]
		charge_per_item = ROUND_UP((charge_per_item / (MAX_STACK_SIZE * SHEET_MATERIAL_AMOUNT)) * coefficient * active_power_usage)
		var/build_time_per_item = (design.construction_time * design.lathe_time_factor * efficiency_coeff) ** 0.8

		busy = TRUE
		soundloop.start()
		set_light(l_outer_range = 1.5)
		icon_state = "colony_lathe_working"
		update_appearance()
		SStgui.update_uis(src)
		var/turf/target_location
		if(drop_direction)
			target_location = get_step(src, drop_direction)
			if(isclosedturf(target_location))
				target_location = get_turf(src)
		else
			target_location = get_turf(src)
		addtimer(CALLBACK(src, PROC_REF(do_make_item), design, print_quantity, build_time_per_item, coefficient, charge_per_item, target_location), build_time_per_item)
		return TRUE

	if(machine_mode == "ammo" && action == "build")
		return TRUE

	. = ..()
	if(.)
		return

	switch(action)
		if("EjectMag")
			eject_magazine()
			return TRUE
		if("FillMagazine")
			if(machine_mode != "ammo")
				return TRUE
			var/type_to_pass = text2path(params["selected_type"])
			fill_magazine_start(type_to_pass)
			return TRUE

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/eject_magazine(mob/living/user)
	if(loaded_magazine)
		loaded_magazine.forceMove(drop_location())
		if(user)
			try_put_in_hand(loaded_magazine, user)
		loaded_magazine = null
	if(ammo_busy)
		ammo_fill_finish(FALSE)
	ammo_error_message = ""
	ammo_error_type = ""
	update_ammotypes()
	update_appearance()

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/update_ammotypes()
	LAZYCLEARLIST(valid_casings)
	LAZYCLEARLIST(casing_mat_strings)
	if(!loaded_magazine)
		return

	var/obj/item/ammo_casing/ammo_type = loaded_magazine.ammo_type
	var/ammo_caliber = initial(ammo_type.caliber)
	var/obj/item/ammo_casing/ammo_parent_type = type2parent(ammo_type)

	if(loaded_magazine.multitype)
		if(ammo_caliber == initial(ammo_parent_type.caliber) && ammo_caliber != null)
			ammo_type = ammo_parent_type
		possible_ammo_types = typesof(ammo_type)
	else
		possible_ammo_types = list(ammo_type)

	for(var/obj/item/ammo_casing/our_casing as anything in possible_ammo_types)
		if(!(initial(our_casing.can_be_printed)))
			continue
		if(initial(our_casing.harmful) && !allowed_harmful)
			continue
		if(initial(our_casing.advanced_print_req) && !allowed_advanced)
			continue
		if(initial(our_casing.projectile_type) == null)
			continue

		var/obj/item/ammo_casing/casing_actual = new our_casing
		var/list/raw_casing_mats = casing_actual.get_material_composition()
		qdel(casing_actual)

		var/list/efficient_casing_mats = list()
		for(var/material in raw_casing_mats)
			efficient_casing_mats[material] = raw_casing_mats[material] * creation_efficiency

		var/mat_string = ""
		for(var/i in 1 to length(efficient_casing_mats))
			var/datum/material/our_material = efficient_casing_mats[i]
			mat_string += "[efficient_casing_mats[our_material]] cm^3 [our_material.name]"
			if(i == length(efficient_casing_mats))
				mat_string += " per cartridge"
			else
				mat_string += ", "

		valid_casings += our_casing
		valid_casings[our_casing] = initial(our_casing.name)
		casing_mat_strings += mat_string

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/fill_magazine_start(casing_type)
	if(machine_stat & (NOPOWER|BROKEN))
		if(ammo_busy)
			ammo_fill_finish(FALSE)
		return

	ammo_error_message = ""
	ammo_error_type = ""

	if(!(casing_type in possible_ammo_types))
		ammo_error_message = "AMMUNITION MISMATCH"
		ammo_error_type = "bad"
		return

	if(!loaded_magazine)
		ammo_error_message = "NO MAGAZINE INSERTED"
		return

	if(loaded_magazine.stored_ammo.len >= loaded_magazine.max_ammo)
		ammo_error_message = "MAGAZINE IS FULL"
		ammo_error_type = "good"
		return

	if(ammo_busy)
		return

	ammo_busy = TRUE
	soundloop.start()
	set_light(l_outer_range = 1.5)
	icon_state = "colony_lathe_working"
	update_appearance()
	ammo_timer_id = addtimer(CALLBACK(src, PROC_REF(fill_round), casing_type), time_per_round, TIMER_STOPPABLE)

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/fill_round(casing_type)
	if(machine_stat & (NOPOWER|BROKEN))
		ammo_fill_finish(FALSE)
		return

	if(!loaded_magazine || !materials?.mat_container)
		ammo_fill_finish(FALSE)
		return

	var/obj/item/ammo_casing/new_casing = new casing_type
	var/list/required_materials = new_casing.get_material_composition()
	var/list/efficient_materials = list()

	for(var/material in required_materials)
		efficient_materials[material] = required_materials[material] * creation_efficiency

	if(!materials.mat_container.has_materials(efficient_materials))
		ammo_error_message = "INSUFFICIENT MATERIALS"
		ammo_error_type = "bad"
		ammo_fill_finish(FALSE)
		qdel(new_casing)
		return

	if(!(new_casing.type in possible_ammo_types) || !loaded_magazine.give_round(new_casing))
		ammo_error_message = "AMMUNITION MISMATCH"
		ammo_error_type = "bad"
		ammo_fill_finish(FALSE)
		qdel(new_casing)
		return

	materials.mat_container.use_materials(efficient_materials)
	new_casing.set_custom_materials(efficient_materials)
	loaded_magazine.update_appearance()
	flick("ammobench_process", src)
	directly_use_energy(ROUND_UP(initial(active_power_usage) * 0.1))
	playsound(loc, 'sound/machines/piston_raise.ogg', 30, TRUE)

	if(loaded_magazine.stored_ammo.len >= loaded_magazine.max_ammo)
		ammo_error_message = "CONTAINER IS FULL"
		ammo_error_type = "good"
		ammo_fill_finish(TRUE)
		return

	SStgui.update_uis(src)
	ammo_timer_id = addtimer(CALLBACK(src, PROC_REF(fill_round), casing_type), time_per_round, TIMER_STOPPABLE)

/obj/machinery/rnd/production/colony_lathe/syndicate/proc/ammo_fill_finish(successfully = TRUE)
	ammo_busy = FALSE
	if(ammo_timer_id)
		deltimer(ammo_timer_id)
		ammo_timer_id = null
	soundloop.stop()
	set_light(l_outer_range = 0)
	icon_state = base_icon_state
	if(successfully)
		playsound(loc, 'sound/machines/ping.ogg', 20, TRUE)
		flick("colony_lathe_finish_print", src)
	else
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
	update_appearance()
	SStgui.update_uis(src)

// Undeployed printer disguised as a normal emergency toolbox.

/obj/item/storage/toolbox/emergency/omnilathe
	var/obj/machinery/rnd/production/colony_lathe/syndicate/type_to_deploy = /obj/machinery/rnd/production/colony_lathe/syndicate
	var/deploy_time = 4 SECONDS
	/// Imported autolathe design IDs preserved while packed.
	var/list/imported_designs = list()
	/// Packed snapshot of local material amounts, keyed by material typepath.
	var/list/packed_materials = list()
	/// Techfab department recipes unlocked before this printer was packed.
	var/list/unlocked_techfab_departments = list()
	/// Last selected lathe recipe set before this printer was packed.
	var/lathe_recipe_set = "autolathe"

/obj/item/storage/toolbox/emergency/omnilathe/PopulateContents()
	return

/obj/item/storage/toolbox/emergency/omnilathe/proc/transfer_contents_to_deployed_object(obj/machinery/rnd/production/colony_lathe/syndicate/deployed_object)
	if(!deployed_object)
		return

	atom_storage?.remove_all(deployed_object)
	for(var/obj/item/stored_item in contents)
		if(stored_item?.loc == src)
			stored_item.forceMove(deployed_object)

/obj/item/storage/toolbox/emergency/omnilathe/attack_self(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return

	var/turf/deploy_location = get_step(user, user.dir)
	if(deploy_location.is_blocked_turf(TRUE))
		balloon_alert(user, "insufficient room to deploy here.")
		return

	balloon_alert(user, "deploying...")
	playsound(src, 'sound/items/ratchet.ogg', 25, TRUE)
	if(!do_after(user, deploy_time, src))
		return

	deploy_location = get_step(user, user.dir)
	if(deploy_location.is_blocked_turf(TRUE))
		balloon_alert(user, "insufficient room to deploy here.")
		return

	var/obj/machinery/rnd/production/colony_lathe/syndicate/deployed_object = new /obj/machinery/rnd/production/colony_lathe/syndicate(deploy_location)
	if(imported_designs?.len)
		deployed_object.imported_designs = imported_designs.Copy()
	if(packed_materials?.len)
		deployed_object.packed_materials = packed_materials.Copy()
	if(unlocked_techfab_departments?.len)
		deployed_object.unlocked_techfab_departments = unlocked_techfab_departments.Copy()
	if(lathe_recipe_set)
		deployed_object.lathe_recipe_set = lathe_recipe_set
	transfer_contents_to_deployed_object(deployed_object)
	deployed_object.restore_packed_material_cache()
	deployed_object.rebuild_cached_designs()
	deployed_object.setDir(user.dir)
	deployed_object.modify_max_integrity(max_integrity)
	deployed_object.update_appearance()
	deployed_object.add_fingerprint(user)
	qdel(src)
