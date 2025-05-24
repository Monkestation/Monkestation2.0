/datum/antagonist/nightmare
	name = "\improper Nightmare"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	job_rank = ROLE_NIGHTMARE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoNightmare"
	suicide_cry = "FOR THE DARKNESS!!"
	preview_outfit = /datum/outfit/nightmare

/datum/antagonist/nightmare/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/nightmare/on_gain()
	owner.set_assigned_role(SSjob.GetJobType(/datum/job/nightmare))
	owner.special_role = ROLE_NIGHTMARE
	var/mob/living/carbon/human/H = owner.current
	H.set_species(/datum/species/shadow/nightmare)
	forge_objectives()
	. = ..()

/datum/outfit/nightmare
	name = "Nightmare (Preview only)"

/datum/outfit/nightmare/post_equip(mob/living/carbon/human/human, visualsOnly)
	human.set_species(/datum/species/shadow/nightmare)

/datum/objective/nightmare_fluff

/datum/objective/nightmare_fluff/New()
	var/list/explanation_texts = list(
		"Consume the last glimmer of light from the space station.",
		"Bring judgment upon the daywalkers.",
		"Extinguish the flame of this hellscape.",
		"Reveal the true nature of the shadows.",
		"From the shadows, all shall perish.",
		"Conjure nightfall by blade or by flame.",
		"Bring the darkness to the light."
	)
	explanation_text = pick(explanation_texts)
	..()

/datum/objective/nightmare_fluff/check_completion()
	return owner.current.stat != DEAD

/datum/antagonist/nightmare/forge_objectives()
	var/datum/objective/nightmare_fluff/objective = new
	objective.owner = owner
	objectives += objective

/datum/antagonist/nightmare/antag_token(datum/mind/hosts_mind, mob/spender)
	var/spender_key = spender.key
	if(!spender_key)
		CRASH("wtf, spender had no key")
	var/turf/spawn_loc = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = TRUE)
	if(isnull(spawn_loc))
		spawn_loc = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE) // Try again but with light. Not ideal but better than not spawning the token.
		if(isnull(spawn_loc))
			message_admins("Failed to find valid spawn location for [ADMIN_LOOKUPFLW(spender)], who spent a nightmare antag token")
			CRASH("Failed to find valid spawn location for nightmare antag token")
	if(isliving(spender) && hosts_mind)
		hosts_mind.current.unequip_everything()
		new /obj/effect/holy(hosts_mind.current.loc)
		QDEL_IN(hosts_mind.current, 1 SECOND)
	var/mob/living/carbon/human/nightmare = new (spawn_loc)
	nightmare.PossessByPlayer(spender_key)
	nightmare.mind.add_antag_datum(/datum/antagonist/nightmare)
	playsound(nightmare, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	if(isobserver(spender))
		qdel(spender)
	message_admins("[ADMIN_LOOKUPFLW(nightmare)] has been made into a nightmare by using an antag token.")
