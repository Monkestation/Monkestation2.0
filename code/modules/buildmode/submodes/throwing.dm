/datum/buildmode_mode/throwing
	key = "throw"

	var/atom/movable/throw_atom = null

/datum/buildmode_mode/throwing/Destroy()
	unset_target()
	return ..()

/datum/buildmode_mode/throwing/show_help(client/user)
	to_chat(user, span_notice("***********************************************************"))
	to_chat(user, span_notice("Left Mouse Button on obj/mob           = Select"))
	to_chat(user, span_notice("Right Mouse Button on turf/obj/mob     = Throw"))
	to_chat(user, span_notice("***********************************************************"))

/datum/buildmode_mode/throwing/handle_click(client/user, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(set_target(object))
			to_chat(user, span_notice("Selected object '[throw_atom]'"))
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!QDELETED(throw_atom))
			throw_atom.throw_at(object, 10, 1, user.mob)
			log_admin("Build Mode: [key_name(user)] threw [throw_atom] at [object] ([AREACOORD(object)])")

/datum/buildmode_mode/throwing/proc/set_target(atom/movable/new_target)
	if(!ismovable(new_target) || QDELING(new_target))
		return FALSE
	if(new_target == throw_atom)
		return TRUE // just to avoid confusing if you click repeatedly on the same thing
	unset_target()
	RegisterSignal(new_target, COMSIG_QDELETING, PROC_REF(unset_target))
	throw_atom = new_target
	return TRUE

/datum/buildmode_mode/throwing/proc/unset_target()
	SIGNAL_HANDLER
	if(isnull(throw_atom))
		return
	UnregisterSignal(throw_atom, COMSIG_QDELETING)
	throw_atom = null
