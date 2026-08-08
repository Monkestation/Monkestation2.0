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
	owner.grant_language(/datum/language/beachbum, source = LANGUAGE_STONER)
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/stoner/on_losing(mob/living/carbon/human/owner)
	..()
	if(!QDELETED(owner))
		owner.remove_language(/datum/language/beachbum, source = LANGUAGE_STONER)
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

/datum/mutation/lisp
	name = "Lisp"
	desc = "Maketh the thubject thpeak with a lithp regardlethth of willingnethth."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_warning("Thomething doethn't feel right.")
	text_lose_indication = span_notice("You now feel able to pronounce consonants.")

/datum/mutation/lisp/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/lisp/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/lisp/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message,"s","th")
		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/uwuspeak
	name = "Neko Speak"
	desc = "Makes the subject speak in horrific combinations of words."
	quality = NEGATIVE
	text_gain_indication = span_warning("Something feels very wrong.")
	text_lose_indication = span_notice("You no longer feel like vomiting up your tongue.")

/datum/mutation/uwuspeak/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return

	owner.AddComponentFrom(GENETIC_MUTATION, /datum/component/fluffy_tongue)

/datum/mutation/uwuspeak/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	owner.RemoveComponentSource(GENETIC_MUTATION, /datum/component/fluffy_tongue)

/datum/mutation/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("YOU FEEL LIKE YELLING!")
	text_lose_indication = span_notice("You feel like being quiet.")

/datum/mutation/loud/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/loud/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/loud/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message,".","!")
		message = replacetext(message,"?","?!")
		message = replacetext(message,"!","!!")
		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/smile
	name = "Smile"
	desc = "Causes the user to be in constant mania."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("You feel so happy. Nothing can be wrong with anything.")
	text_lose_indication = span_notice("Everything is terrible again.")
	power_coeff = 1

/datum/mutation/smile/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/smile/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	if(GET_MUTATION_POWER(src) > 1)
		owner.clear_mood_event(GENETIC_MUTATION)

/datum/mutation/smile/setup()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		owner.add_mood_event(GENETIC_MUTATION, /datum/mood_event/smile, GET_MUTATION_POWER(src))

/datum/mutation/smile/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		// Time for a friendly game of SS13
		message = replacetext(message," stupid "," smart ")
		message = replacetext(message," idiot "," genius ")
		message = replacetext(message," unrobust "," robust ")
		message = replacetext(message," dumb "," smart ")
		message = replacetext(message," awful "," great ")
		message = replacetext(message," gay ",pick(" nice "," ok "," alright "))
		message = replacetext(message," horrible "," fun ")
		message = replacetext(message," terrible "," terribly fun ")
		message = replacetext(message," terrifying "," wonderful ")
		message = replacetext(message," gross "," cool ")
		message = replacetext(message," disgusting "," amazing ")
		message = replacetext(message," loser "," winner ")
		message = replacetext(message," useless "," useful ")
		message = replacetext(message," oh god "," cheese and crackers ")
		message = replacetext(message," jesus "," gee wiz ")
		message = replacetext(message," weak "," strong ")
		message = replacetext(message," kill "," hug ")
		message = replacetext(message," murder "," tease ")
		message = replacetext(message," ugly "," beautiful ")
		message = replacetext(message," douchbag "," nice guy ")
		message = replacetext(message," douchebag "," nice guy ")
		message = replacetext(message," nerd "," smart guy ")
		message = replacetext(message," moron "," fun person ")
		message = replacetext(message," IT'S LOOSE "," EVERYTHING IS FINE ")
		message = replacetext(message," sex "," hug fight ")
		message = replacetext(message," idiot "," genius ")
		message = replacetext(message," fat "," thin ")
		message = replacetext(message," beer "," water with ice ")
		message = replacetext(message," drink "," water ")
		message = replacetext(message," i hate you "," you're mean ")
		message = replacetext(message," shit "," shiz ")
		message = replacetext(message," crap "," poo ")
		message = replacetext(message," ass "," butt ")
		message = replacetext(message," damn "," dang ")
		message = replacetext(message," fuck "," *beeps* ")
		message = replacetext(message," fucking "," *beeps* ")
		message = replacetext(message," cunt "," privates ")
		message = replacetext(message," dick "," jerk ")
		speech_args[SPEECH_MESSAGE] = trim(message)

/datum/mood_event/smile
	description = "EVERYTHING IS FINE AND I FEEL AMAZING!"
	mood_change = 1.5

/datum/mood_event/smile/add_effects(mutation_power)
	mood_change = mutation_power // Gotta love scaling that'll probably never see the light of day
