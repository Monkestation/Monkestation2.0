/**
 * Turns whoever enters into a mob or random person
 *
 * If mob is chosen, turns the person into a random animal type
 * If appearance is chosen, turns the person into a random human with a random species
 * This changes name, and changes their DNA as well
 * Random species is same as wizard swap event so people don't get killed ex: plasmamen
 * Once the spring is used, it cannot be used by the same mind ever again
 * After usage, teleports the user back to a random safe turf (so mobs are not killed by ice moon atmosphere)
 *
 */

/turf/open/water/hot_spring/cursed
	baseturfs = /turf/open/water/hot_spring/cursed
	planetary_atmos = TRUE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	fishing_datum = /datum/fish_source/cursed_spring

/turf/open/water/hot_spring/cursed/dip_in(atom/movable/movable)
	if(!isliving(movable))
		return ..()
	var/mob/living/living = movable
	if(!living.client || living.incorporeal_move || !living.mind)
		return ..()
	if(HAS_MIND_TRAIT(living, TRAIT_HOT_SPRING_CURSED)) // no double dipping
		return ..()

	ADD_TRAIT(living.mind, TRAIT_HOT_SPRING_CURSED, TRAIT_GENERIC)
	// MONKESTATION EDIT: wabbajack() can sleep here (loading preferences), and dip_in() is a signal handler
	INVOKE_ASYNC(src, PROC_REF(curse_bather), living)

/// Turns the bather into a random human or animal, then sends them somewhere safe
/turf/open/water/hot_spring/cursed/proc/curse_bather(mob/living/living)
	var/datum/mind/bather_mind = living.mind
	var/mob/living/transformed_mob = living.wabbajack(pick(WABBAJACK_HUMAN, WABBAJACK_ANIMAL), change_flags = RACE_SWAP)
	if(!transformed_mob)
		// Wabbajack failed, maybe the mob had godmode or something.
		if(!QDELETED(living))
			to_chat(living, span_notice("The water seems to have no effect on you."))
			dip_in(living) // MONKESTATION EDIT: still get the regular hot spring effects
		// because it failed, let's allow them to try again in a lil' bit
		addtimer(TRAIT_CALLBACK_REMOVE(bather_mind, TRAIT_HOT_SPRING_CURSED, TRAIT_GENERIC), 10 SECONDS)
		return

	var/turf/return_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
	transformed_mob.forceMove(return_turf)
	to_chat(transformed_mob, span_notice("You blink and find yourself in [get_area_name(return_turf)]."))
