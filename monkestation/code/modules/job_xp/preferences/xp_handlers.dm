/// Gives job xp to a client. If needs_job is TRUE it only works if they are currently playing that job.
/proc/add_jobxp(client/target, amount, job, needs_job = TRUE)
	if(!target?.prefs || !amount || !job)
		return
	if(needs_job && target.mob?.mind?.assigned_role?.title != job)
		return
	target.prefs.job_xp_list[job] += amount
	target.prefs.job_xp_unsaved = TRUE
	// level ups talk to the database, so don't make whatever gave us the xp sleep
	INVOKE_ASYNC(target.prefs, TYPE_PROC_REF(/datum/preferences, check_levelup), job)

/// Removes job xp from a client. This shouldn't normally ever be called unless you're sadistic.
/proc/remove_jobxp(client/target, amount, job, needs_job = TRUE)
	if(!target?.prefs || !amount || !job)
		return
	if(needs_job && target.mob?.mind?.assigned_role?.title != job)
		return
	target.prefs.job_xp_list[job] = max(target.prefs.job_xp_list[job] - amount, 0)
	target.prefs.job_xp_unsaved = TRUE

/// Same as add_jobxp but only has a chance to give the xp, useful for super spammable stuff.
/proc/add_jobxp_chance(client/target, amount, job, chance, needs_job = TRUE)
	if(prob(chance))
		add_jobxp(target, amount, job, needs_job)

/// Saves the preferences of everyone that got job xp since their last save, including people that already disconnected.
/proc/save_all_jobxp()
	for(var/ckey in GLOB.preferences_datums)
		var/datum/preferences/prefs = GLOB.preferences_datums[ckey]
		if(!prefs?.job_xp_unsaved || !prefs.savefile)
			continue
		prefs.save_preferences()
		CHECK_TICK
