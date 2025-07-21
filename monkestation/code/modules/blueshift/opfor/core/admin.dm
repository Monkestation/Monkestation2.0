ADMIN_VERB(request_more_opfor, R_FUN, FALSE, "Request OPFOR", "Request players sign up for opfor if they have antag on.", ADMIN_CATEGORY_FUN)
	var/asked = 0
	if(tgui_alert(user, "Do you wish to notify all players that OPFORs are desired?", "Confirm Action", list("Yes", "No")) != "Yes")
		return
	for(var/mob/living/carbon/human/human in GLOB.alive_player_list)
		to_chat(human, boxed_message(span_greentext("The admins are looking for OPFOR players, if you're interested, sign up in the OOC tab!")))
		asked++
	message_admins("[ADMIN_LOOKUP(user.mob)] has requested more OPFOR players! (Asked: [asked] players)")

ADMIN_VERB(view_opfors, R_FUN, FALSE, "View OPFORs", "Spawns an amount of chosen pollutant at your current location.", ADMIN_CATEGORY_GAME)
	user << browse(HTML_SKELETON(SSopposing_force.get_check_antag_listing()), "window=roundstatus;size=500x500")
	log_admin("[key_name(user)] viewed OPFORs.")
	BLACKBOX_LOG_ADMIN_VERB("View OPFORs")
