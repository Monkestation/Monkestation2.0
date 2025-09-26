GLOBAL_LIST_EMPTY(mentor_datums) // Active mentor datums
GLOBAL_PROTECT(mentor_datums)
GLOBAL_LIST_EMPTY(protected_mentors) // These appear to be anyone loaded from the config files
GLOBAL_PROTECT(protected_mentors)

GLOBAL_VAR_INIT(mentor_href_token, GenerateToken())
GLOBAL_PROTECT(mentor_href_token)

/datum/mentors
	var/list/datum/mentor_rank/ranks

	var/target // The Mentor's Ckey
	var/name = "nobody's mentor datum (no rank)" //Makes for better runtimes
	var/client/owner = null // The Mentor's Client

	/// href token for Mentor commands, uses the same token generator used by Admins.
	var/href_token

	var/dementored

	/// Are we a Contributor?
	var/is_contributor = FALSE

/datum/mentors/New(list/datum/mentor_rank/ranks, ckey, force_active = FALSE, protected) // Set this back to false after testing
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if (!target) //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of mentor datum")
		return
	if(!ckey)
		QDEL_IN(src, 0)
		CRASH("Admin datum created without a ckey")
	if(!istype(ranks))
		QDEL_IN(src, 0)
		CRASH("Mentor datum created with invalid ranks: [ranks] ([json_encode(ranks)])")
	target = ckey
	name = "[ckey]'s mentor datum ([join_mentor_ranks(ranks)])"
	src.ranks = isnull(ranks) ? NONE : ranks
	href_token = GenerateToken()
	if(protected)
		GLOB.protected_mentors[target] = src
	if(force_active || (rank_flags() & R_AUTOMENTOR))
		activate()
	else
		deactivate()

/datum/mentors/Destroy()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE
	. = ..()

/datum/mentors/proc/activate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.dementors -= target
	GLOB.mentor_datums[target] = src
	dementored = FALSE
	if (GLOB.directory[target])
		associate(GLOB.directory[target]) //find the client for a ckey if they are connected and associate them with us

/datum/mentors/proc/deactivate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	GLOB.dementors[target] = src
	GLOB.mentor_datums -= target

	dementored = TRUE

	var/client/client = owner || GLOB.directory[target]

	if (!isnull(client))
		disassociate()
		add_verb(client, /client/proc/rementor)
		client.update_special_keybinds()

/datum/mentors/proc/associate(client/client)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(!istype(client))
		return

	if(client?.ckey != target)
		var/msg = " has attempted to associate with [target]'s mentor datum"
		message_admins("[key_name_mentor(client)][msg]")
		log_admin("[key_name(client)][msg]")
		return

	if (dementored)
		activate()

//	remove_verb(client, /client/proc/admin_2fa_verify) // Mentors dont 2fa I think

	owner = client
	owner.mentor_datum = src
	owner.add_mentor_verbs()
	remove_verb(owner, /client/proc/rementor)
	owner.init_verbs() //re-initialize the verb list
	owner.update_special_keybinds()
	GLOB.mentors |= client

/datum/mentors/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	if(owner)
		GLOB.admins -= owner
		owner.remove_mentor_verbs()
		owner.mentor_datum = null
		owner = null

/// Will check to see if rank has at least one of the rights required.
/datum/mentors/proc/check_for_rights(rights_required)
	if(rights_required && !(rights_required & rank_flags()))
		return FALSE
	return TRUE

/// Will check to see if rank has exact rights required.
/datum/mentors/proc/check_for_exact_rights(rights_required)
	if(rights_required && ((rights_required & rank_flags()) != rights_required))
		return FALSE
	return TRUE

/// Get the rank flags of the mentor
/datum/mentors/proc/rank_flags()
	var/combined_flags = NONE

	for (var/datum/mentor_rank/rank as anything in ranks)
		combined_flags |= rank.rights

	return combined_flags

/// Get the rank name of the mentor
/datum/mentors/proc/rank_names()
	return join_mentor_ranks(ranks)

/proc/key_name_mentor(whom, include_link = null, include_name = TRUE, include_follow = TRUE, char_name_only = TRUE)
	var/mob/user
	var/client/chosen_client
	var/key
	var/ckey
	if(!whom)
		return "*null*"

	if(istype(whom, /client))
		chosen_client = whom
		user = chosen_client.mob
		key = chosen_client.key
		ckey = chosen_client.ckey
	else if(ismob(whom))
		user = whom
		chosen_client = user.client
		key = user.key
		ckey = user.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		chosen_client = GLOB.directory[ckey]
		if(chosen_client)
			user = chosen_client.mob
	else if(findtext(whom, "Discord"))
		return "<a href='byond://?_src_=mentor;mentor_msg=[whom];[MentorHrefToken(TRUE)]'>"
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = null

	if(key)
		if(include_link != null)
			. += "<a href='byond://?_src_=mentor;mentor_msg=[ckey];[MentorHrefToken(TRUE)]'>"

		if(chosen_client && chosen_client.holder && chosen_client.holder.fakekey)
			. += "Administrator"
		else
			. += key
		if(!chosen_client)
			. += "\[DC\]"

		if(include_link != null)
			. += "</a>"
	else
		. += "*no key*"

	if(include_follow)
		. += " (<a href='byond://?_src_=mentor;mentor_follow=[REF(user)];[MentorHrefToken(TRUE)]'>F</a>)"

	return .

/// This proc checks whether subject has at least ONE of the rights specified in rights_required.
/// NOTE: These will use mentor rights don't mix them with Admin rights.
/proc/check_mentor_rights_for(client/subject, rights_required)
	if(subject?.mentor_datum)
		return subject.mentor_datum.check_for_rights(rights_required)
	return FALSE

/// This proc checks whether subject has ALL of the rights specified in rights_required.
/// NOTE: These will use mentor rights don't mix them with Admin rights.
/proc/check_exact_mentor_rights_for(client/subject, rights_required)
	if(subject?.mentor_datum)
		return subject.mentor_datum.check_for_exact_rights(rights_required)
	return FALSE

/datum/mentors/proc/CheckMentorHREF(href, href_list)
	var/auth = href_list["mentor_token"]
	. = auth && (auth == href_token || auth == GLOB.mentor_href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(usr)] clicked an href with [msg] authorization key!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Debug mode enabled, call not blocked. Please ask your coders to review this round's logs.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")

/proc/RawMentorHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.mentor_href_token
	if(!forceGlobal && usr)
		var/client/client = usr.client
		if(!client)
			CRASH("No client for MentorHrefToken()!")
		var/datum/mentors/holder = client.mentor_datum
		if(holder)
			tok = holder.href_token
	return tok

/proc/MentorHrefToken(forceGlobal = FALSE)
	return "mentor_token=[RawMentorHrefToken(forceGlobal)]"

/// Mentor admins without mentor datums. Use after a mentor reload or similar.
/proc/MentorizeAdmins()
	//If an admin for some reason doesn't have a mentor datum create a deactivated one for them and assign.
	for(var/ckey in (GLOB.admin_datums + GLOB.deadmins))
		if(!(GLOB.mentor_datums[ckey] || GLOB.dementors[ckey]))
			var/datum/admins/some_admin = GLOB.admin_datums[ckey] || GLOB.deadmins[ckey]
			if(some_admin.check_for_rights(NONE))
				new /datum/mentors(mentor_ranks_from_rank_name("Staff Assigned Mentor"), ckey)
