/datum/action/cooldown/clock_cult/eminence/purge_reagents
	name = "Purge Reagents"
	desc = "Purges all reagents from the bloodstream of a marked servant, useful for if they have been given holy water."
	button_icon_state = "Mending Mantra"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/clock_cult/eminence/purge_reagents/Activate(atom/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/eminence/em_user = usr
	var/mob/living/purged = WEAKREF_NULL_IF_UNRESOLVED(em_user.marked_servant, purged)
	if(!purged)
		to_chat(em_user, span_notice("You dont currently have a marked servant!"))
		return FALSE

	var/did_purge = FALSE
	for(var/datum/reagent/chem in purged.reagents?.reagent_list)
		purged.reagents.remove_reagent(chem.type, chem.volume)
		did_purge = TRUE

	em_user.marked_servant = null
	if(!did_purge)
		to_chat(em_user, span_notice("[purged] does not have any reagents to purge."))
		return FALSE

	to_chat(em_user, "You purge the reagents of [purged].")
	return TRUE
