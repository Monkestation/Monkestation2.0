/datum/status_effect/vampire/frenzy
	id = "vampire_frenzy"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/vampire_frenzy

/datum/status_effect/vampire/frenzy/on_remove()
	if(is_transfer)
		return ..()
	SEND_SIGNAL(vampire, COMSIG_VAMPIRE_END_FRENZY)
	return ..()

/atom/movable/screen/alert/status_effect/vampire_frenzy
	name = "Frenzy"
	desc = "An insatiable thirst for blood reigns in your mind!"
	icon = 'monkestation/icons/vampires/actions_vampire.dmi'
	icon_state = "power_frenzy"
	alerttooltipstyle = "cult"
