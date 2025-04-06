/obj/item/mod/control/can_call()
	return ..() && verify_mod_caller(wearer)

/obj/item/clothing/neck/link_scryer/can_call()
	return ..() && verify_mod_caller(loc)

/proc/verify_mod_caller(mob/living/link_caller)
	if(SSticker.current_state == GAME_STATE_FINISHED)
		return TRUE
	if(istype(link_caller, /mob/living/carbon/human/ghost))
		return FALSE
	var/area/area = get_area(link_caller)
	if(area.area_flags & GHOST_AREA)
		return FALSE
	return TRUE
