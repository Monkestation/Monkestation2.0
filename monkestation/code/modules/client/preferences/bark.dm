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
		"open_bark_screen" = PROC_REF(open_bark_screen),
	)
	var/datum/bark_screen/bark_screen
	var/atom/movable/barker

/datum/preference_middleware/bark/proc/open_bark_screen(list/params, mob/user)
	if(bark_screen)
		bark_screen.ui_interact(usr)
		return TRUE
	else
		bark_screen = new(src)
		bark_screen.ui_interact(usr)
		return FALSE
	// return TRUE

/datum/preference_middleware/bark/proc/play_bark(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, bark_cooldown))
		return TRUE
	if (!barker)
		barker = new()
		barker.voice = new()
	barker.voice.set_from_prefs(preferences)
	barker.voice.long_bark(list(user), 7, 100, FALSE, 32, barker)
	COOLDOWN_START(src, bark_cooldown, 2 SECONDS)
	return TRUE

/datum/preference_middleware/bark/Destroy()
	qdel(barker)
	return ..()

/*
	----- Bark Sound -----
*/

/// Which sound does the player want to make
/datum/preference/choiced/bark_sound
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bark_sound"

/datum/preference/choiced/bark_sound/compile_ui_data(mob/user, value)
	var/datum/bark_sound/bark = GLOB.bark_list[value]
	return bark.group_name + ": " + bark.name

/datum/preference/choiced/bark_sound/init_possible_values()
	return assoc_to_keys(GLOB.bark_list)

/datum/preference/choiced/bark_sound/is_valid(value)
	var/datum/bark_sound/bark = GLOB.bark_list[value]
	if (!bark)
		return FALSE
	return !bark.hidden

/datum/preference/choiced/bark_sound/apply_to_human(mob/living/carbon/human/target, value)
	target.set_bark(value)

/datum/preference/choiced/bark_sound/create_default_value()
	return pick(GLOB.random_barks)

/*
	----- Bark Speed / Duration -----
*/

/datum/preference/numeric/bark_speech_speed
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bark_speech_speed"
	minimum = BARK_DEFAULT_MINSPEED
	maximum = BARK_DEFAULT_MAXSPEED
	step = 0.01

/datum/preference/numeric/bark_speech_speed/apply_to_human(mob/living/carbon/human/target, value)
	target.voice.speed = value

/datum/preference/numeric/bark_speech_speed/create_default_value()
	return 6

/*
	----- Bark Pitch -----
*/

/datum/preference/numeric/bark_speech_pitch
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bark_speech_pitch"
	minimum = BARK_DEFAULT_MINPITCH
	maximum = BARK_DEFAULT_MAXPITCH
	step = 0.01

/datum/preference/numeric/bark_speech_pitch/apply_to_human(mob/living/carbon/human/target, value)
	target.voice.pitch = value

/datum/preference/numeric/bark_speech_pitch/create_default_value()
	return 1

/*
	----- Bark Pitch Varience -----
*/

/datum/preference/numeric/bark_pitch_range
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "bark_pitch_range"
	minimum = BARK_DEFAULT_MINVARY
	maximum = BARK_DEFAULT_MAXVARY
	step = 0.01

/datum/preference/numeric/bark_pitch_range/apply_to_human(mob/living/carbon/human/target, value)
	target.voice.pitch_range = value

/datum/preference/numeric/bark_pitch_range/create_default_value()
	return 0.2

/*
	--------- Game Preferences ---------
*/

/// Should this player only hear a single bark
/datum/preference/toggle/short_barks
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_short_barks"
	savefile_identifier = PREFERENCE_PLAYER
