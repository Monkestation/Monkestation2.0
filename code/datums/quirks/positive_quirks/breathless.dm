/datum/quirk/breathless
	name = "Breathless"
	desc = "You can survive indefinitely without breathable air, recycling your own supply as needed. Toxins, temperature extremes, and irritants can still affect you."
	icon = FA_ICON_WIND
	value = 10
	gain_text = span_notice("You don't feel the need to breathe.")
	lose_text = span_danger("You feel the need to breathe again.")
	medical_record_text = "Patient demonstrates extreme respiratory tolerance: survives low partial pressures of required gases."
	mail_goodies = list(/obj/item/storage/box/survival)

	var/obj/item/organ/internal/lungs/last_lungs // Track to detect swaps

/datum/quirk/breathless/add(mob/living/carbon/human/quirk_holder)
	RegisterSignal(quirk_holder, COMSIG_LIVING_LIFE, .proc/on_life)
	on_life(quirk_holder) // Initial apply

/datum/quirk/breathless/remove(mob/living/carbon/human/quirk_holder)
	UnregisterSignal(quirk_holder, COMSIG_LIVING_LIFE)
	restore_originals(quirk_holder)

/datum/quirk/breathless/proc/on_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(!H)
		return
	var/obj/item/organ/internal/lungs/L = H.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!L || L == last_lungs)
		return // No change
	last_lungs = L
	apply_freedom(L, H)

/datum/quirk/breathless/proc/apply_freedom(obj/item/organ/internal/lungs/L, mob/living/carbon/human/H)
	if(!L)
		return
	// Zero any >0 mins
	if(L.safe_oxygen_min > 0)
		L.safe_oxygen_min = 0
	if(L.safe_nitro_min > 0)
		L.safe_nitro_min = 0
	if(L.safe_plasma_min > 0)
		L.safe_plasma_min = 0
	// Critical: Add TRAIT_SPACEBREATHING to ignore low total moles check in check_breath()
	ADD_TRAIT(H, TRAIT_SPACEBREATHING, QUIRK_TRAIT)
	// Reset mob failure + alerts
	H.failed_last_breath = FALSE
	H.clear_alert(list(ALERT_NOT_ENOUGH_OXYGEN, ALERT_NOT_ENOUGH_NITRO, ALERT_NOT_ENOUGH_PLASMA))

/datum/quirk/breathless/proc/restore_originals(mob/living/carbon/human/H)
	if(!H)
		return
	var/obj/item/organ/internal/lungs/L = H.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!L)
		return
	// Restore to subtype defaults
	L.safe_oxygen_min = initial(L.safe_oxygen_min)
	L.safe_nitro_min = initial(L.safe_nitro_min)
	L.safe_plasma_min = initial(L.safe_plasma_min)
	// Remove trait
	REMOVE_TRAIT(H, TRAIT_SPACEBREATHING, QUIRK_TRAIT)
	last_lungs = null
