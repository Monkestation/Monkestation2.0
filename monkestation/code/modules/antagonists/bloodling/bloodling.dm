/datum/antagonist/bloodling
	name = "\improper Bloodling"
	roundend_category = "Bloodlings"
	antagpanel_category = ANTAG_GROUP_BLOODLING
	job_rank = ROLE_BLOODLING
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "bloodling"
	hijack_speed = 0.5
	suicide_cry = "CONSUME!! CLAIM!! THERE WILL BE ANOTHER!!"
	show_name_in_check_antagonists = TRUE

	// If this bloodling is ascended or not
	var/is_ascended = FALSE

/datum/antagonist/bloodling/on_gain()
	forge_objectives()
	var/mob/living/our_mob = owner.current
	our_mob.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue. We are a horrific blob of flesh who can manifest a million tongues.
	our_mob.playsound_local(get_turf(our_mob), 'sound/ambience/antag/ling_alert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	// The midround version of this antag begins as a bloodling, not as a human
	if(!ishuman(our_mob))
		return ..()
	var/datum/action/cooldown/bloodling_infect/infect = new /datum/action/cooldown/bloodling_infect()
	infect.Grant(our_mob)

	add_team_hud(our_mob, /datum/antagonist/changeling/bloodling_thrall)
	add_team_hud(our_mob, /datum/antagonist/infested_thrall)
	return ..()

/datum/antagonist/bloodling/forge_objectives()
	var/datum/objective/bloodling_ascend/ascend_objective = new
	ascend_objective.owner = owner
	objectives += ascend_objective

/datum/antagonist/bloodling/get_preview_icon()
	return finish_preview_icon(icon('monkestation/code/modules/antagonists/bloodling/sprites/bloodling_sprites.dmi', "bloodling_stage_1"))
