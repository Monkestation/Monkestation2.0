
// TODO: Work into reworked uplinks.
/// Selects a set number of unique items from the uplink, and deducts a percentage discount from them
/proc/create_uplink_sales(num, datum/uplink_category/category, limited_stock, list/sale_items)
	var/list/sales = list()
	var/list/per_category = list()

	for (var/datum/uplink_item/possible_sale as anything in sale_items)
		if (!(possible_sale.category in per_category))
			per_category[possible_sale.category] = list()
		per_category[possible_sale.category] += possible_sale

	for (var/i in 1 to min(length(per_category), num))
		var/datum/uplink_category/item_category = pick(per_category)
		var/datum/uplink_item/taken_item = pick(per_category[item_category])
		per_category -= item_category
		var/datum/uplink_item/uplink_item = new taken_item.type()
		var/discount = uplink_item.get_discount()
		var/static/list/disclaimer = list(
			"Void where prohibited.",
			"Not recommended for children.",
			"Contains small parts.",
			"Check local laws for legality in region.",
			"Do not taunt.",
			"Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.",
			"Keep away from fire or flames.",
			"Product is provided \"as is\" without any implied or expressed warranties.",
			"As seen on TV.",
			"For recreational use only.",
			"Use only as directed.",
			"16% sales tax will be charged for orders originating within Space Nebraska.",
		)
		uplink_item.limited_stock = limited_stock
		if(uplink_item.cost >= 20) //Tough love for nuke ops
			discount *= 0.5
		uplink_item.stock_key = WEAKREF(uplink_item)
		uplink_item.category = category
		uplink_item.cost = max(round(uplink_item.cost * (1 - discount)),1)
		uplink_item.name += " ([round(((initial(uplink_item.cost)-uplink_item.cost)/initial(uplink_item.cost))*100)]% off!)"
		uplink_item.desc += " Normally costs [initial(uplink_item.cost)] TC. All sales final. [pick(disclaimer)]"
		uplink_item.item = taken_item.item
		uplink_item.discounted = TRUE

		sales += uplink_item
	return sales

/**
 * Uplink Items
 *
 * Items that can be spawned from an uplink. Can be limited by gamemode.
**/
/datum/uplink_item
	/// Name of the uplink item
	var/name = "item name"
	/// Category of the uplink
	var/datum/uplink_category/category
	/// Description of the uplink
	var/desc = "item description"
	/// Path to the item to spawn.
	var/item = null
	/// Cost of the item.
	var/cost = 0
	/// Amount of TC to refund, in case there's a TC penalty for refunds.
	var/refund_amount = 0
	/// Whether this item is refundable or not.
	var/refundable = FALSE
	/// Chance of being included in the surplus crate.
	var/surplus = 100
	/// Whether this can be discounted or not
	var/cant_discount = FALSE
	/// If discounted, is true. Used to send a signal to update reimbursement.
	var/discounted = FALSE
	/// If this value is changed on two items they will share stock, defaults to not sharing stock with any other item
	var/stock_key = UPLINK_SHARED_STOCK_UNIQUE
	/// How many items of this stock can be purchased.
	var/limited_stock = -1 //Setting this above zero limits how many times this item can be bought by the same traitor in a round, -1 is unlimited
	/// A bitfield to represent what uplinks can purchase this item.
	/// See [`code/__DEFINES/uplink.dm`].
	var/purchasable_from = ALL
	/// If this uplink item is only available to certain roles. Roles are dependent on the frequency chip or stored ID.
	var/list/restricted_roles = list()
	/// The species able to purchase this uplink item.
	var/restricted_species = list()
	/// The minimum amount of progression needed for this item to be added to uplinks.
	var/progression_minimum = 0
	/// The minimum number of living players needed for this item to be bought.
	var/population_minimum = 0
	/// Whether this purchase is visible in the purchase log.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	/// Whether the purchase log lists what this kit held. Only for kits with randomized contents
	var/log_contents = FALSE
	/// Whether this purchase is restricted or not (VR/Events related)
	var/restricted = FALSE
	/// Can this item be deconstructed to unlock certain techweb research nodes?
	var/illegal_tech = TRUE
	/// String to be shown instead of the price, e.g for the Random item.
	var/cost_override_string = ""
	/// Whether this item locks all other items from being purchased. Used by syndicate balloon and a few other purchases.
	/// Can't be purchased if you've already bought other things
	/// Uses the purchase log, so items purchased that are not visible in the purchase log will not count towards this.
	/// However, they won't be purchasable afterwards.
	var/lock_other_purchases = FALSE
	/// Whether this item prevents secondary objectives from being taken.
	/// In addition, if any secondary objectives have been taken or completed, this item will not be available for purchase.
	var/lock_secondary_objectives = FALSE

/datum/uplink_item/New()
	. = ..()
	if(stock_key != UPLINK_SHARED_STOCK_UNIQUE)
		return
	stock_key = type

/datum/uplink_category
	/// Name of the category
	var/name
	/// Weight of the category. Used to determine the positioning in the uplink. High weight = appears first
	var/weight = 0

/// Returns by how much percentage do we reduce the price of the selected item
/datum/uplink_item/proc/get_discount()

	var/static/list/discount_types = list(
		TRAITOR_DISCOUNT_SMALL = 4,
		TRAITOR_DISCOUNT_AVERAGE = 2,
		TRAITOR_DISCOUNT_BIG = 1,
	)

	return get_discount_value(pick_weight(discount_types))

/// Receives a traitor discount type value, returns the amount by which we will reduce the price
/datum/uplink_item/proc/get_discount_value(discount_type)
	switch(discount_type)
		if(TRAITOR_DISCOUNT_BIG)
			return 0.75
		if(TRAITOR_DISCOUNT_AVERAGE)
			return 0.5
		else
			return 0.25

/// Spawns an item and logs its purchase
/datum/uplink_item/proc/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	uplink_handler.logged_purchase_contents = null
	var/atom/A = spawn_item(item, user, uplink_handler, source)
	log_uplink("[key_name(user)] purchased [src] for [cost] telecrystals from [source]'s uplink")
	if(purchase_log_vis && uplink_handler.purchase_log)
		// Crates that can't be handed back tell us what they held, otherwise randomized kits are read off the thing that was bought
		var/list/bought_contents = uplink_handler.logged_purchase_contents
		if(!bought_contents && log_contents && A && A != source)
			bought_contents = summarize_contents(A.contents)
		uplink_handler.purchase_log.LogPurchase(A, src, cost, bought_contents)
	uplink_handler.logged_purchase_contents = null
	if(lock_other_purchases)
		uplink_handler.shop_locked = TRUE
	if(lock_secondary_objectives)
		uplink_handler.disable_secondary_objectives()

/// The uplink entry that sells this item, nothing if it has none. The cheapest entry wins
/datum/uplink_item/proc/get_item_uplink_entry(item_path)
	var/static/list/entry_by_item
	if(!entry_by_item)
		entry_by_item = list()
		for(var/uplink_path in SStraitor.uplink_items_by_type)
			var/datum/uplink_item/entry = SStraitor.uplink_items_by_type[uplink_path]
			if(!ispath(entry.item) || entry.cost <= 0)
				continue
			var/datum/uplink_item/cheapest = entry_by_item[entry.item]
			if(!cheapest || entry.cost < cheapest.cost)
				entry_by_item[entry.item] = entry
	return entry_by_item[item_path]

/// Counts items or item paths for the round end log, as name = list(amount, icon html, TC cost, description)
/// An item that has an uplink entry goes by that entry's name and description, otherwise its own
/datum/uplink_item/proc/summarize_contents(list/things)
	var/list/summary = list()
	for(var/thing in things)
		var/thing_type
		var/thing_name
		var/thing_desc
		var/thing_icon
		var/amount = 1
		if(ispath(thing, /atom))
			var/atom/thing_path = thing
			thing_type = thing_path
			thing_name = initial(thing_path.name)
			thing_desc = initial(thing_path.desc)
			if(initial(thing_path.icon) && initial(thing_path.icon_state))
				thing_icon = icon2base64html(icon(initial(thing_path.icon), initial(thing_path.icon_state), SOUTH, 1))
		else if(isitem(thing))
			var/obj/item/thing_item = thing
			thing_type = thing_item.type
			thing_name = thing_item.name
			thing_desc = thing_item.desc
			if(thing_item.icon && thing_item.icon_state)
				thing_icon = icon2base64html(thing_item)
			if(isstack(thing_item))
				var/obj/item/stack/thing_stack = thing_item
				amount = thing_stack.amount
		if(!thing_name)
			continue
		var/thing_cost
		var/datum/uplink_item/uplink_entry = get_item_uplink_entry(thing_type)
		if(uplink_entry)
			thing_name = uplink_entry.name
			thing_desc = uplink_entry.desc
			thing_cost = uplink_entry.cost
		var/list/existing = summary[thing_name]
		if(existing)
			existing[1] += amount
		else
			summary[thing_name] = list(amount, thing_icon, thing_cost, thing_desc)
	return summary

/// Used to create the uplink's item for generic use, rather than use by a Syndie specifically
/// Can be used to "de-restrict" some items, such as Nukie guns spawning with Syndicate pins
/datum/uplink_item/proc/spawn_item_for_generic_use(mob/user)
	var/atom/movable/created = new item(user.loc)

	if(isgun(created))
		replace_pin(created)
	else if(istype(created, /obj/item/storage/toolbox/guncase))
		for(var/obj/item/gun/gun in created)
			replace_pin(gun)

	if(isobj(created))
		var/obj/created_obj = created
		LAZYREMOVE(created_obj.req_access, ACCESS_SYNDICATE)
		LAZYREMOVE(created_obj.req_one_access, ACCESS_SYNDICATE)

	return created

/// Used by spawn_item_for_generic_use to replace the pin of a gun with a normal one
/datum/uplink_item/proc/replace_pin(obj/item/gun/gun_reward)
	PRIVATE_PROC(TRUE)

	if(!istype(gun_reward.pin, /obj/item/firing_pin/implant/pindicate))
		return

	QDEL_NULL(gun_reward.pin)
	gun_reward.pin = new /obj/item/firing_pin(gun_reward)

/// Spawns an item in the world
/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	if(!spawn_path)
		return
	var/atom/A
	if(ispath(spawn_path))
		A = new spawn_path(get_turf(user))
	else
		A = spawn_path
	if(refundable)
		A.AddElement(/datum/element/uplink_reimburse, (refund_amount ? refund_amount : cost))
	if(ishuman(user) && isitem(A))
		var/mob/living/carbon/human/H = user
		if(H.put_in_hands(A))
			to_chat(H, span_boldnotice("[A] materializes into your hands!"))
			return A
	to_chat(user, span_boldnotice("[A] materializes onto the floor!"))
	return A

///Override for any unique checks for specific items, by default returns TRUE
/datum/uplink_item/proc/unique_checks(mob/user, datum/uplink_handler/handler, atom/movable/source)
	return TRUE

/datum/uplink_category/discounts
	name = "Discounted Gear"
	weight = -1

/datum/uplink_category/discount_team_gear
	name = "Discounted Team Gear"
	weight = -1

/datum/uplink_category/limited_discount_team_gear
	name = "Limited Stock Team Gear"
	weight = -2

//Discounts (dynamically filled above)
/datum/uplink_item/discounts
	category = /datum/uplink_category/discounts

// Special equipment (Dynamically fills in uplink component)
/datum/uplink_item/special_equipment
	category = "Objective-Specific Equipment"
	name = "Objective-Specific Equipment"
	desc = "Equipment necessary for accomplishing specific objectives. If you are seeing this, something has gone wrong."
	limited_stock = 1
	illegal_tech = FALSE

/datum/uplink_item/special_equipment/purchase(mob/user, datum/component/uplink/U)
	..()
	if(user?.mind?.failed_special_equipment)
		user.mind.failed_special_equipment -= item

/// Code that enables the ability to have limited stock that is shared by different items
/datum/shared_uplink_stock
