//All bundles and telecrystals
/datum/uplink_category/bundle
	name = "Bundles"
	weight = 10

/datum/uplink_item/bundles_tc
	category = /datum/uplink_category/bundle
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/bundles_tc/random
	name = "Random Item"
	desc = "Picking this will purchase a random item. Useful if you have some TC to spare or if you haven't decided on a strategy yet."
	item = ABSTRACT_UPLINK_ITEM
	cost = 0
	cost_override_string = "Varies"

/datum/uplink_item/bundles_tc/random/purchase(mob/user, datum/uplink_handler/handler, atom/movable/source)
	var/list/possible_items = list()
	var/ignore_locked = check_ignore_locked(handler) //monkestation edit
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/uplink_item = SStraitor.uplink_items_by_type[item_path]
		if(src == uplink_item || !uplink_item.item)
			continue
		if(!handler.can_purchase_item(user, uplink_item, ignore_locked)) //monkestation edit: adds ignore_locked
			continue
		possible_items += uplink_item

//monkestation edit start, this is the less snowflakey more janky way to handle this
	var/debug_mode = handler.debug_mode
	if(ignore_locked)
		handler.debug_mode = TRUE
//monkestation edit end
	if(possible_items.len)
		var/datum/uplink_item/uplink_item = pick(possible_items)
		log_uplink("[key_name(user)] purchased a random uplink item from [handler.owner]'s uplink with [handler.telecrystals] telecrystals remaining")
		SSblackbox.record_feedback("tally", "traitor_random_uplink_items_gotten", 1, initial(uplink_item.name))
		handler.purchase_item(user, uplink_item)
	handler.debug_mode = debug_mode //monkestation edit

/datum/uplink_item/bundles_tc/telecrystal
	name = "1 Raw Telecrystal"
	desc = "A telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/telecrystal
	cost = 1
	// Don't add telecrystals to the purchase_log since
	// it's just used to buy more items (including itself!)
	purchase_log_vis = FALSE
	purchasable_from = NONE

/datum/uplink_item/bundles_tc/bundle_a
	name = "Syndi-kit Tactical"
	desc = "Syndicate Bundles, also known as Syndi-Kits, are specialized groups of items that arrive in a plain box. \
			These items are collectively worth more than 25 telecrystals, but you do not know which specialization \
			you will receive. May contain discontinued and/or exotic items. \
			The Syndicate will only provide one Syndi-Kit per agent."
	progression_minimum = 30 MINUTES
	item = /obj/item/storage/box/syndicate/bundle_a
	cost = 20
	stock_key = UPLINK_SHARED_STOCK_KITS
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_tc/bundle_b
	name = "Syndi-kit Special"
	desc = "Syndicate Bundles, also known as Syndi-Kits, are specialized groups of items that arrive in a plain box. \
			In Syndi-kit Special, you will receive items used by famous syndicate agents of the past. \
			Collectively worth more than 25 telecrystals, the syndicate loves a good throwback. \
			The Syndicate will only provide one Syndi-Kit per agent."
	progression_minimum = 30 MINUTES
	item = /obj/item/storage/box/syndicate/bundle_b
	cost = 20
	stock_key = UPLINK_SHARED_STOCK_KITS
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_tc/surplus
	name = "Syndicate Surplus Crate"
	desc = "A dusty crate from the back of the Syndicate warehouse delivered directly to you via Supply Pod. \
			If the rumors are true, it will fill it's contents based on your current reputation. Get on that grind. \
			Contents are sorted to always be worth 40 TC. The Syndicate will only provide one surplus item per agent."
	item = /obj/structure/closet/crate // will be replaced in purchase()
	cost = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	stock_key = UPLINK_SHARED_STOCK_SURPLUS
	/// Value of items inside the crate in TC
	var/crate_tc_value = 40 //monkestation edit: from 30 to 40
	/// crate that will be used for the surplus crate
	var/crate_type = /obj/structure/closet/crate

/// generates items that can go inside crates, edit this proc to change what items could go inside your specialized crate
/// monkestation edit: set unrestricted to TRUE if you want to pick from all uplink items
/datum/uplink_item/bundles_tc/surplus/proc/generate_possible_items(mob/user, datum/uplink_handler/handler, unrestricted = FALSE) //monkestation edit: adds unrestricted
	var/list/possible_items = list()
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/uplink_item = SStraitor.uplink_items_by_type[item_path]
		if(src == uplink_item || !uplink_item.item)
			continue
		if(!unrestricted && !handler.check_if_restricted(uplink_item)) //monkestation edit: adds the unrestricted check
			continue
		if(!uplink_item.surplus)
			continue
		possible_items += uplink_item
	return possible_items

/// picks items from the list given to proc and generates a valid uplink item that is less or equal to the amount of TC it can spend
/datum/uplink_item/bundles_tc/surplus/proc/pick_possible_item(list/possible_items, tc_budget)
	var/datum/uplink_item/uplink_item = pick(possible_items)
	if(prob(100 - uplink_item.surplus))
		return null
	if(tc_budget < uplink_item.cost)
		return null
	return uplink_item

/// fills the crate that will be given to the traitor, edit this to change the crate and how the item is filled
/datum/uplink_item/bundles_tc/surplus/proc/fill_crate(obj/structure/closet/crate/surplus_crate, list/possible_items)
	var/tc_budget = crate_tc_value
	while(tc_budget)
		var/datum/uplink_item/uplink_item = pick_possible_item(possible_items, tc_budget)
		if(!uplink_item)
			continue
		tc_budget -= uplink_item.cost
		new uplink_item.item(surplus_crate)

/// overwrites item spawning proc for surplus items to spawn an appropriate crate via a podspawn
/datum/uplink_item/bundles_tc/surplus/spawn_item(spawn_path, mob/user, datum/uplink_handler/handler, atom/movable/source)
	var/obj/structure/closet/crate/surplus_crate = new crate_type()
	if(!istype(surplus_crate))
		CRASH("crate_type is not a crate")
	var/list/possible_items = generate_possible_items(user, handler)

//monkestation edit start
	if(!possible_items || !length(possible_items))
		handler.telecrystals += cost
		to_chat(user, span_warning("You get the feeling something went wrong and that you should inform syndicate command"))
		qdel(surplus_crate)
		CRASH("surplus crate failed to generate possible items")
//monkestation edit end
	fill_crate(surplus_crate, possible_items)

	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = surplus_crate,
	))
	return source //For log icon

/datum/uplink_item/bundles_tc/surplus/united
	name = "United Surplus Crate"
	desc = "A shiny and large crate to be delivered directly to you via Supply Pod. It has an advanced locking mechanism with an anti-tampering protocol. \
			It is recommended that you only attempt to open it by having another agent purchase a Surplus Crate Key. Unite and fight. \
			Rumored to contain a valuable assortment of items based on your current reputation, but you never know. Contents are sorted to always be worth 100 TC. \
			The Syndicate will only provide one surplus item per agent."
	cost = 20
	item = /obj/structure/closet/crate/syndicrate
	progression_minimum = 30 MINUTES
	stock_key = UPLINK_SHARED_STOCK_SURPLUS
	crate_tc_value = 100 //monkestation edit: from 80 to 100
	crate_type = /obj/structure/closet/crate/syndicrate

/// edited version of fill crate for super surplus to ensure it can only be unlocked with the syndicrate key
/datum/uplink_item/bundles_tc/surplus/united/fill_crate(obj/structure/closet/crate/syndicrate/surplus_crate, list/possible_items)
	if(!istype(surplus_crate))
		return
	var/tc_budget = crate_tc_value
	while(tc_budget)
		var/datum/uplink_item/uplink_item = pick_possible_item(possible_items, tc_budget)
		if(!uplink_item)
			continue
		tc_budget -= uplink_item.cost
		surplus_crate.unlock_contents += uplink_item.item

/datum/uplink_item/bundles_tc/surplus_key
	name = "United Surplus Crate Key"
	desc = "This inconscpicous device is actually a key that can open any United Surplus Crate. It can only be used once. \
			Though initially designed to encourage cooperation, agents quickly discovered that you can turn the key to the crate by yourself.  \
			The Syndicate will only provide one surplus item per agent."
	cost = 20
	item = /obj/item/syndicrate_key
	progression_minimum = 30 MINUTES
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	stock_key = UPLINK_SHARED_STOCK_SURPLUS

/datum/uplink_item/bundles_tc/contract_kit
	name = "Contractor Bundle"
	desc = "A box containing everything you need to take contracts from the Syndicate. Kidnap people and drop them off at specified locations for rewards in the form of Telecrystals \
			(Usable in the provided uplink) and Contractor Points. Can not be bought if you have taken any secondary objectives."
	item = /obj/item/storage/box/syndie_kit/contract_kit
	cost = 20
	purchasable_from = UPLINK_TRAITORS

/datum/uplink_item/bundles_tc/contract_kit/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	if(length(handler.active_objectives) || !handler.can_take_objectives || !handler.has_objectives)
		return FALSE

	for(var/datum/traitor_objective/objective in handler.completed_objectives)
		if(objective.objective_state != OBJECTIVE_STATE_INVALID)
			return FALSE

	return TRUE

/datum/uplink_item/bundles_tc/contract_kit/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	. = ..()
	var/datum/component/uplink/our_uplink = source.GetComponent(/datum/component/uplink)
	if(uplink_handler && our_uplink)
		our_uplink.become_contractor()

///Override for any unique checks for specific items, by default returns TRUE
/datum/uplink_item/proc/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	return TRUE

/datum/uplink_item/bundles_tc/surplus/lootbox
	name = "Syndicate Lootbox Crate"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			With their all new kit, codenamed 'scam' the syndicate attempted to extract the energy of the die of fate to \
			make a loot-box style system but failed, so instead just fake their randomness using ook's evil twin brother to sniff out the items to shove in it. \
			Item price not guaranteed. Can contain normally unobtainable items. Purchasing this will prevent you from purchasing any non-random item. \
			Cannot be purchased if you have already bought another item."

/datum/uplink_item/bundles_tc/surplus/lootbox/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	//we dont acually have the var that makes this get checked so do it manually
	if(length(handler.purchase_log.purchase_log) > 0)
		return FALSE
	return TRUE

/datum/uplink_item/bundles_tc/surplus/lootbox/spawn_item(spawn_path, mob/user, datum/uplink_handler/handler, atom/movable/source)
	crate_tc_value = rand(1,20) * 5 // randomise how much in TC it gives, from 5 to 100 TC

	if(crate_tc_value == 5) //horrible luck, welcome to gambling
		crate_tc_value = 0
		to_chat(user, span_warning("You feel an overwhelming sense of pride and accomplishment."))

	if(crate_tc_value == 100) // Jackpot, how lucky
		crate_tc_value *= 2
		print_command_report("Congratulations to [user] for being the [rand(2, 9)]th lucky winner of the syndicate lottery! \
		Dread Admiral Sabertooth has authorised the beaming of your special equipment immediately! Happy hunting operative.",
		"Syndicate Gambling Division High Command", TRUE)
		if(ishuman(user) && !(locate(/obj/item/implant/weapons_auth) in user)) //jackpot winners dont have to find firing pins for any guns they get
			var/obj/item/implant/weapons_auth/auth = new
			auth.implant(user)
			to_chat(user, span_notice("You feel as though the syndicate have given you the ability to use weapons beyond your normal access level."))

	var/obj/structure/closet/crate/surplus_crate = new crate_type()
	// quick safety check
	if(!istype(surplus_crate))
		CRASH("crate_type is not a crate")

	var/list/possible_items = generate_possible_items(user, handler, TRUE)
	// again safety check, if things fucked up badly we give them back their cost and return
	if(!possible_items || !length(possible_items))
		handler.telecrystals += cost
		to_chat(user, span_warning("You get the feeling something went wrong and that you should inform syndicate command."))
		qdel(surplus_crate)
		CRASH("lootbox crate failed to generate possible items")

	fill_crate(surplus_crate, possible_items)

	// unlike other chests, lets give them the chest with STYLE by droppodding in a STYLIZED pod
	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = surplus_crate,
	))

	// lock everything except random entries, once you start gambling you cannot stop
	handler.add_locked_entries(subtypesof(/datum/uplink_item) - /datum/uplink_item/bundles_tc/random)

	// return the source, this is so the round-end uplink section shows how many TC the traitor spent on us (20TC) and a radio icon. Instead of 0 TC and a blank one
	return source

//pain
///Check if we should ignore handler locked_entries or not
/datum/uplink_item/bundles_tc/random/proc/check_ignore_locked(datum/uplink_handler/handler)
	return (length(handler.locked_entries) == (length(subtypesof(/datum/uplink_item)) - 1)) && !(src.type in handler.locked_entries)


/datum/uplink_item/bundles_tc/syndicate_mini_kit
	name = "Syndicate Mini-Kit"
	desc = "A small, budget-friendly kit for new operatives. Contains a selection of basic tools. \
			The Syndicate provides only one Mini-Kit per agent."
	item = /obj/item/storage/box/syndie_kit/mini_kit
	cost = 10
	stock_key = UPLINK_SHARED_STOCK_KITS
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
