// You will kill people if you use non station ones, have fun :)

/turf/open/misc/dirt/station
	gender = PLURAL
	name = "dirt flooring"
	desc = "You heard this place was dirty, but this is just absurd."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	base_icon_state = "dirt"
	baseturfs = /turf/open/floor/plating
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/misc/dirt/station/jungle/dark/
	icon_state = "greenerdirt"
	base_icon_state = "greenerdirt"

/turf/open/misc/dirt/station/jungle/wasteland //Like a more fun version of living in Arizona. This one won't kill people tho.
	name = "cracked dirt"
	desc = "Looks a bit dry, you can see the plating under it."
	icon = 'icons/turf/floors.dmi'
	icon_state = "wasteland"
	base_icon_state = "wasteland"
	var/floor_variance = 15

/turf/open/misc/grass/jungle/station
	name = "artificial jungle grass"
	baseturfs = /turf/open/misc/dirt/station
	desc = "Greener on the other side, this one is fake due to the 2564 accident where grass started to eat people."
	icon_state = "junglegrass"
	base_icon_state = "junglegrass"
	damaged_dmi = 'icons/turf/floors/junglegrass.dmi'
	smooth_icon = 'icons/turf/floors/junglegrass.dmi'
