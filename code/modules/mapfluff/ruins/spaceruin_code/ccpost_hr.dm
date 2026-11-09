// Central Command Liaison Outpost Human Resources. Requires ccpost_hr_dialogue.dm.

GLOBAL_DATUM(ccpost_hr_service, /datum/ccpost_hr_service)

// Editable HR representative directory. All correspondence resolves names from these values.
#define CCPOST_HR_NAME_C "Montgomery P. Ledger"
#define CCPOST_HR_TITLE_C "Deputy Director of Compensation & Benefits"
#define CCPOST_HR_NAME_G "Judith M. Redress"
#define CCPOST_HR_TITLE_G "Senior Employee Relations Adjudicator"
#define CCPOST_HR_NAME_W "Graham T. Fittings"
#define CCPOST_HR_TITLE_W "Workplace Standards & Compliance Officer"
#define CCPOST_HR_NAME_L "Penelope D. Brightwell"
#define CCPOST_HR_TITLE_L "Director of Personnel Welfare"

GLOBAL_LIST_EMPTY(ccpost_hr_delivery_markers)


#define CCPOST_HR_WAITING "awaiting"
#define CCPOST_HR_PENDING "pending"
#define CCPOST_HR_CLOSED "closed"

/datum/ccpost_hr_employee
	var/datum/mind/employee_mind
	var/datum/weakref/original_body
	var/employee_name
	var/employee_role
	var/employee_account_id
	var/list/credited_orders = list()
	var/qualifying_orders = 0
	var/promotion_tier = 0
	var/list/claimed_hr_outcomes = list()
	/// Personnel history survives fax replacement and is scoped to the registered mind.
	var/list/case_history = list()

/datum/ccpost_hr_employee/proc/is_deceased()
	// A disconnected or ghosted client is not automatically a dead character.
	var/mob/living/current_body = employee_mind?.current
	if(!istype(current_body))
		current_body = original_body?.resolve()
	if(!istype(current_body))
		return FALSE
	return current_body.stat == DEAD

/datum/ccpost_hr_case
	var/case_number
	var/owner_key
	var/datum/ccpost_hr_employee/owner
	var/datum/ccpost_hr_employee/target
	var/category
	var/scenario
	var/first_choice
	var/final_choice
	var/status = CCPOST_HR_PENDING
	var/pending_stage = "02"
	var/awaiting_stage
	var/response_token = 0
	var/last_delivered = 0
	var/compliance_form_type
	var/colleague_wait_since = 0
	var/replacement_count = 0
	var/next_replacement_allowed = 0
	/// Snapshot of the authoritative response form, not a second payable document.
	var/document_name
	var/document_body
	var/document_footer
	var/list/document_choices
	var/list/document_targets

/datum/ccpost_hr_service
	/// Keys are REF(mind), values are stable employee records.
	var/list/roster = list()
	/// Per-owner single active case. Entries removed when cases close.
	var/list/active = list()
	var/list/intake_cooldown = list()
	var/next_case_id = 0
	var/last_routine_number = 0
	var/notice_seq = 0
	var/list/queued_reward_cases = list()
	var/list/delivered_reward_cases = list()
	var/next_pod_dispatch = 0

/datum/ccpost_hr_service/New()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(routine_notice)), rand(15 MINUTES, 25 MINUTES))

/// Called only when a named outpost ID is equipped by its actual account holder.
/proc/ccpost_hr_register_employee(mob/living/carbon/human/user, obj/item/card/id/advanced/centcom/id_card)
	if(!istype(user) || !user.mind)
		return
	if(!istype(id_card))
		return
	var/role
	if(istype(id_card, /obj/item/card/id/advanced/centcom/ccpost_liaison))
		role = "Central Command Liaison"
	else if(istype(id_card, /obj/item/card/id/advanced/centcom/ccpost_security))
		role = "Outpost Security Officer"
	else
		return
	if(!id_card.registered_account || id_card.registered_name != user.real_name)
		return
	if(id_card.registered_account.account_id != user.account_id)
		return
	if(!GLOB.ccpost_hr_service)
		GLOB.ccpost_hr_service = new /datum/ccpost_hr_service
	GLOB.ccpost_hr_service.register_employee(user, role)

/datum/ccpost_hr_service/proc/register_employee(mob/living/carbon/human/user, role)
	var/key = REF(user.mind)
	var/datum/ccpost_hr_employee/existing = roster[key]
	if(existing)
		return existing
	var/role_count = 0
	for(var/other_key in roster)
		var/datum/ccpost_hr_employee/coworker = roster[other_key]
		if(coworker.employee_role == role)
			role_count++
	if((role == "Central Command Liaison" && role_count >= 2) || (role == "Outpost Security Officer" && role_count >= 1))
		return null
	var/datum/ccpost_hr_employee/record = new
	record.employee_mind = user.mind
	record.employee_name = user.real_name
	record.employee_role = role
	record.employee_account_id = user.account_id
	record.original_body = WEAKREF(user)
	roster[key] = record
	return record

/datum/ccpost_hr_service/proc/employee_for(mob/user)
	var/mob/living/carbon/human/human = user
	if(!istype(human) || !human.mind || human.stat == DEAD)
		return null
	var/datum/ccpost_hr_employee/record = roster[REF(human.mind)]
	if(!record || record.employee_mind != human.mind)
		return null
	if(record.employee_account_id != human.account_id)
		return null
	var/obj/item/card/id/advanced/centcom/id_card = human.wear_id?.GetID()
	if(!istype(id_card) || id_card.registered_name != record.employee_name)
		return null
	if(id_card.registered_account?.account_id != record.employee_account_id)
		return null
	if(record.employee_role == "Central Command Liaison")
		return istype(id_card, /obj/item/card/id/advanced/centcom/ccpost_liaison) ? record : null
	if(record.employee_role == "Outpost Security Officer")
		return istype(id_card, /obj/item/card/id/advanced/centcom/ccpost_security) ? record : null
	return null

/datum/ccpost_hr_service/proc/active_case_for(mob/user)
	var/datum/ccpost_hr_employee/employee = employee_for(user)
	if(!employee)
		return null
	return active[REF(employee.employee_mind)]

/datum/ccpost_hr_service/proc/ready_fax()
	for(var/obj/machinery/fax/ccpost_hr/fax as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/fax/ccpost_hr))
		if(fax.hr_ready() && world.time >= fax.hr_next_delivery)
			return fax
	return null

/datum/ccpost_hr_service/proc/representative(code)
	switch(copytext(code, 1, 2))
		if("C")
			return CCPOST_HR_NAME_C
		if("G")
			return CCPOST_HR_NAME_G
		if("W")
			return CCPOST_HR_NAME_W
		if("L")
			return CCPOST_HR_NAME_L
	return CCPOST_HR_NAME_G

/datum/ccpost_hr_service/proc/representative_title(code)
	switch(copytext(code, 1, 2))
		if("C")
			return CCPOST_HR_TITLE_C
		if("G")
			return CCPOST_HR_TITLE_G
		if("W")
			return CCPOST_HR_TITLE_W
		if("L")
			return CCPOST_HR_TITLE_L
	return "Human Resources Representative"

/datum/ccpost_hr_service/proc/format_body(content, datum/ccpost_hr_case/hr_case, list/variables)
	var/out = "[content]"
	if(hr_case)
		out = replacetext(out, "%EMPLOYEE%", html_encode(hr_case.owner.employee_name))
		out = replacetext(out, "%EMPLOYEE_ROLE%", html_encode(hr_case.owner.employee_role))
		if(hr_case.target)
			out = replacetext(out, "%TARGET%", html_encode(hr_case.target.employee_name))
			out = replacetext(out, "%TARGET_ROLE%", html_encode(hr_case.target.employee_role))
	if(variables)
		for(var/name in variables)
			out = replacetext(out, "%[name]%", "[variables[name]]")
	return out

// Use the shared Tasking Terminal typography and Nanotrasen insignia for every HR paper.
// This deliberately avoids custom HTML/CSS that PaperSheet's sanitizer strips.
/proc/ccpost_hr_document_header(document_title, reference, descriptor, recipient, position, sender, classification = "Internal Personnel Correspondence", subject = null)
	var/text = ccpost_paper_header()
	text += ccpost_paper_document_heading(document_title, reference, descriptor)
	text += ccpost_paper_value_field("To", recipient)
	if(position)
		text += ccpost_paper_value_field("Position", position)
	text += ccpost_paper_value_field("From", sender)
	text += ccpost_paper_value_field("Classification", classification)
	if(!isnull(subject))
		text += ccpost_paper_value_field("Subject", subject)
	text += ccpost_paper_value_field("Issued", station_time_timestamp())
	return text

/datum/ccpost_hr_service/proc/letter_envelope(datum/ccpost_hr_case/hr_case, subject, representative_name, representative_position, stage = "03")
	var/heading = "Human Resources Correspondence"
	switch(stage)
		if("02")
			switch(hr_case.category)
				if("C")
					heading = "Compensation Inquiry"
				if("G")
					heading = "Workplace Grievance Inquiry"
				if("W")
					heading = "Working Conditions Inquiry"
				if("L")
					heading = "Employee Welfare Inquiry"
		if("05")
			heading = "HR Case Resolution"
	var/reference = "HR-[hr_case.case_number] | FORM HR-[stage]"
	var/text = ccpost_hr_document_header(heading, reference, "Central Command Human Resources", hr_case.owner.employee_name, hr_case.owner.employee_role, "[representative_name], [representative_position]", "Internal Personnel Correspondence", subject)
	text += "<br><b>Dear [html_encode(hr_case.owner.employee_name)],</b><br><br>"
	return text

/datum/ccpost_hr_service/proc/letter_footer(representative_name)
	return "<br><hr><small>Kind regards,<br><i>[html_encode(representative_name)]</i><br><b>CENTRAL COMMAND | HUMAN RESOURCES DIVISION</b></small>"

/datum/ccpost_hr_service/proc/form_has_centcom_stamp(obj/item/paper/ccpost_hr/form)
	for(var/datum/paper_stamp/stamp as anything in form.raw_stamp_data)
		if(istext(stamp.class) && findtext(stamp.class, "stamp-centcom"))
			return TRUE
	return FALSE

/datum/ccpost_hr_service/proc/form_has_signature(obj/item/paper/ccpost_hr/form)
	for(var/datum/paper_field/field as anything in form.raw_field_input_data)
		if(field.is_signature && length(field.field_data?.raw_text))
			return TRUE
	return FALSE

/datum/ccpost_hr_service/proc/form_has_training_answers(obj/item/paper/ccpost_hr/form)
	var/answered = 0
	for(var/datum/paper_field/field as anything in form.raw_field_input_data)
		if(!field.is_signature && length(field.field_data?.raw_text))
			answered++
	return answered >= 3

/datum/ccpost_hr_service/proc/case_reward_type(node_id)
	switch(node_id)
		if("HR-005-C01-A1")
			return "one_credit"
		if("HR-005-W01-B1")
			return "stationery"
		if("HR-005-W01-C1")
			return "refreshments"
		if("HR-005-L02-C1")
			return "clown"
	return null

/datum/ccpost_hr_service/proc/queue_reward(case_number, reward_type)
	if(!reward_type || queued_reward_cases[case_number] || delivered_reward_cases[case_number])
		return
	queued_reward_cases[case_number] = reward_type
	addtimer(CALLBACK(src, PROC_REF(deliver_reward), case_number, 0), 3 SECONDS)

/datum/ccpost_hr_service/proc/is_safe_reward_turf(turf/location)
	if(!istype(location, /turf/open/floor) || location.density)
		return FALSE
	for(var/atom/movable/occupant in location)
		if(occupant.density || ismob(occupant))
			return FALSE
	return TRUE

/datum/ccpost_hr_service/proc/find_reward_landing()
	for(var/obj/effect/landmark/ccpost_hr_delivery/marker as anything in GLOB.ccpost_hr_delivery_markers)
		if(!QDELETED(marker) && is_safe_reward_turf(get_turf(marker)))
			return get_turf(marker)
	// Fallback for existing maps without a dedicated landing landmark.
	for(var/obj/machinery/fax/ccpost_hr/fax as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/fax/ccpost_hr))
		if(!fax.hr_ready())
			continue
		for(var/turf/open/floor/available in range(3, fax))
			if(get_area(available) == get_area(fax) && is_safe_reward_turf(available))
				return available
	return null

/datum/ccpost_hr_service/proc/deliver_reward(case_number, attempts)
	if(delivered_reward_cases[case_number])
		return
	var/reward_type = queued_reward_cases[case_number]
	if(!reward_type)
		return
	if(world.time < next_pod_dispatch)
		addtimer(CALLBACK(src, PROC_REF(deliver_reward), case_number, attempts), next_pod_dispatch - world.time)
		return
	var/turf/landing = find_reward_landing()
	if(!landing)
		if(attempts < 10)
			addtimer(CALLBACK(src, PROC_REF(deliver_reward), case_number, attempts + 1), 30 SECONDS)
		else
			stack_trace("CCPost HR reward HR-[case_number] could not find a safe landing location")
		return
	var/list/contents = list()
	switch(reward_type)
		if("one_credit")
			contents = list(/obj/item/stack/spacecash/c1)
		if("gold_medal")
			contents = list(/obj/item/clothing/accessory/medal/gold/ccpost_hr)
		if("stationery")
			contents = list(/obj/item/pen, /obj/item/paper, /obj/item/paper)
		if("refreshments")
			contents = list(/obj/item/reagent_containers/cup/glass/coffee)
		if("clown")
			contents = list(/mob/living/basic/clown/ccpost_hr_morale)
		else
			return
	var/obj/structure/closet/supplypod/centcompod/pod = new(null)
	for(var/path in contents)
		new path(pod)
	new /obj/effect/pod_landingzone(landing, pod)
	next_pod_dispatch = world.time + 5 SECONDS
	delivered_reward_cases[case_number] = TRUE
	queued_reward_cases -= case_number

/datum/ccpost_hr_service/proc/mark_case_closed(datum/ccpost_hr_case/hr_case, disposition = "Closed")
	if(!hr_case || hr_case.status == CCPOST_HR_CLOSED)
		return
	if(hr_case.owner)
		hr_case.owner.case_history.Insert(1, list(list(
			"reference" = "HR-[hr_case.case_number]",
			"category" = ccpost_hr_case_category_name(hr_case.category),
			"disposition" = disposition,
			"closed_at" = station_time_timestamp(),
		)))
		while(length(hr_case.owner.case_history) > 20)
			hr_case.owner.case_history.Cut(length(hr_case.owner.case_history), length(hr_case.owner.case_history) + 1)
	hr_case.status = CCPOST_HR_CLOSED
	active[hr_case.owner_key] = null
	intake_cooldown[hr_case.owner_key] = world.time + 2 MINUTES
	QDEL_IN(hr_case, 2 SECONDS)

/proc/ccpost_hr_case_category_name(category)
	switch(category)
		if("C")
			return "Compensation & Benefits"
		if("G")
			return "Employee Relations"
		if("W")
			return "Workplace Facilities"
		if("L")
			return "Personnel Welfare"
	return "Human Resources"

/// Personnel Records live on the central HR datum, never on a physical fax.
/// Do not expose another person's grievances to an outpost colleague or observer.
/datum/ccpost_hr_service/proc/personnel_record_data(mob/user)
	var/datum/ccpost_hr_employee/employee = employee_for(user)
	if(!employee)
		return null
	var/datum/ccpost_hr_case/hr_case = active[REF(employee.employee_mind)]
	var/paycheck = 0
	var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[employee.employee_account_id]"]
	if(account?.account_job)
		paycheck = account.account_job.paycheck
	var/next_pay_target = 0
	if(employee.employee_role == "Central Command Liaison")
		if(employee.qualifying_orders < 3)
			next_pay_target = 3
		else if(employee.qualifying_orders < 7)
			next_pay_target = 7
		else if(employee.qualifying_orders < 12)
			next_pay_target = 12
	var/list/awards = list()
	for(var/outcome in employee.claimed_hr_outcomes)
		if(employee.claimed_hr_outcomes[outcome])
			awards += "[outcome]"
	return list(
		"name" = employee.employee_name,
		"role" = employee.employee_role,
		"paycheck" = paycheck,
		"promotion_tier" = employee.promotion_tier,
		"qualifying_assignments" = employee.qualifying_orders,
		"next_pay_target" = next_pay_target,
		"awards" = awards,
		"history" = employee.case_history.Copy(),
		"active_case" = hr_case ? list(
			"reference" = "HR-[hr_case.case_number]",
			"category" = ccpost_hr_case_category_name(hr_case.category),
			"status" = hr_case.status == CCPOST_HR_WAITING ? "Awaiting employee response" : "Awaiting Central Command processing",
			"stage" = hr_case.status == CCPOST_HR_WAITING ? hr_case.awaiting_stage : hr_case.pending_stage,
			"can_replace" = hr_case.status == CCPOST_HR_WAITING && hr_case.document_name && hr_case.replacement_count < 3 && world.time >= hr_case.next_replacement_allowed,
			"replacements_remaining" = max(0, 3 - hr_case.replacement_count),
		) : null,
	)

/// Cache only the currently live HR response form. A replacement reissues the
/// identical choices and text with a new token, invalidating every earlier copy.
/datum/ccpost_hr_service/proc/remember_awaiting_form(datum/ccpost_hr_case/hr_case, obj/item/paper/ccpost_hr/form)
	if(!hr_case || !form)
		return
	hr_case.document_name = form.name
	hr_case.document_body = form.base_text
	hr_case.document_footer = form.footer_text
	hr_case.document_choices = form.choices.Copy()
	hr_case.document_targets = form.target_choices.Copy()
	hr_case.replacement_count = 0
	hr_case.next_replacement_allowed = 0

/datum/ccpost_hr_service/proc/reprint_awaiting_form(mob/user, obj/machinery/fax/ccpost_hr/fax)
	var/datum/ccpost_hr_case/hr_case = active_case_for(user)
	if(!hr_case || hr_case.status != CCPOST_HR_WAITING || !hr_case.document_name)
		return "No awaiting HR response form to replace."
	if(hr_case.replacement_count >= 3 || world.time < hr_case.next_replacement_allowed)
		return "Replacement limit or cooldown reached."
	if(!fax?.hr_ready() || world.time < fax.hr_next_delivery)
		return "Fax currently unavailable for replacement printing."
	var/obj/item/paper/ccpost_hr/replacement = new /obj/item/paper/ccpost_hr(fax)
	replacement.name = hr_case.document_name
	replacement.owner_key = hr_case.owner_key
	replacement.case_number = hr_case.case_number
	replacement.stage = hr_case.awaiting_stage
	replacement.response_token = ++hr_case.response_token
	replacement.choices = hr_case.document_choices?.Copy() || list()
	replacement.target_choices = hr_case.document_targets?.Copy() || list()
	replacement.base_text = hr_case.document_body
	replacement.footer_text = hr_case.document_footer
	replacement.refresh_printed_form()
	fax.receive(replacement, "Central Command Human Resources")
	fax.hr_next_delivery = world.time + 3 SECONDS
	hr_case.replacement_count++
	hr_case.next_replacement_allowed = world.time + 30 SECONDS
	hr_case.last_delivered = world.time
	addtimer(CALLBACK(src, PROC_REF(expire_if_idle), hr_case.owner_key, hr_case.case_number, replacement.response_token), 15 MINUTES)
	return "Replacement issued. Previous HR forms for this case are now void."


/datum/ccpost_hr_service/proc/submit(obj/item/paper/ccpost_hr/form, mob/user)
	var/datum/ccpost_hr_employee/employee = employee_for(user)
	if(!employee)
		to_chat(user, span_warning("HR ACCESS DENIED: No authenticated outpost employee identity found. Wear your assigned outpost ID."))
		return FALSE
	if(form.stage != "A01" && form.stage != "T01" && (!form.selected_option || !form.choices[form.selected_option]))
		to_chat(user, span_warning("FORM REJECTED: Select exactly one authorized answer on the paper first."))
		return FALSE
	var/key = REF(employee.employee_mind)
	var/datum/ccpost_hr_case/hr_case = active[key]
	if(form.stage == "01")
		// The printed identity must match the submitting employee, not just their role.
		if(form.owner_key != key)
			to_chat(user, span_warning("FORM OWNER MISMATCH: This intake was printed for another employee."))
			return FALSE
		if(hr_case)
			to_chat(user, span_warning("TRANSMISSION DECLINED: Your existing case HR-[hr_case.case_number] must be closed first."))
			return FALSE
		if(intake_cooldown[key] > world.time)
			to_chat(user, span_warning("REQUEST DEFERRED: Human Resources requires a brief recovery period between cases."))
			return FALSE
		if(!(form.selected_option in list("C", "G", "W", "L")))
			return FALSE
		hr_case = new /datum/ccpost_hr_case
		next_case_id++
		hr_case.case_number = "[1000 + next_case_id]"
		hr_case.owner_key = key
		hr_case.owner = employee
		hr_case.category = form.selected_option
		active[key] = hr_case
		schedule_reply(hr_case)
		to_chat(user, span_notice("HR-001 TRANSMITTED: Case HR-[hr_case.case_number] opened. Response time not disclosed."))
		return TRUE

	if(!hr_case || hr_case.owner != employee || form.owner_key != key || form.case_number != hr_case.case_number)
		to_chat(user, span_warning("CASE OWNER MISMATCH: This correspondence is not assigned to your active case."))
		return FALSE
	if(hr_case.status != CCPOST_HR_WAITING || form.stage != hr_case.awaiting_stage || form.response_token != hr_case.response_token)
		to_chat(user, span_warning("DOCUMENT OBSOLETE: This response was already processed or is no longer awaiting a reply."))
		return FALSE

	if(form.stage == "A01" || form.stage == "T01")
		if(form.stage == "T01" && !form_has_signature(form))
			to_chat(user, span_warning("FORM REJECTED: Sign the document using a pen (%s or %sign in the signature field)."))
			return FALSE
		if(!form_has_centcom_stamp(form))
			to_chat(user, span_warning("FORM REJECTED: An official CentCom rubber stamp is required."))
			return FALSE
		if(form.stage == "T01" && !form_has_training_answers(form))
			to_chat(user, span_warning("TRAINING INCOMPLETE: Answer all three questions before submission."))
			return FALSE
		hr_case.compliance_form_type = form.stage
		hr_case.pending_stage = "06"
	else if(form.stage == "02")
		if(!(form.selected_option in list("C01", "C02", "G01", "G02", "W01", "W02", "L01", "L02")))
			return FALSE
		if(copytext(form.selected_option, 1, 2) != hr_case.category)
			return FALSE
		if(hr_case.category == "G")
			if(!form.selected_target_key || !form.target_choices[form.selected_target_key])
				to_chat(user, span_warning("GRIEVANCE FORM INCOMPLETE: Select a named outpost colleague."))
				return FALSE
			var/datum/ccpost_hr_employee/target = roster[form.selected_target_key]
			var/mob/living/carbon/human/target_body = target?.employee_mind?.current
			if(!target || target == employee || !istype(target_body) || !target_body.client || target_body.stat == DEAD)
				to_chat(user, span_warning("GRIEVANCE INTAKE PAUSED: The reported employee is no longer available."))
				return FALSE
			hr_case.target = target
		hr_case.scenario = form.selected_option
		hr_case.pending_stage = "03"
	else if(form.stage == "03")
		if(!(form.selected_option in list("A", "B", "C")))
			return FALSE
		hr_case.first_choice = form.selected_option
		hr_case.pending_stage = "04"
	else if(form.stage == "04")
		if(!(form.selected_option in list("A1", "A2", "B1", "B2", "C1", "C2")))
			return FALSE
		if(copytext(form.selected_option, 1, 2) != hr_case.first_choice)
			return FALSE
		hr_case.final_choice = form.selected_option
		hr_case.pending_stage = "05"
	else
		return FALSE

	// Consume the stage token before any delayed work is started.
	hr_case.status = CCPOST_HR_PENDING
	hr_case.awaiting_stage = null
	hr_case.response_token++
	schedule_reply(hr_case)
	to_chat(user, span_notice("REPLY TRANSMITTED: Correspondence accepted for case HR-[hr_case.case_number]."))
	return TRUE

/datum/ccpost_hr_service/proc/schedule_reply(datum/ccpost_hr_case/hr_case)
	if(!hr_case || hr_case.status != CCPOST_HR_PENDING)
		return
	addtimer(CALLBACK(src, PROC_REF(deliver_reply), hr_case.owner_key, hr_case.case_number, hr_case.pending_stage), rand(2 MINUTES, 4 MINUTES))

/datum/ccpost_hr_service/proc/deliver_reply(owner_key, case_number, stage)
	var/datum/ccpost_hr_case/hr_case = active[owner_key]
	if(!hr_case || hr_case.case_number != case_number || hr_case.status != CCPOST_HR_PENDING || hr_case.pending_stage != stage)
		return
	var/obj/machinery/fax/ccpost_hr/fax = ready_fax()
	if(!fax)
		// Only retry while actually blocked by machine availability, not one timer per tick.
		addtimer(CALLBACK(src, PROC_REF(deliver_reply), owner_key, case_number, stage), 30 SECONDS)
		return

	// The grievance intake must have at least one identifiable colleague.
	// Do not print an unanswerable HR-002 while employees are still spawning.
	if(stage == "02" && hr_case.category == "G")
		var/known_coworkers = 0
		for(var/other_key in roster)
			var/datum/ccpost_hr_employee/other_employee = roster[other_key]
			var/mob/living/carbon/human/colleague = other_employee.employee_mind?.current
			if(other_employee != hr_case.owner && istype(colleague) && colleague.client && colleague.stat != DEAD)
				known_coworkers++
		if(!known_coworkers)
			if(!hr_case.colleague_wait_since)
				hr_case.colleague_wait_since = world.time
			if(world.time - hr_case.colleague_wait_since < 5 MINUTES)
				addtimer(CALLBACK(src, PROC_REF(deliver_reply), owner_key, case_number, stage), 30 SECONDS)
				return
			var/obj/item/paper/notice = new /obj/item/paper(fax)
			notice.name = "Central Command HR - HR-[case_number] - Staffing Resolution"
			var/notice_text = letter_envelope(hr_case, "Unable to Proceed with Colleague Grievance", representative("G"), representative_title("G"), "05")
			notice_text += "Human Resources cannot identify another registered outpost employee for the grievance review. Your filing has been closed without findings. This is not a determination that misconduct occurred or did not occur. You may initiate a new case once additional staff are present."
			notice_text += letter_footer(representative("G"))
			notice.add_raw_text(format_body(notice_text, hr_case))
			notice.update_appearance()
			fax.receive(notice, "Central Command Human Resources")
			fax.hr_next_delivery = world.time + 3 SECONDS
			mark_case_closed(hr_case, "Closed: no eligible colleague available")
			return

	// Death is checked against the actual registered body, not the connection state.
	if(hr_case.target?.is_deceased())
		var/obj/item/paper/special = new /obj/item/paper(fax)
		special.name = "Central Command HR - HR-[case_number] - Case Resolution"
		var/message = letter_envelope(hr_case, "Resolved Through Employee Attrition", representative("G"), representative_title("G"), "05")
		message += "We acknowledge your complaint concerning %TARGET%. Unfortunately, our personnel records indicate that the employee in question is currently deceased.\n\nWhile death does not automatically exempt employees from disciplinary proceedings, it significantly complicates the scheduling of performance evaluations. Human Resources therefore considers the alleged conduct unlikely to recur in the immediate future.\n\nYour complaint has been marked **RESOLVED THROUGH EMPLOYEE ATTRITION**.\n\nPlease refrain from interpreting this decision as an endorsement of lethal conflict resolution. Should %TARGET% return to active duty before a new complaint is filed, we trust you will allow them sufficient time to resume being objectionable."
		message += "\n\n*Employee turnover is not always voluntary.*"
		message += letter_footer(representative("G"))
		special.add_raw_text(format_body(message, hr_case))
		special.update_appearance()
		fax.receive(special, "Central Command Human Resources")
		fax.hr_next_delivery = world.time + 3 SECONDS
		mark_case_closed(hr_case)
		return

	if(stage == "A01" || stage == "T01")
		var/rep_name = representative(hr_case.category)
		var/obj/item/paper/ccpost_hr/compliance_form = new /obj/item/paper/ccpost_hr(fax)
		compliance_form.stage = stage
		compliance_form.case_number = hr_case.case_number
		compliance_form.owner_key = hr_case.owner_key
		compliance_form.response_token = ++hr_case.response_token
		compliance_form.name = "Central Command HR - HR-[case_number] - Form HR-[stage]"
		if(stage == "A01")
			compliance_form.base_text = ccpost_hr_document_header("Employee of the Day Medal Application", "HR-[case_number] | FORM HR-A01", "Employee Recognition Authorization", hr_case.owner.employee_name, hr_case.owner.employee_role, "[rep_name], [representative_title(hr_case.category)]", "Personnel Recognition", "Gold Medal of Adequacy")
			compliance_form.base_text += ccpost_paper_section("Recognition Declaration")
			compliance_form.base_text += "By entering my name, I acknowledge that this award carries no financial entitlement, no command authority, and no guarantee of continued recognition.<br><br>"
			compliance_form.base_text += ccpost_paper_blank_field("Employee Name")
		else
			compliance_form.base_text = ccpost_hr_document_header("Mandatory Workplace Re-Education", "HR-[case_number] | FORM HR-T01", "Unauthorized Procurement Corrective Training", hr_case.owner.employee_name, hr_case.owner.employee_role, "[rep_name], [representative_title(hr_case.category)]", "Internal Personnel Training", "Unauthorized Company Purchases")
			compliance_form.base_text += ccpost_paper_section("Knowledge Assessment")
			compliance_form.base_text += "1. Who should authorize expenditure for company equipment?<br>"
			compliance_form.base_text += ccpost_paper_blank_field("Answer 1")
			compliance_form.base_text += "<br>2. Is spending your own credits a substitute for an approved requisition?<br>"
			compliance_form.base_text += ccpost_paper_blank_field("Answer 2")
			compliance_form.base_text += "<br>3. How will you demonstrate future compliance with company purchasing policy?<br>"
			compliance_form.base_text += ccpost_paper_blank_field("Answer 3")
			compliance_form.base_text += ccpost_paper_section("Employee Declaration")
			compliance_form.base_text += ccpost_paper_blank_field("Employee Signature")
		compliance_form.footer_text = ccpost_paper_section("Authorization")
		if(stage == "A01")
			compliance_form.footer_text += "<small>Enter your employee name using a pen. Only an official CentCom rubber stamp is required for authorization.</small><br>"
		else
			compliance_form.footer_text += "<small>Answer all three questions and sign with a pen (%s or %sign). Apply a CentCom stamp before returning this form to the Outpost Administrative Fax.</small><br>"
		compliance_form.footer_text += letter_footer(rep_name)
		compliance_form.refresh_printed_form()
		remember_awaiting_form(hr_case, compliance_form)
		fax.receive(compliance_form, "Central Command Human Resources")
		fax.hr_next_delivery = world.time + 3 SECONDS
		hr_case.awaiting_stage = stage
		hr_case.last_delivered = world.time
		hr_case.status = CCPOST_HR_WAITING
		addtimer(CALLBACK(src, PROC_REF(expire_if_idle), owner_key, case_number, compliance_form.response_token), 15 MINUTES)
		return

	if(stage == "06")
		var/obj/item/paper/completion = new /obj/item/paper(fax)
		var/rep_name = representative(hr_case.category)
		var/notice_text
		if(hr_case.compliance_form_type == "A01")
			completion.name = "Central Command HR - HR-[case_number] - Medal Authorization"
			notice_text = ccpost_hr_document_header("Employee Recognition Authorization", "HR-[case_number] | FORM HR-A02", "Official Award Authorization", hr_case.owner.employee_name, hr_case.owner.employee_role, "[rep_name], [representative_title(hr_case.category)]", "Personnel Recognition", "Gold Medal of Adequacy")
			notice_text += "<br><b>Dear [html_encode(hr_case.owner.employee_name)],</b><br><br>Your stamped nomination has been accepted. Congratulations on achieving Employee of the Day status. A Gold Medal of Adequacy has been authorized for supply-pod delivery. The designation expires at the end of the current day; the medal remains company property."
			if(!hr_case.owner.claimed_hr_outcomes["medal"])
				hr_case.owner.claimed_hr_outcomes["medal"] = TRUE
				queue_reward(hr_case.case_number, "gold_medal")
			else
				notice_text += "<br><br>As you have already received this award this shift, no additional medal will be supplied."
		else if(hr_case.compliance_form_type == "T01")
			completion.name = "Central Command HR - HR-[case_number] - Training Completion"
			notice_text = ccpost_hr_document_header("Corrective Training Completion", "HR-[case_number] | FORM HR-T02", "Personnel Development Notice", hr_case.owner.employee_name, hr_case.owner.employee_role, "[rep_name], [representative_title(hr_case.category)]", "Internal Personnel Training", "Procurement Policy")
			notice_text += "<br><b>Dear [html_encode(hr_case.owner.employee_name)],</b><br><br>HR confirms receipt of your three responses, signature and official CentCom authorization. Your Mandatory Workplace Re-Education has been recorded as complete. Your procurement privileges have neither increased nor decreased; you simply possess slightly more paperwork than before."
			hr_case.owner.claimed_hr_outcomes["training"] = TRUE
		else
			qdel(completion)
			return
		notice_text += letter_footer(rep_name)
		completion.add_raw_text(notice_text)
		completion.update_appearance()
		fax.receive(completion, "Central Command Human Resources")
		fax.hr_next_delivery = world.time + 3 SECONDS
		mark_case_closed(hr_case)
		return

	var/node_id
	switch(stage)
		if("02")
			node_id = "HR-002-[hr_case.category]"
		if("03")
			node_id = "HR-003-[hr_case.scenario]"
		if("04")
			node_id = "HR-004-[hr_case.scenario]-[hr_case.first_choice]"
		if("05")
			node_id = "HR-005-[hr_case.scenario]-[hr_case.final_choice]"
	if(!node_id)
		return
	var/list/node = ccpost_hr_dialogue_node(node_id)
	if(!node)
		CRASH("Missing CCPost HR dialogue node: [node_id]")
	var/rep_code = hr_case.scenario || hr_case.category
	var/rep = representative(rep_code)
	var/text = letter_envelope(hr_case, node["title"], rep, representative_title(rep_code), stage)
	text += format_body(node["body"], hr_case)
	if(stage == "05")
		var/outcome_type = case_reward_type(node_id)
		var/repeat_outcome = outcome_type && hr_case.owner.claimed_hr_outcomes[outcome_type]
		var/needs_medal_application = node_id == "HR-005-C02-A2" && !hr_case.owner.claimed_hr_outcomes["medal"]
		var/needs_training = node_id == "HR-005-C02-B1" && !hr_case.owner.claimed_hr_outcomes["training"]
		if(node_id == "HR-005-G02-C1")
			if(hr_case.owner.employee_role == "Central Command Liaison" && hr_case.target?.employee_role == "Central Command Liaison")
				text += "\n\nTwo Liaisons do not become one another's commanding officer simply by arguing more convincingly."
			else if(hr_case.target?.employee_role == "Outpost Security Officer")
				text += "\n\nThe Security Officer may enforce legitimate visitor, access and protection requirements aboard this installation; these powers do not extend to general administrative command or command of station security."
			else if(hr_case.owner.employee_role == "Outpost Security Officer")
				text += "\n\nA Liaison may coordinate office work but cannot suspend an installation security order or command station personnel by virtue of a Central Command title."
		if(node_id == "HR-005-C01-A1")
			if(hr_case.owner.employee_role == "Central Command Liaison")
				text += "\n\nQualifying completed administrative assignments may trigger a separate pay progression. This correspondence cannot award a second increase."
			else
				text += "\n\nProtective and security duties are recognized under your current assignment, but no additional performance-pay tier is authorized through this correspondence."
		if(node_id == "HR-005-C01-B2")
			text += ccpost_paper_section("Compulsory Employee Recognition")
			text += ccpost_paper_value_field("Recognized Employee", hr_case.owner.employee_name)
			text += ccpost_paper_value_field("Honorary Designation", "Temporary Initiative Enthusiast")
			text += "<small>Certificate of mandatory recognition. Confers no privileges, authority, or compensation.</small><br>"
		if(repeat_outcome)
			text += "<br><br>Additional physical compensation under this programme is limited to one shipment per employee per shift. Your existing award satisfies this request."
		if(node_id == "HR-005-C02-A2" && !needs_medal_application)
			text += "<br><br>Your recognition application is already on file for this shift. No further medal application will be issued."
		if(node_id == "HR-005-C02-B1" && !needs_training)
			text += "<br><br>Your completed training record remains valid for this shift; no second corrective worksheet is required."
		text += letter_footer(rep)
		var/obj/item/paper/final_letter = new /obj/item/paper(fax)
		final_letter.name = "Central Command HR - HR-[case_number] - Final Resolution"
		final_letter.add_raw_text(text)
		final_letter.update_appearance()
		fax.receive(final_letter, "Central Command Human Resources")
		fax.hr_next_delivery = world.time + 3 SECONDS
		if(outcome_type && !repeat_outcome)
			hr_case.owner.claimed_hr_outcomes[outcome_type] = TRUE
			queue_reward(hr_case.case_number, outcome_type)
		if(needs_medal_application || needs_training)
			hr_case.pending_stage = needs_medal_application ? "A01" : "T01"
			hr_case.status = CCPOST_HR_PENDING
			addtimer(CALLBACK(src, PROC_REF(deliver_reply), owner_key, case_number, hr_case.pending_stage), 3 SECONDS)
		else
			mark_case_closed(hr_case)
		return

	var/obj/item/paper/ccpost_hr/form = new /obj/item/paper/ccpost_hr(fax)
	form.case_number = hr_case.case_number
	form.stage = stage
	form.response_token = ++hr_case.response_token
	form.choices = list()
	var/list/raw_choices = node["options"]
	for(var/answer_key in raw_choices)
		form.choices[answer_key] = format_body(raw_choices[answer_key], hr_case)
	form.owner_key = hr_case.owner_key
	form.name = "Central Command HR - HR-[case_number] - Form HR-[stage]"
	if(stage == "02" && hr_case.category == "G")
		form.target_choices = list()
		for(var/other_key in roster)
			var/datum/ccpost_hr_employee/other = roster[other_key]
			var/mob/living/carbon/human/other_body = other.employee_mind?.current
			if(other == hr_case.owner || !istype(other_body) || !other_body.client || other_body.stat == DEAD)
				continue
			form.target_choices[other_key] = "[html_encode(other.employee_name)], [other.employee_role]"
	form.base_text = text
	form.footer_text = "<br>Return this completed form using the Outpost Administrative Fax."
	form.footer_text += letter_footer(rep)
	form.refresh_printed_form()
	remember_awaiting_form(hr_case, form)
	fax.receive(form, "Central Command Human Resources")
	fax.hr_next_delivery = world.time + 3 SECONDS
	hr_case.awaiting_stage = stage
	hr_case.last_delivered = world.time
	hr_case.status = CCPOST_HR_WAITING
	addtimer(CALLBACK(src, PROC_REF(expire_if_idle), owner_key, case_number, form.response_token), 15 MINUTES)

/datum/ccpost_hr_service/proc/expire_if_idle(owner_key, case_number, token)
	var/datum/ccpost_hr_case/hr_case = active[owner_key]
	if(!hr_case || hr_case.case_number != case_number || hr_case.response_token != token)
		return
	if(hr_case.status != CCPOST_HR_WAITING || world.time < hr_case.last_delivered + 15 MINUTES)
		return
	if(!ready_fax())
		hr_case.last_delivered = world.time
		addtimer(CALLBACK(src, PROC_REF(expire_if_idle), owner_key, case_number, token), 15 MINUTES)
		return
	mark_case_closed(hr_case, "Expired: no response received")

/datum/ccpost_hr_service/proc/withdraw(mob/user)
	var/datum/ccpost_hr_case/hr_case = active_case_for(user)
	if(!hr_case)
		to_chat(user, span_warning("No active HR case found for your employee record."))
		return FALSE
	mark_case_closed(hr_case, "Withdrawn by employee")
	to_chat(user, span_notice("WITHDRAWAL ACCEPTED: Case HR-[hr_case.case_number] closed. Human Resources appreciates the reduction in its workload."))
	return TRUE

/datum/ccpost_hr_service/proc/routine_notice()
	var/someone_working = FALSE
	for(var/person_key in roster)
		var/datum/ccpost_hr_employee/person = roster[person_key]
		var/mob/living/body = person.employee_mind?.current
		if(istype(body) && body.client && body.stat != DEAD)
			someone_working = TRUE
			break
	if(someone_working)
		var/obj/machinery/fax/ccpost_hr/fax = ready_fax()
		if(fax)
			var/selection = rand(1, 24)
			if(selection == last_routine_number)
				selection = (selection % 24) + 1
			last_routine_number = selection
			var/notice_id = selection < 10 ? "R0[selection]" : "R[selection]"
			var/list/node = ccpost_hr_dialogue_node(notice_id)
			if(node)
				var/obj/item/paper/paper = new /obj/item/paper(fax)
				paper.name = "Central Command HR - Routine Notice [notice_id]"
				var/sender = representative(node["from"])
				var/message = ccpost_hr_document_header("Human Resources Staff Notice", notice_id, "Routine Administrative Notice", "All Central Command Liaison Outpost Personnel", "All Outpost Employees", sender, "Internal Personnel Correspondence", node["title"])
				// Compact heading for brief routine notices: avoid the <h4> block
				// margin and additional blank line between issued date and text.
				message += "<hr><b><u>ADMINISTRATIVE NOTICE</u></b><br>"
				message += "[node["body"]]"
				message += letter_footer(sender)
				paper.add_raw_text(message)
				paper.update_appearance()
				fax.receive(paper, "Central Command Human Resources")
				fax.hr_next_delivery = world.time + 3 SECONDS
	addtimer(CALLBACK(src, PROC_REF(routine_notice)), rand(15 MINUTES, 25 MINUTES))

/// Liaison-only actual pay progression, called after Tasking Terminal rewards are committed.
/proc/ccpost_hr_note_task_completion(mob/user, datum/ccpost_tasking_order/order)
	if(!GLOB.ccpost_hr_service || !order || !order.rewards_issued || order.audit_compliance_points > 0)
		return
	GLOB.ccpost_hr_service.note_task_completed(user, order)

/datum/ccpost_hr_service/proc/note_task_completed(mob/user, datum/ccpost_tasking_order/order)
	var/datum/ccpost_hr_employee/employee = employee_for(user)
	if(!employee || employee.employee_role != "Central Command Liaison")
		return
	if(employee.credited_orders[order.order_code])
		return
	employee.credited_orders[order.order_code] = TRUE
	employee.qualifying_orders++
	var/new_tier = 0
	if(employee.qualifying_orders >= 12)
		new_tier = 3
	else if(employee.qualifying_orders >= 7)
		new_tier = 2
	else if(employee.qualifying_orders >= 3)
		new_tier = 1
	if(new_tier <= employee.promotion_tier)
		return
	var/mob/living/carbon/human/human = user
	if(!istype(human))
		return
	var/datum/bank_account/ccpost_personnel/account = SSeconomy.bank_accounts_by_id["[human.account_id]"]
	if(!istype(account) || !account.account_job)
		return
	var/old_pay = account.account_job.paycheck
	var/new_pay = 50 + (25 * new_tier)
	if(new_pay <= old_pay)
		employee.promotion_tier = new_tier
		return
	account.account_job.paycheck = new_pay
	employee.promotion_tier = new_tier
	account.bank_card_talk("CENTCOM HR: Your authorized salary is now [new_pay] credits per pay cycle. Formal notice dispatched.")
	addtimer(CALLBACK(src, PROC_REF(deliver_promotion), REF(employee.employee_mind), new_tier, old_pay, new_pay, employee.qualifying_orders), rand(30 SECONDS, 90 SECONDS))

/datum/ccpost_hr_service/proc/deliver_promotion(employee_key, tier, old_pay, new_pay, assignments)
	var/datum/ccpost_hr_employee/employee = roster[employee_key]
	if(!employee)
		return
	var/obj/machinery/fax/ccpost_hr/fax = ready_fax()
	if(!fax)
		addtimer(CALLBACK(src, PROC_REF(deliver_promotion), employee_key, tier, old_pay, new_pay, assignments), 30 SECONDS)
		return
	var/list/node = ccpost_hr_dialogue_node("P0[tier]")
	if(!node)
		return
	notice_seq++
	var/list/replacements = list("ASSIGNMENTS" = assignments, "OLD_PAY" = old_pay, "NEW_PAY" = new_pay, "AWARD_ID" = notice_seq)
	var/notice = ccpost_hr_document_header("Performance Compensation Notice", "PROMOTION P0[tier]-[notice_seq]", "Official Personnel Adjustment", employee.employee_name, employee.employee_role, "[representative("C")], [representative_title("C")]", "Internal Personnel Correspondence", node["title"])
	notice += "<br><b>Dear [html_encode(employee.employee_name)],</b><br><br>"
	notice += format_body(node["body"], null, replacements)
	notice += letter_footer(representative("C"))
	var/obj/item/paper/paper = new /obj/item/paper(fax)
	paper.name = "Central Command HR - Performance Compensation Notice"
	paper.add_raw_text(notice)
	paper.update_appearance()
	fax.receive(paper, "Central Command Human Resources")
	fax.hr_next_delivery = world.time + 3 SECONDS

/obj/item/paper/ccpost_hr
	name = "Human Resources correspondence form"
	desc = "Official, individually addressed Central Command HR paperwork with checkboxes to mark on the sheet."
	var/stage = "01"
	var/case_number
	var/owner_key
	var/response_token = 0
	var/list/choices = list()
	var/list/target_choices = list()
	var/selected_option
	var/selected_target_key
	/// Main body and closing section are stored separately so checkboxes appear between them.
	var/base_text = ""
	var/footer_text = ""
	/// Forces PaperSheet preview to invalidate its renderer cache when the inked selection changes.
	var/hr_revision = 0

/// The first paper input is the printer-owned layout. Change only that input:
/// never clear the sheet when a checkbox changes, which would erase pen entries and stamps.
/obj/item/paper/ccpost_hr/proc/refresh_printed_form()
	var/rendered = base_text
	if(length(target_choices))
		rendered += ccpost_paper_section("Employee Concerned")
		rendered += "<small><i>Select one outpost colleague involved in your grievance.</i></small><br><br>"
		for(var/target_id in target_choices)
			var/target_mark = (target_id == selected_target_key) ? "&#9745;" : "&#9744;"
			rendered += "[target_mark] [html_encode(target_choices[target_id])]<br><br>"
	if(length(choices))
		var/choice_heading = "Response Selection"
		var/instructions = "Select one response below."
		if(stage == "01")
			choice_heading = "Nature of Correspondence"
			instructions = "Select one matter requiring the attention of Human Resources."
		else if(stage == "02" && length(target_choices))
			choice_heading = "Nature of Grievance"
			instructions = "Select one concern involving the employee identified above."
		rendered += ccpost_paper_section(choice_heading)
		rendered += "<small><i>[instructions]</i></small><br><br>"
		for(var/choice_id in choices)
			var/choice_mark = (choice_id == selected_option) ? "&#9745;" : "&#9744;"
			rendered += "<b>[choice_mark] [html_encode(choice_id)]</b> | [html_encode(choices[choice_id])]<br><br>"
	rendered += footer_text
	if(!length(raw_text_inputs))
		add_raw_text(rendered)
	else
		var/datum/paper_input/layout = raw_text_inputs[1]
		layout.raw_text = rendered
	hr_revision++
	update_static_data_for_all_viewers()
	update_appearance()

/// HR paperwork has its own paper UI but reuses native PaperSheet editing and stamping.
/obj/item/paper/ccpost_hr/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostHRPaper", name)
		ui.open()

/obj/item/paper/ccpost_hr/attack_self(mob/user)
	ui_interact(user)
	return TRUE

/obj/item/paper/ccpost_hr/ui_data(mob/user)
	var/list/data = ..()
	data["hr_revision"] = hr_revision
	data["hr_can_mark"] = can_mark(user)
	data["hr_selected_option"] = selected_option
	data["hr_selected_target_key"] = selected_target_key
	data["hr_choices"] = list()
	for(var/choice_id in choices)
		data["hr_choices"] += list(list("id" = choice_id, "label" = choices[choice_id]))
	data["hr_targets"] = list()
	for(var/target_id in target_choices)
		data["hr_targets"] += list(list("id" = target_id, "label" = target_choices[target_id]))
	return data

/obj/item/paper/ccpost_hr/proc/can_mark(mob/user)
	return user && user.stat == CONSCIOUS && !user.is_blind() && user.can_read(src) && user.is_holding(src)

/obj/item/paper/ccpost_hr/ui_act(action, params, datum/tgui/ui)
	if(action == "hr_mark_option" || action == "hr_mark_target")
		var/mob/user = ui.user
		if(!can_mark(user))
			return TRUE
		if(action == "hr_mark_option")
			var/answer_id = params["id"]
			if(!istext(answer_id) || isnull(choices[answer_id]))
				return TRUE
			selected_option = (selected_option == answer_id) ? null : answer_id
		else
			if(stage != "02" || !length(target_choices))
				return TRUE
			var/target_id = params["id"]
			if(!istext(target_id) || isnull(target_choices[target_id]))
				return TRUE
			selected_target_key = (selected_target_key == target_id) ? null : target_id
		refresh_printed_form()
		return TRUE
	return ..()

/obj/item/paper/ccpost_hr/examine(mob/user)
	. = ..()
	. += span_notice("Read this document to mark its checkboxes directly on the paper.")
	if(selected_option)
		. += span_notice("Marked response: [selected_option].")

/obj/machinery/fax/ccpost_hr
	name = "Outpost Administrative Fax"
	desc = "A standard network fax with a separately authorized Central Command Human Resources correspondence channel."
	fax_name = "Central Command Liaison Outpost Administrative Fax"
	var/next_intake_print = 0
	/// Serializes automated incoming documents rather than dropping them simultaneously.
	var/hr_next_delivery = 0

/obj/machinery/fax/ccpost_hr/Initialize(mapload)
	. = ..()
	if(!GLOB.ccpost_hr_service)
		GLOB.ccpost_hr_service = new /datum/ccpost_hr_service

/obj/machinery/fax/ccpost_hr/proc/hr_ready()
	return !QDELETED(src) && !(machine_stat & (NOPOWER | BROKEN)) && !jammed

/// Open the dedicated outpost interface. The normal fax subtype continues to use "Fax".
/obj/machinery/fax/ccpost_hr/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostHRFax")
		ui.open()

/obj/machinery/fax/ccpost_hr/ui_data(mob/user)
	var/list/data = ..()
	data["hr_has_case"] = !!GLOB.ccpost_hr_service?.active_case_for(user)
	data["hr_personnel_record"] = GLOB.ccpost_hr_service?.personnel_record_data(user)
	return data

/obj/machinery/fax/ccpost_hr/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action == "hr_replace_form")
		var/replacement_result = GLOB.ccpost_hr_service?.reprint_awaiting_form(usr, src)
		balloon_alert(usr, replacement_result || "HR service unavailable")
		SStgui.update_uis(src)
		return TRUE
	if(action == "hr_print_intake")
		if(!hr_ready() || world.time < hr_next_delivery || !GLOB.ccpost_hr_service?.employee_for(usr))
			balloon_alert(usr, "human resources ID or power unavailable")
			return TRUE
		if(world.time < next_intake_print)
			balloon_alert(usr, "printer cooling down")
			return TRUE
		next_intake_print = world.time + 30 SECONDS
		var/obj/item/paper/ccpost_hr/intake_form = new /obj/item/paper/ccpost_hr(src)
		intake_form.choices = list(
			"C" = "Compensation, salary or benefits",
			"G" = "Workplace grievance or colleague complaint",
			"W" = "Working conditions and office facilities",
			"L" = "Leave, personal welfare or employee wellbeing",
		)
		intake_form.name = "Central Command Human Resources - HR-001"
		var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service.employee_for(usr)
		intake_form.owner_key = REF(employee.employee_mind)
		intake_form.base_text = ccpost_hr_document_header("Human Resources Intake Form", "FORM HR-001", "Employee Correspondence Request", employee.employee_name, employee.employee_role, "Central Command Human Resources", "Internal Personnel Correspondence", "Employee Correspondence Request")
		intake_form.base_text += ccpost_paper_value_field("Case Reference", "Assigned upon submission")
		intake_form.base_text += ccpost_paper_section("Employee Information")
		intake_form.base_text += ccpost_paper_value_field("Name", employee.employee_name)
		intake_form.base_text += ccpost_paper_value_field("Position", employee.employee_role)
		intake_form.footer_text = ccpost_paper_section("Employee Declaration")
		intake_form.footer_text += "I understand that contacting Human Resources may result in additional paperwork, mandatory evaluations, and outcomes beyond my reasonable expectations.<br>"
		intake_form.footer_text += ccpost_paper_blank_field("Employee Signature")
		intake_form.footer_text += "<br><small><i>Official stamp: Optional. No stamp is required to submit this intake.</i></small><br>"
		intake_form.footer_text += ccpost_paper_note("CENTRAL COMMAND | HUMAN RESOURCES DIVISION. Your concerns matter to us. Their resolution is a separate matter.")
		intake_form.refresh_printed_form()
		receive(intake_form, "Central Command Human Resources")
		hr_next_delivery = world.time + 3 SECONDS
		return TRUE
	if(action == "hr_send")
		if(!hr_ready())
			balloon_alert(usr, "fax unavailable")
			return TRUE
		var/obj/item/paper/ccpost_hr/loaded_hr_form = loaded_item_ref?.resolve()
		if(!istype(loaded_hr_form))
			balloon_alert(usr, "official HR form required")
			return TRUE
		if(!GLOB.ccpost_hr_service.submit(loaded_hr_form, usr))
			return TRUE
		loaded_item_ref = null
		loaded_hr_form.forceMove(null)
		playsound(src, 'sound/machines/high_tech_confirm.ogg', 50, FALSE)
		history_add("Send", "Central Command Human Resources")
		QDEL_IN(loaded_hr_form, 2 SECONDS)
		update_appearance()
		return TRUE
	if(action == "hr_withdraw")
		if(!GLOB.ccpost_hr_service?.employee_for(usr))
			balloon_alert(usr, "identity not verified")
			return TRUE
		GLOB.ccpost_hr_service.withdraw(usr)
		return TRUE
	return ..()

/obj/effect/landmark/ccpost_hr_delivery
	name = "CCPost HR supply pod landing"
	icon_state = "x"

/obj/effect/landmark/ccpost_hr_delivery/Initialize(mapload)
	. = ..()
	GLOB.ccpost_hr_delivery_markers += src

/obj/effect/landmark/ccpost_hr_delivery/Destroy()
	GLOB.ccpost_hr_delivery_markers -= src
	return ..()

/obj/item/clothing/accessory/medal/gold/ccpost_hr
	name = "Gold Medal of Adequacy"
	desc = "A cheaply gold-plated medal awarded for satisfactory completion of an extraordinary amount of paperwork. It bears the inscription: 'Employee of the Day. Recognition expires at midnight. Medal remains company property.'"
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)

/datum/ai_controller/basic_controller/clown/ccpost_hr_morale
	planning_subtrees = list(/datum/ai_planning_subtree/random_speech/blackboard)

/mob/living/basic/clown/ccpost_hr_morale
	name = "Corporate Morale Clown"
	desc = "A harmless clown dispatched by Central Command Human Resources to provide mandatory entertainment. Its contract specifies honking but not competence."
	melee_damage_lower = 0
	melee_damage_upper = 0
	ai_controller = /datum/ai_controller/basic_controller/clown/ccpost_hr_morale
	loot = list()

/mob/living/basic/clown/ccpost_hr_morale/Initialize(mapload)
	. = ..()
	// Standard clowns register retaliation behavior; the HR visitor must never attack.
	qdel(GetComponent(/datum/component/ai_retaliate_advanced))

/mob/living/basic/clown/ccpost_hr_morale/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(old_loc && get_turf(old_loc) != get_turf(src) && isopenturf(loc))
		playsound(src, pick('sound/effects/footstep/clownstep1.ogg', 'sound/effects/footstep/clownstep2.ogg'), 50, TRUE)

#undef CCPOST_HR_NAME_C
#undef CCPOST_HR_TITLE_C
#undef CCPOST_HR_NAME_G
#undef CCPOST_HR_TITLE_G
#undef CCPOST_HR_NAME_W
#undef CCPOST_HR_TITLE_W
#undef CCPOST_HR_NAME_L
#undef CCPOST_HR_TITLE_L

#undef CCPOST_HR_WAITING
#undef CCPOST_HR_PENDING
#undef CCPOST_HR_CLOSED
