/datum/bark_screen
	var/datum/preference_middleware/blooper/owner

/datum/bark_screen/New(user)
	owner = CLIENT_FROM_VAR(user)
	// owner.bark_screen = src
	// custom_loadout = new()

/datum/bark_screen/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BarkScreen")
		ui.open()

/datum/bark_screen/ui_state(mob/user)
	return GLOB.always_state

// /datum/bark_screen/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
// 	. = ..()
// 	if(.)
// 		return

// 	var/datum/store_item/interacted_item
// 	if(params["path"])
// 		interacted_item = GLOB.all_store_datums[text2path(params["path"])]
// 		if(!interacted_item)
// 			stack_trace("Failed to locate desired loadout item (path: [params["path"]]) in the global list of loadout datums!")
// 			return

// 	switch(action)
// 		// Closes the UI, reverting our loadout to before edits if params["revert"] is set
// 		if("close_ui")
// 			if(params["revert"])
// 				owner.prefs.loadout_list = loadout_on_open
// 			SStgui.close_uis(src)
// 			return

// 		if("select_item")
// 			select_item(interacted_item)
// 			owner?.prefs?.character_preview_view.update_body()
// 			owner?.prefs?.update_static_data(usr)

// 		// Rotates the dummy left or right depending on params["dir"]
// 		if("play")


// 	return TRUE

// /// Select [path] item to [category_slot] slot.
// /datum/bark_screen/proc/select_item(datum/store_item/selected_item)
// 	if(selected_item.item_path in owner.prefs.inventory)
// 		return //safety
// 	selected_item.attempt_purchase(owner)

// /datum/store_manager/ui_data(mob/user)
// 	var/list/data = list()

// 	var/list/all_selected_paths = list()
// 	for(var/path in owner?.prefs?.loadout_list)
// 		all_selected_paths += path
// 	return data

/datum/bark_screen/ui_static_data()
	var/list/data = list()

	// [name] is the name of the tab that contains all the corresponding contents.
	// [title] is the name at the top of the list of corresponding contents.
	// [contents] is a formatted list of all the possible items for that slot.
	//  - [contents.path] is the path the singleton datum holds
	//  - [contents.name] is the name of the singleton datum
	//  - [contents.item_cost], the total cost of this item

	data["bark_groups"] = list()
	for (var/group in GLOB.bark_groups)
		var/list/bark_names = list()
		for (var/bark_name in GLOB.bark_groups[group])
			var/datum/bark_voice/bark = GLOB.bark_groups[group][bark_name]
			bark_names += list(list(bark_name, bark.id))
		data["bark_groups"][group] = bark_names

	return data
