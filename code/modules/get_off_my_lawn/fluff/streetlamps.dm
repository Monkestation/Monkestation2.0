/obj/machinery/light/street_lamp
	name = "street lamp"
	desc = "A old timey street lamp. Attracts moths!"
	icon = 'icons/obj/old_timey/lighting_32x64.dmi'
	icon_state = "streetlight"
	base_state = "streetlight"

	light_outer_range = 7
	light_angle = 360

/obj/machinery/light/street_lamp/get_turfs_to_mount_on()
	return list(get_turf(src))

/obj/machinery/light/street_lamp/is_mountable_turf(turf/target)
	return !isgroundlessturf(target)

/obj/machinery/light/street_lamp/get_mountable_objects()
	var/static/list/attachables = list(
		/obj/structure/thermoplastic,
		/obj/structure/lattice/catwalk,
	)

	return attachables
