// DM Backend for Beaker Panel TGUI
// Improved version with better error handling and validation

/proc/reagentsforbeakers()
	var/list/reagent_list = list()
	for(var/reagent_type in subtypesof(/datum/reagent))
		var/datum/reagent/R = reagent_type
		var/reagent_name = initial(R.name)
		// Skip reagents without names or abstract base types
		if(!reagent_name || findtext(reagent_name, "base") || findtext(reagent_name, "template"))
			continue
		// Skip admin-only or dangerous reagents if needed
		// if(initial(R.admin_only))
		//     continue
		reagent_list += list(list(
			"id" = "[reagent_type]",
			"name" = reagent_name
		))
	return reagent_list

/proc/beakersforbeakers()
	var/list/container_list = list()
	for(var/container_type in subtypesof(/obj/item/reagent_containers))
		var/obj/item/reagent_containers/C = container_type
		var/container_name = initial(C.name)
		var/container_volume = initial(C.volume)
		// Skip containers with no name or volume, or abstract base types
		if(!container_name || !container_volume || findtext(container_name, "base"))
			continue
		// Skip containers that are likely abstract or not meant for spawning
		// You can add specific exclusions here if needed, for example:
		// if(findtext(container_name, "abstract") || findtext(container_name, "template"))
		//     continue
		container_list += list(list(
			"id" = "[container_type]",
			"name" = container_name,
			"volume" = container_volume
		))
	return container_list

/datum/admins/proc/beaker_panel()
	set category = "Admin.Events"
	set name = "Spawn reagent container"
	if(!check_rights(R_ADMIN))
		return
	var/datum/beaker_panel/tgui = new(usr)
	tgui.ui_interact(usr)

/datum/beaker_panel
	var/mob/user

/datum/beaker_panel/New(mob/target_user)
	user = target_user

/datum/beaker_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BeakerPanel", "Beaker Panel")
		ui.open()

/datum/beaker_panel/ui_data(mob/user)
	var/list/data = list()
	data["reagents"] = reagentsforbeakers()
	data["containers"] = beakersforbeakers()
	return data

/datum/beaker_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!user || !check_rights(R_ADMIN, 0, user))
		return FALSE

	switch(action)
		if("spawncontainer")
			var/containerdata_json = params["container"]
			if(!containerdata_json)
				return FALSE
			var/list/containerdata = json_decode(containerdata_json)
			if(!islist(containerdata))
				return FALSE
			var/obj/item/reagent_containers/container = beaker_panel_create_container(containerdata, get_turf(user))
			if(!container)
				message_admins("[key_name(user)] failed to spawn container via beaker panel")
				return FALSE
			var/reagent_string = pretty_string_from_reagent_list(container.reagents.reagent_list)
			user.log_message("spawned [container] containing [reagent_string] via beaker panel", LOG_GAME)
			message_admins("[key_name(user)] spawned [container] containing [reagent_string] via beaker panel")
			return TRUE

		if("spawngrenade")
			var/containers_json = params["containers"]
			var/grenadedata_json = params["grenadedata"]
			var/grenadetype = params["grenadetype"]

			if(!containers_json || !grenadedata_json)
				return FALSE

			var/list/containersdata = json_decode(containers_json)
			var/list/grenadedata = json_decode(grenadedata_json)

			if(!islist(containersdata) || !islist(grenadedata))
				return FALSE

			var/obj/item/grenade/chem_grenade/grenade = new(get_turf(user))
			var/reagent_string = ""

			// Create containers and add to grenade
			for(var/i in 1 to min(2, length(containersdata)))
				var/obj/item/reagent_containers/container = beaker_panel_create_container(containersdata[i], grenade)
				if(container)
					grenade.beakers += container
					if(container.reagents && container.reagents.reagent_list)
						reagent_string += " ([container.name] [i]: [pretty_string_from_reagent_list(container.reagents.reagent_list)]);"
					else
						reagent_string += " ([container.name] [i]: empty);"
				else
					message_admins("[key_name(user)] failed to create container [i] for grenade")

			// Set grenade to ready state
			grenade.stage_change(GRENADE_READY)

			// Configure grenade based on type and data
			switch(grenadetype)
				if("normal") // Regular timer grenade
					var/det_time = text2num(grenadedata["grenade-timer"])
					if(det_time && det_time > 0 && det_time <= 300)
						grenade.det_time = det_time
					else
						grenade.det_time = 30 // Default fallback

			var/log_message = "spawned [grenade] (timer: [grenade.det_time]s) containing:[reagent_string] via beaker panel"
			user.log_message(log_message, LOG_GAME)
			message_admins("[key_name(user)] [log_message]")
			return TRUE
	return FALSE

/datum/beaker_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/beaker_panel/proc/beaker_panel_create_container(list/containerdata, atom/location)
	if(!islist(containerdata))
		return null

	var/containertype = text2path(containerdata["container"])
	if(!containertype || !ispath(containertype, /obj/item/reagent_containers))
		return null

	var/obj/item/reagent_containers/container = new containertype(location)
	if(!container || !container.reagents)
		if(container)
			qdel(container)
		return null

	var/datum/reagents/reagents = container.reagents
	// Clear any existing reagents
	reagents.clear_reagents()

	// Add new reagents
	var/list/reagent_list = containerdata["reagents"]
	if(islist(reagent_list))
		for(var/list/item in reagent_list)
			if(!islist(item))
				continue
			var/reagenttype = text2path(item["reagent"])
			var/amount = text2num(item["volume"])

			// Validate reagent type and amount
			if(!reagenttype || !ispath(reagenttype, /datum/reagent))
				continue
			if(!amount || amount <= 0 || amount > 1000) // Cap at 1000u per reagent
				continue

			// Expand container if needed (with reasonable limits)
			var/new_total = reagents.total_volume + amount
			if(new_total > reagents.maximum_volume)
				if(new_total <= 5000) // Cap total volume at 5000u
					reagents.maximum_volume = new_total
				else
					continue // Skip if would exceed limit

			reagents.add_reagent(reagenttype, amount)

	return container
