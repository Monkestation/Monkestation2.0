/turf/open/water
	gender = PLURAL
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/chasm/lavaland
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	turf_flags = NO_RUST

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	astar_weight = 75
	///Do we give the player_sink component
	var/sinking = FALSE
	///If we have one then what should our player_sink max_sinkage be set to, leave unset for default sinkage
	var/max_sinkage

/turf/open/water/Initialize(mapload)
	. = ..()
	if(sinking)
		RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(try_add_sinking))

/turf/open/water/proc/try_add_sinking(turf/open/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(arrived.GetComponent(/datum/component/player_sink))
		return
	arrived.AddComponent(/datum/component/player_sink, max_sinkage = src.max_sinkage, type_to_add = src.type)

/turf/open/water/station
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE

/turf/open/water/jungle
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

//This version of the beach turf uses low pressure, inherieted from above
/turf/open/water/beach
	planetary_atmos = FALSE
	gender = PLURAL
	desc = "You get the feeling that nobody's bothered to actually make this water functional..."
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/beach

/turf/open/water/beach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/ocean/beach)

//Same turf, but instead used in the Beach Biodome
/turf/open/water/beach/biodome
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/water/beach/biodome/sinking
	name = "Water"
	desc = "You get the feeling that somebody's bothered to actually make this water partly functional..."
	sinking = TRUE

//the tram beachside bar has 1 tile of this
/turf/open/water/beach/biodome/sinking/deep
	max_sinkage = 28
