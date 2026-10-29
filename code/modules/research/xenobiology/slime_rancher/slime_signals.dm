/// holds a grudge against whoever hit us, and a monkey swinging at one slime gets the whole pen mad at it
/mob/living/basic/slime/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if(cat_slime && !cat_patience_ran_out(attacker, attack_flags))
		return
	add_grudge(attacker)
	if(!ismonkeybasic(attacker))
		return
	for(var/mob/living/basic/slime/buddy in oview(SLIME_MONKEY_RALLY_RANGE, src))
		if(buddy.stat)
			continue
		buddy.add_grudge(attacker)

/// Cat slimes let a few hits slide, this is TRUE once they've had enough
/mob/living/basic/slime/proc/cat_patience_ran_out(atom/attacker, attack_flags)
	if(!(attack_flags & ATTACKER_DAMAGING_ATTACK))
		return FALSE
	if(attacker in ai_controller?.blackboard[BB_BASIC_MOB_RETALIATE_LIST])
		return TRUE
	if(world.time - cat_patience_last_hit > SLIME_CAT_PATIENCE_WINDOW)
		cat_patience_hits = 0
	cat_patience_hits++
	cat_patience_last_hit = world.time
	return cat_patience_hits >= SLIME_CAT_PATIENCE_HITS

/// Adds (or refreshes) someone on our grudge list. The grudge lasts SLIME_GRUDGE_DURATION past the last hit.
/mob/living/basic/slime/proc/add_grudge(atom/attacker)
	if(attacker == src)
		return
	ai_controller?.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker, world.time)

/// every new friend wipes the slate clean
/mob/living/basic/slime/proc/on_befriended(datum/source, mob/living/new_friend)
	SIGNAL_HANDLER
	set_temporary_mood(SLIME_MOOD_SMILE)
	if(isnull(ai_controller))
		return
	ai_controller.clear_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST)
	ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	ai_controller.CancelActions()
