/datum/round_event_control/wizard/imposter //Mirror Mania
	name = "Imposter Wizard"
	weight = 2
	typepath = /datum/round_event/wizard/imposter
	max_occurrences = 2
	earliest_start = 0 MINUTES
	description = "Spawns a doppelganger of the wizard."
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 100

/datum/round_event/wizard/imposter/start()
	var/list/candidates = SSpolling.poll_ghost_candidates("Would you like to be an [span_notice("imposter wizard")]?",
														check_jobban = ROLE_WIZARD,
														alert_pic = /obj/item/clothing/head/wizard,
														role_name_text = "imposter wizard")

	var/list/wiz_minds = get_antag_minds(/datum/antagonist/wizard)
	while(length(wiz_minds) && length(candidates))
		var/datum/mind/wiz_mind = pick_n_take(wiz_minds)
		if(!wiz_mind.current)
			continue

		var/mob/living/wiz_current = wiz_mind.current
		var/mob/picked = pick_n_take(candidates)
		var/mob/living/carbon/human/created = new /mob/living/carbon/human(wiz_current.loc)
		new /obj/effect/particle_effect/fluid/smoke(get_turf(wiz_current))
		var/datum/dna/wiz_dna = wiz_current.has_dna()
		if(wiz_dna)
			wiz_dna.copy_dna(created.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
			created.domutcheck()
			created.updateappearance(mutcolor_update = TRUE)

		created.fully_replace_character_name(null, wiz_mind.name)
		created.PossessByPlayer(picked.key)
		var/datum/antagonist/wizard/master = wiz_mind.has_antag_datum(/datum/antagonist/wizard)
		if(!master.wiz_team)
			master.create_wiz_team()
		var/datum/antagonist/wizard/apprentice/imposter/imposter = new()
		imposter.master = wiz_mind
		imposter.wiz_team = master.wiz_team
		master.wiz_team.add_member(imposter)
		created.mind.add_antag_datum(imposter)
		created.mind.special_role = ROLE_WIZARD_APPRENTICE //before this had a snowflake special role, I feel this is better
		created.log_message("is an imposter!", LOG_ATTACK, color = "red")
		SEND_SOUND(created, sound('sound/effects/magic.ogg'))
		announce_to_ghosts(created)
