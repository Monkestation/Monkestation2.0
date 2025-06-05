/obj/item/slimecross/stabilized/rainbow/Destroy()
	if(!QDELETED(regencore))
		regencore.forceMove(drop_location())
	regencore = null
	return ..()

/datum/status_effect/stabilized/rainbow/on_apply()
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), PROC_REF(on_enter_critical))
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))
	return TRUE

/datum/status_effect/stabilized/rainbow/on_remove()
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_CRITICAL_CONDITION), COMSIG_LIVING_HEALTH_UPDATE))

/datum/status_effect/stabilized/rainbow/proc/on_enter_critical(datum/source)
	SIGNAL_HANDLER
	activate()

/datum/status_effect/stabilized/rainbow/proc/on_health_update(datum/source)
	SIGNAL_HANDLER
	if(owner.health <= owner.hardcrit_threshold)
		activate()

/datum/status_effect/stabilized/rainbow/proc/activate()
	var/obj/item/slimecross/stabilized/rainbow/extract = linked_extract
	if(QDELETED(src) || !istype(extract) || QDELING(extract) || QDELETED(extract.regencore))
		return
	// bypasses cooldowns, but also removes any existing regen effects
	owner.remove_status_effect(/datum/status_effect/regenerative_extract)
	owner.remove_status_effect(/datum/status_effect/slime_regen_cooldown)
	owner.visible_message(span_hypnophrase("[owner] flashes a rainbow of colors, and [owner.p_their()] skin is coated in a milky regenerative goo!"))
	playsound(owner, 'sound/effects/splat.ogg', vol = 40, vary = TRUE)
	extract.regencore.core_effect_before(owner, owner)
	extract.regencore.apply_effect(owner)
	extract.regencore.core_effect(owner, owner)
	QDEL_NULL(extract.regencore)
	QDEL_NULL(linked_extract)
	qdel(src)

