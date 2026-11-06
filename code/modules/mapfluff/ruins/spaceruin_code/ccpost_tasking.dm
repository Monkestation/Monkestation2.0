/// Central Command Liaison Outpost tasking system.

#define CCPOST_TASK_STATUS_PENDING "Pending"
#define CCPOST_TASK_STATUS_ACKNOWLEDGED "Acknowledged"
#define CCPOST_TASK_STATUS_COMPLETED "Completed"
#define CCPOST_TASK_STATUS_DEFERRED "Deferred"
#define CCPOST_TASK_STATUS_EXPIRED "Expired"

#define CCPOST_TASK_PRIORITY_ROUTINE "Routine"
#define CCPOST_TASK_PRIORITY_ELEVATED "Elevated"
#define CCPOST_TASK_PRIORITY_PRIORITY "Priority"
#define CCPOST_TASK_PRIORITY_CRITICAL "Critical"

#define CCPOST_AUDIT_MINOR "MINOR"
#define CCPOST_AUDIT_SIGNIFICANT "SIGNIFICANT"
#define CCPOST_AUDIT_SEVERE "SEVERE"

#define CCPOST_TASK_AUDIT_TEMPLATE_ID "outpost_audit"
#define CCPOST_TASK_SUBMISSION_REPORT "report"
#define CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD "installation_record"
#define CCPOST_TASK_ARCHIVE_TEXT_LIMIT 10000

// Central Command task templates

/datum/ccpost_task_template
	var/template_id
	var/category
	var/subject
	var/priority = CCPOST_TASK_PRIORITY_ROUTINE
	var/instruction
	var/department_reward_id
	var/submission_type = CCPOST_TASK_SUBMISSION_REPORT
	/// Event-only templates cannot be selected by the general routine scheduler.
	var/event_only = FALSE
	/// Departmental budget accounts that can supply a suitable interview subject.
	var/list/required_staff_accounts
	/// Exclude these departments from otherwise unrestricted civilian interviews.
	var/list/excluded_staff_accounts
	/// Choose a staff member from any currently occupied station department.
	var/any_station_staff = FALSE

/// Only connected, living station employees are eligible. SSD, departed and ghost-role staff
/// must not cause tasks to target unavailable personnel.
/datum/ccpost_task_template/proc/get_available_staff()
	var/list/available = list()
	for(var/mob/living/carbon/human/employee as anything in GLOB.player_list)
		if(!ishuman(employee) || !employee.client || employee.stat == DEAD)
			continue
		var/datum/job/job = employee.mind?.assigned_role
		if(!job || job.faction != FACTION_STATION)
			continue
		var/account = job.paycheck_department
		if(length(required_staff_accounts) && !(account in required_staff_accounts))
			continue
		if(length(excluded_staff_accounts) && (account in excluded_staff_accounts))
			continue
		available += employee
	return available

/datum/ccpost_task_template/proc/is_eligible()
	if(any_station_staff || length(required_staff_accounts) || length(excluded_staff_accounts))
		return length(get_available_staff()) > 0
	return TRUE

/datum/ccpost_task_template/proc/configure_order(datum/ccpost_tasking_order/order, datum/ccpost_logistics_network/logistics_network)
	return

/datum/ccpost_task_template/command_status
	template_id = "command_status"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "General Operational Status"
	instruction = "Contact station Command and request a general operational status report. Identify any unresolved matters which may warrant continued Central Command observation."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_coordination
	template_id = "command_coordination"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "Departmental Coordination Review"
	instruction = "Assess whether station Command is maintaining effective communication and coordination between departments. Document any significant breakdowns in the chain of communication."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_concern
	template_id = "command_concern"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "Command Concern Inquiry"
	instruction = "Request that station Command identify its most significant current operational concern. Verify the matter where practical and record your assessment."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/security_arrests
	template_id = "security_arrests"
	required_staff_accounts = list(ACCOUNT_SEC)
	category = "Audits & Inspections"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Arrest Procedure Review"
	instruction = "Review Security's handling of recent arrests and determine whether appropriate procedure appears to be followed. Distinguish confirmed information from allegation or speculation."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/security_investigations
	template_id = "security_investigations"
	required_staff_accounts = list(ACCOUNT_SEC)
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Security Oversight"
	subject = "Unresolved Investigation Review"
	instruction = "Contact Security and request an overview of any unresolved high-priority investigations. Determine whether any require additional Central Command monitoring."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/engineering_status
	template_id = "engineering_status"
	required_staff_accounts = list(ACCOUNT_ENG)
	category = "Infrastructure Oversight"
	subject = "Engineering Status Assessment"
	instruction = "Contact Engineering and request an assessment of current station infrastructure, including any significant power, atmospheric, structural, or telecommunications concerns."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/engineering_sustainability
	template_id = "engineering_sustainability"
	required_staff_accounts = list(ACCOUNT_ENG)
	category = "Infrastructure Oversight"
	subject = "Continued Operations Assessment"
	instruction = "Request an assessment from Engineering regarding the station's ability to sustain continued operations. Record any systems identified as vulnerable or degraded."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/communications
	template_id = "communications"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	category = "Communications Oversight"
	subject = "Communications Integrity Review"
	instruction = "Review recent station communications for conflicting, incomplete, or unverifiable information. Request clarification from relevant personnel where necessary."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/communications_outage
	template_id = "communications_outage"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Communications Oversight"
	subject = "Communications Reliability Inquiry"
	instruction = "Ask Engineering whether the station has experienced significant communications outages. If a disruption is verified, record its probable cause and impact. If none occurred, assess the current communications reliability and document a baseline."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/medical_status
	template_id = "medical_status"
	required_staff_accounts = list(ACCOUNT_MED)
	category = "Medical Oversight"
	subject = "Personnel Condition Report"
	instruction = "Ask Medical about staffing coverage, critical supplies, patient-service readiness and outstanding maintenance concerns. Verify relevant information and recommend operational improvements where appropriate."
	department_reward_id = ACCOUNT_MED

/datum/ccpost_task_template/explosions
	template_id = "explosions"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG, ACCOUNT_SEC)
	event_only = TRUE
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	category = "Incident Review"
	subject = "Explosive Incident Inquiry"
	instruction = "Request clarification regarding any significant explosions reported aboard the station. Determine their approximate cause, location, and effect on station operations."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/sabotage_review
	template_id = "sabotage_review"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC)
	event_only = TRUE
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Incident Review"
	subject = "Sabotage Assessment"
	instruction = "Review recent significant incidents and assess whether available evidence better supports deliberate sabotage, negligence, equipment failure, or routine operational error."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/department_status
	template_id = "department_status"
	any_station_staff = TRUE
	category = "Operational Oversight"
	subject = "Department Readiness Review"
	instruction = "Determine whether any station department is operating below acceptable staffing or operational levels. Document any significant deficiencies."

/datum/ccpost_task_template/emergency_readiness
	template_id = "emergency_readiness"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC, ACCOUNT_ENG)
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Operational Oversight"
	subject = "Emergency Preparedness Review"
	instruction = "Assess the station's present emergency preparedness. Identify any obvious deficiencies in coordination, staffing, equipment, or response capability."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/conflicting_accounts
	template_id = "conflicting_accounts"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC)
	category = "Administrative Oversight"
	subject = "Report Consistency Review"
	instruction = "Review available departmental accounts of recent noteworthy incidents. Identify significant contradictions and request clarification where appropriate."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/monitoring_assessment
	template_id = "monitoring_assessment"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Administrative Oversight"
	subject = "Monitoring Requirement Assessment"
	instruction = "Determine whether current station conditions justify increased Central Command monitoring. Record the factors supporting your conclusion."

/datum/ccpost_task_template/outpost_audit
	template_id = CCPOST_TASK_AUDIT_TEMPLATE_ID
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Internal Compliance"
	subject = "Liaison Outpost Compliance Audit"
	instruction = "Central Command Internal Compliance has selected this installation for a routine audit. Review the outpost's Operational Allocation ledger, freight requisition history, recent Sector Communications responses, and completed tasking records. Submit a concise account of any discrepancies, unexplained expenditures, missing documentation, or procedural violations."

/datum/ccpost_task_template/developing_situation
	template_id = "developing_situation"
	any_station_staff = TRUE
	category = "General Oversight"
	subject = "Developing Situation Review"
	instruction = "Identify any developing situation aboard the station which may require future Central Command attention. Verify available information and document your findings."


/// Created from a station atmospheric alarm, rather than random selection.
/datum/ccpost_task_template/atmos_emergency
	template_id = "atmos_emergency"
	category = "Infrastructure Oversight"
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	subject = "Atmospheric Emergency Assessment"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	department_reward_id = ACCOUNT_ENG
	instruction = "A station atmospheric alarm has been observed through the emergency monitoring network. Contact Engineering or station Command, determine the reported area and operational impact, establish whether the condition remains active, and document confirmed information. Do not assume sabotage."

/// The supermatter system has begun its actual delamination countdown.
/datum/ccpost_task_template/supermatter_incident
	template_id = "supermatter_incident"
	category = "Infrastructure Oversight"
	priority = CCPOST_TASK_PRIORITY_CRITICAL
	subject = "Supermatter Emergency Review"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	department_reward_id = ACCOUNT_ENG
	instruction = "An emergency indication from the station's supermatter installation has been received. Request a current operational report from Engineering or Command and document the risk, corrective action, and known outcome. This is an information-gathering assignment, not authorization to access or control the reactor."

/// Scoped to broken, depowered or removed station telecomms hubs (not every radio).
/datum/ccpost_task_template/telecomms_incident
	template_id = "telecomms_incident"
	category = "Communications Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Telecommunications Infrastructure Incident"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	department_reward_id = ACCOUNT_ENG
	instruction = "A disruption has been detected at a station telecommunications hub. Ask Engineering to confirm whether station communications were affected and what corrective work is underway. Avoid reporting a complete outage unless independently verified."


/// V3.2 public-round-event assignments. These are never routine-random tasks.
/// The bridge only queues these AFTER their event has issued a public announcement.
/datum/ccpost_task_template/public_radiation_storm
	template_id = "public_radiation_storm"
	category = "Incident Review"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Radiation Storm Response Assessment"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_MED, ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_MED
	instruction = "Following the publicly announced radiation storm warning, contact Medical and/or Engineering when conditions permit. Determine whether protective measures were effective, whether exposure or equipment damage has been confirmed, and whether any concerns remain unresolved. Distinguish direct findings from personnel statements; do not assume anyone was injured."

/datum/ccpost_task_template/public_meteor_wave
	template_id = "public_meteor_wave"
	category = "Infrastructure Oversight"
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	subject = "Meteor Activity Structural Review"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "Meteor activity has been publicly announced. Once the immediate hazard has passed or the station can report safely, contact Engineering or Command to establish whether a collision occurred, which systems were affected, and whether repairs or inspections are outstanding. A meteor warning does not by itself prove the station sustained damage."

/datum/ccpost_task_template/public_electrical_storm
	template_id = "public_electrical_storm"
	category = "Infrastructure Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Electrical Storm Recovery Inquiry"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "A public electrical storm warning has been received. Request an Engineering status report on affected lighting, power distribution, and any damaged equipment. Verify whether service has been restored, identify any persistent faults, and document observed effects without assuming every system failed."

/datum/ccpost_task_template/public_radiation_leak
	template_id = "public_radiation_leak"
	category = "Incident Review"
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	subject = "Announced Radiation Leak Inquiry"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_MED, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "A radiation leak has been publicly announced on the station. Contact Engineering or Medical when safe, establish the reported location, confirm whether the leak has been isolated, and document any known exposure or operational disruption. Do not speculate about the cause before station personnel provide evidence."

/datum/ccpost_task_template/public_communications_blackout
	template_id = "public_communications_blackout"
	category = "Communications Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Announced Communications Disruption Review"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "Central Command received a public station warning of an impending communications disruption. When channels are available, contact Engineering or Command to confirm the actual duration, affected systems, and restoration status. Record any continuing operational limitations. Do not infer a completed outage from the warning alone."
/// V3.5.1: confirmed, publicly announced event reviews. None appear in random routine tasking.
/// These orders request department findings; they never grant operational authority.
/datum/ccpost_task_template/public_supermatter_surge
	template_id = "public_supermatter_surge"
	category = "Infrastructure Oversight"
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	subject = "Supermatter Stability Assessment"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "A supermatter energy surge has been publicly announced. When personnel can respond safely, request an Engineering or Command stability assessment. Record the reported surge severity, any confirmed changes in engine output or containment, protective actions taken, and whether the chamber has returned to normal operation. Identify unresolved hazards and distinguish the surge from an actual delamination emergency. Request findings, not access to or control of the engine."

/datum/ccpost_task_template/public_disease_outbreak
	template_id = "public_disease_outbreak"
	category = "Incident Review"
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	subject = "Biological Containment Review"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_MED, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_MED
	instruction = "A stationwide viral biohazard alert has been publicly announced. Contact Medical or Command when feasible and request an aggregate outbreak status report: verified symptomatic or diagnosed cases, isolation and hygiene measures, diagnostic and treatment readiness, and any continuing containment difficulties. Document confirmed actions and outstanding support needs. Do not demand confidential individual medical records or assume the outbreak has already been contained."

/datum/ccpost_task_template/public_major_power_failure
	template_id = "public_major_power_failure"
	category = "Infrastructure Oversight"
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	subject = "Station Power Continuity Assessment"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "A major station power failure was publicly announced. Request a power-continuity assessment from Engineering or Command. Identify which essential services and departments lost power, whether backup power and emergency lighting functioned, the status of restoration work, and any unresolved risks to station operations. Establish the observed extent and duration; do not treat the announcement as proof that every system lost power."

/datum/ccpost_task_template/public_gravity_generator_blackout
	template_id = "public_gravity_generator_blackout"
	category = "Infrastructure Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Artificial Gravity Restoration Review"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "A gravity-generator disturbance and manual-reset advisory were publicly announced. Ask Engineering or Command to identify affected areas, generator reset progress, the duration and consequences of any verified gravity outage, and any reported injuries or operational interruptions. Confirm whether normal gravity has returned and whether follow-up maintenance is necessary."

/datum/ccpost_task_template/public_ion_storm
	template_id = "public_ion_storm"
	category = "Operational Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Artificial Intelligence Compliance Review"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	department_reward_id = ACCOUNT_CMD
	instruction = "An ion storm warning affecting AI-controlled systems has been publicly issued. Contact Command or Engineering to establish whether unusual AI or automated-equipment behavior was actually observed, whether affected systems were inspected, and what corrective or monitoring measures were taken. Report confirmed operational effects only. Do not request secret AI laws or assume the AI is compromised merely because a storm was announced."

/datum/ccpost_task_template/public_grey_tide
	template_id = "public_grey_tide"
	category = "Security Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Access Control Integrity Assessment"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_SEC, ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_SEC
	instruction = "A Grey Tide access-encryption fault has been publicly announced. Request a Security or Engineering review of malfunctioning doors, lockers, or related access controls; identify any verified breaches of secured areas, containment or repair work, and the current integrity of critical access systems. Treat an alert as evidence of a fault, not proof that an unauthorized person entered a restricted area."


/datum/ccpost_task_template/archived_followup
	template_id = "archived_followup"
	category = "Administrative Follow-Up"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Archived Findings Follow-Up"
	event_only = TRUE
	instruction = "Review the previously submitted report and gather updated findings from appropriate sources. Recontact actual station personnel where relevant; for simulated sector installations, use Remote Oversight records and Sector Communications. Do not presume that a violation occurred."

// Additional oversight, civilian-interview, and records assignments.
/datum/ccpost_task_template/departmental_compliance
	template_id = "departmental_compliance"
	any_station_staff = TRUE
	category = "Audits & Inspections"
	subject = "Departmental Operational Audit"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	instruction = "Select an actively staffed station department and request its operational documentation, personnel coverage, unresolved safety concerns and outstanding maintenance needs. Interview a responsible employee, distinguish verified findings from unsupported claims, and report any procedural deficiencies. Document a lack of available staff if applicable."

/datum/ccpost_task_template/security_detention
	template_id = "security_detention"
	required_staff_accounts = list(ACCOUNT_SEC)
	category = "Audits & Inspections"
	subject = "Detention Procedures Inspection"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	instruction = "Contact the Warden or Head of Security and request a procedural account of detention and prisoner-property handling. Inspect available records if voluntarily provided, identify any discrepancies, and document the evidence. This task does not authorize searches, arrests or command over station Security."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/service_sanitation
	template_id = "service_sanitation"
	required_staff_accounts = list(ACCOUNT_SRV)
	category = "Audits & Inspections"
	subject = "Service Sanitation Review"
	instruction = "Request a sanitation and food-handling assessment from available Service or Janitorial staff. Review available procedures and documented concerns, and identify any recommended follow-up. If the positions are unstaffed, document the staffing deficiency and consult station Command."
	department_reward_id = ACCOUNT_SRV

/datum/ccpost_task_template/cargo_reconciliation
	template_id = "cargo_reconciliation"
	required_staff_accounts = list(ACCOUNT_CAR)
	category = "Audits & Inspections"
	subject = "Cargo Expenditure Reconciliation"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	instruction = "Ask Cargo for a recent procurement summary and identify any major expenditures or incomplete deliveries. Verify the operational justifications where practical and prepare a neutral administrative report. Do not imply misconduct without supporting evidence."
	department_reward_id = ACCOUNT_CAR

/datum/ccpost_task_template/civilian_interview
	template_id = "civilian_interview"
	excluded_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC)
	any_station_staff = TRUE
	category = "Personnel & Civilian Liaison"
	subject = "Civilian Services Interview"
	instruction = "Interview an available non-Command, non-Security employee about workplace conditions, department needs and any obstacles to continued operations. Record their statements accurately and recommend proportionate administrative follow-up. If no suitable employee is available, document the staffing limitation."

/datum/ccpost_task_template/sector_record_certification
	template_id = "sector_record_certification"
	category = "Sector Records & Administration"
	subject = "Regional Installation Record Certification"
	submission_type = CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD

/datum/ccpost_task_template/sector_record_certification/is_eligible()
	if(!..())
		return FALSE
	var/datum/ccpost_sector_network/network = GLOB.ccpost_sector_network
	network?.ensure_started()
	if(!network)
		return FALSE
	for(var/datum/ccpost_sector_installation/installation as anything in network.sector_installations)
		if(!installation.destroyed)
			return TRUE
	return FALSE

/datum/ccpost_task_template/sector_record_certification/configure_order(datum/ccpost_tasking_order/order, datum/ccpost_logistics_network/logistics_network)
	var/datum/ccpost_sector_network/network = GLOB.ccpost_sector_network
	if(!network || !length(network.sector_installations))
		return
	var/list/candidates = list()
	for(var/datum/ccpost_sector_installation/installation as anything in network.sector_installations)
		if(!installation.destroyed)
			candidates += installation
	if(!length(candidates))
		return
	var/datum/ccpost_sector_installation/selected = pick(candidates)
	order.target_installation_code = selected.installation_code
	order.subject = "Installation Record Certification: [selected.installation_code]"
	order.instruction = "Central Command Records Administration requests an authenticated administrative record for [selected.installation_name] ([selected.installation_code]). Open a Remote Oversight Network display, select Installation Records, print the corresponding installation's current administrative record, review its contents, and apply an official Central Command stamp. Submit that exact machine-generated record through the Tasking Terminal. No separate handwritten report is required. Certification records the review; it does not change the installation's condition."

/datum/ccpost_task_template/sector_incident_review
	template_id = "sector_incident_review"
	category = "Sector Records & Administration"
	subject = "Regional Incident Documentation"
	priority = CCPOST_TASK_PRIORITY_ELEVATED

/datum/ccpost_task_template/sector_incident_review/is_eligible()
	if(!..())
		return FALSE
	var/datum/ccpost_sector_network/network = GLOB.ccpost_sector_network
	network?.ensure_started()
	if(!network)
		return FALSE
	for(var/datum/ccpost_sector_installation/installation as anything in network.sector_installations)
		if(!network.is_installation_green(installation))
			return TRUE
	return FALSE

/datum/ccpost_task_template/sector_incident_review/configure_order(datum/ccpost_tasking_order/order, datum/ccpost_logistics_network/logistics_network)
	var/datum/ccpost_sector_network/network = GLOB.ccpost_sector_network
	var/list/candidates = list()
	for(var/datum/ccpost_sector_installation/installation as anything in network.sector_installations)
		if(!network.is_installation_green(installation))
			candidates += installation
	if(!length(candidates))
		return
	var/datum/ccpost_sector_installation/selected = pick(candidates)
	order.target_installation_code = selected.installation_code
	order.subject = "Regional Incident Review: [selected.installation_code]"
	order.instruction = "Regional monitoring indicates that [selected.installation_name] ([selected.installation_code]) is not operating normally. Review its current status and retained history on the Remote Oversight Network, consult recent Sector Communications, and submit a written, stamped summary of confirmed information, outstanding uncertainties and recommended follow-up. This review does not authorize intervention."

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

// Template forms contain preprinted instructions but require actual additional writing.
/obj/item/paper/ccpost_report_template
	name = "Central Command administrative form"
	var/preprinted_text_count = 0
	/// Printed footer is kept last when players append paragraphs with a pen.
	var/template_has_footer = FALSE

/obj/item/paper/ccpost_report_template/add_raw_text(text, font, color, bold, advanced_html)
	. = ..()
	if(!template_has_footer || length(raw_text_inputs) <= preprinted_text_count)
		return
	// PaperSheet appends new writing to the end. Move only new content above
	// the preprinted authorization footer so the document remains properly ordered.
	var/last_index = length(raw_text_inputs)
	var/datum/paper_input/added_entry = raw_text_inputs[last_index]
	raw_text_inputs.Cut(last_index, last_index + 1)
	raw_text_inputs.Insert(last_index - 1, added_entry)

/// An authenticated Remote Oversight Network printout, not a generic paper copy.
/obj/item/paper/ccpost_installation_record
	name = "Central Command installation record"
	var/installation_code

/obj/item/paper/ccpost_frequency_reference
	name = "Central Command radio frequency reference"
	desc = "A reference sheet for ordinary, authorized outpost communications."

// Central Command Tasking System

/datum/ccpost_tasking_order
	var/order_code
	var/template_id
	var/category
	var/subject
	var/priority
	var/instruction
	var/submission_type = CCPOST_TASK_SUBMISSION_REPORT
	var/target_installation_code
	var/submitted_report_name
	var/submitted_report_text
	/// Sanitized archival markup derived from a completed paper record.
	var/submitted_report_markup
	/// Exact detached PaperSheet copy, including inputs, font settings, filled fields and stamp overlays.
	/// This archival copy uses the task-order subtype, so it is never valid completion evidence.
	var/obj/item/paper/ccpost_tasking_order/archived_paper
	/// Whether the original report was printed with an official CentCom masthead.
	var/submitted_report_has_official_layout = FALSE
	var/report_centcom_stamp_verified = FALSE
	var/source_order_code
	var/assigned_contact
	var/assigned_role
	var/assigned_department
	/// Number of times a current order has been temporarily deferred.
	var/deferral_count = 0
	var/deferred_at
	var/deferred_until = 0
	var/deferral_expires_at = 0
	var/deferral_reason
	var/deferred_by
	var/status_before_deferral = CCPOST_TASK_STATUS_PENDING

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
	submission_type = template.submission_type
	department_reward_id = template.department_reward_id
	issued_at = station_time_timestamp()


/datum/ccpost_tasking_order/Destroy()
	QDEL_NULL(archived_paper)
	return ..()

/// Returns the Operational Allocation reward for this task.
///
/// Task value is determined by its priority rather than being configured
/// individually on every assignment template.
/datum/ccpost_tasking_order/proc/get_allocation_reward()
	if(submission_type == CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD)
		return 4
	switch(priority)
		if(CCPOST_TASK_PRIORITY_ROUTINE)
			return 8

		if(CCPOST_TASK_PRIORITY_ELEVATED)
			return 10

		if(CCPOST_TASK_PRIORITY_PRIORITY)
			return 12

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
	/// Pending observable events are queued while Liaisons work on another order.
	var/list/event_task_queue = list()
	var/list/event_task_cooldowns = list()
	/// Ineligible event orders are retained only for a bounded amount of time.
	var/list/event_task_expires = list()
	var/max_history = 30
	/// All distinct incident categories fit without preemptively deleting a lower-priority report.
	var/max_queued_incidents = 32
	var/last_significant_explosion_at = -10 MINUTES
	/// Deferred orders retain their identity, acceptance and reward flag.
	var/list/deferred_orders = list()
	var/max_deferred_orders = 2
	var/max_deferrals_per_order = 2
	/// Completed reports can generate a bounded, single-stage follow-up.
	var/list/followup_orders = list()
	var/max_pending_followups = 2
	var/next_followup_allowed_at = 0

/obj/item/circuitboard/computer/ccpost_tasking/Destroy()
	QDEL_NULL(current_order)
	QDEL_LIST(order_history)
	QDEL_LIST(deferred_orders)
	QDEL_LIST(followup_orders)
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
	/// Only linked station telecomms hubs; register per machine instead of scanning each tick.
	var/list/monitored_telecomms_hubs = list()
	/// Fire once for a cluster of active atmospheric alarms.
	var/list/recent_atmos_alarm_areas = list()
	var/last_atmos_alarm_at = -10 MINUTES

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
	if(!ccpost_has_centcom_id(user))
		balloon_alert(user, "Central Command ID required")
		return ITEM_INTERACT_BLOCKING

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

	if(istype(report, /obj/item/paper/ccpost_tasking_order) || istype(report, /obj/item/paper/ccpost_frequency_reference))
		balloon_alert(user, "reference document is not evidence")
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
		'sound/machines/terminal/terminal_alert.ogg',
		vol = 20,
		vary = TRUE
	)

	balloon_alert(user, "report inserted")

	SStgui.update_uis(src)

	return ITEM_INTERACT_SUCCESS

// Initialization

/obj/machinery/computer/ccpost_tasking/Initialize(mapload)
	. = ..()

	// Issue the first assignment shortly after initialization.
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(on_station_explosion))
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_changed))
	RegisterSignal(SSdcs, COMSIG_GLOB_ALARM_FIRE(ALARM_ATMOS), PROC_REF(on_atmospheric_alarm))
	RegisterSignal(SSdcs, COMSIG_MAIN_SM_DELAMINATING, PROC_REF(on_supermatter_delamination))
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_MACHINE, PROC_REF(on_new_machine))
	addtimer(CALLBACK(src, PROC_REF(register_existing_telecomms)), 30 SECONDS)
	schedule_next_assignment(2 MINUTES, 4 MINUTES)

/obj/machinery/computer/ccpost_tasking/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_ALARM_FIRE(ALARM_ATMOS), COMSIG_MAIN_SM_DELAMINATING, COMSIG_GLOB_NEW_MACHINE))
	for(var/obj/machinery/telecomms/hub/hub as anything in monitored_telecomms_hubs)
		if(!QDELETED(hub))
			UnregisterSignal(hub, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST, COMSIG_QDELETING))
	monitored_telecomms_hubs = null
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

	if(istype(report, /obj/item/paper/ccpost_report_template))
		var/obj/item/paper/ccpost_report_template/form = report
		if(length(form.raw_field_input_data))
			return TRUE
		if(length(form.raw_text_inputs) <= form.preprinted_text_count)
			return FALSE
		var/index = 1
		for(var/datum/paper_input/form_entry as anything in form.raw_text_inputs)
			var/is_preprinted = (index == 1 || (form.template_has_footer && index == length(form.raw_text_inputs)) || (!form.template_has_footer && index <= form.preprinted_text_count))
			index++
			if(is_preprinted)
				continue
			if(length(trim(form_entry.raw_text)))
				return TRUE
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


/// Returns a specific rejection reason. Null means that this document is accepted.
/obj/machinery/computer/ccpost_tasking/proc/report_validation_issue(obj/item/paper/report)
	if(!report)
		return "No supporting documentation has been inserted."
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	var/datum/ccpost_tasking_order/order = board?.current_order
	if(!order)
		return "No active tasking order is available for certification."
	if(istype(report, /obj/item/paper/ccpost_tasking_order) || istype(report, /obj/item/paper/ccpost_frequency_reference))
		return "Reference copies and tasking orders are not valid completion evidence."
	if(order.submission_type == CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD)
		if(!istype(report, /obj/item/paper/ccpost_installation_record))
			return "The assignment requires an original Remote Oversight installation record for [order.target_installation_code]."
		var/obj/item/paper/ccpost_installation_record/record = report
		if(record.installation_code != order.target_installation_code)
			return "Installation mismatch: document [record.installation_code] does not match assigned installation [order.target_installation_code]."
		if(!report_has_centcom_stamp(report))
			return "The installation record requires a physical Central Command stamp."
		return null
	if(istype(report, /obj/item/paper/ccpost_installation_record))
		return "This assignment requires a written report, not an installation record."
	if(!report_has_written_text(report))
		return "Written findings are required; preprinted form text alone is insufficient."
	if(!report_has_centcom_stamp(report))
		return "The report requires a physical Central Command stamp."
	return null

/// Returns TRUE only for an accepted report, including a matching installation ID.
/obj/machinery/computer/ccpost_tasking/proc/report_is_valid(obj/item/paper/report)
	return isnull(report_validation_issue(report))


/// Converts the currently inserted report into TGUI data.
/obj/machinery/computer/ccpost_tasking/proc/report_to_ui_data(
	obj/item/paper/report
)
	if(!report)
		return null

	var/has_text = report_has_written_text(report)
	var/has_centcom_stamp = report_has_centcom_stamp(report)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(board?.current_order?.submission_type == CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD)
		has_text = istype(report, /obj/item/paper/ccpost_installation_record)

	var/obj/item/paper/ccpost_installation_record/installation_record = report
	return list(
		"name" = report.name,
		"has_text" = has_text,
		"has_centcom_stamp" = has_centcom_stamp,
		"record_installation_code" = istype(report, /obj/item/paper/ccpost_installation_record) ? installation_record.installation_code : null,
		"validation_message" = report_validation_issue(report),
		"valid" = report_is_valid(report)
	)


/obj/machinery/computer/ccpost_tasking/proc/attach_staffing_context(datum/ccpost_tasking_order/order, datum/ccpost_task_template/template)
	if(!order || !template || !(template.any_station_staff || length(template.required_staff_accounts) || length(template.excluded_staff_accounts)))
		return TRUE
	var/list/staff = template.get_available_staff()
	if(!length(staff))
		return FALSE
	var/mob/living/carbon/human/employee = pick(staff)
	var/datum/job/job = employee.mind?.assigned_role
	if(!job)
		return FALSE
	order.assigned_contact = employee.real_name
	order.assigned_role = job.title
	order.assigned_department = job.paycheck_department
	order.instruction += "\n\nStaffing verification at issue: [employee.real_name] ([job.title]) is an available contact. If the employee leaves or cannot be reached, use the Defer option rather than inventing an interview."
	return TRUE

/// V3.2: explicit allowlist for publicly announced, non-secret round events.
/// Event definitions invoke this immediately AFTER issuing a stationwide announcement.
/// Internal event creation, start, and unannounced incidents never invoke this proc.
/// The optional fake-event flag is checked by each caller before invoking this bridge.
/proc/ccpost_note_public_round_event(event_id)
	var/template_type
	var/cooldown_duration = 15 MINUTES
	switch(event_id)
		if("radiation_storm")
			template_type = /datum/ccpost_task_template/public_radiation_storm
		if("meteor_wave")
			template_type = /datum/ccpost_task_template/public_meteor_wave
			cooldown_duration = 20 MINUTES
		if("electrical_storm")
			template_type = /datum/ccpost_task_template/public_electrical_storm
		if("radiation_leak")
			template_type = /datum/ccpost_task_template/public_radiation_leak
		if("communications_blackout")
			template_type = /datum/ccpost_task_template/public_communications_blackout
		if("supermatter_surge")
			template_type = /datum/ccpost_task_template/public_supermatter_surge
			cooldown_duration = 25 MINUTES
		if("disease_outbreak")
			template_type = /datum/ccpost_task_template/public_disease_outbreak
			cooldown_duration = 30 MINUTES
		if("major_power_failure")
			template_type = /datum/ccpost_task_template/public_major_power_failure
			cooldown_duration = 20 MINUTES
		if("gravity_generator_blackout")
			template_type = /datum/ccpost_task_template/public_gravity_generator_blackout
			cooldown_duration = 20 MINUTES
		if("ion_storm")
			template_type = /datum/ccpost_task_template/public_ion_storm
			cooldown_duration = 20 MINUTES
		if("grey_tide")
			template_type = /datum/ccpost_task_template/public_grey_tide
			cooldown_duration = 25 MINUTES
	if(!template_type)
		return
	// Event callbacks are rare. Use the engine's by-type machine list instead
	// of scanning turfs/areas or registering signal handlers for secret events.
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in SSmachines.get_machines_by_type(/obj/machinery/computer/ccpost_tasking))
		if(QDELETED(terminal))
			continue
		terminal.queue_event_task(template_type, cooldown_duration)

// TASKING REACTION TO OBSERVABLE STATION EVENTS
// No continuous scans. The handlers only enqueue a small number of distinct assignments.
// Larger rank means higher urgency. Equal-priority assignments keep FIFO arrival order.
/proc/ccpost_incident_priority_rank(priority)
	switch(priority)
		if(CCPOST_TASK_PRIORITY_CRITICAL)
			return 4
		if(CCPOST_TASK_PRIORITY_PRIORITY)
			return 3
		if(CCPOST_TASK_PRIORITY_ELEVATED)
			return 2
	return 1

/obj/machinery/computer/ccpost_tasking/proc/insert_event_task_by_priority(obj/item/circuitboard/computer/ccpost_tasking/board, template_type)
	if(!board || !template_type || template_type in board.event_task_queue)
		return
	var/datum/ccpost_task_template/new_template = new template_type
	var/new_rank = ccpost_incident_priority_rank(new_template.priority)
	qdel(new_template)
	for(var/i in 1 to length(board.event_task_queue))
		var/old_type = board.event_task_queue[i]
		var/datum/ccpost_task_template/old_template = new old_type
		var/old_rank = ccpost_incident_priority_rank(old_template.priority)
		qdel(old_template)
		if(new_rank > old_rank)
			board.event_task_queue.Insert(i, template_type)
			return
	board.event_task_queue += template_type

// TASKING REACTION TO OBSERVABLE STATION EVENTS
// No continuous scans. These signals queue at most one entry per incident category.
/obj/machinery/computer/ccpost_tasking/proc/queue_event_task(template_type, cooldown_duration = 12 MINUTES)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !template_type)
		return
	var/last_queued = board.event_task_cooldowns["[template_type]"]
	if(last_queued && world.time < last_queued)
		return
	if(template_type in board.event_task_queue)
		return
	// Preserve existing queued incident work rather than evicting lower ranks.
	if(length(board.event_task_queue) >= board.max_queued_incidents)
		return
	if(board.current_order?.template_id)
		var/datum/ccpost_task_template/queued_template = new template_type
		var/same_as_active = board.current_order.template_id == queued_template.template_id
		qdel(queued_template)
		if(same_as_active)
			return
	insert_event_task_by_priority(board, template_type)
	board.event_task_cooldowns["[template_type]"] = world.time + cooldown_duration
	board.event_task_expires["[template_type]"] = world.time + 60 MINUTES
	if(!board.current_order || board.current_order.status == CCPOST_TASK_STATUS_COMPLETED)
		schedule_next_assignment(20 SECONDS, 40 SECONDS)

/obj/machinery/computer/ccpost_tasking/proc/on_station_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range)
	SIGNAL_HANDLER
	if(!epicenter || !is_station_level(epicenter.z))
		return
	if(max(devastation_range, heavy_impact_range) < 2)
		return
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(board && world.time - board.last_significant_explosion_at < 5 MINUTES)
		queue_event_task(/datum/ccpost_task_template/sabotage_review)
	if(board)
		board.last_significant_explosion_at = world.time
	queue_event_task(/datum/ccpost_task_template/explosions)

/obj/machinery/computer/ccpost_tasking/proc/on_security_level_changed(datum/source, new_security_level)
	SIGNAL_HANDLER
	if(new_security_level >= SEC_LEVEL_RED)
		queue_event_task(/datum/ccpost_task_template/emergency_readiness, 15 MINUTES)


/obj/machinery/computer/ccpost_tasking/proc/on_atmospheric_alarm(datum/source, datum/alarm_handler/handler, alarm_type, area/alarmed_area, z_level)
	SIGNAL_HANDLER
	if(alarm_type != ALARM_ATMOS || !alarmed_area || !is_station_level(z_level))
		return
	if(("[alarmed_area]" in recent_atmos_alarm_areas) && world.time - last_atmos_alarm_at < 3 MINUTES)
		return
	if(world.time - last_atmos_alarm_at > 3 MINUTES)
		recent_atmos_alarm_areas.Cut()
	recent_atmos_alarm_areas += "[alarmed_area]"
	if(length(recent_atmos_alarm_areas) > 10)
		recent_atmos_alarm_areas.Cut(1, 2)
	last_atmos_alarm_at = world.time
	queue_event_task(/datum/ccpost_task_template/atmos_emergency, 8 MINUTES)

/obj/machinery/computer/ccpost_tasking/proc/on_supermatter_delamination(datum/source, delaminating)
	SIGNAL_HANDLER
	if(!delaminating)
		return
	queue_event_task(/datum/ccpost_task_template/supermatter_incident, 20 MINUTES)

/obj/machinery/computer/ccpost_tasking/proc/register_existing_telecomms()
	if(QDELETED(src))
		return
	for(var/obj/machinery/telecomms/hub/hub as anything in GLOB.telecomms_list)
		if(istype(hub, /obj/machinery/telecomms/hub))
			register_telecomms_hub(hub)

/obj/machinery/computer/ccpost_tasking/proc/register_telecomms_hub(obj/machinery/telecomms/hub/hub)
	if(!hub || QDELETED(hub) || hub in monitored_telecomms_hubs || !is_station_level(hub.z))
		return
	monitored_telecomms_hubs += hub
	RegisterSignal(hub, COMSIG_MACHINERY_BROKEN, PROC_REF(on_telecomms_hub_failure))
	RegisterSignal(hub, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_telecomms_hub_failure))
	RegisterSignal(hub, COMSIG_QDELETING, PROC_REF(on_telecomms_hub_removed))

/obj/machinery/computer/ccpost_tasking/proc/on_new_machine(datum/source, obj/machinery/created_machine)
	SIGNAL_HANDLER
	if(istype(created_machine, /obj/machinery/telecomms/hub))
		register_telecomms_hub(created_machine)

/obj/machinery/computer/ccpost_tasking/proc/on_telecomms_hub_failure(datum/source)
	SIGNAL_HANDLER
	var/obj/machinery/telecomms/hub/hub = source
	if(!hub || !is_station_level(hub.z))
		return
	queue_event_task(/datum/ccpost_task_template/telecomms_incident, 15 MINUTES)

/obj/machinery/computer/ccpost_tasking/proc/on_telecomms_hub_removed(datum/source)
	SIGNAL_HANDLER
	var/obj/machinery/telecomms/hub/hub = source
	monitored_telecomms_hubs -= hub
	if(hub && is_station_level(hub.z))
		queue_event_task(/datum/ccpost_task_template/telecomms_incident, 15 MINUTES)


/// A follow-up request retains the original order reference, not the confidential report text.
/datum/ccpost_task_followup
	var/source_order_code
	var/source_subject
	var/source_category
	var/source_installation_code
	/// Earliest time at which this follow-up may be issued.
	var/ready_at = 0
	var/assigned_contact
	var/assigned_role
	var/assigned_department

/datum/ccpost_task_followup/New(datum/ccpost_tasking_order/original)
	. = ..()
	source_order_code = original.order_code
	source_subject = original.subject
	source_category = original.category
	source_installation_code = original.target_installation_code
	// A report must have aged before Central Command can request another review.
	ready_at = world.time + rand(20 MINUTES, 30 MINUTES)
	assigned_contact = original.assigned_contact
	assigned_role = original.assigned_role
	assigned_department = original.assigned_department

/obj/machinery/computer/ccpost_tasking/proc/queue_report_followup(datum/ccpost_tasking_order/order)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !order?.submitted_report_text || order.source_order_code)
		return
	if(!(order.category in list("Audits & Inspections", "Incident Review", "Infrastructure Oversight", "Communications Oversight", "Sector Records & Administration")))
		return
	if(length(board.followup_orders) >= board.max_pending_followups)
		return
	/// Not every completed report needs revisiting. Selection never invents a finding.
	if(world.time < board.next_followup_allowed_at)
		return
	var/datum/ccpost_task_followup/followup = new(order)
	board.followup_orders += followup
	board.next_followup_allowed_at = world.time + 10 MINUTES

/obj/machinery/computer/ccpost_tasking/proc/make_followup_assignment(datum/ccpost_task_followup/followup)
	if(!followup)
		return null
	var/datum/ccpost_task_template/template = new /datum/ccpost_task_template/archived_followup
	var/datum/ccpost_tasking_order/order = create_task_order(template)
	qdel(template)
	order.source_order_code = followup.source_order_code
	order.assigned_department = followup.assigned_department
	order.assigned_contact = followup.assigned_contact
	order.assigned_role = followup.assigned_role
	order.subject = "Follow-Up: [followup.source_subject]"
	var/is_simulated_installation_task = followup.source_category == "Sector Records & Administration"
	if(is_simulated_installation_task)
		order.target_installation_code = followup.source_installation_code
		order.instruction = "Central Command requests an updated administrative review of archived order [followup.source_order_code] ([followup.source_subject]). Consult its retained documentation in Previous Orders. Recheck current installation status and history through the Remote Oversight Network and review applicable Sector Communications. Submit a stamped report identifying changes, unresolved questions, and recommended administrative action. This remote review does not require direct contact with installation personnel."
	else
		order.instruction = "Central Command requests an updated review of archived order [followup.source_order_code] ([followup.source_subject]). Consult its retained documentation in Previous Orders and obtain a current account from the responsible station department, where available. Submit a stamped report of verified changes, outstanding concerns and any unsuccessful contact attempts. Do not treat prior allegations as established findings."
	return order

/obj/machinery/computer/ccpost_tasking/proc/create_task_order(datum/ccpost_task_template/template)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !template)
		return null
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/order_code = "CC-[round_identifier]-[board.next_order_number]"
	board.next_order_number++
	return new /datum/ccpost_tasking_order(order_code, template)

/// Expire rather than silently deleting deferred paperwork. All results remain archived.
/obj/machinery/computer/ccpost_tasking/proc/expire_overdue_deferrals()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board)
		return
	for(var/datum/ccpost_tasking_order/order as anything in board.deferred_orders.Copy())
		if(world.time < order.deferral_expires_at)
			continue
		board.deferred_orders -= order
		order.status = CCPOST_TASK_STATUS_EXPIRED
		board.order_history.Insert(1, order)
		while(length(board.order_history) > board.max_history)
			var/datum/ccpost_tasking_order/oldest = board.order_history[length(board.order_history)]
			board.order_history.Cut(length(board.order_history), length(board.order_history) + 1)
			qdel(oldest)

/obj/machinery/computer/ccpost_tasking/proc/activate_deferred_order(datum/ccpost_tasking_order/order)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !order || !(order in board.deferred_orders))
		return FALSE
	if(board.current_order && board.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
		return FALSE
	if(world.time < order.deferred_until || world.time >= order.deferral_expires_at)
		return FALSE
	if(board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		archive_finished_order()
	board.deferred_orders -= order
	order.status = order.status_before_deferral
	board.current_order = order
	print_order(order)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/ccpost_tasking/proc/archive_finished_order()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board?.current_order || board.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
		return
	board.order_history.Insert(1, board.current_order)
	board.current_order = null
	while(length(board.order_history) > board.max_history)
		var/datum/ccpost_tasking_order/oldest = board.order_history[length(board.order_history)]
		board.order_history.Cut(length(board.order_history), length(board.order_history) + 1)
		qdel(oldest)

// ASSIGNMENT SCHEDULING

/// Give incident orders a fresh processing window when the Liaison becomes available.
/// While a separate order is active, queued incidents must not silently expire.
/// They still expire if suitable station personnel remain unavailable once the
/// terminal is free. This does not change the original public-event trigger.
/obj/machinery/computer/ccpost_tasking/proc/refresh_queued_incident_window()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !length(board.event_task_queue))
		return
	for(var/template_type in board.event_task_queue)
		board.event_task_expires["[template_type]"] = world.time + 60 MINUTES

/obj/machinery/computer/ccpost_tasking/proc/schedule_next_assignment(
	minimum_delay = 6 MINUTES,
	maximum_delay = 12 MINUTES
)
	if(assignment_timer)
		deltimer(assignment_timer)

	assignment_timer = addtimer(CALLBACK(src, PROC_REF(issue_assignment)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)

/obj/machinery/computer/ccpost_tasking/proc/issue_assignment()
	assignment_timer = null
	if(machine_stat & (NOPOWER | BROKEN))
		schedule_next_assignment(2 MINUTES, 4 MINUTES)
		return
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board)
		return
	expire_overdue_deferrals()
	if(board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		archive_finished_order()
	if(board.current_order)
		schedule_next_assignment(4 MINUTES, 6 MINUTES)
		return

	var/datum/ccpost_tasking_order/new_order
	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network
	var/datum/ccpost_task_template/template
	if(logistics_network?.contraband_audit_pending)
		var/datum/ccpost_task_template/audit = new /datum/ccpost_task_template/outpost_audit
		new_order = create_task_order(audit)
		audit.configure_order(new_order, logistics_network)
		qdel(audit)
	else
		// Elevated requests outrank resumed deferrals; expired events are never immortal.
		var/list/queued_events = board.event_task_queue.Copy()
		for(var/template_type in queued_events)
			var/expiry = board.event_task_expires["[template_type]"]
			if(!expiry || world.time >= expiry)
				board.event_task_queue -= template_type
				board.event_task_expires -= "[template_type]"
				continue
			var/datum/ccpost_task_template/event_template = new template_type
			if(event_template.is_eligible())
				template = event_template
				board.event_task_queue -= template_type
				board.event_task_expires -= "[template_type]"
				break
			qdel(event_template)
		if(!template)
			for(var/datum/ccpost_tasking_order/deferred as anything in board.deferred_orders.Copy())
				if(world.time >= deferred.deferred_until && world.time < deferred.deferral_expires_at)
					board.deferred_orders -= deferred
					deferred.status = deferred.status_before_deferral
					new_order = deferred
					break
		// Keep new follow-ups queued until their individual 20-30 minute waiting
		// periods have passed. A new routine assignment may issue in the meantime.
		if(!template && !new_order && length(board.followup_orders))
			for(var/datum/ccpost_task_followup/followup as anything in board.followup_orders.Copy())
				if(world.time < followup.ready_at)
					continue
				board.followup_orders -= followup
				new_order = make_followup_assignment(followup)
				qdel(followup)
				break
		if(!template && !new_order)
			var/list/routine_candidates = list()
			var/list/elevated_candidates = list()
			for(var/candidate_type in assignment_template_types)
				var/datum/ccpost_task_template/candidate = new candidate_type
				if(!candidate.event_only && candidate.is_eligible() && candidate_type != board.last_template_type)
					if(candidate.priority == CCPOST_TASK_PRIORITY_ROUTINE)
						routine_candidates += candidate_type
					else
						// Non-Routine general tasks are handled as the rarer selection.
						elevated_candidates += candidate_type
				qdel(candidate)
			var/chosen_type
			if(length(routine_candidates) && length(elevated_candidates))
				chosen_type = prob(80) ? pick(routine_candidates) : pick(elevated_candidates)
			else if(length(routine_candidates))
				chosen_type = pick(routine_candidates)
			else if(length(elevated_candidates))
				chosen_type = pick(elevated_candidates)
			if(chosen_type)
				template = new chosen_type
	if(template)
		new_order = create_task_order(template)
		template.configure_order(new_order, logistics_network)
		if(!attach_staffing_context(new_order, template))
			// A suitable employee may disconnect between eligibility and assignment.
			// Keep incident tasking queued until staffing is restored or it expires.
			if(template.event_only && !(template.type in board.event_task_queue))
				insert_event_task_by_priority(board, template.type)
				board.event_task_expires["[template.type]"] = world.time + 60 MINUTES
			qdel(new_order)
			new_order = null
		else
			board.last_template_type = template.type
		qdel(template)
	if(!new_order)
		schedule_next_assignment(2 MINUTES, 4 MINUTES)
		return
	board.current_order = new_order
	playsound(src, 'sound/machines/terminal/terminal_alert.ogg', vol = 45, vary = TRUE)
	visible_message(span_notice("[src] chimes. A Central Command tasking order is ready."))
	print_order(new_order)
	SStgui.update_uis(src)
	schedule_next_assignment()

// Keep bounded, printable copies of submitted findings even after the physical paper is transmitted.
/obj/machinery/computer/ccpost_tasking/proc/archive_submitted_report(datum/ccpost_tasking_order/order, obj/item/paper/report)
	if(!order || !report)
		return
	order.submitted_report_name = copytext(report.name, 1, 161)
	order.report_centcom_stamp_verified = report_has_centcom_stamp(report)
	// Preserve the real submitted PaperSheet contents before the physical original
	// is transmitted and deleted. copy() retains stamps, overlays, typography,
	// written sections and all native [____] field values.
	QDEL_NULL(order.archived_paper)
	order.archived_paper = report.copy(paper_type = /obj/item/paper/ccpost_tasking_order, location = null)
	if(order.archived_paper)
		order.archived_paper.name = order.submitted_report_name
	var/list/parts = list()
	var/obj/item/paper/ccpost_report_template/form = report
	var/is_template = istype(report, /obj/item/paper/ccpost_report_template)
	var/obj/item/paper/ccpost_installation_record/installation_record = report
	var/is_installation_record = istype(report, /obj/item/paper/ccpost_installation_record)
	if(is_installation_record)
		parts += "Authenticated Remote Oversight installation record: [installation_record.installation_code]."
	var/text_index = 0
	for(var/datum/paper_input/entry as anything in report.raw_text_inputs)
		text_index++
		// Skip machine-generated boilerplate in the plain-language archive summary.
		var/is_template_preprint = is_template && (text_index == 1 || (form.template_has_footer && text_index == length(report.raw_text_inputs)) || (!form.template_has_footer && text_index <= form.preprinted_text_count))
		if(is_template_preprint || (is_installation_record && text_index == 1))
			continue
		if(entry.raw_text)
			parts += entry.raw_text
	for(var/datum/paper_field/field as anything in report.raw_field_input_data)
		if(field.field_data?.raw_text)
			parts += "Field [field.field_index]: [field.field_data.raw_text]"
	order.submitted_report_text = copytext(jointext(parts, "\n"), 1, CCPOST_TASK_ARCHIVE_TEXT_LIMIT + 1)
	// The archive records a rendered facsimile, not a paper item or a reusable seal.
	// Physical stamp authentication is retained solely as the verified boolean.
	order.submitted_report_markup = ccpost_archive_render_submission(report)
	order.submitted_report_has_official_layout = istype(report, /obj/item/paper/ccpost_report_template) || istype(report, /obj/item/paper/ccpost_installation_record)

/// Produces a bounded, displayable PaperSheet facsimile of a submitted report.
/// Only the original machine-generated header is trusted as HTML; player text is
/// escaped to prevent archival pages from introducing untrusted markup.
/proc/ccpost_archive_render_submission(obj/item/paper/report)
	if(!report)
		return null
	var/obj/item/paper/ccpost_report_template/form = report
	var/is_template = istype(report, /obj/item/paper/ccpost_report_template)
	var/is_installation_record = istype(report, /obj/item/paper/ccpost_installation_record)
	var/rendered = ""
	var/text_index = 0
	var/field_index = 0
	// All current administrative forms use this PaperSheet input marker.
	var/field_marker = "\[_________________________\]"
	for(var/datum/paper_input/entry as anything in report.raw_text_inputs)
		text_index++
		if(!entry.raw_text)
			continue
		var/trusted_preprint = (is_template && (text_index == 1 || (form.template_has_footer && text_index == length(report.raw_text_inputs)) || (!form.template_has_footer && text_index <= form.preprinted_text_count))) || (is_installation_record && text_index == 1)
		if(!trusted_preprint)
			rendered += "<p>[ccpost_paper_paragraph(entry.raw_text)]</p>"
			continue
		var/raw = entry.raw_text
		var/cursor = 1
		while(TRUE)
			var/position = findtext(raw, field_marker, cursor)
			if(!position)
				break
			rendered += copytext(raw, cursor, position)
			var/field_value
			for(var/datum/paper_field/field as anything in report.raw_field_input_data)
				if(text2num(field.field_index) == field_index)
					field_value = field.field_data?.raw_text
					break
			rendered += length(field_value) ? "<u>[html_encode(field_value)]</u>" : "_________________________"
			field_index++
			cursor = position + length(field_marker)
		rendered += copytext(raw, cursor)
	// Handwritten or externally supplied papers may have fields without the
	// standard form marker. Preserve those answers separately rather than losing them.
	if(!is_template && length(report.raw_field_input_data))
		rendered += "<hr><h4>SUPPLEMENTARY FIELDS</h4>"
		for(var/datum/paper_field/field as anything in report.raw_field_input_data)
			if(field.field_data?.raw_text)
				rendered += ccpost_paper_value_field("Field [field.field_index]", field.field_data.raw_text)
	return copytext(rendered, 1, CCPOST_TASK_ARCHIVE_TEXT_LIMIT + 1)

// Shared printer presentation used by every Tasking Terminal document.
// PaperSheet renders Markdown via marked.js and then sanitizes HTML.
// Avoid CSS classes and inline styles: the sanitizer drops both.
// Restrict formatting to tags supported by PaperSheet (center, table, font, h3/h4, hr, br, etc.).
// Each document has ONE separator above its title and ONE below its subtitle.
/proc/ccpost_paper_header()
	var/header = "<center><table border='0' cellspacing='0' cellpadding='4' bgcolor='#0a1e2b'><tr><td><font color='#f0f0f0' size='6'><b>&#9701;</b></font></td><td><font color='#f0f0f0' size='7'><b>N</b></font></td><td><font color='#f0f0f0' size='6'><b>&#9699;</b></font></td></tr></table></center>"
	header += "<center><font size='2'><i>Central Command Liaison Office</i></font></center>"
	return header

/// Common document title + one rule either side of the title block.
/proc/ccpost_paper_document_heading(document_title, document_reference, descriptor)
	var/heading = "<hr><center><h3><u>[html_encode(uppertext(document_title))]</u></h3><font size='2'>[html_encode(document_reference)]"
	if(descriptor)
		heading += " | [html_encode(descriptor)]"
	heading += "</font></center><hr>"
	return heading

/// Fixed values use the same label rhythm as fillable fields.
/proc/ccpost_paper_value_field(label, value)
	if(isnull(value))
		value = "N/A"
	var/safe_value = html_encode("[value]")
	return "<b>[html_encode(label)]:</b> [safe_value]<br>"

/// Encodes arbitrary message body text before inserting it into a printed document.
/// This deliberately treats transmitted content as text, not as HTML markup.
/proc/ccpost_paper_paragraph(value)
	if(isnull(value))
		return "N/A"
	return replacetext(html_encode("[value]"), "\n", "<br>")

/// Narrow, printer-safe table helpers. Only supported PaperSheet HTML is used.
/proc/ccpost_paper_table_open()
	return "<table border='1' cellspacing='0' cellpadding='3'>"

/proc/ccpost_paper_table_row(list/cells, heading = FALSE)
	if(!islist(cells))
		return ""
	var/cell_tag = heading ? "th" : "td"
	var/output = "<tr>"
	for(var/cell in cells)
		var/safe_cell = html_encode("[cell]")
		output += "<[cell_tag]>[safe_cell]</[cell_tag]>"
	output += "</tr>"
	return output

/// PaperSheet turns these [____] sequences into actual text inputs.
/proc/ccpost_paper_blank_field(label)
	return "<b>[html_encode(label)]:</b> \[_________________________\]<br>"

/// Multiple native PaperSheet fillable fields, one per line. Each [____] is
/// an independent pen-editable input, not decorative empty whitespace.
/proc/ccpost_paper_writing_fields(heading, field_count = 4)
	var/section = "<h4><u>[html_encode(uppertext(heading))]</u></h4>"
	for(var/i in 1 to field_count)
		section += "\[________________________________\]<br>"
	return section + "<br>"

/// Consistent section heading with one separator above it.
/proc/ccpost_paper_section(heading)
	return "<hr><h4><u>[html_encode(uppertext(heading))]</u></h4>"

/// Footer text stays subdued, without introducing stacked rules.
/proc/ccpost_paper_note(note)
	return "<hr><font size='2'><i>[html_encode(note)]</i></font>"

/// Shared authority section, with real empty space *below* the stamp instruction.
/proc/ccpost_paper_stamp_area()
	return "<center><h3><u><code>AFFIRMING AUTHORITY</code></u></h3><font size='2'><u>(Please stamp below)</u></font></center><br><br><br><br><br><br><br><br><br><br>"

/obj/machinery/computer/ccpost_tasking/proc/print_archived_report(datum/ccpost_tasking_order/order)
	if(!order?.archived_paper)
		return FALSE
	// Clone the exact original PaperSheet data and visual stamp overlays.
	// Archived printouts remain task-order papers and cannot be resubmitted.
	var/obj/item/paper/ccpost_tasking_order/record = order.archived_paper.copy(
		paper_type = /obj/item/paper/ccpost_tasking_order,
		location = drop_location(),
	)
	if(!record)
		return FALSE
	record.name = "Archived [order.order_code] - [order.submitted_report_name]"
	record.update_appearance()
	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	return TRUE

// Reusable, fillable paperwork. Visitor Registration deliberately removed.
// Preprinted text does not count as user-written findings on submission.
/obj/machinery/computer/ccpost_tasking/proc/print_administrative_template(template_id)
	var/form_title
	var/form_code
	var/form_body
	switch(template_id)
		if("interview")
			form_title = "Personnel Interview Record"
			form_code = "CCL-101"
			form_body = ccpost_paper_blank_field("Interviewee")
			form_body += ccpost_paper_blank_field("Position / Department")
			form_body += ccpost_paper_blank_field("Interviewed By")
			form_body += ccpost_paper_blank_field("Date / Time")
			form_body += ccpost_paper_section("Statement & Observations")
			form_body += ccpost_paper_writing_fields("Reason for Interview", 3)
			form_body += ccpost_paper_writing_fields("Interview Statement", 7)
			form_body += ccpost_paper_writing_fields("Findings & Recommended Action", 5)
		if("inspection")
			form_title = "Departmental Inspection Checklist"
			form_code = "CCL-204"
			form_body = ccpost_paper_blank_field("Department / Area")
			form_body += ccpost_paper_blank_field("Inspector")
			form_body += ccpost_paper_blank_field("Department Representative")
			form_body += ccpost_paper_blank_field("Inspection Date")
			form_body += ccpost_paper_section("Inspection Findings")
			form_body += ccpost_paper_blank_field("Personnel Readiness")
			form_body += ccpost_paper_blank_field("Equipment / Facilities")
			form_body += ccpost_paper_blank_field("Safety Conditions")
			form_body += ccpost_paper_blank_field("Deficiencies Observed")
			form_body += ccpost_paper_blank_field("Corrective Action")
		if("incident")
			form_title = "Operational Incident Report"
			form_code = "CCL-301"
			form_body = ccpost_paper_blank_field("Incident Type")
			form_body += ccpost_paper_blank_field("Location")
			form_body += ccpost_paper_blank_field("Date / Time")
			form_body += ccpost_paper_blank_field("Reporting Officer")
			form_body += ccpost_paper_section("Incident Assessment")
			form_body += ccpost_paper_blank_field("Information Source")
			form_body += ccpost_paper_writing_fields("Incident Assessment & Findings", 8)
			form_body += ccpost_paper_writing_fields("Operational Impact & Recommended Action", 5)
		if("information")
			form_title = "Departmental Information Request"
			form_code = "CCL-402"
			form_body = ccpost_paper_blank_field("Requesting Officer")
			form_body += ccpost_paper_blank_field("Recipient / Position")
			form_body += ccpost_paper_blank_field("Recipient Department")
			form_body += ccpost_paper_blank_field("Requested By Date")
			form_body += ccpost_paper_section("Information Requested")
			form_body += ccpost_paper_blank_field("Purpose / Context")
			form_body += ccpost_paper_blank_field("Specific Question 1")
			form_body += ccpost_paper_blank_field("Specific Question 2")
			form_body += ccpost_paper_blank_field("Response / Reference")
			form_body += ccpost_paper_blank_field("Additional Follow-Up")
		if("frequencies")
			var/obj/item/paper/ccpost_frequency_reference/reference = new(drop_location())
			reference.name = "Central Command - Radio Frequency Reference"
			var/frequency_text = ccpost_paper_header()
			frequency_text += ccpost_paper_document_heading("Radio Frequency Reference", "CCL-R01", "Authorized Channels")
			frequency_text += ccpost_paper_value_field("Classification", "Internal")
			frequency_text += ccpost_paper_value_field("Priority", "Routine")
			frequency_text += ccpost_paper_value_field("Category", "Communications Reference")
			frequency_text += ccpost_paper_value_field("Subject", "Operational Radio Channels")
			frequency_text += ccpost_paper_value_field("Issued", station_time_timestamp())
			frequency_text += ccpost_paper_section("Authorized Channels")
			frequency_text += "<table border='1' cellspacing='0' cellpadding='4'><tr><th>Channel</th><th>Frequency</th></tr>"
			frequency_text += "<tr><td>Common</td><td>[FREQ_COMMON / 10]</td></tr>"
			frequency_text += "<tr><td>Command</td><td>[FREQ_COMMAND / 10]</td></tr>"
			frequency_text += "<tr><td>Security</td><td>[FREQ_SECURITY / 10]</td></tr>"
			frequency_text += "<tr><td>Engineering</td><td>[FREQ_ENGINEERING / 10]</td></tr>"
			frequency_text += "<tr><td>Medical</td><td>[FREQ_MEDICAL / 10]</td></tr>"
			frequency_text += "<tr><td>Science</td><td>[FREQ_SCIENCE / 10]</td></tr>"
			frequency_text += "<tr><td>Supply</td><td>[FREQ_SUPPLY / 10]</td></tr>"
			frequency_text += "<tr><td>Service</td><td>[FREQ_SERVICE / 10]</td></tr>"
			frequency_text += "<tr><td>CentCom</td><td>[FREQ_CENTCOM / 10]</td></tr>"
			frequency_text += "<tr><td>AI Private</td><td>[FREQ_AI_PRIVATE / 10]</td></tr>"
			frequency_text += "<tr><td>Entertainment</td><td>[FREQ_ENTERTAINMENT / 10]</td></tr>"
			frequency_text += "<tr><td>Uncommon</td><td>[FREQ_UNCOMMON / 10]</td></tr></table><br>"
			frequency_text += ccpost_paper_section("Classification Notice")
			frequency_text += "<b>RESTRICTED NANOTRASEN COMMUNICATIONS MATERIAL</b><br>"
			frequency_text += "This reference is furnished solely to authorized Central Command Liaison personnel for official operational use. Its contents are confidential corporate communications information. Unauthorized disclosure, reproduction, retransmission or distribution outside approved NanoTrasen channels is strictly prohibited.<br><br>"
			frequency_text += "Recipients are personally responsible for safeguarding this document against observation, loss and unauthorized access. Suspected compromise is to be reported through established Central Command security channels without delay."
			reference.add_raw_text(frequency_text)
			reference.update_appearance()
			playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
			return TRUE
	if(!form_title)
		return FALSE
	var/obj/item/paper/ccpost_report_template/report = new(drop_location())
	report.name = "Central Command - [form_title]"
	var/form_text = ccpost_paper_header()
	form_text += ccpost_paper_document_heading(form_title, "FORM [form_code]", "Shift Administrative Record")
	form_text += ccpost_paper_blank_field("Classification")
	form_text += ccpost_paper_blank_field("Priority")
	form_text += ccpost_paper_blank_field("Category")
	form_text += ccpost_paper_blank_field("Subject")
	form_text += ccpost_paper_blank_field("Issued")
	form_text += ccpost_paper_section("Record Details")
	form_text += form_body
	report.add_raw_text(form_text)
	var/footer_text = ccpost_paper_note("CENTRAL COMMAND RECORDS: Complete all applicable entries. Authenticate with the official seal before submission.")
	footer_text += ccpost_paper_stamp_area()
	report.add_raw_text(footer_text)
	report.preprinted_text_count = length(report.raw_text_inputs)
	report.template_has_footer = TRUE
	report.update_appearance()
	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	return TRUE

// TGUI

/obj/machinery/computer/ccpost_tasking/ui_status(mob/user)
	if(!ccpost_has_centcom_id(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/ccpost_tasking/ui_interact(mob/user, datum/tgui/ui)
	if(!ccpost_has_centcom_id(user))
		balloon_alert(user, "Central Command ID required")
		return
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostTasking", name)
		ui.open()

/obj/machinery/computer/ccpost_tasking/ui_data(mob/user)
	if(!ccpost_has_centcom_id(user))
		return list()
	var/list/data = list()

	data["submitted_report"] = report_to_ui_data(submitted_report)

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		data["current_order"] = null
		data["history"] = list()
		data["deferred_orders"] = list()
		data["queued_events"] = 0
		data["queued_priorities"] = list("Critical" = 0, "Priority" = 0, "Elevated" = 0, "Routine" = 0)
		data["queued_events_ready"] = 0
		data["queued_followups"] = 0
		return data

	data["current_order"] = tasking_board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED ? null : order_to_ui_data(tasking_board.current_order)

	expire_overdue_deferrals()
	var/list/history_data = list()
	if(tasking_board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		history_data += list(order_to_ui_data(tasking_board.current_order))

	for(var/datum/ccpost_tasking_order/order as anything in tasking_board.order_history)
		history_data += list(
			order_to_ui_data(order)
		)

	data["history"] = history_data
	var/list/deferred_data = list()
	for(var/datum/ccpost_tasking_order/deferred as anything in tasking_board.deferred_orders)
		var/list/serialized = order_to_ui_data(deferred)
		serialized["resume_in_seconds"] = max(0, round((deferred.deferred_until - world.time) / (1 SECONDS)))
		serialized["expires_in_seconds"] = max(0, round((deferred.deferral_expires_at - world.time) / (1 SECONDS)))
		deferred_data += list(serialized)
	data["deferred_orders"] = deferred_data
	data["queued_events"] = length(tasking_board.event_task_queue)
	// Reporting eligibility explains why a correctly hooked event can remain queued.
	// Do not reveal event identity or otherwise hidden round-event information.
	var/queued_events_ready = 0
	var/list/priority_counts = list("Critical" = 0, "Priority" = 0, "Elevated" = 0, "Routine" = 0)
	for(var/queued_type in tasking_board.event_task_queue)
		var/datum/ccpost_task_template/queued_template = new queued_type
		if(queued_template.is_eligible())
			queued_events_ready++
		priority_counts[queued_template.priority] = (priority_counts[queued_template.priority] || 0) + 1
		qdel(queued_template)
	data["queued_events_ready"] = queued_events_ready
	data["queued_priorities"] = priority_counts
	data["queued_followups"] = length(tasking_board.followup_orders)
	return data

/// A PaperSheet-compatible serialized snapshot for formatting in the archive viewer.
/// Only completed history contains an archived_paper; no extra object is created.
/proc/ccpost_archived_paper_to_ui(obj/item/paper/paper)
	if(!paper)
		return null
	var/list/text_entries = list()
	for(var/datum/paper_input/entry as anything in paper.raw_text_inputs)
		text_entries += list(entry.to_list())
	var/list/field_entries = list()
	for(var/datum/paper_field/field as anything in paper.raw_field_input_data)
		field_entries += list(field.to_list())
	return list("raw_text_input" = text_entries, "raw_field_input" = field_entries)

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
		"completed_at" = order.completed_at,
		"submission_type" = order.submission_type,
		"target_installation_code" = order.target_installation_code,
		"submitted_report_name" = order.submitted_report_name,
		"submitted_report_text" = order.submitted_report_text,
		"submitted_report_markup" = order.submitted_report_markup,
		"archived_paper" = ccpost_archived_paper_to_ui(order.archived_paper),
		"source_order_code" = order.source_order_code,
		"assigned_contact" = order.assigned_contact,
		"assigned_role" = order.assigned_role,
		"deferral_count" = order.deferral_count,
		"deferral_reason" = order.deferral_reason,
		"deferred_by" = order.deferred_by,
		"report_stamp_verified" = order.report_centcom_stamp_verified
	)


/obj/machinery/computer/ccpost_tasking/ui_act(
	action,
	list/params,
	datum/tgui/ui,
	datum/ui_state/state
)
	if(!ccpost_has_centcom_id(ui?.user))
		return TRUE
	. = ..()

	if(.)
		return

	var/mob/user = ui.user

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		return FALSE

	switch(action)

		if("defer_order")
			var/datum/ccpost_tasking_order/order = tasking_board.current_order
			if(!order || order.status == CCPOST_TASK_STATUS_COMPLETED || order.priority == CCPOST_TASK_PRIORITY_CRITICAL || order.template_id == CCPOST_TASK_AUDIT_TEMPLATE_ID)
				balloon_alert(user, "order cannot be deferred")
				return TRUE
			if(submitted_report || order.deferral_count >= tasking_board.max_deferrals_per_order || length(tasking_board.deferred_orders) >= tasking_board.max_deferred_orders)
				balloon_alert(user, "deferral unavailable")
				return TRUE
			var/reason = params["reason"]
			if(!(reason in list("Awaiting staffing", "Awaiting documents", "Situation unresolved", "Additional authorization")))
				balloon_alert(user, "invalid deferral reason")
				return TRUE
			order.status_before_deferral = order.status
			order.deferral_count++
			order.deferred_by = user.name
			order.deferred_at = station_time_timestamp()
			order.deferred_until = world.time + 5 MINUTES
			order.deferral_expires_at = world.time + 25 MINUTES
			order.deferral_reason = reason
			order.status = CCPOST_TASK_STATUS_DEFERRED
			tasking_board.deferred_orders += order
			tasking_board.current_order = null
			if(length(tasking_board.event_task_queue))
				refresh_queued_incident_window()
				schedule_next_assignment(20 SECONDS, 40 SECONDS)
			else
				schedule_next_assignment(40 SECONDS, 90 SECONDS)
			balloon_alert(user, "order deferred")
			SStgui.update_uis(src)
			return TRUE

		if("resume_deferred")
			var/order_code = params["order_code"]
			for(var/datum/ccpost_tasking_order/deferred as anything in tasking_board.deferred_orders)
				if(deferred.order_code != order_code)
					continue
				if(!activate_deferred_order(deferred))
					balloon_alert(user, "order not ready")
				else
					balloon_alert(user, "order resumed")
				return TRUE
			return TRUE

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

			playsound(src, 'sound/machines/terminal/terminal_alert.ogg', vol = 25, vary = FALSE)

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
				'sound/machines/terminal/terminal_alert.ogg',
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

			var/rejection_reason = report_validation_issue(submitted_report)
			if(rejection_reason)
				balloon_alert(user, rejection_reason)
				return TRUE

			var/obj/item/paper/accepted_report = submitted_report
			submitted_report = null
			archive_submitted_report(tasking_board.current_order, accepted_report)
			queue_report_followup(tasking_board.current_order)
			if(tasking_board.current_order.submission_type == CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD)
				var/datum/ccpost_sector_installation/certified_installation = GLOB.ccpost_sector_network.get_installation_by_code(tasking_board.current_order.target_installation_code)
				if(certified_installation)
					GLOB.ccpost_sector_network.add_installation_history(certified_installation, "ADMINISTRATION", "Record certified: [tasking_board.current_order.order_code]", "Certified by [user.name] through the Liaison Tasking Terminal. No operational changes were applied.")

			tasking_board.current_order.status = CCPOST_TASK_STATUS_COMPLETED
			tasking_board.current_order.completed_by = user.name
			tasking_board.current_order.completed_at = station_time_timestamp()

			// Issue Operational Allocation and any applicable
			// departmental budget grant.
			apply_task_rewards(
				tasking_board.current_order,
				user
			)
			if(length(tasking_board.event_task_queue))
				// Incident orders outrank routine work after this order is resolved.
				refresh_queued_incident_window()
				schedule_next_assignment(20 SECONDS, 40 SECONDS)
			else if(length(tasking_board.followup_orders))
				schedule_next_assignment(2 MINUTES, 4 MINUTES)

			// Supporting documentation has been transmitted and is no
			// longer physically available at the outpost.
			qdel(accepted_report)

			playsound(
				src,
				'sound/machines/terminal/terminal_alert.ogg',
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

		if("print_template")
			if(!COOLDOWN_FINISHED(src, print_cooldown))
				balloon_alert(user, "printer cooling down")
				return TRUE
			if(print_administrative_template(params["template_id"]))
				COOLDOWN_START(src, print_cooldown, 5 SECONDS)
				balloon_alert(user, "template printed")
			else
				balloon_alert(user, "unknown template")
			return TRUE

		if("print_archived_report")
			if(!COOLDOWN_FINISHED(src, print_cooldown))
				balloon_alert(user, "printer cooling down")
				return TRUE
			var/datum/ccpost_tasking_order/archived_order = find_order(params["order_code"])
			if(print_archived_report(archived_order))
				COOLDOWN_START(src, print_cooldown, 5 SECONDS)
				balloon_alert(user, "archived report printed")
			else
				balloon_alert(user, "no archived report available")
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
	for(var/datum/ccpost_tasking_order/deferred as anything in tasking_board.deferred_orders)
		if(deferred.order_code == order_code)
			return deferred

	return null

// Paper Printing

/obj/machinery/computer/ccpost_tasking/proc/print_order(
	datum/ccpost_tasking_order/order
)
	if(!order)
		return

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice("[src] prints a Central Command tasking order."))

	var/obj/item/paper/ccpost_tasking_order/assignment_paper = new /obj/item/paper/ccpost_tasking_order(drop_location())
	assignment_paper.name = "Central Command Tasking Order - [order.order_code]"

	var/assignment_text = ccpost_paper_header()
	assignment_text += ccpost_paper_document_heading("Central Command Tasking Order", order.order_code, "Official Directive")
	assignment_text += ccpost_paper_value_field("Classification", "Internal")
	assignment_text += ccpost_paper_value_field("Priority", order.priority)
	assignment_text += ccpost_paper_value_field("Category", order.category)
	assignment_text += ccpost_paper_value_field("Subject", order.subject)
	assignment_text += ccpost_paper_value_field("Issued", order.issued_at)
	assignment_text += ccpost_paper_value_field("Status", order.status)

	assignment_text += ccpost_paper_section("Instructions to Liaison Personnel")
	assignment_text += replacetext(html_encode(order.instruction), "\n", "<br>")
	assignment_text += "<br><br>Verify available information and record findings impartially for Central Command review.<br>"
	if(order.submission_type == CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD)
		assignment_text += "<br><b>Completion Requirement:</b> Submit the exact stamped Remote Oversight Network installation record.<br>"
	else
		assignment_text += "<br><b>Completion Requirement:</b> Submit a separate written report bearing an official Central Command stamp.<br>"
	assignment_text += "<br><font size='2'><i>Direct intervention is not authorized by this order alone.</i></font>"

	assignment_text += ccpost_paper_section("Administrative Record")
	assignment_text += ccpost_paper_value_field("Acknowledged By", order.acknowledged_by)
	assignment_text += ccpost_paper_value_field("Acknowledged At", order.acknowledged_at)
	assignment_text += ccpost_paper_value_field("Completed By", order.completed_by)
	assignment_text += ccpost_paper_value_field("Completed At", order.completed_at)
	assignment_text += ccpost_paper_note("Official tasking directive. This document is not accepted as completion evidence.")

	assignment_paper.add_raw_text(assignment_text)
	assignment_paper.update_appearance()

#undef CCPOST_TASK_STATUS_PENDING
#undef CCPOST_TASK_STATUS_ACKNOWLEDGED
#undef CCPOST_TASK_STATUS_COMPLETED
#undef CCPOST_TASK_STATUS_DEFERRED
#undef CCPOST_TASK_STATUS_EXPIRED
#undef CCPOST_TASK_PRIORITY_ROUTINE
#undef CCPOST_TASK_PRIORITY_ELEVATED
#undef CCPOST_TASK_PRIORITY_PRIORITY
#undef CCPOST_TASK_PRIORITY_CRITICAL
#undef CCPOST_AUDIT_MINOR
#undef CCPOST_AUDIT_SIGNIFICANT
#undef CCPOST_AUDIT_SEVERE
#undef CCPOST_TASK_AUDIT_TEMPLATE_ID
#undef CCPOST_TASK_SUBMISSION_REPORT
#undef CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD
#undef CCPOST_TASK_ARCHIVE_TEXT_LIMIT
