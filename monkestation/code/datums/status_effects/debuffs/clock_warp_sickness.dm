/datum/status_effect/clock_warp_sickness
	id = "clock_warp_sickness"
	alert_type = /atom/movable/screen/alert/status_effect/clock_warp_sickness

/datum/status_effect/clock_warp_sickness/on_creation(mob/living/new_owner, _duration = 1 SECOND)
	duration = _duration
	return ..()

/datum/status_effect/clock_warp_sickness/on_apply()
	. = ..()
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/clock_warp_sickness)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/clock_warp_sickness)
	owner.adjust_confusion(duration)
	owner.adjust_dizzy(duration)
	owner.add_client_colour(/datum/client_colour/clock_warp)

/datum/status_effect/clock_warp_sickness/on_remove()
	. = ..()
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/clock_warp_sickness)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/clock_warp_sickness)
	owner.remove_client_colour(/datum/client_colour/clock_warp)

/atom/movable/screen/alert/status_effect/clock_warp_sickness
	name = "Warp Sickness"
	desc = "You are disoriented from recently teleporting."
	icon = 'monkestation/icons/mob/clock_cult/actions_clock.dmi'
	icon_state = "warp_down"
	alerttooltipstyle = "clockwork"

/datum/movespeed_modifier/clock_warp_sickness
	multiplicative_slowdown = 1

/datum/actionspeed_modifier/clock_warp_sickness
	multiplicative_slowdown = 0.6

/datum/client_colour/clock_warp
	colour = LIGHT_COLOR_CLOCKWORK
	priority = 2
	fade_out = 5
