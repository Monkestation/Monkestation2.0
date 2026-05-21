/// All of the default reagent lists for each hypospray along with hacked variants.
#define BASE_MEDICAL_REAGENTS list(\
		/datum/reagent/medicine/c2/aiuri,\
		/datum/reagent/medicine/c2/convermol,\
		/datum/reagent/medicine/epinephrine,\
		/datum/reagent/medicine/c2/libital,\
		/datum/reagent/medicine/c2/multiver,\
		/datum/reagent/medicine/salglu_solution,\
		/datum/reagent/medicine/antipathogenic/spaceacillin\
	)

#define EXPANDED_MEDICAL_REAGENTS list(\
		/datum/reagent/medicine/haloperidol,\
		/datum/reagent/medicine/inacusiate,\
		/datum/reagent/medicine/mannitol,\
		/datum/reagent/medicine/mutadone,\
		/datum/reagent/medicine/oculine,\
		/datum/reagent/medicine/oxandrolone,\
		/datum/reagent/medicine/pen_acid,\
		/datum/reagent/medicine/rezadone,\
		/datum/reagent/medicine/sal_acid\
	)

#define HACKED_MEDICAL_REAGENTS list(\
		/datum/reagent/toxin/cyanide,\
		/datum/reagent/toxin/acid/fluacid,\
		/datum/reagent/toxin/heparin,\
		/datum/reagent/toxin/lexorin,\
		/datum/reagent/toxin/mutetoxin,\
		/datum/reagent/toxin/sodium_thiopental\
	)

#define BASE_PEACE_REAGENTS list(\
		/datum/reagent/peaceborg/confuse,\
		/datum/reagent/pax/peaceborg,\
		/datum/reagent/peaceborg/tire\
	)
#define HACKED_PEACE_REAGENTS list(\
		/datum/reagent/toxin/cyanide,\
		/datum/reagent/toxin/fentanyl,\
		/datum/reagent/toxin/sodium_thiopental,\
		/datum/reagent/toxin/staminatoxin,\
		/datum/reagent/toxin/sulfonal\
	)

#define BASE_SERVICE_REAGENTS list(/datum/reagent/consumable/applejuice, /datum/reagent/consumable/banana,\
		/datum/reagent/consumable/coffee, /datum/reagent/consumable/cream, /datum/reagent/consumable/dr_gibb,\
		/datum/reagent/consumable/grenadine, /datum/reagent/consumable/ice, /datum/reagent/consumable/lemonjuice,\
		/datum/reagent/consumable/lemon_lime, /datum/reagent/consumable/limejuice, /datum/reagent/consumable/menthol,\
		/datum/reagent/consumable/milk, /datum/reagent/consumable/nothing, /datum/reagent/consumable/orangejuice,\
		/datum/reagent/consumable/peachjuice, /datum/reagent/consumable/pineapplejuice,\
		/datum/reagent/consumable/pwr_game, /datum/reagent/consumable/shamblers, /datum/reagent/consumable/sodawater,\
		/datum/reagent/consumable/sol_dry, /datum/reagent/consumable/soymilk, /datum/reagent/consumable/space_cola,\
		/datum/reagent/consumable/spacemountainwind, /datum/reagent/consumable/space_up, /datum/reagent/consumable/sugar,\
		/datum/reagent/consumable/tea, /datum/reagent/consumable/tomatojuice, /datum/reagent/consumable/tonic,\
		/datum/reagent/water,\
		/datum/reagent/consumable/ethanol/ale, /datum/reagent/consumable/ethanol/applejack, /datum/reagent/consumable/ethanol/beer,\
		/datum/reagent/consumable/ethanol/champagne, /datum/reagent/consumable/ethanol/cognac, /datum/reagent/consumable/ethanol/creme_de_coconut,\
		/datum/reagent/consumable/ethanol/creme_de_cacao, /datum/reagent/consumable/ethanol/creme_de_menthe, /datum/reagent/consumable/ethanol/gin,\
		/datum/reagent/consumable/ethanol/kahlua, /datum/reagent/consumable/ethanol/rum, /datum/reagent/consumable/ethanol/sake,\
		/datum/reagent/consumable/ethanol/tequila, /datum/reagent/consumable/ethanol/triple_sec, /datum/reagent/consumable/ethanol/vermouth,\
		/datum/reagent/consumable/ethanol/vodka, /datum/reagent/consumable/ethanol/whiskey, /datum/reagent/consumable/ethanol/wine,\
	)
#define HACKED_SERVICE_REAGENTS list(\
		/datum/reagent/toxin/fakebeer,\
		/datum/reagent/consumable/ethanol/fernet,\
	)

#define BASE_CLOWN_REAGENTS list(\
		/datum/reagent/consumable/laughter\
	)

#define HACKED_CLOWN_REAGENTS list(\
		/datum/reagent/consumable/superlaughter\
	)

#define BASE_SYNDICATE_REAGENTS list(\
		/datum/reagent/medicine/inacusiate,\
		/datum/reagent/medicine/painkiller/morphine,\
		/datum/reagent/medicine/potass_iodide,\
		/datum/reagent/medicine/syndicate_nanites\
	)

#define BASE_CENTCOM_REAGENTS list(\
		/datum/reagent/consumable/icetea, /datum/reagent/consumable/melon_soda, /datum/reagent/consumable/bogril,\
		/datum/reagent/consumable/ethanol/absinthe, /datum/reagent/consumable/ethanol/coconut_rum, /datum/reagent/consumable/ethanol/curacao,\
		/datum/reagent/consumable/ethanol/hcider, /datum/reagent/consumable/ethanol/beer/maltliquor, /datum/reagent/consumable/ethanol/navy_rum,\
		/datum/reagent/consumable/ethanol/rice_beer, /datum/reagent/consumable/ethanol/yuyake, /datum/reagent/consumable/ethanol/wine_voltaic\
	)

#define BASE_STANDARD_REAGENTS list(\
		/datum/reagent/medicine/epinephrine,\
		/datum/reagent/medicine/salglu_solution,\
	)

#define PARAMEDIC_MEDICAL_REAGENTS list(\
		/datum/reagent/medicine/epinephrine,\
		/datum/reagent/toxin/formaldehyde,\
		/datum/reagent/medicine/ammoniated_mercury,\
		/datum/reagent/medicine/painkiller/morphine\
	)

/obj/item/reagent_containers/cyborg_hypospray
	name = "cyborg hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/medical/syringe.dmi'
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
	var/list/datum/reagent/stored_reagents = list()
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
	if(!isnull(default_reagent_types))
		add_reagent_list(default_reagent_types)
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/cyborg_hypospray/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/// Every [recharge_time] seconds, restore all of the hypospray's reagents.
/obj/item/reagent_containers/cyborg_hypospray/process(seconds_per_tick)
	. = TRUE
	charge_timer += (seconds_per_tick SECONDS)
	if(recharge_time > charge_timer)
		return
	charge_timer = 0
	regenerate_reagents(stored_reagents, initial(amount_per_transfer_from_this))

/obj/item/reagent_containers/cyborg_hypospray/attack(mob/living/target_mob, mob/user)
	var/mob/living/carbon/injectee = target_mob
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
	to_chat(injectee, span_warning("You feel a tiny prick!"))
	to_chat(user, span_notice("You inject [injectee] with the injector ([selected_reagent_typepath ? selected_reagent_typepath.name : selected_recipe_id])."))
	balloon_alert(user, "[reagent_injector.total_volume] unit\s injected")
	reagent_injector.trans_to(injectee, reagent_injector.total_volume, transfered_by = user, methods = INJECT)
	log_combat(user, injectee, "injected", src, "(CHEMICALS: [reagent_injector])")

/obj/item/reagent_containers/cyborg_hypospray/attack_self(mob/user)
	ui_interact(user)

/// Adds a list of reagents that can be produced.
/obj/item/reagent_containers/cyborg_hypospray/proc/add_reagent_list(list/datum/reagent/reagent_typepaths)
	for(var/datum/reagent/reagent_typepath as anything in reagent_typepaths)
		if(stored_reagents[reagent_typepath])
			continue
		stored_reagents[reagent_typepath] = max_volume_per_reagent

/// Removes a list of reagents from being produced.
/obj/item/reagent_containers/cyborg_hypospray/proc/remove_reagent_list(list/datum/reagent/reagent_typepaths)
	for(var/datum/reagent/reagent_typepath as anything in reagent_typepaths)
		if(!stored_reagents[reagent_typepath])
			continue
		stored_reagents[reagent_typepath] = null
		if(selected_reagent_typepath == reagent_typepath)
			selected_reagent_typepath = null

/// Regenerates the supply of multiple reagents (if they're not full already).
/obj/item/reagent_containers/cyborg_hypospray/proc/regenerate_reagents(list/datum/reagent/reagents_typepaths_to_regen, amount)
	var/total_charge_cost = 0
	for(var/datum/reagent/reagents_typepath_to_regen as anything in reagents_typepaths_to_regen)
		if(!stored_reagents[reagents_typepath_to_regen])
			continue
		var/reagent_volume = stored_reagents[reagents_typepath_to_regen]
		if(reagent_volume >= max_volume_per_reagent)
			continue
		stored_reagents[reagents_typepath_to_regen] = clamp(reagent_volume + amount, 0, reagent_volume)
		total_charge_cost += charge_cost
	if(iscyborg(loc))
		var/mob/living/silicon/robot/cyborg = loc
		cyborg.cell?.use(total_charge_cost)

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
					balloon_alert(user, "not enough [recipe_typepath.name]!")
				return FALSE
		return TRUE
	if(!silent)
		balloon_alert(user, "no reagent selected!")
	return FALSE

/// Creates the reagents. Capped by the injection volume (single) or by possible transfer amount (recipe).
/obj/item/reagent_containers/cyborg_hypospray/proc/create_reagent_injector()
	var/datum/reagents/reagent_injector = new(new_flags = NO_REACT)
	if(selected_reagent_typepath)
		reagent_injector.add_reagent(selected_reagent_typepath, amount_per_transfer_from_this, reagtemp = dispensed_temperature, no_react = TRUE)
	else if(selected_recipe_id)
		var/recipe_information = saved_recipes[selected_recipe_id]
		if(recipe_information)
			for(var/recipe_step in recipe_information)
				var/recipe_typepath = recipe_step["typepath"]
				var/recipe_amount_amount = recipe_step["volume"]
				reagent_injector.add_reagent(recipe_typepath, recipe_amount_amount, reagtemp = dispensed_temperature, no_react = TRUE)

	var/capped_injection_volume = clamp(reagent_injector.total_volume, possible_transfer_amounts[1], possible_transfer_amounts[length(possible_transfer_amounts)])
	if(capped_injection_volume >= reagent_injector.total_volume)
		for(var/datum/reagent/added_reagent in reagent_injector.reagent_list)
			deplete_reagent(added_reagent.type, added_reagent.volume)
		return reagent_injector

	// Only transfer and consume reagents up to the cap.
	var/datum/reagents/limited_reagent_injector = new(new_flags = NO_REACT)
	reagent_injector.trans_to(limited_reagent_injector, capped_injection_volume, methods = INJECT)
	for(var/datum/reagent/added_reagent in limited_reagent_injector.reagent_list)
		deplete_reagent(added_reagent.type, added_reagent.volume)
	return limited_reagent_injector

/// Upgrades the hypospray.
/obj/item/reagent_containers/cyborg_hypospray/proc/upgrade()
	if(upgraded || isnull(expanded_reagent_types))
		return FALSE
	upgraded = TRUE
	add_reagent_list(expanded_reagent_types)
	return TRUE

/// Degrades the hypospray.
/obj/item/reagent_containers/cyborg_hypospray/proc/degrade()
	if(upgraded || isnull(expanded_reagent_types))
		return FALSE
	upgraded = FALSE
	remove_reagent_list(expanded_reagent_types)
	return TRUE

/obj/item/reagent_containers/cyborg_hypospray/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgChemicalDispenser", "Integrated Chemical Hypospray")
		ui.open()

/obj/item/reagent_containers/cyborg_hypospray/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["transferAmounts"] = possible_transfer_amounts
	static_data["minTransferVolume"] = possible_transfer_amounts[1]
	static_data["maxTransferVolume"] = possible_transfer_amounts[length(possible_transfer_amounts)]
	static_data["maxReagentVolume"] = max_volume_per_reagent
	return static_data

/obj/item/reagent_containers/cyborg_hypospray/ui_data(mob/user)
	var/list/data = list()
	data["theme"] = tgui_theme
	data["amount"] = amount_per_transfer_from_this
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
	data["saved_recipes"] = saved_recipes
	data["recording"] = !isnull(recording_recipe)
	data["recordingRecipe"] = recording_recipe
	return data

/obj/item/reagent_containers/cyborg_hypospray/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("select_reagent")
			playsound(src, 'sound/effects/pop.ogg', 50, 0)
			var/datum/reagent/clicked_reagent_typepath = text2path(params["typepath"])
			if(!isnull(stored_reagents[clicked_reagent_typepath]))
				if(recording_recipe)
					UNTYPED_LIST_ADD(recording_recipe, list("typepath" = clicked_reagent_typepath, "name" = clicked_reagent_typepath.name, "volume" = amount_per_transfer_from_this))
				else
					selected_reagent_typepath = clicked_reagent_typepath
					selected_recipe_id = null
			. = TRUE

		if("set_amount")
			// It is intentional that they can transfer an amount that is not defined in `possible_transfer_amounts`.
			// As long they are between the minimum and maximum, it is a feature as we allow for custom value.
			amount_per_transfer_from_this = clamp(round(text2num(params["amount"]), 1), possible_transfer_amounts[1], possible_transfer_amounts[length(possible_transfer_amounts)])
			. = TRUE

		if("record_recipe")
			recording_recipe = list()
			. = TRUE

		if("cancel_recording")
			recording_recipe = null
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
			selected_reagent_typepath = null
			. = TRUE

/// Medical cyborg hypospray.
/obj/item/reagent_containers/cyborg_hypospray/medical
	default_reagent_types = BASE_MEDICAL_REAGENTS
	expanded_reagent_types = EXPANDED_MEDICAL_REAGENTS

/obj/item/reagent_containers/cyborg_hypospray/medical/hacked
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	default_reagent_types = HACKED_MEDICAL_REAGENTS
	expanded_reagent_types = null

/// Peacekeeper cyborg hypospray.
/obj/item/reagent_containers/cyborg_hypospray/peace
	name = "Peace Hypospray"
	default_reagent_types = BASE_PEACE_REAGENTS

/obj/item/reagent_containers/cyborg_hypospray/peace/hacked
	desc = "Everything's peaceful in death!"
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	default_reagent_types = HACKED_PEACE_REAGENTS

/// Clown cyborg hypospray.
/obj/item/reagent_containers/cyborg_hypospray/clown
	name = "laughter injector"
	desc = "Keeps the crew happy and productive!"
	default_reagent_types = BASE_CLOWN_REAGENTS

/obj/item/reagent_containers/cyborg_hypospray/clown/hacked
	desc = "Keeps the crew so happy they don't work!"
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	default_reagent_types = HACKED_CLOWN_REAGENTS

/// Standard cyborg hypospray.
/obj/item/reagent_containers/cyborg_hypospray/epi
	name = "Emergency Hypospray"
	desc = "Better then nothing, right?"
	default_reagent_types = BASE_STANDARD_REAGENTS

/// Syndicate medical cyborg hypospray.
/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. \
		Also metabolizes potassium iodide for radiation poisoning, inacusiate for ear damage and morphine for offense."
	icon_state = "borghypo_s"
	tgui_theme = "syndicate"
	charge_cost = 0.02 * STANDARD_CELL_CHARGE
	recharge_time = 2 SECONDS
	default_reagent_types = BASE_SYNDICATE_REAGENTS
	bypass_protection = TRUE

/// Paramedic toolset hypospray.
/obj/item/reagent_containers/cyborg_hypospray/paramedic
	name = "emergency paramedic hypospray"
	desc = "A cut-down version of the cyborg's chemical synthesizer and injection system for paramedics able to fit into implants."
	amount_per_transfer_from_this = 2
	max_volume_per_reagent = 10
	default_reagent_types = PARAMEDIC_MEDICAL_REAGENTS
	bypass_protection = TRUE

/obj/item/reagent_containers/cyborg_hypospray/shaker
	name = "cyborg shaker"
	desc = "An advanced drink synthesizer and mixer."
	icon = 'icons/obj/drinks/bottles.dmi'
	icon_state = "shaker"
	possible_transfer_amounts = list(5, 10, 20)
	charge_cost = 0.02 * STANDARD_CELL_CHARGE // Lots of reagents all regenerating at once, so the charge cost is lower. They also regenerate faster.
	recharge_time = 3 SECONDS
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP // Water stays wet. Ice stays ice.
	default_reagent_types = BASE_SERVICE_REAGENTS

/obj/item/reagent_containers/cyborg_hypospray/shaker/attack(mob/living/target_mob, mob/user)
	return // No injecting people with this.

/obj/item/reagent_containers/cyborg_hypospray/shaker/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with.is_refillable())
		return NONE
	if(!has_reagents_for_injection(user, FALSE)) // Gives balloon alerts.
		return ITEM_INTERACT_BLOCKING
	if(interacting_with.reagents.total_volume >= interacting_with.reagents.maximum_volume)
		balloon_alert(user, "it's full!")
		return ITEM_INTERACT_BLOCKING
	var/datum/reagents/reagent_injector = create_reagent_injector()
	balloon_alert(user, "[reagent_injector.total_volume] unit\s poured")
	reagent_injector.trans_to(interacting_with, reagent_injector.total_volume, transfered_by = user)
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/cyborg_hypospray/shaker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorgChemicalShaker", "Integrated Drink Dispenser")
		ui.open()

/obj/item/reagent_containers/cyborg_hypospray/shaker/ui_data(mob/user)
	var/list/alcohol_reagents = list()
	var/list/drink_reagents = list()
	for(var/datum/reagent/reagent_typepath as anything in stored_reagents)
		// Split the reagents into alcoholic / non-alcoholic.
		if(istype(reagent_typepath, /datum/reagent/consumable/ethanol))
			alcohol_reagents.Add(list(list(
				"typepath" = reagent_typepath,
				"name" = reagent_typepath.name,
				"description" = reagent_typepath.description,
				"volume" = round(stored_reagents[reagent_typepath], 0.01)
			)))
			continue
		drink_reagents.Add(list(list(
			"typepath" = reagent_typepath,
			"name" = reagent_typepath.name,
			"description" = reagent_typepath.description,
			"volume" = round(stored_reagents[reagent_typepath], 0.01)
		)))

	var/list/data = list()
	data["theme"] = tgui_theme
	data["amount"] = amount_per_transfer_from_this
	data["reagents_alc"] = alcohol_reagents
	data["reagents_nonalc"] = drink_reagents
	data["selectedReagent"] = selected_reagent_typepath
	data["selectedRecipeId"] = selected_recipe_id
	data["saved_recipes"] = saved_recipes
	data["recording"] = !isnull(recording_recipe)
	data["recordingRecipe"] = recording_recipe
	return data

/obj/item/reagent_containers/borghypo/borgshaker/hacked
	name = "cyborg shaker"
	desc = "Will mix drinks that knock them dead."
	icon_state = "threemileislandglass"
	icon = 'icons/obj/drinks/mixed_drinks.dmi'
	tgui_theme = "syndicate"
	dispensed_temperature = WATER_MATTERSTATE_CHANGE_TEMP
	default_reagent_types = HACKED_SERVICE_REAGENTS

/obj/item/reagent_containers/borghypo/borgshaker/centcom
	max_volume_per_reagent = 50
	possible_transfer_amounts = list(5, 10, 20, 50, 100)
	charge_cost = 0.05 * STANDARD_CELL_CHARGE
	recharge_time = 1 SECOND

/obj/item/reagent_containers/borghypo/borgshaker/centcom/Initialize(mapload)
	default_reagent_types += BASE_CENTCOM_REAGENTS
	. = ..()

#undef BASE_MEDICAL_REAGENTS
#undef EXPANDED_MEDICAL_REAGENTS
#undef HACKED_MEDICAL_REAGENTS
#undef BASE_PEACE_REAGENTS
#undef HACKED_PEACE_REAGENTS
#undef BASE_SERVICE_REAGENTS
#undef HACKED_SERVICE_REAGENTS
#undef BASE_CLOWN_REAGENTS
#undef HACKED_CLOWN_REAGENTS
#undef BASE_SYNDICATE_REAGENTS
#undef BASE_CENTCOM_REAGENTS
#undef BASE_STANDARD_REAGENTS
#undef PARAMEDIC_MEDICAL_REAGENTS
