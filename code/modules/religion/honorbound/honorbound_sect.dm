/datum/religion_sect/honorbound
	name = "Honorbound"
	quote = "A good, honorable crusade against evil is required."
	desc = "Your deity requires fair fights from you. You may not attack the unready, the just, or the innocent. \
	You earn favor by getting others to join the crusade, and you may spend favor to announce a battle, bypassing some conditions to attack."
	tgui_icon = "scroll"
	altar_icon_state = "convertaltar-white"
	alignment = ALIGNMENT_GOOD
	rites_list = list(/datum/religion_rites/deaconize, /datum/religion_rites/forgive, /datum/religion_rites/summon_rules)
	///people who have agreed to join the crusade, and can be deaconized
	var/list/possible_crusaders = list()
	///people who have been offered an invitation, they haven't finished the alert though.
	var/list/currently_asking = list()

/**
 * Called by deaconize rite, this async'd proc waits for a response on joining the sect.
 * If yes, the deaconize rite can now recruit them instead of just offering invites
 */
/datum/religion_sect/honorbound/proc/invite_crusader(mob/living/carbon/human/invited, mob/living/inviter)
	inviter.balloon_alert(inviter, "the honor code has been presented")
	currently_asking += invited
	var/ask = tgui_alert(invited, "Join [GLOB.deity]? You will be bound to a code of honor.", "Invitation", list("Yes", "No"), 60 SECONDS)
	currently_asking -= invited
	if(ask == "Yes")
		possible_crusaders += invited
		inviter.balloon_alert(inviter, "accepts being bound to the code!")
	else
		inviter.balloon_alert(inviter, "refuses to be bound to the code!")

/datum/religion_sect/honorbound/on_conversion(mob/living/carbon/new_convert)
	. = ..()
	if(!ishuman(new_convert))
		to_chat(new_convert, span_warning("[GLOB.deity] has no respect for lower creatures, and refuses to make you honorbound."))
		return FALSE
	new_convert.gain_trauma(/datum/brain_trauma/special/honorbound, TRAUMA_RESILIENCE_MAGIC)
