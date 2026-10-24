/// The minimum amount of water stacks needed to start washing off the slime.
#define MIN_WATER_STACKS 5
/// How many stacks of an oozeling's own membrane it takes to wash off one stack of slime.
#define OOZE_STACKS_PER_SLIME_STACK 2
/// The minimum amount of health a mob has to have before the status effect is removed.
#define MIN_HEALTH 10

/atom/movable/screen/alert/status_effect/slimed
	name = "Covered in Slime"
	desc = "You are covered in slime and it's eating away at you! Click to start cleaning it off, or find a faster way to wash it away!"
	icon_state = "template"
	overlay_icon = 'icons/obj/xenobiology/slime_rancher/slimed.dmi'
	overlay_state = "slimed"
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/slimed/Click()
	. = ..()
	if (!.)
		return FALSE
	if (!can_wash())
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(remove_slime))
	return TRUE

/// Confirm that we are capable of washing off slime
/atom/movable/screen/alert/status_effect/slimed/proc/can_wash()
	var/mob/living/living_owner = owner
	if (!living_owner.can_resist())
		return FALSE
	if (DOING_INTERACTION_WITH_TARGET(owner, owner))
		return FALSE
	var/datum/status_effect/slimed/slime_effect = attached_effect
	if (slime_effect.get_washing_wetness())
		return FALSE // Don't double dip with washing
	return TRUE

/// Try to get rid of it
/atom/movable/screen/alert/status_effect/slimed/proc/remove_slime()
	owner.balloon_alert(owner, "cleaning off slime...")
	var/datum/status_effect/slimed/slime_effect = owner.has_status_effect(/datum/status_effect/slimed)
	while (!QDELETED(src) && !isnull(slime_effect))
		if (!can_wash())
			return
		owner.Shake(2, 0, duration = 1.2 SECONDS, shake_interval = 0.05 SECONDS)
		if (!do_after(owner, 1.5 SECONDS, owner))
			return
		slime_effect.remove_stacks()

/datum/status_effect/slimed
	id = "slimed"
	tick_interval = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/slimed
	remove_on_fullheal = TRUE

	/// The amount of slime stacks that were applied, reduced by showering yourself under water.
	var/slime_stacks = 10 // ~10 seconds of standing under a shower
	/// Slime color, used for particles.
	var/slime_color
	/// Changes particle colors to rainbow, this overrides `slime_color`.
	var/rainbow

/datum/status_effect/slimed/on_creation(mob/living/new_owner, slime_color = COLOR_SLIME_GREY, rainbow = FALSE)
	src.slime_color = slime_color
	src.rainbow = rainbow
	return ..()

/datum/status_effect/slimed/on_apply()
	if(owner.get_organic_health() <= MIN_HEALTH)
		return FALSE
	to_chat(owner, span_userdanger("You have been covered in a thick layer of slime! Find a way to wash it off!"))
	return ..()

/datum/status_effect/slimed/on_remove()
	owner.remove_shared_particles(rainbow ? "slimed_rainbow" : "slimed_[slime_color]")

/datum/status_effect/slimed/update_particles()
	var/obj/effect/abstract/shared_particle_holder/holder = owner.add_shared_particles(rainbow ? /particles/slime/rainbow : /particles/slime, rainbow ? "slimed_rainbow" : "slimed_[slime_color]")
	if (!rainbow)
		holder.particles.color = "[slime_color]a0"

/// The wetness effect with enough stacks to wash slime off, if any.
/datum/status_effect/slimed/proc/get_washing_wetness()
	var/seconds_between_ticks = tick_interval / (1 SECONDS)
	for(var/datum/status_effect/fire_handler/wet_stacks/wetness in owner.status_effects)
		// a membrane only refills by 1 every heart tick, so it can't wait on a full tick's worth like a shower can
		if(istype(wetness, /datum/status_effect/fire_handler/wet_stacks/oozeling))
			if(wetness.stacks >= OOZE_STACKS_PER_SLIME_STACK)
				return wetness
			continue
		if(wetness.stacks > (MIN_WATER_STACKS * seconds_between_ticks))
			return wetness
	return null

/datum/status_effect/slimed/proc/remove_stacks(stacks_to_remove = 1)
	slime_stacks -= stacks_to_remove // lose 1 stack per second
	if(slime_stacks <= 0)
		to_chat(owner, span_notice("You manage to wash off the layer of slime completely."))
		qdel(src)
		return

	if(prob(10))
		to_chat(owner,span_warning("The layer of slime is slowly getting thinner."))

/datum/status_effect/slimed/tick(seconds_between_ticks)
	// remove from the mob once we have dealt enough damage
	if(owner.get_organic_health() <= MIN_HEALTH)
		to_chat(owner, span_warning("You feel the layer of slime crawling off of your weakened body."))
		qdel(src)
		return

	// handle washing slime off
	var/datum/status_effect/fire_handler/wet_stacks/wetness = get_washing_wetness()
	if(wetness)
		var/stacks_per_slime_stack = istype(wetness, /datum/status_effect/fire_handler/wet_stacks/oozeling) ? OOZE_STACKS_PER_SLIME_STACK : MIN_WATER_STACKS
		var/washed = min(seconds_between_ticks, wetness.stacks / stacks_per_slime_stack) // 1 per second
		wetness.adjust_stacks(-washed * stacks_per_slime_stack)
		remove_stacks(washed)
		return

	// otherwise deal brute damage
	owner.apply_damage(rand(2,4) * seconds_between_ticks, damagetype = BRUTE, wound_bonus = CANT_WOUND)

	if(SPT_PROB(10, seconds_between_ticks))
		var/feedback_text = pick(list(
			"Your entire body screams with pain",
			"Your skin feels like it's coming off",
			"Your body feels like it's melting together"
		))
		to_chat(owner, span_userdanger("[feedback_text] as the layer of slime eats away at you!"))

/datum/status_effect/slimed/get_examine_text(mob/examiner)
	return span_warning("[owner.p_They()] [owner.p_are()] covered in bubbling slime!")

#undef MIN_HEALTH
#undef MIN_WATER_STACKS
#undef OOZE_STACKS_PER_SLIME_STACK
