#define BASE_PATH "_maps/map_files/Mining/"

/datum/map_template/lava_base
	name = "TG lavaland base"
	mappath = BASE_PATH + "lavabase_tg.dmm" // "[BASE_PATH]lavabase_tg.dmm" is considered non-constant </3

/datum/map_template/lava_base/bee
	name = "Bee lavaland base"
	mappath = BASE_PATH + "lavabase_bee.dmm"

/datum/map_template/lava_base/yog
	name = "Yogs lavaland base (gulag)"
	mappath = BASE_PATH + "lavabase_yog_gulag.dmm"

/datum/map_template/ruin/lavaland/yogs_base
	name = "Yogs lavaland base"
//	id = "yog-base-ruin" Purposefully left out so SSmapping won't spawn us naturally
	description = "The Yogs lavaland base, gulag spawned seperatelly"
	prefix = BASE_PATH
	suffix = "lavabase_yog.dmm"
	allow_duplicates = FALSE
	always_place = TRUE

#undef BASE_PATH
