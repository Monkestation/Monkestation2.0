/datum/round_event/aurora_caelus/announce()
	priority_announce("[station_name()]: A harmless cloud of ions is approaching your station, and will exhaust their energy battering the hull. Nanotrasen has approved a short break for all employees to relax and observe this very rare event. During this time, starlight will be bright but gentle, shifting between quiet green and blue colors. Any staff who would like to view these lights for themselves may proceed to the area nearest to them with viewing ports to open space. We hope you enjoy the lights.",
	sound = 'sound/misc/notice2.ogg',
	sender_override = "Nanotrasen Meteorology Division")
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.read_preference(/datum/preference/toggle/sound_midi)) && is_station_level(M.z))
			M.playsound_local(M, pick('hippiestation/sound/ambience/auroraborealis.ogg','sound/ambience/aurora_caelus.ogg'), 20, FALSE, pressure_affected = FALSE)
