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

	// Listen for both insertion and removal to handle replacements properly
	RegisterSignal(quirk_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gain_organ))
	RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_lose_organ))

/datum/quirk/breathless/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(!istype(carbon_holder))
		return

	var/obj/item/organ/internal/lungs/current_lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(current_lungs)
		REMOVE_TRAIT(current_lungs, TRAIT_SPACEBREATHING, QUIRK_TRAIT)

	UnregisterSignal(quirk_holder, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))

/datum/quirk/breathless/proc/on_gain_organ(mob/living/carbon/source, obj/item/organ/new_organ, special)
	SIGNAL_HANDLER

	if(!istype(new_organ, /obj/item/organ/internal/lungs))
		return

	ADD_TRAIT(new_organ, TRAIT_SPACEBREATHING, QUIRK_TRAIT)

/datum/quirk/breathless/proc/on_lose_organ(mob/living/carbon/source, obj/item/organ/old_organ, special)
	SIGNAL_HANDLER

	if(!istype(old_organ, /obj/item/organ/internal/lungs))
		return

	REMOVE_TRAIT(old_organ, TRAIT_SPACEBREATHING, QUIRK_TRAIT)
