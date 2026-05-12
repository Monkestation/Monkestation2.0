/datum/status_effect/thermally_destabilized
	id = "thermally_destabilized"
	status_type = STATUS_EFFECT_REFRESH //Custom code
	alert_type = /atom/movable/screen/alert/status_effect/thermally_destabilized
	duration = 3 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	remove_on_fullheal = TRUE

/datum/status_effect/thermally_destabilized/on_apply()
	ADD_TRAIT(owner, TRAIT_THERMAL_STASIS, TRAIT_STATUS_EFFECT(id)) // Prevent temp stablization
	return TRUE

/datum/status_effect/thermally_destabilized/on_remove()
	REMOVE_TRAIT(owner, TRAIT_THERMAL_STASIS, TRAIT_STATUS_EFFECT(id))

//Screen alert
/atom/movable/screen/alert/status_effect/thermally_destabilized
	name = "Thermally Destabilized"
	desc = "Your body temperature is being disrupted. Natural warming and cooling is temporarily impossible."
	icon = 'monkestation/icons/hud/screen_alert.dmi'
	icon_state = "stabilization"
