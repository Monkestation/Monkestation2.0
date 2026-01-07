/datum/status_effect/chilled_core
	id = "chilled_core"
	status_type = STATUS_EFFECT_REFRESH //Custom code
	alert_type = /atom/movable/screen/alert/status_effect/chilled_core
	duration = 3 SECONDS
	tick_interval = 1 SECONDS
	on_remove_on_mob_delete = TRUE
	remove_on_fullheal = TRUE

/datum/status_effect/chilled_core/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_HYPOTHERMIC, TRAIT_STATUS_EFFECT(id)) // Prevent temp stablization

/datum/status_effect/chilled_core/on_remove()
	REMOVE_TRAIT(owner, TRAIT_HYPOTHERMIC, TRAIT_STATUS_EFFECT(id))

//Screen alert
/atom/movable/screen/alert/status_effect/chilled_core
	name = "Chilled to the Core"
	desc = "Something has chilled you to your very core. Warming up seems impossible for now."
	icon_state = "cold"
