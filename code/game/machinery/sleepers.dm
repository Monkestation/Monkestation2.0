/obj/machinery/sleeper
	name = "sleeper"
	desc = "An enclosed machine used to stabilize and heal patients."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	base_icon_state = "sleeper"
	density = FALSE
	obj_flags = BLOCKS_CONSTRUCTION
	state_open = TRUE
	interaction_flags_mouse_drop = NEED_DEXTERITY
	circuit = /obj/item/circuitboard/machine/sleeper
	clicksound = 'sound/machines/pda_button1.ogg'

	payment_department = ACCOUNT_MED
	fair_market_price = 5

	///How much chems is allowed to be in a patient at once, before we force them to wait for the reagent to process.
	var/efficiency = 1
	///The minimum damage required to use any chem other than Epinephrine.
	var/min_health = -25
	///Whether the machine can be operated by the person inside of it.
	var/controls_inside = FALSE
	///Message sent when a user enters the machine.
	var/enter_message = span_boldnotice("You feel cool air surround you. You go numb as your senses turn inward.")

	///Сurrent dose
	var/inject_amount = 5
	///Available dose options
	var/list/available_amounts = list(1, 2, 3, 5, 10, 15, 20)
	///List of currently available chems.
	var/list/available_chems = list()
	///Used when emagged to scramble which chem is used, eg: mutadone -> morphine
	var/list/chem_buttons

	/// Is the synthesis of custom chemicals enabled?
	var/synthesis_active = FALSE
	/// Chemical for accelerated synthesis (null = random)
	var/forced_synthesis_chem
	/// Synthesis rate (depends on the capacity)
	var/synthesis_rate = 0.25

	/// Maximum capacity for each custom chemical (depends on matter_bin)
	var/max_custom_storage = 50
	/// Storage of custom chemicals: reagent path -> quantity
	var/list/custom_chem_storage = list()

	///All chems this sleeper will get, depending on the parts inside.
	var/list/possible_chems = list(
		list(
			/datum/reagent/medicine/c2/libital, // line 1
			/datum/reagent/medicine/c2/aiuri,
			/datum/reagent/medicine/c2/multiver,
			/datum/reagent/medicine/salbutamol,
			/datum/reagent/medicine/epinephrine, // line 2
			/datum/reagent/medicine/painkiller/morphine,
		),
		list(
			/datum/reagent/medicine/oculine,
			/datum/reagent/medicine/inacusiate,
			/datum/reagent/medicine/salglu_solution,  // line 3
			/datum/reagent/medicine/antipathogenic/spaceacillin,
			/datum/reagent/medicine/potass_iodide,
		),
		list(
			/datum/reagent/toxin/formaldehyde,
			/datum/reagent/medicine/pen_acid, // line 4
			/datum/reagent/medicine/mutadone,
			/datum/reagent/medicine/mannitol,
		),
		list(
			/datum/reagent/medicine/diphenhydramine,
			/datum/reagent/medicine/omnizine, // line 5
			/datum/reagent/medicine/nanopaste,
			/datum/reagent/medicine/coagulant,
			/datum/reagent/toxin/radiomagnetic_disruptor,
		),
	)

	/// List of custom chemicals available for addition. >>> ORDER IS IMPORTANT <<<
	var/list/available_custom_chems = list(
		// First, declare categories and subtypes
		/datum/reagent/medicine = TRUE,
		/datum/reagent/toxin = FALSE,
		/datum/reagent/consumable = TRUE,

		// Second, declare direct names
		/datum/reagent/iron = TRUE,
		/datum/reagent/water = TRUE,

		// Third, we declare exceptions from categories that will overwrite the value.
		/datum/reagent/toxin/mutagen = TRUE,
		/datum/reagent/toxin/plasma = TRUE,
		/datum/reagent/toxin/lipolicide = TRUE,
	)

	/// Emergency chemicals (can be administered in any condition, including the dead)
	var/list/emergency_chems = list(
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/atropine,
		/datum/reagent/medicine/salbutamol,
		/datum/reagent/medicine/coagulant,
		/datum/reagent/medicine/rezadone,
		/datum/reagent/medicine/c2/synthflesh,
		/datum/reagent/toxin/formaldehyde,
	)
	/// Adds a special set of chemicals when using E-mag
	var/list/emag_chems_to_add = list(
		/datum/reagent/toxin/cyanide,
		/datum/reagent/toxin/acid/fluacid,
		/datum/reagent/toxin/heparin,
		/datum/reagent/toxin/lexorin,
		/datum/reagent/toxin/mutetoxin,
		/datum/reagent/toxin/sodium_thiopental,
		/datum/reagent/toxin/mutagen,
	)

/obj/machinery/sleeper/Initialize(mapload)
	. = ..()
	occupant_typecache = GLOB.typecache_living
	update_appearance()
	reset_chem_buttons()

/obj/machinery/sleeper/RefreshParts()
	. = ..()
	// Matterbin — maximum injection limit, volume of synthesis capacity, minimum acceptable health for work
	var/matterbin_rating = 0
	for(var/datum/stock_part/matter_bin/matterbins in component_parts)
		matterbin_rating += matterbins.tier

	efficiency = initial(efficiency) * max(matterbin_rating, 1)
	min_health = initial(min_health) * max(matterbin_rating, 1)
	max_custom_storage = initial(max_custom_storage) * max(matterbin_rating, 1)

	// Capacitor — synthesis rate
	var/capacitor_rating = 0
	for(var/datum/stock_part/capacitor/capacitors in component_parts)
		capacitor_rating += capacitors.tier
	switch(capacitor_rating)
		if(2)
			synthesis_rate = 0.05	// 0.25u / 10sec
		if(3)
			synthesis_rate = 0.1	// 0.5u / 10sec
		if(4)
			synthesis_rate = 0.2	// 1u / 10sec
		else
			synthesis_rate = 0

	// Manipulator — open standard chemicals
	var/manipulator_rating = 0
	for(var/datum/stock_part/manipulator/manipulators in component_parts)
		manipulator_rating += manipulators.tier
	available_chems.Cut()
	for(var/i in 1 to manipulator_rating)
		if(i <= possible_chems.len)
			available_chems |= possible_chems[i]

	reset_chem_buttons()

/obj/machinery/sleeper/update_icon_state()
	icon_state = "[base_icon_state][state_open ? "-open" : null]"
	return ..()

/obj/machinery/sleeper/attackby(obj/item/weapon, mob/user, params)
	if(is_reagent_container(weapon) && weapon.is_open_container())
		var/obj/item/reagent_containers/container = weapon
		if(!length(container.reagents.reagent_list))
			balloon_alert(user, "container is empty!")
			return

		var/added_any = FALSE

		// It eat all reagents in 1 beaker
		for(var/datum/reagent/reagent in container.reagents.reagent_list)
			var/chem_path = reagent.type

			if(!is_chem_allowed(chem_path))
				continue

			var/current = custom_chem_storage[chem_path] || 0
			var/space_left = max_custom_storage - current

			if(space_left <= 0)
				continue

			var/to_add = min(reagent.volume, space_left)
			container.reagents.remove_reagent(chem_path, to_add)
			custom_chem_storage[chem_path] = current + to_add
			added_any = TRUE

		user.do_attack_animation(src)
		if(added_any)
			playsound(src, 'sound/effects/pop.ogg', 50, 0)
			update_appearance()
			balloon_alert(user, "chemicals added!")
		else
			balloon_alert(user, "no compatible chemicals!")
		return

	return ..()

// Can u add custom chem?
/obj/machinery/sleeper/proc/is_chem_allowed(chem_path)
	// Direct name and exceptions
	for(var/key in available_custom_chems)
		if(chem_path == key)
			return available_custom_chems[key]

	// Category
	for(var/key in available_custom_chems)
		if(ispath(chem_path, key))
			return available_custom_chems[key]

	return FALSE

/obj/machinery/sleeper/container_resist_act(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/sleeper/Exited(atom/movable/gone, direction)
	. = ..()
	if (!state_open && gone == occupant)
		container_resist_act(gone)

/obj/machinery/sleeper/relaymove(mob/living/user, direction)
	if (!state_open)
		container_resist_act(user)

/obj/machinery/sleeper/open_machine(drop = TRUE, density_to_set = FALSE)
	if(!state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		playsound(src, 'sound/effects/servostep.ogg', 50, 0)
	return ..()

/obj/machinery/sleeper/close_machine(mob/user, density_to_set = TRUE)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		playsound(src, 'sound/effects/servostep.ogg', 50, 0)
		..()
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")

/obj/machinery/sleeper/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational && occupant)
		open_machine()

/obj/machinery/sleeper/mouse_drop_receive(atom/target, mob/user, params)
	if(!iscarbon(target))
		return
	target.visible_message(span_warning(
		"[user] starts buckling [target] to [src]!"),
		span_userdanger("[user] starts buckling you to [src]!"),
		span_hear("You hear metal clanking."),
	)
	if(!do_after(user, 1 SECONDS, target))
		return
	close_machine(target)

/obj/machinery/sleeper/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(occupant)
		to_chat(user, span_warning("[src] is currently occupied!"))
		return TRUE
	if(state_open)
		to_chat(user, span_warning("[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!"))
		return TRUE
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return TRUE
	return FALSE

/obj/machinery/sleeper/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_change_direction_wrench(user, I))
		return TRUE
	return FALSE

/obj/machinery/sleeper/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_pry_open(I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	return FALSE

/obj/machinery/sleeper/default_pry_open(obj/item/I) //wew
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open [src]."), span_notice("You pry open [src]."))
		open_machine()

/obj/machinery/sleeper/ui_state(mob/user)
	if(!controls_inside)
		return GLOB.notcontained_state
	return GLOB.default_state

/obj/machinery/sleeper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Sleeper", name)
		ui.open()

/obj/machinery/sleeper/click_alt(mob/user)
	if(state_open)
		close_machine()
	else
		open_machine()
	return CLICK_ACTION_SUCCESS

/obj/machinery/sleeper/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to [state_open ? "close" : "open"] it.")

/obj/machinery/sleeper/process()
	if(synthesis_active)
		use_energy(active_power_usage)
	else
		use_energy(idle_power_usage)

	if(synthesis_active)
		perform_synthesis()

/obj/machinery/sleeper/proc/perform_synthesis()
	if(!length(custom_chem_storage))
		synthesis_active = FALSE
		return

	// Get list of incomplete chemicals
	var/list/not_full_chems = list()
	for(var/chem in custom_chem_storage)
		var/current = custom_chem_storage[chem] || 0
		if(current < max_custom_storage)
			not_full_chems += chem

	if(!length(not_full_chems))
		synthesis_active = FALSE
		return

	// Choosing a chemical for synthesis
	var/target_chem
	if(forced_synthesis_chem && (forced_synthesis_chem in not_full_chems))
		target_chem = forced_synthesis_chem
	else if(forced_synthesis_chem && !(forced_synthesis_chem in not_full_chems))
		// The forced chemical is full — we switch to a random one
		forced_synthesis_chem = null
		target_chem = pick(not_full_chems)
	else
		target_chem = pick(not_full_chems)

	if(!target_chem)
		return

	var/current = custom_chem_storage[target_chem] || 0
	var/to_add = min(synthesis_rate, max_custom_storage - current)
	if(to_add <= 0)
		return

	custom_chem_storage[target_chem] = current + to_add

/obj/machinery/sleeper/nap_violation(mob/violator)
	. = ..()
	open_machine()

/obj/machinery/sleeper/ui_data()
	var/list/data = list()
	data["occupied"] = !!occupant
	data["open"] = state_open
	data["available_amounts"] = available_amounts
	data["inject_amount"] = inject_amount
	data["max_custom_storage"] = max_custom_storage
	var/is_synthesizing = FALSE
	if(synthesis_active)
		for(var/chem in custom_chem_storage)
			var/current = custom_chem_storage[chem] || 0
			if(current < max_custom_storage)
				is_synthesizing = TRUE
				break

	data["is_synthesizing"] = is_synthesizing
	data["synthesis_active"] = synthesis_active
	data["synthesis_rate"] = synthesis_rate
	data["forced_synthesis_chem"] = forced_synthesis_chem ? "[forced_synthesis_chem]" : null

	var/forced_name = null
	if(forced_synthesis_chem)
		var/datum/reagent/R = GLOB.chemical_reagents_list[forced_synthesis_chem]
		if(R)
			forced_name = R.name
	data["forced_synthesis_name"] = forced_name

	// --- STANDARD CHEMICALS (endless) ---
	data["standard_chems"] = list()
	for(var/chem in available_chems)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		var/display_name = R.display_name_short ? R.display_name_short : R.name
		data["standard_chems"] += list(
			list(
				"name" = display_name,
				"full_name" = R.name,
				"id" = R.type,
				"allowed" = chem_allowed(chem),
				"description" = R.description,
				"is_standard" = TRUE,
			),
		)

	// --- CUSTOM CHEMICALS (finite) ---
	data["custom_chems"] = list()
	for(var/chem in custom_chem_storage)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		if(!R)
			continue
		var/display_name = R.display_name_short ? R.display_name_short : R.name
		var/stored = custom_chem_storage[chem] || 0
		var/percent = round((stored / max_custom_storage) * 100)
		var/is_empty = stored < inject_amount

		data["custom_chems"] += list(
			list(
				"name" = display_name,
				"full_name" = R.name,
				"id" = R.type,
				"allowed" = !is_empty && chem_allowed(chem),
				"description" = R.description,
				"storage" = stored,
				"max_storage" = max_custom_storage,
				"percent" = percent,
				"is_empty" = is_empty,
			),
		)

	data["occupant"] = list()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS, HARD_CRIT)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = mob_occupant.health
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = mob_occupant.dead_threshold
		data["occupant"]["bruteLoss"] = mob_occupant.getBruteLoss()
		data["occupant"]["oxyLoss"] = mob_occupant.getOxyLoss()
		data["occupant"]["toxLoss"] = mob_occupant.getToxLoss()
		data["occupant"]["fireLoss"] = mob_occupant.getFireLoss()
		data["occupant"]["cloneLoss"] = mob_occupant.getCloneLoss()
		data["occupant"]["brainLoss"] = mob_occupant.get_organ_loss(ORGAN_SLOT_BRAIN)
		data["occupant"]["blood_volume"] = mob_occupant.blood_volume

		// Chems in blood
		var/list/blood_chems = list()
		if(mob_occupant.reagents && length(mob_occupant.reagents.reagent_list))
			for(var/datum/reagent/reagent in mob_occupant.reagents.reagent_list)
				if(reagent.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems on scanners
					continue
				var/display_volume = round(reagent.volume, 0.001)
				blood_chems += list(list(
					"name" = reagent.name,
					"volume" = display_volume,
					"overdosed" = reagent.overdosed
				))
		data["occupant"]["blood_chems"] = blood_chems

		data["occupant"]["reagents"] = list()
		if(mob_occupant.reagents && mob_occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
				if(R.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems
					continue
				data["occupant"]["reagents"] += list(
					list(
						"name" = R.name,
						"volume" = R.volume,
					),
				)

	return data

/obj/machinery/sleeper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/mob_occupant = occupant
	check_nap_violations()
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE

		if("inject")
			var/chem = text2path(params["chem"])
			if(!is_operational || !mob_occupant || isnull(chem))
				return

			// Emergency chemicals can always be administered, the rest — only if the health is above the threshold.
			if(!(chem in emergency_chems) && mob_occupant.health < min_health)
				balloon_alert(usr, "patient too damaged!")
				return

			if(inject_chem(chem, usr))
				playsound(src, 'sound/items/hypospray.ogg', 50, TRUE, 2)
				. = TRUE

		if("toggle_synthesis")
			if(!length(custom_chem_storage))
				balloon_alert(usr, "no custom chemicals!")
				return
			synthesis_active = !synthesis_active
			if(synthesis_active)
				balloon_alert(usr, "synthesis started")
			else
				balloon_alert(usr, "synthesis stopped")
			. = TRUE

		if("force_synthesis")
			var/chem = text2path(params["chem"])
			if(!chem || !(chem in custom_chem_storage))
				return
			if(forced_synthesis_chem == chem)
				forced_synthesis_chem = null
				balloon_alert(usr, "synthesis: random")
			else
				forced_synthesis_chem = chem
				balloon_alert(usr, "synthesis: [chem]")
				if(!synthesis_active)
					synthesis_active = TRUE
			. = TRUE

		if("inject_custom")
			var/chem = text2path(params["chem"])
			if(!is_operational || !mob_occupant || isnull(chem))
				return
			var/stored = custom_chem_storage[chem] || 0
			if(stored < inject_amount)
				balloon_alert(usr, "not enough!")
				return
			var/actual_amount = min(inject_amount, 20 * efficiency - mob_occupant.reagents.get_reagent_amount(chem))
			if(actual_amount > 0)
				mob_occupant.reagents.add_reagent(chem, actual_amount)
				custom_chem_storage[chem] = stored - actual_amount
				if(usr)
					log_combat(usr, mob_occupant, "injected [actual_amount] units of custom [chem] into", addition = "via [src]")
				playsound(src, 'sound/items/hypospray.ogg', 50, TRUE, 2)
				. = TRUE

		if("remove_custom_chem")
			var/chem = text2path(params["chem"])
			if(!chem || !(chem in custom_chem_storage))
				return
			if(forced_synthesis_chem == chem)
				forced_synthesis_chem = null
			custom_chem_storage -= chem
			if(!length(custom_chem_storage))
				synthesis_active = FALSE
			playsound(src, 'sound/effects/pop.ogg', 50, 0)
			. = TRUE

		if("set_amount")
			var/new_amount = text2num(params["amount"])
			if(new_amount in available_amounts)
				playsound(src, 'sound/effects/pop.ogg', 50, 0)
				inject_amount = new_amount
				. = TRUE

/obj/machinery/sleeper/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "already emagged!")
		return FALSE

	var/choice = tgui_input_list(user, "Select emag function:", "Sleeper Emag", list(
		"Scramble Buttons",
		"Syndicate chemicals kit",
		"Cancel"
	))

	if(!choice || choice == "Cancel")
		return FALSE

	balloon_alert(user, "interface scrambled")
	obj_flags |= EMAGGED

	switch(choice)
		if("Scramble Buttons")
			var/list/av_chem = available_chems.Copy()
			for(var/chem in av_chem)
				chem_buttons[chem] = pick_n_take(av_chem)
			to_chat(user, span_warning("Chemical buttons scrambled!"))

		if("Syndicate chemicals kit")
			available_custom_chems[/datum/reagent/toxin] = TRUE

			for(var/toxin in emag_chems_to_add)
				if(!(toxin in custom_chem_storage))
					custom_chem_storage[toxin] = 20

			to_chat(user, span_warning("Toxic chemicals unlocked and added to synthesis data base!"))
	return TRUE

/obj/machinery/sleeper/proc/inject_chem(chem, mob/user)
	if((chem in available_chems) && chem_allowed(chem))
		//dosage of medications
		var/actual_amount = min(inject_amount, 20 * efficiency - occupant.reagents.get_reagent_amount(chem))
		if(actual_amount > 0)
			occupant.reagents.add_reagent(chem_buttons[chem], actual_amount)
			if(user)
				log_combat(user, occupant, "injected [actual_amount] units of [chem] into", addition = "via [src]")
			return TRUE
	return FALSE

// Can u inject chem?
/obj/machinery/sleeper/proc/chem_allowed(chem)
	var/mob/living/mob_occupant = occupant
	if(!mob_occupant || !mob_occupant.reagents)
		return FALSE

	var/amount = mob_occupant.reagents.get_reagent_amount(chem) + inject_amount <= 20 * efficiency
	var/occ_health = (chem in emergency_chems) || mob_occupant.health > min_health

	var/has_storage = TRUE
	if(chem in custom_chem_storage)
		var/stored = custom_chem_storage[chem] || 0
		has_storage = stored >= inject_amount

	return amount && occ_health && has_storage

/obj/machinery/sleeper/proc/reset_chem_buttons()
	obj_flags &= ~EMAGGED
	LAZYINITLIST(chem_buttons)
	for(var/chem in available_chems)
		chem_buttons[chem] = chem

/**
 * Syndicate version
 * Can be controlled from the inside and can be deconstructed.
 */
/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s"
	base_icon_state = "sleeper_s"
	controls_inside = TRUE

///Fully upgraded variant, the circuit using tier 4 parts.
/obj/machinery/sleeper/syndie/fullupgrade
	circuit = /obj/item/circuitboard/machine/sleeper/fullupgrade

/obj/machinery/sleeper/self_control
	controls_inside = TRUE

/obj/machinery/sleeper/old
	icon_state = "oldpod"
	base_icon_state = "oldpod"

/obj/machinery/sleeper/party
	name = "party pod"
	desc = "'Sleeper' units were once known for their healing properties, until a lengthy investigation revealed they were also dosing patients with deadly lead acetate. This appears to be one of those old 'sleeper' units repurposed as a 'Party Pod'. It’s probably not a good idea to use it."
	icon_state = "partypod"
	base_icon_state = "partypod"
	circuit = /obj/item/circuitboard/machine/sleeper/party
	controls_inside = TRUE
	enter_message = span_boldnotice("You're surrounded by some funky music inside the chamber. You zone out as you feel waves of krunk vibe within you.")

	//Exclusively uses non-lethal, "fun" chems. At an obvious downside.
	possible_chems = list(
		list(
			/datum/reagent/consumable/ethanol/beer,
			/datum/reagent/consumable/laughter,
		),
		list(
			/datum/reagent/spraytan,
			/datum/reagent/barbers_aid,
		),
		list(
			/datum/reagent/colorful_reagent,
			/datum/reagent/hair_dye,
		),
		list(
			/datum/reagent/drug/space_drugs,
			/datum/reagent/baldium,
		),
	)
	///Chemicals that need to have a touch or vapor reaction to be applied, not the standard chamber reaction.
	var/spray_chems = list(
		/datum/reagent/spraytan,
		/datum/reagent/hair_dye,
		/datum/reagent/baldium,
		/datum/reagent/barbers_aid,
	)

/obj/machinery/sleeper/party/inject_chem(chem, mob/user)
	if(obj_flags & EMAGGED)
		occupant.reagents.add_reagent(/datum/reagent/toxin/leadacetate, 4)
	else if (prob(20)) //You're injecting chemicals into yourself from a recalled, decrepit medical machine. What did you expect?
		occupant.reagents.add_reagent(/datum/reagent/toxin/leadacetate, rand(1,3))
	if(chem in spray_chems)
		var/datum/reagents/holder = new()
		holder.add_reagent(chem_buttons[chem], 10) //I hope this is the correct way to do this.
		holder.trans_to(occupant, 10, methods = VAPOR)
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		if(user)
			log_combat(user, occupant, "sprayed [chem] into", addition = "via [src]")
		return TRUE
	return ..()
