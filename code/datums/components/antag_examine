/datum/component/mycomponent
	//dupe_mode = COMPONENT_DUPE_ALLOWED    // code/__DEFINES/dcs/flags.dm
	var/examine_result
  var/datums_allowed

/datum/component/mycomponent/Initialize(myargone, myargtwo)
	if(myargone)
		myvar = myargone
	if(myargtwo)
		send_to_playing_players(myargtwo)

/datum/component/antag_examine/RegisterWithParent()
  	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/antag_examine/UnregisterFromParent()
	  UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/datum/component/antag_examine/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
  for
	examine_list += span_danger("[source.p_theyre(TRUE)] covered in a corrosive liquid!")
