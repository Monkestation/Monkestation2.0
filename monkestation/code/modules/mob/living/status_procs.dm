/* DISORIENTED */
/**
 * Applies the "disoriented" status effect to the mob, among other potential statuses.
 * Args:
 * * amount : duration for src to be disoriented
 * * stamina_amount : stamina damage to deal before LERP
 * * ignore_canstun : ignore stun immunities, if using a secondary form of status
 * * knockdown : duration to knock src down
 * * stun : duration to stun src
 * * paralyze : duration to paralyze src
 * * stack_status : Should the given status value(s) stack ontop of existing status values?
 */
/mob/living/proc/Disorient(amount, ignore_canstun, knockdown, stun, paralyze, stack_status = FALSE)
	if(!HAS_TRAIT(src, TRAIT_CANT_STAMCRIT))
		if(knockdown)
			if(stack_status)
				AdjustKnockdown(knockdown, ignore_canstun, TRUE)
			else
				Knockdown(knockdown, ignore_canstun, TRUE)

		if(paralyze)
			if(stack_status)
				AdjustParalyzed(paralyze, ignore_canstun, TRUE)
			else
				Paralyze(paralyze, ignore_canstun, TRUE)

		if(stun)
			if(stack_status)
				AdjustStun(stun, ignore_canstun, TRUE)
			else
				Stun(stun, ignore_canstun, TRUE)

	if(amount > 0)
		adjust_timed_status_effect(amount, /datum/status_effect/incapacitating/disoriented, 15 SECONDS)
		var/datum/status_effect/incapacitating/disoriented/existing = has_status_effect(/datum/status_effect/incapacitating/disoriented)
		existing.knockdown += knockdown
		existing.paralyze += paralyze
		existing.stun += stun
	return


/mob/living/proc/IsDisoriented() //If we're paralyzed
	return has_status_effect(/datum/status_effect/incapacitating/disoriented)

/mob/living/proc/AmountDisoriented() //How many deciseconds remain in our Paralyzed status effect
	var/datum/status_effect/incapacitating/disoriented/P = IsDisoriented()
	if(P)
		return P.duration - world.time
	return 0
