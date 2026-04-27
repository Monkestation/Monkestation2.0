/datum/objective/vampire
	martyr_compatible = TRUE

/datum/objective/vampire/New()
	update_explanation_text()
	return ..()

//////////////////////////////////////////////////////////////////////////////////////
//	//						   EGO OBJECTIVES 									//	//
//////////////////////////////////////////////////////////////////////////////////////
/datum/objective/vampire/ego
	name = "Dominion"
	explanation_text = "You crave power, the authority to rule:"

//////////////////////////////////////////////////       Lair
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/vassals
	name = "Vassalize Mortals"

/datum/objective/vampire/ego/vassals/New()
	target_amount = rand(1, 3)
	return ..()

/datum/objective/vampire/ego/vassals/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Vassalize [target_amount] mortal\s using a Vassalization Rack, and ensure they survive the shift."

// WIN CONDITIONS?
/datum/objective/vampire/ego/vassals/check_completion()
	var/datum/antagonist/vampire/vampire_datum = owner.has_antag_datum(/datum/antagonist/vampire)
	return vampire_datum?.count_vassals(only_living = TRUE) >= target_amount


////////////////////////////////////////////////// Department Vassal
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/department_vassal
	name = "Bind a Department"

	///The selected department we have to vassalize.
	var/target_department
	///List of all departments that can be selected for the objective.
	var/static/list/possible_departments = list(
		"engineering" = DEPARTMENT_BITFLAG_ENGINEERING,
		"medical" = DEPARTMENT_BITFLAG_MEDICAL,
		"science" = DEPARTMENT_BITFLAG_SCIENCE,
		"cargo" = DEPARTMENT_BITFLAG_CARGO,
		"service" = DEPARTMENT_BITFLAG_SERVICE,
	)

/datum/objective/vampire/ego/department_vassal/New()
	target_department = pick(possible_departments)
	target_amount = 1
	return ..()

/datum/objective/vampire/ego/department_vassal/update_explanation_text()
	explanation_text = "[initial(explanation_text)] Convert a crew member from the [target_department] department into your vassal."
	return ..()

/datum/objective/vampire/ego/department_vassal/proc/get_vassal_occupations()
	var/datum/antagonist/vampire/vampire_datum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!length(vampire_datum?.vassals))
		return FALSE

	var/list/all_vassal_jobs = list()
	for(var/datum/antagonist/vassal/vassal_datum in vampire_datum.vassals)
		if(!vassal_datum.owner)
			continue

		var/datum/mind/vassal_mind = vassal_datum.owner

		// Mind Assigned
		if(vassal_mind.assigned_role)
			all_vassal_jobs += vassal_mind.assigned_role
			continue
		// Mob Assigned
		if(vassal_mind.current?.job)
			all_vassal_jobs += SSjob.GetJob(vassal_mind.current.job)
			continue
		// PDA Assigned
		if(ishuman(vassal_mind.current))
			var/mob/living/carbon/human/human_vassal = vassal_mind.current
			all_vassal_jobs += SSjob.GetJob(human_vassal.get_assignment())
			continue

	return all_vassal_jobs

/datum/objective/vampire/ego/department_vassal/check_completion()
	var/list/vassal_jobs = get_vassal_occupations()
	var/converted_count = 0
	for(var/datum/job/checked_job in vassal_jobs)
		if(checked_job.departments_bitflags & possible_departments[target_department])
			converted_count++
	if(converted_count >= target_amount)
		return TRUE
	return FALSE


//////////////////////////////////////////////////    Big Places
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/ego/bigplaces
	name = "Ascend the Ranks"

/datum/objective/vampire/ego/bigplaces/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Rise in power, reach prince or scourge, or prey on enough mortals to rank up as much as possible. You must reach at least rank 8 by the end of the shift!"

// WIN CONDITIONS?
/datum/objective/vampire/ego/bigplaces/check_completion()
	var/datum/antagonist/vampire/vampire_datum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire_datum)
		return FALSE

	if(vampire_datum.vampire_level + vampire_datum.vampire_level_unspent >= 8)
		return TRUE

	return FALSE


//////////////////////////////////////////////////////////////////////////////////////
//	//						 HEDONISM OBJECTIVES 								//	//
//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism
	name = "Hunger"
	explanation_text = "You crave depravity, to sate your thirst on the mortals:"


//////////////////////////////////////////////////     Gourmand
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/gourmand
	name = "Gorge"

/datum/objective/vampire/hedonism/gourmand/New()
	target_amount = rand(500, 1000) // This is blood, not vitae.
	return ..()

/datum/objective/vampire/hedonism/gourmand/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Consume at least [target_amount] units of blood to sate your ravenous thirst."

/datum/objective/vampire/hedonism/gourmand/check_completion()
	var/datum/antagonist/vampire/vampiredatum = owner.has_antag_datum(/datum/antagonist/vampire)
	if(!vampiredatum)
		return FALSE
	var/stolen_blood = vampiredatum.total_blood_drank
	if(stolen_blood >= target_amount)
		return TRUE
	return FALSE

//////////////////////////////////////////////////     Thirster
////////////////////////////////////////////////////////////////////

/datum/objective/vampire/hedonism/thirster
	name = "Complete Drain"
	// no check_completion, we just manually set `completed` in feed.

/datum/objective/vampire/hedonism/thirster/update_explanation_text()
	. = ..()
	explanation_text = "[initial(explanation_text)] Drain a mortal completely, letting their lifeblood become your sustenance and their body fall cold and spent."

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////       MISC       //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

/datum/objective/survive/vampire
	name = "Endure"
	explanation_text = "Avoid final death at all costs."

/**
 * Vassal
 */
/datum/objective/vampire/vassal
	name = "assist master"
	explanation_text = "You crave the blood of your sire! Obey and protect them at all costs!"

/datum/objective/vampire/vassal/check_completion()
	var/datum/antagonist/vassal/vassal_datum = owner.has_antag_datum(/datum/antagonist/vassal)
	return vassal_datum.master?.owner?.current?.stat != DEAD
