///Construction bag
/datum/storage/bag/construction
	max_total_storage = 100
	max_slots = 50
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/bag/construction/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/assembly,
		/obj/item/circuitboard,
		/obj/item/electronics,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/stack/cable_coil,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/stock_parts,
		/obj/item/wallframe/camera,
		/obj/item/stack/sheet,
		/obj/item/rcd_ammo,
		/obj/item/stack/rods,
	))

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
