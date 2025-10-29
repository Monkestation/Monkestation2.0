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
	ui_name = "AntagInfoBloodling"
	antag_flags = parent_type::antag_flags | FLAG_ANTAG_CAP_TEAM | FLAG_ANTAG_CAP_IGNORE_HUMANITY
	antag_count_points = 15

	// If this bloodling is ascended or not
	var/is_ascended = FALSE
	// The team datum
	var/datum/team/bloodling/bling_team
	// The areas in which in you are able to ascend
	var/list/ascension_areas = list()

/datum/antagonist/bloodling/on_gain()
	generate_ascension_areas()
	forge_objectives()
	var/mob/living/our_mob = owner.current
	our_mob.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue. We are a horrific blob of flesh who can manifest a million tongues.
	our_mob.playsound_local(get_turf(our_mob), 'sound/ambience/antag/ling_alert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	// The midround version of this antag begins as a bloodling, not as a human
	if(!ishuman(our_mob))
		return ..()
	var/datum/action/cooldown/bloodling_infect/infect = new /datum/action/cooldown/bloodling_infect()
	infect.Grant(our_mob)
	handle_clown_mutation(our_mob, "Though this form may be that of a clown you will not stoop to the level of a fool.")

	for(var/datum/antagonist/bloodling/bling in GLOB.antagonists)
		if(!bling.owner)
			continue
		if(bling.bling_team)
			bling_team = bling.bling_team
			add_team_hud(our_mob)
			return ..()

	bling_team = new /datum/team/bloodling
	bling_team.setup_objectives()
	bling_team.master = src
	add_team_hud(our_mob, /datum/antagonist/infested_thrall)
	add_team_hud(our_mob, /datum/antagonist/changeling/bloodling_thrall)

	return ..()

/datum/antagonist/bloodling/forge_objectives()
	var/datum/objective/bloodling_ascend/ascend_objective = new
	ascend_objective.owner = owner
	ascend_objective.ascend_areas = ascension_areas
	objectives += ascend_objective

/datum/antagonist/bloodling/get_preview_icon()
	return finish_preview_icon(icon('monkestation/code/modules/antagonists/bloodling/sprites/bloodling_sprites.dmi', "bloodling_stage_1"))

/// This generates the areas for the bloodling to ascend in
/datum/antagonist/bloodling/proc/generate_ascension_areas()
	/// List of high-security areas that we pick required ones from
	var/list/allowed_areas = typecacheof(list(/area/station/command,
		/area/station/comms,
		/area/station/engineering,
		/area/station/science,
		/area/station/security,
	))

	var/list/blacklisted_areas = typecacheof(list(/area/station/engineering/hallway,
		/area/station/engineering/lobby,
		/area/station/engineering/storage,
		/area/station/science/lobby,
		/area/station/science/ordnance/bomb,
		/area/station/security/prison,
	))

	var/list/possible_areas = GLOB.areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(!is_type_in_typecache(possible_area, allowed_areas) || initial(possible_area.outdoors) || is_type_in_typecache(possible_area, blacklisted_areas))
			possible_areas -= possible_area

	for(var/i in 1 to 3)
		ascension_areas += pick_n_take(possible_areas)

	return ascension_areas
