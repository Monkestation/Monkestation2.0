/datum/action/cooldown/borer/upgrade_chemical
	name = "Learn New Chemical"
	button_icon_state = "bloodlevel"
	chemical_evo_points = 1
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Allows you to learn various unlocked chemicals\n\
	To expand the chemical choice you need to use the evolution ability\n\
	"
	/// What chemicals the borer can learn
	var/list/learnable_reagents = list(
		/datum/reagent/drug/methamphetamine/borer_version,

		/datum/reagent/impurity/libitoil,

		/datum/reagent/lithium,

		/datum/reagent/medicine/antipathogenic/spaceacillin,

		/datum/reagent/medicine/c2/convermol,
		/datum/reagent/medicine/c2/lenturi,
		/datum/reagent/medicine/c2/libital,
		/datum/reagent/medicine/c2/multiver,
		/datum/reagent/medicine/c2/seiver,

		/datum/reagent/medicine/diphenhydramine,
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/haloperidol,
		/datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/mannitol,
		/datum/reagent/medicine/painkiller/morphine,
		/datum/reagent/medicine/mutadone,
		/datum/reagent/medicine/oculine,
		/datum/reagent/medicine/potass_iodide,
		/datum/reagent/medicine/salglu_solution,

		/datum/reagent/toxin/formaldehyde,
		/datum/reagent/toxin/heparin,
		/datum/reagent/toxin/mindbreaker,
	)

/datum/action/cooldown/borer/upgrade_chemical/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner

	if(!length(learnable_reagents))
		owner.balloon_alert(owner, "all chemicals learned")
		return

	// Give the chemicals we can learn all proper names instead of datum/chemical/whatever, and show that to the user
	var/named_chemicals = list()
	for(var/datum/reagent/learnable_chemical as anything in learnable_reagents)
		named_chemicals += initial(learnable_chemical.name)

	var/reagent_choice = tgui_input_list(
		cortical_owner,
		"Choose a chemical to learn.",
		"Chemical Selection",
		named_chemicals,
	)
	if(!reagent_choice)
		owner.balloon_alert(owner, "no chemical chosen")
		return

	// We only know the chosen chemicals name at this point, so we gotta check what chemical do we actually give them
	var/datum/reagent/learned_reagent
	for(var/datum/reagent/chemical as anything in learnable_reagents)
		if(initial(chemical.name) == reagent_choice)
			learned_reagent = chemical

	var/datum/action/cooldown/borer/inject_chemical/action = locate() in cortical_owner.actions
	if(!action)
		return

	cortical_owner.chemical_evolution -= chemical_evo_points
	action.known_chemicals += learned_reagent
	learnable_reagents -= learned_reagent

	owner.balloon_alert(owner, "[reagent_choice] learned")
	if(!HAS_TRAIT(cortical_owner.human_host, TRAIT_AGEUSIA))
		to_chat(cortical_owner.human_host, span_notice("You get a strange aftertaste of [initial(learned_reagent.taste_description)]!"))

	cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * cortical_owner.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)

	StartCooldown()

/**
 * Lets borers learn chemicals that the host they reside in currently possess unless its in the "blacklisted_chemicals" list
 * This ability is required for one of the borer's objectives
 */
/datum/action/cooldown/borer/learn_bloodchemical
	name = "Learn Chemical from Blood"
	button_icon_state = "bloodchem"
	chemical_evo_points = 5
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Allows you to learn chemicals from blood at a much steeper price\n\
	Does not work on certain chemicals whose mollecular complexity is too high\n\
	"

/datum/action/cooldown/borer/learn_bloodchemical/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner

	if(length(cortical_owner.human_host.reagents.reagent_list) <= 0)
		owner.balloon_alert(owner, "no reagents in host")
		return

	// Give the chemicals we can learn all proper names instead of datum/chemical/whatever, and show that to the user
	var/named_chemicals = list()
	for(var/datum/reagent/learnable_chemical as anything in cortical_owner.human_host.reagents.reagent_list)
		named_chemicals += learnable_chemical.name

	var/reagent_choice = tgui_input_list(
		cortical_owner,
		"Choose a chemical to learn.",
		"Chemical Selection",
		named_chemicals,
	)
	if(!reagent_choice)
		owner.balloon_alert(owner, "no chemical chosen")
		return

	// We only know the chosen chemicals name at this point, so we gotta check what chemical do we actually give them
	var/datum/reagent/learned_reagent
	for(var/datum/reagent/reagent as anything in cortical_owner.human_host.reagents.reagent_list)
		if(reagent.name == reagent_choice)
			learned_reagent = reagent

	var/datum/action/cooldown/borer/inject_chemical/action = locate() in cortical_owner.actions
	if(!action)
		to_chat(owner, span_warning("What use is it wihout a chemical production gland?"))
		return

	if(locate(learned_reagent) in action.known_chemicals)
		owner.balloon_alert(owner, "chemical already known")
		return

	if(!(learned_reagent.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
		owner.balloon_alert(owner, "cannot learn [reagent_choice]")
		return

	cortical_owner.chemical_evolution -= chemical_evo_points
	action.known_chemicals += learned_reagent.type
	cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * cortical_owner.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)
	if(!HAS_TRAIT(cortical_owner.human_host, TRAIT_AGEUSIA))
		to_chat(cortical_owner.human_host, span_notice("You get a strange aftertaste of [learned_reagent.taste_description]!"))

	owner.balloon_alert(owner, "[reagent_choice] learned")
	var/datum/antagonist/cortical_borer/antag = owner.mind?.has_antag_datum(/datum/antagonist/cortical_borer)
	if(antag)
		var/datum/objective/borer/learn_chemicals/objective = locate() in antag.objectives
		if(objective)
			objective.borers[owner.tag] += 1
			objective.check_completion()

	StartCooldown()
