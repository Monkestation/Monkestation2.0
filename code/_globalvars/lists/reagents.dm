/// List of all /datum/chemical_reaction datums indexed by their typepath. Use this for general lookup stuff.
GLOBAL_LIST(chemical_reactions_list)
/// List of all /datum/chemical_reaction datums. Used during chemical reactions. Indexed by REACTANT types.
GLOBAL_LIST(chemical_reactions_list_reactant_index)
/// List of all /datum/chemical_reaction datums. Used for the reaction lookup UI. Indexed by PRODUCT type.
GLOBAL_LIST(chemical_reactions_list_product_index)
/// List of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff.
GLOBAL_LIST_INIT(chemical_reagents_list, init_chemical_reagent_list())
/// Names of reagents used by plumbing UI.
GLOBAL_LIST_INIT(chemical_name_list, init_chemical_name_list())
/// List of all reactions with their associated product and result ids. Used for reaction lookups.
GLOBAL_LIST(chemical_reactions_results_lookup_list)
/// List of all reagents that are parent types used to define a bunch of children - but aren't used themselves as anything.
GLOBAL_LIST(fake_reagent_blacklist)
/// Map of reagent names to its datum path.
GLOBAL_LIST_INIT(name2reagent, build_name2reagentlist())

/// Initialises all /datum/reagent into a list indexed by reagent id.
/proc/init_chemical_reagent_list()
	var/list/reagent_list = list()
	for(var/datum/reagent/path as anything in subtypesof(/datum/reagent))
		if(path in GLOB.fake_reagent_blacklist)
			continue
		var/datum/reagent/target_object = new path()
		target_object.mass = rand(10, 800)
		reagent_list[path] = target_object
	return reagent_list

/// Creates an list which is indexed by reagent name. Used by plumbing reaction chamber and chemical filter UI.
/proc/init_chemical_name_list()
	var/list/name_list = list()
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[X]
		name_list += reagent.name
	return sort_list(name_list)

/proc/build_chemical_reactions_lists()
	// Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// 	It is filtered into multiple lists within a list.
	// 	For example:
	// 	chemical_reactions_list_reactant_index[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma.
	// For chemical reaction list product index - indexes reactions based off the product reagent type - see get_recipe_from_reagent_product() in helpers.
	// For chemical reactions list lookup list - creates a bit list of info passed to the UI. This is saved to reduce lag from new windows opening, since it's a lot of data.

	// Prevent these reactions from appearing in lookup tables (UI code).
	var/list/blacklist = (/datum/chemical_reaction/randomized)

	if(GLOB.chemical_reactions_list_reactant_index)
		return

	// Randomized need to go last since they need to check against conflicts with normal recipes.
	var/paths = subtypesof(/datum/chemical_reaction) - typesof(/datum/chemical_reaction/randomized) + subtypesof(/datum/chemical_reaction/randomized)
	GLOB.chemical_reactions_list = list() // typepath to reaction list.
	GLOB.chemical_reactions_list_reactant_index = list() // reagents to reaction list.
	GLOB.chemical_reactions_results_lookup_list = list() // UI glob.
	GLOB.chemical_reactions_list_product_index = list() // product to reaction list.

	for(var/path in paths)
		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()
		var/list/product_ids = list()
		var/list/reagents = list()
		var/list/product_names = list()
		var/bitflags = D.reaction_tags

		// Skip impossible reactions.
		if(!D.required_reagents || !D.required_reagents.len)
			continue

		GLOB.chemical_reactions_list[path] = D

		for(var/reaction in D.required_reagents)
			reaction_ids += reaction
			var/datum/reagent/reagent = find_reagent_object_from_type(reaction)
			if(!istype(reagent))
				stack_trace("Invalid reagent found in [D] required_reagents: [reaction]")
				continue
			reagents += list(list("name" = reagent.name, "id" = reagent.type))

		for(var/product in D.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(product)
			if(!istype(reagent))
				stack_trace("Invalid reagent found in [D] results: [product]")
				continue
			product_names += reagent.name
			product_ids += product

		var/product_name
		if(!length(product_names))
			var/list/names = splittext("[D.type]", "/")
			product_name = names[names.len]
		else
			product_name = product_names[1]

		// Create filters based on each reagent id in the required reagents list - this is specifically for finding reactions from product(reagent) ids/typepaths.
		for(var/id in product_ids)
			if(is_type_in_list(D.type, blacklist))
				continue
			if(!GLOB.chemical_reactions_list_product_index[id])
				GLOB.chemical_reactions_list_product_index[id] = list()
			GLOB.chemical_reactions_list_product_index[id] += D

		// Master list of ALL reactions that is used in the UI lookup table. This is expensive to make. Since we don't want to lag the server by creating it on UI request, it is cached to send to UIs instantly.
		if(!(is_type_in_list(D.type, blacklist)))
			GLOB.chemical_reactions_results_lookup_list += list(list("name" = product_name, "id" = D.type, "bitflags" = bitflags, "reactants" = reagents))

		// Create filters based on each reagent id in the required reagents list - this is used to speed up handle_reactions().
		for(var/id in reaction_ids)
			if(!GLOB.chemical_reactions_list_reactant_index[id])
				GLOB.chemical_reactions_list_reactant_index[id] = list()
			GLOB.chemical_reactions_list_reactant_index[id] += D
			break // Don't bother adding ourselves to other reagent ids. It is redundant.

/proc/build_name2reagentlist()
	. = list()

	// Build map with keys stored separately.
	var/list/name_to_reagent = list()
	var/list/only_names = list()
	for (var/datum/reagent/reagent as anything in GLOB.chemical_reagents_list)
		var/name = initial(reagent.name)
		if (length(name))
			name_to_reagent[name] = reagent
			only_names += name

	// Sort keys.
	only_names = sort_list(only_names)

	// Build map with sorted keys.
	for(var/name in only_names)
		.[name] = name_to_reagent[name]
