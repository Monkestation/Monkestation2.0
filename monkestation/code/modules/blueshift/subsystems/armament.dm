/**
 * Armament entries
 *
 * These are basic entries that are compiled into the global list of armaments.
 * It is strongly suggested that if you wish to make your own armaments station, you
 * create your own entries.
 *
 * Armament stations are capable of having a restricted list of products, which you should fill if you plan on making
 * your own station. This is the products variable. If you plan on using the premade list, you can leave this empty.
 *
 * Create your own file with all of the entries if you do wish to make your own custom armaments vendor.
 *
 * @author Gandalf2k15
 */

/*
*	ARMAMENT ENTRIES
*/

/datum/armament_entry
	/// The name of the equipment used in the listing, if not set, it will use the items name.
	var/name
	/// The description of the equipment used in the listing, if not set, it will use the items description.
	var/description
	/// The item path that we refer to when equipping. If left empty, it will be considered abstract.
	var/obj/item_type
	/// Category of the item. This is used to group items together in the UI.
	var/category = ARMAMENT_CATEGORY_STANDARD
	/// This is an abstract variable, only set this for base category types. It should not be overriden by subtypes. Set to 0 for infinite.
	var/category_item_limit = 0
	/// Our subcategory, where the item will be listed.
	var/subcategory = ARMAMENT_SUBCATEGORY_NONE
	/// The points cost of this item.
	var/cost = 0
	/// Defines what slot we will try to equip this item to.
	var/slot_to_equip = ITEM_SLOT_HANDS
	/// The maximum amount of this item that can be equipped.
	var/max_purchase = 1
	/// Do we have magazines for purchase?
	var/magazine
	/// If we have a magazine, how much is it?
	var/magazine_cost = 1
	/// Is this restricted for purchase in some form? Requires extra code in the vendor to function, used for guncargo.
	var/restricted = FALSE

/datum/armament_entry/proc/setup()
	if(ispath(item_type, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ballistic_type = item_type
		if(!ballistic_type::internal_magazine)
			magazine = ballistic_type::spawn_magazine_type

/// This proc handles how the item should be equipped to the player. This needs to return either TRUE or FALSE, TRUE being that it was able to equip the item.
/datum/armament_entry/proc/equip_to_human(mob/living/carbon/human/equipping_human, obj/item/item_to_equip)
	return equipping_human.equip_to_slot_if_possible(item_to_equip, slot_to_equip)

/datum/armament_entry/proc/after_equip(turf/safe_drop_location, obj/item/item_to_equip)
	return TRUE

/datum/armament_entry/company_import
	max_purchase = 0
	category_item_limit = 0
	cost = CARGO_CRATE_VALUE
	/// Bitflag of the company
	var/company_bitflag
	/// If this requires a multitooled console to be visible
	var/contraband = FALSE
