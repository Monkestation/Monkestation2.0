/// Central Command Liaison Outpost tasking system.

#define CCPOST_TASK_STATUS_PENDING "Pending"
#define CCPOST_TASK_STATUS_ACKNOWLEDGED "Acknowledged"
#define CCPOST_TASK_STATUS_COMPLETED "Completed"

#define CCPOST_TASK_PRIORITY_ROUTINE "Routine"
#define CCPOST_TASK_PRIORITY_ELEVATED "Elevated"
#define CCPOST_TASK_PRIORITY_PRIORITY "Priority"
#define CCPOST_TASK_PRIORITY_CRITICAL "Critical"

#define CCPOST_AUDIT_MINOR "MINOR"
#define CCPOST_AUDIT_SIGNIFICANT "SIGNIFICANT"
#define CCPOST_AUDIT_SEVERE "SEVERE"

#define CCPOST_TASK_AUDIT_TEMPLATE_ID "outpost_audit"

// Central Command task templates

/datum/ccpost_task_template
	var/template_id
	var/category
	var/subject
	var/priority = CCPOST_TASK_PRIORITY_ROUTINE
	var/instruction
	var/department_reward_id

/datum/ccpost_task_template/proc/configure_order(datum/ccpost_tasking_order/order, datum/ccpost_logistics_network/logistics_network)
	return

/datum/ccpost_task_template/command_status
	template_id = "command_status"
	category = "Command Oversight"
	subject = "General Operational Status"
	instruction = "Contact station Command and request a general operational status report. Identify any unresolved matters which may warrant continued Central Command observation."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_coordination
	template_id = "command_coordination"
	category = "Command Oversight"
	subject = "Departmental Coordination Review"
	instruction = "Assess whether station Command is maintaining effective communication and coordination between departments. Document any significant breakdowns in the chain of communication."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_concern
	template_id = "command_concern"
	category = "Command Oversight"
	subject = "Command Concern Inquiry"
	instruction = "Request that station Command identify its most significant current operational concern. Verify the matter where practical and record your assessment."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/security_arrests
	template_id = "security_arrests"
	category = "Security Oversight"
	subject = "Arrest Procedure Review"
	instruction = "Review Security's handling of recent arrests and determine whether appropriate procedure appears to be followed. Distinguish confirmed information from allegation or speculation."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/security_investigations
	template_id = "security_investigations"
	category = "Security Oversight"
	subject = "Unresolved Investigation Review"
	instruction = "Contact Security and request an overview of any unresolved high-priority investigations. Determine whether any require additional Central Command monitoring."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/engineering_status
	template_id = "engineering_status"
	category = "Infrastructure Oversight"
	subject = "Engineering Status Assessment"
	instruction = "Contact Engineering and request an assessment of current station infrastructure, including any significant power, atmospheric, structural, or telecommunications concerns."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/engineering_sustainability
	template_id = "engineering_sustainability"
	category = "Infrastructure Oversight"
	subject = "Continued Operations Assessment"
	instruction = "Request an assessment from Engineering regarding the station's ability to sustain continued operations. Record any systems identified as vulnerable or degraded."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/communications
	template_id = "communications"
	category = "Communications Oversight"
	subject = "Communications Integrity Review"
	instruction = "Review recent station communications for conflicting, incomplete, or unverifiable information. Request clarification from relevant personnel where necessary."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/communications_outage
	template_id = "communications_outage"
	category = "Communications Oversight"
	subject = "Communications Reliability Inquiry"
	instruction = "Determine whether the station has experienced any significant communications outages or disruptions. Establish their likely cause and operational impact."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/medical_status
	template_id = "medical_status"
	category = "Medical Oversight"
	subject = "Personnel Condition Report"
	instruction = "Request a personnel and casualty status report from Medical. Identify any unusual casualty trends or incidents requiring further review."
	department_reward_id = ACCOUNT_MED

/datum/ccpost_task_template/casualty_review
	template_id = "casualty_review"
	category = "Medical Oversight"
	subject = "Casualty Review"
	instruction = "Determine whether any recent casualties warrant further Central Command review. Establish whether hostile action, negligence, or routine operational hazards were involved."
	department_reward_id = ACCOUNT_MED

/datum/ccpost_task_template/explosions
	template_id = "explosions"
	category = "Incident Review"
	subject = "Explosive Incident Inquiry"
	instruction = "Request clarification regarding any significant explosions reported aboard the station. Determine their approximate cause, location, and effect on station operations."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/sabotage_review
	template_id = "sabotage_review"
	category = "Incident Review"
	subject = "Sabotage Assessment"
	instruction = "Review recent significant incidents and assess whether available evidence better supports deliberate sabotage, negligence, equipment failure, or routine operational error."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/department_status
	template_id = "department_status"
	category = "Operational Oversight"
	subject = "Department Readiness Review"
	instruction = "Determine whether any station department is operating below acceptable staffing or operational levels. Document any significant deficiencies."

/datum/ccpost_task_template/emergency_readiness
	template_id = "emergency_readiness"
	category = "Operational Oversight"
	subject = "Emergency Preparedness Review"
	instruction = "Assess the station's present emergency preparedness. Identify any obvious deficiencies in coordination, staffing, equipment, or response capability."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/conflicting_accounts
	template_id = "conflicting_accounts"
	category = "Administrative Oversight"
	subject = "Report Consistency Review"
	instruction = "Review available departmental accounts of recent noteworthy incidents. Identify significant contradictions and request clarification where appropriate."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/monitoring_assessment
	template_id = "monitoring_assessment"
	category = "Administrative Oversight"
	subject = "Monitoring Requirement Assessment"
	instruction = "Determine whether current station conditions justify increased Central Command monitoring. Record the factors supporting your conclusion."

/datum/ccpost_task_template/outpost_audit
	template_id = CCPOST_TASK_AUDIT_TEMPLATE_ID
	category = "Internal Compliance"
	subject = "Liaison Outpost Compliance Audit"
	instruction = "Central Command Internal Compliance has selected this installation for a routine audit. Review the outpost's Operational Allocation ledger, freight requisition history, recent Sector Communications responses, and completed tasking records. Submit a concise account of any discrepancies, unexplained expenditures, missing documentation, or procedural violations."

/datum/ccpost_task_template/developing_situation
	template_id = "developing_situation"
	category = "General Oversight"
	subject = "Developing Situation Review"
	instruction = "Identify any developing situation aboard the station which may require future Central Command attention. Verify available information and document your findings."

/datum/ccpost_task_template/outpost_audit/configure_order(datum/ccpost_tasking_order/order, datum/ccpost_logistics_network/logistics_network)
	if(!order || !logistics_network)
		return

	var/new_restricted_requisitions = max(0, logistics_network.contraband_requisition_count - logistics_network.contraband_requisitions_at_last_audit)
	var/new_compliance_points = max(0, logistics_network.contraband_compliance_points - logistics_network.contraband_points_at_last_audit)

	if(new_restricted_requisitions <= 0)
		return

	var/requisition_label = new_restricted_requisitions == 1 ? "requisition" : "requisitions"
	var/audit_severity = CCPOST_AUDIT_MINOR
	var/audit_priority = CCPOST_TASK_PRIORITY_ELEVATED

	if(new_compliance_points >= 6)
		audit_severity = CCPOST_AUDIT_SEVERE
		audit_priority = CCPOST_TASK_PRIORITY_CRITICAL
	else if(new_compliance_points >= 3)
		audit_severity = CCPOST_AUDIT_SIGNIFICANT
		audit_priority = CCPOST_TASK_PRIORITY_PRIORITY

	order.priority = audit_priority
	order.subject = "Procurement Compliance Audit"
	order.audit_requisition_count = new_restricted_requisitions
	order.audit_compliance_points = new_compliance_points
	order.audit_severity = audit_severity
	order.instruction = "Central Command Internal Compliance has identified [new_restricted_requisitions] new restricted procurement [requisition_label] associated with this installation since its last review. Preliminary classification: [audit_severity]. Conduct an immediate audit of the Logistics Terminal and Operational Allocation ledger. Account for each restricted order, identify the requesting personnel and operational justification where available, verify the remaining allocation, and document any discrepancies or unauthorized material still held aboard the outpost. Be advised that confirmed violations may result in recovery assessments, withheld task compensation, and temporary suspension of restricted procurement privileges."

	logistics_network.contraband_requisitions_at_last_audit = logistics_network.contraband_requisition_count
	logistics_network.contraband_points_at_last_audit = logistics_network.contraband_compliance_points
	logistics_network.contraband_audit_pending = FALSE


// CENTRAL COMMAND PRINTED TASKING ORDER

/// Printed Central Command tasking orders cannot be used as
/// supporting completion reports.

/obj/item/paper/ccpost_tasking_order
	name = "Central Command Tasking Order"
	desc = "An official Central Command tasking order. The order itself is not accepted as supporting completion documentation."

// Central Command Tasking System

/datum/ccpost_tasking_order
	var/order_code
	var/template_id
	var/category
	var/subject
	var/priority
	var/instruction

	/// Optional station department which receives a Central Command
	/// budget grant when this task is successfully completed.
	var/department_reward_id

	/// Prevents task rewards from ever being issued more than once.
	var/rewards_issued = FALSE

	/// Restricted procurement activity captured by a compliance audit.
	/// Zero means this is a routine audit rather than a contraband-triggered one.
	var/audit_requisition_count = 0
	var/audit_compliance_points = 0
	var/audit_severity

	var/status = CCPOST_TASK_STATUS_PENDING

	var/issued_at
	var/acknowledged_by
	var/acknowledged_at
	var/completed_by
	var/completed_at


/datum/ccpost_tasking_order/New(_order_code, datum/ccpost_task_template/template)
	. = ..()

	order_code = _order_code
	template_id = template.template_id
	category = template.category
	subject = template.subject
	priority = template.priority
	instruction = template.instruction
	department_reward_id = template.department_reward_id
	issued_at = station_time_timestamp()


/// Returns the Operational Allocation reward for this task.
///
/// Task value is determined by its priority rather than being configured
/// individually on every assignment template.
/datum/ccpost_tasking_order/proc/get_allocation_reward()
	switch(priority)
		if(CCPOST_TASK_PRIORITY_ROUTINE)
			return 5

		if(CCPOST_TASK_PRIORITY_ELEVATED)
			return 7

		if(CCPOST_TASK_PRIORITY_PRIORITY)
			return 10

		if(CCPOST_TASK_PRIORITY_CRITICAL)
			return 15

	return 5


/// Returns the station departmental budget grant for this task.
///
/// The amount is based on task priority. The assignment template decides
/// which department, if any, receives it.
/datum/ccpost_tasking_order/proc/get_department_reward()
	switch(priority)
		if(CCPOST_TASK_PRIORITY_ROUTINE)
			return 500

		if(CCPOST_TASK_PRIORITY_ELEVATED)
			return 750

		if(CCPOST_TASK_PRIORITY_PRIORITY)
			return 1000

		if(CCPOST_TASK_PRIORITY_CRITICAL)
			return 1500

	return 500

// Central Command Tasking Computer Circuit Board

/obj/item/circuitboard/computer/ccpost_tasking
	name = "Central Command Tasking Terminal"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/ccpost_tasking

	/// Current assignment stored by this board.
	var/datum/ccpost_tasking_order/current_order

	/// Completed previous assignments.
	var/list/order_history = list()

	/// Incrementing number used when generating new tasking orders.
	var/next_order_number = 1

	/// Prevents the same assignment template immediately repeating.
	var/last_template_type

/obj/item/circuitboard/computer/ccpost_tasking/Destroy()
	QDEL_NULL(current_order)
	QDEL_LIST(order_history)

	return ..()

// Central Command Tasking Computer

/obj/machinery/computer/ccpost_tasking
	name = "Central Command tasking terminal"
	desc = "A secure Central Command terminal used to receive, acknowledge, archive, and print administrative tasking orders."

	icon_screen = "comm"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_BLUEGREEN

	circuit = /obj/item/circuitboard/computer/ccpost_tasking

	/// Current automatic assignment timer.
	var/assignment_timer

	/// Physical report currently inserted for task completion.
	var/obj/item/paper/submitted_report

	/// Prevents repeated manual printing.
	COOLDOWN_DECLARE(print_cooldown)

	/// Pool of Central Command assignments.
	/// Available task template types. Concrete content lives on template datums.
	var/static/list/assignment_template_types = subtypesof(/datum/ccpost_task_template)

// COMPLETION REPORT INSERTION

/obj/machinery/computer/ccpost_tasking/item_interaction(
	mob/living/user,
	obj/item/tool,
	list/modifiers
)
	if(!istype(tool, /obj/item/paper))
		return NONE

	var/obj/item/paper/report = tool

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board?.current_order)
		balloon_alert(user, "no active tasking order")
		return ITEM_INTERACT_BLOCKING

	if(tasking_board.current_order.status == CCPOST_TASK_STATUS_PENDING)
		balloon_alert(user, "acknowledge order first")
		return ITEM_INTERACT_BLOCKING

	if(tasking_board.current_order.status == CCPOST_TASK_STATUS_COMPLETED)
		balloon_alert(user, "order already completed")
		return ITEM_INTERACT_BLOCKING

	if(istype(report, /obj/item/paper/ccpost_tasking_order))
		balloon_alert(user, "tasking order is not evidence")
		return ITEM_INTERACT_BLOCKING

	if(submitted_report)
		balloon_alert(user, "report slot occupied")
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(report, src))
		balloon_alert(user, "unable to insert report")
		return ITEM_INTERACT_BLOCKING

	submitted_report = report

	playsound(
		src,
		'sound/machines/terminal_alert.ogg',
		vol = 20,
		vary = TRUE
	)

	balloon_alert(user, "report inserted")

	SStgui.update_uis(src)

	return ITEM_INTERACT_SUCCESS

// Initialization

/obj/machinery/computer/ccpost_tasking/Initialize(mapload)
	. = ..()

	// Allow the round to establish itself before the first assignment is issued.
	schedule_next_assignment()

/obj/machinery/computer/ccpost_tasking/Destroy()
	if(assignment_timer)
		deltimer(assignment_timer)
		assignment_timer = null

	// Never destroy an inserted report when the machine is dismantled.
	if(submitted_report)
		submitted_report.forceMove(drop_location())
		submitted_report = null

	// Do NOT delete the current order or history here.
	// Those belong to the circuit board and survive deconstruction.

	return ..()

// TASK COMPLETION REWARDS

/obj/machinery/computer/ccpost_tasking/proc/apply_task_rewards(
	datum/ccpost_tasking_order/order,
	mob/completing_user
)
	if(!order)
		return

	// Absolute safeguard against duplicate payouts.
	if(order.rewards_issued)
		return

	order.rewards_issued = TRUE

	var/reward_actor = "CENTRAL COMMAND TASKING"

	if(completing_user)
		reward_actor = completing_user.name

	// Contraband-triggered compliance audits do not award normal tasking
	// compensation. Instead, Internal Compliance issues a finding and applies
	// the appropriate administrative recovery assessment.
	if(order.template_id == CCPOST_TASK_AUDIT_TEMPLATE_ID && order.audit_compliance_points > 0)
		apply_procurement_audit_finding(order, completing_user)
		return

	// --------------------------------------------------------
	// LIAISON OUTPOST OPERATIONAL ALLOCATION
	// --------------------------------------------------------

	var/allocation_reward = order.get_allocation_reward()

	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network

	if(logistics_network && allocation_reward > 0)
		var/credited_allocation = logistics_network.credit_allocation(
			allocation_reward,
			"Completed tasking order [order.order_code]: [order.subject]",
			reward_actor
		)

		if(credited_allocation > 0)
			logistics_network.refresh_registered_terminals()

			say(
				"Tasking compensation authorized. [credited_allocation] CU has been credited to this installation's Operational Allocation."
			)

		else
			say(
				"Tasking compensation processed. Operational Allocation is already at maximum capacity."
			)

	// --------------------------------------------------------
	// STATION DEPARTMENTAL BUDGET GRANT
	// --------------------------------------------------------

	if(!order.department_reward_id)
		return

	var/department_reward = order.get_department_reward()

	if(department_reward <= 0)
		return

	var/datum/bank_account/department/department_account = SSeconomy.get_dep_account(
		order.department_reward_id
	)

	if(!department_account)
		say(
			"Tasking grant processing failed. Unable to contact the designated departmental account."
		)

		return

	// The station economy datum names ACCOUNT_SEC the Defense Budget.
	// Keep the underlying account untouched, but present it as Security here.
	var/department_display_name = department_account.account_holder
	if(order.department_reward_id == ACCOUNT_SEC)
		department_display_name = "Security Budget"

	var/grant_reason = "Central Command Tasking Grant: [order.order_code] - [order.subject]"

	if(!department_account.adjust_money(
		department_reward,
		grant_reason
	))
		say(
			"Tasking grant processing failed for [department_display_name]."
		)

		return

	say(
		"Central Command has authorized a [department_reward] credit grant to [department_display_name]."
	)

/// Applies the consequences of a contraband-triggered procurement audit.
/// Returns without action for routine audits.
/obj/machinery/computer/ccpost_tasking/proc/apply_procurement_audit_finding(
	datum/ccpost_tasking_order/order,
	mob/completing_user
)
	if(!order || order.audit_compliance_points <= 0)
		return

	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network

	if(!logistics_network)
		say("Internal Compliance finding could not be applied. Logistics network unavailable.")
		return

	var/severity = order.audit_severity
	var/assessment = 3
	var/suspension_duration = 2 MINUTES

	switch(severity)
		if(CCPOST_AUDIT_SIGNIFICANT)
			assessment = 8
			suspension_duration = 5 MINUTES

		if(CCPOST_AUDIT_SEVERE)
			assessment = 15
			suspension_duration = 10 MINUTES

		else
			severity = CCPOST_AUDIT_MINOR

	var/available_allocation = logistics_network.get_available_allocation()
	var/charged_amount = min(assessment, available_allocation)

	if(charged_amount > 0)
		logistics_network.spend_allocation(
			charged_amount,
			"Internal Compliance recovery assessment - [severity] procurement finding ([order.order_code])",
			"CENTRAL COMMAND INTERNAL COMPLIANCE"
		)

	var/uncollected_amount = assessment - charged_amount

	// A compliance hold only blocks Restricted procurement. Routine operational
	// requisitions remain available so the outpost can continue functioning.
	if(uncollected_amount > 0)
		suspension_duration += 5 MINUTES

	logistics_network.suspend_restricted_procurement(suspension_duration)
	logistics_network.refresh_logistics_outputs()

	var/completing_name = "Liaison personnel"
	if(completing_user)
		completing_name = completing_user.name

	say(
		"INTERNAL COMPLIANCE FINDING: [severity] unauthorized procurement activity confirmed. [charged_amount] CU has been recovered from Operational Allocation. Restricted procurement privileges are suspended for [round(suspension_duration / (1 MINUTES))] minutes. Audit compensation has been withheld."
	)

	if(uncollected_amount > 0)
		say(
		"Internal Compliance was unable to recover the full [assessment] CU assessment due to insufficient unreserved allocation. The procurement suspension has been extended by five minutes. Responsible personnel: [completing_name]."
	)

// CIRCUIT BOARD ACCESS

/obj/machinery/computer/ccpost_tasking/proc/get_tasking_board()
	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = circuit
	return tasking_board

// COMPLETION REPORT VALIDATION

/// Returns TRUE when the paper contains actual non-whitespace written text.
/obj/machinery/computer/ccpost_tasking/proc/report_has_written_text(
	obj/item/paper/report
)
	if(!report)
		return FALSE

	for(var/datum/paper_input/entry as anything in report.raw_text_inputs)
		if(length(trim(entry.raw_text)))
			return TRUE

	return FALSE


/// Returns TRUE when the report contains a genuine CentCom stamp.
/obj/machinery/computer/ccpost_tasking/proc/report_has_centcom_stamp(
	obj/item/paper/report
)
	if(!report)
		return FALSE

	var/datum/asset/spritesheet/sheet = get_asset_datum(
		/datum/asset/spritesheet/simple/paper
	)

	var/centcom_stamp_class = sheet.icon_class_name("stamp-centcom")

	for(var/datum/paper_stamp/stamp as anything in report.raw_stamp_data)
		if(stamp.class == centcom_stamp_class)
			return TRUE

	return FALSE


/// Returns TRUE when the submitted report meets all completion requirements.
/obj/machinery/computer/ccpost_tasking/proc/report_is_valid(
	obj/item/paper/report
)
	if(!report)
		return FALSE

	if(!report_has_written_text(report))
		return FALSE

	if(!report_has_centcom_stamp(report))
		return FALSE

	return TRUE


/// Converts the currently inserted report into TGUI data.
/obj/machinery/computer/ccpost_tasking/proc/report_to_ui_data(
	obj/item/paper/report
)
	if(!report)
		return null

	var/has_text = report_has_written_text(report)
	var/has_centcom_stamp = report_has_centcom_stamp(report)

	return list(
		"name" = report.name,
		"has_text" = has_text,
		"has_centcom_stamp" = has_centcom_stamp,
		"valid" = has_text && has_centcom_stamp
	)

// ASSIGNMENT SCHEDULING

/obj/machinery/computer/ccpost_tasking/proc/schedule_next_assignment(
	minimum_delay = 8 MINUTES,
	maximum_delay = 20 MINUTES
)
	if(assignment_timer)
		deltimer(assignment_timer)

	assignment_timer = addtimer(CALLBACK(src, PROC_REF(issue_assignment)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)

/obj/machinery/computer/ccpost_tasking/proc/issue_assignment()
	assignment_timer = null

	// Try again later if the computer is currently unusable.
	if(machine_stat & (NOPOWER | BROKEN))
		schedule_next_assignment(2 MINUTES, 4 MINUTES)
		return

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		return

	// Do not issue another task while an existing one remains unresolved.
	if(tasking_board.current_order && tasking_board.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
		playsound(src, 'sound/machines/terminal_alert.ogg', vol = 35, vary = TRUE)
		visible_message(
			span_notice("[src] emits a brief reminder tone. An active Central Command tasking order remains unresolved.")
		)
		schedule_next_assignment(5 MINUTES, 8 MINUTES)
		return

	// Move the previous completed task into the archive.
	if(tasking_board.current_order)
		tasking_board.order_history.Insert(1, tasking_board.current_order)
		tasking_board.current_order = null

	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network
	var/template_type

	// Restricted procurement forces the compliance-audit template unless the
	// immediately preceding assignment was already that audit.
	if(logistics_network?.contraband_audit_pending && tasking_board.last_template_type != /datum/ccpost_task_template/outpost_audit)
		template_type = /datum/ccpost_task_template/outpost_audit
	else
		template_type = pick(assignment_template_types)

		if(length(assignment_template_types) > 1)
			while(template_type == tasking_board.last_template_type)
				template_type = pick(assignment_template_types)

	var/datum/ccpost_task_template/chosen_template = new template_type
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/order_code = "CC-[round_identifier]-[tasking_board.next_order_number]"

	tasking_board.next_order_number++

	var/datum/ccpost_tasking_order/new_order = new(order_code, chosen_template)
	chosen_template.configure_order(new_order, logistics_network)

	tasking_board.last_template_type = template_type
	tasking_board.current_order = new_order

	qdel(chosen_template)

	playsound(src, 'sound/machines/terminal_alert.ogg', vol = 45, vary = TRUE)
	visible_message(
		span_notice("[src] chimes. A new Central Command tasking order has been received.")
	)

	print_order(tasking_board.current_order)
	SStgui.update_uis(src)
	schedule_next_assignment()

// TGUI

/obj/machinery/computer/ccpost_tasking/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostTasking", name)
		ui.open()

/obj/machinery/computer/ccpost_tasking/ui_data(mob/user)
	var/list/data = list()

	data["submitted_report"] = report_to_ui_data(submitted_report)

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		data["current_order"] = null
		data["history"] = list()

		return data

	data["current_order"] = order_to_ui_data(
		tasking_board.current_order
	)

	var/list/history_data = list()

	for(var/datum/ccpost_tasking_order/order as anything in tasking_board.order_history)
		history_data += list(
			order_to_ui_data(order)
		)

	data["history"] = history_data

	return data

/obj/machinery/computer/ccpost_tasking/proc/order_to_ui_data(
	datum/ccpost_tasking_order/order
)
	if(!order)
		return null

	return list(
		"order_code" = order.order_code,
		"category" = order.category,
		"subject" = order.subject,
		"priority" = order.priority,
		"instruction" = order.instruction,
		"status" = order.status,
		"issued_at" = order.issued_at,
		"acknowledged_by" = order.acknowledged_by,
		"acknowledged_at" = order.acknowledged_at,
		"completed_by" = order.completed_by,
		"completed_at" = order.completed_at
	)


/obj/machinery/computer/ccpost_tasking/ui_act(
	action,
	list/params,
	datum/tgui/ui,
	datum/ui_state/state
)
	. = ..()

	if(.)
		return

	var/mob/user = ui.user

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		return FALSE

	switch(action)
		if("acknowledge")
			if(!tasking_board.current_order)
				return TRUE

			if(tasking_board.current_order.status != CCPOST_TASK_STATUS_PENDING)
				balloon_alert(
					user,
					"already acknowledged"
				)

				return TRUE

			tasking_board.current_order.status = CCPOST_TASK_STATUS_ACKNOWLEDGED
			tasking_board.current_order.acknowledged_by = user.name
			tasking_board.current_order.acknowledged_at = station_time_timestamp()

			playsound(src, 'sound/machines/terminal_alert.ogg', vol = 25, vary = FALSE)

			balloon_alert(
				user,
				"order acknowledged"
			)

			SStgui.update_uis(src)

			return TRUE

		if("eject_report")
			if(!submitted_report)
				balloon_alert(
					user,
					"no report inserted"
				)

				return TRUE

			var/obj/item/paper/ejected_report = submitted_report
			submitted_report = null

			ejected_report.forceMove(drop_location())
			user.put_in_hands(ejected_report)

			playsound(
				src,
				'sound/machines/terminal_alert.ogg',
				vol = 15,
				vary = TRUE
			)

			balloon_alert(
				user,
				"report ejected"
			)

			SStgui.update_uis(src)

			return TRUE

		if("complete")
			if(!tasking_board.current_order)
				return TRUE

			if(tasking_board.current_order.status == CCPOST_TASK_STATUS_PENDING)
				balloon_alert(
					user,
					"acknowledge order first"
				)

				return TRUE

			if(tasking_board.current_order.status == CCPOST_TASK_STATUS_COMPLETED)
				balloon_alert(
					user,
					"already completed"
				)

				return TRUE

			if(!submitted_report)
				balloon_alert(
					user,
					"completion report required"
				)

				return TRUE

			if(!report_has_written_text(submitted_report))
				balloon_alert(
					user,
					"report contains no written findings"
				)

				return TRUE

			if(!report_has_centcom_stamp(submitted_report))
				balloon_alert(
					user,
					"CentCom stamp required"
				)

				return TRUE

			var/obj/item/paper/accepted_report = submitted_report
			submitted_report = null

			tasking_board.current_order.status = CCPOST_TASK_STATUS_COMPLETED
			tasking_board.current_order.completed_by = user.name
			tasking_board.current_order.completed_at = station_time_timestamp()

			// Issue Operational Allocation and any applicable
			// departmental budget grant.
			apply_task_rewards(
				tasking_board.current_order,
				user
			)

			// Supporting documentation has been transmitted and is no
			// longer physically available at the outpost.
			qdel(accepted_report)

			playsound(
				src,
				'sound/machines/terminal_alert.ogg',
				vol = 30,
				vary = TRUE
			)

			balloon_alert(
				user,
				"supporting documentation accepted"
			)

			say(
				"Supporting documentation accepted. Tasking order closed and forwarded for Central Command review."
			)

			SStgui.update_uis(src)

			return TRUE

		if("print_order")
			if(!COOLDOWN_FINISHED(src, print_cooldown))
				balloon_alert(
					user,
					"printer cooling down"
				)

				return TRUE

			var/order_code = params["order_code"]

			var/datum/ccpost_tasking_order/order = find_order(
				order_code
			)

			if(!order)
				balloon_alert(
					user,
					"order not found"
				)

				return TRUE

			COOLDOWN_START(src, print_cooldown, 5 SECONDS)

			print_order(order)

			return TRUE

	return FALSE

// Order Look up

/obj/machinery/computer/ccpost_tasking/proc/find_order(order_code)
	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		return null

	if(tasking_board.current_order?.order_code == order_code)
		return tasking_board.current_order

	for(var/datum/ccpost_tasking_order/order as anything in tasking_board.order_history)
		if(order.order_code == order_code)
			return order

	return null

// Paper Printing

/obj/machinery/computer/ccpost_tasking/proc/print_order(
	datum/ccpost_tasking_order/order
)
	if(!order)
		return

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)

	visible_message(
		span_notice("[src] prints a Central Command tasking order.")
	)

	var/obj/item/paper/ccpost_tasking_order/assignment_paper = new /obj/item/paper/ccpost_tasking_order(
		drop_location()
	)

	assignment_paper.name = "Central Command Tasking Order - [order.order_code]"

	var/acknowledged_by = order.acknowledged_by ? sanitize(order.acknowledged_by) : "N/A"
	var/acknowledged_at = order.acknowledged_at ? order.acknowledged_at : "N/A"

	var/completed_by = order.completed_by ? sanitize(order.completed_by) : "N/A"
	var/completed_at = order.completed_at ? order.completed_at : "N/A"

	var/assignment_text = "<center><table border='0' cellspacing='0' cellpadding='4' bgcolor='#0a1e2b'><tr><td><font color='#f0f0f0' size='6'><b>&#9701;</b></font></td><td><font color='#f0f0f0' size='7'><b>N</b></font></td><td><font color='#f0f0f0' size='6'><b>&#9699;</b></font></td></tr></table></center>"
	assignment_text += "<center><small><i>Central Command Tasking Order</i></small></center><hr><hr><small>"
	assignment_text += "<center>[order.order_code]</center><br>"
	assignment_text += "<hr>"
	assignment_text += "<b>Classification:</b> Internal<br>"
	assignment_text += "<b>Priority:</b> [order.priority]<br>"
	assignment_text += "<b>Category:</b> [order.category]<br>"
	assignment_text += "<b>Subject:</b> [order.subject]<br>"
	assignment_text += "<b>Issued:</b> [order.issued_at]<br>"
	assignment_text += "<b>Status:</b> [order.status]<br>"
	assignment_text += "<hr><br>"
	assignment_text += "[order.instruction]<br><br>"
	assignment_text += "You are instructed to investigate the matter, verify available information, and record your findings for Central Command review.<br><br>"
	assignment_text += "<b>Completion Requirement:</b> Submit a separately written report bearing an official Central Command stamp to the Tasking Terminal.<br><br>"
	assignment_text += "Direct intervention is not authorized unless otherwise instructed.<br><br>"
	assignment_text += "<hr>"
	assignment_text += "<b>Acknowledged By:</b> [acknowledged_by]<br>"
	assignment_text += "<b>Acknowledged At:</b> [acknowledged_at]<br>"
	assignment_text += "<b>Completed By:</b> [completed_by]<br>"
	assignment_text += "<b>Completed At:</b> [completed_at]<br>"
	assignment_text += "<hr><br>"
	assignment_text += "<i>Central Command Administrative Oversight Division</i></small>"

	assignment_paper.add_raw_text(assignment_text)
	assignment_paper.update_appearance()

#undef CCPOST_TASK_STATUS_PENDING
#undef CCPOST_TASK_STATUS_ACKNOWLEDGED
#undef CCPOST_TASK_STATUS_COMPLETED
#undef CCPOST_TASK_PRIORITY_ROUTINE
#undef CCPOST_TASK_PRIORITY_ELEVATED
#undef CCPOST_TASK_PRIORITY_PRIORITY
#undef CCPOST_TASK_PRIORITY_CRITICAL
#undef CCPOST_AUDIT_MINOR
#undef CCPOST_AUDIT_SIGNIFICANT
#undef CCPOST_AUDIT_SEVERE
#undef CCPOST_TASK_AUDIT_TEMPLATE_ID
