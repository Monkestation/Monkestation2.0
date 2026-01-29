/obj/machinery/lathe
	name = "industrial lathe"
	desc = "An industrial lathe, a machinery that is rendered semi-obselete with the advent of autolathes. It is however still commonly seen across the spinward sector for small-scale prototyping use."
	icon = 'monkestation/icons/obj/machines/machining_machinery.dmi'
	icon_state = "lathe"
	pixel_x = -8
	density = TRUE
	circuit = /obj/item/circuitboard/machine/industrial_lathe
	layer = BELOW_OBJ_LAYER

	///what type of machining machine this is
	var/machinery_type = MACHINING_LATHE

	///Recipe that the stuff is currently set to make
	var/datum/machining_recipe/to_make
	///is the lathe currently busy crafting something?
	var/busy = FALSE
	///is recipe craftable? (ie. does it have all the required materials?)
	var/craftable = FALSE
	///path of materials needed to craft the item (and it's quantity)
	var/list/req_materials = null
	//names of the component
	var/list/req_materials_name = null
	///materials inputted to craft the item
	var/list/materials = list()

	//Automation
	///Should the lathe automatically dispense the crafted item?
	var/auto_dispense = FALSE
	///Should the lathe automatically build the item?
	var/auto_build = FALSE
	///what tier are the parts
	var/manipulator_tier = 1
	var/speed_mod = 1

	//current user
	var/current_user_machining_skill
	///sounds for machines
	var/operating_sound = 'sound/items/welder.ogg'

/obj/machinery/lathe/examine(mob/user)
	. = ..()

	if(to_make)
		. += span_notice("The lathe is currently set to produce a [to_make.name]")

		var/list/nice_list = list()
		for(var/materials in req_materials)
			if(!ispath(materials))
				stack_trace("An item in [src]'s req_materials list is not a path!")
				continue
			if(!req_materials[materials])
				continue

			nice_list += list("[req_materials[materials]] [req_materials_name[materials]]\s")
		. += span_info(span_notice("It requires [english_list(nice_list, "no more components")]."))
	if(obj_flags & EMAGGED)
		. += span_warning("The safety protocols panel shows sparks coming out of it!")

/obj/machinery/lathe/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/lathe/emag_act(mob/user, obj/item/card/emag/emag_card)
	if (obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "safety protocols disabled")
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/lathe/proc/emag_death(mob/victim)
	var/obj/item/bodypart/chopchop = victim.get_active_hand()
	chopchop.dismember()
	victim.take_damage(105, BRUTE)
	playsound(src, 'sound/weapons/slice.ogg', 25, TRUE, -1)
	to_chat(victim, span_userdanger("The safety protocols fails and the [src] sucks your arm into the machine!"))

/obj/machinery/lathe/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Machining")
		ui.open()

/obj/machinery/lathe/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/crafting/machining),
	)

/obj/machinery/lathe/ui_data(mob/user)
	var/list/data = list()
	current_user_machining_skill = user?.mind?.get_skill_level(/datum/skill/machinist) || 1

	data["recipes"] = list()
	data["categories"] = list()
	data["busy"] = busy
	data["craftable"] = craftable
	data["auto_dispense"] = auto_dispense
	data["auto_build"] = auto_build
	data["user_machining_skill"] = current_user_machining_skill

	// Recipes
	for(var/datum/machining_recipe/recipe as anything in GLOB.machining_recipes)
		if(machinery_type != recipe.machinery_type)
			continue

		if(recipe.category)
			data["categories"] |= recipe.category

		data["recipes"] += list(build_crafting_data(recipe))

	// Atoms in said Recipes
	for(var/atom/atom as anything in GLOB.machining_recipes_atoms)
		data["atom_data"] += list(capitalize(initial(atom.name)))

	return data

/obj/machinery/lathe/proc/build_crafting_data(datum/machining_recipe/recipe)
	var/list/data = list()
	var/list/atoms = GLOB.machining_recipes_atoms

	data["ref"] = "[REF(recipe)]"
	var/atom/atom = recipe.result
	data["result"] = atoms.Find(atom)

	var/recipe_data = recipe.crafting_ui_data()
	for(var/new_data in recipe_data)
		data[new_data] = recipe_data[new_data]

	// Category
	data["category"] = recipe.category

	// Name, Description
	data["name"] = recipe.name

	// Crafting Skill Needed
	data["machining_skill_required"] = recipe.machining_skill_required

	if(ispath(recipe.result, /datum/reagent))
		var/datum/reagent/reagent = recipe.result
		if(recipe.result_amount > 1)
			data["name"] = "[data["name"]] [recipe.result_amount]u"
		data["desc"] = recipe.desc || initial(reagent.description)

	else if(ispath(recipe.result, /obj/item/pipe))
		var/obj/item/pipe/pipe_obj = recipe.result
		var/obj/pipe_real = initial(pipe_obj.pipe_type)
		data["desc"] = recipe.desc || initial(pipe_real.desc)

	else
		if(recipe.result_amount > 1)
			data["name"] = "[data["name"]] x[recipe.result_amount]"
		data["desc"] = recipe.desc || initial(atom.desc)

	// Machinery Type
	data["machinery_type"] = recipe.machinery_type

	// Ingredients / Materials
	if(recipe.reqs.len)
		data["reqs"] = list()
		for(var/req_atom in recipe.reqs)
			var/id = atoms.Find(req_atom)
			data["reqs"]["[id]"] = recipe.reqs[req_atom]

	// craftability
	if((current_user_machining_skill) >= recipe.machining_skill_required)
		data["req_required"] = TRUE
	else
		data["req_required"] = FALSE
	return data

/obj/machinery/lathe/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	switch(action)
		if("make")
			var/datum/machining_recipe/recipe_path = (locate(params["recipe"]) in (GLOB.machining_recipes))
			if(!recipe_path)
				return
			if(!recipe_path.machinery_type == machinery_type)
				return
			if(busy)
				to_chat(usr, span_warning("[src] workspace is preoccupied with another recipe!"))
				return

			if((current_user_machining_skill) < recipe_path.machining_skill_required)
				to_chat(usr, span_warning("You do not have the skill necessary to construct this upgrade! Try sharpening your skills more?"))
				return

			to_chat(usr, span_notice("[usr.name] is making [recipe_path.name] on [src]"))
			load_recipe(new recipe_path.type)

		if("produce")
			produce_recipe()

		if("abort")
			reset_machine()
			for(var/obj/item in materials)
				item.forceMove(src.loc)
				materials -= item

		if("toggle_dispense")
			if(manipulator_tier < 3)
				to_chat(usr, span_warning("You need at least a tier 3 manipulator to toggle auto dispense!"))
				return
			auto_dispense = !auto_dispense
			to_chat(usr, span_notice("Auto dispense is now [auto_dispense ? "enabled" : "disabled"]."))

		if("toggle_build")
			if(manipulator_tier < 4)
				to_chat(usr, span_warning("You need at least a tier 4 manipulator to toggle auto dispense!"))
				return
			auto_build = !auto_build
			to_chat(usr, span_notice("Auto build is now [auto_build ? "enabled" : "disabled"]."))

	update_icon() // Not applicable to all objects. TODO: revise this(?)

/obj/machinery/lathe/RefreshParts()
	. = ..()
	var/speed = 1
	var/list/speed_mod_table = list(1, 0.95, 0.90, 0.85)
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		speed *= speed_mod_table[clamp(laser.tier, 1, 4)]
	speed_mod = speed
	for(var/datum/stock_part/manipulator/manip in component_parts)
		manipulator_tier = manip.tier

/**
	* Collates the displayed names of the machine's needed materials
	*	This is done to extract the names off the path list.
* Arguments:
* * specific_parts - If true, the stock parts in the recipe should not use base name, but a specific tier
*/
/obj/machinery/lathe/proc/update_namelist(specific_parts)
	if(!req_materials)
		return

	req_materials_name = list()
	for(var/material_path in req_materials)
		if(!ispath(material_path))
			continue

		if(ispath(material_path, /obj/item/stack))
			var/obj/item/stack/stack_path = material_path
			if(initial(stack_path.singular_name))
				req_materials_name[material_path] = initial(stack_path.singular_name)
			else
				req_materials_name[material_path] = initial(stack_path.name)
		else if(ispath(material_path, /datum/stock_part))
			var/datum/stock_part/stock_part = material_path
			var/obj/item/physical_object_type = initial(stock_part.physical_object_type)

			req_materials_name[material_path] = initial(physical_object_type.name)
		else if(ispath(material_path, /obj/item/stock_parts))
			var/obj/item/stock_parts/stock_part = material_path

			if(!specific_parts && initial(stock_part.base_name))
				req_materials_name[material_path] = initial(stock_part.base_name)
			else
				req_materials_name[material_path] = initial(stock_part.name)
		else if(ispath(material_path, /obj/item))
			var/obj/item/part = material_path

			req_materials_name[material_path] = initial(part.name)
		else
			stack_trace("Invalid component part [material_path] in [type], couldn't get its name")
			req_materials_name[material_path] = "[material_path] (this is a bug)"

/obj/machinery/lathe/proc/load_recipe(datum/machining_recipe/recipe)
	to_make = recipe
	busy = TRUE
	req_materials = to_make.reqs
	update_namelist(to_make)

/obj/machinery/lathe/proc/produce_recipe(automatic = FALSE)
	if(!automatic)
		to_chat(usr, span_notice("You start following the design document on [src]..."))
		if(!do_after(usr, to_make.crafting_time * speed_mod, src))
			if (obj_flags & EMAGGED)
				emag_death(usr)
				return
			else
				to_chat(usr, span_warning("You fail to follow the design document on [src]!"))
				return
		if(!to_make)
			to_chat(usr, span_warning("You fail to follow the design document on [src]!"))
			return //no abusing abort button while in do_after
		var/gain_array = list(MACHINING_DELAY_VERY_FAST, MACHINING_DELAY_FAST, MACHINING_DELAY_NORMAL, MACHINING_DELAY_SLOW, MACHINING_DELAY_VERY_SLOW)
		usr?.mind?.adjust_experience(/datum/skill/machinist, gain_array[clamp(to_make.machining_skill_required, 1, 5)])
		spawn_item()
		return

	audible_message(span_notice("You look as manipulators on [src] start working on the design document..."))
	addtimer(CALLBACK(src, PROC_REF(spawn_item)), to_make.crafting_time * speed_mod)

/obj/machinery/lathe/proc/spawn_item()
	if(!to_make)
		visible_message(span_warning("[src] manipulators fizzles out!"))
		return //no abusing by using auto-dispense

	for(var/amount in 1 to to_make.result_amount)
		new to_make.result(src.loc)
	to_chat(usr, span_notice("You produce [to_make.name] on [src]."))

	var/to_make_path
	if(auto_build)
		to_make_path = to_make.type
	reset_machine()
	for(var/obj/item in materials)
		materials -= item
		qdel(item)

	if(to_make_path)
		load_recipe(new to_make_path)
	playsound(src, operating_sound, 100, TRUE)

/obj/machinery/lathe/item_interaction(mob/living/user, obj/item/interacted_item, list/modifiers)
	for(var/stock_part_base in req_materials)
		if (req_materials[stock_part_base] == 0)
			continue

		var/stock_part_path

		if (ispath(stock_part_base, /obj/item))
			stock_part_path = stock_part_base
		else if (ispath(stock_part_base, /datum/stock_part))
			var/datum/stock_part/stock_part_datum_type = stock_part_base
			stock_part_path = initial(stock_part_datum_type.physical_object_type)
		else
			stack_trace("Bad stock part in req_materials: [stock_part_base]")
			continue

		if (!istype(interacted_item, stock_part_path))
			continue

		if(isstack(interacted_item))
			var/obj/item/stack/stack_mat = interacted_item
			var/used_amt = min(round(stack_mat.get_amount()), req_materials[stock_part_path])
			if(used_amt && stack_mat.use(used_amt))
				req_materials[stock_part_path] -= used_amt
				var/obj/item/stack/stack_in_machine = new stack_mat.type(src)
				stack_in_machine.amount = used_amt
				materials += stack_in_machine
				to_chat(user, span_notice("You add [interacted_item] to [src]."))
				check_done(user)
			return ITEM_INTERACT_SUCCESS

		// We might end up qdel'ing the part if it's a stock part datum.
		// In practice, this doesn't have side effects to the name,
		// but academically we should not be using an object after it's deleted.
		var/part_name = "[interacted_item]"

		if(ispath(stock_part_base, /datum/stock_part))
			// We can't just reuse stock_part_path here or its singleton,
			// or else putting in a tier 2 part will deconstruct to a tier 1 part.
			var/stock_part_datum = GLOB.stock_part_datums_per_object[interacted_item.type]
			if (isnull(stock_part_datum))
				stack_trace("[interacted_item.type] does not have an associated stock part datum!")
				continue

			materials += stock_part_datum

			// We regenerate the stock parts on deconstruct.
			// This technically means we lose unique qualities of the stock part, but
			// it's worth it for how dramatically this simplifies the code.
			// The only place I can see it affecting anything is like...RPG qualities. :P
			qdel(interacted_item)
		else if(user.transferItemToLoc(interacted_item, src))
			materials += interacted_item
		else
			break

		to_chat(user, span_notice("You add [part_name] to [src]."))
		req_materials[stock_part_base]--
		check_done(user)
		return ITEM_INTERACT_SUCCESS

	to_chat(user, span_warning("You cannot add that to the machine!"))
	return . = ..()

/obj/machinery/lathe/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/lathe/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

//check if lathe materials requirements are met
/obj/machinery/lathe/proc/check_done(mob/user)
	var/is_not_enough = FALSE
	for(var/req in req_materials)
		if(req_materials[req] > 0)
			is_not_enough = TRUE
	if(!is_not_enough)
		craftable = TRUE
		to_chat(user, span_notice("You have added all the required materials to [src]."))
		if(auto_dispense)
			produce_recipe(TRUE)

// Modular machining machineries, based off the lathe
/obj/machinery/lathe/workstation
	name = "workstation"
	desc = "A workstation used to gather and assemble parts."
	icon_state = "workstation"
	machinery_type = MACHINING_WORKSTATION
	operating_sound = 'sound/items/screwdriver.ogg'
	circuit = /obj/item/circuitboard/machine/industrial_lathe/workstation

/obj/machinery/lathe/furnace
	name = "furnace"
	desc = "A furnace used to melt down metal and other materials."
	icon_state = "furnace"
	machinery_type = MACHINING_FURNACE
	circuit = /obj/item/circuitboard/machine/industrial_lathe/furnace

/obj/machinery/lathe/tablesaw
	name = "tablesaw"
	desc = "A tablesaw used to cut wood and other materials."
	icon_state = "tablesaw"
	machinery_type = MACHINING_TABLESAW
	operating_sound = 'sound/weapons/chainsawhit.ogg'
	circuit = /obj/item/circuitboard/machine/industrial_lathe/tablesaw

/obj/machinery/lathe/drophammer
	name = "drophammer"
	desc = "A drophammer used to forge metal and other materials."
	icon_state = "drophammer"
	machinery_type = MACHINING_DROPHAMMER
	operating_sound = 'sound/effects/picaxe3.ogg'
	circuit = /obj/item/circuitboard/machine/industrial_lathe/drophammer

/obj/machinery/lathe/tailor
	name = "tailor"
	desc = "A tailor used to sew and craft clothing and other fabric items."
	icon_state = "tailorstation"
	machinery_type = MACHINING_TAILOR
	operating_sound = 'sound/items/screwdriver.ogg'
	circuit = /obj/item/circuitboard/machine/industrial_lathe/tailor

/obj/machinery/lathe/drillpress
	name = "drill press"
	desc = "A drill press used to drill holes in metal and other materials."
	icon_state = "drillpress"
	machinery_type = MACHINING_DRILLPRESS
	operating_sound = 'sound/weapons/drill.ogg'
	circuit = /obj/item/circuitboard/machine/industrial_lathe/drillpress


/*
* Resets the lathe to a clean state
*/
/obj/machinery/lathe/proc/reset_machine()
	busy = FALSE
	qdel(to_make)
	to_make = null
	req_materials = null
	req_materials_name = null
	craftable = FALSE

//circuits
/obj/item/circuitboard/machine/industrial_lathe
	name = "Industrial Lathe"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/lathe
	req_components = list(
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/manipulator = 1,
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stack/cable_coil = 15,
		)

/obj/item/circuitboard/machine/industrial_lathe/workstation
	name = "Workstation"
	build_path = /obj/machinery/lathe/workstation

/obj/item/circuitboard/machine/industrial_lathe/furnace
	name = "Furnace"
	build_path = /obj/machinery/lathe/furnace

/obj/item/circuitboard/machine/industrial_lathe/tablesaw
	name = "Tablesaw"
	build_path = /obj/machinery/lathe/tablesaw

/obj/item/circuitboard/machine/industrial_lathe/drophammer
	name = "Drophammer"
	build_path = /obj/machinery/lathe/drophammer

/obj/item/circuitboard/machine/industrial_lathe/tailor
	name = "Tailor"
	build_path = /obj/machinery/lathe/tailor

/obj/item/circuitboard/machine/industrial_lathe/drillpress
	name = "Drill Press"
	build_path = /obj/machinery/lathe/drillpress

//machinery design
/datum/design/board/industrial_lathe
	name = "Industrial Lathe Board"
	desc = "The circuit board for an industrial lathe."
	id = "industrial_lathe"
	build_path = /obj/item/circuitboard/machine/industrial_lathe
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/industrial_lathe_workstation
	name = "Workstation Board"
	desc = "The circuit board for a workstation."
	id = "industrial_lathe_workstation"
	build_path = /obj/item/circuitboard/machine/industrial_lathe/workstation
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/industrial_lathe_furnace
	name = "Furnace Board"
	desc = "The circuit board for a furnace."
	id = "industrial_lathe_furnace"
	build_path = /obj/item/circuitboard/machine/industrial_lathe/furnace
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/industrial_lathe_tablesaw
	name = "Tablesaw Board"
	desc = "The circuit board for a tablesaw."
	id = "industrial_lathe_tablesaw"
	build_path = /obj/item/circuitboard/machine/industrial_lathe/tablesaw
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/industrial_lathe_drophammer
	name = "Drophammer Board"
	desc = "The circuit board for a drophammer."
	id = "industrial_lathe_drophammer"
	build_path = /obj/item/circuitboard/machine/industrial_lathe/drophammer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/industrial_lathe_tailor
	name = "Tailor Board"
	desc = "The circuit board for a tailor."
	id = "industrial_lathe_tailor"
	build_path = /obj/item/circuitboard/machine/industrial_lathe/tailor
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/industrial_lathe_drillpress
	name = "Drill Press Board"
	desc = "The circuit board for a drill press."
	id = "industrial_lathe_drillpress"
	build_path = /obj/item/circuitboard/machine/industrial_lathe/drillpress
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
