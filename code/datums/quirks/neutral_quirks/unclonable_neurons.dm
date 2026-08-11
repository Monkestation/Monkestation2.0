/datum/quirk/uncloneable
	name = "Uncloneable Neurons"
	desc = "Your brain neurons are too short to be scanned by a cloner, but your body can be scanned fine."
	icon = FA_ICON_CLONE
	value = 0
	gain_text = span_notice("Your brain feels fuzzy.")
	lose_text = span_notice("Your brain feels less fuzzy.")
	medical_record_text = "Subject's brain neurons are too short to be scanned by a cloner."

/datum/quirk/uncloneable/post_add()
	if(quirk_holder.mind)
		ADD_TRAIT(quirk_holder.mind, TRAIT_NO_CLONE, QUIRK_TRAIT)

/datum/quirk/uncloneable/remove()
	if(quirk_holder.mind)
		REMOVE_TRAIT(quirk_holder.mind, TRAIT_NO_CLONE, QUIRK_TRAIT)
