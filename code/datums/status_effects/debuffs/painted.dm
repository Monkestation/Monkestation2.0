//used by gangs
/datum/status_effect/painted
	id = "painted"
	//gets removed when the mob is cleaned
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = -1
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect
	remove_on_fullheal = TRUE
	///How long before the effect becomes removable, getting it reapplied refreshes this
	var/resistant_duration = 30 SECONDS
	///The game tick we become removable on
	var/removable_tick = 0
	///How many stacks of paint have been applied
	var/stacks = 1
	///At how many stacks do we "detonate"
	var/max_stacks = 10
	///How much damage to do when detonating
	var/detonation_damage = 50

/datum/status_effect/painted/on_creation(mob/living/new_owner, applied_stacks = 1)
	stacks = applied_stacks
	removable_tick = world.time + resistant_duration
	return ..()

/datum/status_effect/painted/on_apply()
	check_detonation()
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(owner_cleaned))
	return TRUE

/datum/status_effect/painted/on_remove()
	UnregisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT)

/datum/status_effect/painted/refresh(effect, applied_stacks = 1)
	removable_tick = world.time + resistant_duration
	if(stacks < max_stacks)
		stacks += applied_stacks
		check_detonation()

/datum/status_effect/painted/proc/check_detonation()
	if(stacks < max_stacks)
		return

	owner.balloon_alert_to_viewers("[owner] doubles over in pain!")
	owner.visible_message("The paint covering [owner] becomes too much and they double over in pain!")
	playsound(owner, 'sound/effects/attackblob.ogg', 60)
	if(IS_GANGMEMBER(owner) || !owner.stamina)
		owner.adjustBruteLoss(detonation_damage, TRUE, TRUE)
	else
		owner.stamina.adjust(-detonation_damage)

/datum/status_effect/painted/proc/owner_cleaned(mob/living/cleaned, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & CLEAN_TYPE_HARD_DECAL) || world.time < removable_tick)
		return

	qdel(src)
	return COMPONENT_CLEANED
