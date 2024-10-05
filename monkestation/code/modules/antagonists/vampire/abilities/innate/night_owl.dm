/datum/vampire_ability/night_owl
	name = "Night Owl"
	desc = "You can see well in the dark."

/datum/vampire_ability/night_owl/on_grant_mob()
	RegisterSignal(user, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(on_update_sight))
	user.RegisterSignal(owner, COMSIG_VAMPIRE_MASQUERADE, TYPE_PROC_REF(/mob, update_sight))
	user.update_sight()

/datum/vampire_ability/night_owl/on_remove_mob()
	UnregisterSignal(user, COMSIG_MOB_UPDATE_SIGHT)
	user.UnregisterSignal(owner, COMSIG_VAMPIRE_MASQUERADE)
	user.update_sight()

/datum/vampire_ability/night_owl/proc/on_update_sight()
	SIGNAL_HANDLER
	if(owner.masquerade_enabled)
		return
	user.lighting_color_cutoffs = blend_cutoff_colors(user.lighting_color_cutoffs, list(50, 20, 20))
