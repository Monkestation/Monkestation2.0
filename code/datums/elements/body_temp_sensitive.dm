/**
 * When attached to a basic mob, it gives it the ability to be hurt by cold/hot body temperatures
 */
/datum/element/body_temp_sensitive
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	///Min body temp
	var/min_body_temp = 250
	///Max body temp
	var/max_body_temp = 350
	////Damage when below min temp
	var/cold_damage = 1
	///Damage when above max temp
	var/heat_damage = 1

/datum/element/body_temp_sensitive/Attach(datum/target, min_body_temp, max_body_temp, cold_damage, heat_damage)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	if(isnum(min_body_temp))
		src.min_body_temp = min_body_temp

	if(isnum(max_body_temp))
		src.max_body_temp = max_body_temp

	if(isnum(cold_damage))
		src.cold_damage = cold_damage

	if(isnum(heat_damage))
		src.heat_damage = heat_damage

	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/element/body_temp_sensitive/Detach(datum/source)
	if(source)
		UnregisterSignal(source, COMSIG_LIVING_LIFE)
	return ..()

/// Hurts the mob and shows an alert when its body temperature is outside the range it can survive in
/datum/element/body_temp_sensitive/proc/on_life(datum/target, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/mob/living/living_mob = target
	var/gave_alert = FALSE

	if(living_mob.bodytemperature < min_body_temp && cold_damage > 0 && !HAS_TRAIT(living_mob, TRAIT_RESISTCOLD))
		living_mob.adjustFireLoss(cold_damage * seconds_per_tick, forced = TRUE)
		if(!living_mob.has_status_effect(/datum/status_effect/inebriated))
			switch(cold_damage)
				if(10 to INFINITY)
					living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)
				if(5 to 10)
					living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
				if(-INFINITY to 5)
					living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
			gave_alert = TRUE

	else if(living_mob.bodytemperature > max_body_temp && heat_damage > 0 && !HAS_TRAIT(living_mob, TRAIT_RESISTHEAT))
		living_mob.adjustFireLoss(heat_damage * seconds_per_tick, forced = TRUE)
		switch(heat_damage)
			if(10 to INFINITY)
				living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)
			if(5 to 10)
				living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
			if(-INFINITY to 5)
				living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
		gave_alert = TRUE

	if(!gave_alert)
		living_mob.clear_alert(ALERT_TEMPERATURE)
