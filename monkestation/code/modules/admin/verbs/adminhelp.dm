/datum/admin_help
	var/handling_admin_ckey
	var/list/_interactions = list()

/datum/admin_help/proc/Administer(announce = FALSE)
	if(!usr.client)
		return FALSE
	if(handling_admin_ckey)
		if(handling_admin_ckey == usr.ckey)
			to_chat(usr, "This ticket is already yours.")
			return FALSE
		if(tgui_alert(usr, "This ticket has already been claimed by [handling_admin_ckey], are you sure you wish to continue?", "Confirm", list("Yes", "No")) != "Yes")
			return FALSE

	handling_admin_ckey = usr.ckey

	var/msg = "[usr.ckey]/([usr]) has been assigned to [TicketHref("ticket #[id]")] as primary admin."
	message_admins(msg)
	log_admin_private(msg)

	if(announce && initiator)
		to_chat(initiator,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_notice("[key_name(usr, TRUE, FALSE)] has taken your ticket and will respond shortly."),
			confidential = TRUE)

/datum/admin_help/Close(key_name = key_name_admin(usr), silent = FALSE)
	if(!handling_admin_ckey)
		Administer(FALSE)
	. = ..()

/datum/admin_help/Resolve(key_name = key_name_admin(usr), silent = FALSE)
	if(!handling_admin_ckey)
		Administer(FALSE)
	. = ..()

/datum/ticket_log
	var/datum/admin_help/parent
	var/gametime
	var/user
	var/text
	var/player_text
	var/for_admins

/datum/ticket_log/New(datum/admin_help/parent, ckey, text, player_text, for_admins = FALSE)
	src.gametime = gameTimestamp()
	src.parent = parent
	src.for_admins = for_admins
	src.user = ckey ? ckey : get_fancy_key(usr)
	src.text = text
	if(player_text)
		src.player_text = player_text
	else if(!for_admins)
		src.player_text = text
