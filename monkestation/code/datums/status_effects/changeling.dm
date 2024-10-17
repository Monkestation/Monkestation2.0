/atom/movable/screen/alert/status_effect/changeling/Initialize(mapload)
	. = ..()
	underlays += mutable_appearance('icons/mob/actions/backgrounds.dmi', "bg_changeling")
	add_overlay(mutable_appearance('icons/mob/actions/backgrounds.dmi', "bg_changeling_border"))

/datum/movespeed_modifier/changeling_adrenaline
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.8

/atom/movable/screen/alert/status_effect/changeling/adrenaline
	name = "Adrenaline"
	desc = "Energy is surging through us. If we wish to escape, the time is now!"
	icon = 'icons/mob/actions/actions_changeling.dmi'
	icon_state = "adrenaline"

/datum/status_effect/changeling_adrenaline
	id = "changeling_adrenaline"
	duration = 20 SECONDS
	show_duration = TRUE
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/changeling/adrenaline
	status_type = STATUS_EFFECT_REFRESH

	var/static/list/traits = list(TRAIT_SLEEPIMMUNE, TRAIT_BATON_RESISTANCE, TRAIT_CANT_STAMCRIT)

	var/movespeed_timer

/datum/status_effect/changeling_adrenaline/on_apply()
	. = ..()
	to_chat(owner, span_notice("Energy rushes through us."))
	owner.add_traits(traits, REF(src))

	owner.SetAllImmobility(0)
	owner.set_resting(FALSE, silent = TRUE, instant = TRUE)

	owner.add_movespeed_modifier(/datum/movespeed_modifier/changeling_adrenaline)
	movespeed_timer = addtimer(CALLBACK(src, PROC_REF(remove_movespeed_modifier)), 6 SECONDS, TIMER_STOPPABLE)

/datum/status_effect/changeling_adrenaline/on_remove()
	. = ..()
	to_chat(owner, span_notice("Our energy fizzles out."))
	owner.remove_traits(traits, REF(src))
	remove_movespeed_modifier()

/datum/status_effect/changeling_adrenaline/refresh(effect, ...)
	duration += initial(duration)
	remove_movespeed_modifier()
	on_apply()

/datum/status_effect/changeling_adrenaline/tick(seconds_per_tick, times_fired)
	owner.AdjustAllImmobility(-1 SECOND * seconds_per_tick)
	owner.stamina.adjust(STAMINA_MAX / 20 * seconds_per_tick)
	owner.set_jitter_if_lower(10 SECONDS)
	owner.adjustToxLoss(0.5 * seconds_per_tick) // 10 toxin damage total.

/datum/status_effect/changeling_adrenaline/proc/remove_movespeed_modifier()
	deltimer(movespeed_timer)
	movespeed_timer = null
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/changeling_adrenaline)
