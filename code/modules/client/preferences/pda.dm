/**
 * This is the preference for the player's SpaceMessenger ringtone.
 * Currently only applies to humans spawned in with a job, as it's hooked
 * into `/datum/job/proc/after_spawn()`.
 */
/datum/preference/text/pda_ringtone
	savefile_key = "pda_ringtone"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	maximum_value_length = MESSENGER_RINGTONE_MAX_LENGTH


/datum/preference/text/pda_ringtone/create_default_value()
	return MESSENGER_RINGTONE_DEFAULT

// Returning false here because this pref is handled a little differently, due to its dependency on the existence of a PDA.
/datum/preference/text/pda_ringtone/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/**
 * PDA theme
 */
/datum/preference/choiced/pda_theme
	savefile_key = "pda_theme"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/pda_theme/init_possible_values()
	var/list/values = list()
	for(var/name in GLOB.default_pda_themes)
		values[name] = GLOB.default_pda_themes[name]
	return values

/datum/preference/choiced/pda_theme/create_default_value()
	return PDA_THEME_NTOS_NAME

// Returning false here because this pref is handled a little differently, due to its dependency on the existence of a PDA.
/datum/preference/choiced/pda_theme/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

// Monkestation Ringtone Sounds Addition START
// To add sounds to the PDA, all you need to do is add the following define ex:
// #define PDA_RINGTONE_WOOF "Woof"
// Then Add the PDA_RINGTONE_WOOF to the global list pda_ringtone_sounds, with its associative sound path
/// List of available ringtone sounds
#define PDA_RINGTONE_ALERT1 "Alert 1"
#define PDA_RINGTONE_ALERT2 "Alert 2"
#define PDA_RINGTONE_ALERT3 "Alert 3"
#define PDA_RINGTONE_ALERT4 "Alert 4"
#define PDA_RINGTONE_BELL "Bell"
#define PDA_RINGTONE_BEEP "Beep"
#define PDA_RINGTONE_BUZZ "BUZZ"
#define PDA_RINGTONE_BYONDPAGER "BYOND Pager"
#define PDA_RINGTONE_BYONDPAGERDOWN "BYOND Pager Down"
#define PDA_RINGTONE_BIKEHORN "Bikehorn"
#define PDA_RINGTONE_CHIME "Chime"
#define PDA_RINGTONE_CHORD1 "Chord 1"
#define PDA_RINGTONE_CHORD2 "Chord 2"
#define PDA_RINGTONE_CHORD3 "Chord 3"
#define PDA_RINGTONE_CODEC "Codec"
#define PDA_RINGTONE_DING "Ding"
#define PDA_RINGTONE_HORN "Horn"
#define PDA_RINGTONE_MAUS "Maus"
#define PDA_RINGTONE_MEOW1 "Meow 1"
#define PDA_RINGTONE_MEOW2 "Meow 2"
#define PDA_RINGTONE_MEOW3 "Meow 3"
#define PDA_RINGTONE_MEOW4 "Meow 4"
#define PDA_RINGTONE_MEOW_ELECTRIC "Meow (Electric)"
#define PDA_RINGTONE_MORSE "Morse"
#define PDA_RINGTONE_OHHIMARK "Oh Hi Mark"
#define PDA_RINGTONE_JINGLE "Mysterious Jingle"
#define PDA_RINGTONE_NORMALIZE "Normalize"
#define PDA_RINGTONE_NOT_ALPHYS "Not Alphys"
#define PDA_RINGTONE_PHONE_CHIME "Phone Chime"
#define PDA_RINGTONE_PIANO "Piano"
#define PDA_RINGTONE_PING "Ping"
#define PDA_RINGTONE_SPEAKING "Speaking"
#define PDA_RINGTONE_SPLAT "Splat"
#define PDA_RINGTONE_TARGET "Target"
#define PDA_RINGTONE_TERMINAL_NOTIF1 "Terminal Notif 1"
#define PDA_RINGTONE_WEH "Weh"

/// Default ringtone sound
#define PDA_RINGTONE_SOUND_DEFAULT PDA_RINGTONE_BEEP

// Map ringtone names to sound files
GLOBAL_LIST_INIT(pda_ringtone_sounds, list(
	PDA_RINGTONE_ALERT1 = 'sound/machines/pda_ringtones/alert1.ogg',
	PDA_RINGTONE_ALERT2 = 'sound/machines/pda_ringtones/alert2.ogg',
	PDA_RINGTONE_ALERT3 = 'sound/machines/pda_ringtones/alert3.ogg',
	PDA_RINGTONE_ALERT4 = 'sound/machines/pda_ringtones/alert4.ogg',
	PDA_RINGTONE_BEEP = 'sound/machines/pda_ringtones/terminal_success.ogg',
	PDA_RINGTONE_BELL = 'sound/machines/pda_ringtones/bell.ogg',
	PDA_RINGTONE_BIKEHORN = 'sound/machines/pda_ringtones/bikehorn.ogg',
	PDA_RINGTONE_BYONDPAGER = 'sound/machines/pda_ringtones/byond_pager.ogg',
	PDA_RINGTONE_BYONDPAGERDOWN = 'sound/machines/pda_ringtones/byond_pager_down.ogg',
	PDA_RINGTONE_CHIME = 'sound/machines/pda_ringtones/chime.ogg',
	PDA_RINGTONE_CHORD1 = 'sound/machines/pda_ringtones/chord1.ogg',
	PDA_RINGTONE_CHORD2 = 'sound/machines/pda_ringtones/chord2.ogg',
	PDA_RINGTONE_CHORD3 = 'sound/machines/pda_ringtones/chord3.ogg',
	PDA_RINGTONE_CODEC = 'sound/machines/pda_ringtones/codec.ogg',
	PDA_RINGTONE_DING = 'sound/machines/pda_ringtones/ding.ogg',
	PDA_RINGTONE_HORN = 'sound/machines/pda_ringtones/horn.ogg',
	PDA_RINGTONE_MAUS = 'sound/machines/pda_ringtones/maus.ogg',
	PDA_RINGTONE_MEOW1 = 'sound/machines/pda_ringtones/meow1.ogg',
	PDA_RINGTONE_MEOW2 = 'sound/machines/pda_ringtones/meow2.ogg',
	PDA_RINGTONE_MEOW3 = 'sound/machines/pda_ringtones/meow3.ogg',
	PDA_RINGTONE_MEOW4 = 'sound/machines/pda_ringtones/meow4.ogg',
	PDA_RINGTONE_MEOW_ELECTRIC = 'sound/machines/pda_ringtones/meow_electric.ogg',
	PDA_RINGTONE_MORSE = 'sound/machines/pda_ringtones/morse.ogg',
	PDA_RINGTONE_OHHIMARK = 'sound/machines/pda_ringtones/oh_hi_mark.ogg',
	PDA_RINGTONE_JINGLE = 'sound/machines/pda_ringtones/jingle.ogg',
	PDA_RINGTONE_BUZZ = 'sound/machines/pda_ringtones/buzz.ogg',
	PDA_RINGTONE_NOT_ALPHYS = 'sound/machines/pda_ringtones/not_alphys.ogg',
	PDA_RINGTONE_PHONE_CHIME = 'sound/machines/pda_ringtones/phone_chime.ogg',
	PDA_RINGTONE_PIANO = 'sound/machines/pda_ringtones/piano.ogg',
	PDA_RINGTONE_PING = 'sound/machines/pda_ringtones/ping.ogg',
	PDA_RINGTONE_SPEAKING = 'sound/machines/pda_ringtones/speaking.ogg',
	PDA_RINGTONE_SPLAT = 'sound/machines/pda_ringtones/splat.ogg',
	PDA_RINGTONE_TARGET = 'sound/machines/pda_ringtones/target.ogg',
	PDA_RINGTONE_TERMINAL_NOTIF1 = 'sound/machines/pda_ringtones/terminal_notif1.ogg',
	PDA_RINGTONE_WEH = 'sound/machines/pda_ringtones/weh.ogg',
))

/datum/preference/choiced/pda_ringtone_sound
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "pda_ringtone_sound"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference_middleware/pda_ringtone_sound
	COOLDOWN_DECLARE(ringtone_cooldown)
	action_delegations = list(
		"play_ringtone_sound" = PROC_REF(play_ringtone_sound),
	)

/datum/preference_middleware/pda_ringtone_sound/proc/play_ringtone_sound(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, ringtone_cooldown))
		return TRUE
	user.playsound_local(get_turf(user), GLOB.pda_ringtone_sounds[preferences.read_preference(/datum/preference/choiced/pda_ringtone_sound)], 90, TRUE, null, 7, pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_MACHINERY)
	COOLDOWN_START(src, ringtone_cooldown, 0.5 SECONDS)
	return TRUE

/datum/preference/choiced/pda_ringtone_sound/init_possible_values()
	return GLOB.pda_ringtone_sounds

/datum/preference/choiced/pda_ringtone_sound/create_default_value()
	return PDA_RINGTONE_SOUND_DEFAULT

// Returning false here because this pref is handled a little differently, due to its dependency on the existence of a PDA.
/datum/preference/choiced/pda_ringtone_sound/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE
