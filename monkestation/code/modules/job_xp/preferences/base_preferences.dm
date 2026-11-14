/datum/preferences
	///job xp
	var/list/job_xp_list = list()
	//job level
	var/list/job_level_list = list()
	///claimed rewards
	var/list/job_rewards_claimed = list()
	///per round claims
	var/list/job_rewards_per_round = list()
	/// Set when we got job xp that isn't written to the savefile yet, so it gets saved at roundend
	var/job_xp_unsaved = FALSE

/datum/preferences/proc/write_jobxp_preferences()
	savefile.set_entry("job_xp_list", job_xp_list)
	savefile.set_entry("job_rewards_claimed", job_rewards_claimed)
	savefile.set_entry("job_rewards_per_round", job_rewards_per_round)
	savefile.set_entry("job_level_list", job_level_list)
	job_xp_unsaved = FALSE

/datum/preferences/proc/load_jobxp_preferences()
	job_xp_list = savefile.get_entry("job_xp_list", job_xp_list)
	job_rewards_claimed = savefile.get_entry("job_rewards_claimed", job_rewards_claimed)
	job_rewards_per_round = savefile.get_entry("job_rewards_per_round", job_rewards_per_round)
	job_level_list = savefile.get_entry("job_level_list", job_level_list)

	job_xp_list = SANITIZE_LIST(job_xp_list)
	job_rewards_claimed = SANITIZE_LIST(job_rewards_claimed)
	job_rewards_per_round = SANITIZE_LIST(job_rewards_per_round)
	job_level_list = SANITIZE_LIST(job_level_list)

	if(!length(job_xp_list))
		build_jobxp_list(job_xp_list)
	update_jobxp_list(job_xp_list)

	if(!length(job_rewards_claimed))
		build_jobxp_list(job_rewards_claimed)
	update_jobxp_list(job_rewards_claimed, FALSE)

	if(!length(job_rewards_per_round))
		build_jobxp_list(job_rewards_per_round)
	update_jobxp_list(job_rewards_per_round, FALSE)

	if(!length(job_level_list))
		build_jobxp_list(job_level_list)
	update_jobxp_list(job_level_list)
	//check_unclaimed_rewards()

/datum/preferences/proc/rebuild_all_jobxp_lists()
	job_xp_list = list()
	job_rewards_claimed = list()
	job_rewards_per_round = list()
	job_level_list = list()

	if(!length(job_xp_list))
		build_jobxp_list(job_xp_list)
	if(!length(job_rewards_claimed))
		build_jobxp_list(job_rewards_claimed, FALSE)
	if(!length(job_rewards_per_round))
		build_jobxp_list(job_rewards_per_round, FALSE)
	if(!length(job_level_list))
		build_jobxp_list(job_level_list)

	save_preferences()


/datum/preferences/proc/build_jobxp_list(list/empty_list, should_zero = TRUE)
	var/list/jobs = list()
	var/list/all_jobs = subtypesof(/datum/job)
	for(var/job_type in all_jobs)
		var/datum/job/job = job_type
		jobs += initial(job.title)

	for(var/job in jobs)
		if(!length(SSjob.all_occupations))
			SSjob.SetupOccupations()
		empty_list += job
		if(should_zero)
			empty_list[job] = 0

/datum/preferences/proc/update_jobxp_list(list/update_list, should_zero = TRUE)
	var/list/jobs = list()
	var/list/all_jobs = subtypesof(/datum/job)
	for(var/job_type in all_jobs)
		var/datum/job/job = job_type
		jobs += initial(job.title)

	for(var/job in jobs)
		if(job in update_list)
			if(!update_list[job])
				update_list[job] = 0
			continue
		update_list += job
		if(should_zero)
			update_list[job] = 0

/// Levels up the job as many times as the current xp allows, giving the rewards for each level
/datum/preferences/proc/check_levelup(job)
	if(!job)
		CRASH("check_levelup called without a job passed in how did this happen!")
	while(job_xp_list[job] >= xp_for_next_level(job))
		job_xp_list[job] -= xp_for_next_level(job)
		job_level_list[job]++
		job_xp_unsaved = TRUE
		var/new_level = job_level_list[job]
		if(parent)
			to_chat(parent, span_nicegreen(span_bold("You are now level [new_level] as [job]!")))
		level_up_reward(job)
		for(var/datum/job_milestone/subtype as anything in subtypesof(/datum/job_milestone))
			if(initial(subtype.key_id) != job)
				continue
			var/datum/job_milestone/subtype_created = new subtype
			subtype_created.check_milestones(new_level, parent)

/datum/preferences/proc/level_up_reward(job)
	if(!job || !job_level_list[job])
		return
	adjust_metacoins(parent_ckey, 25 * job_level_list[job], "You have leveled up!")

/// Returns how much xp the job needs to reach its next level
/datum/preferences/proc/xp_for_next_level(job)
	return (job_level_list[job] ** 1.5) + 125

/// Returns an assoc list of job title : xp needed for the next level, only for jobs you can join the station as
/datum/preferences/proc/return_xp_for_nextlevel()
	var/list/jobs_with_xp = list()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		jobs_with_xp[job.title] = xp_for_next_level(job.title)
	return jobs_with_xp
