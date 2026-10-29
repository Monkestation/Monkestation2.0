/datum/emote/slime
	mob_type_allowed_typecache = /mob/living/basic/slime
	mob_type_blacklist_typecache = list()

/datum/emote/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "bounces in place."

/datum/emote/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "jiggles!"

/datum/emote/slime/light
	key = "light"
	key_third_person = "lights"
	message = "lights up for a bit, then stops."

/datum/emote/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "vibrates!"

/datum/emote/slime/mood
	key = "moodnone"
	///Mood key, will set the slime's emote to this.
	var/mood_key

/datum/emote/slime/mood/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/mob/living/basic/slime/slime_user = user
	slime_user.set_mood(mood_key)

/datum/emote/slime/mood/sneaky
	key = "moodsneaky"
	mood_key = SLIME_MOOD_MISCHIEVOUS

/datum/emote/slime/mood/smile
	key = "moodsmile"
	mood_key = SLIME_MOOD_SMILE

/datum/emote/slime/mood/cat
	key = "moodcat"
	mood_key = SLIME_MOOD_CAT

/datum/emote/slime/mood/pout
	key = "moodpout"
	mood_key = SLIME_MOOD_POUT

/datum/emote/slime/mood/sad
	key = "moodsad"
	mood_key = SLIME_MOOD_SAD

/datum/emote/slime/mood/angry
	key = "moodangry"
	mood_key = SLIME_MOOD_ANGRY
