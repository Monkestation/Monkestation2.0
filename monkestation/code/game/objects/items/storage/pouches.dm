
/obj/item/storage/bag/medipen
	name = "Medipen Pouch"
	icon = 'monkestation/icons/obj/storage/pouches.dmi'
	icon_state = "medipenpouch"
	worn_icon_state = "nothing"
	desc = "A small bag made to safely store up to 11 medipens of any kind. Hooks onto the pockets of any uniform."
	resistance_flags = FIRE_PROOF

/obj/item/storage/bag/medipen/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 11
	atom_storage.max_slots = 11
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/hypospray/medipen
		))
