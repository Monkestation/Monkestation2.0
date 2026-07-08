/**
 * A version of the standard borer that can't reproduce
 */

/mob/living/basic/cortical_borer/neutered
	antagonist_datum = /datum/antagonist/cortical_borer
	neutered = TRUE
	skip_status_tab = TRUE
	generation = 1
	/// How many blood chemicals they need to reach for max maturation.
	var/objective_blood_chems = 10
	/// How many dissections they need to reach for max maturation
	var/objective_dissection = 3
	/// How many dissections have they preformed?
	var/dissections = 0


/mob/living/basic/cortical_borer/neutered/get_status_tab_items()
	. = ..()
	. += "Chemical Storage: [chemical_storage]/[max_chemical_storage]"
	. += "Chemical Evolution Points: [chemical_evolution]"
	. += "Stat Evolution Points: [stat_evolution]"
	. += ""
	if(host_sugar())
		. += "Sugar detected! Unable to generate resources!"
		. += ""
	. += "GROWTH OBJECTIVES:"
	. += "1) Dissecting [objective_dissection] bodies: [dissections]/[objective_dissection]"
	. += "2) Learning [objective_blood_chems] chemicals from the blood: [blood_chems_learned]/[objective_blood_chems]"

/mob/living/basic/cortical_borer/neutered/calculate_maturation_discounts()
	/**
	 * In the beginning you start out with the following generation:
	 * Evolution point per 60 seconds
	 * Chemical point per 30 seconds
	 */

	//20:40, 15:30, 10:20, 5:10
	var/maturity_threshold = 30

	maturity_threshold -= min(blood_chems_learned, objective_blood_chems)

	maturity_threshold -= (3.5 * min(dissections, objective_dissection))

	return maturity_threshold
