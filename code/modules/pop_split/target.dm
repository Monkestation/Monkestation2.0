// target.dm - Target server code for rebooting and checking if we can safely reboot

/datum/world_topic/can_empty_reboot
	keyword = "can_empty_reboot"
	require_comms_key = TRUE

/datum/world_topic/can_empty_reboot/Run(list/input)
	return world.CanEmptyReboot()

/datum/world_topic/reboot
	keyword = "reboot"
	require_comms_key = TRUE

/datum/world_topic/reboot/Run(list/input)
	if(!input["force"] && !world.CanEmptyReboot())
		return FALSE

	// We want a HARD restart. none of that fancy shit.
	CONFIG_SET(number/rounds_until_hard_restart, 0)
	spawn(1 SECOND)
		world.Reboot("Reboot by Topic", TRUE)

	return TRUE

/world/proc/CanEmptyReboot()
	// Check if the round is ended. If the round is ended (or at least 30 seconds after roundend),
	// and no admins online (if open tickets) OR admins online and no open tickets and there's no admins
	// actively trying to message someone, fuck it and return true
	if(SSticker.current_state == GAME_STATE_FINISHED)
		// there are active tickets!! check if theres an admin on
		if(length(GLOB.ahelp_tickets.active_tickets))
			for(var/client/client as anything in GLOB.clients)
				if(check_rights_for(client, R_ADMIN))
					return FALSE

	// Check for carbon mobs.
	for(var/mob/mob in GLOB.player_list)
		if((iscarbon(mob) || isdrone(mob) || issilicon(mob)) && (mob.stat != DEAD) && !QDELETED(mob.client))
			return FALSE

	// All mobs are dead, there's no clients or there's just lobby players.
	return TRUE

