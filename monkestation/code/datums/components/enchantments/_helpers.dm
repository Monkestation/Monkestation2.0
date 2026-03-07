/proc/attempt_enchantment(obj/item/enchanted, list/enchant_types = subtypesof(/datum/enchantment), description_span = "<span class='purple'>", level_override)
	if(!isitem(enchanted))
		return FALSE

	if(!length(GLOB.enchantment_datums_by_type))
		generate_enchantment_datums()

	if(!islist(enchant_types))
		enchant_types = list(enchant_types)

	var/list/valid_enchant_types = list()
	for(var/datum/enchantment/enchant as anything in enchant_types)
		enchant = GLOB.enchantment_datums_by_type[enchant]
		if(enchant.can_apply_to(enchanted))
			valid_enchant_types += enchant

	if(!length(valid_enchant_types))
		return FALSE
	return enchanted.AddComponent(/datum/component/enchanted, valid_enchant_types, description_span, level_override)

/proc/generate_enchantment_datums()
	for(var/datum/enchantment/enchant as anything in subtypesof(/datum/enchantment))
		GLOB.enchantment_datums_by_type[enchant] = new enchant()
