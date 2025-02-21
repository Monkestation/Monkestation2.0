// Category

/datum/traitor_objective_category/propaganda_implant
	name = "Propaganda Implant"
	objectives = list(
		/datum/traitor_objective/propaganda_implant/common = 1,
		/datum/traitor_objective/propaganda_implant/authority = 1,
		/datum/traitor_objective/propaganda_implant/nt_rep = 0.25,
	)
	weight = OBJECTIVE_WEIGHT_UNLIKELY

// Objective

/datum/traitor_objective/propaganda_implant
	name = "Inject %TARGET% the %JOB TITLE% with a propaganda implant"
	description = "%TARGET% has been identified as a good target for spreading propaganda. You will be provided with a compacted propaganda implanter to inject them with. Due its reduced size it is unable to inject through thick clothing and takes 10 seconds to use. Additional implants can be purchased if desired."

	abstract_type = /datum/traitor_objective/propaganda_implant

	var/datum/mind/target_mind
	var/spawned_implanter = FALSE

	// The code below is for limiting how often you can get this objective. You will get this objective at a maximum of maximum_objectives_in_period every objective_period
	/// The objective period at which we consider if it is an 'objective'. Set to 0 to accept all objectives.
	var/objective_period = 20 MINUTES
	/// The maximum number of objectives that can be taken in this period.
	var/maximum_objectives_in_period = 2

	duplicate_type = /datum/traitor_objective/propaganda_implant

/datum/traitor_objective/propaganda_implant/proc/applicable_job(var/datum/job/job)
	return TRUE

/datum/traitor_objective/propaganda_implant/common
	progression_minimum = 0 MINUTES
	progression_maximum = 40 MINUTES
	progression_reward = list(3 MINUTES, 6 MINUTES)
	telecrystal_reward = list(0, 2)

/datum/traitor_objective/propaganda_implant/common/applicable_job(datum/job/job)
	return !(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)

/datum/traitor_objective/propaganda_implant/authority
	progression_minimum = 20 MINUTES
	progression_maximum = 80 MINUTES
	progression_reward = list(6 MINUTES, 12 MINUTES)
	telecrystal_reward = list(2, 4)

/datum/traitor_objective/propaganda_implant/authority/applicable_job(datum/job/job)
	return (job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND|DEPARTMENT_BITFLAG_SECURITY) && !istype(job, /datum/job/nanotrasen_representative)

/datum/traitor_objective/propaganda_implant/nt_rep
	progression_minimum = 20 MINUTES
	progression_maximum = INFINITY
	progression_reward = list(8 MINUTES, 16 MINUTES)
	telecrystal_reward = 4

/datum/traitor_objective/propaganda_implant/nt_rep/applicable_job(datum/job/job)
	return istype(job, /datum/job/nanotrasen_representative)

/datum/traitor_objective/propaganda_implant/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/propaganda_implant, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/propaganda_implant/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/already_targeting = list() //List of minds we're already targeting. The possible_duplicates is a list of objectives, so let's not mix things
	for(var/datum/objective/task as anything in handler.primary_objectives)
		if(!istype(task.target, /datum/mind))
			continue
		already_targeting += task.target //Removing primary objective kill targets from the list

	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	if(generating_for.late_joiner)
		try_target_late_joiners = TRUE

	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == generating_for)
			continue

		if(possible_target in already_targeting)
			continue

		if(!ishuman(possible_target.current))
			continue

		if(possible_target.current.stat == DEAD)
			continue

		if(possible_target.has_antag_datum(/datum/antagonist/traitor))
			continue

		if(!possible_target.assigned_role)
			continue

		if(!applicable_job(possible_target.assigned_role))
			continue

		if(HAS_TRAIT(possible_target.current, TRAIT_SPONSOR_IMPLANT_SYNDI))
			continue

		possible_targets += possible_target

	for(var/datum/traitor_objective/propaganda_implant/objective as anything in possible_duplicates)
		possible_targets -= objective.target_mind

	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/datum/mind/possible_target as anything in all_possible_targets)
			if(!possible_target.late_joiner)
				possible_targets -= possible_target

		if(!length(possible_targets))
			possible_targets = all_possible_targets

	if(!length(possible_targets))
		return FALSE //MISSION FAILED, WE'LL GET EM NEXT TIME

	target_mind = pick(possible_targets)
	var/mob/living/target = target_mind.current

	replace_in_name("%TARGET%", target_mind.name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	target.AddComponent(/datum/component/propaganda_target, src)
	AddComponent(/datum/component/traitor_objective_register, target, fail_signals = list(COMSIG_QDELETING))
	return TRUE

/datum/traitor_objective/propaganda_implant/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!spawned_implanter)
		buttons += add_ui_button("", "Pressing this will materialize a compacted propaganda implanter.", "syringe", "propaganda_implanter")
	return buttons

/datum/traitor_objective/propaganda_implant/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("propaganda_implanter")
			if(spawned_implanter)
				return
			spawned_implanter = TRUE
			var/obj/item/implanter/syndi_propaganda/objective/implanter = new(user.drop_location())
			user.put_in_hands(implanter)
			implanter.balloon_alert(user, "the implanter materializes in your hand")

// Target component

/datum/component/propaganda_target
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/datum/traitor_objective/objective

/datum/component/propaganda_target/Initialize(datum/traitor_objective/objective)
	. = ..()
	src.objective = objective

/datum/component/propaganda_target/proc/implanted()
	objective.succeed_objective()
	qdel(src)

// Implanter

/obj/item/implanter/syndi_propaganda/objective
	w_class = WEIGHT_CLASS_TINY

/obj/item/implanter/syndi_propaganda/objective/attack(mob/living/target, mob/user)
	if(!(istype(target) && user && imp))
		return

	if(!target.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return

	if(target != user)
		target.visible_message(span_warning("[user] is attempting to implant [target]."))
		if(!do_after(user, 10 SECONDS, target, extra_checks = CALLBACK(target, TYPE_PROC_REF(/mob/living, try_inject), user, null, INJECT_TRY_SHOW_ERROR_MESSAGE)))
			return

	if(!(src && imp))
		return

	if(imp.implant(target, user))
		if (target == user)
			to_chat(user, span_notice("You implant yourself."))
		else
			target.visible_message(span_notice("[user] implants [target]."), span_notice("[user] implants you."))
		imp = null
		update_appearance()
	else
		to_chat(user, span_warning("[src] fails to implant [target]."))
