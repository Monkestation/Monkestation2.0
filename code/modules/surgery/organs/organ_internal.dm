/obj/item/organ/internal
	name = "organ"

/obj/item/organ/internal/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/Destroy()
	if(owner)
		// The special flag is important, because otherwise mobs can die
		// while undergoing transformation into different mobs.
		Remove(owner, special=TRUE)
	else
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/organ/internal/Insert(mob/living/carbon/receiver, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(!. || !owner)
		return

	// organs_slot must ALWAYS be ordered in the same way as organ_process_order
	// Otherwise life processing breaks down
	sortTim(owner.organs_slot, GLOBAL_PROC_REF(cmp_organ_slot_asc))

	STOP_PROCESSING(SSobj, src)

/obj/item/organ/internal/Remove(mob/living/carbon/organ_owner, special = FALSE)
	. = ..()

	if(organ_owner)
		if((organ_flags & ORGAN_VITAL) && !special && !(HAS_TRAIT(organ_owner, TRAIT_GODMODE)))
			if(organ_owner.stat != DEAD)
				organ_owner.investigate_log("has been killed by losing a vital organ ([src]).", INVESTIGATE_DEATHS)
			organ_owner.death(null, "losing your [name]")

	START_PROCESSING(SSobj, src)


/obj/item/organ/internal/process(seconds_per_tick, times_fired)
	on_death(seconds_per_tick, times_fired) //Kinda hate doing it like this, but I really don't want to call process directly.

/obj/item/organ/internal/on_death(seconds_per_tick, times_fired) //runs decay when outside of a person
	if(organ_flags & (ORGAN_ROBOTIC | ORGAN_FROZEN))
		return
	if(HAS_TRAIT(src, TRAIT_NO_ORGAN_DECAY) || (owner && HAS_TRAIT(owner, TRAIT_NO_ORGAN_DECAY)))
		return
	var/air_temperature_factor = 1
	if(owner)
		if(owner.bodytemperature <= T0C)
			return
		air_temperature_factor = min((owner.bodytemperature - T0C) / 20, 1)
	else
		var/datum/gas_mixture/exposed_air = return_air()
		if(exposed_air)
			if(exposed_air.temperature <= T0C)
				return
			air_temperature_factor = min((exposed_air.temperature - T0C) / 20, 1)
	apply_organ_damage(decay_factor * maxHealth * seconds_per_tick * air_temperature_factor)

/// Called once every life tick on every organ in a carbon's body
/// NOTE: THIS IS VERY HOT. Be careful what you put in here
/// To give you some scale, if there's 100 carbons in the game, they each have maybe 9 organs
/// So that's 900 calls to this proc every life process. Please don't be dumb
/obj/item/organ/internal/on_life(seconds_per_tick, times_fired) //repair organ damage if the organ is not failing
	if(organ_flags & ORGAN_FAILING)
		handle_failing_organs(seconds_per_tick)
		return

	if(failure_time > 0)
		failure_time--

	if(organ_flags & ORGAN_EMP) //Synthetic organ has been emped, is now failing.
		apply_organ_damage(decay_factor * maxHealth * seconds_per_tick)
		return

	if(!damage) // No sense healing if you're not even hurt bro
		return

	///Damage decrements by a percent of its maxhealth
	var/healing_amount = healing_factor
	///Damage decrements again by a percent of its maxhealth, up to a total of 4 extra times depending on the owner's health
	healing_amount += (owner.satiety > 0) ? (4 * healing_factor * owner.satiety / MAX_SATIETY) : 0
	apply_organ_damage(-healing_amount * maxHealth * seconds_per_tick, damage) // pass curent damage incase we are over cap

///Used as callbacks by object pooling
/obj/item/organ/internal/exit_wardrobe()
	START_PROCESSING(SSobj, src)

//See above
/obj/item/organ/internal/enter_wardrobe()
	STOP_PROCESSING(SSobj, src)

///Organs don't die instantly, and neither should you when you get fucked up
/obj/item/organ/internal/handle_failing_organs(seconds_per_tick)
	if(owner.stat == DEAD)
		return

	failure_time += seconds_per_tick
	organ_failure(seconds_per_tick)
