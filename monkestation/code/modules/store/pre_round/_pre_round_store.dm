GLOBAL_LIST_INIT(pre_round_items, init_pre_round_items())

/proc/init_pre_round_items()
	. = list()
	for(var/datum/store_item/store_item_type as anything in (subtypesof(/datum/store_item) - /datum/store_item/roundstart))
		if(!store_item_type::one_time_buy)
			continue
		.[store_item_type] = new store_item_type

/client
	var/datum/pre_round_store/readied_store

/client/Destroy()
	QDEL_NULL(readied_store)
	return ..()

/datum/pre_round_store
	var/datum/store_item/bought_item

/datum/pre_round_store/Destroy(force)
	SStgui.close_uis(src)
	bought_item = null
	return ..()

/datum/pre_round_store/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreRoundStore", "Spend Monkecoins")
		ui.open()

/datum/pre_round_store/ui_state(mob/user)
	return GLOB.always_state

/datum/pre_round_store/ui_static_data(mob/user)
	var/list/items = list()
	for(var/datum/store_item/store_item_type as anything in GLOB.pre_round_items)
		var/datum/store_item/store_item = GLOB.pre_round_items[store_item_type]
		var/obj/item/item_path = store_item.item_path
		if(isnull(item_path))
			continue
		items += list(
			list(
				"path" = store_item_type,
				"name" = store_item.name,
				"cost" = store_item.item_cost,
				"icon" = item_path::icon,
				"icon_state" = item_path::icon_state,
			)
		)
	return list("items" = items)

/datum/pre_round_store/ui_data(mob/user)
	. = list(
		"notices" = config.lobby_notices,
		"currently_owned" = null,
		"balance" = 0,
	)
	var/datum/preferences/user_prefs = user?.client?.prefs
	if(QDELETED(src) || QDELETED(user_prefs))
		return
	if(!user_prefs.metacoins)
		user_prefs.load_metacoins(user.client.ckey)

	if(!isnull(bought_item))
		.["balance"] = user_prefs.metacoins - bought_item::item_cost
		.["currently_owned"] = bought_item::name
	else
		.["balance"] = user_prefs.metacoins

/datum/pre_round_store/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("attempt_buy")
			attempt_buy(params)
			return TRUE

/datum/pre_round_store/proc/attempt_buy(list/params)
	var/store_item_type = text2path(params["path"])
	if(isnull(store_item_type))
		return
	if(!ispath(store_item_type, /datum/store_item))
		message_admins("[usr] attempted an href exploit - tried to buy pre-round item [store_item_type], which isn't a /datum/store_item")
		CRASH("Attempted an href exploit - tried to buy pre-round item [store_item_type], which isn't a /datum/store_item")
	var/datum/store_item/store_item = GLOB.pre_round_items[store_item_type]
	if(isnull(store_item))
		CRASH("[store_item_type] wasn't in GLOB.pre_round_items")
	bought_item = store_item

/datum/pre_round_store/proc/finalize_purchase_spawn(mob/new_player_mob, mob/new_player_mob_living)
	var/datum/preferences/owners_prefs = new_player_mob?.client?.prefs
	if(isnull(bought_item) || QDELETED(src) || QDELETED(owners_prefs))
		return
	if(!owners_prefs.has_coins(bought_item::item_cost))
		to_chat(new_player_mob, span_warning("It seems you're lacking coins to complete this transaction."))
		return
	var/obj/item/created_item = new bought_item.item_path

	if(istype(created_item, /obj/item/effect_granter))
		var/obj/item/effect_granter/granting_time = created_item
		if(granting_time.human_only && iscarbon(new_player_mob_living))
			addtimer(CALLBACK(granting_time, TYPE_PROC_REF(/obj/item/effect_granter, grant_effect), new_player_mob_living), 4 SECONDS)
		else
			QDEL_NULL(new_player_mob.client.readied_store)
			qdel(created_item)
			return
	else if(!new_player_mob.put_in_hands(created_item, FALSE))
		var/obj/item/storage/backpack/backpack = new_player_mob_living.get_item_by_slot(ITEM_SLOT_BACK)
		if(!backpack)
			to_chat(new_player_mob, span_warning("There was an error spawning in your items, you will not be charged"))
			qdel(created_item)
			return
		backpack.atom_storage.attempt_insert(created_item, new_player_mob, force = TRUE)

	owners_prefs.adjust_metacoins(new_player_mob.client.ckey, -bought_item::item_cost, "Bought a [created_item] for [initial(bought_item.item_cost)] (Pre-round Store)", donator_multiplier = FALSE)
	QDEL_NULL(new_player_mob.client.readied_store)
