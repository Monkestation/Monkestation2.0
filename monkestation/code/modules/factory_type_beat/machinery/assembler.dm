#define ASSEMBLER_MAX_CRAFTS 10

/obj/machinery/assembler
	name = "assembler"
	desc = "Produces a set recipe when given the materials, some say a small cargo technican is stuck inside making these things."
	circuit = /obj/item/circuitboard/machine/assembler

	var/speed_multiplier = 1
	var/datum/crafting_recipe/chosen_recipe
	var/crafting = FALSE

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
	//AddComponent(/datum/component/hovering_information, /datum/hover_data/assembler)
	register_context()

	if(!length(legal_crafting_recipes))
		create_recipes()

/obj/machinery/assembler/RefreshParts()
	. = ..()
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	if(!locate_servo)
		return FALSE
	speed_multiplier = 1 / locate_servo.tier

/obj/machinery/assembler/Destroy()
	chosen_recipe = null
	empty_machine()
	return ..()

/obj/machinery/assembler/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Select a recipe."
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

/obj/machinery/assembler/proc/create_recipes()
	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		if(initial(recipe.non_craftable) || !initial(recipe.always_available))
			continue
		legal_crafting_recipes += recipe

/obj/machinery/assembler/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/datum/crafting_recipe/choice = tgui_input_list(user, "Choose a recipe", name, legal_crafting_recipes)
	if(!choice || (choice && chosen_recipe ==  choice))
		return
	chosen_recipe = choice
	empty_machine()

/obj/machinery/assembler/CanAllowThrough(atom/movable/mover, border_dir)
	if(!anchored || !chosen_recipe)
		return FALSE

	if(!check_item(mover))
		return FALSE

	return ..()

/obj/machinery/assembler/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(accept_item), atom_movable)

/obj/machinery/assembler/proc/accept_item(atom/movable/atom_movable)
	if(!chosen_recipe || QDELETED(atom_movable) || !check_item(atom_movable))
		return

	atom_movable.forceMove(src)
	crafting_inventory += atom_movable
	check_recipe_state()
	return TRUE

/obj/machinery/assembler/can_drop_off(atom/movable/target)

/obj/machinery/assembler/proc/check_item(atom/movable/atom_movable)
	if(!chosen_recipe)
		return FALSE

	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		if(!(stack.merge_type in chosen_recipe.reqs))
			return FALSE
	else if(!(atom_movable.type in chosen_recipe.reqs))
		return FALSE

	var/list/remaining_space = get_remaining_requirements(ASSEMBLER_MAX_CRAFTS)

	 // Check if the incoming item's type is still needed
	if(isstack(atom_movable))
		var/obj/item/stack/stack = atom_movable
		return stack.merge_type in remaining_space
	return atom_movable.type in remaining_space

/obj/machinery/assembler/proc/check_recipe_state()
	if(!chosen_recipe)
		return

	if(!length(get_remaining_requirements()))
		start_craft()

/obj/machinery/assembler/proc/empty_machine()
	for(var/atom/movable/listed as anything in crafting_inventory)
		listed.forceMove(get_turf(src))
		crafting_inventory -= listed

/obj/machinery/assembler/proc/get_remaining_requirements(craft_amount = 1)
	if(!chosen_recipe)
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
			if(item.type in remaining_reqs)
				remaining_reqs[item.type]--
				if(remaining_reqs[item.type] <= 0)
					remaining_reqs -= item.type

	return remaining_reqs

/obj/machinery/assembler/proc/start_craft()
	if(crafting)
		return

	RefreshParts()

	if(!machine_do_after_visable(src, chosen_recipe.time * speed_multiplier * 3))
		crafting = FALSE
		addtimer(CALLBACK(src, PROC_REF(check_recipe_state)), 1 SECOND) // Attempt to craft in a second if we were interupted.
		return

	crafting = TRUE
	var/list/requirements = chosen_recipe.reqs.Copy()
	var/list/parts = list()
	for(var/obj/item/req as anything in requirements)
		for(var/obj/item/item as anything in crafting_inventory)
			if(isstack(item))
				var/obj/item/stack/stack = item
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
			else if(istype(item, req))
				requirements[item.type]--
				parts += item
				if(requirements[item.type] <= 0)
					requirements -= item.type

	var/atom/movable/new_craft
	if(ispath(chosen_recipe.result, /obj/item/stack))
		new_craft = new chosen_recipe.result(src, chosen_recipe.result_amount || 1)
	else
		new_craft = new chosen_recipe.result (src)
		if(new_craft.atom_storage && chosen_recipe.delete_contents)
			for(var/obj/item/thing in new_craft)
				qdel(thing)
	crafting_inventory -= parts
	QDEL_LIST(parts)
	//new_craft.CheckParts(parts, chosen_recipe) // Causes part dup issue. If this missing causes issues find a real solution.
	new_craft.forceMove(drop_location())
	crafting = FALSE
	check_recipe_state()

#undef ASSEMBLER_MAX_CRAFTS

/datum/hover_data/assembler
	var/obj/effect/overlay/hover/recipe_icon
	var/last_type

/datum/hover_data/assembler/New(datum/component/hovering_information, atom/parent)
	. = ..()
