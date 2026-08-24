/datum/objective/borer
	/// Text of what should be shown in the status panel of all borers
	var/status_text = null
	/// The amount of bonus maturation speed we get upon completing the objective
	var/maturation_boost = 5 SECONDS

/datum/objective/borer/proc/recalculate_borer_speed()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/mind as anything in owners)
		var/mob/living/basic/cortical_borer/borer = mind.current
		if(isnull(mind.current) || !istype(borer))
			continue
		borer.calculate_maturation_speed()

/datum/objective/borer_survive
	name = "survive"
	explanation_text = "Ensure at least one reproductive specimen survives until the end."

/datum/objective/borer_survive/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/mind in owners)
		var/mob/living/basic/cortical_borer/borer = mind.current
		if(isnull(mind.current) || !istype(borer)) // You are gibbed or not a borer, your survival is meaningless without a borer
			continue
		if(!locate(/datum/action/cooldown/borer/produce_offspring) in borer.actions)
			if(!locate(/datum/action/cooldown/borer/empowered_offspring) in borer.actions)
				continue
		if(considered_alive(mind))
			return TRUE
	return FALSE

/datum/objective/borer/produce_egg
	name = "produce eggs"
	target_amount = 5
	/// A list of borers and their amount of created eggs
	/// [borer.tag] = egg_amount
	var/list/borers = list()
	/// The amount of borers that need to complete this objective for it to be successfull
	var/required_borers = 2

/datum/objective/borer/produce_egg/update_explanation_text()
	explanation_text = "We require [required_borers] different borers to produce [target_amount] eggs to spread widely in order to increase our chances of survival."
	check_completion()

/datum/objective/borer/produce_egg/check_completion()
	. = FALSE
	if(completed)
		return TRUE

	var/successfull_borers = 0
	for(var/borer_key in borers)
		if(borers[borer_key] < target_amount)
			continue
		successfull_borers++
		if(successfull_borers == required_borers)
			. = TRUE
			completed = TRUE
			recalculate_borer_speed()
			break

	status_text = "[required_borers] borers producing [target_amount] eggs: [successfull_borers]/[required_borers]"

/datum/objective/borer/willing_hosts
	name = "gather willing hosts"
	target_amount = 2
	maturation_boost = 12.5 SECONDS
	/// A list of minds that are willing
	var/list/minds = list()

/datum/objective/borer/willing_hosts/update_explanation_text()
	explanation_text = "We require [target_amount] willing hosts to create a backbone for our continued survival, should our prey attempt to exterminate us."
	check_completion()

/datum/objective/borer/willing_hosts/check_completion()
	if(completed)
		return TRUE
	status_text = "[target_amount] willing hosts: [length(minds)]/[target_amount]"
	if(length(minds) < target_amount)
		return FALSE

	completed = TRUE
	recalculate_borer_speed()
	return TRUE

/datum/objective/borer/learn_chemicals
	name = "learn chemicals from blood"
	target_amount = 3
	/// A list of borers and their amount of learned chems
	/// [borer.tag] = chems_learned
	var/list/borers = list()
	/// The amount of borers that need to complete this objective for it to be successfull
	var/required_borers = 3
	/// The total amount of chemicals learned, including duplicates
	var/total_chems_learned = 0

/datum/objective/borer/learn_chemicals/update_explanation_text()
	if(required_borers > 1)
		explanation_text = "We need [required_borers] different borers to learn [target_amount] chemicals from the bloodstreams of our hosts to acquire further chemical insight."
	else
		explanation_text = "We need to learn [target_amount] chemicals from the bloodstreams of different hosts to acquire further chemical insight."
	check_completion()

/datum/objective/borer/learn_chemicals/check_completion()
	. = FALSE
	if(completed)
		return TRUE

	total_chems_learned = 0
	var/successfull_borers = 0
	for(var/borer_key in borers)
		total_chems_learned += borers[borer_key]
		if(borers[borer_key] < target_amount)
			continue
		successfull_borers++
		if(successfull_borers == required_borers)
			. = TRUE
			completed = TRUE
			recalculate_borer_speed()
			break

	status_text = "[required_borers] borers learning [target_amount] chemicals from the blood: [successfull_borers]/[required_borers]"

/datum/objective/borer/learn_chemicals/selfish
	name = "learn chemicals from blood"
	target_amount = 10
	required_borers = 1

/datum/objective/borer/learn_chemicals/selfish/check_completion()
	. = ..()
	if(completed)
		maturation_boost = target_amount SECONDS
	else
		maturation_boost = total_chems_learned SECONDS

	recalculate_borer_speed()
	status_text = "Learning [target_amount] chemicals from the blood: [min(total_chems_learned, target_amount)]/[target_amount]"

/datum/objective/borer/dissect_bodies
	name = "dissect bodies"
	target_amount = 3
	/// The amount of bodies we dissected
	var/dissected_bodies = 0

/datum/objective/borer/dissect_bodies/update_explanation_text()
	explanation_text = "To grow stronger we can dissect up to [target_amount] different corpses."
	check_completion()

/datum/objective/borer/dissect_bodies/check_completion()
	if(completed)
		return TRUE

	status_text = "Dissecting [target_amount] bodies: [dissected_bodies]/[target_amount]"
	maturation_boost = 3.5 SECONDS * min(dissected_bodies, target_amount)
	recalculate_borer_speed()

	if(dissected_bodies < target_amount)
		return FALSE
	completed = TRUE
	return TRUE
