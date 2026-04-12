/datum/antagonist/devil/antag_token(datum/mind/hosts_mind, mob/living/carbon/human/spender)
	if(istype(spender))
		hosts_mind.add_antag_datum(type) // Easy enough, and yes this can happen when you are dead.
		message_admins("[ADMIN_LOOKUPFLW(spender)] has been made into a devil by using an antag token. (Used existing character)")
		return

	var/mob/living/carbon/human/new_body = make_body()
	new_body.PossessByPlayer(spender.ckey)
	new_body.mind.add_antag_datum(type)
	message_admins("[ADMIN_LOOKUPFLW(new_body)] has been made into a devil by using an antag token. (Newly spawned character)")
