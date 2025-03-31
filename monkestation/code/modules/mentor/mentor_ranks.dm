///
//This is in attempt to merge the mentor system with the AVD system. If done right it should
//mimic how admin verbs are read, applied and saved while still keeping mentors its seperate thing.
//This should be used for all ranks that shouldnt have the ability to affect deeper game components and mechanics
GLOBAL_LIST_EMPTY(mentor_ranks) //list of all mentor_rank datums
GLOBAL_PROTECT(mentor_ranks)

//GLOBAL_LIST_EMPTY(protected_ranks) //admin ranks loaded from txt
//GLOBAL_PROTECT(protected_ranks)

/datum/mentor_rank
	var/name = "NoRank"
	var/rights = NONE
	var/exclude_rights = NONE
	var/include_rights = NONE
	var/can_edit_rights = NONE

/datum/mentor_rank/New(init_name, init_rights, init_exclude_rights, init_edit_rights)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if (name == "NoRank") //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return

	name = init_name
	if(!name)
		qdel(src)
		CRASH("Mentor rank created without name.")
	if(init_rights)
		rights = init_rights
	include_rights = rights
	if(init_exclude_rights)
		exclude_rights = init_exclude_rights
		rights &= ~exclude_rights
	if(init_edit_rights)
		can_edit_rights = init_edit_rights

// Adds/removes rights to this mentor_rank
// Rights are the same as admin rights. However these rights only work for mentor verbs only. These rights do not transfer.
/datum/mentor_rank/proc/process_keyword(group, group_count, datum/mentor_rank/previous_rank)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	var/list/keywords = splittext(group, " ")
	var/flag = 0
	for(var/k in keywords)
		switch(k)
			if("BUILD")
				flag = R_BUILD
			if("ADMIN")
				flag = R_ADMIN
			if("BAN")
				flag = R_BAN
			if("FUN")
				flag = R_FUN
			if("SERVER")
				flag = R_SERVER
			if("DEBUG")
				flag = R_DEBUG
			if("PERMISSIONS")
				flag = R_PERMISSIONS
			if("POSSESS")
				flag = R_POSSESS
			if("STEALTH")
				flag = R_STEALTH
			if("POLL")
				flag = R_POLL
			if("VAREDIT")
				flag = R_VAREDIT
			if("EVERYTHING")
				flag = R_EVERYTHING
			if("SOUND")
				flag = R_SOUND
			if("SPAWN")
				flag = R_SPAWN
			if("AUTOADMIN")
				flag = R_AUTOADMIN
			if("DBRANKS")
				flag = R_DBRANKS
			if("HEADMENTOR")
				flag = R_HEADMENTOR
			if("MENTOR")
				flag = R_MENTOR
			if("@")
				if(previous_rank)
					switch(group_count)
						if(1)
							flag = previous_rank.include_rights
						if(2)
							flag = previous_rank.exclude_rights
						if(3)
							flag = previous_rank.can_edit_rights
				else
					continue
		switch(group_count)
			if(1)
				rights |= flag
				include_rights |= flag
			if(2)
				rights &= ~flag
				exclude_rights |= flag
			if(3)
				can_edit_rights |= flag

//load our rank - > rights associations
/proc/load_mentor_ranks(dbfail, no_update)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin Reload blocked: Advanced ProcCall detected.</span>", confidential = TRUE)
		return
	GLOB.mentor_ranks.Cut()
	//GLOB.protected_ranks.Cut()
	GLOB.dementors.Cut()
	//load text from file and process each entry
	var/ranks_text = file2text("[global.config.directory]/mentor_ranks.txt")
	if (!ranks_text || ranks_text == "") // If file is missing or empty, use fallback defaults for two ranks
		ranks_text = "Name = Mentor\nInclude = MENTOR\nExclude =\nEdit = \n\nName = Head_Mentor\nInclude = @ HEADMENTOR\nExclude = \nEdit =\n"
	var/datum/mentor_rank/previous_rank
	var/regex/mentor_ranks_regex = new(@"^Name\s*=\s*(.+?)\s*\n+Include\s*=\s*([\l @]*?)\s*\n+Exclude\s*=\s*([\l @]*?)\s*\n+Edit\s*=\s*([\l @]*?)\s*\n*$", "gm")
	while(mentor_ranks_regex.Find(ranks_text))
		var/datum/mentor_rank/Rank = new(mentor_ranks_regex.group[1])
		if(!Rank)
			continue
		var/count = 1
		for(var/i in mentor_ranks_regex.group - mentor_ranks_regex.group[1])
			if(i)
				Rank.process_keyword(i, count, previous_rank)
			count++
		GLOB.mentor_ranks += Rank
		//GLOB.protected_ranks += R
		previous_rank = Rank
	if(!CONFIG_GET(flag/mentor_legacy_system) || dbfail)
		if(CONFIG_GET(flag/load_legacy_ranks_only))
			if(!no_update)
				to_chat(world, "Updating.")
				//continue // make a sync with mentor ranks proc
				//sync_ranks_with_db()
	//load ranks from backup file
	if(dbfail)
		var/backup_file = file2text("data/mentors_backup.json")
		if(backup_file == null)
			log_world("Unable to locate admins backup file.")
			return FALSE
/*
//load our rank - > rights associations
/proc/load_admin_ranks(dbfail, no_update)
	if(!CONFIG_GET(flag/admin_legacy_system) || dbfail)
		if(CONFIG_GET(flag/load_legacy_ranks_only))
			if(!no_update)
				sync_ranks_with_db()
		else
			var/datum/db_query/query_load_admin_ranks = SSdbcore.NewQuery("SELECT `rank`, flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")]")
			if(!query_load_admin_ranks.Execute())
				message_admins("Error loading admin ranks from database. Loading from backup.")
				log_sql("Error loading admin ranks from database. Loading from backup.")
				dbfail = 1
			else
				while(query_load_admin_ranks.NextRow())
					var/skip
					var/rank_name = query_load_admin_ranks.item[1]
					for(var/datum/admin_rank/R in GLOB.admin_ranks)
						if(R.name == rank_name) //this rank was already loaded from txt override
							skip = 1
							break
					if(!skip)
						var/rank_flags = text2num(query_load_admin_ranks.item[2])
						var/rank_exclude_flags = text2num(query_load_admin_ranks.item[3])
						var/rank_can_edit_flags = text2num(query_load_admin_ranks.item[4])
						var/datum/admin_rank/R = new(rank_name, rank_flags, rank_exclude_flags, rank_can_edit_flags)
						if(!R)
							continue
						GLOB.admin_ranks += R
			qdel(query_load_admin_ranks)
	//load ranks from backup file
	if(dbfail)
		var/backup_file = file2text("data/admins_backup.json")
		if(backup_file == null)
			log_world("Unable to locate admins backup file.")
			return FALSE
		var/list/json = json_decode(backup_file)
		for(var/J in json["ranks"])
			var/skip
			for(var/datum/admin_rank/R in GLOB.admin_ranks)
				if(R.name == "[J]") //this rank was already loaded from txt override
					skip = TRUE
			if(skip)
				continue
			var/datum/admin_rank/R = new("[J]", json["ranks"]["[J]"]["include rights"], json["ranks"]["[J]"]["exclude rights"], json["ranks"]["[J]"]["can edit rights"])
			if(!R)
				continue
			GLOB.admin_ranks += R
		return json
	#ifdef TESTING
	var/msg = "Permission Sets Built:\n"
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		msg += "\t[R.name]"
		var/rights = rights2text(R.rights,"\n\t\t")
		if(rights)
			msg += "\t\t[rights]\n"
	testing(msg)
	#endif
*/

/// Converts a rank name (such as "Coder+Moth") into a list of /datum/admin_rank
/proc/mentor_ranks_from_rank_name(rank_name)
	var/list/rank_names = splittext(rank_name, "+")
	var/list/ranks = list()

	for (var/datum/mentor_rank/rank as anything in GLOB.mentor_ranks)
		if (rank.name in rank_names)
			rank_names -= rank.name
			ranks += rank

			if (rank_names.len == 0)
				break

	if (rank_names.len > 0)
		log_config("Mentor rank names were invalid: [jointext(ranks, ", ")]")

	return ranks

/// Takes a list of rank names and joins them with +
/proc/join_mentor_ranks(list/datum/mentor_rank/ranks)
	var/list/names = list()

	for (var/datum/mentor_rank/rank as anything in ranks)
		names += rank.name

	return jointext(names, "+")

/proc/load_mentors(no_update)
	var/dbfail // When db checking is implemented
	if(!CONFIG_GET(flag/mentor_legacy_system) && !SSdbcore.Connect()) // Do we need the config_get here when we check lower?
		message_admins("Failed to connect to database while loading mentors. Loading from backup.")
		log_sql("Failed to connect to database while loading mentors. Loading from backup.")
		dbfail = 1
	//clear the datums references
	GLOB.mentor_datums.Cut()
	for(var/client/mentor in GLOB.mentors)
		mentor.remove_mentor_verbs()
		mentor.mentor_datum = null
	GLOB.mentors.Cut()
	var/list/backup_file_json = load_mentor_ranks(dbfail, no_update)
	dbfail = backup_file_json != null
	var/list/rank_names = list()
	for(var/datum/mentor_rank/Rank in GLOB.mentor_ranks)
		rank_names[Rank.name] = Rank
	//ckeys listed in admins.txt are always made admins before sql loading is attempted
	var/mentors_text = file2text("[global.config.directory]/mentors.txt")
	var/regex/mentors_regex = new(@"^(?!#)(.+?)\s+=\s+(.+)", "gm")

	while(mentors_regex.Find(mentors_text))
		var/mentor_key = mentors_regex.group[1]
		var/mentor_rank = mentors_regex.group[2]
		new /datum/mentors(mentor_ranks_from_rank_name(mentor_rank), ckey(mentor_key), force_active = FALSE, protected = TRUE)

	if(!CONFIG_GET(flag/mentor_legacy_system) || dbfail)
		var/datum/db_query/query_load_mentors = SSdbcore.NewQuery("SELECT ckey, `rank`FROM [format_table_name("mentor")] ORDER BY `rank`")
		if(!query_load_mentors.Execute())
			message_admins("Error loading mentors from database. Loading from backup.")
			log_sql("Error loading mentors from database. Loading from backup.")
			dbfail = 1
		else
			while(query_load_mentors.NextRow())
				var/mentor_ckey = ckey(query_load_mentors.item[1])
				var/mentor_rank = query_load_mentors.item[2]
				var/skip

				var/list/mentor_ranks = mentor_ranks_from_rank_name(mentor_rank)

				if(mentor_ranks.len == 0)
					message_admins("[mentor_ckey] loaded with invalid mentor rank [mentor_rank].")
					skip = 1
				if(GLOB.mentor_datums[mentor_ckey] || GLOB.dementors[mentor_ckey])
					skip = 1
				if(!skip)
					new /datum/mentors(mentor_ranks, mentor_ckey)
		qdel(query_load_mentors)
	//load mentors from backup file
	if(dbfail)
		if(!backup_file_json)
			if(backup_file_json != null)
				//already tried
				return
			var/backup_file = file2text("data/mentors_backup.json")
			if(backup_file == null)
				log_world("Unable to locate mentors backup file.")
				return
			backup_file_json = json_decode(backup_file)
		for(var/J in backup_file_json["mentors"])
			var/skip
			for(var/A in GLOB.mentor_datums + GLOB.dementors)
				if(A == "[J]") //this mentor was already loaded from txt override
					skip = TRUE
			if(skip)
				continue
			new /datum/mentors(mentor_ranks_from_rank_name(backup_file_json["mentors"]["[J]"]), ckey("[J]"))
	return dbfail
