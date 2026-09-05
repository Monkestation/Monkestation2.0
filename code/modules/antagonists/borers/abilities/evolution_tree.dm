/datum/action/cooldown/borer/evolution_tree
	name = "Open Evolution Tree"
	button_icon_state = "newability"
	ability_explanation = "\
	Allows you to evolve essential to survive abilities.\n\
	Beware, as evolving a tier 3 path will lock you out of all other tier 3 paths.\n\
	- The Diveworm path focuses on killing hosts, and making eggs in their corpses.\n\
	- The Hivelord path focuses on making lots of eggs.\n\
	- The Symbiote path focuses on helping their host, for mutual benefit.\n\
	"
	/// Assoc list of [evolution.name = evolution ref], ALL NAMES MUST BE UNIQUE ELSE EVERYTHING BREAKS
	var/static/alist/initialized_evolutions = null
	/// Evolutions we have completed
	var/list/completed_evolutions = list()
	/// Evolutions that are currently available to us
	var/list/available_evolutions = list()
	/// The path we chose, if any
	var/chosen_path = null

/datum/action/cooldown/borer/evolution_tree/New(Target, original)
	. = ..()
	if(isnull(initialized_evolutions))
		initialized_evolutions = alist()
		initialized_evolutions[/datum/borer_evolution/base::name] = new /datum/borer_evolution/base

#ifdef UNIT_TESTS
		var/list/exclusion_list = list(
			/datum/borer_evolution/base,
			/datum/borer_evolution/reagent_giver,
			/datum/borer_evolution/diveworm,
			/datum/borer_evolution/hivelord,
			/datum/borer_evolution/symbiote,
		)
		for(var/datum/borer_evolution/evo_path as anything in subtypesof(/datum/borer_evolution) - exclusion_list)
			if(initialized_evolutions[initial(evo_path.name)])
				var/datum/borer_evolution/bad_ref = initialized_evolutions[initial(evo_path.name)]
				stack_trace("All borer evolution names must be unique! ([bad_ref.type]) and ([evo_path]) conflicted.")
				continue
			initialized_evolutions[initial(evo_path.name)] = new evo_path
#endif

/datum/action/cooldown/borer/evolution_tree/Destroy(force)
	completed_evolutions = null
	available_evolutions = null
	return ..()

/datum/action/cooldown/borer/evolution_tree/Grant(mob/grant_to)
	. = ..()
	if(grant_to && length(completed_evolutions) == 0)
		evolve(initialized_evolutions[/datum/borer_evolution/base::name])

/datum/action/cooldown/borer/evolution_tree/proc/evolve(datum/borer_evolution/evolution)
	available_evolutions -= evolution
	completed_evolutions += evolution
	evolution.on_evolve(owner)
	if(evolution.locks_paths)
		chosen_path = evolution.evo_type
		for(var/datum/borer_evolution/lockable_evolution as anything in available_evolutions)
			if(lockable_evolution.locks_paths)
				available_evolutions -= lockable_evolution

	var/list/evolve_paths = evolution.get_evolution_paths(owner)
	for(var/datum/borer_evolution/new_evolution as anything in evolve_paths)
		if(!initialized_evolutions[initial(new_evolution.name)])
			initialized_evolutions[initial(new_evolution.name)] = new new_evolution()
		new_evolution = initialized_evolutions[initial(new_evolution.name)]
		if(!new_evolution.locks_paths || isnull(chosen_path))
			available_evolutions += new_evolution

/datum/action/cooldown/borer/evolution_tree/Activate(mob/living/basic/cortical_borer/user)
	ui_interact(user)
	return ..()

/datum/action/cooldown/borer/evolution_tree/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorerEvolution", name)
		ui.open()

/datum/action/cooldown/borer/evolution_tree/ui_data(mob/user)
	var/list/data = list()

	var/static/list/path_to_color = list(
		BORER_EVOLUTION_DIVEWORM = "red",
		BORER_EVOLUTION_HIVELORD = "purple",
		BORER_EVOLUTION_SYMBIOTE = "green",
		BORER_EVOLUTION_GENERAL = "label",
	)

	var/mob/living/basic/cortical_borer/cortical_owner = owner

	data["evolution_points"] = cortical_owner.stat_evolution

	data["learnableEvolution"] = list()
	for(var/datum/borer_evolution/evolution as anything in available_evolutions)
		var/list/evo_data = list()
		evo_data["name"] = evolution.name
		evo_data["desc"] = evolution.desc
		evo_data["gainFlavor"] = evolution.gain_text
		evo_data["cost"] = evolution.evo_cost
		evo_data["disabled"] = evolution.evo_cost > cortical_owner.stat_evolution
		evo_data["evoPath"] = evolution.evo_type
		evo_data["color"] = path_to_color[evolution.evo_type] || "grey"
		evo_data["tier"] = evolution.tier
		evo_data["exclusive"] = evolution.locks_paths
		data["learnableEvolution"] += list(evo_data)

	data["learnedEvolution"] = list()
	for(var/datum/borer_evolution/evolution as anything in completed_evolutions)
		var/list/evo_data = list()
		evo_data["name"] = evolution.name
		evo_data["desc"] = evolution.desc
		evo_data["gainFlavor"] = evolution.gain_text
		evo_data["cost"] = evolution.evo_cost
		evo_data["evoPath"] = evolution.evo_type
		evo_data["color"] = path_to_color[evolution.evo_type] || "grey"
		evo_data["tier"] = evolution.tier

		data["learnedEvolution"] += list(evo_data)
	return data

/datum/action/cooldown/borer/evolution_tree/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("evolve")
			var/mob/living/basic/cortical_borer/borer = owner
			if(!istype(borer))
				return
			var/datum/borer_evolution/evolution = initialized_evolutions[params["name"]]
			if(isnull(evolution) || !(evolution in available_evolutions) || evolution.evo_cost > borer.stat_evolution)
				return

			evolve(evolution)
			borer.stat_evolution -= evolution.evo_cost
			return TRUE

/datum/action/cooldown/borer/evolution_tree/ui_state(mob/user)
	return GLOB.always_state
