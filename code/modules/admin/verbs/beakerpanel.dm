/proc/reagentsforbeakers()
	//Basic list pulled from random.dm /obj/item/seeds/random/lesser
	var/static/list/reagent_blacklist = typecacheof(list(
		/datum/reagent/aslimetoxin,
		/datum/reagent/drug/blastoff,
		/datum/reagent/drug/demoneye,
		/datum/reagent/drug/twitch,
		/datum/reagent/magillitis,
		/datum/reagent/medicine/antipathogenic/changeling,
		/datum/reagent/medicine/changelinghaste,
		/datum/reagent/medicine/coagulant,
		/datum/reagent/medicine/regen_jelly,
		/datum/reagent/medicine/stimulants,
		/datum/reagent/medicine/syndicate_nanites,
		/datum/reagent/metalgen,
		/datum/reagent/mulligan,
		/datum/reagent/mutationtoxin,
		/datum/reagent/prefactor_a,
		/datum/reagent/prefactor_b,
		/datum/reagent/reaction_agent,
		/datum/reagent/spider_extract,
	))

	var/list/reagent_list = list()
	for(var/reagent_type in subtypesof(/datum/reagent))
		var/datum/reagent/R = reagent_type
		var/reagent_name = initial(R.name)
		// Skip reagents without names or abstract base types
		if(!reagent_name || findtext(reagent_name, "base") || findtext(reagent_name, "template"))
			continue
		// Hard skip admin-only or dangerous reagents if needed, otherwise it's filtered in UI.
		// if(initial(R.admin_only))
		//     continue
		reagent_list += list(list(
			"id" = "[reagent_type]",
			"name" = reagent_name,
			"dangerous" = ((R in reagent_blacklist) || !(R.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED)) ? "TRUE" : "FALSE",
		))
	return reagent_list

/proc/beakersforbeakers()
	var/list/container_list = list()
	for(var/container_type in subtypesof(/obj/item/reagent_containers))
		var/obj/item/reagent_containers/C = container_type
		var/container_name = initial(C.name)
		var/container_volume = initial(C.volume)
		// Skip containers with no name or volume, abstract base types, or any container already filled.
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

ADMIN_VERB(beaker_panel, R_SPAWN, FALSE, "Spawn Reagent Container", "Spawn a reagent container.", ADMIN_CATEGORY_EVENTS)
	var/datum/beaker_panel/tgui = new(user.mob)
	tgui.ui_interact(user.mob)

/datum/beaker_panel
	var/chemstring
	var/mob/user

/datum/beaker_panel/New(mob/target_user)
	user = target_user

/datum/beaker_panel/proc/beaker_panel_create_container(list/containerdata, list/reagent_data, location)
	var/containertype = text2path(containerdata["id"])
	if(isnull(containertype))
		return null
	var/obj/item/reagent_containers/container = new containertype(location)
	var/datum/reagents/reagents = container.reagents
	for(var/datum/reagent/R in reagents.reagent_list) // clear the container of reagents
		reagents.remove_reagent(R.type,R.volume)
	for(var/list/item in reagent_data)
		var/datum/reagent/reagenttype = text2path(item["id"])
		var/amount = text2num(item["amount"])
		if ((reagents.total_volume + amount) > reagents.maximum_volume)
			reagents.maximum_volume = reagents.total_volume + amount
		reagents.add_reagent(reagenttype, amount)
	return container

/datum/beaker_panel/proc/beaker_panel_create_grenade(list/grenadedata, list/obj/item/reagent_containers/containers, location)
	switch(grenadedata["grenadeType"] )
		if("Normal")
			var/timer = text2num(grenadedata["grenadeTimer"]) SECONDS
			var/obj/item/grenade/chem_grenade/grenade = new(location)
			for(var/obj/item/reagent_containers/container in containers)
				grenade.beakers += container
				container.forceMove(grenade)
			grenade.stage_change(GRENADE_READY)
			if(timer)
				grenade.det_time = timer

			return grenade
		else
			return null

/datum/beaker_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BeakerPanel", "Beaker Panel")
		ui.open()

/datum/beaker_panel/ui_state(mob/user)
	return ADMIN_STATE(R_SPAWN)

/datum/beaker_panel/ui_static_data(mob/user)
	var/list/data = list()
	data["reagents"] = reagentsforbeakers()
	data["containers"] = beakersforbeakers()
	return data

/datum/beaker_panel/ui_data(mob/user)
	var/list/data = list()
	data["chemstring"] = chemstring
	return data

/datum/beaker_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!user || !check_rights(R_ADMIN, 0, user))
		return FALSE
	if(!action || !params)
		return
	switch(action)
		if("spawncontainer")
			var/list/container_data = json_decode(params["container"])
			var/list/reagents_data = json_decode(params["reagents"])
			var/obj/item/reagent_containers/container = beaker_panel_create_container(container_data, reagents_data, get_turf(usr))
			if(istype(container))
				usr.log_message("spawned a [container] containing [pretty_string_from_reagent_list(container.reagents.reagent_list)]", LOG_GAME)
		if("spawngrenade")
			var/list/grenade_data = json_decode(params["grenadedata"])
			var/list/containers_data = json_decode(params["containers"])
			var/list/reagentmatrix_data = json_decode(params["reagents"])

			//TODO check if returned gredadetype is a valide type then process chems
			var/reagent_string
			var/list/obj/item/reagent_containers/beakers = list()
			for(var/item in containers_data)
				var/list/container_data = containers_data[item]
				var/list/reagent_data = reagentmatrix_data[item]

				var/obj/item/reagent_containers/new_beaker = beaker_panel_create_container(container_data, reagent_data, null)
				if(!istype(new_beaker))
					continue
				beakers += new_beaker
				reagent_string += " ([new_beaker.name] [text2num(item)] : " + pretty_string_from_reagent_list(new_beaker.reagents.reagent_list) + ");"

			if(!length(beakers))
				return

			var/obj/item/grenade/chem_grenade/grenade = beaker_panel_create_grenade(grenade_data, beakers, get_turf(usr))
			if(istype(grenade))
				usr.log_message("spawned a [grenade] containing: [reagent_string]", LOG_GAME)
				beakers = list()
			else
				QDEL_LIST(beakers)
