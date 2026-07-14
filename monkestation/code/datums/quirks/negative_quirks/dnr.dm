/datum/quirk/dnr
	name = "Revival Blacklist"
	desc = "You cannot be revived through most means such as defibrilation, cloning, vampiric or changeling powers. Make your only shot count."
	value = -8
	gain_text = span_danger("You have one chance left.")
	lose_text = span_notice("Your connection to this mortal plane strengthens!")
	medical_record_text = "The connection between the patient's soul and body is incredibly weak, and attempts to resuscitate after death will fail. Ensure heightened care."
	icon = FA_ICON_HEART

/datum/quirk/dnr/add(client/client_source)
	. = ..()
	//can no longer revive
	quirk_holder.mind.add_traits(list(TRAIT_DEFIB_BLACKLISTED, TRAIT_NO_SPECIAL_REVIVAL), QUIRK_TRAIT)

/datum/quirk/dnr/remove()
	quirk_holder.mind.remove_traits(list(TRAIT_DEFIB_BLACKLISTED, TRAIT_NO_SPECIAL_REVIVAL), QUIRK_TRAIT)
	return ..()
