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
	if(is_latched() || stat != CONSCIOUS)
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

/datum/targeting_strategy/ally_mob/awake_player

/datum/targeting_strategy/ally_mob/awake_player/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/candidate = target
	if(!isliving(candidate) || !candidate.client || candidate.incapacitated())
		return FALSE
	// roaming cleaners have a station to clean, they only say hi in passing
	var/mob/living/basic/slime/slime_pawn = living_mob
	return !(slime_pawn.cleaner_slime && isnull(slime_pawn.pen) && get_dist(slime_pawn, candidate) > 1)

/datum/target_source/from_bb_list/slime_friends
	list_key = BB_FRIENDS_LIST

/datum/bt_node/decorator/slime_wants_to_nuzzle

/datum/bt_node/decorator/slime_wants_to_nuzzle/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.is_latched() || IS_UNCONSCIOUS_OR_CRIT(slime_pawn))
		return FALSE
	if(!COOLDOWN_FINISHED(slime_pawn, nuzzle_cooldown))
		return FALSE
	if(controller.blackboard[BB_SLIME_RABID])
		return FALSE
	return !slime_pawn.was_recently_attacked() // :(

/datum/bt_node/ai_behavior/nuzzle_friend

/datum/bt_node/ai_behavior/nuzzle_friend/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/mob/living/friend = controller.blackboard[BB_SLIME_NUZZLE_TARGET]
	if(!istype(slime_pawn) || QDELETED(friend) || !slime_pawn.Adjacent(friend))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	slime_pawn.nuzzle(friend)
	controller.clear_blackboard_key(BB_SLIME_NUZZLE_TARGET)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

#undef SLIME_NUZZLE_COOLDOWN_MAX
#undef SLIME_NUZZLE_COOLDOWN_MIN
