//Pre-Defined Global Diseases for use by nanites/wendigo/xenomicrobes/ect.
GLOBAL_LIST_INIT(global_diseases, list())

/proc/create_global_diseases()
	for(var/disease_type in subtypesof(/datum/disease/premade))
		var/datum/disease/premade/D = new disease_type
		GLOB.global_diseases[D.category] = D
		D.update_global_log()

/datum/disease/premade/New()
	. = ..()
	antigen = list(pick(antigen_family(ANTIGEN_RARE)))
	antigen |= pick(antigen_family(ANTIGEN_RARE))
	uniqueID = rand(0,9999)
	subID = rand(0,9999)
	strength = rand(70,100)
	Refresh()

/datum/disease/premade/randomize_disease(min_strength, max_strength, min_robustness, max_robustness, list/antigen, list/symptom_danger, atom/source)
	return

/mob/living/proc/infect_disease_predefined(category, forced, notes)
	if(!GLOB.global_diseases[category])
		return
	infect_disease(GLOB.global_diseases[category], forced, notes)
