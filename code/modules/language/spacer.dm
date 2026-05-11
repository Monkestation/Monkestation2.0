/datum/language/spacer
	name = "Spacer"
	desc = "A rough, informal tongue used as a last resort when attempts to establish dialogue in more proper languages fail and no automatic translators are available. It relies heavily on tone, body language, signing, and a multitude of creole loanwords. While its use has fallen severely over the years, it's still practiced by a quantity of Frontier crews and unions."
	key = "j"
	flags = TONGUELESS_SPEECH
	sentence_chance = 10
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 1
	syllables = list(
		"ada", "zir", "bian", "ach", "usk", "ado", "ich", "cuan", "iga", "qing", "le", "que", "ki", "qaf", "dei", "eta"
	)
	icon_state = "spacer"
	default_priority = 50

	mutual_understanding = list(
		/datum/language/uncommon = 25,
		/datum/language/common = 25,
		/datum/language/panslavic = 20,
		/datum/language/yangyu = 10,
		/datum/language/piratespeak = 5,
		/datum/language/draconic = 5,
		/datum/language/moffic = 5,
	)
