/datum/reagent
	///do we need to start checking processes of chemicals?
	var/requires_process = FALSE

///called whenever a reagent holder (beaker, plumbing machine, etc.) processes its internal chemicals
/datum/reagent/proc/reagent_fire(datum/reagents/holder)
	return
