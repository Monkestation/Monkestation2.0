/datum/quirk/breathless
	name = "Breathless"
	desc = "You can survive indefinitely without breathable air, recycling your own supply as needed. Toxins, temperature extremes, and irritants can still affect you."
	icon = FA_ICON_WIND
	value = 10
	mob_trait = TRAIT_SPACEBREATHING
	gain_text = span_notice("You don't feel the need to breathe.")
	lose_text = span_danger("You feel the need to breathe again.")
	medical_record_text = "Patient demonstrates extreme respiratory tolerance: survives low partial pressures of required gases."
	mail_goodies = list(/obj/item/storage/box/survival)
