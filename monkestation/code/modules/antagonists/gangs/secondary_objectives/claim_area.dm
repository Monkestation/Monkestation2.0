/datum/traitor_objective_category/gang_claim_areas
	name = "Claim Areas(gang)"
	objectives = list(/datum/traitor_objective/gang/claim_areas = 1,
					/datum/traitor_objective/gang/claim_areas/high_risk_department = 1)

/datum/traitor_objective/gang/claim_areas
	name = "Disrupt the operations of %DEPARTMENT% by placing a T1de virus bug in %AREA%."
	description = "Use the button below to materialize the T1de virus bug within your hand, where you'll then be able to place it in %AREA%. \
				   One minute after the bug is placed it will randomly open, bolt, and or electrify all airlocks in the department, \
				   if the bug is destroyed before this, the objective will fail."
	progression_minimum = 10 MINUTES
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(4, 5)

	///What departments can we pick from mapped to their base area type
	var/list/valid_departments = list(/datum/job_department/cargo = /area/station/cargo,
									/datum/job_department/medical = /area/station/medical,
									/datum/job_department/science = /area/station/science,
									/datum/job_department/engineering = /area/station/engineering) //service is too low security for them to be worth anything(sorry clown)
	///The department chosen for this objective to target
	var/datum/job_department/targeted_department
	var/list/possible_areas = list()
	var/list/valid_areas
	var/needed_area_count = 3
	///Does an area need its exact type in possible_areas
	var/needs_exact_type = FALSE
	///The area chosen for this objective to target
	var/area/targeted_area
	///Have we sent them the bug yet
	var/bug_sent = FALSE
	///The areas affected by this bug
	var/list/affected_areas

//ASSOC FOR DEPART NAMES?

/datum/traitor_objective/gang/claim_areas/high_risk_department
	progression_minimum = 10 MINUTES
	progression_reward = list(15 MINUTES, 20 MINUTES)
	telecrystal_reward = list(3, 4)
	valid_departments = list(/datum/job_department/command = /area/station/command,
							/datum/job_department/security = /area/station/security)

/datum/traitor_objective/gang/claim_areas/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(length(possible_duplicates))
		return FALSE
	return TRUE

/datum/traitor_objective/gang/claim_areas/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	valid_areas = typecacheof(possible_areas, needs_exact_type)
	var/datum/job/role = generating_for.assigned_role
	for(var/datum/traitor_objective/gang/claim_areas/objective as anything in possible_duplicates)
		valid_departments -= objective.targeted_department
	for(var/datum/job_department/department as anything in role.departments_list) //breaking into your own department should not be an objective
		valid_departments -= department

	if(!length(valid_departments))
		return FALSE

	targeted_department = SSjob.joinable_departments_by_type[pick(valid_departments)]

	var/list/valid_areas = typecacheof(valid_departments[targeted_department.type])
	var/list/blacklisted_areas = typecacheof(TRAITOR_OBJECTIVE_BLACKLISTED_AREAS + /area/station/security/checkpoint) //sec checkpoint is fine for weakpoints but not tide bugs
	affected_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in affected_areas)
		if(is_type_in_typecache(possible_area, blacklisted_areas) || !is_type_in_typecache(possible_area, valid_areas) || initial(possible_area.outdoors))
			affected_areas -= possible_area

	if(!length(affected_areas))
		return FALSE

	targeted_area = pick(affected_areas)

	replace_in_name("%DEPARTMENT%", targeted_department.department_name)
	replace_in_name("%AREA%", initial(targeted_area.name))
	return TRUE

/datum/traitor_objective/gang/claim_areas/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!bug_sent)
		buttons += add_ui_button("", "Pressing this will materialize a T1de virus bug in your hand.", "globe", "bug")
	return buttons

/datum/traitor_objective/gang/claim_areas/ui_perform_action(mob/user, action)
	. = ..()
	if(action == "bug")
		if(bug_sent)
			return
		bug_sent = TRUE
		var/obj/item/traitor_bug/bug = new(user.drop_location(), src)
		user.put_in_hands(bug)
		bug.balloon_alert(user, "The Tide virus bug materializes in your hand.")
		AddComponent(/datum/component/traitor_objective_register, bug, \
				succeed_signals = list(COMSIG_TRAITOR_BUG_ACTIVATED), \
				fail_signals = list(COMSIG_QDELETING), \
				penalty = telecrystal_penalty)
		bug.objective_weakref = WEAKREF(src)

/datum/traitor_objective/gang/claim_areas/department

