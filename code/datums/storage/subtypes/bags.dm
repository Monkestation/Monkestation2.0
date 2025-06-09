///Rebar quiver bag
/datum/storage/bag/rebar_quiver
	max_specific_storage = WEIGHT_CLASS_TINY
	max_slots = 10
	max_total_storage = 15

/datum/storage/bag/rebar_quiver/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_casing/rebar,
	))

///Syndicate rebar quiver bag
/datum/storage/bag/rebar_quiver/syndicate
	max_slots = 20
	max_total_storage = 20
