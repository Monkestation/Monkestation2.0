#define CHEM_COST 1
#define BLOOD_CHEM_COST (CHEM_COST * 5)

/datum/action/cooldown/borer/upgrade_chemical
	name = "Learn New Chemical (1 chemical point)"
	button_icon_state = "bloodlevel"
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

/datum/action/cooldown/borer/upgrade_chemical/IsAvailable(feedback)
	. = ..()
	if(!.)
		return

	if(!length(learnable_reagents))
		if(feedback)
			owner.balloon_alert(owner, "all chemicals learned")
		return FALSE

/datum/action/cooldown/borer/upgrade_chemical/check_conditions()
	var/mob/living/basic/cortical_borer/user = owner
	if(user.chemical_evolution < CHEM_COST)
		user.balloon_alert(user, "need [CHEM_COST] chemical point")
		return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/action/cooldown/borer/upgrade_chemical/Activate(mob/living/basic/cortical_borer/user)
	// Give the chemicals we can learn all proper names instead of datum/chemical/whatever, and show that to the user
	var/named_chemicals = list()
	for(var/datum/reagent/learnable_chemical as anything in learnable_reagents)
		named_chemicals += initial(learnable_chemical.name)

	var/reagent_choice = tgui_input_list(
		user,
		"Choose a chemical to learn.",
		"Chemical Selection",
		named_chemicals,
	)
	if(!IsAvailable(TRUE) || check_conditions())
		return

	if(!reagent_choice)
		owner.balloon_alert(owner, "no chemical chosen")
		return

	var/datum/action/cooldown/borer/inject_chemical/action = locate() in user.actions
	if(!action)
		to_chat(owner, span_warning("What use is it wihout a chemical production gland?"))
		return

	var/datum/reagent/learned_reagent = GLOB.name2reagent[reagent_choice]
	if(action.known_chemicals.Find(learned_reagent))
		owner.balloon_alert(owner, "chemical already known!")
		return

	user.chemical_evolution -= CHEM_COST
	action.known_chemicals += learned_reagent
	learnable_reagents -= learned_reagent
	if(length(learnable_reagents) == 0)
		build_all_button_icons(UPDATE_BUTTON_STATUS)

	owner.balloon_alert(owner, "[reagent_choice] learned")
	if(!HAS_TRAIT(user.human_host, TRAIT_AGEUSIA))
		to_chat(user.human_host, span_notice("You get a strange aftertaste of [initial(learned_reagent.taste_description)]!"))

	user.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * user.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)
	return ..()

/**
 * Lets borers learn chemicals that the host they reside in currently possess unless its in the "blacklisted_chemicals" list
 * This ability is required for one of the borer's objectives
 */
/datum/action/cooldown/borer/learn_bloodchemical
	name = "Learn Chemical from Blood (5 chemical points)"
	button_icon_state = "bloodchem"
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Allows you to learn chemicals from blood at a much steeper price\n\
	Does not work on certain chemicals whose mollecular complexity is too high\n\
	"

/datum/action/cooldown/borer/learn_bloodchemical/check_conditions()
	var/mob/living/basic/cortical_borer/user = owner
	if(!length(user.human_host.reagents.reagent_list))
		owner.balloon_alert(owner, "no chemicals in host")
		return COMPONENT_ACTION_BLOCK_TRIGGER

	if(user.chemical_evolution < BLOOD_CHEM_COST)
		user.balloon_alert(user, "need [BLOOD_CHEM_COST] chemical points")
		return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/action/cooldown/borer/learn_bloodchemical/Activate(mob/living/basic/cortical_borer/user)
	// Give the chemicals we can learn all proper names instead of datum/chemical/whatever, and show that to the user
	var/named_chemicals = list()
	for(var/datum/reagent/learnable_chemical as anything in user.human_host.reagents.reagent_list)
		named_chemicals += learnable_chemical.name

	var/reagent_choice = tgui_input_list(
		user,
		"Choose a chemical to learn.",
		"Chemical Selection",
		named_chemicals,
	)
	if(!IsAvailable(TRUE) || check_conditions())
		return

	if(!reagent_choice)
		owner.balloon_alert(owner, "no chemical chosen")
		return

	var/datum/action/cooldown/borer/inject_chemical/action = locate() in user.actions
	if(!action)
		to_chat(owner, span_warning("What use is it wihout a chemical production gland?"))
		return

	// We only know the chosen chemicals name at this point, so we gotta check what chemical do we actually give them
	var/datum/reagent/learned_reagent = GLOB.name2reagent[reagent_choice]
	if(!user.human_host.reagents.reagent_list.Find(learned_reagent))
		owner.balloon_alert(owner, "chemical ran out!")
		return

	if(action.known_chemicals.Find(learned_reagent))
		owner.balloon_alert(owner, "chemical already known!")
		return

	if(!(learned_reagent.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED))
		owner.balloon_alert(owner, "cannot learn [reagent_choice]")
		return

	user.chemical_evolution -= BLOOD_CHEM_COST
	action.known_chemicals += learned_reagent.type
	user.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * user.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)
	if(!HAS_TRAIT(user.human_host, TRAIT_AGEUSIA))
		to_chat(user.human_host, span_notice("You get a strange aftertaste of [learned_reagent.taste_description]!"))

	owner.balloon_alert(owner, "[reagent_choice] learned")
	var/datum/antagonist/cortical_borer/antag = owner.mind?.has_antag_datum(/datum/antagonist/cortical_borer)
	if(antag)
		var/datum/objective/borer/learn_chemicals/objective = locate() in antag.objectives
		if(objective)
			objective.borers[owner.tag] += 1
			objective.check_completion()

	return ..()

#undef CHEM_COST
#undef BLOOD_CHEM_COST
