/obj/item/radio/intercom
	/// The proximity monitor used to allow people to hear DJ music while in hearing range.
	var/datum/proximity_monitor/advanced/dj_music/music_field

/obj/item/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	var/range = isnull(listening_range) ? canhear_range : listening_range
	if(isturf(loc) && range > 0 && (is_station_level(loc.z) || is_centcom_level(loc.z)))
		music_field = new(src, range)

/obj/item/radio/intercom/Destroy()
	QDEL_NULL(music_field)
	return ..()
