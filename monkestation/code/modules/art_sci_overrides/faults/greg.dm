/datum/artifact_fault/greg
	name = "Greg Fault"
	discovered_credits = 250
	research_value = 1000
	trigger_chance = 1

/datum/artifact_fault/greg/on_added(datum/component/artifact/component)
	component.holder.AddComponent(/datum/component/spirit_holding,component.holder)

/datum/artifact_fault/greg/on_trigger(datum/component/artifact/component)
	var/datum/component/spirit_holding/spiritholder = component.GetComponent(/datum/component/spirit_holding)
	if(!(spiritholder.bound_spirit.client))
		var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as [component.holder]",
		check_jobban = ROLE_SENTIENCE,
		poll_time = 15 SECONDS,
		ignore_category = POLL_IGNORE_SHADE,
		alert_pic = component.holder,
		role_name_text = "[component.holder]",
	)
		if(!LAZYLEN(candidates))
			return
		var/mob/dead/observer/chosen_spirit = pick(candidates)
		spiritholder.bound_spirit = new(component.holder)
		spiritholder.bound_spirit.ckey = chosen_spirit.ckey
		spiritholder.bound_spirit.fully_replace_character_name(null, "[component.holder]")
		spiritholder.bound_spirit.status_flags |= GODMODE
		spiritholder.bound_spirit.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue
		spiritholder.bound_spirit.update_atom_languages()

