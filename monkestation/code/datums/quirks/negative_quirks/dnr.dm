/datum/quirk/dnr
	name = "Revival Blacklist"
	desc = "You cannot be revived through conventional means such as defibrilation or cloning, but have a bit more health. Make your only shot count."
	value = -6
	gain_text = span_danger("You have one chance left.")
	lose_text = span_notice("Your connection to this mortal plane strengthens!")
	medical_record_text = "The connection between the patient's soul and body is incredibly weak, and attempts to resuscitate after death will fail. Ensure heightened care."
	icon = FA_ICON_HEART

/datum/quirk/dnr/add(client/client_source)
	. = ..()
	ADD_TRAIT(quirk_holder.mind, TRAIT_DEFIB_BLACKLISTED, QUIRK_TRAIT)
	quirk_holder.hardcrit_threshold -= (MAX_LIVING_HEALTH / 2)
	quirk_holder.dead_threshold -= MAX_LIVING_HEALTH

/datum/quirk/dnr/remove()
	REMOVE_TRAIT(quirk_holder.mind, TRAIT_DEFIB_BLACKLISTED, QUIRK_TRAIT)
	quirk_holder.hardcrit_threshold += (MAX_LIVING_HEALTH / 2)
	quirk_holder.dead_threshold += MAX_LIVING_HEALTH
	return ..()
