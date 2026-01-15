#define INCUBATOR_DISH_GROWTH  (1 << 0)
#define INCUBATOR_DISH_REAGENT (1 << 1)
#define INCUBATOR_DISH_MAJOR   (1 << 2)
#define INCUBATOR_DISH_MINOR   (1 << 3)

/obj/machinery/disease2/incubator
	name = "pathogenic incubator"
	desc = "Uses radiation to accelerate the incubation of pathogen. The dishes must be filled with reagents for the incubation to have any effects."
	density = TRUE
	anchored = TRUE
	icon = 'monkestation/code/modules/virology/icons/virology.dmi'
	base_icon_state = "incubator"
	icon_state = "incubator"

	circuit = /obj/item/circuitboard/machine/incubator

	light_color = "#6496FA"
	light_outer_range = 2
	light_power = 1

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.2

	processing_flags = START_PROCESSING_MANUALLY

	// Contains instances of /datum/dish_incubator_dish.
	var/list/dish_data = list(null, null, null)

	var/on = FALSE

	var/mutatechance = 10
	var/growthrate = 8
	var/can_focus = FALSE //Whether the machine can focus on an effect to mutate it or not
	var/effect_focus = 0 //What effect of the disease are we focusing on?


/obj/machinery/disease2/incubator/Destroy()
	for(var/i in 1 to length(dish_data))
		var/datum/dish_incubator_dish/dish_datum = dish_data[i]
		if(isnull(dish_datum))
			continue

		if(!QDELETED(dish_datum.dish))
			dish_datum.dish.forceMove(drop_location())
		dish_data[i] = null
	return ..()

/obj/machinery/disease2/incubator/RefreshParts()
	. = ..()
	var/scancount = 0
	var/lasercount = 0
	for(var/datum/stock_part/scanning_module/SP in component_parts)
		scancount += SP.tier * 0.5
	for(var/datum/stock_part/micro_laser/SP in component_parts)
		lasercount += SP.tier * 0.5
	if(lasercount >= 4)
		can_focus = TRUE
	else
		can_focus = FALSE
	mutatechance = initial(mutatechance) * max(1, scancount)
	growthrate = initial(growthrate) + lasercount


/obj/machinery/disease2/incubator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isvirusdish(tool))
		return NONE

	if(machine_stat & BROKEN)
		to_chat(user, span_warning("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return ITEM_INTERACT_BLOCKING

	for(var/i in 1 to length(dish_data))
		if(isnull(dish_data[i])) // Empty slot
			add_dish(tool, user, i)
			return ITEM_INTERACT_SUCCESS

	to_chat(user, span_warning("There is no more room inside \the [src]. Remove a dish first."))
	return ITEM_INTERACT_BLOCKING

/obj/machinery/disease2/incubator/screwdriver_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	if(on)
		to_chat(user, span_warning("\The [src] is currently on! Please turn the machine off."))
		return FALSE
	return default_deconstruction_screwdriver(user, "[base_icon_state]u", base_icon_state, tool)

/obj/machinery/disease2/incubator/crowbar_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	if(on)
		to_chat(user, span_warning("\The [src] is currently processing! Please wait until completion."))
		return FALSE
	return default_deconstruction_crowbar(tool)

/obj/machinery/disease2/incubator/proc/add_dish(obj/item/weapon/virusdish/dish, mob/user, slot)
	if(!dish.open)
		to_chat(user, span_warning("You must open the dish's lid before it can be put inside the incubator. Be sure to wear proper protection first (at least a sterile mask and latex gloves)."))
		return

	if(!isnull(dish_data[slot]))
		to_chat(user, span_warning("This slot is already occupied. Remove the dish first."))
		return

	if(!user.transferItemToLoc(dish, src))
		return

	dish_data[slot] = new /datum/dish_incubator_dish(dish)

	visible_message(span_notice("[user] adds \the [dish] to \the [src]."), span_notice("You add \the [dish] to \the [src]."))
	playsound(src, 'sound/machines/click.ogg', vol = 50, vary = TRUE, mixer_channel = CHANNEL_MACHINERY)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/disease2/incubator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("power")
			set_on(!on, user)
			return TRUE

		if("ejectdish")
			var/slot = text2num(params["slot"])
			if(!isnum(slot) || !ISINRANGE(slot, 1, length(dish_data)))
				return TRUE

			var/datum/dish_incubator_dish/dish_datum = dish_data[slot]
			if(isnull(dish_datum))
				return TRUE

			dish_datum.dish.forceMove(drop_location())
			if(Adjacent(user))
				user.put_in_hands(dish_datum.dish)

			dish_datum.dish.update_appearance()
			dish_data[slot] = null
			update_appearance(UPDATE_OVERLAYS)
			return TRUE

		if("insertdish")
			var/slot = text2num(params["slot"])
			if(!isnum(slot) || !ISINRANGE(slot, 1, length(dish_data)))
				return TRUE

			if(!isliving(user))
				return TRUE

			var/obj/item/weapon/virusdish/VD = user.get_active_hand()
			if(istype(VD))
				add_dish(VD, user, slot)

			return TRUE

		if("examinedish")
			var/slot = text2num(params["slot"])
			if(!isnum(slot) || !ISINRANGE(slot, 1, length(dish_data)))
				return TRUE

			var/datum/dish_incubator_dish/dish_datum = dish_data[slot]
			if(isnull(dish_datum))
				return TRUE

			user.examinate(dish_datum.dish)
			return TRUE

		if("flushdish")
			var/slot = text2num(params["slot"])
			if(!isnum(slot) || !ISINRANGE(slot, 1, length(dish_data)))
				return TRUE

			var/datum/dish_incubator_dish/dish_datum = dish_data[slot]
			if(isnull(dish_datum))
				return TRUE

			dish_datum.dish.reagents.clear_reagents()
			return TRUE
		if("changefocus")
			var/slot = text2num(params["slot"])
			if(!isnum(slot) || !ISINRANGE(slot, 1, length(dish_data)))
				return TRUE
			var/datum/dish_incubator_dish/dish_datum = dish_data[slot]
			if(isnull(dish_datum))
				return TRUE
			var/stage_to_focus = tgui_input_number(user, "Choose a stage to focus on. This will block symptoms from other stages from being mutated. Input 0 to disable effect focusing.", "Choose a stage.")
			if(!stage_to_focus)
				to_chat(user, span_notice("The effect focusing is now turned off."))
			else
				to_chat(user, span_notice("\The [src] will now focus on stage [stage_to_focus]."))
			effect_focus = stage_to_focus
			return TRUE

/obj/machinery/disease2/incubator/attack_hand(mob/user)
	. = ..()
	if(machine_stat & BROKEN)
		to_chat(user, span_notice("\The [src] is broken. Some components will have to be replaced before it can work again."))
		return
	if(machine_stat & NOPOWER)
		to_chat(user, span_notice("Deprived of power, \the [src] is unresponsive."))
		for(var/i in 1 to length(dish_data))
			var/datum/dish_incubator_dish/dish_datum = dish_data[i]
			if(isnull(dish_datum))
				continue

			playsound(src, 'sound/machines/click.ogg', vol = 50, vary = TRUE, mixer_channel = CHANNEL_MACHINERY)
			dish_datum.dish.forceMove(drop_location())
			dish_data[i] = null
			sleep(0.1 SECONDS)

		update_appearance(UPDATE_OVERLAYS)

	if(.)
		return

	ui_interact(user)

/obj/machinery/disease2/incubator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DiseaseIncubator", "Incubator")
		ui.open()

/obj/machinery/disease2/incubator/ui_data(mob/user)
	// this is the data which will be sent to the ui
	var/list/data = list()

	var/dish_amt = length(dish_data)
	data["on"] = on
	data["can_focus"] = can_focus
	data["focus_stage"] = effect_focus
	var/list/dish_ui_data = new /list(dish_amt)
	data["dishes"] = dish_ui_data

	for(var/i = 1 to dish_amt)
		var/datum/dish_incubator_dish/dish_datum = dish_data[i]
		var/list/dish_ui_datum = list()
		dish_ui_data[i] = dish_ui_datum

		var/inserted = !isnull(dish_datum)
		dish_ui_datum["inserted"] = inserted
		if(!inserted)
			dish_ui_datum["name"] = "Empty Slot"
			continue

		dish_ui_datum["name"] = dish_datum.dish.name
		dish_ui_datum["growth"] = dish_datum.dish.growth
		dish_ui_datum["reagents_volume"] = round(dish_datum.dish.reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
		dish_ui_datum["major_mutations"] = dish_datum.major_mutations_count
		dish_ui_datum["minor_mutations_strength"] = mutatechance //add support for other reagents
		dish_ui_datum["minor_mutations_robustness"] = mutatechance //add support for other reagents
		dish_ui_datum["minor_mutations_effects"] = mutatechance //add support for other reagents
		dish_ui_datum["dish_slot"] = i

		var/list/symptom_data = list()
		var/obj/item/weapon/virusdish/dish = dish_datum.dish
		dish_ui_datum["contains_disease"] = istype(dish.contained_virus) ? TRUE : FALSE
		for(var/datum/symptom/symptom in dish.contained_virus?.symptoms)
			if(!(dish.contained_virus.disease_flags & DISEASE_ANALYZED))
				symptom_data += list(list("name" = "Unknown", "desc" = "Unknown", "strength" = symptom.multiplier, "max_strength" = symptom.max_multiplier, "chance" = symptom.chance, "max_chance" = symptom.max_chance, "stage" = symptom.stage))
				continue
			symptom_data += list(list("name" = symptom.name, "desc" = symptom.desc, "strength" = symptom.multiplier, "max_strength" = symptom.max_multiplier, "chance" = symptom.chance, "max_chance" = symptom.max_chance, "stage" = symptom.stage))
		dish_ui_datum["symptom_data"] = symptom_data

	return data

/obj/machinery/disease2/incubator/on_set_machine_stat(old_value)
	. = ..()
	update_appearance(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/disease2/incubator/on_set_is_operational(old_value)
	. = ..()
	if(!is_operational)
		set_on(FALSE)

/obj/machinery/disease2/incubator/process()
	if(!on)
		return PROCESS_KILL

	for(var/datum/dish_incubator_dish/dish_datum in dish_data)
		dish_datum.dish.incubate(mutatechance, growthrate, effect_focus)

/obj/machinery/disease2/incubator/proc/set_on(status, mob/user)
	if(status == on)
		return
	on = status
	if(on)
		update_use_power(ACTIVE_POWER_USE)
		begin_processing()
		if(user)
			for(var/datum/dish_incubator_dish/dish_datum in dish_data)
				if(dish_datum.dish?.contained_virus)
					dish_datum.dish.contained_virus.log += "<br />[ROUND_TIME()] Incubation started by [key_name(user)]"
	else
		update_use_power(IDLE_POWER_USE)
		end_processing()
	update_appearance(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/machinery/disease2/incubator/proc/find_dish_datum(obj/item/weapon/virusdish/dish)
	for(var/datum/dish_incubator_dish/dish_datum in dish_data)
		if(dish_datum.dish == dish)
			return dish_datum

	return null

/obj/machinery/disease2/incubator/proc/update_major(obj/item/weapon/virusdish/dish)
	var/datum/dish_incubator_dish/dish_datum = find_dish_datum(dish)
	if(isnull(dish_datum))
		return

	dish_datum.updates_new |= INCUBATOR_DISH_MAJOR
	dish_datum.updates &= ~INCUBATOR_DISH_MAJOR
	dish_datum.major_mutations_count++

/obj/machinery/disease2/incubator/proc/update_minor(obj/item/weapon/virusdish/dish, str=0, rob=0, eff=0)
	var/datum/dish_incubator_dish/dish_datum = find_dish_datum(dish)
	if(isnull(dish_datum))
		return

	dish_datum.updates_new |= INCUBATOR_DISH_MINOR
	dish_datum.updates &= ~INCUBATOR_DISH_MINOR
	dish_datum.minor_mutation_strength += str;
	dish_datum.minor_mutation_robustness += rob;
	dish_datum.minor_mutation_effects += eff;

/obj/machinery/disease2/incubator/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]b"
	else if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]0"
	else
		icon_state = base_icon_state
	return ..()

/obj/machinery/disease2/incubator/update_appearance(updates)
	. = ..()
	if(!is_operational)
		set_light(0)
	else if(on)
		set_light(2, 2)
	else
		set_light(2, 1)

/obj/machinery/disease2/incubator/update_overlays()
	. = ..()
	if(on && is_operational)
		. += mutable_appearance(icon, "incubator_light")
		. += mutable_appearance(icon, "incubator_glass")
		. += emissive_appearance(icon, "incubator_light", src)
		. += emissive_appearance(icon, "incubator_glass", src)

	for(var/i = 1 to length(dish_data))
		if(!isnull(dish_data[i]))
			. += add_dish_sprite(dish_data[i], i)

/obj/machinery/disease2/incubator/proc/add_dish_sprite(datum/dish_incubator_dish/dish_datum, slot)
	var/obj/item/weapon/virusdish/dish = dish_datum.dish
	var/list/overlays = list()

	slot--
	var/mutable_appearance/dish_outline = mutable_appearance(icon, "smalldish2-outline")
	dish_outline.alpha = 128
	dish_outline.pixel_z = -5 * slot
	overlays += dish_outline
	var/mutable_appearance/dish_content = mutable_appearance(icon, "smalldish2-empty")
	dish_content.alpha = 128
	dish_content.pixel_z = -5 * slot
	if(dish.contained_virus)
		dish_content.icon_state = "smalldish2-color"
		dish_content.color = dish.contained_virus.color
	overlays += dish_content

	//updating the light indicators
	if(dish.contained_virus && is_operational)
		var/mutable_appearance/grown_gauge = mutable_appearance(icon, "incubator_growth7", offset_spokesman = src, plane = ABOVE_LIGHTING_PLANE)
		grown_gauge.pixel_z = -5 * slot
		if(dish.growth < 100)
			grown_gauge.icon_state = "incubator_growth[clamp(round(dish.growth * 70 / 1000), 1, 6)]"
		else
			var/update = FALSE
			if(!(dish_datum.updates & INCUBATOR_DISH_GROWTH))
				dish_datum.updates += INCUBATOR_DISH_GROWTH
				update = TRUE

			if(update)
				var/mutable_appearance/grown_light = emissive_appearance(icon, "incubator_grown_update", src)
				grown_light.pixel_z = -5 * slot
				var/mutable_appearance/grown_light_n = mutable_appearance(icon, "incubator_grown_update")
				grown_light_n.pixel_z = -5 * slot

				overlays += grown_light
				overlays += grown_light_n
			else
				var/mutable_appearance/grown_light = emissive_appearance(icon, "incubator_grown", src)
				grown_light.pixel_z = -5 * slot
				var/mutable_appearance/grown_light_n = mutable_appearance(icon, "incubator_grown")
				grown_light_n.pixel_z = -5 * slot

				overlays += grown_light_n
				overlays += grown_light

		overlays += grown_gauge
		if(round(dish.reagents.total_volume, CHEMICAL_QUANTISATION_LEVEL) < 0.02)
			var/update = FALSE
			if(!(dish_datum.updates & INCUBATOR_DISH_REAGENT))
				dish_datum.updates += INCUBATOR_DISH_REAGENT
				update = TRUE

			if(update)
				var/mutable_appearance/reagents_light = emissive_appearance(icon, "incubator_reagents_update", src)
				reagents_light.pixel_z = -5 * slot
				var/mutable_appearance/reagents_light_n = mutable_appearance(icon, "incubator_reagents_update")
				reagents_light_n.pixel_z = -5 * slot

				overlays += reagents_light_n
				overlays += reagents_light
			else
				var/mutable_appearance/reagents_light = emissive_appearance(icon, "incubator_reagents", src)
				reagents_light.pixel_z = -5 * slot
				var/mutable_appearance/reagents_light_n = mutable_appearance(icon, "incubator_reagents")
				reagents_light_n.pixel_z = -5 * slot

				overlays += reagents_light_n
				overlays += reagents_light

		/*
		if(dish_datum.updates_new & INCUBATOR_DISH_MAJOR)
			if(!(dish_datum.updates & INCUBATOR_DISH_MAJOR))
				dish_datum.updates += INCUBATOR_DISH_MAJOR
				var/mutable_appearance/effect_light = emissive_appearance(icon, "incubator_major_update", src)
				effect_light.pixel_z = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon, "incubator_major_update")
				effect_light_n.pixel_z = -5 * slot

				overlays += effect_light_n
				overlays += effect_light
			else
				var/mutable_appearance/effect_light = emissive_appearance(icon, "incubator_major", src)
				effect_light.pixel_z = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon, "incubator_major")
				effect_light_n.pixel_z = -5 * slot

				overlays += effect_light_n
				overlays += effect_light

		if(dish_datum.updates_new & INCUBATOR_DISH_MINOR)
			if(!(dish_datum.updates & INCUBATOR_DISH_MINOR))
				dish_datum.updates += INCUBATOR_DISH_MINOR
				var/mutable_appearance/effect_light = emissive_appearance(icon, "incubator_minor_update", src)
				effect_light.pixel_z = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon, "incubator_minor_update")
				effect_light_n.pixel_z = -5 * slot

				overlays += effect_light_n

				overlays += effect_light
			else
				var/mutable_appearance/effect_light = mutable_appearance(icon, "incubator_minor")
				effect_light.pixel_z = -5 * slot
				var/mutable_appearance/effect_light_n = mutable_appearance(icon, "incubator_minor", src)
				effect_light_n.pixel_z = -5 * slot

				overlays += effect_light_n
				overlays += effect_light
			*/

	return overlays

/datum/dish_incubator_dish
	// The inserted virus dish.
	var/obj/item/weapon/virusdish/dish

	var/major_mutations_count = 0

	var/minor_mutation_strength = 0
	var/minor_mutation_robustness = 0
	var/minor_mutation_effects = 0

	var/updates_new = NONE
	var/updates = NONE

/datum/dish_incubator_dish/New(obj/item/weapon/virusdish/dish)
	. = ..()
	src.dish = dish

/datum/dish_incubator_dish/Destroy(force)
	dish = null
	return ..()

#undef INCUBATOR_DISH_GROWTH
#undef INCUBATOR_DISH_REAGENT
#undef INCUBATOR_DISH_MAJOR
#undef INCUBATOR_DISH_MINOR
