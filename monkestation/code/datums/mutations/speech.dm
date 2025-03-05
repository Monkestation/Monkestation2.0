/datum/mutation/human/lisp
	name = "Lisp"
	desc = "Maketh the thubject thpeak with a lithp regardlethth of willingnethth."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_warning("Thomething doethn't feel right.")
	text_lose_indication = span_notice("You now feel able to pronounce consonants.")

/datum/mutation/human/lisp/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/lisp/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/lisp/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message,"s","th")
		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/human/uwuspeak
	name = "Neko Speak"
	desc = "Makes the subject speak in horrific combinations of words."
	quality = NEGATIVE
	text_gain_indication = span_warning("Something feels very wrong.")
	text_lose_indication = span_notice("You no longer feel like vomiting up your tongue.")

/datum/mutation/human/uwuspeak/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	owner.AddComponentFrom(GENETIC_MUTATION, /datum/component/fluffy_tongue)

/datum/mutation/human/uwuspeak/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	owner.RemoveComponentSource(GENETIC_MUTATION, /datum/component/fluffy_tongue)

/datum/mutation/human/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("YOU FEEL LIKE YELLING!")
	text_lose_indication = span_notice("You feel like being quiet.")

/datum/mutation/human/loud/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/loud/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/loud/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = replacetext(message,".","!")
		message = replacetext(message,"?","?!")
		message = replacetext(message,"!","!!")
		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/human/smile
	name = "Smile"
	desc = "Causes the user to be in constant mania."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("You feel so happy. Nothing can be wrong with anything.")
	text_lose_indication = span_notice("Everything is terrible again.")
	power_coeff = 1

/datum/mutation/human/smile/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/smile/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	if(GET_MUTATION_POWER(src) > 1)
		owner.clear_mood_event(GENETIC_MUTATION)

/datum/mutation/human/smile/modify()
	. = ..()
	if(owner && GET_MUTATION_POWER(src) > 1)
		owner.add_mood_event(GENETIC_MUTATION, /datum/mood_event/smile, GET_MUTATION_POWER(src))

/datum/mutation/human/smile/proc/handle_speech(datum/source, list/speech_args)
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

/datum/mood_event/smile/add_effects(var/mutation_power)
	mood_change = mutation_power // Gotta love scaling that'll probably never see the light of day
