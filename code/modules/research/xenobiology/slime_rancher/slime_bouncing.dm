/// Each bounce picks its wait between MIN and MAX.
#define SLIME_BOUNCE_COOLDOWN_MIN (30 SECONDS)
#define SLIME_BOUNCE_COOLDOWN_MAX (75 SECONDS)
/// Pixels the slime lunges toward the person.
#define SLIME_BOUNCE_REACH 6
/// Pixels the slime hops up.
#define SLIME_BOUNCE_HEIGHT 6

/// Whether we're in the mood to go bounce off someone right now. Cat slimes only
/mob/living/basic/slime/proc/wants_to_bounce()
	if(!cat_slime || buckled || stat != CONSCIOUS)
		return FALSE
	if(!COOLDOWN_FINISHED(src, bounce_cooldown))
		return FALSE
	if(ai_controller?.blackboard[BB_SLIME_RABID])
		return FALSE
	return !was_recently_attacked()

// "GET A JOB" nope I'm hopping around :3
/mob/living/basic/slime/proc/bounce_off(mob/living/person)
	COOLDOWN_START(src, bounce_cooldown, rand(SLIME_BOUNCE_COOLDOWN_MIN, SLIME_BOUNCE_COOLDOWN_MAX))
	set_temporary_mood(SLIME_MOOD_CAT)
	playsound(src, 'sound/effects/attackblob.ogg', 25, TRUE, -3)
	manual_emote(pick(
		"boings off of [person].",
		"bounces right off [person] and wobbles.",
		"hops into [person], then bounces away giggling.",
		"flumps against [person] and ricochets!",
	))

	var/start_x = pixel_x
	var/start_y = pixel_y
	var/start_z = pixel_z
	var/start_w = pixel_w
	var/offset_x = (person.x - x) * ICON_SIZE_X + (person.pixel_x + person.pixel_w) - (start_x + start_w)
	var/offset_y = (person.y - y) * ICON_SIZE_Y + person.pixel_y - start_y
	var/bump_x = start_x + offset_x / ICON_SIZE_X * SLIME_BOUNCE_REACH
	var/bump_y = start_y + offset_y / ICON_SIZE_Y * SLIME_BOUNCE_REACH
	var/bump_z = person.pixel_z
	var/matrix/base = matrix(transform)
	var/matrix/squished = matrix(transform)
	squished.Scale(1.15, 0.8)
	animate(src, pixel_x = bump_x, pixel_y = bump_y, pixel_z = bump_z + SLIME_BOUNCE_HEIGHT, time = 0.15 SECONDS, easing = EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_z = bump_z, transform = squished, time = 0.1 SECONDS, easing = EASE_IN)
	animate(pixel_x = start_x, pixel_y = start_y, pixel_z = start_z + SLIME_BOUNCE_HEIGHT, transform = base, time = 0.15 SECONDS, easing = EASE_OUT)
	animate(pixel_z = start_z, time = 0.15 SECONDS, easing = EASE_IN)

#undef SLIME_BOUNCE_HEIGHT
#undef SLIME_BOUNCE_REACH
#undef SLIME_BOUNCE_COOLDOWN_MAX
#undef SLIME_BOUNCE_COOLDOWN_MIN
