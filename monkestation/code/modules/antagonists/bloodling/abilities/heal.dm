/datum/action/cooldown/mob_cooldown/bloodling/heal
	name = "Heal"
	desc = "Allows you to heal or revive a humanoid thrall. Costs 50 biomass."
	button_icon_state = "mend"
	biomass_cost = 50

/datum/action/cooldown/mob_cooldown/bloodling/heal/PreActivate(atom/target)
	. = ..()

	if(!ismob(target))
		return FALSE

	var/mob/living/targetted_mob = target
	if(!iscarbon(targetted_mob))
		return FALSE

	if(!IS_BLOODLING_THRALL(targetted_mob))
		return FALSE
	return

/datum/action/cooldown/mob_cooldown/bloodling/heal/Activate(atom/target)
	. = ..()

	var/mob/living/carbon/carbon_mob = target
	if(!do_after(owner, 2 SECONDS))
		return FALSE

	// A bit of everything healing not much but helpful
	carbon_mob.adjustBruteLoss(-40)
	carbon_mob.adjustToxLoss(-40)
	carbon_mob.adjustFireLoss(-40)
	carbon_mob.adjustOxyLoss(-40)
	playsound(get_turf(carbon_mob), 'sound/magic/staff_healing.ogg', 30)

	if(carbon_mob.stat != DEAD)
		return TRUE

	carbon_mob.revive()
	// Any oxygen damage they suffered whilst in crit
	carbon_mob.adjustOxyLoss(-200)
	return TRUE

