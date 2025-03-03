/datum/preference/toggle/short_barks
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "short_barks"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/blooper
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "blooper_speech"

/datum/preference/choiced/blooper/init_possible_values()
	return assoc_to_keys(GLOB.bark_list)


/datum/preference/choiced/blooper/apply_to_human(mob/living/carbon/human/target, value)
	target.set_bark(value)

/datum/preference_middleware/blooper
	/// Cooldown on requesting a Blooper preview.
	COOLDOWN_DECLARE(blooper_cooldown)

	action_delegations = list(
		"play_blooper" = PROC_REF(play_blooper),
	)

/datum/preference_middleware/blooper/proc/play_blooper(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, blooper_cooldown))
		return TRUE
	var/atom/movable/blooperbox = new(get_turf(user))
	blooperbox.set_bark(preferences.read_preference(/datum/preference/choiced/blooper))
	blooperbox.vocal_pitch = preferences.read_preference(/datum/preference/numeric/blooper_speech_pitch)
	blooperbox.vocal_speed = preferences.read_preference(/datum/preference/numeric/blooper_speech_speed)
	blooperbox.vocal_pitch_range = preferences.read_preference(/datum/preference/numeric/blooper_pitch_range)
	var/total_delay = blooperbox.long_bark(list(user), 7, 10, FALSE, 32)
	QDEL_IN(blooperbox, total_delay)
	COOLDOWN_START(src, blooper_cooldown, 2 SECONDS)
	return TRUE

/datum/preference/numeric/blooper_speech_speed
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "blooper_speech_speed"
	minimum = BARK_DEFAULT_MINSPEED
	maximum = BARK_DEFAULT_MAXSPEED
	step = 0.01

/datum/preference/numeric/blooper_speech_speed/apply_to_human(mob/living/carbon/human/target, value)
	target.vocal_speed = value

/datum/preference/numeric/blooper_speech_speed/create_default_value()
	return round((BARK_DEFAULT_MINSPEED + BARK_DEFAULT_MAXSPEED) / 2)

/datum/preference/numeric/blooper_speech_pitch
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "blooper_speech_pitch"
	minimum = BARK_DEFAULT_MINPITCH
	maximum = BARK_DEFAULT_MAXPITCH
	step = 0.01

/datum/preference/numeric/blooper_speech_pitch/apply_to_human(mob/living/carbon/human/target, value)
	target.vocal_pitch = value

/datum/preference/numeric/blooper_speech_pitch/create_default_value()
	return round((BARK_DEFAULT_MINPITCH + BARK_DEFAULT_MAXPITCH) / 2)

/datum/preference/numeric/blooper_pitch_range
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "blooper_pitch_range"
	minimum = BARK_DEFAULT_MINVARY
	maximum = BARK_DEFAULT_MAXVARY
	step = 0.01

/datum/preference/numeric/blooper_pitch_range/apply_to_human(mob/living/carbon/human/target, value)
	target.vocal_pitch_range = value

/datum/preference/numeric/blooper_pitch_range/create_default_value()
	return 0.2

/// Can I hear everyone else's bloops?
/datum/preference/toggle/hear_sound_blooper
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "hear_sound_blooper"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/// Can I have a slider to adjust the volume of the barks?
/datum/preference/numeric/sound_blooper_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_blooper_volume"
	savefile_identifier = PREFERENCE_PLAYER
	minimum = 0
	maximum = 60
	step = 5
