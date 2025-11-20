/datum/asset/spritesheet_batched/job_icons
	name = "job_icons"
	/// The width and height to scale the job icons to.
	var/icon_size = 24

/datum/asset/spritesheet_batched/job_icons/create_spritesheets()
	var/list/id_list = list()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		var/id = sanitize_css_class_name(lowertext(job.config_tag || job.title))
		if(id_list[id])
			continue
		var/datum/universal_icon/job_icon = get_job_hud_icon(job)
		if(!job_icon)
			continue
		insert_icon(id, job_icon)
		id_list[id] = TRUE
