/obj/item/mod/control/can_call()
	if(isnull(wearer?.loc) || istype(wearer, /mob/living/carbon/human/dummy)) // completely skip checks if this is the case
		return FALSE
	return ..() && verify_mod_caller(wearer)

/obj/item/clothing/neck/link_scryer/can_call()
	if(isnull(loc?.loc) || istype(loc, /mob/living/carbon/human/dummy)) // completely skip checks if this is the case
		return FALSE
	return ..() && verify_mod_caller(loc)

/proc/verify_mod_caller(mob/living/link_caller)
	if(SSticker.current_state == GAME_STATE_FINISHED)
		return TRUE
	if(istype(link_caller, /mob/living/carbon/human/ghost))
		return FALSE
	var/area/area = get_area(link_caller)
	if(isnull(area) || (area.area_flags & GHOST_AREA))
		return FALSE
	return TRUE

GLOBAL_LIST_INIT(scryer_auto_link_freqs, zebra_typecacheof(list(
	/area/station = MODLINK_FREQ_NANOTRASEN,
	/area/ruin/space/ancientstation = MODLINK_FREQ_CHARLIE,
	/area/ruin/space/has_grav/syndicate_depot = MODLINK_FREQ_SYNDICATE,
)))

/// Scryer that automatically links based on area/Z-level
/obj/item/clothing/neck/link_scryer/auto_link/Initialize(mapload)
	. = ..()
	var/turf/turf = get_turf(src)
	if(isnull(turf))
		return
	if(is_station_level(turf.z))
		mod_link.frequency = MODLINK_FREQ_NANOTRASEN
		return
	var/area/area = get_area(turf)
	if(!isnull(GLOB.scryer_auto_link_freqs[area.type]))
		mod_link.frequency = GLOB.scryer_auto_link_freqs[area.type]

