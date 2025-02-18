/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range=0)
	. = ..()
	if (!.)
		return .
	if(("syndi-propaganda" in spans) && has_language(message_language))
		var/mob/living/speaker_implant/speaker_implant = speaker
		var/mob/living/afs_speaker = istype(speaker_implant) ? speaker_implant.owner : speaker
		var/is_speaker = src == afs_speaker
		var/action = is_speaker ? "Saying" : "Hearing"
		if (is_special_character(src))
			to_chat(src, span_notice("[action] the Syndicate propaganda raises your spirits."))
			add_mood_event("syndi_propaganda", /datum/mood_event/syndi_propaganda/antag, is_speaker)
		else if (mind.assigned_role.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY|DEPARTMENT_BITFLAG_COMMAND) || HAS_TRAIT(src, TRAIT_MINDSHIELD))
			to_chat(src, span_notice("[action] the Syndicate propaganda dampens your spirits."))
			add_mood_event("syndi_propaganda", /datum/mood_event/syndi_propaganda/authority, is_speaker)
		else
			to_chat(src, span_notice("[action] the Syndicate propaganda lowers your spirits."))
			add_mood_event("syndi_propaganda", /datum/mood_event/syndi_propaganda, is_speaker)
