/**
 *	# Tremere Powers
 *
 *	This file is for Tremere power procs and Bloodsucker procs that deals exclusively with Tremere.
 *	Tremere has quite a bit of unique things to it, so I thought it's own subtype would be nice
 */

/datum/action/cooldown/bloodsucker/targeted/tremere
	name = "Tremere Gift"
	active_background_icon_state = "tremere_power_on"
	base_background_icon_state = "tremere_power_off"
	button_icon = 'monkestation/icons/bloodsuckers/actions_tremere_bloodsucker.dmi'
	background_icon = 'monkestation/icons/bloodsuckers/actions_tremere_bloodsucker.dmi'
	level_current = 0
	// Re-defining these as we want total control over them
	power_flags = BP_AM_STATIC_COOLDOWN
	// Targeted stuff
	unset_after_click = FALSE

