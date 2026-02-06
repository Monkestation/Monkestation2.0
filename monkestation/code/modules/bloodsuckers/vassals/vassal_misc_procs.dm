/datum/antagonist/vassal/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(vassal_warning_message)
		to_chat(owner, vassal_warning_message)

/**
 * Returns a Vassals's examine strings.
 * Args:
 * viewer - The person examining.
 */
/datum/antagonist/vassal/proc/return_vassal_examine(mob/living/viewer)
	if(!viewer.mind || !iscarbon(owner.current))
		return FALSE
	var/mob/living/carbon/carbon_current = owner.current
	// Target must be a Vassal
	// Vassals and Bloodsuckers recognize eachother, while Monster Hunters can see Vassals.
	if(!HAS_MIND_TRAIT(viewer, TRAIT_BLOODSUCKER_ALIGNED) && !IS_MONSTERHUNTER(viewer))
		return FALSE
	// Default String
	var/return_info
	var/return_state
	var/species_name = carbon_current.dna?.species?.name || initial(carbon_current.name)
	// Am I Viewer's Vassal?
	if(master.owner == viewer.mind)
		return_info = "This [species_name] bears YOUR mark!"
		return_state = "vassal"
	// Am I someone ELSE'S Vassal?
	else if(IS_BLOODSUCKER(viewer) || IS_MONSTERHUNTER(viewer))
		return_info = "This [species_name] bears the mark of <b>[master.return_full_name()][master.broke_masquerade ? " who has broken the Masquerade" : ""]</b>"
		return_state = "vassal_grey"
	// Are you serving the same master as I am?
	else if(viewer.mind.has_antag_datum(/datum/antagonist/vassal) in master.vassals)
		return_info = "[p_They()] bear[p_s()] the mark of your Master"
		return_state = "vassal"
	// You serve a different Master than I do.
	else
		return_info = "[p_They()] bear[p_s()] the mark of another Bloodsucker"
		return_state = "vassal_grey"

	var/img_html = "<img class='icon' src='\ref['monkestation/icons/bloodsuckers/vampiric.dmi']?state=[return_state]'></img>"
	return "\[" + span_warning("[img_html] [return_info]") + "\]"

/// Used when your Master teaches you a new Power.
/datum/antagonist/vassal/proc/BuyPower(datum/action/cooldown/bloodsucker/power)
	powers += power
	power.Grant(owner.current)
	log_uplink("[key_name(owner.current)] gained [power].")

/datum/antagonist/vassal/proc/RemovePower(datum/action/cooldown/bloodsucker/power)
	if(power.active)
		power.DeactivatePower()
	powers -= power
	power.Remove(owner.current)

/// Called when we are made into the Favorite Vassal
/datum/antagonist/vassal/proc/make_special(datum/antagonist/vassal/vassal_type)
	//store what we need
	var/datum/mind/vassal_owner = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = master

	//remove our antag datum
	silent = TRUE
	vassal_owner.remove_antag_datum(/datum/antagonist/vassal)

	//give our new one
	var/datum/antagonist/vassal/vassaldatum = new vassal_type(vassal_owner)
	vassaldatum.master = bloodsuckerdatum
	vassaldatum.silent = TRUE
	vassal_owner.add_antag_datum(vassaldatum)
	vassaldatum.silent = FALSE

	//send alerts of completion
	to_chat(master, span_danger("You have turned [vassal_owner.current] into your [vassaldatum.name]!"))
	to_chat(vassal_owner, span_notice("As Blood drips over your body, you feel closer to your Master... You are now the [vassaldatum.name]!"))
	vassal_owner.current.playsound_local(null, 'sound/magic/mutate.ogg', vol = 75, vary = FALSE, pressure_affected = FALSE)
