/// Areas whose turfs get filled with rooms by a dungeon generator. Areas on the same z-level with the same generator share it
/area/procedurally_generated
	name = "Dungeon"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	map_generator = /datum/map_generator/dungeon_generator
	area_flags = NONE

	///If there's other areas on the same z-level that share a generator, their turfs will be aggregated together into a combined working area
	var/shared_generator_initialized = FALSE

/area/procedurally_generated/RunTerrainGeneration()
	if(ispath(map_generator))
		map_generator = new map_generator(src)
		map_generator.combine_local_areas()

	if(!shared_generator_initialized)
		map_generator.generate_terrain()

/area/procedurally_generated/test_gen()
	if(!ispath(map_generator))
		map_generator.generate_terrain()
