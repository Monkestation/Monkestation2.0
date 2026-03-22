/datum/action/cooldown/bloodling/give_life
	name = "Give Life"
	desc = "Bestow the gift of life onto the ignorant. Costs 20 biomass."
	button_icon_state = "give_life"
	biomass_cost = 20
	cooldown_time = 15 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/bloodling/give_life/PreActivate(atom/target)
	if(get_dist(usr, target) > 1)
		owner.balloon_alert(owner, "too Far!")
		return FALSE

	if(!ismob(target))
		owner.balloon_alert(owner, "only works on mobs!")
		return FALSE

	var/mob/living/mob_target = target

	if(!istype(target, /mob/living/basic/bloodling/minion))
		owner.balloon_alert(owner, "must target one of our own flesh minions!")
		return FALSE

	if(mob_target.mind && !mob_target.stat == DEAD)
		owner.balloon_alert(owner, "only works on non-sentient alive mobs!")
		return FALSE
	..()

/datum/action/cooldown/bloodling/give_life/Activate(atom/target)

	var/mob/living/target_mob = target
	if(target_mob.ckey) //only works on animals that aren't player controlled
		target_mob.balloon_alert(target_mob, "already sentient!")
		return FALSE
	..()
	target_mob.balloon_alert(target_mob, "giving sentience to flesh...")

	var/mob/living/basic/bloodling/proper/our_bloodling = owner
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target("Do you want to play as [span_notice("Bloodling Thrall")]?",
	check_jobban = ROLE_BLOODLING_THRALL, poll_time = 10 SECONDS,
	checked_target = target_mob,
	alert_pic = target_mob,
	role_name_text = "Bloodling Thrall",
	)

	if(isnull(chosen_one))
		owner.balloon_alert(owner, "[target_mob] rejects your generous gift...for now...")
		our_bloodling.add_biomass(20)
		return FALSE

	target_mob.ghostize()
	target_mob.PossessByPlayer(chosen_one.key)
	target_mob.mind.enslave_mind_to_creator(owner)
	var/datum/antagonist/infested_thrall/bloodling_minion = target_mob.mind.add_antag_datum(/datum/antagonist/infested_thrall)
	bloodling_minion.set_master(owner)
	message_admins("[key_name_admin(chosen_one)] has taken control of ([key_name_admin(target_mob)])")
	return TRUE
