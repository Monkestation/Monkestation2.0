/datum/language/russian
	name = "Space Russian"
	desc = "An archaic, terrestrial language still spoken in Space Russia."
	key = "2"
	sentence_chance = 5
	space_chance = 50
	syllables = list(
		"bly", "bor", "cy", "da", "ko", "et", "sa", "gop", "grad", "kov",
		"ski", "vok", "nik", "cyka", "ka", "kor", "yov", "suk", "grad",
		"kov", "blyat", "vod", "ka",
	)
	icon = 'fulp_modules/icons/species/russian_language.dmi'
	icon_state = "commie"
	default_priority = 90
	flags = TONGUELESS_SPEECH

/datum/language_holder/russian
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/russian = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/russian = list(LANGUAGE_ATOM),
	)

/datum/language/russian/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()

	// Not a fan of this. Beef and experiment names are tied to the russian language because of this,
	// which is bound to do weird stuff when humans that speak russian get Randomized. Hopefully that's an edge case.
	// I don't have the heart to remove "Subject VI Sirloin" as a possible random beefman name, so it has to stay for now.
	if(prob(50))
		return "[pick(GLOB.experiment_names)] \Roman[rand(1,49)] [pick(GLOB.russian_names)]"
	return "[pick(GLOB.experiment_names)] \Roman[rand(1,49)] [pick(GLOB.beef_names)]"


/obj/item/organ/tongue/beefman
	name = "meaty tongue"
	desc = "A meaty and thick muscle typically found in Beefmen."
	icon = 'fulp_modules/icons/species/mob/beef_tongue.dmi'
	icon_state = "beef_tongue"
	say_mod = "gurgles"
	taste_sensitivity = 15
	languages_native = list(/datum/language/russian)
	disliked_foodtypes = VEGETABLES | FRUIT | CLOTH
	liked_foodtypes = RAW | MEAT | FRIED
	toxic_foodtypes = DAIRY | PINEAPPLE
