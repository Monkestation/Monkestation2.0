/datum/artifact_fault/whisper
	name = "Whispering Fault"
	trigger_chance = 75
	var/list/whispers = list("Help me!","I've seen your sins","Egg.","I see you.","Admin clown greif plz ban he.","They come for us.","It's almost time.")

	research_value = TECHWEB_DISCOUNT_MINOR / 4

/datum/artifact_fault/whisper/on_trigger()
	if(!length(whispers))
		return

	var/center_turf = get_turf(our_artifact.parent)

	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")

	for(var/mob/living/living in range(rand(7, 10), center_turf))
		to_chat(living, span_hear("[pick(whispers)]"))
