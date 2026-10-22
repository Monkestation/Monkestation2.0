/datum/quirk/language
	var/list/language_mutilation = list()
	var/list/language_word_mutiliation = list()
	var/list/end_string = list()
	var/end_string_chance = 0
	value = 0
	abstract_parent_type = /datum/quirk/language

/datum/quirk/language/add()
	quirk_holder.AddComponent(/datum/component/speechmod, replacements = language_mutilation, word_replacements = language_word_mutiliation, end_string = end_string, end_string_chance = end_string_chance)

/datum/quirk/language/remove()
	qdel(quirk_holder.GetComponent(/datum/component/speechmod))

/datum/quirk/language/swedish
	name = "Swedish"
	desc = "You hail from the strange place of Space Sweden. Land of meatballs and flatpacked furniture."
	gain_text = span_danger("You could really go for some meatballs.")
	lose_text = span_notice("You are no longer overenthusiastic about flatpacked furniture.")
	medical_record_text = "Patient is a Space Swede. Poor sod."
	icon = FA_ICON_CROSS
	language_mutilation = list("w" = "v", "j" = "y", "bo" = "bjo", "a" = list("å","ä","æ","a"), "o" = list("ö","ø","o"))
	end_string = list("",", bork",", bork, bork")
	end_string_chance = 30

/datum/quirk/language/scottish
	name = "Scottish"
	desc = "You spent much of your life on the highlands, your matter of speech has evolved alongside with your tastes in alcoholic beverages and eyepatches."
	gain_text = span_danger("You can't help but speak with a Scottish accent.")
	lose_text = span_notice("Your speech has devolved into its old speech patterns.")
	medical_record_text = "Patient has spent a long time in the highlands."
	icon = FA_ICON_SWATCHBOOK

/datum/quirk/language/scottish/New()
	. = ..()
	language_mutilation = strings("scottish.json", "scottish")
	language_word_mutiliation = strings("scottish.json", "scottish_words")
