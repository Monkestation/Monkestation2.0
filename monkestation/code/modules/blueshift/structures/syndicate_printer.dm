/// A Syndicate-manufactured alternate rapid construction fabricator with its own recipe list.

/obj/machinery/rnd/production/colony_lathe/syndicate
	name = "Syndicate 3D Printer"
	desc = "A sleek, unmarked fabrication unit of Syndicate manufacture. No serial numbers. No warranty. \
		Capable of producing a wide array of illicit hardware on demand, whether you're outfitting a team \
		or just need something that shouldn't exist."
	allowed_buildtypes = AUTOLATHE
	ui_theme = "syndicate"
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 2
	link_on_init = FALSE
	repacked_type = /obj/item/storage/toolbox/emergency/syndicate_printer
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
	var/creation_efficiency = 1.4
	/// Time per round in ammo mode.
	var/time_per_round = 1.0 SECONDS
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

/obj/machinery/rnd/production/colony_lathe/syndicate/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	AddElement(/datum/element/manufacturer_examine, COMPANY_CYBERSUN)
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
	// On local-only setups this machine may have no matter bins installed, which would yield zero capacity.
	if(materials && !materials.silo && materials.local_size <= 0)
		materials.set_local_size(75 * SHEET_MATERIAL_AMOUNT)

	var/time_efficiency = 1.8 SECONDS
	for(var/datum/stock_part/micro_laser/new_laser in component_parts)
		time_efficiency -= new_laser.tier * 2
	time_per_round = clamp(time_efficiency, 1, 20)

	var/efficiency = 1.4
	for(var/datum/stock_part/manipulator/new_servo in component_parts)
		efficiency -= new_servo.tier * 0.1
	creation_efficiency = max(0, efficiency)
	update_ammotypes()


/obj/machinery/rnd/production/colony_lathe/syndicate/proc/rebuild_cached_designs()
	var/previous_design_count = cached_designs.len
	cached_designs.Cut()

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

	var/design_delta = cached_designs.len - previous_design_count
	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

/obj/machinery/rnd/production/colony_lathe/syndicate/update_designs()
	rebuild_cached_designs()

/obj/machinery/rnd/production/colony_lathe/syndicate/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
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
		playsound(loc, 'sound/weapons/autoguninsert.ogg', 35, TRUE)
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
	playsound(loc, 'sound/machines/piston_raise.ogg', 60, TRUE)

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
		playsound(loc, 'sound/machines/ping.ogg', 40, TRUE)
		flick("colony_lathe_finish_print", src)
	else
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 40, TRUE)
	update_appearance()
	SStgui.update_uis(src)

// Undeployed printer disguised as a normal emergency toolbox.

/obj/item/storage/toolbox/emergency/syndicate_printer
	var/obj/machinery/rnd/production/colony_lathe/syndicate/type_to_deploy = /obj/machinery/rnd/production/colony_lathe/syndicate
	var/deploy_time = 4 SECONDS
	/// Imported autolathe design IDs preserved while packed.
	var/list/imported_designs = list()

/obj/item/storage/toolbox/emergency/syndicate_printer/PopulateContents()
	return

/obj/item/storage/toolbox/emergency/syndicate_printer/attack_self(mob/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return

	var/turf/deploy_location = get_step(user, user.dir)
	if(deploy_location.is_blocked_turf(TRUE))
		balloon_alert(user, "insufficient room to deploy here.")
		return

	balloon_alert(user, "deploying...")
	playsound(src, 'sound/items/ratchet.ogg', 50, TRUE)
	if(!do_after(user, deploy_time, src))
		return

	deploy_location = get_step(user, user.dir)
	if(deploy_location.is_blocked_turf(TRUE))
		balloon_alert(user, "insufficient room to deploy here.")
		return

	var/obj/machinery/rnd/production/colony_lathe/syndicate/deployed_object = new /obj/machinery/rnd/production/colony_lathe/syndicate(deploy_location)
	if(imported_designs?.len)
		deployed_object.imported_designs = imported_designs.Copy()
		deployed_object.rebuild_cached_designs()
	deployed_object.setDir(user.dir)
	deployed_object.modify_max_integrity(max_integrity)
	deployed_object.update_appearance()
	deployed_object.add_fingerprint(user)
	atom_storage?.remove_all(get_turf(src))
	qdel(src)
