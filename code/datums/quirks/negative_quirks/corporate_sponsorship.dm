/datum/quirk/corporate_sponsorship
	name = "Corporate Sponsorship"
	desc = "Become a living ad-break with a neural connection directly from the NT Advertisement Network to your mouth or an implanted speaker! Each ad is roughly 5 mins apart and has a revenue of 5 whole credits!"
	value = -2
	icon = FA_ICON_MONEY_BILL

/datum/quirk/corporate_sponsorship/add()
	var/datum/brain_trauma/mild/advert_force_speak/T = new()
	var/mob/living/carbon/human/quirk_holder = src.quirk_holder
	quirk_holder.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)
	var/obj/item/implant/sponsorship/implant = new()
	implant.implant(quirk_holder, quirk_holder, TRUE, TRUE)

/datum/quirk/corporate_sponsorship/remove()
	var/mob/living/carbon/human/quirk_holder = src.quirk_holder
	quirk_holder.cure_trauma_type(/datum/brain_trauma/mild/advert_force_speak, TRAUMA_RESILIENCE_ABSOLUTE)
