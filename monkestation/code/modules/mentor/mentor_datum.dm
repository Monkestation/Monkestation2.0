GLOBAL_LIST_EMPTY(mentor_datums)
GLOBAL_PROTECT(mentor_datums)

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
	//var/mob/following
	/// Are we a Contributor?
	//var/is_contributor = FALSE

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
	src.ranks = ranks
	href_token = GenerateToken()
	if(force_active)
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
	//plane_debug = new(src) //DO we need? Mostly likely no.
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
	//QDEL_NULL(plane_debug)

	dementored = TRUE

	var/client/client = owner || GLOB.directory[target]

	if (!isnull(client))
		disassociate()
		add_verb(client, /client/proc/rementor)
		//client.disable_combo_hud()
		//client.update_special_keybinds()

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
	//owner.update_special_keybinds()
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

/datum/mentors/proc/check_for_rights(rights_required)
	if(rights_required && !(rights_required & rank_flags()))
		return FALSE
	return TRUE

/// Get the rank flags of the mentor
/datum/mentors/proc/rank_flags()
	var/combined_flags = NONE

	for (var/datum/mentor_rank/rank as anything in ranks)
		combined_flags |= rank.rights

	return combined_flags

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
/*
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
*/
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

		//if(chosen_client && chosen_client.holder && chosen_client.holder.fakekey)
		//	. += "Administrator"
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

/proc/RawMentorHrefToken(forceGlobal = FALSE)
	var/tok = GLOB.mentor_href_token
	if(!forceGlobal && usr)
		var/client/client = usr.client
		//to_chat(world, client) // Dont see a reason to have these here.
		//to_chat(world, usr)
		if(!client)
			CRASH("No client for MentorHrefToken()!")
		var/datum/mentors/holder = client.mentor_datum
		if(holder)
			tok = holder.href_token
	return tok

/proc/MentorHrefToken(forceGlobal = FALSE)
	return "mentor_token=[RawMentorHrefToken(forceGlobal)]"
