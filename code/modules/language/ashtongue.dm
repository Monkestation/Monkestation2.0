/datum/language/ashtongue
	name = "Ashtongue"
	desc = "A language derived from Draconic, altered and morphed into a strange tongue by the enigmatic will of the Necropolis, a half-successful attempt at patterning its own alien communication methods onto mundane races. It's become nigh-incomprehensible to speakers of the original language."
	key = "a"
	flags = TONGUELESS_SPEECH
	space_chance = 70
	space_chance = 12
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 3
	syllables = list(
		list(
			"za", "az", "ze", "ez", "zi", "iz", "zo", "oz", "zu", "uz", "zs", "sz",
			"ha", "ah", "he", "eh", "hi", "ih", "ho", "oh", "hu", "uh", "hs", "sh",
			"la", "al", "le", "el", "li", "il", "lo", "ol", "lu", "ul", "ls", "sl",
			"ka", "ak", "ke", "ek", "ki", "ik", "ko", "ok", "ku", "uk", "ks", "sk",
			"sa", "as", "se", "es", "si", "is", "so", "os", "su", "us", "ss", "ss",
			"ra", "ar", "re", "er", "ri", "ir", "ro", "or", "ru", "ur", "rs", "sr",
			"er", "en", "et", "as", "ot", "un", "ku", "et", "de", "ty", "am",
		),
		list(
			"sint", "nor", "bahr", "sint", "lakor", "eri",
			"noj", "dashilu", "lih", "morh", "ghinu", "kin", "sha", "marik", "jibu",
			"sudas", "fut", "kol", "bivi", "pohim", "devohr", "huirf", "neiris", "sut",
			"viepn", "bag", "docu", "kar", "xlaqf", "raa", "qwos", "nen", "von", "kytaf", "xin",
			"devehr", "iru", "gher", "gan", "ujil", "lacor", "bahris", "ghar", "alnef", "wah",
			"khurdhar", "bar", "ilu", "dash", "diru", "noj", "damjulan", "luvahr",
			"telshahr", "tifur", "enhi", "bahr", "nei", "neibahri", "n'chow", "n'wah",
			"baak", "hlaf", "pyk", "znu", "agr", "ith", "na'ar", "uah", "plhu", "six", "fhler", "bjel", "scee",
			"lleri", "dttm", "aggr", "uujl", "hjjifr", "wuth", "aav", "inya", "sod", "bli", "min", "fril", "bli", "'ddn", "tun'da",
			"'ad", "iir", "krei", "tii'", "ruuk", "nei", "zirua", "surai", "lieket", "miruk", "ettirup", "mireez", "cqiek",
			"brut", "vaahk", "nah'za", "diierk", "piut", "vuurk", "cs'eer", "jeirk", "qiruvk",
		),
	)
	icon_state = "ashtongue"
	default_priority = 90

	mutual_understanding = list(
		/datum/language/draconic = 45,
	)
