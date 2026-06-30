/datum/language/serpentid
	name = "Serpentid"
	desc = "A strange language that can be understood both by the sounds made and by the movement needed to create those sounds."
	key = "N"
	space_chance = 40
	syllables = list(
		"azs","zis","zau","azua","skiu","zuakz","izo","aei","ki","kut","zo",
		"za", "az", "ze", "ez", "zi", "iz", "zo", "oz", "zu", "uz", "zs", "sz",
		"ha", "ah", "he", "eh", "hi", "ih", "ho", "oh", "hu", "uh", "hs", "sh",
		"la", "al", "le", "el", "li", "il", "lo", "ol", "lu", "ul", "ls", "sl",
		"ka", "ak", "ke", "ek", "ki", "ik", "ko", "ok", "ku", "uk", "ks", "sk",
		"sa", "as", "se", "es", "si", "is", "so", "os", "su", "us", "ss", "ss",
		"ra", "ar", "re", "er", "ri", "ir", "ro", "or", "ru", "ur", "rs", "sr",
		"a",  "a",  "e",  "e",  "i",  "i",  "o",  "o",  "u",  "u",  "s",  "s"
	) //taken from bay lizards
	icon = 'icons/misc/language.dmi'
	icon_state = "serpentid"
	default_priority = 90

/datum/language/nabber/get_random_name()
	var/random_name = ""
	random_name += (pick("Alpha","Delta","Dzetta","Phi","Epsilon","Gamma","Tau","Omega") + "-[rand(0, 999)]") //put shrek with stolen clothes here
	return (random_name)
