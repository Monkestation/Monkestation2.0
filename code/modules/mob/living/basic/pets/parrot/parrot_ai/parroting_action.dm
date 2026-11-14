/// When a parrot... parrots... it occasionally asks for a fresh phrase to repeat, then squawks it (sometimes over the radio).
/datum/bt_node/ai_behavior/parrot_repeat_speech

/datum/bt_node/ai_behavior/parrot_repeat_speech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/parrot/speaking_pawn = controller.pawn

	var/switch_up_probability = controller.blackboard[BB_PARROT_PHRASE_CHANGE_PROBABILITY]
	if(prob(switch_up_probability) || isnull(controller.blackboard[BB_PARROT_REPEAT_STRING]))
		if(SEND_SIGNAL(speaking_pawn, COMSIG_NEEDS_NEW_PHRASE) & NO_NEW_PHRASE_AVAILABLE)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!prob(controller.blackboard[BB_PARROT_REPEAT_PROBABILITY]))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/speech = controller.blackboard[BB_PARROT_REPEAT_STRING]
	if(isnull(speech))
		stack_trace("Parrot repeat speech somehow got a null phrase while not getting `NO_NEW_PHRASE_AVAILABLE`!")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/available_channels = speaking_pawn.get_available_channels()
	var/modified_speech = speech
	var/use_radio = prob(50) // we might not even use the radio if we even have a channel

	var/has_channel_prefix = (speech[1] in GLOB.department_radio_prefixes) && (copytext_char(speech, 2, 3) in GLOB.department_radio_keys) // determine if we need to crop the channel prefix

	if(!length(available_channels)) // might not even use the radio at all
		if(has_channel_prefix)
			modified_speech = copytext_char(speech, 3)
	else
		if(has_channel_prefix)
			modified_speech = "[use_radio ? pick(available_channels) : ""][copytext_char(speech, 3)]"
		else
			modified_speech = "[use_radio ? pick(available_channels) : ""][speech]"

	INVOKE_ASYNC(speaking_pawn, TYPE_PROC_REF(/atom/movable, say), modified_speech, forced = "AI Controller")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
