/obj/item/gps
	/// If TRUE, then this GPS needs to be calibrated to point to specific z-levels.
	var/requires_z_calibration = TRUE

/obj/item/gps/Initialize(mapload)
	. = ..()
	add_gps_component(mapload)

/// Adds the GPS component to this item.
/obj/item/gps/proc/add_gps_component(mapload = FALSE)
	var/list/calibrate_zs
	var/turf/our_turf = get_turf(src)
	if(our_turf)
		if(is_station_level(our_turf.z))
			calibrate_zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
		else if(mapload)
			calibrate_zs = list(our_turf.z)
	AddComponent(/datum/component/gps/item, gpstag, requires_z_calibration = requires_z_calibration, calibrate_zs = calibrate_zs)
