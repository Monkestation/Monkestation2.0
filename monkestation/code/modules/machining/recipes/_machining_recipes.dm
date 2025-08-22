//init functions
/proc/init_machining_recipes()
	. = list()
	for(var/type in subtypesof(/datum/machining_recipe))
		. += new type

/proc/init_machining_recipes_atoms()
	. = list()
	for(var/datum/machining_recipe/recipe as anything in GLOB.machining_recipes)
		// Result
		. |= recipe.result
		// Ingredients
		for(var/atom/req_atom as anything in recipe.reqs)
			. |= req_atom

///Representative icons for the contents of each crafting recipe
/datum/asset/spritesheet_batched/crafting/machining
	name = "machining"

/datum/asset/spritesheet_batched/crafting/machining/create_spritesheets()
	var/id = 1
	for(var/atom in GLOB.machining_recipes_atoms)
		add_atom_icon(atom, id++)

//base object for all machining recipes
/datum/machining_recipe
	//in-game display name. Optional, if not set uses result name
	var/name
	///description displayed in game. Optional, if not set uses result desc
	var/desc
	///type paths of items consumed associated with how many are needed
	var/list/reqs = list()
	///type path of item resulting from this craft
	var/result
	///where it shows up in the crafting UI
	var/category = TAB_GENERAL_PARTS
	///What machining machine it belongs to
	var/machinery_type = MACHINING_LATHE
	///how much time it takes to craft
	var/crafting_time = MACHINING_DELAY_NORMAL
	///how much item to pop out
	var/result_amount = 1
	///determines if the recipe requires specific levels of parts. (ie specifically a femto menipulator vs generic manipulator)
	var/specific_parts = FALSE
	///what tier of skill required to craft this recipe
	var/machining_skill_required = 1

/datum/machining_recipe/New()
	if(!result)
		return
	var/atom/atom_result = result
	if(!name && result)
		name = capitalize("[initial(atom_result.name)]")
	if(!desc && result)
		desc = initial(atom_result.desc)


///Additional UI data to be passed to the crafting UI for this recipe
/datum/machining_recipe/proc/crafting_ui_data()
	return list()
