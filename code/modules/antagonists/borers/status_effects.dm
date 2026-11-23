/datum/status_effect/borer_sugar
	id = "borer_sugar"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/borer_sugar

/datum/status_effect/borer_sugar/on_apply()
	. = ..()
	SEND_SIGNAL(owner, COMSIG_SUGAR_CHANGED)

/datum/status_effect/borer_sugar/on_remove()
	. = ..()
	SEND_SIGNAL(owner, COMSIG_SUGAR_CHANGED)

/atom/movable/screen/alert/status_effect/borer_sugar
	name = "Sugar Dampening"
	desc = "Your powers are diminished while sugar is in you or your host!"
	icon = 'icons/mob/actions/actions_borer.dmi'
	icon_state = "borer_sugar"
