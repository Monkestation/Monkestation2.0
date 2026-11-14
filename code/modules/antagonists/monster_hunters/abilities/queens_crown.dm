/// The hunter's reward from the Queen for starting the apocalypse
/datum/status_effect/queens_crown
	id = "queens_crown"
	duration = STATUS_EFFECT_PERMANENT
	processing_speed = STATUS_EFFECT_PRIORITY
	tick_interval = 0.5 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/queens_crown
	var/list/traits_to_give = list(
		TRAIT_ANTIMAGIC,
		TRAIT_NOFLASH,
		TRAIT_NOCRITDAMAGE,
	)

/atom/movable/screen/alert/status_effect/queens_crown
	name = "Crowned"
	desc = "The Queen has promoted you. You are faster, harder to keep down, and no spell can touch you."
	icon_state = "wonderland"

/datum/status_effect/queens_crown/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/queens_crown)
	owner.add_traits(traits_to_give, TRAIT_STATUS_EFFECT(id))
	owner.add_filter("queens_crown", 2, outline_filter(size = 1, color = "#c4143c"))
	var/filter = owner.get_filter("queens_crown")
	animate(filter, size = 2, time = 1 SECONDS, loop = -1)
	animate(size = 1, time = 1 SECONDS)
	return TRUE

/datum/status_effect/queens_crown/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/queens_crown)
	owner.remove_traits(traits_to_give, TRAIT_STATUS_EFFECT(id))
	owner.remove_filter("queens_crown")

/datum/status_effect/queens_crown/get_examine_text()
	return span_rose("There is no crown on [owner.p_their()] head, and yet you are certain it sits perfectly straight. Nothing done to [owner.p_them()] seems to stay done.")

/datum/status_effect/queens_crown/tick(seconds_between_ticks, times_fired)
	var/needs_update = FALSE
	needs_update += owner.adjustBruteLoss(-1.5 * seconds_between_ticks, updating_health = FALSE)
	needs_update += owner.adjustFireLoss(-1.5 * seconds_between_ticks, updating_health = FALSE)
	needs_update += owner.adjustToxLoss(-1 * seconds_between_ticks, updating_health = FALSE, forced = TRUE)
	needs_update += owner.adjustOxyLoss(-1 * seconds_between_ticks, updating_health = FALSE)
	owner.AdjustAllImmobility((-3 SECONDS) * seconds_between_ticks)
	owner.stamina.adjust(3 * seconds_between_ticks, forced = TRUE)
	if(needs_update)
		owner.updatehealth()

/datum/movespeed_modifier/queens_crown
	multiplicative_slowdown = -0.3
