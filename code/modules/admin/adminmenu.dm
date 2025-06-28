/datum/verbs/menu/Admin/Generate_list(client/C)
	if (C.holder)
		. = ..()

ADMIN_VERB(playerpanel, NONE, FALSE, "Player Panel", "Old TGUI player panel.", ADMIN_CATEGORY_GAME)
	user.holder.player_panel_new()
	BLACKBOX_LOG_ADMIN_VERB("Player Panel New")
