SUBSYSTEM_DEF(sound_tokens)
	name = "Sound Tokens"
	wait = 1
	flags = SS_TICKER | SS_BACKGROUND | SS_NO_INIT

	/// Assoc list of clients that moved or need their sound tokens recalculated -> TRUE
	var/list/clients_needing_update = list()
	/// Clients still left to process in the current run
	var/list/currentrun = list()

/datum/controller/subsystem/sound_tokens/fire(resumed)
	if(!resumed)
		currentrun = clients_needing_update
		clients_needing_update = list()
	while(length(currentrun))
		var/client/client = currentrun[currentrun.len]
		currentrun.len--
		var/mob/owned_mob = client.mob
		for(var/datum/sound_token/token as anything in owned_mob?.sound_tokens)
			token.update_listener(owned_mob)
		if(MC_TICK_CHECK)
			break
