/obj/machinery/nanite_program_hub
	name = "nanite program hub"
	desc = "Compiles nanite programs from the techweb servers and downloads them into disks."
	icon = 'monkestation/icons/obj/machines/nanites/nanite_machines.dmi'
	icon_state = "nanite_program_hub"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/nanite_program_hub

	///Boolean on whether the UI should give a detailed view of everything.
	var/detail_view = TRUE
	///The disk currently inserted into the machine, that we upload programs onto.
	var/obj/item/disk/nanite_program/inserted_disk
	///The techweb we're connected to, and get designs from.
	var/datum/techweb/linked_techweb
	///List of all unlocked nanite designs, cached to only state when you receive a new one.
	var/list/datum/design/nanites/cached_designs = list()

/obj/machinery/nanite_program_hub/Destroy()
	linked_techweb = null
	return ..()

/obj/machinery/nanite_program_hub/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		linked_techweb = SSresearch.science_tech
	if(linked_techweb)
		on_connected_techweb()

/obj/machinery/nanite_program_hub/proc/connect_techweb(datum/techweb/new_techweb)
	if(linked_techweb)
		UnregisterSignal(linked_techweb, list(COMSIG_TECHWEB_ADD_DESIGN))
	linked_techweb = new_techweb
	if(!isnull(linked_techweb))
		on_connected_techweb()

/obj/machinery/nanite_program_hub/proc/on_connected_techweb()
	for (var/researched_design_id in linked_techweb.researched_designs)
		var/datum/design/nanites/design = SSresearch.techweb_design_by_id(researched_design_id)
		if (!ispath(design))
			continue

		cached_designs[design.program_type] = design.id

	RegisterSignal(linked_techweb, COMSIG_TECHWEB_ADD_DESIGN, PROC_REF(on_research))

/obj/machinery/nanite_program_hub/proc/on_research(datum/source, datum/design/nanites/added_design, custom)
	SIGNAL_HANDLER
	// We're probably going to get more than one update (design) at a time, so batch them together.
	addtimer(CALLBACK(src, PROC_REF(update_menu_tech)), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/**
 * Updates the `final_sets` and `buildable_parts` for the current mecha fabricator.
 */
/obj/machinery/nanite_program_hub/proc/update_menu_tech()
	var/previous_design_count = cached_designs.len

	cached_designs.Cut()
	for(var/v in linked_techweb.researched_designs)
		var/datum/design/nanites/design = SSresearch.techweb_design_by_id(v)

		if(istype(design))
			cached_designs |= design

	var/design_delta = cached_designs.len - previous_design_count

	if(design_delta > 0)
		say("Received [design_delta] new design[design_delta == 1 ? "" : "s"].")
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)

	update_static_data_for_all_viewers()

/obj/machinery/nanite_program_hub/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/disk/nanite_program))
		return ..()
	if(!user.transferItemToLoc(weapon, src))
		return
	if(inserted_disk)
		balloon_alert(user, "disk swapped")
		eject(user)
	else
		balloon_alert(user, "disk inserted")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	inserted_disk = weapon

/obj/machinery/nanite_program_hub/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/nanite_program_hub/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/nanite_program_hub/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		connect_techweb(tool.buffer)
	return TRUE

/obj/machinery/nanite_program_hub/proc/eject(mob/living/user)
	if(!inserted_disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(inserted_disk))
		inserted_disk.forceMove(drop_location())
	inserted_disk = null

/obj/machinery/nanite_program_hub/attack_hand_secondary(mob/user, list/modifiers)
	if(inserted_disk && user.can_perform_action(src, ALLOW_SILICON_REACH))
		balloon_alert(user, "disk ejected")
		eject(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/machinery/nanite_program_hub/ui_interact(mob/user, datum/tgui/ui)
	if(!linked_techweb)
		visible_message("Warning: no linked server!")
		SStgui.close_uis(src)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteProgramHub", name)
		ui.open()

/obj/machinery/nanite_program_hub/ui_data()
	var/list/data = list()
	if(inserted_disk)
		data["has_disk"] = TRUE
		var/list/disk_data = list()
		var/datum/nanite_program/P = inserted_disk.program
		if(P)
			data["has_program"] = TRUE
			disk_data["name"] = P.name
			disk_data["desc"] = P.desc
		data["disk"] = disk_data
	else
		data["has_disk"] = FALSE

	data["detail_view"] = detail_view

	return data

/obj/machinery/nanite_program_hub/ui_static_data(mob/user)
	var/list/data = list()
	data["programs"] = list()
	data["categories"] = list()
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/nanites/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		var/cat_name = D.category[1] //just put them in the first category fuck it
		if(!(cat_name in data["categories"]))
			data["categories"] += cat_name
		if(isnull(data["programs"][cat_name]))
			data["programs"][cat_name] = list()
		var/list/program_design = list()
		program_design["id"] = D.id
		program_design["name"] = D.name
		program_design["desc"] = D.desc
		data["programs"][cat_name] += list(program_design)

	if(!length(data["programs"]))
		data["programs"] = null

	return data

/obj/machinery/nanite_program_hub/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			eject(usr)
			return TRUE
		if("download")
			if(!inserted_disk)
				return
			var/datum/design/nanites/downloaded = linked_techweb.isDesignResearchedID(params["program_id"]) //check if it's a valid design
			if(!istype(downloaded))
				return
			if(inserted_disk.program)
				qdel(inserted_disk.program)
			inserted_disk.program = new downloaded.program_type
			inserted_disk.name = "[initial(inserted_disk.name)] \[[inserted_disk.program.name]\]"
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			return TRUE
		if("refresh")
			update_static_data(usr)
			return TRUE
		if("toggle_details")
			detail_view = !detail_view
			return TRUE
		if("clear")
			if(inserted_disk && inserted_disk.program)
				qdel(inserted_disk.program)
				inserted_disk.program = null
				inserted_disk.name = initial(inserted_disk.name)
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)
			return TRUE
