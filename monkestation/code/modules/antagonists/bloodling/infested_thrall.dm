/datum/antagonist/changeling/bloodling_thrall
	name = "\improper Changeling Thrall"
	roundend_category = "bloodling thralls"
	antagpanel_category = ANTAG_GROUP_BLOODLING
	job_rank = ROLE_BLOODLING_THRALL
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "infested_thrall"
	hijack_speed = 0
	suicide_cry = "FOR THE MASTER!!"
	genetic_points = 5
	total_genetic_points = 5

	// This thralls master
	var/master = null

/datum/antagonist/changeling/bloodling_thrall/purchase_power(datum/action/changeling/sting_path)
	if(istype(sting_path, /datum/action/changeling/fakedeath))
		to_chat(owner.current, span_warning("We are unable to evolve that ability"))
		return FALSE
	return ..()

/datum/antagonist/changeling/bloodling_thrall/create_innate_actions()
	for(var/datum/action/changeling/path as anything in all_powers)
		if(initial(path.dna_cost) != 0)
			continue
		var/datum/action/changeling/innate_ability = new path()
		if(istype(innate_ability, /datum/action/changeling/fakedeath))
			continue
		innate_powers += innate_ability
		innate_ability.on_purchase(owner.current, TRUE)
	var/datum/action/cooldown/bloodling_hivespeak/hivetalk = new()
	hivetalk.Grant(owner.current)

/datum/antagonist/changeling/bloodling_thrall/proc/set_master(mob/living/basic/bloodling/master)
	to_chat(owner, span_info("Your master is [master], they have granted you this gift. Obey their commands. Praise be the living flesh."))
	src.master = master
	add_team_hud(owner.current)
	add_team_hud(owner.current, /datum/antagonist/bloodling)
	add_team_hud(owner.current, /datum/antagonist/infested_thrall)

/datum/antagonist/changeling/bloodling_thrall/forge_objectives()
	var/datum/objective/bloodling_thrall/serve_objective = new
	serve_objective.owner = owner
	objectives += serve_objective

/datum/antagonist/infested_thrall
	name = "\improper Infested Thrall"
	roundend_category = "bloodling thralls"
	antagpanel_category = ANTAG_GROUP_BLOODLING
	job_rank = ROLE_BLOODLING_THRALL
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "infested_thrall"
	hijack_speed = 0
	suicide_cry = "FOR THE MASTER!!"

	// This thralls master
	var/master = null

/datum/antagonist/infested_thrall/on_gain()
	forge_objectives()
	owner.current.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue. We are a horrific blob of flesh who can manifest a million tongues.
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_alert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	return ..()

/datum/antagonist/changeling/bloodling_thrall/create_innate_actions()
	var/datum/action/cooldown/bloodling_hivespeak/hivetalk = new()
	hivetalk.Grant(owner.current)

/datum/antagonist/infested_thrall/forge_objectives()
	var/datum/objective/bloodling_thrall/serve_objective = new
	serve_objective.owner = owner
	objectives += serve_objective
	if(master)
		serve_objective.update_explanation_text()

/datum/antagonist/infested_thrall/proc/set_master(mob/living/basic/bloodling/master)
	to_chat(owner, span_info("Your master is [master], they have granted you this gift. Obey their commands. Praise be the living flesh."))
	src.master = master
	add_team_hud(owner.current)
	add_team_hud(owner.current, /datum/antagonist/bloodling)
	add_team_hud(owner.current, /datum/antagonist/changeling/bloodling_thrall)
