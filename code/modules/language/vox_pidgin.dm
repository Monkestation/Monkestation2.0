/datum/language/vox_pidgin
	name = "Vox Pidgin"
	desc = "The common tongue of the various Vox ships making up the Shoal. It sounds like chaotic shrieking to everyone else."
	key = "@"
	flags = LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD // alien language to most species
	space_chance = 5
	sentence_chance = 25
	between_word_sentence_chance = 10
	between_word_space_chance = 5
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list("ti","ti","ti","hi","hi","ki","ki","ki","ki","ya","ta","ha","ka","ya","chi","cha","kah", \
	"SKRE","AHK","EHK","RAWK","KRA","AAA","EEE","KI","II","KRI","KA")
	icon_state = "vox"
	default_priority = 90

