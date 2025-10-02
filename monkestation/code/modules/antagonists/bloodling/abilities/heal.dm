/datum/action/cooldown/bloodling/heal
	name = "Heal"
	desc = "Allows you to heal or revive a humanoid thrall. Costs 50 biomass."
	button_icon_state = "mend"
	biomass_cost = 50

/datum/action/cooldown/bloodling/heal/PreActivate(atom/target)

	var/mob/living/target_mob = target

	if(get_dist(usr, target) > 1)
		owner.balloon_alert(owner, "Too Far!")
		return FALSE

	if(!ismob(target_mob))
		owner.balloon_alert(owner, "Must target living being!")
		return FALSE

	if(!IS_BLOODLING_OR_THRALL(target_mob))
		owner.balloon_alert(owner, "Only works on your thralls!")
		return FALSE
	. = ..()
	return

/datum/action/cooldown/bloodling/heal/Activate(atom/target)

	if(!IsAvailable(feedback = TRUE))
		return FALSE

	..()

	var/mob/living/carbon/carbon_mob = target
	if(!do_after(owner, 2 SECONDS, hidden = TRUE))
		return FALSE

	// A bit of everything healing not much but helpful
	carbon_mob.adjustBruteLoss(-40)
	carbon_mob.adjustToxLoss(-40)
	carbon_mob.adjustFireLoss(-40)
	carbon_mob.adjustOxyLoss(-40)
	playsound(get_turf(carbon_mob), 'monkestation/sound/effects/fleshyheal.ogg', 55)

	if(carbon_mob.stat != DEAD)
		return FALSE

	carbon_mob.revive()
	// Any oxygen damage they suffered whilst in crit
	carbon_mob.adjustOxyLoss(-200)
	return TRUE

