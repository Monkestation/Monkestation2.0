GENERAL_PROTECT_DATUM(/datum/controller/subsystem/admin_verbs)

SUBSYSTEM_DEF(admin_verbs)
	name = "Admin/Mentor Verbs" // MONKE EDIT
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ADMIN_VERBS
	/// A list of all admin verbs indexed by their type.
	var/list/datum/admin_verb/admin_verbs_by_type = list()
	/// A list of all admin verbs indexed by their visibility flag.
	var/list/list/datum/admin_verb/admin_verbs_by_visibility_flag = list()
	/// A map of all assosciated admins and their visibility flags.
	var/list/admin_visibility_flags = list()
	/// A list of all admins that are pending initialization of this SS.
	var/list/admins_pending_subsytem_init = list()

	//MONKE EDIT START All mentor related verb lists.
	/// A list of all mentor verbs indexed by their type.
	var/list/datum/mentor_verb/mentor_verbs_by_type = list()
	/// A list of all mentor verbs indexed by their visibility flag.
	var/list/list/datum/mentor_verb/mentor_verbs_by_visibility_flag = list()
	/// A map of all assosciated admins and their visibility flags.
	var/list/mentor_visibility_flags = list()
	/// A list of all mentor that are pending initialization of this SS.
	var/list/mentors_pending_subsytem_init = list()
	//MONKE EDIT END

/datum/controller/subsystem/admin_verbs/Initialize()
	setup_verb_list()
	process_pending_admins()
	process_pending_mentors() // Always process mentors second in most systems including here.
	return SS_INIT_SUCCESS

/datum/controller/subsystem/admin_verbs/Recover()
	admin_verbs_by_type = SSadmin_verbs.admin_verbs_by_type
	mentor_verbs_by_type = SSadmin_verbs.mentor_verbs_by_type // MONKE EDIT

/datum/controller/subsystem/admin_verbs/stat_entry(msg)
//MONKE EDIT START Having it report offline is confusing. So if it initialized it initialized.
	. = ..()
	if(initialized)
		. = "Initialized | AV: [length(admin_verbs_by_type)] | MV: [length(mentor_verbs_by_type)]"
	return .
//MONKE EDIT END

/datum/controller/subsystem/admin_verbs/proc/process_pending_admins()
	var/list/pending_admins = admins_pending_subsytem_init
	admins_pending_subsytem_init = null
	for(var/admin_ckey in pending_admins)
		assosciate_admin(GLOB.directory[admin_ckey])

/datum/controller/subsystem/admin_verbs/proc/setup_verb_list()
	if(length(admin_verbs_by_type))
		CRASH("Attempting to setup admin verbs twice!")
	for(var/datum/admin_verb/verb_type as anything in subtypesof(/datum/admin_verb))
		var/datum/admin_verb/verb_singleton = new verb_type
		if(!verb_singleton.__avd_check_should_exist())
			qdel(verb_singleton, force = TRUE)
			continue

		admin_verbs_by_type[verb_type] = verb_singleton
		if(verb_singleton.visibility_flag)
			if(!(verb_singleton.visibility_flag in admin_verbs_by_visibility_flag))
				admin_verbs_by_visibility_flag[verb_singleton.visibility_flag] = list()
			admin_verbs_by_visibility_flag[verb_singleton.visibility_flag] |= list(verb_singleton)

	//MONKE EDIT START loading mentor verbs
	if(length(mentor_verbs_by_type))
		CRASH("Attempting to setup mentor verbs twice!")
	for(var/datum/mentor_verb/verb_type as anything in subtypesof(/datum/mentor_verb))
		var/datum/mentor_verb/verb_singleton = new verb_type
		if(!verb_singleton.__avd_check_should_exist())
			qdel(verb_singleton, force = TRUE)
			continue

		mentor_verbs_by_type[verb_type] = verb_singleton
		if(verb_singleton.visibility_flag)
			if(!(verb_singleton.visibility_flag in mentor_verbs_by_visibility_flag))
				mentor_verbs_by_visibility_flag[verb_singleton.visibility_flag] = list()
			mentor_verbs_by_visibility_flag[verb_singleton.visibility_flag] |= list(verb_singleton)
	//MONKE EDIT END

/datum/controller/subsystem/admin_verbs/proc/get_valid_verbs_for_admin(client/admin)
	if(isnull(admin.holder))
		CRASH("Holder containing admin datums was empty. Is [admin] a valid client or admin?") //MONKE EDIT

	var/list/has_permission = list()
	for(var/permission_flag in GLOB.bitflags)
		if(admin.holder.check_for_rights(permission_flag))
			has_permission["[permission_flag]"] = TRUE

	var/list/valid_verbs = list()
	for(var/datum/admin_verb/verb_type as anything in admin_verbs_by_type)
		var/datum/admin_verb/verb_singleton = admin_verbs_by_type[verb_type]
		if(!verify_visibility(admin, verb_singleton))
			continue

		var/verb_permissions = verb_singleton.permissions
		if(verb_permissions == R_NONE)
			valid_verbs |= list(verb_singleton)
		else if(verb_type.match_exact_permissions)
			if(!admin.holder.check_for_exact_rights(verb_permissions))
				continue
			valid_verbs |= list(verb_singleton)
		else for(var/permission_flag in bitfield_to_list(verb_permissions))
			if(!has_permission["[permission_flag]"])
				continue
			valid_verbs |= list(verb_singleton)

	return valid_verbs

/datum/controller/subsystem/admin_verbs/proc/verify_visibility(client/admin, datum/admin_verb/verb_singleton)
	var/needed_flag = verb_singleton.visibility_flag
	return !needed_flag || (needed_flag in admin_visibility_flags[admin.ckey])

/datum/controller/subsystem/admin_verbs/proc/update_visibility_flag(client/admin, flag, state)
	if(state)
		admin_visibility_flags[admin.ckey] |= list(flag)
		assosciate_admin(admin)
		return

	admin_visibility_flags[admin.ckey] -= list(flag)
	// they lost the flag, iterate over verbs with that flag and yoink em
	for(var/datum/admin_verb/verb_singleton as anything in admin_verbs_by_visibility_flag[flag])
		verb_singleton.unassign_from_client(admin)
	admin.init_verbs()

/datum/controller/subsystem/admin_verbs/proc/dynamic_invoke_verb(client/admin, datum/admin_verb/verb_type, ...)
	if(IsAdminAdvancedProcCall())
		message_admins("PERMISSION ELEVATION: [key_name_admin(admin)] attempted to dynamically invoke admin verb '[verb_type]'.")
		return

	if(ismob(admin))
		var/mob/mob = admin
		admin = mob.client

	if(!ispath(verb_type, /datum/admin_verb) || verb_type == /datum/admin_verb)
		CRASH("Attempted to dynamically invoke admin verb with invalid typepath '[verb_type]'.")
	if(isnull(admin.holder))
		CRASH("Attempted to dynamically invoke admin verb '[verb_type]' with a non-admin.")

	var/list/verb_args = args.Copy()
	verb_args.Cut(2, 3)
	var/datum/admin_verb/verb_singleton = admin_verbs_by_type[verb_type] // this cannot be typed because we need to use `:`
	if(isnull(verb_singleton))
		CRASH("Attempted to dynamically invoke admin verb '[verb_type]' that doesn't exist.")

	if(!admin.holder.check_for_rights(verb_singleton.permissions))
		to_chat(admin, span_adminnotice("You lack the permissions to do this."))
		return

	var/old_usr = usr
	usr = admin.mob
	// THE MACRO ENSURES THIS EXISTS. IF IT EVER DOESNT EXIST SOMEONE DIDNT USE THE DAMN MACRO!
	verb_singleton.__avd_do_verb(arglist(verb_args))
	usr = old_usr
	SSblackbox.record_feedback("tally", "dynamic_admin_verb_invocation", 1, "[verb_type]")

/**
 * Assosciates and/or resyncs an admin with their accessible admin verbs.
 */
/datum/controller/subsystem/admin_verbs/proc/assosciate_admin(client/admin)
	if(IsAdminAdvancedProcCall())
		return

	if(!isnull(admins_pending_subsytem_init)) // if the list exists we are still initializing
		to_chat(admin, span_big(span_green("Admin Verbs are still initializing. Please wait and you will be automatically assigned your verbs when it is complete.")))
		admins_pending_subsytem_init |= list(admin.ckey)
		return

	// refresh their verbs
	admin_visibility_flags[admin.ckey] ||= list()
	for(var/datum/admin_verb/verb_singleton as anything in get_valid_verbs_for_admin(admin))
		verb_singleton.assign_to_client(admin)
	admin.init_verbs()

/**
 * Unassosciates an admin from their admin verbs.
 * Goes over all admin verbs because we don't know which ones are assigned to the admin's mob without a bunch of extra bookkeeping.
 * This might be a performance issue in the future if we have a lot of admin verbs.
 */
/datum/controller/subsystem/admin_verbs/proc/deassosciate_admin(client/admin)
	if(IsAdminAdvancedProcCall())
		return

	UnregisterSignal(admin, COMSIG_CLIENT_MOB_LOGIN)
	for(var/datum/admin_verb/verb_type as anything in admin_verbs_by_type)
		admin_verbs_by_type[verb_type].unassign_from_client(admin)
	admin_visibility_flags -= list(admin.ckey)


///MENTOR VERB PROCS START HERE
/datum/controller/subsystem/admin_verbs/proc/process_pending_mentors()
	load_contrib_status() //By the time we reach here mentor datums are already created. Give them their special flag.
	var/list/pending_mentors = mentors_pending_subsytem_init
	mentors_pending_subsytem_init = null
	for(var/mentor_ckey in pending_mentors)
		assosciate_mentor(GLOB.directory[mentor_ckey])

/datum/controller/subsystem/admin_verbs/proc/verify_mentor_visibility(client/mentor, datum/mentor_verb/verb_singleton)
	var/needed_flag = verb_singleton.visibility_flag
	return !needed_flag || (needed_flag in mentor_visibility_flags[mentor.ckey])

/datum/controller/subsystem/admin_verbs/proc/update_mentor_visibility_flag(client/mentor, flag, state)
	if(state)
		mentor_visibility_flags[mentor.ckey] |= list(flag)
		assosciate_mentor(mentor)
		return

	mentor_visibility_flags[mentor.ckey] -= list(flag)
	// they lost the flag, iterate over verbs with that flag and yoink em
	for(var/datum/mentor_verb/verb_singleton as anything in mentor_verbs_by_visibility_flag[flag])
		verb_singleton.unassign_from_client(mentor)
	mentor.init_verbs()

/datum/controller/subsystem/admin_verbs/proc/dynamic_invoke_mentor_verb(client/mentor, datum/mentor_verb/verb_type, ...)
	if(IsAdminAdvancedProcCall())
		message_admins("PERMISSION ELEVATION: [key_name_admin(mentor)] attempted to dynamically invoke mentor verb '[verb_type]'.")
		return

	if(ismob(mentor))
		var/mob/mob = mentor
		mentor = mob.client

	if(!ispath(verb_type, /datum/mentor_verb) || verb_type == /datum/mentor_verb)
		CRASH("Attempted to dynamically invoke mentor verb with invalid typepath '[verb_type]'.")
	if(isnull(mentor.mentor_datum))
		CRASH("Attempted to dynamically invoke mentor verb '[verb_type]' with a non-mentor.")

	var/list/verb_args = args.Copy()
	verb_args.Cut(2, 3)
	var/datum/mentor_verb/verb_singleton = mentor_verbs_by_type[verb_type] // this cannot be typed because we need to use `:`
	if(isnull(verb_singleton))
		CRASH("Attempted to dynamically invoke mentor verb '[verb_type]' that doesn't exist.")

	if(!mentor.mentor_datum.check_for_rights(verb_singleton.permissions))
		to_chat(mentor, span_adminnotice("You lack the permissions to do this."))
		return

	var/old_usr = usr
	usr = mentor.mob
	// THE MACRO ENSURES THIS EXISTS. IF IT EVER DOESNT EXIST SOMEONE DIDNT USE THE DAMN MACRO!
	verb_singleton.__avd_do_verb(arglist(verb_args))
	usr = old_usr
	SSblackbox.record_feedback("tally", "dynamic_mentor_verb_invocation", 1, "[verb_type]")

/datum/controller/subsystem/admin_verbs/proc/get_valid_verbs_for_mentor(client/mentor)
	if(isnull(mentor.mentor_datum))
		CRASH("Holder containing mentor datums was empty. Is [mentor] a valid client or mentor?")

	var/list/has_permission = list()
	for(var/permission_flag in GLOB.bitflags)
		if(mentor.mentor_datum.check_for_rights(permission_flag))
			has_permission["[permission_flag]"] = TRUE

	var/list/valid_verbs = list()
	for(var/datum/mentor_verb/verb_type as anything in mentor_verbs_by_type)
		var/datum/mentor_verb/verb_singleton = mentor_verbs_by_type[verb_type]
		if(!verify_mentor_visibility(mentor, verb_singleton))
			continue

		var/verb_permissions = verb_singleton.permissions
		if(verb_permissions == R_NONE)
			valid_verbs |= list(verb_singleton)
		else if(verb_type.match_exact_permissions)
			if(!mentor.mentor_datum.check_for_exact_rights(verb_permissions))
				continue
			valid_verbs |= list(verb_singleton)
		else for(var/permission_flag in bitfield_to_list(verb_permissions))
			if(!has_permission["[permission_flag]"])
				continue
			valid_verbs |= list(verb_singleton)

	return valid_verbs

/**
 * Assosciates and/or resyncs a mentor with their accessible mentor verbs.
 */
/datum/controller/subsystem/admin_verbs/proc/assosciate_mentor(client/mentor)
	if(IsAdminAdvancedProcCall())
		return

	if(!isnull(mentors_pending_subsytem_init)) // if the list exists we are still initializing
		to_chat(mentor, span_big(span_green("Mentor Verbs are still initializing. Please wait and you will be automatically assigned your verbs when it is complete.")))
		mentors_pending_subsytem_init |= list(mentor.ckey)
		return

	// refresh their verbs
	mentor_visibility_flags[mentor.ckey] ||= list()
	for(var/datum/mentor_verb/verb_singleton as anything in get_valid_verbs_for_mentor(mentor))
		verb_singleton.assign_to_client(mentor)
	mentor.init_verbs()

/**
 * Unassosciates a mentor from their mentor verbs.
 * Goes over all mentor verbs because we don't know which ones are assigned to the mentor's mob without a bunch of extra bookkeeping.
 * This might be a performance issue in the future if we have a lot of mentor verbs.
 */
/datum/controller/subsystem/admin_verbs/proc/deassosciate_mentor(client/mentor)
	if(IsAdminAdvancedProcCall())
		return

	UnregisterSignal(mentor, COMSIG_CLIENT_MOB_LOGIN) // What is the implications of this?
	for(var/datum/mentor_verb/verb_type as anything in mentor_verbs_by_type)
		mentor_verbs_by_type[verb_type].unassign_from_client(mentor)
	mentor_visibility_flags -= list(mentor.ckey)
