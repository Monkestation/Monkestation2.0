///As it turns out, lists are a pain to protect in BYOND as we dont actually have any direct control over their logic.
///Thus, the protected list manager.
///It provides a way to protect a list from outside interference(such as admin meddling)
///Please note this system is built for security over speed, so it should only be used if ABSOLUTELY NECESSARY.
///This is the manager singleton, if you want to create a new protected list then do `new /datum/protected_list_holder(list_value, list_owner)`
/datum/controller/protected_list_manager
	///Have we initialized
	var/initialized = FALSE

/datum/controller/protected_list_manager/New()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call [src].New()!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if(!initialized) //only del if this is a true creation (and not just a New() proc call) so as to ensure this cant be used to null protected lists
			qdel(src, TRUE)
			CRASH("Admin proc call creation of admin datum")
		return

	var/static/list/protected_lists
	if(!protected_lists)
		protected_lists = list()
	get_protected(protected_lists)
	has_value(null, protected_lists)
	initialized = TRUE

/datum/controller/protected_list_manager/Destroy(force)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to delete a protected list handler!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE
	if(!force)
		stack_trace("protected_list_manager calling Destroy() without force being set.")
		return QDEL_HINT_LETMELIVE
	return ..()

///Returns our protected lists
/datum/controller/protected_list_manager/proc/get_protected(list/list_ref) as /list
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call get_protected() on the protected list manager!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(caller.src != src) //should only be used internally
		CRASH("[src].get_protected() called by [caller]([caller.src])")

	var/static/list/protected_lists
	if(list_ref)
		protected_lists = list_ref
	return protected_lists

///Returns a copy of the list assigned to the passed key
/datum/controller/protected_list_manager/proc/read_list(datum/protected_list_holder/key) as /list
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call read_list() on the protected list manager!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(!key)
		CRASH("[src].read_list() called without a key(passed key: [key])")

	if(caller.src != key)
		CRASH("[src].read_list() called by something besides the passed key([caller.src])")

	var/list/returned_list = get_protected()[key]
	if(!returned_list)
		CRASH("[src].read_list() called with an invalid key(passed key: [key])")
	return returned_list.Copy()

///Update the value of a stored list, also how you null a list
/datum/controller/protected_list_manager/proc/update_list(datum/protected_list_holder/key, list/new_value)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call update_list() on the protected list manager!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(!key)
		CRASH("[src].update_list() called without a key(passed key: [key])")

	if(caller.src != key)
		CRASH("[src].read_list() called by something besides the passed key([caller.src])")

	var/list/protected = get_protected()
	if(isnull(new_value))
		protected -= key
		return
	protected[key] = new_value

///Returns a bool of if a passed key has a value or not, does NOT check for admin call
/datum/controller/protected_list_manager/proc/has_value(datum/protected_list_holder/key, list/list_ref)
	var/static/list/protected_lists
	if(list_ref)
		if(caller.src != src)
			CRASH("[src].read_list() called by [caller]([caller.src]) with a set list_ref")
		protected_lists = list_ref
		return
	return !!protected_lists[key]

/*///The proc we store our lists within
/datum/controller/protected_list_manager/proc/storage_loop(list/passed_list)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call storage_loop() on the protected list manager!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	var/static/is_running
	if(is_running)
		CRASH("[src].storage_loop() called when already running.")

	is_running = TRUE
	src = null //we handle stopping ourselves if parent is deleted so as to ensure is_running gets set correctly
	var/static/list/protected_lists
	if(!isnull(passed_list))
		protected_lists = passed_list

	while(TRUE)
		if(isnull(caller?.src)) //this means src got deleted, make sure to set is_running to FALSE then kill our current run
			is_running = FALSE
			return

/datum/controller/protected_list_manager/proc/get_value_updates()

///Return the ref to our list after some checks
/datum/controller/protected_list_manager/proc/get_value()
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to get the value of a protected list handler!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(usr) //this ensures we are only being accessed through
		return*/

GENERAL_PROTECT_DATUM(/datum/controller/protected_list_manager)

//if testing then we allow access to the datum
#ifndef TESTING
/datum/controller/protected_list_manager/vv_do_topic(list/href_list)
	return FALSE

/datum/controller/protected_list_manager/vv_get_var(var_name)
	return "Protected Variable"

/datum/controller/protected_list_manager/vv_get_dropdown()
	SHOULD_CALL_PARENT(FALSE)
	return list()

/datum/controller/protected_list_manager/vv_get_header()
	return list()
#endif


///Used to track a specific protected list, you should set the list your replacing to an instance of this
/datum/protected_list_holder
	///The protected list manager
	var/static/datum/controller/protected_list_manager/manager = new
	///Ref to our owner, restricts what can access this if set
	var/datum/owner

/datum/protected_list_holder/New(list/our_list = list(), datum/owner)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call [src].New()!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		if(!manager?.has_value(src))
			qdel(src, TRUE)
		return

	if(isnull(our_list))
		qdel(src)
		CRASH("protected_list_holder New() called with null our_list")
	src.owner = owner
	update_value(our_list)

/datum/protected_list_holder/Destroy(force)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call Destroy() on [src]!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return QDEL_HINT_LETMELIVE

	//this is dumb and bad and should just be a recursive call but opendream cant compile it as a recursive so we need to do this instead
	var/callee/our_caller = caller.caller
	if(owner && our_caller.src != owner)
		stack_trace("protected_list_holder qdeleted by something([our_caller.src]) not its owner([owner])")
		return QDEL_HINT_LETMELIVE
	update_value(null)
	return ..()

///Return the a copy of our assigned list
/datum/protected_list_holder/proc/Value() as /list
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call [src].Value()!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(owner && caller.src != owner) //we call CRASH() as you should not have code that is able to access a list it does not own
		CRASH("[src].Value() called by something([caller.src]) not its owener([owner])")
	return manager.read_list(src)

///Update the value of our assigned list
/datum/protected_list_holder/proc/update_value(list/new_value)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to call [src].update_value()!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(caller.src != src && (owner && caller.src != owner)) //same as above
		CRASH("[src].update_value() called by something([caller.src]) not its owener([owner])")

	if(!gc_destroyed && isnull(new_value))
		CRASH("[src].update_value called with a null new_value, qdel the holder instead")
	manager.update_list(src, new_value)

GENERAL_PROTECT_DATUM(/datum/protected_list_holder)

//if testing then we allow access to the datum
#ifndef TESTING
/datum/protected_list_holder/vv_do_topic(list/href_list)
	return FALSE

/datum/protected_list_holder/vv_get_var(var_name)
	return "Protected Variable"

/datum/protected_list_holder/vv_get_dropdown()
	SHOULD_CALL_PARENT(FALSE)
	return list()

/datum/protected_list_holder/vv_get_header()
	return list()
#endif
