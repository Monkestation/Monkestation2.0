/// Starts a looping squish animation, extra squishy when splitting.
/mob/living/basic/slime/proc/start_undulating(splitting = FALSE)
	var/matrix/squished = matrix(transform)
	squished.Scale(splitting ? 1.1 : 1, 0.85)
	var/matrix/base = matrix(transform)
	animate(src, transform = squished, time = 0.4 SECONDS, easing = EASE_OUT, loop = -1)
	animate(pixel_z = pixel_z - 2, time = 0.4 SECONDS, easing = EASE_OUT)
	animate(transform = base, time = 0.4 SECONDS, easing = EASE_IN)
	animate(pixel_z = pixel_z, time = 0.4 SECONDS, easing = EASE_IN)

/// hnnngh... *plop*
/mob/living/basic/slime/proc/squish_out_extract()
	var/matrix/base = matrix(transform)
	var/matrix/squished = matrix(transform)
	squished.Scale(1.15, 0.8)
	var/matrix/stretched = matrix(transform)
	stretched.Scale(0.9, 1.1)
	animate(src, transform = squished, time = 0.15 SECONDS, easing = EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(transform = stretched, time = 0.1 SECONDS, easing = EASE_OUT)
	animate(transform = base, time = 0.15 SECONDS, easing = EASE_IN)

/// Stops the animation and puts the saved transform and pixel_z back.
/mob/living/basic/slime/proc/stop_undulating(matrix/base, base_pixel_z)
	animate(src)
	if(base)
		transform = base
	pixel_z = base_pixel_z

/// The bit where a slime wobbles around before it splits or mutates.
/datum/status_effect/slime_reproducing
	id = "slime_reproducing"
	duration = SLIME_SPLIT_WINDUP
	tick_interval = STATUS_EFFECT_NO_TICK
	show_duration = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/slime_reproducing
	processing_speed = STATUS_EFFECT_PRIORITY // so slimes don't spend half an eternity mutating/splitting if server is laggy
	/// TRUE if something interrupted the wobbling, so the split or mutation doesn't happen.
	var/interrupted = FALSE
	/// Transform to restore when the animation stops.
	var/matrix/base_transform
	/// pixel_z to restore when the animation stops.
	var/base_pixel_z

/datum/status_effect/slime_reproducing/on_creation(mob/living/new_owner, new_duration)
	if(new_duration)
		duration = new_duration
	return ..()

/datum/status_effect/slime_reproducing/on_apply()
	var/mob/living/basic/slime/slime_owner = owner
	if(!isslime(slime_owner))
		return FALSE
	var/splitting = (slime_owner.queued_mutation == slime_owner.slime_type.type)

	owner.add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED), TRAIT_STATUS_EFFECT(id))
	slime_owner.pause_ai(SLIME_WINDUP_TRAIT)

	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(interrupt))
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))

	if(splitting)
		owner.visible_message(span_notice("[owner] starts to flatten, [owner.p_they()] look[owner.p_s()] to be splitting."))
		owner.balloon_alert_to_viewers("splitting...")
	else
		owner.visible_message(span_notice("[owner] starts to undulate, [owner.p_they()] look[owner.p_s()] to be mutating."))
		owner.balloon_alert_to_viewers("mutating...")

	base_transform = matrix(owner.transform)
	base_pixel_z = owner.pixel_z
	slime_owner.start_undulating(splitting) // hehe jiggle
	owner.do_jitter_animation()
	return TRUE

/// a shove interrupts, unless it's a monkey flailing at us
/datum/status_effect/slime_reproducing/proc/on_attack_hand(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(ismonkeybasic(user) || !(user.istate & ISTATE_SECONDARY))
		return
	interrupt()

/// Interrupts the wobbling, so the slime doesn't split or mutate.
/datum/status_effect/slime_reproducing/proc/interrupt()
	SIGNAL_HANDLER
	interrupted = TRUE
	qdel(src)

/datum/status_effect/slime_reproducing/proc/on_damaged(mob/living/source, damage)
	SIGNAL_HANDLER
	if(damage > 0)
		interrupt()

/datum/status_effect/slime_reproducing/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_DEATH, COMSIG_ATOM_ATTACK_HAND, COMSIG_MOB_APPLY_DAMAGE))
	owner.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED), TRAIT_STATUS_EFFECT(id))

	var/mob/living/basic/slime/slime_owner = owner
	slime_owner.unpause_ai(SLIME_WINDUP_TRAIT)
	slime_owner.stop_undulating(base_transform, base_pixel_z)

	if(interrupted || QDELETED(owner) || owner.stat != CONSCIOUS)
		slime_owner.queued_mutation = null
		COOLDOWN_START(slime_owner, ranch_retry_cooldown, SLIME_RANCH_RETRY_COOLDOWN)
	else
		slime_owner.finish_reproduce()

/atom/movable/screen/alert/status_effect/slime_reproducing
	name = "Reproducing"
	desc = "You're busy dividing yourself. Hold still."
	icon = 'icons/hud/screen_slimecore.dmi'
	icon_state = "template"
	overlay_icon = 'icons/mob/actions/actions_slime.dmi'
	overlay_state = "slimesplit"
