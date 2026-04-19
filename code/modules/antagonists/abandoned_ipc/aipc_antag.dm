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
	can_assign_self_objectives = FALSE
	antagpanel_category = ANTAG_GROUP_ABANDONED_IPC
	///The ion laws that this abandoned IPC must follow
	var/list/laws = list()

/datum/antagonist/abandoned_ipc/on_gain()
	for(var/i in 1 to rand(4,8))
		laws += generate_ion_law()
	return ..()

/datum/antagonist/abandoned_ipc/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	data["can_change_objective"] = can_assign_self_objectives
	data["laws"] = laws
	return data
