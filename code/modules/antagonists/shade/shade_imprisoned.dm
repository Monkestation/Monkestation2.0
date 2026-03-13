/**
 * This datum is for use by shades who get trapped inside magic dice created by the DNDagger
 */
/datum/antagonist/shade_imprisoned
	name = "\improper Dice-Damned Spirit"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE
	silent = TRUE
	ui_name = "AntagInfoDiceDamned"
	count_against_dynamic_roll_chance = FALSE

/datum/antagonist/shade_imprisoned/proc/display_panel()
	var/datum/action/antag_info/info_button = info_button_ref?.resolve()
	info_button?.Trigger()
