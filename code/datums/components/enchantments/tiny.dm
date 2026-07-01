/datum/enchantment/tiny
	examine_description = "It has been blessed and distorts reality into a tiny space around it."
	max_level = 1

/datum/enchantment/tiny/get_allowed_on(list/allowed_on_base, list/denied_from = list(), list/overriden_types)
	. = ..()

/datum/enchantment/tiny/apply_effect(obj/item/target)
	target.w_class = WEIGHT_CLASS_TINY
