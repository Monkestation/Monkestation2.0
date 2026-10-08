/datum/round_event_control/wizard/fake_explosion //Oh no the station is gone!
	name = "Fake Nuclear Explosion"
	weight = 0
	typepath = /datum/round_event/wizard/fake_explosion
	max_occurrences = 1
	earliest_start = 0 MINUTES
	description = "The nuclear explosion cutscene begins to play to scare the crew."

/datum/round_event_control/wizard/fake_explosion/New()
	. = ..()
	if(prob(50)) //combined with being a wizard event this should make the event quite rare
		weight = 1

/datum/round_event/wizard/fake_explosion
	end_when = 130 //should take around ~110 seconds total so this ensures everything can clean up correctly

/datum/round_event/wizard/fake_explosion/start()
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	addtimer(CALLBACK(src, PROC_REF(do_explosion)), 90 SECONDS)

/datum/round_event/wizard/fake_explosion/proc/do_explosion()
	sound_to_playing_players('sound/machines/alarm.ogg')
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(play_cinematic), /datum/cinematic/nuke/fake, world), 10 SECONDS)
