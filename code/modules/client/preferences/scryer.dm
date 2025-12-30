// note: see /datum/station_trait/scryers/proc/on_job_after_spawn for ringtone selection
// and /datum/loadout_item/neck/modlink/post_equip_item

#define CALL_RINGTONE_I_SOUNDFILE 1
#define CALL_RINGTONE_I_LENGTH 2

#define CALL_RINGTONE_SOUND_DEFAULT CALL_RINGTONE_FLIP_FLAP

#define CALL_RINGTONE_ALLSTAR "All Star"
#define CALL_RINGTONE_BIGSHOT "Big Shot"
#define CALL_RINGTONE_BADAPPLE "Bad Apple"
#define CALL_RINGTONE_BONETROUSLE "Bonetrousle"
#define CALL_RINGTONE_CATS "🐈"
#define CALL_RINGTONE_COFFEE_SHOP "Coffee Shop in Yume"
#define CALL_RINGTONE_FLIP_FLAP "Flip Flap"
#define CALL_RINGTONE_GRASS_SPACE "Grass Space Chase"
#define CALL_RINGTONE_HALL_OF_MOUNTAIN_KING "Hall of the Mountain King"
#define CALL_RINGTONE_LANCER "Lancer."
#define CALL_RINGTONE_SPIDER_DANCE "Spider Dance"
#define CALL_RINGTONE_STYAOS "Six Trillion Years and Overnight Story"
#define CALL_RINGTONE_THIRD_SANCTUARY "Third Sanctuary"
#define CALL_RINGTONE_YUMENO "YU.ME.NO"
#define CALL_RINGTONE_ULTIMATUM "Grinchs Ultimatum"
#define CALL_RINGTONE_TENNABOARD "Mike, the Board Please!"
#define CALL_RINGTONE_BADPIGGIES "🥚🐖🛻"
#define CALL_RINGTONE_DOOMGATE "At Dooms Gate"
//#define CALL_RINGTONE_OKIEDOKIE "Okie Dokie!" ((Because we dont want nintendo to SOMEHOW get angry at this shit))
#define CALL_RINGTONE_TEACHFISH "To Teach a Fish to Man"
#define CALL_RINGTONE_RUNNINGOUT "Running Out Time"
#define CALL_RINGTONE_MEGALO "☠️" //er er er er
#define CALL_RINGTONE_PLANETWISP "Planet Wisp Act 1"
#define CALL_RINGTONE_ASGORE "bergentrückung" //Driving in my car right after a beeeeeeer


// (soundfile, soundlength)
GLOBAL_LIST_INIT(call_ringtones, list(
	CALL_RINGTONE_ALLSTAR = list('sound/machines/call_ringtones/allstar.ogg', 14.7 SECONDS),
	CALL_RINGTONE_BIGSHOT = list('sound/machines/call_ringtones/bigshot.ogg', 21.1 SECONDS),
	CALL_RINGTONE_BADAPPLE = list('sound/machines/call_ringtones/bad_apple.ogg', 21.1 SECONDS),
	CALL_RINGTONE_BONETROUSLE = list('sound/machines/call_ringtones/bonetrousle.ogg', 20 SECONDS),
	CALL_RINGTONE_CATS = list('sound/machines/call_ringtones/cats.ogg', 28 SECONDS),
	CALL_RINGTONE_COFFEE_SHOP = list('sound/machines/call_ringtones/coffee_shop_in_yume.ogg', 19.2 SECONDS),
	CALL_RINGTONE_FLIP_FLAP = list('sound/machines/call_ringtones/flip_flap.ogg', 18 SECONDS),
	CALL_RINGTONE_GRASS_SPACE = list('sound/machines/call_ringtones/grass_space_chase.ogg', 15.7 SECONDS),
	CALL_RINGTONE_HALL_OF_MOUNTAIN_KING = list('sound/machines/call_ringtones/hall_of_the_mountain_king.ogg', 19.4 SECONDS),
	CALL_RINGTONE_LANCER = list('sound/machines/call_ringtones/lancer.ogg', 20.3 SECONDS),
	CALL_RINGTONE_SPIDER_DANCE = list('sound/machines/call_ringtones/spider_dance.ogg', 16.1 SECONDS),
	CALL_RINGTONE_STYAOS = list('sound/machines/call_ringtones/trillion_years_overnight_story.ogg', 11.9 SECONDS),
	CALL_RINGTONE_THIRD_SANCTUARY = list('sound/machines/call_ringtones/third_sanctuary.ogg', 12.7 SECONDS),
	CALL_RINGTONE_YUMENO = list('sound/machines/call_ringtones/yu_me_no.ogg', 28.2 SECONDS),
	CALL_RINGTONE_ULTIMATUM = list('sound/machines/call_ringtones/grinch_ultimatum.ogg', 30 SECONDS),
	CALL_RINGTONE_TENNABOARD = list('sound/machines/call_ringtones/TennaBoardIntro.ogg', 21 SECONDS),
	CALL_RINGTONE_BADPIGGIES = list('sound/machines/call_ringtones/BadPiggies.ogg', 27.7 SECONDS),
	CALL_RINGTONE_DOOMGATE = list('sound/machines/call_ringtones/AtDoomsGate.ogg', 26.2 SECONDS),
	CALL_RINGTONE_TEACHFISH = list('sound/machines/call_ringtones/TeachAFishToMan.ogg', 26.8 SECONDS),
	CALL_RINGTONE_RUNNINGOUT = list('sound/machines/call_ringtones/RunningOut.ogg', 14.8 SECONDS),
	CALL_RINGTONE_MEGALO = list('sound/machines/call_ringtones/megalovania.ogg', 16.8 SECONDS),
	CALL_RINGTONE_PLANETWISP = list('sound/machines/call_ringtones/PlanetWisp.ogg', 26 SECONDS),
	CALL_RINGTONE_ASGORE = list('sound/machines/call_ringtones/Asgore.ogg', 16.9 SECONDS)
))


/datum/preference/choiced/call_ringtone
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "call_ringtone"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference_middleware/call_ringtone
	COOLDOWN_DECLARE(ringtone_cooldown)
	action_delegations = list(
		"play_call_ringtone_sound" = PROC_REF(play_call_ringtone_sound),
		"stop_call_ringtone_sound" = PROC_REF(stop_call_ringtone_sound)
	)

/datum/preference_middleware/call_ringtone/proc/play_call_ringtone_sound(list/params, mob/user)
	if(!COOLDOWN_FINISHED(src, ringtone_cooldown))
		return
	user.playsound_local(
		get_turf(user),
		sound_to_use = sound(GLOB.call_ringtones[preferences.read_preference(/datum/preference/choiced/call_ringtone)][CALL_RINGTONE_I_SOUNDFILE]),
		vol = 90,
		vary = FALSE,
		use_reverb = FALSE,
		pressure_affected = FALSE,
		channel = CHANNEL_RINGTONES,
		mixer_channel = CHANNEL_RINGTONES
	)
	COOLDOWN_START(src, ringtone_cooldown, 0.5 SECONDS)

/datum/preference_middleware/call_ringtone/proc/stop_call_ringtone_sound(list/params, mob/user)
	SEND_SOUND(user, sound(null, channel = CHANNEL_RINGTONES, repeat = 0, wait = 0))

/datum/preference/choiced/call_ringtone/init_possible_values()
	return GLOB.call_ringtones

/datum/preference/choiced/call_ringtone/create_default_value()
	return CALL_RINGTONE_SOUND_DEFAULT

/datum/preference/choiced/call_ringtone/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE
