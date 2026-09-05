/datum/borer_evolution/hivelord
	evo_type = BORER_EVOLUTION_HIVELORD

// T1
/datum/borer_evolution/hivelord/produce_offspring
	name = "Produce Offspring"
	desc = "Produce an egg, which your host will vomit up."
	gain_text = "The way that a Cortical Borer produces an egg is a strange one. So far, we have not seen how it produces one, or it doing so outside a host."
	tier = 1
	evo_cost = 1
	unlocked_evolutions = list(/datum/borer_evolution/hivelord/blood_chemical)
	added_action = /datum/action/cooldown/borer/produce_offspring

/datum/borer_evolution/hivelord/dissection
	name = "Dissect Corpse"
	desc = "Gain the ability to probes a corspe's brain to further the rate you grow."
	gain_text = "After applying extreme radiation exposure to a sample of the eggs, that generation's bed of worms never produced eggs. However, the sanitation teams observed these same worms festering around a dead host that was to be removed."
	tier = 1
	evo_cost = 1
	unlocked_evolutions = list(/datum/borer_evolution/hivelord/blood_chemical)
	added_action = /datum/action/cooldown/borer/dissection

/datum/borer_evolution/hivelord/dissection/on_evolve(mob/living/basic/cortical_borer/borer)
	. = ..()
	if(isnull(borer.mind))
		return

	var/datum/antagonist/cortical_borer/antag = borer.mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(isnull(antag))
		return

	var/datum/objective/borer/dissect_bodies/objective = new()
	objective.owner = borer.mind
	objective.update_explanation_text()
	antag.objectives += objective
	antag.update_static_data_for_all_viewers()

// T2
/datum/borer_evolution/hivelord/blood_chemical
	name = "Learn Blood Chemical"
	desc = "Learn a synthesizable chemical from the blood of your host."
	gain_text = "As we were dissecting a former host monkey's fecal matter, I noticed a high concentration of banana matter, despite us not feeding them any for the past week."
	tier = 2
	unlocked_evolutions = list(/datum/borer_evolution/hivelord/movespeed)
	added_action = /datum/action/cooldown/borer/learn_bloodchemical

// T3
/datum/borer_evolution/hivelord/movespeed
	name = "Increased Energy"
	desc = "Boost your speed by a large amount."
	gain_text = "And as I watched, the Cortical Borer was able to complete the course in just over half the time it had last week."
	locks_paths = TRUE
	tier = 3
	unlocked_evolutions = list(/datum/borer_evolution/hivelord/stealth_mode)

/datum/borer_evolution/hivelord/movespeed/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.add_movespeed_modifier(/datum/movespeed_modifier/borer_speed)
	cortical_owner.upgrade_flags |= BORER_ENERGIC
	if(!(cortical_owner.upgrade_flags & BORER_HIDING))
		cortical_owner.add_movespeed_modifier(/datum/movespeed_modifier/borer_speed_bonus) //bonus movespeed if not hiding

// T4
/datum/borer_evolution/hivelord/stealth_mode
	name = "Stealth Mode"
	desc = "While in stealth mode, your presence is much less noticable in hosts, but you do not gain passive benefits."
	gain_text = "As I was writing my report one day, I noticed that one of the worms had slipped out of its cage and into a monkey without so much as a sound. Fascinating how they seem to know the importance of sound."
	tier = 4
	unlocked_evolutions = list(/datum/borer_evolution/hivelord/produce_offspring_alone)
	added_action = /datum/action/cooldown/borer/stealth_mode

/datum/borer_evolution/hivelord/stealth_mode/get_evolution_paths(mob/living/basic/cortical_borer/borer)
	if(HAS_TRAIT(borer, TRAIT_NEUTERED))
		return list(
			/datum/borer_evolution/sugar_immunity,
			/datum/borer_evolution/synthetic_borer,
			/datum/borer_evolution/reagent_giver/synthetic_chems_positive,
			/datum/borer_evolution/reagent_giver/synthetic_chems_negative,
		)
	return unlocked_evolutions

// T5
/datum/borer_evolution/hivelord/produce_offspring_alone
	name = "Produce Offspring II"
	desc = "Allows you to produce eggs outside a host, in exchange for health and chemicals."
	gain_text = "One of the worms seems to have taken an... Alpha position in the hive, producing more eggs than the others. Most worryingly, eggs have shown up without them having a host, but I haven't *seen* them lay any..."
	evo_cost = 3
	tier = 5
	unlocked_evolutions = list(
		/datum/borer_evolution/sugar_immunity,
		/datum/borer_evolution/synthetic_borer,
		/datum/borer_evolution/reagent_giver/synthetic_chems_positive,
		/datum/borer_evolution/reagent_giver/synthetic_chems_negative,
	)

/datum/borer_evolution/hivelord/produce_offspring_alone/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	var/datum/action/cooldown/borer/produce_offspring/action = locate() in cortical_owner.actions
	if(action)
		action.requires_host = FALSE
		action.build_all_button_icons(UPDATE_BUTTON_STATUS)
		action.UnregisterSignal(action.owner, COMSIG_HOST_CHANGED)
