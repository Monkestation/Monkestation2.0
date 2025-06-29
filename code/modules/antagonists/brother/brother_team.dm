/datum/team/brother_team
	name = "\improper Blood Brothers"
	member_name = "blood brother"
	/// The color used for the Blood Bond communication.
	var/color
	/// If the BBs have summoned their gear already or not.
	var/summoned_gear = FALSE
	/// If the BBs are currently trying to select what gear to summon.
	var/choosing_gear = FALSE
	/// The gear the BBs chose.
	var/datum/bb_gear/chosen_gear
	/// The index of GLOB.color_list_blood_brothers to use to generate the color.
	var/static/next_color = 1

/datum/team/brother_team/add_member(datum/mind/new_member)
	. = ..()
	if (!new_member.has_antag_datum(/datum/antagonist/brother))
		add_brother(new_member.current)
	roll_for_color()

/datum/team/brother_team/remove_member(datum/mind/member)
	if (!(member in members))
		return
	. = ..()
	member.remove_antag_datum(/datum/antagonist/brother)
	if (!length(members))
		qdel(src)
		return
	if (isnull(member.current))
		return
	for (var/datum/mind/brother_mind as anything in members)
		to_chat(brother_mind, span_warning("[span_bold("[member.current.real_name]")] is no longer your brother!"))
	update_name()

/// Adds a new brother to the team
/datum/team/brother_team/proc/add_brother(mob/living/new_brother, source)
	if (isnull(new_brother) || isnull(new_brother.mind) || !GET_CLIENT(new_brother) || new_brother.mind.has_antag_datum(/datum/antagonist/brother))
		return FALSE
	new_brother.mind.add_antag_datum(/datum/antagonist/brother, src)
	return TRUE

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/team_minds as anything in members)
		var/list/split_name = splittext_char(team_minds.name, " ")
		last_names += split_name[length(split_name)]

	if (length(last_names) == 1)
		name = "[last_names[1]]'s Isolated Intifada"
	else
		name = "[initial(name)] of " + english_list(last_names)

/datum/team/brother_team/proc/notify_whos_who()
	for(var/datum/mind/member as anything in members)
		var/datum/antagonist/brother/blood_bond = member.has_antag_datum(/datum/antagonist/brother)
		to_chat(member.current, span_alertsyndie("Your fellow blood brother[length(members) > 2 ? "s are" : " is"] [blood_bond.get_brother_names(TRUE)]."), type = MESSAGE_TYPE_INFO)

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()

	var/is_hijacker = prob(10)
	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (length(members) > 2) - is_hijacker))
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new /datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new /datum/objective/escape)

	for(var/datum/mind/brother as anything in members)
		var/datum/antagonist/brother/blood_bond = brother.has_antag_datum(/datum/antagonist/brother)
		// stupid hack to ensure they all see their objectives
		addtimer(CALLBACK(blood_bond, TYPE_PROC_REF(/datum, update_static_data_for_all_viewers)), 0.5 SECONDS)

/datum/team/brother_team/proc/forge_single_objective()
	if(prob(50))
		if(LAZYLEN(active_ais()) && prob(100/length(GLOB.joined_player_list)))
			add_objective(new /datum/objective/destroy, needs_target = TRUE)
		else if(prob(30))
			add_objective(new /datum/objective/maroon, needs_target = TRUE)
		else
			add_objective(new /datum/objective/assassinate, needs_target = TRUE)
	else
		add_objective(new /datum/objective/steal, needs_target = TRUE)

/datum/team/brother_team/proc/roll_for_color()
	if(!isnull(color) || !length(members))
		return
	color = GLOB.color_list_blood_brothers[next_color]
	next_color = WRAP_UP(next_color, length(GLOB.color_list_blood_brothers))

/datum/team/brother_team/proc/update_action_icons()
	for(var/datum/mind/brother as anything in members)
		var/datum/antagonist/brother/blood_bond = brother.has_antag_datum(/datum/antagonist/brother)
		blood_bond?.comms_action?.build_all_button_icons()
		blood_bond?.gear_action?.build_all_button_icons()

/datum/team/brother_team/proc/summon_gear(mob/living/summoner)
	if(summoned_gear || choosing_gear || !chosen_gear || QDELETED(summoner) || !(summoner.mind in members))
		return FALSE
	summoned_gear = TRUE
	for(var/datum/mind/member as anything in members)
		var/datum/antagonist/brother/blood_bond = member.has_antag_datum(/datum/antagonist/brother)
		to_chat(member.current, span_notice("[summoner.mind.name || summoner.real_name] has summoned their gear, [chosen_gear.name], at [get_area(get_turf(summoner))]!"), type = MESSAGE_TYPE_INFO, avoid_highlighting = (member.current == summoner))
		if(!QDELETED(blood_bond?.gear_action))
			QDEL_NULL(blood_bond.gear_action)
	chosen_gear.summon(summoner, src)
	update_action_icons()
	return TRUE
