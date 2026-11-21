/// Staggered can occur most often via shoving, but can also occur in other places too.
/datum/status_effect/staggered
	id = "staggered"
	tick_interval = 0.8 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE

/datum/status_effect/staggered/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/staggered/on_apply()
	//you can't stagger the dead.
	if(owner.stat == DEAD)
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(clear_staggered))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/staggered)
	return TRUE

/datum/status_effect/staggered/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/staggered)

/// Signal proc that self deletes our staggered effect
/datum/status_effect/staggered/proc/clear_staggered(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/staggered/tick(seconds_between_ticks)
	//you can't stagger the dead - in case somehow you die mid-stagger
	if(owner.stat == DEAD)
		qdel(src)
		return
	if(HAS_TRAIT(owner, TRAIT_FAKEDEATH))
		return
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living, do_stagger_animation))

/// Helper proc that causes the mob to do a stagger animation.
/// Doesn't change significantly, just meant to represent swaying back and forth
/mob/living/proc/do_stagger_animation()
	var/normal_pos = base_pixel_x + body_position_pixel_x_offset
	var/jitter_right = normal_pos + 4
	var/jitter_left = normal_pos - 4
	animate(src, pixel_x = jitter_left, 0.2 SECONDS, flags = ANIMATION_PARALLEL)
	animate(pixel_x = jitter_right, time = 0.4 SECONDS)
	animate(pixel_x = normal_pos, time = 0.2 SECONDS)
