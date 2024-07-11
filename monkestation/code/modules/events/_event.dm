/datum/round_event_control
	var/managed = FALSE
	var/oh_god = FALSE

/datum/round_event_control/proc/oh_shit_oh_fuck()
	SIGNAL_HANDLER
	if(managed)
		oh_god = TRUE
		stack_trace("ANERI DEBUG: [type] ([src]) is a managed event that's being deleted!!! this is bad!!!")
		message_admins("ANERI DEBUG: [type] ([src]) is a managed event that's being deleted!!! this is bad!!! tell borbop and/or absolucy ASAP!!! tell borbop and/or absolucy ASAP!!!")
