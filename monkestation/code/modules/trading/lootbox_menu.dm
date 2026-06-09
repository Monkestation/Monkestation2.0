/datum/lootbox_menu
	var/client/client_owner

/datum/lootbox_menu/New(client/owner, mob/viewer)
	src.client_owner = owner
	ui_interact(viewer)

/datum/lootbox_menu/ui_state()
	return GLOB.always_state

/datum/lootbox_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "LootboxMenu")
		ui.open()

/datum/lootbox_menu/ui_data(mob/user)
	var/list/data = list()

	data["numberLootboxes"] = client_owner.prefs.lootboxes_owned
	data["canWithdrawLootbox"] = isliving(user) && client_owner.prefs.lootboxes_owned > 1 && user.can_hold_items()
	data["coins"] = client_owner.prefs.metacoins

	return data

/datum/lootbox_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("withdraw_lootbox")
			return TRUE
		if("openboxes")
			return TRUE
		if("buyboxes")
			return TRUE
		if("open_all_boxes")
			return TRUE
