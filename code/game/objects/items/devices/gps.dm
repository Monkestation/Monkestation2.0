
/obj/item/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	verb_say = "beeps"
	verb_yell = "blares"
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

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."

/obj/item/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/advanced
	name = "advanced global positioning system"
	desc = "An advanced variant of the usual GPS, capable of navigating across vast distances of space without a calibration process."
	icon_state = "gps-a"
	requires_z_calibration = FALSE
	custom_materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 1.5,
	)

/obj/item/gps/medical
	desc = "A variention on the standard GPS Model, purposed for finding signals of those who have been lost. This one is in blue!"
	icon_state = "gps-med"
	gpstag = "PARA0"

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

/obj/item/gps/security
	name = "secure global positioning system"
	desc = "A security GPS device. Sounds an alarm if seperated from its wearer, be it by stripping or death."
	icon_state = "gps-sec"
	gpstag = "SEC0"
	var/datum/component/gps/item/security_gps/gps_component
	var/mob/living/tracked_mob
	COOLDOWN_DECLARE(yellow_alert_cooldown)
	var/can_play_jam_sound = TRUE
	var/yellow_alerts_issued = 0
	var/yellow_alerts_issued_maximum = 2
	var/yellow_alert_interval = 5 MINUTES

/obj/item/gps/security/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_GPS_TOGGLED_TRACKING, PROC_REF(gps_tracking_toggled))

/obj/item/gps/security/Destroy(force)
	. = ..()
	UnregisterSignal(src, COMSIG_GPS_TOGGLED_TRACKING)
	UnregisterSignal(tracked_mob, COMSIG_LIVING_DEATH)
	UnregisterSignal(tracked_mob, COMSIG_LIVING_FAKE_DEATH)
	QDEL_NULL(tracked_mob)
	QDEL_NULL(gps_component)

/obj/item/gps/security/add_gps_component(mapload = FALSE)
	var/list/calibrate_zs
	if(requires_z_calibration) // don't waste time with this if we don't need z-calibration in the first place
		var/turf/our_turf = get_turf(src)
		if(our_turf)
			if(is_station_level(our_turf.z))
				calibrate_zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
			else if(mapload)
				calibrate_zs = list(our_turf.z)
	AddComponent(/datum/component/gps/item/security_gps, gpstag, requires_z_calibration = requires_z_calibration, calibrate_zs = calibrate_zs)
	gps_component = GetComponent(/datum/component/gps/item/security_gps)

/obj/item/gps/security/proc/gps_tracking_toggled(tracking)
	SIGNAL_HANDLER

	if(tracking && !(obj_flags & EMAGGED))
		START_PROCESSING(SSobj, src)
	else
		yellow_alerts_issued = 0
		UnregisterSignal(tracked_mob, COMSIG_LIVING_DEATH)
		UnregisterSignal(tracked_mob, COMSIG_LIVING_FAKE_DEATH)
		STOP_PROCESSING(SSobj, src)

/obj/item/gps/security/process()
	//look for a mob in either our location
	if(obj_flags & EMAGGED || !gps_component.tracking)
		UnregisterSignal(tracked_mob, COMSIG_LIVING_DEATH)
		UnregisterSignal(tracked_mob, COMSIG_LIVING_FAKE_DEATH)
		tracked_mob = null
		return PROCESS_KILL
	var/atom/object = src
	while(!ismob(object))
		object = object.loc
		if(isnull(object))
			break

	if(!ismob(object))
		UnregisterSignal(tracked_mob, COMSIG_LIVING_DEATH)
		UnregisterSignal(tracked_mob, COMSIG_LIVING_FAKE_DEATH)
		tracked_mob = null
		if(COOLDOWN_FINISHED(src, yellow_alert_cooldown))
			COOLDOWN_START(src, yellow_alert_cooldown, yellow_alert_interval)
			SEND_SIGNAL(src, COMSIG_SEC_GPS_ALERT, "Code YELLOW")
			yellow_alerts_issued++
			if(yellow_alerts_issued >= yellow_alerts_issued_maximum && gps_component.tracking)
				gps_component.toggletracking()
				yellow_alerts_issued = 0
				return PROCESS_KILL
			return
		return

	var/mob/living/current_mob = object
	yellow_alerts_issued = 0

	if(tracked_mob == current_mob)
		return

	UnregisterSignal(tracked_mob, COMSIG_LIVING_DEATH)
	UnregisterSignal(tracked_mob, COMSIG_LIVING_FAKE_DEATH)
	tracked_mob = current_mob
	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(current_mob, COMSIG_LIVING_FAKE_DEATH, PROC_REF(on_death))

/obj/item/gps/security/proc/on_death()
	SEND_SIGNAL(src, COMSIG_SEC_GPS_ALERT, "Code RED")

/obj/item/gps/security/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	do_sparks(3, FALSE, src)
	sleep(1 SECOND)
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
	gps_component.jammed = TRUE
	gps_component.handle_overlay()
	balloon_alert(user, "jamming signal created!")
