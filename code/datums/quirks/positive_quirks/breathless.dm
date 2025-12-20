/datum/quirk/breathless
	name = "Breathless"
	desc = "You can survive indefinitely without breathable air, recycling your own supply as needed. Toxins, temperature extremes, and irritants can still affect you."
	icon = FA_ICON_WIND
	value = 10
	// Removed: mob_trait = TRAIT_NOBREATH (too OP: blocks CPR, all gas effects, diseases, smoke/pepper)
	gain_text = span_notice("You don't feel the need to breathe.")
	lose_text = span_danger("You feel the need to breathe again.")
	medical_record_text = "Patient demonstrates extreme respiratory tolerance: survives low partial pressures of required gases."
	mail_goodies = list(/obj/item/storage/box/survival)

	var/obj/item/organ/internal/lungs/current_lungs
	var/list/originals = list() // Backups: "oxygen" -> orig_safe_oxygen_min, etc.

/datum/quirk/breathless/add()
	var/mob/living/carbon/human/H = parent
	RegisterSignal(H, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_REMOVE_ORGAN), .proc/on_lung_change)
	current_lungs = H.getorganslot(ORGAN_SLOT_LUNGS)
	apply_freedom(current_lungs)

/datum/quirk/breathless/remove()
	if(current_lungs)
		restore_originals(current_lungs)
	UnregisterSignal(parent, list(COMSIG_CARBON_GAIN_ORGAN, COMSIG_CARBON_REMOVE_ORGAN))
	current_lungs = null
	originals.Cut()

/datum/quirk/breathless/proc/apply_freedom(obj/item/organ/internal/lungs/L)
	if(!L)
		return
	// Backup originals (for restore on lose/swap)
	originals["oxygen"] = L.safe_oxygen_min
	originals["nitrogen"] = L.safe_nitro_min
	originals["plasma"] = L.safe_plasma_min
	// Zero any >0 mins → no suff from low required gas pp
	if(L.safe_oxygen_min > 0)
		L.safe_oxygen_min = 0
	if(L.safe_nitro_min > 0)
		L.safe_nitro_min = 0
	if(L.safe_plasma_min > 0)
		L.safe_plasma_min = 0
	// Reset any pending failure
	L.failed_last_breath = FALSE
	if(L.owner)
		L.owner.clear_alert(list(ALERT_NOT_ENOUGH_OXYGEN, ALERT_NOT_ENOUGH_NITRO, ALERT_NOT_ENOUGH_PLASMA))

/datum/quirk/breathless/proc/restore_originals(obj/item/organ/internal/lungs/L)
	if(!L || !length(originals))
		return
	L.safe_oxygen_min = originals["oxygen"] || initial(L.safe_oxygen_min)
	L.safe_nitro_min = originals["nitrogen"] || initial(L.safe_nitro_min)
	L.safe_plasma_min = originals["plasma"] || initial(L.safe_plasma_min)

/datum/quirk/breathless/proc/on_lung_change(datum/source, obj/item/organ/new_organ)
	SIGNAL_HANDLER
	if(new_organ.slot != ORGAN_SLOT_LUNGS)
		return
	// Restore old lungs
	restore_originals(current_lungs)
	// Apply to new
	current_lungs = new_organ
	apply_freedom(current_lungs)
