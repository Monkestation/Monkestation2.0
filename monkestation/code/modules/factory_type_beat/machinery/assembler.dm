/obj/machinery/assembler
	name = "assembler"
	desc = "Produces a set recipe when given the materials, some say a small cargo technican is stuck inside making these things."
	circuit = /obj/item/circuitboard/machine/assembler

	var/speed_multiplier = 1
	var/wire_integrity = 1 // Affects speed_multiplier depending on wires cut and causes electric mishaps
	var/datum/crafting_recipe/chosen_recipe
	var/crafting = FALSE
	var/datum/crafting_recipe/current_craft_recipe // The recipe currently being crafted
	var/datum/effect_system/spark_spread/spark_system // The spark system, used for generating... sparks?

	var/static/list/legal_crafting_recipes = list()
	var/list/crafting_inventory = list()

	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "assembler"

/obj/machinery/assembler/Initialize(mapload)
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/hovering_information, /datum/hover_data/assembler)
	register_context()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	var/spark_size = (wire_integrity) * 10
	spark_system.set_up(spark_size, 0, src)
	spark_system.attach(src)

	if(!length(legal_crafting_recipes))
		create_recipes()

/obj/machinery/assembler/proc/empty_crafting_inventory()
	for(var/atom/movable/listed as anything in crafting_inventory)
		listed.forceMove(get_turf(src))
		crafting_inventory -= listed

/obj/machinery/assembler/RefreshParts()
	. = ..()
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	if(!locate_servo)
		return
	speed_multiplier = wire_integrity / locate_servo.tier

/obj/machinery/assembler/proc/refresh_parts()
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	if(!locate_servo)
		return
	if(wire_integrity >= 2)
		wire_integrity = 2
	speed_multiplier = wire_integrity / locate_servo.tier

/obj/machinery/assembler/Destroy()
	. = ..()
	QDEL_NULL(spark_system)
	empty_crafting_inventory()

/obj/machinery/assembler/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(chosen_recipe)
		var/processable = "Accepts: "
		var/comma = FALSE
		for(var/atom/atom as anything in chosen_recipe.reqs)
			if(comma)
				processable += ", "
			processable += initial(atom.name)
			comma = !comma
		context[SCREENTIP_CONTEXT_MISC] = processable

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"

	if(!panel_open)
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_CROWBAR)
		if(!length(crafting_inventory) && !crafting)
			context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		context[SCREENTIP_CONTEXT_RMB] = "Force Apart"

	if(held_item.tool_behaviour == TOOL_MULTITOOL)
		if(!chosen_recipe == null || length(crafting_inventory))
			context[SCREENTIP_CONTEXT_LMB] = "Reset"
		context[SCREENTIP_CONTEXT_RMB] = "Examine Wires"

	if(held_item.tool_behaviour == TOOL_WIRECUTTER && wire_integrity <= 2.0)
		context[SCREENTIP_CONTEXT_LMB] = "Cut Wires"

	if(held_item)
		if(istype(held_item, /obj/item/stack/cable_coil))
			context[SCREENTIP_CONTEXT_LMB] = "Mend Wires"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/assembler/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("The maintenance panel is open.")
		if(wire_integrity == 2)
			. += span_notice("The wires inside are cut apart, hampering its utility.")
		if(wire_integrity >= 1.4 && !wire_integrity == 2)
			. += span_notice("Inside you see a couple stray wires.")

	if(chosen_recipe)
		. += span_notice("Selected recipe: [chosen_recipe.name]")
		for(var/atom/atom as anything in chosen_recipe.reqs)
			if(chosen_recipe.reqs[atom] >= 2)
				. += span_notice("Consumes [chosen_recipe.reqs[atom]] [initial(atom.name)]\s per operation.")
			else
				. += span_notice("Consumes one [initial(atom.name)] per operation.")

	if(length(crafting_inventory))
		. += span_notice("The assembler currently contains the following stacks:")
		for(var/atom/item as anything in crafting_inventory)
			. += span_notice("[initial(item.name)]")

	if(!crafting)
		. += span_notice("The machine currently lies dormant.")

	. += span_notice("Its maintenance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(crafting)
		. += span_notice("The machine cannot be interacted with further while in operation.")
		return

	if(panel_open)
		if(length(crafting_inventory))
			. += span_notice("The machine's ingredient eject function can be triggered with special [EXAMINE_HINT("tools")].")
		. += span_notice("The [EXAMINE_HINT("right tools")] could be used to activate the assembler's wiring diagnostic switch.")
		if(!wire_integrity == 2)
			. += span_notice("The machine's wires can be [EXAMINE_HINT("cut")].")
		if(wire_integrity >= 1.4)
			. += span_notice("The machine's [EXAMINE_HINT("wires")] can be mended.")
		if(!length(crafting_inventory))
			. += span_notice("The machine can be safetly [EXAMINE_HINT("pried")] apart.")
		if(length(crafting_inventory))
			. += span_notice("With the [EXAMINE_HINT("right")] amount of force, the assembler can be [EXAMINE_HINT("pried")] apart, destroying its contents.")


/obj/machinery/assembler/proc/create_recipes()
	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		if(initial(recipe.non_craftable) || !initial(recipe.always_available))
			continue
		legal_crafting_recipes += recipe

/obj/machinery/assembler/attack_hand(mob/living/carbon/user, list/modifiers)
	if(panel_open && iscarbon(user))
		shock(user)

/obj/machinery/assembler/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(panel_open)
		to_chat(user, span_warning("The assembler cannot select a recipe while its service panel is open!"))
		user.balloon_alert(user, "panel open!")
		return
	var/datum/crafting_recipe/choice = tgui_input_list(user, "Choose a recipe", name, legal_crafting_recipes)
	if(!choice)
		return
	chosen_recipe = choice
	if(crafting)
		return
	empty_crafting_inventory()

/obj/machinery/assembler/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!panel_open)
		to_chat(user, span_warning("The assembler cannot be deconstructed while the maintenance panel is closed!"))
		user.balloon_alert(user, "panel closed!")
		return
	if(length(crafting_inventory))
		to_chat(user, span_warning("The assembler cannot be safetly deconstructed until it has been emptied!"))
		user.balloon_alert(user, "needs a reset!")
		return
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/assembler/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "assembler-open", "assembler", tool))
		check_recipe_state()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/assembler/multitool_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!panel_open)
		to_chat(user, span_warning("The assembler cannot be reset while the maintenance panel is closed!"))
		user.balloon_alert(user, "panel closed!")
		return
	if(crafting)
		to_chat(user, span_warning("The assembler cannot be reset until the current operation is completed!"))
		user.balloon_alert(user, "wait for operation!")
		return
	if(!length(crafting_inventory) && chosen_recipe == null)
		to_chat(user, span_warning("The assembler is already reset!"))
		user.balloon_alert(user, "already reset!")
		return
	chosen_recipe = null
	empty_crafting_inventory()
	to_chat(user, span_notice("You reset the assembler with the multitool."))
	user.balloon_alert(user, "reset!")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/assembler/multitool_act_secondary(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!panel_open)
		to_chat(user, span_warning("The wiring diagnostic switch cannot be interfaced while the maintenance panel is closed!"))
		user.balloon_alert(user, "panel closed!")
		return
	var/cut_wires = (wire_integrity - 1) * 5
	if(wire_integrity == 1)
		user.balloon_alert(user, ("wires intact!"))
		to_chat(user, span_green("You activate the wiring diagnostic switch. A small light in the assembler turns green!"))
		return ITEM_INTERACT_SUCCESS
	user.balloon_alert(user, ("[cut_wires] cut wires!"))
	to_chat(user, span_warning("You activate the wiring diagnostic switch. A small light in the assembler blinks red [wire_integrity == 1.2 ? "once" : "[cut_wires] times"]."))
	return ITEM_INTERACT_SUCCESS


/obj/machinery/assembler/wirecutter_act(mob/living/user, obj/item/tool, list/modifiers)
	. = ITEM_INTERACT_BLOCKING
	if(!panel_open)
		to_chat(user, span_warning("The maintenance panel is closed!"))
		user.balloon_alert(user, "panel closed!")
		return
	if(wire_integrity == 2)
		to_chat(user, span_warning("The assembler's wires have all been cut!"))
		balloon_alert(user, "wires already cut!")
		return
	to_chat(user, span_warning("You begin cutting out one of the wires in the assembler."))
	user.balloon_alert(user, "cutting wire...")
	if(tool.use_tool(src, user, 2 SECONDS, volume = 50))
		tool.play_tool_sound(src)
		balloon_alert(user, "wire cut")
		to_chat(user, span_warning("You finish cutting out the wire."))
		wire_integrity += 0.2
		refresh_parts()
		if(iscarbon(user))
			shock(user)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/assembler/proc/shock(mob/living/carbon/user, list/modifiers)
	var/zapchance = (wire_integrity-1)*100
	if(prob(zapchance))
		spark_system.start()
		if(ismecha(loc) || user.wearing_shock_proof_gloves() || HAS_TRAIT(user, TRAIT_SHOCKIMMUNE))
			return
		user.electrocute_act(10, src, 1, SHOCK_NOGLOVES|SHOCK_SUPPRESS_MESSAGE)

/obj/machinery/assembler/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/stack/cable_coil))
		if(!panel_open)
			to_chat(user, span_warning("The maintenance panel is closed!"))
			user.balloon_alert(user, "panel closed!")
			return
		if(wire_integrity == 1)
			to_chat(user, span_warning("You find no loose wires to refit."))
			balloon_alert(user, "no cut wires!")
			return
		to_chat(user, span_warning("You begin mending the assembler's wires."))
		user.balloon_alert(user, "mending wires...")
		if(attacking_item.use_tool(src, user, 2 SECONDS, volume = 50))
			attacking_item.play_tool_sound(src)
			balloon_alert(user, "wires mended")
			to_chat(user, span_warning("You finish mending the wires."))
			wire_integrity = 1
			refresh_parts()
			return ITEM_INTERACT_SUCCESS

/obj/machinery/assembler/attackby_secondary(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.tool_behaviour != TOOL_CROWBAR)
		return
	if(!panel_open)
		to_chat(user, span_warning("The assembler cannot be forcibly deconstructed while the maintenance panel is closed!"))
		user.balloon_alert(user, "panel closed!")
		return
	if(!length(crafting_inventory) && !crafting)
		if(default_deconstruction_crowbar(attacking_item))
			return ITEM_INTERACT_SUCCESS
	user.balloon_alert(user, "forcing apart...")
	if(attacking_item.use_tool(src, user, 3 SECONDS, volume = 50))
		attacking_item.play_tool_sound(src, 50)
		if(length(crafting_inventory))
			balloon_alert(user, "contents destroyed!")
		deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/assembler/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored || !chosen_recipe)
		return FALSE

	var/failed = TRUE
	for(var/atom/movable/movable as anything in chosen_recipe.reqs)
		if(istype(mover, movable))
			failed = FALSE
			break
	if(failed)
		return FALSE

	if(!check_item(mover))
		return FALSE

	return ..()

/obj/machinery/assembler/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(accept_item), atom_movable)

/obj/machinery/assembler/proc/accept_item(atom/movable/atom_movable)
	if(!chosen_recipe)
		return
	if(!isturf(atom_movable.loc))
		return
	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if(!(stack.merge_type in chosen_recipe.reqs))
			return FALSE
	else
		var/failed = TRUE
		for(var/atom/movable/movable as anything in chosen_recipe.reqs)
			if(istype(atom_movable, movable))
				failed = FALSE
				break
		if(failed)
			return FALSE

	atom_movable.forceMove(src)
	crafting_inventory += atom_movable
	check_recipe_state()


/obj/machinery/assembler/can_drop_off(atom/movable/target)
	if(!check_item(target))
		return FALSE
	return TRUE


/obj/machinery/assembler/proc/check_item(atom/movable/atom_movable)
	if(!chosen_recipe)
		return
	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if(!(stack.merge_type in chosen_recipe.reqs))
			return FALSE

	if(!isstack(atom_movable))
		var/failed = TRUE
		for(var/atom/movable/movable as anything in chosen_recipe.reqs)
			if(istype(atom_movable, movable))
				failed = FALSE
				break
		if(failed)
			return FALSE

	var/list/reqs = chosen_recipe.reqs.Copy()
	for(var/atom/movable/listed in reqs)
		reqs[listed] *= 10 // we can queue 10 crafts of everything

	for(var/atom/movable/item in crafting_inventory)
		if(isstack(item))
			var/obj/item/stack/stack = item
			if(item in reqs)
				reqs[item.type] -= stack.amount
				if(reqs[item.type] <= 0)
					reqs -= item.type
		else
			for(var/atom/movable/movable as anything in chosen_recipe.reqs)
				if(istype(item, movable))
					reqs[movable]--
					if(reqs[movable] <= 0)
						reqs -= movable
	if(!length(reqs))
		return FALSE

	var/passed = FALSE
	for(var/atom/movable/movable as anything in chosen_recipe.reqs)
		if(istype(atom_movable, movable))
			passed = TRUE
			break
	if(passed)
		return TRUE

	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if((stack.merge_type in reqs))
			return TRUE

	return FALSE


/obj/machinery/assembler/proc/check_recipe_state()
	if(!chosen_recipe)
		return
	if(panel_open)
		return
	var/list/reqs = chosen_recipe.reqs.Copy()
	if(!length(reqs))
		return

	for(var/atom/movable/item in crafting_inventory)
		if(isstack(item))
			var/obj/item/stack/stack = item
			if(stack.merge_type in reqs)
				reqs[stack.merge_type] -= stack.amount
				if(reqs[stack.merge_type] <= 0)
					reqs -= stack.merge_type
		else
			for(var/atom/movable/movable as anything in chosen_recipe.reqs)
				if(istype(item, movable))
					reqs[movable]--
					if(reqs[movable] <= 0)
						reqs -= movable
	if(!length(reqs))
		start_craft()

/obj/machinery/assembler/proc/consume_stack(obj/item/Type, amount)
	var/left = amount
	for(var/obj/item/item as anything in crafting_inventory)
		if(isstack(item) && istype(item, Type))
			var/obj/item/stack/stack = item
			if(left >= stack.amount)
				left -= stack.amount
				stack.use(stack.amount)
				crafting_inventory -= item
				if(left == 0)
					return
			else
				stack.use(left)
				return

/obj/machinery/assembler/proc/start_craft()
	if(panel_open)
		return
	if(crafting)
		return
	crafting = TRUE
	current_craft_recipe = chosen_recipe // Store the recipe we're actually crafting

	if(!machine_do_after_visable(src, current_craft_recipe.time * speed_multiplier * 3))
		crafting = FALSE
		current_craft_recipe = null
		return

	var/list/requirements = current_craft_recipe.reqs
	var/list/parts = list()

	for(var/obj/item/req as anything in requirements)
		if(ispath(req, /obj/item/stack))
			for(var/obj/item/part as anything in current_craft_recipe.parts)
				if(!istype(req, part))
					continue
				var/obj/item/stack/new_stack = new req.type
				new_stack.amount = current_craft_recipe.parts[part]
				parts += new_stack
			consume_stack(req, requirements[req])
			continue
		else
			var/left = requirements[req]
			for(var/obj/item/item as anything in crafting_inventory)
				if(!istype(item, req))
					continue
				var/failed = TRUE
				crafting_inventory -= item
				for(var/obj/item/part as anything in current_craft_recipe.parts)
					if(!istype(item, part))
						continue
					parts += item
					failed = FALSE

				if(failed)
					qdel(item)
				left -= 1
				if(left <= 0)
					break

	var/atom/movable/I
	if(ispath(current_craft_recipe.result, /obj/item/stack))
		I = new current_craft_recipe.result(src, current_craft_recipe.result_amount || 1)
		I.forceMove(drop_location())
	else
		I = new current_craft_recipe.result (src)
		I.forceMove(drop_location())
		if(I.atom_storage && current_craft_recipe.delete_contents)
			for(var/obj/item/thing in I)
				qdel(thing)
	I.CheckParts(parts, current_craft_recipe)
	I.forceMove(drop_location())
	var/assembler_spark_chance = (wire_integrity - 1) * 50
	if(prob(assembler_spark_chance))
		spark_system.start()
	if(current_craft_recipe != chosen_recipe)
		empty_crafting_inventory()

	crafting = FALSE
	current_craft_recipe = null
	check_recipe_state()

/obj/machinery/assembler/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && atom_integrity > 0) //damage received
		spark_system.start()

/datum/hover_data/assembler
	var/obj/effect/overlay/hover/recipe_icon
	var/last_type

/datum/hover_data/assembler/New(datum/component/hovering_information, atom/parent)
	. = ..()
	recipe_icon = new(null)
	recipe_icon.maptext_width = 64
	recipe_icon.maptext_y = 32
	recipe_icon.maptext_x = -4
	recipe_icon.alpha = 125

/datum/hover_data/assembler/setup_data(obj/machinery/assembler/source, mob/enterer)
	. = ..()
	if(!source.chosen_recipe)
		return
	if(last_type != source.chosen_recipe.result)
		update_image(source)
	var/image/new_image = new(source)
	new_image.appearance = recipe_icon.appearance
	SET_PLANE_EXPLICIT(new_image, new_image.plane, source)
	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	add_client_image(new_image, enterer.client)

/datum/hover_data/assembler/proc/update_image(obj/machinery/assembler/source)
	if(!source.chosen_recipe)
		return
	last_type = source.chosen_recipe.result

	var/atom/atom = source.chosen_recipe.result

	recipe_icon.icon = initial(atom.icon)
	recipe_icon.icon_state = initial(atom.icon_state)
