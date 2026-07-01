
/obj/item/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	obj_flags = UNIQUE_RENAME
	var/gpstag
	/// If TRUE, then this GPS needs to be calibrated to point to specific z-levels.
	var/requires_z_calibration = TRUE

/obj/item/gps/Initialize(mapload)
	. = ..()
	add_gps_component(mapload)

/// Adds the GPS component to this item.
/obj/item/gps/proc/add_gps_component(mapload = FALSE)
	var/list/calibrate_zs
	if(requires_z_calibration) // don't waste time with this if we don't need z-calibration in the first place
		var/turf/our_turf = get_turf(src)
		if(our_turf)
			if(is_station_level(our_turf.z))
				calibrate_zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
			else if(mapload)
				calibrate_zs = list(our_turf.z)
	AddComponent(/datum/component/gps/item, gpstag, requires_z_calibration = requires_z_calibration, calibrate_zs = calibrate_zs)

/obj/item/gps/advanced
	name = "advanced global positioning system"
	desc = "An advanced variant of the usual GPS, capable of navigating across vast distances of space without a calibration process."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "gps-a"
	requires_z_calibration = FALSE
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 1.5,
	)

/obj/item/gps/spaceruin
	gpstag = SPACE_SIGNAL_GPSTAG

/obj/item/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/medical
	desc = "A variention on the standard GPS Model, purposed for finding signals of those who have been lost. This one is in blue!"
	icon_state = "gps-c"
	gpstag = "PARA0"

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."

/obj/item/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/*
 * GPS for pAIS, which only allows access if it's contained within the user.
 */
/obj/item/gps/pai
	gpstag = "PAI0"

/obj/item/gps/pai/add_gps_component()
	AddComponent(/datum/component/gps/item, gpstag, state = GLOB.inventory_state)

/obj/item/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	var/list/turf/tagged

/obj/item/gps/visible_debug/Initialize(mapload)
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = MAPTEXT("[T.x],[T.y],[T.z]")
		tagged |= T

/obj/item/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()
