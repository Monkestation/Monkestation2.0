/datum/component/antag_examine
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/examine_result = "This is a default antag-datum exclusive message. If you see this anywhere, *especially* if you aren't a traitor (the default datum this message should be exclusive to), please report it. Something has royally fucked up."
	var/datums_allowed = list(/datum/antagonist/traitor)

/datum/component/antag_examine/Initialize(message, allowed_datums)
	if(message)
		examine_result = message
	if(allowed_datums)
		datums_allowed = allowed_datums

/datum/component/antag_examine/RegisterWithParent()
  	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/antag_examine/UnregisterFromParent()
	  UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/datum/component/antag_examine/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/isgood = FALSE
	for thingy in datums_allowed
		if(user?.mind?.has_antag_datum(thingy))
			isgood = TRUE
	if(isgood)
		examine_list += examine_result
