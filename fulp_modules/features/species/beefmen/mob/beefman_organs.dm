/obj/item/organ/brain/beefman
	name = "minced-meat brain"
	desc = "The inexplicably functional brain of a beefman. Some parts seem beyond any dream of repair though..."

/obj/item/organ/brain/beefman/on_mob_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	organ_owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)

/obj/item/organ/brain/beefman/on_mob_remove(mob/living/carbon/organ_owner, special)
	organ_owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	return ..()
