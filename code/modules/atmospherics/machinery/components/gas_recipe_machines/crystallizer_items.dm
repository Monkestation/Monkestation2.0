/obj/item/hypernoblium_crystal
	name = "Hypernoblium Crystal"
	desc = "Crystalized oxygen and hypernoblium stored in a bottle to pressureproof your clothes or stop reactions occuring in portable atmospheric devices."
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "hypernoblium_crystal"
	var/uses = 1

// monkestation start: allow using on storage items via right clicking or combat mode
/obj/item/hypernoblium_crystal/attackby_storage_insert(datum/storage, atom/storage_holder, mob/living/user)
	return !(user?.istate & (ISTATE_HARM | ISTATE_SECONDARY))
// monkestation end

/obj/item/hypernoblium_crystal/afterattack(obj/target_object, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/obj/machinery/portable_atmospherics/atmos_device = target_object
	if(istype(atmos_device))
		if(atmos_device.nob_crystal_inserted)
			to_chat(user, span_warning("[atmos_device] already has a hypernoblium crystal inserted in it!"))
			return
		atmos_device.nob_crystal_inserted = TRUE
		to_chat(user, span_notice("You insert the [src] into [atmos_device]."))
	var/obj/item/clothing/worn_item = target_object
	if(!istype(worn_item) && !istype(atmos_device))
		to_chat(user, span_warning("The crystal can only be used on clothing and portable atmospheric devices!"))
		return
	if(istype(worn_item))
		if(istype(worn_item, /obj/item/clothing/suit/space))
			to_chat(user, span_warning("The [worn_item] is already pressure-resistant!"))
			return
		if(worn_item.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && (worn_item.clothing_flags & STOPSPRESSUREDAMAGE))
			to_chat(user, span_warning("[worn_item] is already pressure-resistant!"))
			return
		to_chat(user, span_notice("You see how the [worn_item] changes color, it's now pressure proof."))
		worn_item.name = "pressure-resistant [worn_item.name]"
		worn_item.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		worn_item.add_atom_colour("#00fff7", FIXED_COLOUR_PRIORITY)
		worn_item.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		worn_item.clothing_flags |= STOPSPRESSUREDAMAGE
	uses--
	if(!uses)
		qdel(src)

/obj/item/halon_crystal
	name = "halon crystal"
	desc = "A crystal made from halon and hyper-noblium that will fireproof any article of clothing."
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "halon_crystal"
	resistance_flags = FIRE_PROOF

/obj/item/halon_crystal/attackby_storage_insert(datum/storage, atom/storage_holder, mob/living/user)
	return !(user?.istate & (ISTATE_HARM | ISTATE_SECONDARY))

/obj/item/halon_crystal/afterattack(obj/item/clothing/clothing, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!istype(clothing))
		to_chat(user, span_warning("The crystal can only be used on clothing!"))
		return
	if(clothing.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		to_chat(user, span_warning("\The [clothing] is already fireproof!"))
		return
	to_chat(user, span_notice("You crush the crystal against [clothing], fireproofing it."))
	clothing.name = "fireproofed [clothing.name]"
	clothing.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	clothing.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	clothing.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	clothing.resistance_flags |= FIRE_PROOF
	qdel(src)

/obj/item/hexane_crystal
	name = "hexane crystal"
	desc = "Potent radiation shield made from hexane and carbon dioxide. Has two uses."
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "hexane_crystal"
	var/uses = 2

/obj/item/hexane_crystal/attackby_storage_insert(datum/storage, atom/storage_holder, mob/living/user)
	return !(user?.istate & (ISTATE_HARM | ISTATE_SECONDARY))

/obj/item/hexane_crystal/afterattack(obj/item/clothing/clothing, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!uses)
		qdel(src)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!istype(clothing))
		to_chat(user, span_warning("The crystal can only be used on clothing!"))
		return
	if(HAS_TRAIT(clothing, TRAIT_RADIATION_PROTECTED_CLOTHING))
		to_chat(user, span_warning("\The [clothing] is already shielded against radiation!"))
		return
	to_chat(user, span_notice("You crush the crystal against [clothing], shielding it from radiation."))
	clothing.name = "rad-shielded [clothing.name]"
	clothing.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	clothing.add_atom_colour("#f870f1", FIXED_COLOUR_PRIORITY)
	ADD_TRAIT(clothing, TRAIT_RADIATION_PROTECTED_CLOTHING, src)
	uses --
	if(!uses)
		qdel(src)
