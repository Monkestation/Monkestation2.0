/**
 * The abandoned IPC - a forgotten relic from the previous shift, which has taken some damagee in the form of ion laws
 * They awaken in maintence to find someone attempted to repair them, but gave up halfway through - nonetheless, their self repair systems finished the job.
 *
 * Basic gameplay is just following the ion laws to the best of their abilties - so it depends entirely on what laws they get.
 **/
/datum/antagonist/abandoned_ipc
	name = "\improper Abandoned IPC"
	job_rank = ROLE_ABANDONED_IPC
	antag_hud_name = "abandoned_ipc"
	suicide_cry = "Beep Boop"
	show_name_in_check_antagonists = FALSE
	show_to_ghosts = TRUE
	stinger_sound = 'sound/ambience/antag/malf.ogg'
	ui_name = "AntagInfoAIPC"
	can_assign_self_objectives = TRUE
	default_custom_objective = "Steal the clown"
	antagpanel_category = ANTAG_GROUP_ABANDONED_IPC
