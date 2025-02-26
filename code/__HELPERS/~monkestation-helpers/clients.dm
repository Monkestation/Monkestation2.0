/proc/kick_client(client/to_kick, reason, server_call)
	// Pretty much everything in this proc is copied straight from `code/modules/admin/topic.dm`,
	// proc `/datum/admins/Topic()`, href `"boot2"`. If it breaks here, it was probably broken there
	// too.

	if (server_call)
		if(QDELETED(to_kick))
			return
		to_chat(to_kick, span_danger("You have been kicked from the server[reason && " with the reason \"[reason]\""]."), confidential = TRUE)
		log_admin("SERVER: Kicked [key_name(to_kick)][reason && " with the reason \"[reason]\""].")
		message_admins(span_adminnotice("SERVER: Kicked [key_name_admin(to_kick)][reason && " with the reason \"[reason]\""]."))
		qdel(to_kick)
	else
		if(!check_rights(R_ADMIN))
			return
		if(QDELETED(to_kick))
			to_chat(usr, span_danger("Error: The client you specified has disappeared!"), confidential = TRUE)
			return
		if(!check_if_greater_rights_than(to_kick))
			to_chat(usr, span_danger("Error: They have more rights than you do."), confidential = TRUE)
			return
		to_chat(to_kick, span_danger("You have been kicked from the server by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"][reason && " with the reason \"[reason]\""]."), confidential = TRUE)
		log_admin("[key_name(usr)] kicked [key_name(to_kick)][reason && " with the reason \"[reason]\""].")
		message_admins(span_adminnotice("[key_name_admin(usr)] kicked [key_name_admin(to_kick)][reason && " with the reason \"[reason]\""]."))
		qdel(to_kick)

/// When passed a mob, client, or mind, returns their admin holder, if they have one.
/proc/get_admin_holder(doohickey) as /datum/admins
	RETURN_TYPE(/datum/admins)
	var/client/client = CLIENT_FROM_VAR(doohickey)
	return client?.holder

/proc/should_be_verifying(mob/target)
	. = FALSE
	if(QDELETED(target))
		return
	. = target.client?.not_discord_verified
	var/ckey = target.ckey
	if(ckey)
		if(is_admin(target.client) || target.client.is_mentor())
			return FALSE

/proc/verification_safety(mob/target, context)
	. = should_be_verifying(target)
	if(.)
		message_admins(span_danger("<b>WARNING</b>: [ADMIN_SUSINFO(target)] has seemingly bypassed verification! (context: [context]) <i>note: this detection is still wip, tell absolucy if it's causing false positives</i>"))
		log_admin_private("[key_name(target)] has seemingly bypassed verification! (context: [context])")
		if(isnewplayer(target))
			var/mob/dead/new_player/dingbat = target
			if(dingbat.ready == PLAYER_READY_TO_PLAY)
				dingbat.ready = PLAYER_NOT_READY
				qdel(dingbat.client)
