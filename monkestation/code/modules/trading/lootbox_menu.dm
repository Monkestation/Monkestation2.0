/datum/lootbox_menu
	var/client/client_owner
	var/opening_boxes = FALSE

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
	data["openingboxes"] = opening_boxes

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
				if(client_owner.mob.trigger_lootbox_on_self())
					client_owner.prefs.lootboxes_owned--
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

///Holds a rewarded item's important info for the lootbox menu to process
/datum/reward_item_container
	var/name
	var/icon
	var/icon_state
	var/duplicate

/datum/lootbox_menu/proc/open_boxes(number_boxes)
	if(opening_boxes)
		return
	opening_boxes = TRUE
	var/obj/result_loot
	var/low_tokens_gained = 0
	var/med_tokens_gained = 0
	var/high_tokens_gained = 0
	var/duplicates = 0
	var/list/loadout_items = list()
	var/datum/reward_item/reward = new

	for(var/i in 1 to number_boxes)
		reward = generate_lootbox_item(client_owner.mob)
		result_loot = reward.item
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
			var/datum/reward_item_container/container = new
			container.name = copytext(result_loot.name, 14) // Trimming the "loadout item" portion of the name, as that clutters the menu
			container.icon = result_loot.icon
			container.icon_state = result_loot.icon_state
			container.duplicate = reward.duplicate
			loadout_items += container
			if(reward.duplicate)
				duplicates++
	if((high_tokens_gained + med_tokens_gained + low_tokens_gained) == 0 && !(length(loadout_items)) && number_boxes > 0)
		log_runtime("A lootbox menu attempted to generate items, but returned no tokens and no loadout items. This really shouldnt happen")
		CRASH("A lootbox menu attempted to generate items, but returned no tokens and no loadout items. This really shouldnt happen")
	new /datum/lootbox_rewards_display(client_owner, low_tokens_gained, med_tokens_gained, high_tokens_gained, loadout_items, number_boxes, duplicates)
	opening_boxes = FALSE

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
	/// How many duplicates we recieved
	var/duplicates
	/// How many boxes were opened in total
	var/totalboxes

/datum/lootbox_rewards_display/New(client/owner, low_tokens, med_tokens, high_tokens, _loadout_items, total_boxes_opened, duplicates_total)
	client_owner = owner
	src.low_tokens = low_tokens
	src.med_tokens = med_tokens
	src.high_tokens = high_tokens
	totalboxes = total_boxes_opened
	duplicates = duplicates_total
	loadout_items = list()
	for(var/datum/reward_item_container/container in _loadout_items)
		loadout_items += list(list("name" = container.name, "icon" = container.icon, "iconstate" = container.icon_state, "duplicate" = container.duplicate))
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
	data["duplicates"] = duplicates
	data["totalboxes"] = totalboxes

	return data

