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
#define PDA_RINGTONE_BEEP "Beep"
#define PDA_RINGTONE_BUZZ "Buzz"
#define PDA_RINGTONE_CHIME "Chime"
#define PDA_RINGTONE_PING "Ping"
#define PDA_RINGTONE_CHIRP "Chirp"
#define PDA_RINGTONE_DING "Ding"
#define PDA_RINGTONE_HONK "Honk"
#define PDA_RINGTONE_WEH "Weh!"
#define PDA_RINGTONE_CODEC "Codec"
#define PDA_RINGTONE_MEOW "Meow"

/// Default ringtone sound
#define PDA_RINGTONE_SOUND_DEFAULT PDA_RINGTONE_BEEP

// Map ringtone names to sound files
GLOBAL_LIST_INIT(pda_ringtone_sounds, list(
	PDA_RINGTONE_BEEP = 'sound/machines/terminal_success.ogg',
	PDA_RINGTONE_BUZZ = 'sound/machines/buzz-sigh.ogg',
	PDA_RINGTONE_CHIME = 'sound/machines/chime.ogg',
	PDA_RINGTONE_PING = 'sound/machines/ping.ogg',
	PDA_RINGTONE_CHIRP = 'sound/machines/terminal_processing.ogg',
	PDA_RINGTONE_DING = 'sound/machines/ding.ogg',
	PDA_RINGTONE_HONK = 'sound/items/bikehorn.ogg',
	PDA_RINGTONE_WEH = 'monkestation/sound/voice/weh.ogg',
	PDA_RINGTONE_CODEC = 'sound/machines/pda_ringtones/codec.ogg',
	PDA_RINGTONE_MEOW = 'monkestation/sound/voice/feline/meow1.ogg',
))

/datum/preference/choiced/pda_ringtone_sound
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "pda_ringtone_sound"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/pda_ringtone_sound/init_possible_values()
	return GLOB.pda_ringtone_sounds

/datum/preference/choiced/pda_ringtone_sound/create_default_value()
	return PDA_RINGTONE_SOUND_DEFAULT
