/datum/round_event_control/wizard/blobies //avast!
	name = "Blob Zombie Outbreak"
	weight = 3
	typepath = /datum/round_event/wizard/blobies
	max_occurrences = 3
	description = "Spawns a blob spore on every corpse on the station."
	min_wizard_trigger_potency = 5
	max_wizard_trigger_potency = 100

/datum/round_event/wizard/blobies/start()
	for(var/mob/living/carbon/human/dead_human in GLOB.dead_mob_list)
		var/turf/human_turf = get_turf(dead_human)
		if(is_station_level(human_turf.z))
			new /mob/living/basic/blob_minion/spore/minion(dead_human.loc) // Creates zombies which ghosts can control
