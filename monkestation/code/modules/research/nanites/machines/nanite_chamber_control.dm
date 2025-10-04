/obj/machinery/computer/nanite_chamber_control
	name = "nanite chamber control console"
	desc = "Controls a connected nanite chamber. Can inoculate and destroy nanites or analyze existing nanite swarms within patients."
	icon = 'monkestation/icons/obj/machines/nanites/computer.dmi'
	icon_screen = "nanite_chamber_control"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/nanite_chamber_control

	///The nanite chamber we're connected to, that we use to scan people and modify nanites.
	var/obj/machinery/nanite_chamber/chamber
	///The techweb that hosts the nanites we're injecting into people.
	var/datum/techweb/linked_techweb

/obj/machinery/computer/nanite_chamber_control/post_machine_initialize()
	. = ..()
	find_chamber()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		linked_techweb = SSresearch.science_tech

/obj/machinery/computer/nanite_chamber_control/Destroy()
	linked_techweb = null
	return ..()

/obj/machinery/computer/nanite_chamber_control/interact()
	if(!chamber)
		find_chamber()
	return ..()

/obj/machinery/computer/nanite_chamber_control/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		linked_techweb = tool.buffer
	return TRUE

/obj/machinery/computer/nanite_chamber_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteChamberControl", name)
		ui.open()

/obj/machinery/computer/nanite_chamber_control/ui_data()
	var/list/data = list()

	if(!linked_techweb)
		data["status_msg"] = "No techweb detected."
		return data

	if(!chamber)
		data["status_msg"] = "No chamber detected."
		return data

	if(!chamber.occupant)
		data["status_msg"] = "No occupant detected."
		return data

	var/mob/living/person_inside = chamber.occupant

	if(!(person_inside.mob_biotypes & NANITE_COMPATIBLE_BIOTYPES))
		data["status_msg"] = "Occupant not compatible with nanites."
		return data

	if(chamber.busy)
		data["status_msg"] = chamber.busy_message
		return data

	data["has_nanites"] = FALSE
	data["status_msg"] = null
	data["scan_level"] = chamber.scan_level
	data["locked"] = chamber.locked
	data["occupant_name"] = chamber.occupant.name

	SEND_SIGNAL(person_inside, COMSIG_NANITE_UI_DATA, data, chamber.scan_level)

	return data

/obj/machinery/computer/nanite_chamber_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_lock")
			chamber.locked = !chamber.locked
			chamber.update_appearance(UPDATE_ICON)
			return TRUE
		if("set_safety")
			var/threshold = text2num(params["value"])
			if(!isnull(threshold))
				chamber.set_safety(clamp(round(threshold, 1), 0, 500))
				playsound(src, "terminal_type", 25, FALSE)
				chamber.occupant.investigate_log("'s nanites' safety threshold was set to [threshold] by [key_name(usr)] via [src] at [AREACOORD(src)].", INVESTIGATE_NANITES)
			return TRUE
		if("set_cloud")
			var/cloud_id = text2num(params["value"])
			if(!isnull(cloud_id))
				chamber.set_cloud(clamp(round(cloud_id, 1), 0, 100))
				playsound(src, "terminal_type", 25, FALSE)
				chamber.occupant.investigate_log("'s nanites' cloud id was set to [cloud_id] by [key_name(usr)] via [src] at [AREACOORD(src)].", INVESTIGATE_NANITES)
			return TRUE
		if("connect_chamber")
			find_chamber()
			return TRUE
		if("remove_nanites")
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			chamber.remove_nanites()
			log_combat(usr, chamber.occupant, "cleared nanites from", null, "via [src]")
			chamber.occupant.investigate_log("'s nanites were cleared by [key_name(usr)] via [src] at [AREACOORD(src)].", INVESTIGATE_NANITES)
			return TRUE
		if("nanite_injection")
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			chamber.inject_nanites()
			log_combat(usr, chamber.occupant, "injected", null, "with nanites via [src]")
			chamber.occupant.investigate_log("was injected with nanites by [key_name(usr)] via [src] at [AREACOORD(src)].", INVESTIGATE_NANITES)
			return TRUE

///Looks in all directions for a nanite chamber to sync to.
/obj/machinery/computer/nanite_chamber_control/proc/find_chamber()
	for(var/direction in GLOB.cardinals)
		var/found_chamber = locate(/obj/machinery/nanite_chamber, get_step(src, direction))
		if(!found_chamber)
			continue
		var/obj/machinery/nanite_chamber/nanite_chamber = found_chamber
		chamber = nanite_chamber
		nanite_chamber.linked_console = src
