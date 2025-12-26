/datum/quirk/breathless
	name = "Breathless"
	desc = "You can survive indefinitely without breathable air, recycling your own supply as needed. Toxins, temperature extremes, and irritants can still affect you."
	icon = FA_ICON_WIND
	value = 10
	gain_text = span_notice("You don't feel the need to breathe.")
	lose_text = span_danger("You feel the need to breathe again.")
	medical_record_text = "Patient demonstrates extreme respiratory tolerance: survives low partial pressures of required gases."
	mail_goodies = list(/obj/item/storage/box/survival)

/datum/quirk/breathless/add()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(!istype(carbon_holder))
		return

	var/obj/item/organ/internal/lungs/current_lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(current_lungs)
		ADD_TRAIT(current_lungs, TRAIT_SPACEBREATHING, QUIRK_TRAIT)

	// Listen for future lung insertions (surgery, etc.)
	RegisterSignal(quirk_holder, COMSIG_ORGAN_INSERTED, PROC_REF(on_organ_inserted))

/datum/quirk/breathless/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(!istype(carbon_holder))
		return

	var/obj/item/organ/internal/lungs/current_lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(current_lungs)
		REMOVE_TRAIT(current_lungs, TRAIT_SPACEBREATHING, QUIRK_TRAIT)

	UnregisterSignal(quirk_holder, COMSIG_ORGAN_INSERTED)

/datum/quirk/breathless/proc/on_organ_inserted(mob/living/carbon/source, obj/item/organ/new_organ, special)
	SIGNAL_HANDLER

	if(!istype(new_organ, /obj/item/organ/internal/lungs))
		return

	ADD_TRAIT(new_organ, TRAIT_SPACEBREATHING, QUIRK_TRAIT)
