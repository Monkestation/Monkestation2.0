///Crayons storage
/datum/storage/crayons/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(
		can_hold_list = /obj/item/toy/crayon,
		cant_hold_list = list(
			/obj/item/toy/crayon/spraycan,
			/obj/item/toy/crayon/mime,
			/obj/item/toy/crayon/rainbow,
		),
	)
