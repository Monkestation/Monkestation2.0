/datum/mood_event/nanite_sadness
	description = "+++++++HAPPINESS SUPPRESSION+++++++</span>"
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = "<span class='warning robot'>+++++++[message]+++++++</span>"

/datum/mood_event/superfart_armed
	description = "MUST... FART..."
	mood_change = -20

/datum/mood_event/syndi_propaganda
	description = "Hearing Syndicate propaganda is unnerving."
	mood_change = -1
	timeout = 4 MINUTES

/datum/mood_event/syndi_propaganda/add_effects(is_speaker)
	if (is_speaker)
		mood_change *= 2

/datum/mood_event/syndi_propaganda/authority
	description = "The Syndicate propaganda might be corrupting the rest of the crew."
	timeout = 2 MINUTE
