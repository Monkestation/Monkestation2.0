/datum/language/panslavic
	name = "Pan-Slavic"
	desc = "An elaborate mix of various Slavic languages that was once used by the Third Soviet Union and now \
		is the official language of the SSC, being used on spaceports across Human space - even finding a \
		niche in communication with other species."
	key = "P"
	flags = TONGUELESS_SPEECH
	syllables = list(
		"do", "ber", "sve", "tel", "po", "ča", "sen", "jag", "nje", "sla", "do",
		"led", "klo", "ba", "sa", "pa", "ra", "diž", "nik", "vol", "ko", "vi", "ži",
		"ra", "fa", "zob", "na", "ščet", "ka", "zgo", "do", "vi", "na", "zah", "ra",
		"da", "tam", "ten", "led", "nič", "ka", "zá", "pis", "ník", "krá", "va",
		"ku", "ku", "ři", "ce", "ve", "přo", "vé", "ma", "so", "mo", "cný", "pi",
		"kan", "tní", "o", "ran", "žo", "vý", "vlast", "nos", "ti", "hvi", "li", "na",
		"mіs", "ce", "vij", "snі", "da", "nok", "kva", "so", "lja", "char", "ka", "mіs",
		"jacj", "gar", "na", "ne", "pra", "vil", "niy", "min", "dal", "io", "lam", "pa",
		"i", "zo", "bra", "ze", "ni", "e", "is", "kus", "stvo", "bi", "bli", "o", "te",
		"ka", "bas", "se", "in", "fut", "bol", "o", "fis", "po", "che", "mu", "ru",
		"bash", "ka", "kuh", "nia", "rech", "nik", "gor", "ko", "pi", "le", "ti", "na",
		"ko", "ni", "spa", "va", "ha", "so", "ba", "sve", "ska", "nov", "cha", "nik",
		"zem", "lya", "kan", "ce", "la", "ri", "јa", "snezh", "ne", "pa", "da", "vi", "ne"
	)
	space_chance = 5
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 25
	additional_syllable_low = 0
	additional_syllable_high = 0
	icon_state = "panslavic"
	default_priority = 95

	mutual_understanding = list(
		/datum/language/spacer = 20,
		/datum/language/uncommon = 20,
		/datum/language/common = 10,
	)
