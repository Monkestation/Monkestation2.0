//These are all minor mutations that affect your speech somehow.
//Individual ones aren't commented since their functions should be evident at a glance

/datum/mutation/nervousness
	name = "Nervousness"
	desc = "Causes the holder to stutter."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>You feel nervous.</span>"

/datum/mutation/nervousness/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(5, seconds_per_tick))
		owner.set_stutter_if_lower(20 SECONDS)

/datum/mutation/wacky
	name = "Wacky"
	desc = "You are not a clown. You are the entire circus."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='sans'><span class='infoplain'>You feel an off sensation in your voicebox.</span></span>"
	text_lose_indication = "<span class='notice'>The off sensation passes.</span>"

/datum/mutation/wacky/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/wacky/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/wacky/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= SPAN_SANS

/datum/mutation/mute
	name = "Mute"
	desc = "Completely inhibits the vocal section of the brain."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You feel unable to express yourself at all.</span>"
	text_lose_indication = "<span class='danger'>You feel able to speak freely again.</span>"

/datum/mutation/mute/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)

/datum/mutation/mute/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)

/datum/mutation/unintelligible
	name = "Unintelligible"
	desc = "Partially inhibits the vocal center of the brain, severely distorting speech."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>You can't seem to form any coherent thoughts!</span>"
	text_lose_indication = "<span class='danger'>Your mind feels more clear.</span>"

/datum/mutation/unintelligible/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/unintelligible/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/swedish
	name = "Swedish"
	desc = "A horrible mutation originating from the distant past. Thought to be eradicated after the incident in 2037."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("You feel Swedish, however that works.")
	text_lose_indication = span_notice("The feeling of Swedishness passes.")
	var/static/list/language_mutilation = list("w" = "v", "j" = "y", "bo" = "bjo", "a" = list("å","ä","æ","a"), "o" = list("ö","ø","o"))

/datum/mutation/swedish/New(datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = language_mutilation, end_string = list("",", bork",", bork, bork"), end_string_chance = 30)

/datum/mutation/chav
	name = "Chav"
	desc = "Unknown"
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Ye feel like a reet prat like, innit?</span>"
	text_lose_indication = "<span class='notice'>You no longer feel like being rude and sassy.</span>"

/datum/mutation/chav/New(datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("chav_replacement.json", "chav"), end_string = ", mate", end_string_chance = 30)

/datum/mutation/elvis
	name = "Elvis"
	desc = "A terrifying mutation named after its 'patient-zero'."
	quality = MINOR_NEGATIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel pretty good, honeydoll.</span>"
	text_lose_indication = "<span class='notice'>You feel a little less conversation would be great.</span>"

/datum/mutation/chav/New(datum/mutation/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("elvis_replacement.json", "elvis"))

/datum/mutation/elvis/on_life(seconds_per_tick, times_fired)
	switch(pick(1,2))
		if(1)
			if(SPT_PROB(7.5, seconds_per_tick))
				var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
				var/dancemoves = pick(dancetypes)
				owner.visible_message("<b>[owner]</b> busts out some [dancemoves] moves!")
		if(2)
			if(SPT_PROB(7.5, seconds_per_tick))
				owner.visible_message("<b>[owner]</b> [pick("jiggles their hips", "rotates their hips", "gyrates their hips", "taps their foot", "dances to an imaginary song", "jiggles their legs", "snaps their fingers")]!")

/datum/mutation/stoner
	name = "Stoner"
	desc = "A common mutation that severely decreases intelligence."
	quality = NEGATIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel...totally chill, man!</span>"
	text_lose_indication = "<span class='notice'>You feel like you have a better sense of time.</span>"

/datum/mutation/stoner/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	owner.grant_language(/datum/language/beachbum, TRUE, TRUE, LANGUAGE_STONER)
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/stoner/on_losing(mob/living/carbon/human/owner)
	..()
	owner.remove_language(/datum/language/beachbum, TRUE, TRUE, LANGUAGE_STONER)
	owner.remove_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/medieval
	name = "Medieval"
	desc = "A horrible mutation originating from the distant past, thought to have once been a common gene in all of old world Europe."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>You feel like seeking the holy grail!</span>"
	text_lose_indication = "<span class='notice'>You no longer feel like seeking anything.</span>"

/datum/mutation/medieval/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/medieval/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/medieval/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		var/list/medieval_words = strings("medieval_replacement.json", "medieval")
		var/list/startings = strings("medieval_replacement.json", "startings")
		for(var/key in medieval_words)
			var/value = medieval_words[key]
			if(islist(value))
				value = pick(value)
			if(uppertext(key) == key)
				value = uppertext(value)
			if(capitalize(key) == key)
				value = capitalize(value)
			message = replacetextEx(message,regex("\b[REGEX_QUOTE(key)]\b","ig"), value)
		message = trim(message)
		var/chosen_starting = pick(startings)
		message = "[chosen_starting] [message]"

		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/piglatin
	name = "Pig Latin"
	desc = "Historians say back in the 2020's humanity spoke entirely in this mystical language."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Omethingsay eelsfay offyay.")
	text_lose_indication = span_notice("The off sensation passes.")

/datum/mutation/piglatin/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/piglatin/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/piglatin/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/spoken_message = speech_args[SPEECH_MESSAGE]
	spoken_message = piglatin_sentence(spoken_message)
	speech_args[SPEECH_MESSAGE] = spoken_message
