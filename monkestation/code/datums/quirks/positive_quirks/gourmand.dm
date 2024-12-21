/datum/quirk/gourmand
	name = "Gourmand"
	desc = "You enjoy the finer things in life. You are able to have one more food buff applied at once."
	value = 2
	icon = FA_ICON_COOKIE_BITE
	mob_trait = TRAIT_GOURMAND
	gain_text = span_notice("You start to enjoy fine cuisine.</span>")
	lose_text = span_warning("Those Space Twinkies are starting to look mighty fine.")

/datum/quirk/gourmand/add()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs++

/datum/quirk/gourmand/remove()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs--
