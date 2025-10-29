ADMIN_VERB(battle_royale_easy_setup, R_FUN, FALSE, "Easy Set Up Battle Royale", "Quick way to set up a battle royale.", ADMIN_CATEGORY_FUN)
	user?.holder?.battle_royale_easy_setup()

/datum/admins/proc/battle_royale_easy_setup()
	if(!check_rights(R_FUN))
		return

	if(!GLOB.battle_royale_controller)
		GLOB.battle_royale_controller = new

	if(GLOB.battle_royale_controller?.active)
		to_chat(usr, span_warning("A game has already started!"))
		return

	var/input = tgui_alert(usr, "Do you want to quick start a battle royale?", "Battle royale", list("Normal(20 min max duration)", "Fast(10 min max duration)", "No"))
	if(!input || input == "No")
		return

	if(tgui_alert(usr, "Are you sure you want to start a battle royale?", "Battle royale", list("Yes", "No")) != "Yes")
		return

	message_admins("[key_name_admin(usr)] has triggered battle royale.")
	log_admin("[key_name(usr)] has triggered battle royale.")
	GLOB.battle_royale_controller.setup((input == "Fast(10 min max duration)") ? TRUE : FALSE)

ADMIN_VERB(battle_royale_panel, R_FUN, FALSE, "Battle Royale Panel", "Open the battle royale panel.", ADMIN_CATEGORY_FUN)
	if(!GLOB.battle_royale_controller)
		GLOB.battle_royale_controller = new

	GLOB.battle_royale_controller?.ui_interact(usr)
