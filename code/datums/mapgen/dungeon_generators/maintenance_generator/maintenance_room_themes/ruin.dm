/// Rooms with the size of a maint ruin, that get one of the random room templates loaded in them
/datum/dungeon_room_theme/maintenance/ruin
	room_type = ROOM_TYPE_RUIN

/datum/dungeon_room_theme/maintenance/ruin/pre_initialize()
	. = ..()
	var/width_without_walls = dungeon_room_ref.width-2
	var/height_without_walls = dungeon_room_ref.height-2

	switch("[width_without_walls]x[height_without_walls]")
		if("3x3")
			special_feature = /obj/effect/spawner/room/threexthree/reusable
		if("3x5")
			special_feature = /obj/effect/spawner/room/threexfive/reusable
		if("5x3")
			special_feature = /obj/effect/spawner/room/fivexthree/reusable
		if("5x4")
			special_feature = /obj/effect/spawner/room/fivexfour/reusable
		if("10x5")
			special_feature = /obj/effect/spawner/room/tenxfive/reusable
		if("10x10")
			special_feature = /obj/effect/spawner/room/tenxten/reusable

// Room spawners that can repeat rooms, so a whole z-level of generated maintenance doesn't run out of them
/obj/effect/spawner/room/threexthree/reusable
	uses_stock = FALSE

/obj/effect/spawner/room/threexfive/reusable
	uses_stock = FALSE

/obj/effect/spawner/room/fivexthree/reusable
	uses_stock = FALSE

/obj/effect/spawner/room/fivexfour/reusable
	uses_stock = FALSE

/obj/effect/spawner/room/tenxfive/reusable
	uses_stock = FALSE

/obj/effect/spawner/room/tenxten/reusable
	uses_stock = FALSE
