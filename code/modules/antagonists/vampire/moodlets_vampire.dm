/datum/mood_event/drankblood
	description = span_nicegreen("I have fed greedily from that which nourishes me.")
	mood_change = 10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = span_boldwarning("I drank the blood of a lesser creature. Disgusting.")
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = span_boldwarning("I drank dead blood. I am better than this.")
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = span_boldwarning("I drank synthetic blood. What is wrong with me?")
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = span_boldwarning("I drained a mortal to death. I feel... inhuman.")
	mood_change = -15
	timeout = 10 MINUTES

// otherwise the next feed would wash the kill off your conscience
/datum/mood_event/drankkilled/be_replaced(datum/mood/home, datum/mood_event/new_event, ...)
	return BLOCK_NEW_MOOD

/datum/mood_event/coffinsleep
	description = span_nicegreen("I slept in a coffin during the day. I feel whole again.")
	mood_change = 10
	timeout = 6 MINUTES

///Candelabrum's mood event to non Vampire/Vassals
/datum/mood_event/vampcandle
	description = span_boldwarning("You feel something crawling in your mind...")
	mood_change = -15
	timeout = 5 MINUTES

/datum/mood_event/vassal_happy
	description = span_awe("I feel complete when I'm near my master...")
	mood_change = 10
	hidden = TRUE

/datum/mood_event/vassal_away
	description = span_warning("I crave my master's presence...")
	mood_change = -5
	hidden = TRUE

/datum/mood_event/vassal_away_severe //not hidden since it's so severe
	description = span_awe(span_big("I feel so empty being away from my master for so long..."))
	mood_change = -30

/datum/mood_event/lasombra_dread
	description = span_boldwarning("Something in that darkness was looking at me.")
	mood_change = -6
	timeout = 2 MINUTES

/datum/mood_event/blood_bond
	description = span_awe("I had the sweetest drink. I want more...")
	mood_change = 4
	timeout = 15 MINUTES
