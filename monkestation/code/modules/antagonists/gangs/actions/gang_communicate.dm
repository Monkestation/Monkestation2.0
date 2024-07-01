//might turn this into a cheap implant upgrade, also I should componentize this at some point
/datum/action/innate/gang_communicate
	name = "Gang Communicator"
	desc = "Use your implant's built-in communication device to send a message to all other members of your gang. \
			Note that you must speak your message out loud so those near by may be able to hear you."
	button_icon = 'icons/obj/radio.dmi'
	button_icon_state = "walkietalkie"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/gang_communicate/Activate()
	if(!IsAvailable())
		return

	var/input = tgui_input_text(owner, "Message to tell to the other gang members.", "Gang Communicator")
	if(!input)
		return

	var/list/filter_result = CAN_BYPASS_FILTER(owner) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(owner, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(owner) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)
		if(tgui_alert(owner, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", \
						"Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(owner)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. \
						Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(owner)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")

	var/mob/living/sender_mob = owner
	if(!istype(sender_mob))
		CRASH("[src] attempting to activate without a living mob.")

	var/datum/antagonist/gang_member/antag_datum = IS_GANGMEMBER(sender_mob)
	if(!antag_datum)
		CRASH("[src] attempting to activate without its owner having a valid gang antag datum.")

	var/datum/team/gang/owner_gang = antag_datum.gang_team
	if(!owner_gang)
		CRASH("[src] attempting to activate without valid owner gang.")

	sender_mob.whisper(input, sanitize = TRUE)
	send_gang_message(owner_gang, antag_datum, sanitize_text(input))

/**
 * Send a message to everyone in the passed gang(s)
 * sender - The mob sending this message, if any
 * receiving_gangs - List of gangs who's members will hear the message
 * sent_message - The message to send
 * span - The span to wrap the message in
 * append - Extra text to append onto the end of sent_message
 * need_communicator - Do we only send to people with a communicator upgrade
 */
/proc/send_gang_message(list/receiving_gangs, datum/antagonist/gang_member/sender_datum, sent_message, span = "<span class='syndradio'>", append, need_communicator = TRUE)
	if(!receiving_gangs)
		CRASH("send_gang_message() called without receiving_gangs.")

	var/final_message = ""
	var/mob/living/sender_mob = sender_datum?.owner?.current
	if(sender_mob)
		var/sender_rank = "Member"
		if(sender_datum.rank == GANG_RANK_LIEUTENANT)
			sender_rank = "Lieutenant"
			span += "<span class='big'>"
			append = "</span>"
		else if(sender_datum.rank == GANG_RANK_BOSS)
			sender_rank = "Boss"
			span = "<span class='alertsyndie'>"
		final_message = span + "<i><b>[sender_rank] \
						[findtextEx(sender_mob.name, sender_mob.real_name) ? sender_mob.name : "[sender_mob.real_name] (as [sender_mob.name])"]</b> transmits, \"" \
						+ sent_message + "\"</i></span>" + append
	else
		final_message = span + sent_message + "</span>" + append

	if(!islist(receiving_gangs))
		receiving_gangs = list(receiving_gangs)

	var/list/receiving_members = list()
	for(var/datum/team/gang/team in receiving_gangs)
		for(var/obj/item/implant/uplink/gang/implant in team.implants)
			if(implant.imp_in && (!need_communicator || implant.communicate))
				receiving_members += implant.imp_in

	relay_to_list_and_observers(final_message, receiving_members, sender_datum?.owner?.current)
