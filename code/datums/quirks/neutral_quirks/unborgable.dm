/datum/quirk/unborgable
	name = "Unborgable"
	desc = "For some reason or another, your brain is completely incompatible with cyborgs or AIs."
	quirk_flags = NONE
	value = 0
	medical_record_text = "Patient's brain is incompatible with artifical intelligence constructs, and cannot be used for a cyborg or AI."
	icon = FA_ICON_LINK_SLASH

/datum/quirk/unborgable/post_add()
	if(quirk_holder.mind)
		ADD_TRAIT(quirk_holder.mind, TRAIT_UNBORGABLE, QUIRK_TRAIT)
