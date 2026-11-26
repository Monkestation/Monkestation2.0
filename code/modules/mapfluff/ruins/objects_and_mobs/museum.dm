/obj/structure/fluff/dnamod
	name = "DNA Modifier"
	desc = "DNA Manipulator replica. Essentially just a box of cool lights."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE

/obj/structure/fluff/preserved_borer
	name = "preserved borer exhibit"
	desc = "A preserved cortical borer. Probably been there long enough to not last long outside the exhibit."
	icon = 'icons/obj/structures.dmi'
	icon_state = "preservedborer"
	density = TRUE

/obj/structure/fluff/balloon_nuke
	name = "nuclear balloon explosive"
	desc = "You probably shouldn't stick around to see if this is inflated."
	icon = /obj/machinery/nuclearbomb::icon
	icon_state = /obj/machinery/nuclearbomb::icon_state
	density = TRUE
	max_integrity = 5 //one tap

/obj/structure/fluff/balloon_nuke/atom_destruction()
	playsound(loc, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 75, vary = TRUE)
	..()

/obj/structure/fluff/fake_camera
	name = /obj/machinery/camera::name
	desc = /obj/machinery/camera::desc
	icon = /obj/machinery/camera::icon
	icon_state = /obj/machinery/camera::icon_state

/obj/structure/fluff/fake_scrubber
	name = /obj/machinery/atmospherics/components/unary/vent_scrubber::name
	desc = /obj/machinery/atmospherics/components/unary/vent_scrubber::desc
	icon = /obj/machinery/atmospherics/components/unary/vent_scrubber::icon
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "scrub_on"

/obj/structure/fluff/fake_vent
	name = /obj/machinery/atmospherics/components/unary/vent_pump::name
	desc = /obj/machinery/atmospherics/components/unary/vent_pump::desc
	icon = /obj/machinery/atmospherics/components/unary/vent_pump::icon
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "vent_out"
