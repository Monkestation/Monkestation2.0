/datum/quirk/swedish
	name = "Swedish"
	desc = "You hail from the strange place of Space Sweden. Land of meatballs and flatpacked furniture"
	value = 0
	gain_text = span_danger("You could really go for some meatballs.")
	lose_text = span_notice("You are no longer overenthusiastic about flatpacked furniture.")
	medical_record_text = "Patient is a Space Swede. Poor sod."
	icon = FA_ICON_CROSS
	var/static/list/language_mutilation = list("w" = "v", "j" = "y", "bo" = "bjo", "a" = list("å","ä","æ","a"), "o" = list("ö","ø","o"))


/datum/quirk/swedish/add()
	quirk_holder.AddComponent(/datum/component/speechmod, replacements = language_mutilation, end_string = list("",", bork",", bork, bork"), end_string_chance = 30)

/datum/quirk/swedish/remove()
	qdel(quirk_holder.GetComponent(/datum/component/speechmod))
