// Cold
/datum/disease/advance/cold
	copy_type = /datum/disease/advance

/datum/disease/advance/cold/New()
	name = "Cold"
	symptoms = list(new/datum/symptom/sneeze)
	..()

// Flu
/datum/disease/advance/flu
	copy_type = /datum/disease/advance

/datum/disease/advance/flu/New()
	name = "Flu"
	symptoms = list(new/datum/symptom/cough)
	..()

//Randomly generated Disease, for virus crates and events
/datum/disease/premade/random
	name = "Experimental Disease"
	copy_type = /datum/disease

/datum/disease/advance/random/New(max_symptoms, max_level = 8)
	var/list/anti = list(
		ANTIGEN_BLOOD	= 1,
		ANTIGEN_COMMON	= 2,
		ANTIGEN_RARE	= 2,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 2,
		EFFECT_DANGER_FLAVOR	= 2,
		EFFECT_DANGER_ANNOYING	= 2,
		EFFECT_DANGER_HINDRANCE	= 3,
		)
	randomize_disease(30, 60, 50, 100, max_symptoms, anti, bad, list(GLOB.disease_variations), src)

	name = "Sample #[rand(1,10000)]"
