/datum/action/cooldown/bloodling/give_life
	name = "Give Life"
	desc = "Bestow the gift of life onto the ignorant. Costs 20 biomass."
	button_icon_state = "give_life"
	biomass_cost = 20

/datum/action/cooldown/bloodling/give_life/PreActivate(atom/target)
	. = ..()

	if(!ismob(target))
		owner.balloon_alert(owner, "only works on mobs!")
		return FALSE

	var/mob/living/mob_target = target
	if(mob_target.mind && !mob_target.stat == DEAD)
		owner.balloon_alert(owner, "only works on non-sentient alive mobs!")
		return FALSE

	if(iscarbon(mob_target))
		owner.balloon_alert(owner, "doesn't work on carbons!")
		return FALSE
	return

/datum/action/cooldown/bloodling/give_life/Activate(atom/target)
	. = ..()

	var/mob/living/target_mob = target
	var/mob/living/basic/bloodling/proper/our_bloodling = owner

	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(check_jobban = ROLE_BLOODLING_THRALL, poll_time = 10 SECONDS, checked_target = target_mob, alert_pic = target_mob, role_name_text = "Bloodling Thrall")

	if(!LAZYLEN(chosen_one))
		owner.balloon_alert(owner, "[target_mob] rejects your generous gift...for now...")
		our_bloodling.add_biomass(20)
		return FALSE

	target_mob.ghostize(FALSE)
	message_admins("[key_name_admin(chosen_one)] has taken control of ([key_name_admin(target_mob)])")
	target_mob.key = chosen_one.key
	target_mob.mind.add_antag_datum(/datum/antagonist/changeling/bloodling_thrall)
	playsound(get_turf(target_mob), 'sound/effects/pray_chaplain.ogg')
	return TRUE

