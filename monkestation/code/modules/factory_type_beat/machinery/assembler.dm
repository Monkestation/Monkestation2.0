#define ASSEMBLER_MAX_CRAFTS 10

/obj/machinery/assembler
	name = "assembler"
	desc = "Produces a set recipe when given the materials, some say a small cargo technican is stuck inside making these things."
	circuit = /obj/item/circuitboard/machine/assembler
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	anchored = TRUE
	//density = TRUE

	var/speed_multiplier = 1
	var/bulk_craft_storage = 1
	var/datum/crafting_recipe/chosen_recipe
	var/crafting = FALSE
	var/datum/crafting_recipe/current_craft_recipe // The recipe currently being crafted

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

	if(!length(legal_crafting_recipes))
		create_recipes()

/obj/machinery/assembler/on_deconstruction(disassembled)
	chosen_recipe = null
	empty_machine()

/obj/machinery/assembler/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Select a recipe."
		context[SCREENTIP_CONTEXT_RMB] = "Restart crafting."
	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Un" : ""]Anchor"
	else if(panel_open && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"

	if(chosen_recipe)
		var/processable = "Accepts: "
		var/list/named_reqs = list()
		for(var/atom/atom as anything in chosen_recipe.reqs)
			named_reqs += initial(atom.name)
		context[SCREENTIP_CONTEXT_MISC] = processable + english_list(named_reqs)
	else
		context[SCREENTIP_CONTEXT_MISC] = "No recipe selected."
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/assembler/examine(mob/user)
	. = ..()
	if(chosen_recipe)
		. += span_notice(chosen_recipe.name)
		for(var/atom/atom as anything in chosen_recipe.reqs)
			. += span_notice("[initial(atom.name)]: [chosen_recipe.reqs[atom]]")

	if(anchored)
		. += span_notice("Its [EXAMINE_HINT("anchored")] in place.")
	else
		. += span_warning("It needs to be [EXAMINE_HINT("anchored")] to start operations.")
	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("The whole machine can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/assembler/proc/create_recipes()
	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		if(initial(recipe.non_craftable) || !initial(recipe.always_available))
			continue
		legal_crafting_recipes += recipe

/obj/machinery/assembler/RefreshParts()
	. = ..()
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	var/datum/stock_part/matter_bin/locate_bin = null //locate() in component_parts
	if(!locate_servo)
		speed_multiplier = 2 // If they somehow do this reward them with longer crafting times.
	else
		speed_multiplier = 1 / locate_servo.tier
	if(!locate_bin)
		bulk_craft_storage = 1

/obj/machinery/assembler/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(modifiers["left"] == "1")
		var/datum/crafting_recipe/choice = tgui_input_list(user, "Choose a recipe", name, legal_crafting_recipes)
		if(!choice || (choice && chosen_recipe ==  choice))
			return
		chosen_recipe = choice
		empty_machine()

/obj/machinery/assembler/attackby(obj/item/attacking_item, mob/user, params)
	. = accept_item(attacking_item)
	if(.)
		balloon_alert_to_viewers("accepted")
		return
	balloon_alert_to_viewers("cannot accept!")
	return ..()

/obj/machinery/assembler/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!anchored)
		balloon_alert(user, "anchor it first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	balloon_alert(user, "Starting crafting process!")
	begin_processing()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/assembler/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		if(!anchored)
			end_processing()
		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/assembler/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), tool))
		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/assembler/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return

/obj/machinery/assembler/proc/empty_machine()
	dump_inventory_contents(crafting_inventory)
	crafting_inventory.Cut()

/obj/machinery/assembler/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(accept_item), atom_movable)

/obj/machinery/assembler/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored || panel_open || !is_operational || (machine_stat & (BROKEN | NOPOWER)))
		return FALSE

	if(!chosen_recipe || istype(mover, /mob))
		return FALSE

	if(!check_item(mover))
		return FALSE

	return ..()

/obj/machinery/assembler/proc/get_remaining_requirements(craft_amount = 1)
	if(!chosen_recipe || !craft_amount)
		return null

	var/list/remaining_reqs = chosen_recipe.reqs.Copy()
	for(var/listed in remaining_reqs)
		remaining_reqs[listed] *= craft_amount

	for(var/atom/movable/item in crafting_inventory)
		if(isstack(item))
			var/obj/item/stack/stack = item
			if(stack.merge_type in remaining_reqs)
				remaining_reqs[stack.merge_type] -= stack.amount
				if(remaining_reqs[stack.merge_type] <= 0)
					remaining_reqs -= stack.merge_type
		else
			for(var/req_type in remaining_reqs)
				if(istype(item, req_type))
					remaining_reqs[req_type]--
					if(remaining_reqs[req_type] <= 0)
						remaining_reqs -= req_type
					break // already counted dont need to look at the other req_types

	return remaining_reqs

/obj/machinery/assembler/proc/check_item(atom/movable/atom_movable)
	if(!chosen_recipe)
		return FALSE

	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if(!(stack.merge_type in chosen_recipe.reqs) || (stack.merge_type in chosen_recipe.blacklist))
			return FALSE
	else if(!is_type_in_list(atom_movable, chosen_recipe.reqs) || is_type_in_list(atom_movable, chosen_recipe.blacklist))
		return FALSE

	var/list/remaining_space = get_remaining_requirements(ASSEMBLER_MAX_CRAFTS)

	// Check if the incoming item's type is still needed
	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		return stack.merge_type in remaining_space
	else
		return is_type_in_list(atom_movable, remaining_space)

/obj/machinery/assembler/proc/accept_item(atom/movable/atom_movable)
	if(!chosen_recipe || QDELETED(atom_movable) || !check_item(atom_movable))
		return FALSE

	atom_movable.forceMove(src)
	crafting_inventory += atom_movable
	begin_processing()
	return TRUE

/obj/machinery/assembler/can_drop_off(atom/movable/target)
	return check_item(target)

/obj/machinery/assembler/process()
	if(!anchored || panel_open || !is_operational || (machine_stat & (BROKEN | NOPOWER)))
		return
	if(!chosen_recipe)
		end_processing()
	if(!crafting)
		INVOKE_ASYNC(src, PROC_REF(start_craft), bulk_craft_storage)

/obj/machinery/assembler/proc/start_craft(amt = 1)
	if(!chosen_recipe || crafting)
		return
	crafting = TRUE
	current_craft_recipe = chosen_recipe // Store the recipe we're actually crafting

	if(!machine_do_after_visable(src, current_craft_recipe.time * speed_multiplier * 3))
		crafting = FALSE
		current_craft_recipe = null
	if(length(get_remaining_requirements(amt)) || !machine_do_after_visable(src, chosen_recipe.time * speed_multiplier * 3))
		crafting = FALSE
		return

	var/list/requirements = current_craft_recipe.reqs
	var/list/requirements = chosen_recipe.reqs.Copy()
	for(var/listed in requirements)
		requirements[listed] *= amt
	var/list/parts = list()
	for(var/obj/item/req as anything in requirements)
		for(var/obj/item/item as anything in crafting_inventory)
			if(!length(requirements))
				break // We already satisfied the requirements don't check other items.

			if(isstack(item) && (req in requirements))
				var/obj/item/stack/stack = item
				if(stack.amount == requirements[stack.merge_type])
					var/failed = TRUE
					crafting_inventory -= item
					for(var/obj/item/part as anything in current_craft_recipe.parts)
						if(!istype(item, part))
							continue
						parts += item
						failed = FALSE
					if(failed)
						qdel(item)
				else if(stack.amount > requirements[item.type])
					for(var/obj/item/part as anything in current_craft_recipe.parts)
						if(!istype(item, part))
				if(stack.merge_type == req)
					if(stack.is_zero_amount(TRUE)) // How this happened who knows delete it..
						continue
					else if(stack.amount <= requirements[stack.merge_type])
						requirements[stack.merge_type] -= stack.amount
						parts += stack
					else if(stack.amount > requirements[stack.merge_type])
						var/amt_used = requirements[stack.merge_type]
						var/obj/item/stack/new_stack
						if(stack.use(used = amt_used, check = FALSE))
							new_stack = new stack.merge_type(src, amt_used, FALSE, stack.mats_per_unit)
							crafting_inventory += new_stack
							if(stack.is_zero_amount(TRUE))
								crafting_inventory -= stack
							requirements[stack.merge_type] -= new_stack.amount
							parts += new_stack
						else
							continue
					if(requirements[stack.merge_type] <= 0)
						requirements -= stack.merge_type
			else if(istype(item, req) && (req in requirements))
				requirements[req]--
				parts += item
				if(requirements[req] <= 0)
					requirements -= req

	if(length(requirements))
		crafting = FALSE
		return
	for(var/i in 1 to amt)
		var/atom/movable/new_craft
		if(ispath(chosen_recipe.result, /obj/item/stack))
			new_craft = new chosen_recipe.result(src, chosen_recipe.result_amount || 1)
		else
			new_craft = new chosen_recipe.result (src)
			if(new_craft.atom_storage && chosen_recipe.delete_contents)
				for(var/obj/item/thing in new_craft)
					qdel(thing)
		//new_craft.CheckParts(parts, chosen_recipe) // Causes part dup issue. If this missing causes issues find a real solution.
		new_craft.forceMove(drop_location())
	crafting_inventory -= parts
	QDEL_LIST(parts)
	use_energy(active_power_usage * amt)
	RefreshParts()
	crafting = FALSE
	current_craft_recipe = null
	check_recipe_state()

#undef ASSEMBLER_MAX_CRAFTS

/datum/hover_data/assembler
	var/obj/effect/overlay/hover/recipe_icon
	var/last_type

/datum/hover_data/assembler/New(datum/component/hovering_information, atom/parent)
	. = ..()
	recipe_icon = new(null)
	recipe_icon.maptext_width = 64
	recipe_icon.maptext_y = 32
	recipe_icon.maptext_x = -41
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
