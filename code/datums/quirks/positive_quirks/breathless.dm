/datum/quirk/breathless
	name = "Breathless"
	desc = "You can survive indefinitely without breathable air, recycling your own supply as needed. Toxins, temperature extremes, and irritants can still affect you."
	icon = FA_ICON_WIND
	value = 10
	gain_text = span_notice("You don't feel the need to breathe.")
	lose_text = span_danger("You feel the need to breathe again.")
	medical_record_text = "Patient demonstrates extreme respiratory tolerance: survives low partial pressures of required gases."
	mail_goodies = list(/obj/item/storage/box/survival)

	var/list/originals = list() // "oxygen" -> orig_safe_oxygen_min, etc.

/datum/quirk/breathless/add()
	var/mob/living/carbon/human/H = parent
	RegisterSignal(H, COMSIG_MOB_LOGIN, .proc/on_login) // Handles cloning/surgery mid-round
	apply_freedom(H)

/datum/quirk/breathless/remove()
	var/mob/living/carbon/human/H = parent
	UnregisterSignal(H, COMSIG_MOB_LOGIN)
	restore_originals(H)

/datum/quirk/breathless/proc/apply_freedom(mob/living/carbon/human/H)
	if(!H)
		return
	var/obj/item/organ/internal/lungs/L = H.getorganslot(ORGAN_SLOT_LUNGS)
	if(!L)
		return // No lungs? (rare, e.g., lungless status) - skip

	// Backup (only once per quirk life)
	if(!length(originals))
		originals["oxygen"] = L.safe_oxygen_min
		originals["nitrogen"] = L.safe_nitro_min
		originals["plasma"] = L.safe_plasma_min

	// Zero mins
	if(L.safe_oxygen_min > 0)
		L.safe_oxygen_min = 0
	if(L.safe_nitro_min > 0)
		L.safe_nitro_min = 0
	if(L.safe_plasma_min > 0)
		L.safe_plasma_min = 0

	// Reset mob failure flag + clear alerts
	H.failed_last_breath = FALSE
	H.clear_alert(list(ALERT_NOT_ENOUGH_OXYGEN, ALERT_NOT_ENOUGH_NITRO, ALERT_NOT_ENOUGH_PLASMA))

/datum/quirk/breathless/proc/restore_originals(mob/living/carbon/human/H)
	if(!H || !length(originals))
		return
	var/obj/item/organ/internal/lungs/L = H.getorganslot(ORGAN_SLOT_LUNGS)
	if(!L)
		return

	L.safe_oxygen_min = originals["oxygen"] || initial(L.safe_oxygen_min)
	L.safe_nitro_min = originals["nitrogen"] || initial(L.safe_nitro_min)
	L.safe_plasma_min = originals["plasma"] || initial(L.safe_plasma_min)

	// No need to reset alerts here - normal breathing will handle

/datum/quirk/breathless/proc/on_login(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	apply_freedom(H) // Re-apply on login (cloning, mind transfer, etc.)
