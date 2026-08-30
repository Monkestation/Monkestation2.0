/datum/borer_evolution
	/// Name of the evolution
	var/name = ""
	/// Description of the evolution
	var/desc = ""
	/// Cost to get the evolution
	var/evo_cost = 2 // T5 cost 3 points instead of 2
	/// Text to show the borer when they evolve
	var/gain_text = "Allan please add details"
	/// What evolution genome this is
	var/evo_type = BORER_EVOLUTION_GENERAL
	/// If TRUE, this is an evolution that locks out other `locks_paths` evolutions
	var/locks_paths = FALSE
	/// What numerical tier is this? (Doesn't affect anything mechanically)
	var/tier = 0

	/// What evolutions this one unlocks
	var/list/unlocked_evolutions = list()
	/// What action does this evolution unlock
	var/added_action = null

/// What happens when a borer gets this evolution
/datum/borer_evolution/proc/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	SHOULD_CALL_PARENT(TRUE)
	to_chat(cortical_owner, span_notice("<span class='italics'>[gain_text]</span>"))
	if(added_action)
		var/datum/action/cooldown/borer/new_action = new added_action(cortical_owner)
		new_action.Grant(cortical_owner)

/// Can a borer learn this evolution?
/datum/borer_evolution/proc/get_evolution_paths(mob/living/basic/cortical_borer/borer)
	return unlocked_evolutions

/datum/borer_evolution/base
	name = "The Beginning"
	desc = "The start of a great age."
	gain_text = "The worms, which we came to call \"Cortical Borers\", are fascinating creatures."
	evo_cost = 0
	evo_type = BORER_EVOLUTION_START
	tier = 0
	unlocked_evolutions = list(
		/datum/borer_evolution/upgrade_injection,
		/datum/borer_evolution/symbiote/willing_host,
		/datum/borer_evolution/hivelord/produce_offspring,
		/datum/borer_evolution/diveworm/health_per_level,
	)

/datum/borer_evolution/base/get_evolution_paths(mob/living/basic/cortical_borer/borer)
	if(HAS_TRAIT(borer, TRAIT_NEUTERED))
		return list(
			/datum/borer_evolution/upgrade_injection,
			/datum/borer_evolution/symbiote/chem_per_level,
			/datum/borer_evolution/hivelord/dissection,
			/datum/borer_evolution/diveworm/health_per_level,
		)
	return unlocked_evolutions

/datum/borer_evolution/reagent_giver
	var/list/reagents = list()

/datum/borer_evolution/reagent_giver/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	var/datum/action/cooldown/borer/upgrade_chemical/action = locate() in cortical_owner.actions
	if(!action)
		return

	var/list/reagents_copy = reagents.Copy()
	var/datum/action/cooldown/borer/inject_chemical/inject_action = locate() in cortical_owner.actions
	if(inject_action)
		for(var/reagent in reagents_copy)
			if(inject_action.known_chemicals.Find(reagent))
				reagents_copy -= reagent

	action.learnable_reagents |= reagents_copy
	action.build_all_button_icons(UPDATE_BUTTON_STATUS)
