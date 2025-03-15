GLOBAL_VAR_INIT(player_deaths, 0)

/mob/living/carbon/human
	/// Has this player's death already incremented player_deaths?
	/// This is reset when revived.
	var/counted_death = FALSE

/mob/living/carbon/human/death(gibbed, cause_of_death)
	increment_death_counter()
	return ..()

/mob/living/carbon/human/revive(full_heal_flags, excess_healing, force_grab_ghost)
	. = ..()
	counted_death = FALSE

/mob/living/carbon/human/proc/increment_death_counter()
	// don't count the same death twice
	if(counted_death)
		return
	// don't count deaths before/after the round
	if(!SSticker.IsRoundInProgress())
		return
	// don't count admins screwing around on the lobby or at centcom
	var/area/our_area = get_area(src)
	if(istype(our_area, /area/misc/start) || istype(our_area, /area/centcom))
		return
	// don't count admins screwing around in general tbh
	if(IsAdminAdvancedProcCall())
		return
	// don't count deaths from non-player mobs
	if(!mind && !client)
		return
	counted_death = TRUE
	GLOB.player_deaths++

/mob/living/carbon/human/dummy/increment_death_counter()
	return

/mob/living/carbon/human/ghost/increment_death_counter()
	return

/mob/living/carbon/human/cult_ghost/increment_death_counter()
	return
