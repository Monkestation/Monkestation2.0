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
	owner.current.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue. We are a horrific blob of flesh who can manifest a million tongues.
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_alert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	// The midround version of this antag begins as a bloodling, not as a human
	if(!ishuman(owner.current))
		return ..()
	var/datum/action/cooldown/bloodling_infect/infect = new /datum/action/cooldown/bloodling_infect()
	infect.Grant(owner.current)
	return ..()

/datum/antagonist/bloodling/forge_objectives()
	var/datum/objective/bloodling_ascend/ascend_objective = new
	ascend_objective.owner = owner
	objectives += ascend_objective

/datum/antagonist/bloodling/get_preview_icon()
	return finish_preview_icon(icon('monkestation/code/modules/antagonists/bloodling/sprites/bloodling_sprites.dmi', "bloodling_stage_1"))
