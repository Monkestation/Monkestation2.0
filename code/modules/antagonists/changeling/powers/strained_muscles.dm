//Strained Muscles: Temporary speed boost at the cost of rapid damage
//Limited because of space suits and such; ideally, used for a quick getaway

//////////////////////
// MONKE REFACTORED //
//////////////////////

/datum/action/changeling/strained_muscles
	name = "Strained Muscles"
	desc = "We evolve the ability to reduce the acid buildup in our muscles, allowing us to move much faster. Costs 10 chemicals to activate."
	helptext = "The strain will make us tired, and we will rapidly become fatigued. Standard weight restrictions, like space suits, still apply. Cannot be used in lesser form."
	button_icon_state = "strained_muscles"
	chemical_cost = 10
	dna_cost = 1
	req_human = TRUE
	active = FALSE //Whether or not you are a hedgehog
	disabled_by_fire = FALSE

	/// How long this has been on in seconds.
	var/accumulation = 0

	/// Whether we've warned the user about their exhaustion.
	var/warning_given = FALSE

/datum/action/changeling/strained_muscles/sting_action(mob/living/carbon/user)
	..()

	if(active)
		stop(user)
	else
		start(user)

	return TRUE

/datum/action/changeling/strained_muscles/Remove(mob/user)
	stop(user, removed = TRUE)
	return ..()

/datum/action/changeling/strained_muscles/proc/start(mob/living/carbon/user)
	active = TRUE
	warning_given = FALSE
	chemical_cost = initial(chemical_cost)
	user.add_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	user.add_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/exhaustion)

	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(user, COMSIG_LIVING_STAMINA_STUN, PROC_REF(on_stamina_stun))
	RegisterSignal(user, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

	to_chat(user, span_notice("Our muscles tense and strengthen."))

/datum/action/changeling/strained_muscles/proc/stop(mob/living/carbon/user, removed = FALSE, forced = FALSE)
	SIGNAL_HANDLER

	active = FALSE
	chemical_cost = 0
	user.remove_movespeed_modifier(/datum/movespeed_modifier/strained_muscles)
	user.remove_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/exhaustion)

	UnregisterSignal(user, list(COMSIG_LIVING_LIFE, COMSIG_LIVING_STAMINA_STUN))

	if(removed) // Don't collapse or send any messages if we've been removed, just remove the effects.
		return

	if(forced)
		user.balloon_alert(user, "relaxed!")

	to_chat(user, forced ? span_warning("Our muscles relax, stripped of energy to strengthen them.") : span_notice("Our muscles relax."))

	if(accumulation > 40)
		user.balloon_alert(user, "you collapse!")
		user.Paralyze(6 SECONDS)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, emote), "gasp")

/datum/action/changeling/strained_muscles/proc/on_life(mob/living/carbon/user, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	accumulation += DELTA_WORLD_TIME(SSmobs)

	if(accumulation > 40 && !warning_given)
		to_chat(user, span_userdanger("Our legs are really starting to hurt..."))
		warning_given = TRUE

	user.stamina.adjust(STAMINA_MAX * -0.001 * accumulation * seconds_per_tick)

/datum/action/changeling/strained_muscles/proc/on_stamina_stun(mob/living/carbon/user)
	SIGNAL_HANDLER
	stop(user, forced = TRUE)

/datum/action/changeling/strained_muscles/proc/on_stat_change(mob/living/carbon/user, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat != CONSCIOUS)
		stop(user, forced = TRUE)
