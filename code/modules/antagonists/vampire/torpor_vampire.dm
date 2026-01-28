/**
 * # Torpor
 *
 * Torpor is what deals with the Vampire falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [coffins.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Burn damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [vampire_daylight.dm]
**/
/datum/antagonist/vampire/proc/check_begin_torpor()
	var/mob/living/carbon/carbon_owner = owner.current
	if(QDELETED(carbon_owner))
		return
	var/total_damage = carbon_owner.getBruteLoss() + carbon_owner.getFireLoss()
	if(total_damage >= 10 || length(carbon_owner.all_wounds))
		carbon_owner.apply_status_effect(/datum/status_effect/vampire_torpor)

/datum/status_effect/vampire_torpor
	id = "torpor"
	alert_type = null
	remove_on_fullheal = TRUE
	heal_flag_necessary = HEAL_ADMIN // so admins can aheal in case stuff goes fucky wucky
	/// Antag datum of the vampire.
	var/datum/antagonist/vampire/vampire_datum
	/// Cooldown twhere, if it finishes, we'll just force heal the vampire, to avoid eternal torpor.
	COOLDOWN_DECLARE(force_heal_time)
	/// List of traits applied while in torpor.
	var/static/list/torpor_traits = list(
		TRAIT_DEATHCOMA,
		TRAIT_FAKEDEATH,
		TRAIT_NODEATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TORPOR,
	)

/datum/status_effect/vampire_torpor/on_apply()
	if(!iscarbon(owner) || QDELING(owner))
		return FALSE
	vampire_datum = IS_VAMPIRE(owner)
	if(!vampire_datum)
		. = FALSE
		CRASH("Attempted to apply [type] to a non-vampire!")
	if(vampire_datum.final_death)
		return FALSE
	REMOVE_TRAIT(owner, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
	owner.add_traits(torpor_traits, TRAIT_STATUS_EFFECT(id))
	owner.remove_status_effect(/datum/status_effect/jitter)
	vampire_datum.disable_all_powers()
	to_chat(owner, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))
	COOLDOWN_START(src, force_heal_time, 5 MINUTES)
	return TRUE

/datum/status_effect/vampire_torpor/on_remove()
	if(!iscarbon(owner) || vampire_datum.final_death)
		return

	owner.grab_ghost()
	owner.remove_traits(torpor_traits, TRAIT_STATUS_EFFECT(id))
	if(!HAS_TRAIT(owner, TRAIT_MASQUERADE))
		ADD_TRAIT(owner, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)

	vampire_datum.heal_vampire_organs()
	vampire_datum.my_clan?.on_exit_torpor()
	vampire_datum = null

	to_chat(owner, span_notice("You have recovered from Torpor."))

/datum/status_effect/vampire_torpor/tick(seconds_between_ticks)
	if(should_end())
		qdel(src)
		return

	if(COOLDOWN_FINISHED(src, force_heal_time) && !QDELETED(owner))
		owner.revive(HEAL_ALL, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
		qdel(src)

/datum/status_effect/vampire_torpor/proc/should_end()
	if(HAS_TRAIT(owner, TRAIT_FRENZY))
		return TRUE
	var/total_brute = owner.getBruteLoss()
	var/total_burn = owner.getFireLoss()

	if(total_burn >= 199)
		return FALSE

	// You are in a coffin, so instead we'll check TOTAL damage.
	if(istype(owner.loc, /obj/structure/closet/crate/coffin))
		if((total_brute + total_burn) <= 10)
			owner.heal_overall_damage(brute = 10, burn = 10) // heal minor leftover damage
			return TRUE
	else if(total_brute <= 10)
		owner.heal_overall_damage(brute = 10) // heal minor leftover damage
		return TRUE

	return FALSE
