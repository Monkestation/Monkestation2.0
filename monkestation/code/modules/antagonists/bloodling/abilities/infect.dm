/datum/action/cooldown/bloodling_infect
	name = "Infect"
	desc = "Allows us to make someone our thrall, this consumes our host body and reveals our true form. You will be VERY vulnerable when you initially reach this form."
	background_icon = 'monkestation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_bloodling"
	button_icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_abilities.dmi'
	button_icon_state = "infest"
	///if we're currently infecting
	var/is_infecting = FALSE

/datum/action/cooldown/bloodling_infect/Activate(atom/target)
	. = ..()

	if(is_infecting)
		owner.balloon_alert(owner, "already infecting!")
		return

	if(!owner.pulling)
		owner.balloon_alert(owner, "needs grab!")
		return

	if(!iscarbon(owner.pulling))
		owner.balloon_alert(owner, "not a humanoid!")
		return

	if(owner.grab_state <= GRAB_NECK)
		owner.balloon_alert(owner, "needs tighter grip!")
		return

	is_infecting = TRUE
	var/mob/living/old_body = owner

	var/mob/living/carbon/human/carbon_mob = owner.pulling


	var/infest_time = 10 SECONDS

	if(HAS_TRAIT(carbon_mob, TRAIT_MINDSHIELD))
		infest_time *= 2

	carbon_mob.Paralyze(infest_time)
	ADD_TRAIT(carbon_mob, TRAIT_MUTE, REF(src))
	owner.balloon_alert(carbon_mob, "[owner] attempts to infect you!")
	if(!do_after(owner, infest_time, hidden = TRUE))
		is_infecting = FALSE
		REMOVE_TRAIT(carbon_mob, TRAIT_MUTE, REF(src))
		return FALSE

	REMOVE_TRAIT(carbon_mob, TRAIT_MUTE, REF(src))

	if(!carbon_mob.mind || !carbon_mob.client)
		var/mob/chosen_one = null
		if(carbon_mob.stat == DEAD)
			chosen_one = carbon_mob.get_ghost(ghosts_with_clients = TRUE)
			if(!carbon_mob.client && !chosen_one)
				chosen_one = SSpolling.poll_ghosts_for_target(
					check_jobban = ROLE_BLOODLING_THRALL,
					poll_time = 10 SECONDS,
					checked_target = carbon_mob,
					alert_pic = carbon_mob,
					role_name_text = "Bloodling Thrall",
					)

		if(isnull(chosen_one))
			is_infecting = FALSE
			return FALSE

		carbon_mob.ghostize(FALSE)
		carbon_mob.PossessByPlayer(chosen_one.key)

	if(carbon_mob.stat == DEAD)
		// This cures limbs and anything, the target is made a changeling through this process anyhow
		carbon_mob.revive(ADMIN_HEAL_ALL, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)

	var/datum/antagonist/changeling/bloodling_thrall/thrall = carbon_mob.mind.add_antag_datum(/datum/antagonist/changeling/bloodling_thrall)
	if(!thrall)
		carbon_mob.balloon_alert(owner, "failed to infect [carbon_mob]")
		return FALSE
	thrall.set_master(owner)
	carbon_mob.mind.enslave_mind_to_creator(owner)

	carbon_mob.balloon_alert(owner, "[carbon_mob] successfully infected!")

	var/mob/living/basic/bloodling/proper/tier1/bloodling = new /mob/living/basic/bloodling/proper/tier1/(old_body.loc)
	owner.mind.transfer_to(bloodling)

	var/datum/action/cooldown/spell/vow_of_silence/vow = locate() in bloodling.actions
	if(vow)
		vow.Remove(bloodling)

	old_body.gib()
	var/datum/antagonist/bloodling_datum = IS_BLOODLING(bloodling)
	for(var/datum/objective/objective in bloodling_datum.objectives)
		objective.update_explanation_text()

	playsound(get_turf(bloodling), 'sound/ambience/antag/blobalert.ogg', 50, FALSE)
	qdel(src)
