/mob/living/Logout()
	lastclienttime = world.time
	set_ssd_indicator(TRUE)
	update_z(null)
	..()
	if(!key && mind) //key and mind have become separated.
		mind.active = FALSE //This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
	med_hud_set_status()
	process_as_clientless_mob()
