/datum/enchantment/sharpness
	examine_description = "It has been blessed with the gift of sharpness."
	max_level = 5

/datum/enchantment/sharpness/apply_effect(obj/item/target, level)
	target.force += 2 * level
