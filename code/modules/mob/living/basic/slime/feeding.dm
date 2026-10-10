///Can the slime leech life energy from the target?
/mob/living/basic/slime/proc/can_feed_on(mob/living/meal, silent = FALSE, check_adjacent = FALSE, check_friendship = FALSE)
	if(!isliving(meal))
		return FALSE

	if(stat != CONSCIOUS)
		if(!silent)
			balloon_alert(src, stat == DEAD ? "dead!" : "not conscious!")
		return FALSE

	if(!COOLDOWN_FINISHED(src, latch_cooldown))
		if(!silent)
			balloon_alert(src, "still reeling!")
		return FALSE

	if(hunger_disabled)
		if(!silent)
			balloon_alert(src, "not hungry!")
		return FALSE

	if(ranch_mutation_ready())
		if(!silent)
			balloon_alert(src, "about to mutate!")
		return FALSE

	if(check_friendship && (REF(meal) in faction))
		return FALSE

	if(check_adjacent && (!Adjacent(meal) || !isturf(loc)))
		return FALSE

	if(!(mobility_flags & MOBILITY_MOVE))
		if(!silent)
			balloon_alert(src, "can't move!")
		return FALSE

	if(meal.stat == DEAD)
		if(!silent)
			balloon_alert(src, "no life energy!")
		return FALSE

	if(locate(/mob/living/basic/slime) in meal.buckled_mobs)
		if(!silent)
			balloon_alert(src, "another slime in the way!")
		return FALSE

	if(issilicon(meal) || meal.mob_biotypes & MOB_ROBOTIC || meal.flags_1 & HOLOGRAM_1)
		if(!silent)
			balloon_alert(src, "no life energy!")
		return FALSE

	if(isslime(meal))
		if(!silent)
			balloon_alert(src, "can't eat slime!")
		return FALSE

	if(isbasicmob(meal))
		var/mob/living/basic/basic_meal = meal
		if(basic_meal.damage_coeff[BRUTE] <= 0 && basic_meal.damage_coeff[TOX] <= 0) //The creature wouldn't take any damage, it must be too weird even for us.
			if(!silent)
				balloon_alert(src, "not food!")
			return FALSE

	return TRUE

///The slime will start feeding on the target
/mob/living/basic/slime/proc/start_feeding(mob/living/target_mob)
	target_mob.unbuckle_all_mobs(force = TRUE) // rips other mobs (eg: shoulder parrots) off - slime vs slime is already handled in can_feed_on()
	if(!target_mob.buckle_mob(src, force = TRUE))
		balloon_alert(src, "latch failed!")
		return
	layer = MOB_ABOVE_PIGGYBACK_LAYER //appear above the target mob
	target_mob.apply_status_effect(/datum/status_effect/slime_leech, src)
	// marked here, so letting go early doesn't undo it
	target_mob.visible_message(
		span_danger("[name] latches onto [target_mob]!"),
		span_userdanger("[name] latches onto [target_mob]!"),
	)
	to_chat(src, span_notice("<i>I start feeding on [target_mob]...</i>"))
	balloon_alert(src, "feeding started")

///The slime will stop feeding
/mob/living/basic/slime/proc/stop_feeding(silent = FALSE)
	if(!isliving(buckled)) // don't "let go of" a chair
		return

	if(!silent)
		visible_message(span_warning("[src] lets go of [buckled]!"), span_notice("You let go of [buckled]"))
		balloon_alert(src, "feeding stopped")
	layer = initial(layer)
	INVOKE_ASYNC(buckled, TYPE_PROC_REF(/atom/movable, unbuckle_mob), src, TRUE)
