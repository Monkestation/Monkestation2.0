/turf/closed/wall/r_wall/fakewood
	desc = "A huge chunk of reinforced metal used to separate rooms. This one has been painted like a log."
	color = COLOR_ORANGE_BROWN

/turf/open/water/jungle/biodome
	name="Biodome Lake"

/turf/open/water/jungle/biodome/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/ocean/beach)

/turf/open/misc/ashplanet/wateryrock/biodome
	name="Biodome Lake Rocks"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/lava/plasma/biodome
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	baseturfs = /turf/open/lava/plasma/biodome

/turf/open/floor/fake_iron_sand
	desc = "Wait a minute. This martian soil is just painted on!"
	icon_state = "ironsand1"
	base_icon_state = "ironsand1"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/fake_iron_sand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/open/floor/fake_iron_sand/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/fake_iron_sand/crowbar_act(mob/living/user, obj/item/I)
	return


/turf/open/floor/fake_snow/safe
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	slowdown = 0

/turf/open/floor/wood/stairs
	icon = 'monkestation/code/modules/biodome/icons/floor.dmi'
	icon_state = "woodstairs_up"

/turf/open/floor/wood/stairs/down
	icon_state = "woodstairs_down"

/turf/open/floor/wood/stairs/left
	icon_state = "woodstairs_left"

/turf/open/floor/wood/stairs/right
	icon_state = "woodstairs_right"

/turf/open/misc/beach/coast
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon_state = "sandwater_t"
	base_icon_state = "sandwater_t"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/misc/beach/coast/break_tile()
	. = ..()
	icon_state = "sandwater_t"

/turf/open/misc/beach/coast/corner
	icon_state = "sandwater_inner"
	base_icon_state = "sandwater_inner"

/turf/open/misc/beach/coast/corner/break_tile()
	. = ..()
	icon_state = "sandwater_inner"

/turf/closed/mineral/random/regrowth/station
	turf_transforms = FALSE
	color = "#9dfa8b"

	turf_type = /turf/open/misc/asteroid/airless
	baseturfs = /turf/open/misc/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	defer_change = TRUE
