/datum/round_event_control/antagonist/heretic
	antag_flag = ROLE_HERETIC
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_MAGICAL, TAG_CREW_ANTAG)
	antag_datum = /datum/antagonist/heretic
	typepath = /datum/round_event/antagonist/heretic
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
		JOB_BRIDGE_ASSISTANT,
		JOB_CHAPLAIN
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
		JOB_CHAPLAIN,
	)
	required_enemies = 6
	weight = 5
	min_players = 20

/datum/round_event_control/antagonist/heretic/get_weight()
	. = ..()
	// 1.5x higher weight if there's an active blood cult and no living heretics currently
	for(var/datum/mind/heretic as anything in get_antag_minds(/datum/antagonist/heretic))
		if(!ishuman(heretic.current) || QDELING(heretic.current))
			continue
		var/turf/heretic_turf = get_turf(heretic.current)
		if(!is_centcom_level(heretic_turf?.z) && heretic.current.stat == CONSCIOUS)
			return .
	var/active_cultists = 0
	for(var/datum/mind/cultist as anything in get_antag_minds(/datum/antagonist/cult))
		var/mob/living/carbon/human/cultist_body = cultist.current
		if(!ishuman(cultist_body) || QDELING(cultist_body))
			continue
		if(cultist_body.stat != CONSCIOUS)
			continue
		if(cultist_body.reagents?.has_reagent(/datum/reagent/water/holywater)) // skip cultists being deconverted
			continue
		active_cultists++
	if(active_cultists >= 3)
		. *= 1.5

/datum/round_event_control/antagonist/heretic/roundstart
	name = "Heretics"
	roundstart = TRUE
	earliest_start = 0

/datum/round_event_control/antagonist/heretic/midround
	antag_flag = ROLE_FORBIDDENCALLING
	name = "Forbidden Calling (Heretics)"
	prompted_picking = TRUE
	max_occurrences = 1
	typepath = /datum/round_event/antagonist/heretic/midround

/datum/round_event/antagonist/heretic/start()
	. = ..()
	// go ahead and try to load the heretic sacrifice template after we make our heretics
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, lazy_load_template), LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE)

/datum/round_event/antagonist/heretic/midround/add_datum_to_mind(datum/mind/antag_mind)
	var/datum/antagonist/heretic/new_heretic = antag_mind.add_antag_datum(antag_datum)

	// Heretics passively gain influence over time.
	// As a consequence, latejoin heretics start out at a massive
	// disadvantage if the round's been going on for a while.
	// Let's give them some influence points when they arrive.
	new_heretic.adjust_knowledge_points(min(round(STATION_TIME_PASSED() / new_heretic.passive_gain_timer, 1), 4))

	return new_heretic
