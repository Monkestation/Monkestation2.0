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

/datum/admins/proc/beaker_panel()
	set category = "Admin.Events"
	set name = "Spawn reagent container"

	if(!check_rights(R_ADMIN))
		return
	var/datum/beaker_panel/tgui = new(usr)
	tgui.ui_interact(usr)

/datum/beaker_panel
	var/chemstring
	var/mob/user

/datum/beaker_panel/New(mob/target_user)
	user = target_user

/datum/beaker_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BeakerPanel", "Beaker Panel")
		ui.open()

/datum/beaker_panel/ui_state(mob/user)
	return GLOB.admin_state

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
