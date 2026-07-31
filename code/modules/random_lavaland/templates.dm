#define BASE_PATH "_maps/map_files/Mining/"

// We need to be faster than mapgen/lava inits, else we're polluted with mobs and all catwalks are on fire.
INITIALIZE_IMMEDIATE(/obj/effect/spawner/lavabase_spawner)

/obj/effect/spawner/lavabase_spawner
	name = "Lavaland base spawner"
	desc = "A spawner that creates the lavaland mining base. \
		If you are an admin you can call the \"load\" proc on it to spawn the lavaland base, though its not supported. \
		If you aren't an admin then something went very wrong and you should bug-report this."
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"

/obj/effect/spawner/lavabase_spawner/Initialize(mapload)
	..()
	. = INITIALIZE_HINT_NORMAL
	if(!mapload)
		message_admins("[src] tried initializing on non-mapload, if this is due to an admin and you are SURE you \
			know what you are doing you can call the \"load\" proc on it.")
		stack_trace("[src] tried initializing on non-mapload, this should never happen.")
		return
	load()

/obj/effect/spawner/lavabase_spawner/proc/load()
	var/datum/map_template/lava_base/chosen_base = /datum/map_template/lava_base
	if(HAS_TRAIT(SSstation, STATION_TRAIT_RANDOM_LAVALAND))
		switch(rand(1, 2))
			if(1)
				chosen_base = /datum/map_template/lava_base/bee
			if(2)
				if(SSmapping.themed_ruins[ZTRAIT_LAVA_RUINS])
					chosen_base = /datum/map_template/lava_base/bee
					stack_trace("SSmapping.themed_ruins exists while [src] tried assigning a yogstation base, this should never happen.")
				else
					chosen_base = /datum/map_template/lava_base/yog
					var/datum/map_template/ruin/lavaland/yogs_base/base = new()
					base.id = "yog-base-ruin"
					SSmapping.themed_ruins[ZTRAIT_LAVA_RUINS] = list()
					SSmapping.themed_ruins[ZTRAIT_LAVA_RUINS][base.name] = base

	chosen_base = new chosen_base()
	chosen_base.load(get_turf(src))
	qdel(chosen_base)
	qdel(src)

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
