#ifndef OPENDREAM
/proc/count_atoms()
	. = list()
	for(var/datum/thing in world) //atoms (don't believe its lies)
		.[thing.type]++
	sortTim(., cmp = GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)

/proc/count_datums()
	. = list()
	for(var/datum/thing)
		.[thing.type]++
	sortTim(., cmp = GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
#else
/proc/count_atoms()
	. = list()
	CRASH("count_atoms not supported on OpenDream")

/proc/count_datums()
	. = list()
	CRASH("count_datums not supported on OpenDream")
#endif

ADMIN_VERB(count_instances, R_DEBUG, FALSE, "Count Atoms/Datums", "Count the number of Atoms/Datums.", ADMIN_CATEGORY_DEBUG)
	var/static/is_counting
	if(is_counting)
		to_chat(user, span_warning("Please wait until the previous count is finished!"), type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		return
	is_counting = TRUE
	ASYNC
		user.count_instances_inner()
		is_counting = FALSE

/client/proc/count_instances_inner()
	var/option = tgui_alert(usr, "What type of instances do you wish to count?", "Instance Count", list("Atoms", "Datums"))
	if(!option)
		return
	var/list/result
	to_chat(usr, span_notice("Beginning instance count ([option])"), type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
	switch(option)
		if("Atoms")
			result = count_atoms()
		if("Datums")
			result = count_datums()

	if(result)
		to_chat(usr, span_adminnotice("Counted [length(result)] instances, sending compiled JSON file now."), type = MESSAGE_TYPE_DEBUG, confidential = TRUE)
		var/tmp_path = "tmp/instance_count_[ckey].json"
		fdel(tmp_path)
		rustg_file_write(json_encode(result, JSON_PRETTY_PRINT), tmp_path)
		var/exportable_json = file(tmp_path)
		DIRECT_OUTPUT(usr, ftp(exportable_json, "[lowertext(option)]_instance_count_round_[GLOB.round_id].json"))
		fdel(tmp_path)
