/datum/action/cooldown/bloodling_infect
	name = "Infect"
	desc = "Allows us to make someone our thrall, this consumes our host body and reveals our true form."
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

	owner.balloon_alert(carbon_mob, "[owner] attempts to infect you!")
	if(!do_after(owner, infest_time))
		is_infecting = FALSE
		return FALSE

	if(carbon_mob.stat == DEAD)
		// This cures limbs and anything, the target is made a changeling through this process anyhow
		carbon_mob.revive(ADMIN_HEAL_ALL)

	if(!carbon_mob.mind)
		var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
			"Would you like to be a [carbon_mob] servant of [owner]?",
			ROLE_BLOODLING_THRALL,
			ROLE_BLOODLING_THRALL,
			10 SECONDS,
			carbon_mob,
			POLL_IGNORE_SHUTTLE_DENIZENS,
			alert_pic = carbon_mob
		)

		if(!LAZYLEN(candidates))
			is_infecting = FALSE
			return FALSE

		var/mob/dead/observer/chosen = pick(candidates)
		carbon_mob.key = chosen.key

	var/datum/antagonist/changeling/bloodling_thrall/thrall = carbon_mob.mind.add_antag_datum(/datum/antagonist/changeling/bloodling_thrall)
	thrall.set_master(owner)

	carbon_mob.balloon_alert(owner, "[carbon_mob] is successfully infected!")

	var/mob/living/basic/bloodling/proper/tier1/bloodling = new /mob/living/basic/bloodling/proper/tier1/(old_body.loc)
	owner.mind.transfer_to(bloodling)

	old_body.gib()
	var/datum/antagonist/bloodling_datum = IS_BLOODLING(bloodling)
	for(var/datum/objective/objective in bloodling_datum.objectives)
		objective.update_explanation_text()

	playsound(get_turf(bloodling), 'sound/ambience/antag/blobalert.ogg', 50, FALSE)
	qdel(src)
