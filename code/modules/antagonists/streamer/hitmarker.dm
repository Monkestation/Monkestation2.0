
/atom/movable/proc/do_hitmarker(mob/shooter)
	spawn()
		var/datum/antagonist/streamer/streamer_role = shooter?.mind?.has_antag_datum(/datum/antagonist/streamer)
		if(streamer_role?.team == "Security")
			streamer_role.hits += 1
			streamer_role.update_streamer_hud()
			//playsound(src, 'monkestation/code/modules/bloody_cult/sound/hitmarker.ogg', 100, FALSE)
			var/image/hitmarker = image(icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', loc = src, icon_state = "hitmarker")
			for(var/client/C in GLOB.clients)
				C.images += hitmarker
			sleep(3)
			for(var/client/C in GLOB.clients)
				C.images -= hitmarker
