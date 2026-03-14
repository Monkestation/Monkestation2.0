// These are used in uplink_devices.dm to determine whether or not an item is purchasable.

/// This item is purchasable to traitors
#define UPLINK_TRAITORS (1 << 0)

/// This item is purchasable to nuke ops
#define UPLINK_NUKE_OPS (1 << 1)

/// This item is purchasable to clown ops
#define UPLINK_CLOWN_OPS (1 << 2)

/// Progression gets turned into a user-friendly form. This is just an abstract equation that makes progression not too large.
#define DISPLAY_PROGRESSION(time) round(time/60, 0.01)

/// Traitor discount size categories
#define TRAITOR_DISCOUNT_BIG "big_discount"
#define TRAITOR_DISCOUNT_AVERAGE "average_discount"
#define TRAITOR_DISCOUNT_SMALL "small_discount"

/// Typepath used for uplink items which don't actually produce an item (essentially just a placeholder)
/// Future todo: Make this not necessary / make uplink items support item-less items natively
#define ABSTRACT_UPLINK_ITEM /obj/item/loot_table_maker

/// Minimal cost for an item to be eligible for a discount
#define TRAITOR_DISCOUNT_MIN_PRICE 4

#define STARTING_COMMON_CONTRACTS 3
#define STARTING_UNCOMMON_CONTRACTS 2
#define STARTING_RARE_CONTRACTS 1
/datum/component/uplink/proc/become_contractor()
	uplink_handler.uplink_flag = UPLINK_CONTRACTORS
	uplink_handler.clear_secondaries()
	uplink_handler.generate_objectives(list(
		/datum/traitor_objective/target_player/kidnapping/common = STARTING_COMMON_CONTRACTS,
		/datum/traitor_objective/target_player/kidnapping/uncommon = STARTING_UNCOMMON_CONTRACTS,
		/datum/traitor_objective/target_player/kidnapping/rare = STARTING_RARE_CONTRACTS,
	))
	for(var/item in subtypesof(/datum/contractor_item))
		uplink_handler.contractor_market_items += new item

#undef STARTING_COMMON_CONTRACTS
#undef STARTING_UNCOMMON_CONTRACTS
#undef STARTING_RARE_CONTRACTS
