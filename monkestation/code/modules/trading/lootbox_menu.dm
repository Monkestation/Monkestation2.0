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
	data["canWithdrawLootbox"] = isliving(user) && client_owner.prefs.lootboxes_owned >= 1 && user.can_hold_items()
	data["coins"] = client_owner.prefs.metacoins

	return data

/datum/lootbox_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("withdraw_lootbox")
			withdraw_lootbox()

		if("openboxes")
			var/opening_amount = params["lootboxamount"]
			if(isnewplayer(client_owner.mob))
				to_chat(client_owner.mob, span_warning("You can't open a lootbox here! Observe or spawn in first, then try again."))
				return
			if(client_owner.prefs.lootboxes_owned < 1)
				return
			if(opening_amount == 1)
				client_owner.prefs.lootboxes_owned--
				client_owner.mob.trigger_lootbox_on_self()
			else
				open_boxes(opening_amount)

		if("buyboxes")
			client_owner.attempt_lootbox_buy(params["buyboxamount"])

		if("open_all_boxes")
			if(isnewplayer(client_owner.mob))
				to_chat(client_owner.mob, span_warning("You can't open a lootbox here! Observe or spawn in first, then try again."))
				return
			if(client_owner.prefs.lootboxes_owned < 1)
				return
			open_boxes(client_owner.prefs.lootboxes_owned)

///WIthdraw a single lootbox to our client's hands, given that they are living and capable of holding items
/datum/lootbox_menu/proc/withdraw_lootbox()
	if(client_owner.prefs.lootboxes_owned < 1)
		return

	if(!client_owner.mob)
		return

	var/mob/user = client_owner.mob

	if(!isliving(user) || !user.can_hold_items())
		return

	var/obj/item/lootbox/box = new(get_turf(user))
	user.put_in_hands(box)
	client_owner.prefs.lootboxes_owned--
	playsound(user, 'sound/items/pshoom.ogg', 50, TRUE)

/datum/lootbox_menu/proc/open_boxes(number_boxes)
	var/result_loot
	var/low_tokens_gained = 0
	var/med_tokens_gained = 0
	var/high_tokens_gained = 0
	var/list/loadout_items = list()
	for(var/i in 1 to number_boxes)
		result_loot = generate_lootbox_item(client_owner.mob)
		client_owner.prefs.lootboxes_owned--
		if(client_owner.prefs.lootboxes_owned < 1)
			break

		if(istype(result_loot, /obj/item/coin/antagtoken))
			var/obj/item/coin/antagtoken/token = result_loot
			switch(token.token_type)
				if(LOW_THREAT)
					low_tokens_gained++
				if(MEDIUM_THREAT)
					med_tokens_gained++
				if(HIGH_THREAT)
					high_tokens_gained++
		else
			loadout_items += result_loot
	new /datum/lootbox_rewards_display(client_owner, low_tokens_gained, med_tokens_gained, high_tokens_gained, loadout_items, number_boxes)

/// Datum that shows the rewards of opening mutiple lootboxes at once
/datum/lootbox_rewards_display
	/// The client that owns this datum
	var/client/client_owner
	/// How many low tokens were earned from opening boxes
	var/low_tokens
	/// How many med tokens were earned from opening boxes
	var/med_tokens
	/// How many high tokens were earned from opening boxes
	var/high_tokens
	/// A list of all the loadout items that were earned from opening boxes
	var/list/loadout_items = list()
	/// How many boxes were opened in total
	var/total_boxes_opened
	/// How many duplicates we recieved
	var/duplicates

/datum/lootbox_rewards_display/New(client/owner, low_tokens, med_tokens, high_tokens, _loadout_items, total_boxes_opened)
	client_owner = owner
	src.low_tokens = low_tokens
	src.med_tokens = med_tokens
	src.high_tokens = high_tokens
	loadout_items = list()
	for(var/obj/item/item in _loadout_items)
		loadout_items += list(list("name" = initial(item.name), "icon" = item.icon, "iconstate" = item.icon_state))
	ui_interact(owner.mob)

/datum/lootbox_rewards_display/ui_state()
	return GLOB.always_state

/datum/lootbox_rewards_display/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "LootboxRewards")
		ui.open()

/datum/lootbox_rewards_display/ui_static_data(mob/user)
	var/list/data = list()

	data["numberlowtokens"] = low_tokens
	data["numbermedtokens"] = med_tokens
	data["numberhightokens"] = high_tokens
	data["loadoutitems"] = loadout_items

	return data

