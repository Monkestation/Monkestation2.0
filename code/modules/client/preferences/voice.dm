/*
	--------- Character Preferences ---------
*/

/*
	----- Bark Middleware -----
*/

/datum/preference_middleware/bark
	/// Cooldown on requesting a bark preview.
	COOLDOWN_DECLARE(bark_cooldown)

	action_delegations = list(
		"play_bark" = PROC_REF(play_bark),
		"open_voice_screen" = PROC_REF(open_voice_screen),
	)
	var/datum/voice_screen/voice_screen
	var/atom/movable/barker

/datum/preference_middleware/bark/proc/open_voice_screen(list/params, mob/user)
	if(voice_screen)
		voice_screen.ui_interact(user)
		return TRUE
	else
		voice_screen = new(src)
		voice_screen.ui_interact(user)
		return FALSE
	// return TRUE

/datum/preference_middleware/bark/proc/play_bark(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, bark_cooldown))
		return TRUE
	if (!barker)
		barker = new()
		barker.voice = new()
	barker.voice.set_from_prefs(preferences)
	barker.voice.long_bark(list(user), 7, 300, FALSE, 32, barker)
	COOLDOWN_START(src, bark_cooldown, 2 SECONDS)
	return TRUE

/datum/preference_middleware/bark/Destroy()
	QDEL_NULL(barker)
	return ..()

/*
	----- Bark Sound -----
*/

/// Which sound does the player want to make
/datum/preference/choiced/voice_pack
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "voice_pack"

/datum/preference/choiced/voice_pack/compile_ui_data(mob/user, value)
	var/datum/voice_pack/voicepack = GLOB.voice_pack_list[value]
	return voicepack.group_name + ": " + voicepack.name

/datum/preference/choiced/voice_pack/init_possible_values()
	return assoc_to_keys(GLOB.voice_pack_list)

/datum/preference/choiced/voice_pack/is_valid(value)
	if (!istext(value))
		return FALSE
	var/datum/voice_pack/voicepack = GLOB.voice_pack_list[value]
	if (!voicepack)
		return FALSE
	return !voicepack.hidden

/datum/preference/choiced/voice_pack/apply_to_human(mob/living/carbon/human/target, value)
	target.set_voice_pack(value)

/datum/preference/choiced/voice_pack/create_default_value()
	return pick(GLOB.random_voice_packs)

/*
	----- Bark Speed / Duration -----
*/

/datum/preference/numeric/bark_speech_speed
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bark_speech_speed"
	minimum = VOICE_DEFAULT_MINSPEED
	maximum = VOICE_DEFAULT_MAXSPEED
	step = 0.01

/datum/preference/numeric/bark_speech_speed/apply_to_human(mob/living/carbon/human/target, value)
	target.voice.speed = value

/datum/preference/numeric/bark_speech_speed/create_default_value()
	return 6

/*
	----- Bark Pitch -----
*/

/datum/preference/numeric/bark_speech_pitch
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bark_speech_pitch"
	minimum = VOICE_DEFAULT_MINPITCH
	maximum = VOICE_DEFAULT_MAXPITCH
	step = 0.01

/datum/preference/numeric/bark_speech_pitch/apply_to_human(mob/living/carbon/human/target, value)
	target.voice.pitch = value

/datum/preference/numeric/bark_speech_pitch/create_default_value()
	return 1

/*
	----- Bark Pitch Varience -----
*/

/datum/preference/numeric/bark_pitch_range
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bark_pitch_range"
	minimum = VOICE_DEFAULT_MINVARY
	maximum = VOICE_DEFAULT_MAXVARY
	step = 0.01

/datum/preference/numeric/bark_pitch_range/apply_to_human(mob/living/carbon/human/target, value)
	target.voice.pitch_range = value

/datum/preference/numeric/bark_pitch_range/create_default_value()
	return 0.2

/*
	--------- Game Preferences ---------
*/

/// Should this player only hear a single bark
/datum/preference/toggle/barks_short
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "voice_sounds_short"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/// Should this player hear barks without pitch modification
/datum/preference/toggle/barks_limited_pitch
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "voice_sounds_limited_pitch"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/// Should this player only hear goonstation speak barks
/datum/preference/toggle/voice_sounds_only_simple
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "voice_sounds_only_goon"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE
