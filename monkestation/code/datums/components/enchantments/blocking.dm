//might have to change this due to us having TG instead of bee blocking
/datum/enchantment/blocking
	examine_description = "It has been blessed with the gift of blocking."
	max_level = 3

/datum/enchantment/blocking/apply_effect(obj/item/target, level)
	target.block_chance += 5 * level
