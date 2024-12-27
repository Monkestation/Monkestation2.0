/proc/attempt_enchantment(obj/item/enchanted, list/valid_enchant_types = subtypesof(/datum/enchantment), description_span = "<span class='purple'>", level_override)
	if(!isitem(enchanted))
		return FALSE

	if(!length(GLOB.enchantment_datums_by_type))
		generate_enchantment_datums()

	for(var/datum/enchantment/enchant as anything in valid_enchant_types)
		valid_enchant_types -= enchant
		enchant = GLOB.enchantment_datums_by_type[enchant]
		if(enchant.can_apply_to(enchanted))
			valid_enchant_types += enchant

	if(!length(valid_enchant_types))
		return FALSE
	return enchanted.AddComponent(/datum/component/enchanted, valid_enchant_types, description_span, level_override)

/proc/generate_enchantment_datums()
	for(var/datum/enchantment/enchant as anything in subtypesof(/datum/enchantment))
		GLOB.enchantment_datums_by_type[enchant] = new enchant()
