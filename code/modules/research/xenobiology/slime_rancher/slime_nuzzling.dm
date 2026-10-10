/// Each nuzzle picks its wait between MIN and MAX.
#define SLIME_NUZZLE_COOLDOWN_MIN (45 SECONDS)
#define SLIME_NUZZLE_COOLDOWN_MAX (90 SECONDS)

/// Nuzzles a friend, which cheers them up and starts our cooldown.
/mob/living/basic/slime/proc/nuzzle(mob/living/friend)
	COOLDOWN_START(src, nuzzle_cooldown, rand(SLIME_NUZZLE_COOLDOWN_MIN, SLIME_NUZZLE_COOLDOWN_MAX))
	set_temporary_mood(SLIME_MOOD_CAT)
	new /obj/effect/temp_visual/heart(loc)
	friend.add_mood_event("slime_nuzzle", /datum/mood_event/slime_nuzzle, src)
	manual_emote(pick(
		"nuzzles up against [friend].",
		"squishes happily against [friend].",
		"blorbles adoringly at [friend].",
		"boops [friend] with a wobbly little bounce.",
		"leans against [friend] and jiggles.",
	))

/// Whether we're in the mood to go nuzzle a friend right now
/mob/living/basic/slime/proc/wants_to_nuzzle()
	if(buckled || stat != CONSCIOUS)
		return FALSE
	if(!COOLDOWN_FINISHED(src, nuzzle_cooldown))
		return FALSE
	if(ai_controller?.blackboard[BB_SLIME_RABID])
		return FALSE
	return !was_recently_attacked() // :(

/datum/mood_event/slime_nuzzle
	mood_change = 1
	timeout = 3 MINUTES

/datum/mood_event/slime_nuzzle/add_effects(mob/living/basic/slime/nuzzler)
	description = "[nuzzler] squished up against me, how adorable!"

#undef SLIME_NUZZLE_COOLDOWN_MAX
#undef SLIME_NUZZLE_COOLDOWN_MIN
