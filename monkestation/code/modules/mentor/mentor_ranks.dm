///
//This is in attempt to merge the mentor system with the AVD system. If done right it should
//mimic how admin verbs are read, applied and saved while still keeping mentors its seperate thing.
//This should be used for all ranks that shouldnt have the ability to affect deeper game components and mechanics
//Maybe things like community manager or give some special donator rank a verb.
GLOBAL_LIST_EMPTY(mentor_ranks) //list of all mentor_rank datums
GLOBAL_PROTECT(mentor_ranks)

GLOBAL_LIST_EMPTY(protected_mentor_ranks) //admin ranks loaded from txt
GLOBAL_PROTECT(protected_mentor_ranks)

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
			if("HEADMENTOR")
				flag = R_HEADMENTOR
			if("MENTOR")
				flag = R_MENTOR
			if("EVERYTHING")
				flag = R_MENTOR_EVERYTHING
			if("AUTOMENTOR")
				flag = R_AUTOMENTOR
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

/proc/sync_mentor_ranks_with_db()
	set waitfor = FALSE

	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin rank DB Sync blocked: Advanced ProcCall detected.</span>", confidential = TRUE)
		return

	var/list/sql_ranks = list()
	for(var/datum/mentor_rank/R in GLOB.protected_mentor_ranks)
		sql_ranks += list(list("rank" = R.name, "flags" = R.include_rights, "exclude_flags" = R.exclude_rights, "can_edit_flags" = R.can_edit_rights))
	SSdbcore.MassInsert(format_table_name("mentor_ranks"), sql_ranks, duplicate_key = TRUE)

//load our rank - > rights associations
/proc/load_mentor_ranks(dbfail, no_update)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin Reload blocked: Advanced ProcCall detected.</span>", confidential = TRUE)
		return
	GLOB.mentor_ranks.Cut()
	GLOB.protected_mentor_ranks.Cut()
	GLOB.dementors.Cut()
	//load text from file and process each entry
	var/ranks_text = file2text("[global.config.directory]/mentor_ranks.txt")
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
		GLOB.protected_mentor_ranks += Rank
		previous_rank = Rank
	if(!CONFIG_GET(flag/mentor_legacy_system) || dbfail)
		if(CONFIG_GET(flag/load_legacy_ranks_only))
			if(!no_update)
				sync_mentor_ranks_with_db() // make a sync with mentor ranks proc
		else
			var/datum/db_query/query_load_mentor_ranks = SSdbcore.NewQuery("SELECT `rank`, flags, exclude_flags, can_edit_flags FROM [format_table_name("mentor_ranks")]")
			if(!query_load_mentor_ranks.Execute())
				message_admins("Error loading mentor ranks from database. Loading from backup.")
				log_sql("Error loading mentor ranks from database. Loading from backup.")
				dbfail = 1
			else
				while(query_load_mentor_ranks.NextRow())
					var/skip
					var/rank_name = query_load_mentor_ranks.item[1]
					for(var/datum/mentor_rank/R in GLOB.mentor_ranks)
						if(R.name == rank_name) //this rank was already loaded from txt override
							skip = 1
							break
					if(!skip)
						var/rank_flags = text2num(query_load_mentor_ranks.item[2])
						var/rank_exclude_flags = text2num(query_load_mentor_ranks.item[3])
						var/rank_can_edit_flags = text2num(query_load_mentor_ranks.item[4])
						var/datum/mentor_rank/R = new(rank_name, rank_flags, rank_exclude_flags, rank_can_edit_flags)
						if(!R)
							continue
						GLOB.mentor_ranks += R
			qdel(query_load_mentor_ranks)
	//load ranks from backup file
	if(dbfail)
		var/backup_file = file2text("data/mentors_backup.json")
		if(backup_file == null)
			log_world("Unable to locate mentors backup file.")
			return FALSE
		var/list/json = json_decode(backup_file)
		for(var/J in json["ranks"])
			var/skip
			for(var/datum/mentor_rank/R in GLOB.mentor_ranks)
				if(R.name == "[J]") //this rank was already loaded from txt override
					skip = TRUE
			if(skip)
				continue
			var/datum/mentor_rank/R = new("[J]", json["ranks"]["[J]"]["include rights"], json["ranks"]["[J]"]["exclude rights"], json["ranks"]["[J]"]["can edit rights"])
			if(!R)
				continue
			GLOB.mentor_ranks += R
		return json

/// Converts a rank name (such as "Coder+Moth") into a list of /datum/mentor_rank
/proc/mentor_ranks_from_rank_name(rank_name)
	var/list/rank_names = splittext(rank_name, "+")
	var/list/ranks = list()

	for (var/datum/mentor_rank/rank as anything in GLOB.mentor_ranks)
		if (rank.name in rank_names)
			rank_names -= rank.name
			ranks += rank

			if (!length(rank_names))
				break

	if (length(rank_names) > 0)
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
	//ckeys listed in mentors.txt are always made mentors before sql loading is attempted
	var/mentors_text = file2text("[global.config.directory]/mentors.txt")
	var/regex/mentors_regex = new(@"^(?!#)(\S+)(?:\s+=\s+(.+))?", "gm")

	while(mentors_regex.Find(mentors_text))
		var/mentor_key = mentors_regex.group[1]
		var/mentor_rank = mentors_regex.group[2]
		new /datum/mentors(mentor_ranks_from_rank_name(mentor_rank), ckey(mentor_key), force_active = FALSE, protected = TRUE)

	if(!CONFIG_GET(flag/mentor_legacy_system) || dbfail)
		var/datum/db_query/query_load_mentors = SSdbcore.NewQuery("SELECT ckey, `rank` FROM [format_table_name("mentor")] ORDER BY `rank`")
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

/// Reads contributor file and sets is_contributor if their ckey exists and they have a valid datum to store it.
/proc/load_contrib_status()
	for(var/coder in world.file2list("[global.config.directory]/contributors.txt"))
		var/key = ckey(coder)
		var/datum/mentors/contrib_mentor = GLOB.mentor_datums[key] || GLOB.dementors[key]
		if(istype(contrib_mentor))
			contrib_mentor.is_contributor = TRUE
