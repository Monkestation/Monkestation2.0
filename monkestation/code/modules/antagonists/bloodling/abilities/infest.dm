/datum/action/cooldown/bloodling/infest
	name = "Infest"
	desc = "Allows you to infest a living creature, turning them into a thrall. Can be used on mindshielded people but it takes longer. Costs 75 biomass."
	button_icon_state = "infest"
	biomass_cost = 75
	/// If we are currently infesting
	var/is_infesting = FALSE

/datum/action/cooldown/bloodling/infest/PreActivate(atom/target)

	if(is_infesting)
		owner.balloon_alert(owner, "already infesting!")
		return FALSE

	if(get_dist(usr, target) > 1)
		owner.balloon_alert(owner, "Too Far!")
		return FALSE

	if(!ismob(target))
		owner.balloon_alert(owner, "doesn't work on non-mobs!")
		return FALSE

	var/mob/living/alive_mob = target
	if(isnull(alive_mob.mind))
		owner.balloon_alert(owner, "doesn't work on mindless mobs!")
		return FALSE

	if(IS_BLOODLING_OR_THRALL(alive_mob))
		return FALSE

	if(alive_mob.stat == DEAD)
		owner.balloon_alert(owner, "doesn't work on dead mobs!")
		return FALSE
	..()
	return

/datum/action/cooldown/bloodling/infest/Activate(atom/target)
	. = ..()

	var/mob/living/mob = target
	var/infest_time = 15 SECONDS

	// If they are standing on the ascended bloodling tiles it takes 1/5th of the time to infest them
	if(isturf(get_turf(mob), /turf/open/misc/bloodling))
		infest_time = infest_time / 5

	if(iscarbon(mob))
		var/mob/living/carbon/human/carbon_mob = target
		infest_time *= 2

		if(HAS_TRAIT(carbon_mob, TRAIT_MINDSHIELD))
			infest_time *= 2

		owner.balloon_alert(carbon_mob, "[owner] attempts to infest you!")
		is_infesting = TRUE
		ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, src)
		if(!do_after(owner, infest_time, hidden = TRUE))
			is_infesting = FALSE
			REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, src)
			return FALSE

		is_infesting = FALSE
		var/datum/antagonist/changeling/bloodling_thrall/thrall = carbon_mob.mind.add_antag_datum(/datum/antagonist/changeling/bloodling_thrall)
		thrall.set_master(owner)

	else
		is_infesting = TRUE
		ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, src)
		if(!do_after(owner, infest_time, hidden = TRUE))
			is_infesting = FALSE
			REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, src)
			return FALSE

		is_infesting = FALSE
		var/datum/antagonist/infested_thrall/thrall = mob.mind.add_antag_datum(/datum/antagonist/infested_thrall)
		thrall.set_master(owner)

	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, src)
	playsound(get_turf(mob), 'sound/items/drink.ogg', 30)
	return TRUE
