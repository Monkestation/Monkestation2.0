/datum/quirk/dnr
	name = "Revival Blacklist"
	desc = "You cannot be revived through most means such as defibrilation, cloning, vampiric or changeling powers, but have a bit more health. Make your only shot count."
	value = -6
	gain_text = span_danger("You have one chance left.")
	lose_text = span_notice("Your connection to this mortal plane strengthens!")
	medical_record_text = "The connection between the patient's soul and body is incredibly weak, and attempts to resuscitate after death will fail. Ensure heightened care."
	icon = FA_ICON_HEART

/datum/quirk/dnr/add(client/client_source)
	. = ..()
	//can no longer revive
	quirk_holder.mind.add_traits(list(TRAIT_DEFIB_BLACKLISTED, TRAIT_NO_SPECIAL_REVIVAL), QUIRK_TRAIT)

	//can survive a bit longer
	quirk_holder.hardcrit_threshold -= (MAX_LIVING_HEALTH / 2)
	quirk_holder.dead_threshold -= MAX_LIVING_HEALTH
	var/obj/item/organ/internal/brain/target_brain = quirk_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(target_brain)
		target_brain.maxHealth += BRAIN_DAMAGE_SEVERE

/datum/quirk/dnr/remove()
	quirk_holder.mind.remove_traits(list(TRAIT_DEFIB_BLACKLISTED, TRAIT_NO_SPECIAL_REVIVAL), QUIRK_TRAIT)
	quirk_holder.hardcrit_threshold += (MAX_LIVING_HEALTH / 2)
	quirk_holder.dead_threshold += MAX_LIVING_HEALTH
	var/obj/item/organ/internal/brain/target_brain = quirk_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(target_brain)
		target_brain.maxHealth -= BRAIN_DAMAGE_SEVERE
	return ..()
