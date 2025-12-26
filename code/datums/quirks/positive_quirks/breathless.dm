/datum/quirk/breathless
    name = "Breathless"
    desc = "You can survive indefinitely without breathable air, recycling your own supply as needed. Toxins, temperature extremes, and irritants can still affect you."
    icon = FA_ICON_WIND
    value = 10
    gain_text = span_notice("You don't feel the need to breathe.")
    lose_text = span_danger("You feel the need to breathe again.")
    medical_record_text = "Patient demonstrates extreme respiratory tolerance: survives low partial pressures of required gases."
    mail_goodies = list(/obj/item/storage/box/survival)

/datum/quirk/breathless/add(client/source_client)
    var/mob/living/carbon/human/human_holder = quirk_holder
    if(!istype(human_holder))
        return

    // Add to current lungs if they exist
    var/obj/item/organ/internal/lungs/current_lungs = human_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
    if(current_lungs)
        ADD_TRAIT(current_lungs, TRAIT_SPACEBREATHING, QUIRK_TRAIT)

    // Ensure it gets added to any future lungs (surgery, regeneration, etc.)
    RegisterSignal(quirk_holder, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gain_organ))
    RegisterSignal(quirk_holder, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_lose_organ))

/datum/quirk/breathless/remove()
    var/mob/living/carbon/human/human_holder = quirk_holder
    if(!istype(human_holder))
        return

    // Remove from current lungs
    var/obj/item/organ/internal/lungs/current_lungs = human_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
    if(current_lungs)
        REMOVE_TRAIT(current_lungs, TRAIT_SPACEBREATHING, QUIRK_TRAIT)

    // Clean up signals
    UnregisterSignal(quirk_holder, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_LOSE_ORGAN))

/// Called when the mob gains any organ — we only care about lungs
/datum/quirk/breathless/proc/on_gain_organ(datum/source, obj/item/organ/new_organ)
    SIGNAL_HANDLER

    if(!istype(new_organ, /obj/item/organ/internal/lungs))
        return

    ADD_TRAIT(new_organ, TRAIT_SPACEBREATHING, QUIRK_TRAIT)

/// Optional: if lungs are removed and re-inserted, make sure trait is gone while no lungs
/datum/quirk/breathless/proc/on_lose_organ(datum/source, obj/item/organ/old_organ)
    SIGNAL_HANDLER

    if(!istype(old_organ, /obj/item/organ/internal/lungs))
        return

    REMOVE_TRAIT(old_organ, TRAIT_SPACEBREATHING, QUIRK_TRAIT)
