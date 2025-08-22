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
	///what tier of machinery required to craft this recipe
	var/upgrade_tier_required = 1
	///what tier of skill required to craft this recipe
	var/machining_skill_required = 0

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

//upgrade tiers
/datum/machining_recipe/upgrade_tier_1
	name = "Upgrade Tier 1 parts"
	desc = "Crappy rusted and warped machine parts, better then the half decayed parts NT supplied. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/stack/sheet/iron = 10,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t1
	upgrade_tier_required = 1
	machining_skill_required = 1

/datum/machining_recipe/upgrade_tier_2
	name = "Upgrade Tier 2 parts"
	desc = "Dull but workable machine parts, much better then what you could make before. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 10,
		/obj/item/stack/machining_intermediates/steel = 10,
		/obj/item/machining_intermediates/moltenplastic = 4,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t2
	upgrade_tier_required = 2
	machining_skill_required = 2

/datum/machining_recipe/upgrade_tier_3
	name = "Upgrade Tier 3 parts"
	desc = "Shiny and strong machine parts. Able to work with great efficency. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 10,
		/obj/item/stack/machining_intermediates/hardsteel = 5,
		/obj/item/machining_intermediates/universalcircuit = 4,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t3
	upgrade_tier_required = 3
	machining_skill_required = 3

/datum/machining_recipe/upgrade_tier_4
	name = "Upgrade Tier 4 parts"
	desc = "Perfect parts, able to work flawlessly with anything its designed for, which is your machines. Allows for more designs to be produced."
	machinery_type = MACHINING_WORKSTATION
	category = TAB_ASSEMBLY_PARTS
	reqs = list(
		/obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/stack/machining_intermediates/hardsteel = 5,
		/obj/item/machining_intermediates/universalcircuit = 6,
	)
	result = /obj/item/machining_intermediates/upgrade/machineparts_t4
	upgrade_tier_required = 4
	machining_skill_required = 4
