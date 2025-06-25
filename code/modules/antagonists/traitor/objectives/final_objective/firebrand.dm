/datum/traitor_objective/ultimate/firebrand
	name = "Recieve a technologically upgraded flamethrower terror tank in %AREA% and melt the station down with it"
	description = "Go to %AREA%, and recieve the Noble Fireband Mk.XVII. It has been modified to only need 1 person to drive and fire it, \
	the flamethrower can melt walls, kill through firesuits, and make rooms uninhabitable. Warning: The tank is slow and dies to melee attacks very fast."

	//this is a prototype so this progression is for all basic level kill objectives
	// stole rommerol code and modified it.
	///area type the objective owner must be in to recieve the romerol
	var/area/firebrand_spawnarea_type
	///checker on whether we have sent the romerol yet.
	var/sent_firebrand = FALSE

/datum/traitor_objective/ultimate/firebrand/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		//remove areas too close to the destination, too obvious for our poor shmuck, or just unfair
		if(ispath(possible_area, /area/station/hallway) || ispath(possible_area, /area/station/security))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	firebrand_spawnarea_type = pick(possible_areas)
	replace_in_name("%AREA%", initial(firebrand_spawnarea_type.name))
	return TRUE

/datum/traitor_objective/ultimate/firebrand/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_firebrand)
		buttons += add_ui_button("", "Pressing this will call down a pod with the Flamethrower Tank.", "tank", "firebrand")
	return buttons

/datum/traitor_objective/ultimate/firebrand/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("firebrand")
			if(sent_firebrand)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != firebrand_spawnarea_type)
				to_chat(user, span_warning("You must be in [initial(firebrand_spawnarea_type.name)] to recieve the terror tank."))
				return
			sent_firebrand = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = STYLE_SYNDICATE,
				"spawn" = /obj/vehicle/sealed/mecha/firebrandone,
			))
