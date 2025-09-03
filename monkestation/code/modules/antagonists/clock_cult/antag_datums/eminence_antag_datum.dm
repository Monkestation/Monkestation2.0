/datum/antagonist/clock_cultist/eminence
	name = "Eminence"
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_IGNORE
	give_slab = FALSE
	antag_moodlet = null
	communicate = null
	recall = null
	///The list of our actions
	var/list/action_list = list(
		/datum/action/innate/clockcult/space_fold,
		/datum/action/cooldown/clock_cult/eminence/purge_reagents,
		/datum/action/cooldown/clock_cult/eminence/linked_abscond,
		/datum/action/innate/clockcult/teleport_to_servant,
		/datum/action/innate/clockcult/teleport_to_station,
		/datum/action/innate/clockcult/eminence_abscond,
		/datum/action/innate/clockcult/show_warpable_areas,
		/datum/action/innate/clockcult/add_warp_area,
	)

/datum/antagonist/clock_cultist/eminence/Destroy()
	QDEL_LIST(action_list)
	return ..()

/datum/antagonist/clock_cultist/eminence/greet()
	to_chat(owner.current, boxed_message("[span_bigbrass("You are the Eminence, a being bound to Rat'var. By his light you are able to influence nearby space and time.")] <br/>\
								[span_brass("As the Eminence you have access to various abilities, they are as follows. <br/>\
								You may click on various machines to interface with them or a servant to mark them. <br/>\
								Purge Reagents: Remove all reagents from the bloodstream of a marked servant, this is useful for a servant who is being deconverted by holy water. <br/>\
								Linked Abscond: Return a marked servant and anything they are pulling to reebe, this has a lengthy cooldown and they must remain still for 7 seconds. <br/>\
								Space Fold: Fold local spacetime to ensure certain \"events\" are inflicted upon the station, while doing this will cost cogs, \
								these cogs are not taken from the cult itself. The cooldown is based on the cog cost of the event. <br/>\
								You can also teleport yourself to any other servant, useful for servants who need to be absconded like those which are dead or being deconverted.")]"))

/datum/antagonist/clock_cultist/eminence/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	add_team_hud(current, /datum/antagonist/clock_cultist)
	for(var/datum/action/our_action as anything in action_list)
		if(ispath(our_action))
			our_action = new our_action()
		our_action.Grant(current)

/datum/antagonist/clock_cultist/eminence/remove_innate_effects(mob/living/mob_override)
	. = ..()
	for(var/datum/action/removed_action in action_list)
		removed_action.Remove(owner.current)

/datum/antagonist/clock_cultist/eminence/on_removal() //this should never happen without an admin being involved, something has gone wrong
	to_chat(owner.current, span_userdanger("You lost your eminence antagonist status! This should not happen and you should ahelp(f1) unless you are already talking to an admin."))
	return ..()
