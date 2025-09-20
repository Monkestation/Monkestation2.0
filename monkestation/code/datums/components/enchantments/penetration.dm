/datum/enchantment/penetration
	examine_description = "It has been blessed with the gift of armor penetration, allowing it to cut through targets with ease."
	max_level = 5

/datum/enchantment/penetration/apply_effect(obj/item/target, level)
	target.armour_penetration = max(15 * level, target.armour_penetration)
