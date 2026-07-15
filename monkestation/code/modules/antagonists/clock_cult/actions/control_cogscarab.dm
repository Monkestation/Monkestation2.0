/datum/action/control_host/cogscarab
	name = "Control Cogscarab"
	button_icon = 'icons/obj/clock_cult/clockwork_objects.dmi'
	button_icon_state = "cogscarab_shell"
	background_icon = 'icons/mob/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"
	kill_on_overlord_death = FALSE //an eminence should never die so this is not needed
	no_host_text = "No cogscarab currently hosting you, try clicking on an empty cogscarb shell."
	return_action = /datum/action/return_to_overlord/cogscarab

/datum/action/control_host/cogscarab/proc/try_take_shell(obj/effect/mob_spawn/ghost_role/drone/cogscarab/target_shell, forced)
	if(!forced && tgui_alert(owner, "Take control of this cogscarab shell?", "Control Cogscarab", list("Yes", "No")) != "Yes")
		return

	var/turf/target_turf = get_turf(target_shell)
	qdel(target_shell)
	gain_host(new /mob/living/basic/drone/cogscarab(target_turf))

/datum/action/return_to_overlord/cogscarab
	button_icon = 'icons/obj/clock_cult/clockwork_effects.dmi'
	button_icon_state = "eminence"
	background_icon = 'icons/mob/clock_cult/background_clock.dmi'
	background_icon_state = "bg_clock"
