/datum/artifact_fault/greg
	name = "Greg Fault"
	discovered_credits = 250
	research_value = 1000
	trigger_chance = 5

/datum/artifact_fault/greg/on_added()
	our_artifact.holder.AddComponent(/datum/component/spirit_holding,our_artifact.holder)

/datum/artifact_fault/greg/on_trigger()
	var/datum/component/spirit_holding/spiritholder = our_artifact.GetComponent(/datum/component/spirit_holding)
	if(!(spiritholder.bound_spirit.client))
		var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as [our_artifact.holder]",
		check_jobban = ROLE_SENTIENCE,
		poll_time = 15 SECONDS,
		ignore_category = POLL_IGNORE_SHADE,
		alert_pic = our_artifact.holder,
		role_name_text = "[our_artifact.holder]",
	)
		if(!LAZYLEN(candidates))
			return
		var/mob/dead/observer/chosen_spirit = pick(candidates)
		spiritholder.bound_spirit = new(our_artifact.holder)
		spiritholder.bound_spirit.ckey = chosen_spirit.ckey
		spiritholder.bound_spirit.fully_replace_character_name(null, "[our_artifact.holder]")
		spiritholder.bound_spirit.status_flags |= GODMODE
		spiritholder.bound_spirit.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue
		spiritholder.bound_spirit.update_atom_languages()

