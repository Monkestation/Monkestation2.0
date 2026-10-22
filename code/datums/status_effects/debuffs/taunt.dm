/datum/status_effect/taunt
	id = "taunt"
	alert_type = /atom/movable/screen/alert/status_effect/star_mark
	duration = 5 SECONDS
	tick_interval = CLICK_CD_MELEE
	var/mob/living/taunter

/datum/status_effect/taunt/on_creation(mob/living/new_owner, mob/living/taunter)
	src.taunter = taunter
	return ..()

/datum/status_effect/taunt/on_apply()
	. = ..()
	if(HAS_TRAIT(owner, TRAIT_STUNIMMUNE))
		return FALSE
	if(!taunter)
		return FALSE
	owner.SetImmobilized(5 SECONDS)

/datum/status_effect/taunt/tick(delta_time, times_fired)
	step_towards(owner, taunter)
	owner.SetImmobilized(5 SECONDS)

/datum/status_effect/taunt/on_remove()
	owner.SetImmobilized(0)
