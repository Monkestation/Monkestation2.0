/mob/living/basic/slime/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	// living/Life doesn't return anything useful here, so check for ourselves
	if(QDELETED(src) || stat == DEAD)
		return

	if(!HAS_TRAIT(src, TRAIT_STASIS)) //No hunger in stasis
		handle_nutrition(seconds_per_tick)

	handle_slime_stasis()
	handle_ranching()
	handle_slime_upkeep(seconds_per_tick)

/mob/living/basic/slime/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	. = ..()
	if(bodytemperature <= (T0C - 40)) // stun temperature
		apply_status_effect(/datum/status_effect/freon, SLIME_COLD)
	else
		remove_status_effect(/datum/status_effect/freon, SLIME_COLD)

///Handles if a slime's environment would cause it to enter stasis. Ignores TRAIT_STASIS
/mob/living/basic/slime/proc/handle_slime_stasis()
	var/datum/gas_mixture/environment = loc.return_air()
	var/total_moles = environment?.total_moles()
	var/bz_percentage = total_moles ? environment.moles[/datum/gas/bz] / total_moles : 0

	if(bz_percentage >= 0.05 && bodytemperature < (T0C + 100))
		if(!has_status_effect_from_source(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ))
			to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
			apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)
			adjust_power_level(-SLIME_MAX_POWER)
			ai_controller?.set_blackboard_key(BB_SLIME_RABID, FALSE)
	else if(has_status_effect_from_source(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ))
		to_chat(src, span_notice("You wake up from the stasis."))
		remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_SLIME_BZ)

///Handles the consumption of nutrition, and growth
/mob/living/basic/slime/proc/handle_nutrition(seconds_per_tick = SSMOBS_DT)
	if(hunger_disabled) // god as my witness, i will never go hungry again
		set_nutrition(SLIME_STARTING_NUTRITION)
		return

	if(!stops_hunger && SPT_PROB(1.25, seconds_per_tick))
		adjust_nutrition((life_stage == SLIME_LIFE_STAGE_ADULT ? -1 : -0.5) * seconds_per_tick)

	if(nutrition < SLIME_STARVE_NUTRITION)
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_STARVING)

		if(SPT_PROB(0.5, seconds_per_tick) && LAZYLEN(ai_controller?.blackboard[BB_FRIENDS_LIST]))
			var/your_fault = pick(ai_controller.blackboard[BB_FRIENDS_LIST])
			unfriend(your_fault)

	else if(nutrition < SLIME_HUNGER_NUTRITION || (nutrition < SLIME_GROW_NUTRITION && SPT_PROB(25, seconds_per_tick)) )
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_HUNGRY)

	else
		ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_LEVEL, SLIME_HUNGER_NONE)

	// no starvation damage on purpose: starting xenobio three hours into the shift shouldn't be a room of corpses

	if (SLIME_GROW_NUTRITION <= nutrition)

		if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
			adjust_nutrition(-2.5 * seconds_per_tick)
			amount_grown++

		if(powerlevel < SLIME_MAX_POWER && SPT_PROB(30-powerlevel*2, seconds_per_tick))
			adjust_power_level(1 + extra_charge)

	else if (powerlevel < SLIME_MEDIUM_POWER && SLIME_HUNGER_NUTRITION <= nutrition && SPT_PROB(25-powerlevel*5, seconds_per_tick))
		adjust_power_level(1 + extra_charge)

	update_mob_action_buttons()

///Given a number to adjust by, changes our powerlevel.
/mob/living/basic/slime/proc/adjust_power_level(to_adjust)
	// var/was_charged = powerlevel > SLIME_MEDIUM_POWER
	powerlevel = clamp(powerlevel + to_adjust, SLIME_MIN_POWER, SLIME_MAX_POWER)
	// lightning overlay, see update_overlays()
	/* if(was_charged != (powerlevel > SLIME_MEDIUM_POWER))
		update_appearance(UPDATE_OVERLAYS) */
