/datum/quirk/self_respiration
	name = "Breathless"
	desc = "You either have no need to breathe, or recycle your own air supply. You won't be able to do CPR properly."
	icon = FA_ICON_LUNGS
	value = 8
	mob_trait = TRAIT_NOBREATH
	gain_text = span_notice("You don't feel the need to breathe.")
	lose_text = span_danger("You feel the need to breathe again.")
	medical_record_text = "Patient demonstrates no need to breathe."
	mail_goodies = list(/obj/item/storage/box/survival)
