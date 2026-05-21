/// All of the default reagent lists for each hypospray (+ hacked variants)
#define BASE_MEDICAL_REAGENTS list(\
		/datum/reagent/medicine/c2/aiuri,\
		/datum/reagent/medicine/c2/convermol,\
		/datum/reagent/medicine/epinephrine,\
		/datum/reagent/medicine/c2/libital,\
		/datum/reagent/medicine/c2/multiver,\
		/datum/reagent/medicine/salglu_solution,\
		/datum/reagent/medicine/antipathogenic/spaceacillin\
	)

/obj/item/reagent_containers/cyborg_hypospray
	name = "cyborg hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "borghypo"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 5
	/// In the hypo's TGUI, each of these numbers will be available as buttons to click on.
	possible_transfer_amounts = list(1, 2, 5)

	/// Cell cost for charging a reagent.
	var/charge_cost = 0.05 * STANDARD_CELL_CHARGE
	/// Counts up to the next time we charge.
	var/charge_timer = 0 SECONDS
	/// Time it takes for shots to recharge (in deciseconds).
	var/recharge_time = 10 SECONDS
	/// Optional variable to override the temperature that [add_reagent()] will use.
	var/dispensed_temperature = DEFAULT_REAGENT_TEMPERATURE
	/// Can the hypospray bypass clothing that have THICKMATERIAL?
	var/bypass_protection = FALSE
	/// Has this hypospray been upgraded with additional chemicals?
	var/upgraded = FALSE
	/// The basic reagents that come with this hypospray.
	var/list/default_reagent_types
	/// The expanded suite of reagents that comes from upgrading this hypospray.
	var/list/expanded_reagent_types
	/// The maximum volume for each reagent stored in this hypospray.
	var/max_volume_per_reagent = 30
	/// An associated list of reagents that we can use and how much volume is remaining for it. Indexed via the reagent's typepath.
	var/list/datum/reagent/stored_reagents
	/// The reagent typepath we've selected to dispense.
	var/datum/reagent/selected_reagent_typepath
	/// The recipe that we are actively recording, if any.
	var/list/recording_recipe
	/// An associated list of the recipes that have been saved. Indexed via the string ID of the recipe.
	var/list/saved_recipes = list()
	/// The recipe we've selected to dispense.
	var/selected_recipe_id
	/// The theme for our UI.
	var/tgui_theme = PDA_THEME_NTOS
	/// Changes the UI's text to match if it is for drinks or chemicals.
	var/is_dispensing_drinks = FALSE

/obj/item/reagent_containers/cyborg_hypospray/Initialize(mapload)
	. = ..()
	for(var/reagent in default_reagent_types)
		add_new_reagent(reagent)
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/cyborg_hypospray/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/// Every [recharge_time] seconds, restore some of the hypospray's reagents.
/obj/item/reagent_containers/cyborg_hypospray/process(seconds_per_tick)
	. = TRUE
	charge_timer += seconds_per_tick
	if(recharge_time > charge_timer)
		return
	charge_timer = 0
	regenerate_reagents(default_reagent_types)
	if(upgraded)
		regenerate_reagent(expanded_reagent_types)

/obj/item/reagent_containers/cyborg_hypospray/attack(mob/living/carbon/injectee, mob/user)
	if(!istype(injectee))
		return
	if(!has_reagents_for_injection(user, FALSE)) // Gives balloon alerts.
		return
	if(!injectee.reagents) // They should have reagents, but just in case.
		balloon_alert(user, "unable to inject!")
		return
	if(!injectee.try_inject(user, user.zone_selected, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE | (bypass_protection ? INJECT_CHECK_PENETRATE_THICK : 0)))
		balloon_alert(user, "[parse_zone(user.zone_selected)] is blocked!")
		return

	var/datum/reagents/reagent_injector = create_reagent_injector()
	var/total_units_to_injected = reagent_injector.total_volume

	to_chat(injectee, span_warning("You feel a tiny prick!"))
	to_chat(user, span_notice("You inject [injectee] with the injector ([selected_reagent_typepath ? selected_reagent_typepath.name : selected_recipe_id])."))
	balloon_alert(user, "[total_units_to_injected] unit\s injected")
	reagent_injector.trans_to(injectee, total_units_to_injected, transfered_by = user, methods = INJECT)
	log_combat(user, injectee, "injected", src, "(CHEMICALS: [reagent_injector])")

/// Adds a single reagent that can be produced.
/obj/item/reagent_containers/cyborg_hypospray/proc/add_new_reagent(datum/reagent/reagent_typepath)
	if(stored_reagents[reagent_typepath])
		return
	stored_reagents[reagent_typepath] = max_volume_per_reagent

/// Adds a list of reagents that can be produced.
/obj/item/reagent_containers/cyborg_hypospray/proc/add_new_reagent_list(list/datum/reagent/reagent_typepaths)
	for(var/datum/reagent/reagent_typepath in reagent_typepaths)
		add_new_reagent(reagent_typepath)

/// Removes a single reagent from being produced.
/obj/item/reagent_containers/cyborg_hypospray/proc/del_new_reagent(datum/reagent/reagent_typepath)
	if(!stored_reagents[reagent_typepath])
		return
	stored_reagents[reagent_typepath] = null
	if(selected_reagent_typepath == reagent_typepath)
		selected_reagent_typepath = null

/// Removes a list of reagents from being produced.
/obj/item/reagent_containers/cyborg_hypospray/proc/del_new_reagent_list(list/datum/reagent/reagent_typepaths)
	for(var/datum/reagent/reagent_typepath in reagent_typepaths)
		del_new_reagent(reagent_typepath)

/// Regenerates the supply of a reagent (if they're not full already).
/obj/item/reagent_containers/cyborg_hypospray/proc/regenerate_reagent(datum/reagent/reagent_typepath, amount)
	if(!stored_reagents[reagent_typepath])
		return
	var/reagent_volume = stored_reagents[reagent_typepath]
	if(reagent_volume >= max_volume_per_reagent)
		return
	stored_reagents[reagent_typepath] = clamp(reagent_volume, 0, reagent_volume + amount)
	if(iscyborg(loc))
		var/mob/living/silicon/robot/cyborg = loc
		cyborg.cell?.use(charge_cost)

/// Regenerates the supply of multiple reagents (if they're not full already).
/obj/item/reagent_containers/cyborg_hypospray/proc/regenerate_reagents(list/datum/reagent/reagents_typepaths_to_regen, amount)
	for(var/datum/reagent/reagents_typepath_to_regen in reagents_typepaths_to_regen)
		regenerate_reagent(reagents_typepath_to_regen, amount)

/// Depletes the supply of a reagent.
/obj/item/reagent_containers/cyborg_hypospray/proc/deplete_reagent(datum/reagent/reagent_typepath, amount)
	var/reagent_volume = stored_reagents[reagent_typepath]
	if(!stored_reagents[reagent_typepath])
		return
	stored_reagents[reagent_typepath] = clamp(reagent_volume - amount, 0, reagent_volume)

/// Checks if the hypospray has enough reagents to perform an injection.
/obj/item/reagent_containers/cyborg_hypospray/proc/has_reagents_for_injection(user, silent = TRUE)
	if(selected_reagent_typepath)
		if(!stored_reagents[selected_reagent_typepath])
			if(!silent)
				balloon_alert(user, "not enough [selected_reagent_typepath.name]!")
			return FALSE
		return TRUE
	if(selected_recipe_id)
		var/recipe_information = saved_recipes[selected_recipe_id]
		if(!recipe_information)
			to_chat(user, span_warning("Couldn't find recipe ") + span_boldwarning(selected_recipe_id) + span_warning("!"))
			return FALSE
		for(var/recipe in recipe_information)
			var/datum/reagent/recipe_typepath = recipe["typepath"]
			var/recipe_volume = recipe["amount"]
			var/reagent_volume = stored_reagents[recipe_typepath]
			if(!reagent_volume || recipe_volume > reagent_volume)
				if(!silent)
					balloon_alert(user, "not enough [recipe_typepath.name]!") // TODO: Should this mention the recipe instead?
				return FALSE
		return TRUE
	if(!silent)
		balloon_alert(user, "no reagent selected!")
	return FALSE

/// Creates the reagents.
/obj/item/reagent_containers/cyborg_hypospray/proc/create_reagent_injector()
	var/datum/reagents/reagent_injector = new()
	if(selected_reagent_typepath)
		deplete_reagent(selected_reagent_typepath, amount_per_transfer_from_this)
		reagent_injector.add_reagent(selected_reagent_typepath, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)
	else if(selected_recipe_id)
		var/recipe_information = saved_recipes[selected_recipe_id]
		if(recipe_information)
			for(var/recipe_step in recipe_information)
				var/recipe_typepath = recipe_step["typepath"]
				var/recipe_amount_amount = recipe_step["amount"]
				deplete_reagent(recipe_typepath, recipe_amount_amount)
				reagent_injector.add_reagent(recipe_typepath, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)
	return reagent_injector

/obj/item/reagent_containers/cyborg_hypospray/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgChemicalDispenser", "Integrated [is_dispensing_drinks ? "Drink Dispenser" : "Chemical Hypospray"]")
		ui.open()

/obj/item/reagent_containers/cyborg_hypospray/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["isDispensingDrinks"] = is_dispensing_drinks
	static_data["transferAmounts"] = possible_transfer_amounts
	return static_data

/obj/item/reagent_containers/cyborg_hypospray/ui_data(mob/user)
	var/list/data = list()
	data["theme"] = tgui_theme
	data["amount"] = amount_per_transfer_from_this
	data["maxVolume"] = max_volume_per_reagent
	var/list/available_reagents = list()
	for(var/datum/reagent/reagent_typepath as anything in stored_reagents)
		available_reagents.Add(list(list(
			"typepath" = reagent_typepath,
			"name" = reagent_typepath.name,
			"description" = reagent_typepath.description,
			"volume" = round(stored_reagents[reagent_typepath], 0.01),
		)))
	data["reagents"] = available_reagents
	data["selectedReagent"] = selected_reagent_typepath
	data["selectedRecipeId"] = selected_recipe_id
	return data

/obj/item/reagent_containers/cyborg_hypospray/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("select_reagent")
			playsound(src, 'sound/effects/pop.ogg', 50, 0)
			var/datum/reagent/clicked_reagent_typepath = params["typepath"]
			if(!isnull(stored_reagents[clicked_reagent_typepath]))
				if(recording_recipe)
					UNTYPED_LIST_ADD(recording_recipe, list("typepath" = clicked_reagent_typepath, "amount" = amount_per_transfer_from_this))
				else
					selected_reagent_typepath = clicked_reagent_typepath
			. = TRUE

		if("set_amount")
			amount_per_transfer_from_this = clamp(round(text2num(params["amount"]), 1), possible_transfer_amounts[1], possible_transfer_amounts[length(possible_transfer_amounts)])
			. = TRUE

		if("record_recipe")
			recording_recipe = list()
			. = TRUE

		if("cancel_recording")
			recording_recipe = null
			. = TRUE

		if("clear_recipes")
			saved_recipes = list()
			. = TRUE

		if("save_recording")
			var/name = tgui_input_text(ui.user, "What do you want to name this recipe?", "Recipe Name?", "Recipe Name", MAX_NAME_LEN)
			if(ui_status(user, state) != UI_INTERACTIVE)
				return
			if(saved_recipes[name] && tgui_alert(ui.user, "\"[name]\" already exists, do you want to overwrite it?",, list("No", "Yes")) != "Yes")
				return
			if(name && recording_recipe)
				for(var/list/recipe_reagent in recording_recipe)
					var/datum/reagent/recipe_typepath = recipe_reagent["typepath"]
					// Verify this hypo can dispense every chemical
					if(isnull(stored_reagents[recipe_typepath]))
						to_chat(user, span_warning("\The [src] cannot find ") + span_boldwarning(recipe_typepath.name) + span_warning("!"))
						return
				saved_recipes[name] = recording_recipe
				recording_recipe = null
				. = TRUE

		if("remove_recipe")
			var/recipe_name = params["recipe"]
			// If we've selected the recipe we're deleting, un-select it!
			if(selected_recipe_id == recipe_name)
				selected_recipe_id = null
			saved_recipes -= recipe_name
			. = TRUE

		if("select_recipe")
			// Make sure we actually have a recipe saved with the given name before setting it!
			var/recipe_name = params["recipe"]
			var/selectedRecipe = saved_recipes[recipe_name]
			if(!selectedRecipe)
				to_chat(user, span_warning("\The [src] cannot find the recipe ") + span_boldwarning(recipe_name) + span_warning("!"))
				return
			playsound(user, 'sound/effects/pop.ogg', 50, 0)
			balloon_alert(user, "now injecting: '[recipe_name]'")
			selected_recipe_id = recipe_name
			. = TRUE

/obj/item/reagent_containers/cyborg_hypospray/medical
	default_reagent_types = BASE_MEDICAL_REAGENTS

#undef BASE_MEDICAL_REAGENTS
