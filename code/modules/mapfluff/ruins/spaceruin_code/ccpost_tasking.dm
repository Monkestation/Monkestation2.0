/// Central Command Liaison Outpost tasking system.

#define CCPOST_TASK_STATUS_PENDING "Pending"
#define CCPOST_TASK_STATUS_ACKNOWLEDGED "Acknowledged"
#define CCPOST_TASK_STATUS_COMPLETED "Completed"
#define CCPOST_TASK_STATUS_DEFERRED "Deferred"
#define CCPOST_TASK_STATUS_ON_HOLD "On Hold"
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

#define CCPOST_TASK_FIRST_MIN 4 MINUTES
#define CCPOST_TASK_FIRST_MAX 6 MINUTES
#define CCPOST_TASK_INTERVAL_MIN 12 MINUTES
#define CCPOST_TASK_INTERVAL_MAX 18 MINUTES
#define CCPOST_TASK_RETRY_MIN 3 MINUTES
#define CCPOST_TASK_RETRY_MAX 5 MINUTES
#define CCPOST_TASK_INCIDENT_MIN 1 MINUTES
#define CCPOST_TASK_INCIDENT_MAX 2 MINUTES
#define CCPOST_TASK_ATMOS_GRACE 20 MINUTES
#define CCPOST_TASK_INTERVIEW_HISTORY 5
// Independent from population: avoid issuing similar random paperwork back-to-back.
#define CCPOST_TASK_FAMILY_COOLDOWN 12 MINUTES
#define CCPOST_TASK_INTERNAL_FAMILY_COOLDOWN 20 MINUTES
#define CCPOST_TASK_FAMILY_HISTORY 2
#define CCPOST_TASK_VARIETY_RETRY_MIN 3 MINUTES
#define CCPOST_TASK_VARIETY_RETRY_MAX 5 MINUTES
#define CCPOST_TASK_CONTACT_SSD_GRACE 90 SECONDS
#define CCPOST_TASK_DEPARTMENT_COOLDOWN 30 MINUTES
#define CCPOST_TASK_SHARED_ARCHIVE_LIMIT 100
#define CCPOST_TASK_REASSIGN_GRACE 10 MINUTES

// These are relative percentages of eligible routine assignments; Priority/Critical event-triggered tasks retain their event-based priorities. Each list should total 100.
GLOBAL_LIST_INIT(ccpost_task_category_weights, list(
	"Command Oversight" = 10,
	"Security Oversight" = 8,
	"Infrastructure Oversight" = 14,
	"Communications Oversight" = 4,
	"Medical Oversight" = 10,
	"Operational Oversight" = 11,
	"Administrative Oversight" = 9,
	"General Oversight" = 4,
	"Audits & Inspections" = 8,
	"Personnel & Civilian Liaison" = 5,
	"Sector Records & Administration" = 2,
	"Research Oversight" = 6,
	"Supply Chain Oversight" = 5,
	"Service Oversight" = 4
))

GLOBAL_LIST_INIT(ccpost_task_priority_weights, list(
	CCPOST_TASK_PRIORITY_ROUTINE = 72,
	CCPOST_TASK_PRIORITY_ELEVATED = 23,
	CCPOST_TASK_PRIORITY_PRIORITY = 4,
	CCPOST_TASK_PRIORITY_CRITICAL = 1
))


/datum/ccpost_task_template
	var/template_id
	var/category
	var/subject
	var/priority = CCPOST_TASK_PRIORITY_ROUTINE
	var/instruction
	var/department_reward_id
	/// Additional departments may be evaluated independently if they actually participated.
	/// These are authorized grant recipients, NOT alternative interview contacts.
	var/list/additional_grant_departments
	/// Per-template funding factors keep cross-departmental assignments balanced.
	var/primary_grant_factor = 1
	var/secondary_grant_factor = 0.65
	var/submission_type = CCPOST_TASK_SUBMISSION_REPORT
	/// Event-only templates cannot be selected by the general routine scheduler.
	var/event_only = FALSE
	/// Departmental budget accounts that can supply a suitable interview subject.
	var/list/required_staff_accounts
	/// Exclude these departments from otherwise unrestricted civilian interviews.
	var/list/excluded_staff_accounts
	/// Choose a staff member from any currently occupied station department.
	var/any_station_staff = FALSE
	var/selection_weight = 100
	/// Semantically equivalent work shares a family even when the template ID differs.
	/// Do not use the display category here; unrelated assignments may share categories.
	var/rotation_family

/datum/ccpost_task_template/proc/get_rotation_family()
	return rotation_family ? rotation_family : template_id

/// Assigned station personnel remain on the roster while SSD. Use the full mob
/// registry, not the connected-player list; only real assigned, living station
/// employees count (not ghost roles, bodies without a mind or outpost staff).
/datum/ccpost_task_template/proc/get_available_staff()
	var/list/available = list()
	for(var/mob/living/carbon/human/employee as anything in GLOB.mob_list)
		if(!ishuman(employee) || QDELETED(employee) || employee.stat == DEAD || !is_station_level(employee.z))
			continue
		var/datum/mind/employee_mind = employee.mind
		var/datum/job/job = employee_mind?.assigned_role
		if(!job || employee_mind.current != employee || job.faction != FACTION_STATION)
			continue
		var/account = job.paycheck_department
		if(length(required_staff_accounts) && !(account in required_staff_accounts))
			continue
		if(length(excluded_staff_accounts) && (account in excluded_staff_accounts))
			continue
		available += employee
	return available

/// Prefer personnel available to answer immediately, but do not erase SSD
/// employees from assignment/staffing eligibility when they are the only option.
/proc/ccpost_prefer_contactable_staff(list/staff)
	var/list/reachable = list()
	for(var/mob/living/carbon/human/employee as anything in staff)
		if(employee.client)
			reachable += employee
	return length(reachable) ? reachable : staff

/datum/ccpost_task_template/proc/is_eligible()
	if(any_station_staff || length(required_staff_accounts) || length(excluded_staff_accounts))
		return length(get_available_staff()) > 0
	return TRUE

/datum/ccpost_task_template/proc/configure_order(datum/ccpost_tasking_order/order, datum/ccpost_logistics_network/logistics_network)
	return

/datum/ccpost_task_template/command_status
	template_id = "command_status"
	rotation_family = "station_command"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "General Operational Status"
	instruction = "Request a concise shift-status report from Command identifying the station alert posture, unresolved critical concerns, and whether any departments need administrative support. Record one confirmed priority or explicitly report that none was identified."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_coordination
	template_id = "command_coordination"
	rotation_family = "station_command"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "Departmental Coordination Review"
	instruction = "Request examples of interdepartmental requests handled this shift. Assess whether escalation channels and response responsibilities were clear, and document specific communication failures only where supported by evidence."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_concern
	template_id = "command_concern"
	rotation_family = "station_command"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "Command Concern Inquiry"
	instruction = "Ask Command to nominate its highest unresolved operational risk, identify who is responsible for follow-up, and state what would constitute resolution. Corroborate key details where practical and distinguish plans from completed action."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/security_arrests
	template_id = "security_arrests"
	rotation_family = "station_security"
	required_staff_accounts = list(ACCOUNT_SEC)
	category = "Audits & Inspections"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Arrest Procedure Review"
	instruction = "Review Security's handling of recent arrests and determine whether appropriate procedure appears to be followed. Distinguish confirmed information from allegation or speculation."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/security_investigations
	template_id = "security_investigations"
	rotation_family = "station_security"
	required_staff_accounts = list(ACCOUNT_SEC)
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Security Oversight"
	subject = "Unresolved Investigation Review"
	instruction = "Contact Security and request an overview of any unresolved high-priority investigations. Determine whether any require additional Central Command monitoring."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/engineering_status
	template_id = "engineering_status"
	rotation_family = "station_engineering"
	required_staff_accounts = list(ACCOUNT_ENG)
	category = "Infrastructure Oversight"
	subject = "Engineering Status Assessment"
	instruction = "Request Engineering readings or a concise operational account for power, atmosphere, hull integrity, and telecommunications. Identify confirmed deficiencies, current mitigations, and which systems require follow-up."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/engineering_sustainability
	template_id = "engineering_sustainability"
	rotation_family = "station_engineering"
	required_staff_accounts = list(ACCOUNT_ENG)
	category = "Infrastructure Oversight"
	subject = "Continued Operations Assessment"
	instruction = "Ask Engineering to assess long-term station endurance using power reserves, atmospheric support, critical spare parts, and unresolved maintenance. Document credible failure points and the proposed contingency for each."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/communications
	template_id = "communications"
	additional_grant_departments = list(ACCOUNT_ENG)
	secondary_grant_factor = 0.8
	rotation_family = "station_communications"
	selection_weight = 35
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	category = "Communications Oversight"
	subject = "Communications Integrity Review"
	instruction = "Compare two relevant station communication records or departmental accounts where available. Ask Command to reconcile specific contradictory reports, and consult Engineering only if it contributed technical evidence. Mark facts that cannot be independently confirmed."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/communications_outage
	template_id = "communications_outage"
	rotation_family = "station_communications"
	selection_weight = 35
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Communications Oversight"
	subject = "Communications Reliability Inquiry"
	instruction = "Request an Engineering telecommunications status report, including verified outages, restoration efforts, and unresolved faults. If no disruption occurred, document current link health and how it was assessed rather than inventing an outage."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/medical_status
	template_id = "medical_status"
	rotation_family = "station_medical"
	required_staff_accounts = list(ACCOUNT_MED)
	category = "Medical Oversight"
	subject = "Personnel Condition Report"
	instruction = "Request Medical's current treatment capacity, staffing coverage, critical supplies, and any unfilled urgent needs. Identify one supported service risk or confirm that no material concerns were reported; do not request individual patient records."
	department_reward_id = ACCOUNT_MED

/datum/ccpost_task_template/explosions
	template_id = "explosions"
	additional_grant_departments = list(ACCOUNT_SEC)
	secondary_grant_factor = 0.8
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG, ACCOUNT_SEC)
	event_only = TRUE
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	category = "Incident Review"
	subject = "Explosive Incident Inquiry"
	instruction = "Following a verified explosion report, obtain Engineering findings on structural or equipment damage and Security findings on potential foul play where each department participated. Record the event location, confirmed effects, remaining hazards, and uncertainties without presuming sabotage."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/sabotage_review
	template_id = "sabotage_review"
	additional_grant_departments = list(ACCOUNT_CMD)
	secondary_grant_factor = 0.6
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC)
	event_only = TRUE
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Incident Review"
	subject = "Sabotage Assessment"
	instruction = "Request Security's evidence summary and, if Command substantively assisted, its operational context. Distinguish sabotage from negligence or equipment failure and record unresolved evidence without assigning guilt without proof."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/department_status
	template_id = "department_status"
	rotation_family = "station_department_reviews"
	any_station_staff = TRUE
	category = "Operational Oversight"
	subject = "Department Readiness Review"
	instruction = "Select a station department and compare its assigned staffing with its current operational obligations. Document concrete service gaps, available contingency support, and any limitations caused by unavailable personnel. Do not confuse temporary unavailability with an unfilled position."

/datum/ccpost_task_template/emergency_readiness
	template_id = "emergency_readiness"
	additional_grant_departments = list(ACCOUNT_SEC, ACCOUNT_ENG)
	secondary_grant_factor = 0.55
	rotation_family = "station_emergency_readiness"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC, ACCOUNT_ENG)
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Operational Oversight"
	subject = "Emergency Preparedness Review"
	instruction = "Ask Command to describe emergency coordination responsibilities and request Security or Engineering input where they actively contributed. Review evacuation readiness, emergency equipment, and escalation routes; document verified gaps without staging an incident."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/conflicting_accounts
	template_id = "conflicting_accounts"
	additional_grant_departments = list(ACCOUNT_SEC)
	secondary_grant_factor = 0.65
	rotation_family = "station_report_verification"
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC)
	category = "Administrative Oversight"
	subject = "Report Consistency Review"
	instruction = "Compare Command records with relevant departmental incident reports; seek Security clarification only if it contributed independently. Cite each contradiction, distinguish dates from estimates, and note unresolved differences rather than inventing a definitive narrative."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/monitoring_assessment
	template_id = "monitoring_assessment"
	rotation_family = "station_command"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Administrative Oversight"
	subject = "Monitoring Requirement Assessment"
	instruction = "Review available station alerts and Command reports and decide whether enhanced remote observation is justified. Cite concrete indicators, identify a reasonable review interval, and record whether normal monitoring remains sufficient."

/datum/ccpost_task_template/outpost_audit
	template_id = CCPOST_TASK_AUDIT_TEMPLATE_ID
	rotation_family = "outpost_internal"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Internal Compliance"
	subject = "Liaison Outpost Compliance Audit"
	instruction = "Central Command Internal Compliance has selected this installation for a routine audit. Review the outpost's Operational Allocation ledger, freight requisition history, recent Sector Communications responses, and completed tasking records. Submit a concise account of any discrepancies, unexplained expenditures, missing documentation, or procedural violations."

/datum/ccpost_task_template/developing_situation
	template_id = "developing_situation"
	rotation_family = "station_emergency_readiness"
	any_station_staff = TRUE
	category = "General Oversight"
	subject = "Developing Situation Review"
	instruction = "Identify a credible developing operational concern, if any. Request an update from an appropriate station contact, assess whether it remains active, and record the next expected action. If no concern is substantiated, submit a no-findings report."


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
	rotation_family = "station_communications"
	category = "Communications Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Telecommunications Infrastructure Incident"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_ENG)
	department_reward_id = ACCOUNT_ENG
	instruction = "A disruption has been detected at a station telecommunications hub. Ask Engineering to confirm whether station communications were affected and what corrective work is underway. Avoid reporting a complete outage unless independently verified."


/// The bridge only queues these AFTER their event has issued a public announcement.
/datum/ccpost_task_template/public_radiation_storm
	template_id = "public_radiation_storm"
	additional_grant_departments = list(ACCOUNT_ENG)
	secondary_grant_factor = 0.7
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
	additional_grant_departments = list(ACCOUNT_MED)
	secondary_grant_factor = 0.65
	category = "Incident Review"
	priority = CCPOST_TASK_PRIORITY_PRIORITY
	subject = "Announced Radiation Leak Inquiry"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_MED, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "A radiation leak has been publicly announced on the station. Contact Engineering or Medical when safe, establish the reported location, confirm whether the leak has been isolated, and document any known exposure or operational disruption. Do not speculate about the cause before station personnel provide evidence."

/datum/ccpost_task_template/public_communications_blackout
	template_id = "public_communications_blackout"
	rotation_family = "station_communications"
	category = "Communications Oversight"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	subject = "Announced Communications Disruption Review"
	event_only = TRUE
	required_staff_accounts = list(ACCOUNT_ENG, ACCOUNT_CMD)
	department_reward_id = ACCOUNT_ENG
	instruction = "Central Command received a public station warning of an impending communications disruption. When channels are available, contact Engineering or Command to confirm the actual duration, affected systems, and restoration status. Record any continuing operational limitations. Do not infer a completed outage from the warning alone."
/// confirmed, publicly announced event reviews. None appear in random routine tasking.
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
	additional_grant_departments = list(ACCOUNT_ENG)
	secondary_grant_factor = 0.7
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
	rotation_family = "station_department_reviews"
	any_station_staff = TRUE
	category = "Audits & Inspections"
	subject = "Departmental Operational Audit"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	instruction = "Select an operating station department and request its operational documentation, personnel coverage, unresolved safety concerns and outstanding maintenance needs. Interview a responsible employee, distinguish verified findings from unsupported claims, and report any procedural deficiencies. Document a lack of available staff if applicable."

/datum/ccpost_task_template/security_detention
	template_id = "security_detention"
	rotation_family = "station_security"
	required_staff_accounts = list(ACCOUNT_SEC)
	category = "Audits & Inspections"
	subject = "Detention Procedures Inspection"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	instruction = "Contact the Warden or Head of Security and request a procedural account of detention and prisoner-property handling. Inspect available records if voluntarily provided, identify any discrepancies, and document the evidence. This task does not authorize searches, arrests or command over station Security."
	department_reward_id = ACCOUNT_SEC

/datum/ccpost_task_template/service_sanitation
	template_id = "service_sanitation"
	rotation_family = "station_service_review"
	required_staff_accounts = list(ACCOUNT_SRV)
	category = "Audits & Inspections"
	subject = "Service Sanitation Review"
	instruction = "Ask Service personnel to outline food-handling and sanitation controls, recent verified concerns, and corrective work. Where no Service representative is available, document attempted contact and seek an operational account from Command without inventing violations."
	department_reward_id = ACCOUNT_SRV

/datum/ccpost_task_template/cargo_reconciliation
	template_id = "cargo_reconciliation"
	rotation_family = "station_cargo_review"
	required_staff_accounts = list(ACCOUNT_CAR)
	category = "Audits & Inspections"
	subject = "Cargo Expenditure Reconciliation"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	instruction = "Ask Cargo to reconcile a recent order or procurement period against delivery records. Identify incomplete shipments and exceptional expenditures, note their documented purposes, and distinguish accounting delays from unsupported allegations of misconduct."
	department_reward_id = ACCOUNT_CAR

/datum/ccpost_task_template/civilian_interview
	template_id = "civilian_interview"
	rotation_family = "station_personnel"
	selection_weight = 45
	excluded_staff_accounts = list(ACCOUNT_CMD, ACCOUNT_SEC)
	any_station_staff = TRUE
	category = "Personnel & Civilian Liaison"
	subject = "Civilian Services Interview"
	instruction = "Interview an eligible civilian or departmental employee about specific working conditions, resource gaps, and obstacles to assigned work. Attribute statements to the source, separate observations from opinions, and recommend proportionate follow-up. If no interview can be obtained, document attempted contact."


// Additional department-focused reports. Each has a distinct evidence request and
// shares a rotation family only with genuinely similar work.
/datum/ccpost_task_template/science_experimental_safety
	template_id = "science_experimental_safety"
	rotation_family = "science_safety"
	required_staff_accounts = list(ACCOUNT_SCI)
	category = "Research Oversight"
	subject = "Experimental Safety Assessment"
	instruction = "Ask Research to identify its currently active experiments, applicable containment precautions, and any documented safety exceptions. Obtain a concise account of corrective actions for verified concerns. Do not require classified formulas or entry to restricted laboratories."
	department_reward_id = ACCOUNT_SCI

/datum/ccpost_task_template/science_robotics
	template_id = "science_robotics"
	rotation_family = "science_robotics"
	required_staff_accounts = list(ACCOUNT_SCI)
	category = "Research Oversight"
	subject = "Robotics Operational Review"
	instruction = "Request a Robotics status report covering current cyborg availability, maintenance needs, service interruptions, and any properly documented safety incidents. Distinguish equipment issues from unverified misconduct claims."
	department_reward_id = ACCOUNT_SCI

/datum/ccpost_task_template/science_progress
	template_id = "science_progress"
	rotation_family = "science_progress"
	required_staff_accounts = list(ACCOUNT_SCI)
	category = "Research Oversight"
	subject = "Research Progress Inquiry"
	instruction = "Ask Research to summarize completed work, active priorities, and resource constraints affecting the shift. Record at least one verifiable milestone or explain why progress cannot yet be assessed. Do not demand proprietary research data."
	department_reward_id = ACCOUNT_SCI

/datum/ccpost_task_template/medical_triage
	template_id = "medical_triage"
	rotation_family = "medical_preparedness"
	required_staff_accounts = list(ACCOUNT_MED)
	category = "Medical Oversight"
	subject = "Emergency Triage Preparedness"
	instruction = "Ask Medical to describe its response plan for several simultaneous casualties, available treatment areas, staffing coverage, and identified bottlenecks. Recommend feasible improvements without staging a real emergency."
	department_reward_id = ACCOUNT_MED

/datum/ccpost_task_template/medical_pharmaceuticals
	template_id = "medical_pharmaceuticals"
	rotation_family = "medical_inventory"
	required_staff_accounts = list(ACCOUNT_MED)
	category = "Medical Oversight"
	subject = "Pharmaceutical Accountability Review"
	instruction = "Request a Medical review of controlled medication storage, inventory accountability, and any recorded discrepancies. Document verified shortages or procedural gaps without requesting patient-specific prescriptions or confidential records."
	department_reward_id = ACCOUNT_MED

/datum/ccpost_task_template/cargo_reliability
	template_id = "cargo_reliability"
	rotation_family = "cargo_procurement"
	required_staff_accounts = list(ACCOUNT_CAR)
	category = "Supply Chain Oversight"
	subject = "Supply Chain Reliability Assessment"
	instruction = "Review Cargo's outstanding orders and delivery records with Supply personnel. Identify essential requests that remain unfulfilled, their practical impact, and any documented obstacles. Distinguish delays from canceled or completed shipments."
	department_reward_id = ACCOUNT_CAR

/datum/ccpost_task_template/cargo_emergency_procurement
	template_id = "cargo_emergency_procurement"
	rotation_family = "cargo_readiness"
	required_staff_accounts = list(ACCOUNT_CAR)
	category = "Supply Chain Oversight"
	subject = "Emergency Procurement Preparedness"
	instruction = "Ask Cargo to explain its procedure for urgent departmental requests, including authorization, funding, delivery priorities, and communication of unavailable stock. Identify practical changes that would improve response readiness."
	department_reward_id = ACCOUNT_CAR

/datum/ccpost_task_template/service_welfare
	template_id = "service_welfare"
	rotation_family = "service_welfare"
	required_staff_accounts = list(ACCOUNT_SRV)
	category = "Service Oversight"
	subject = "Crew Welfare Assessment"
	instruction = "Consult Service personnel about meal access, recreational amenities, crew feedback, and unresolved welfare concerns. Distinguish observed shortages from personal preferences and document realistic corrective actions."
	department_reward_id = ACCOUNT_SRV

/datum/ccpost_task_template/service_facilities
	template_id = "service_facilities"
	rotation_family = "service_facilities"
	required_staff_accounts = list(ACCOUNT_SRV)
	category = "Service Oversight"
	subject = "Civilian Facilities Inspection"
	instruction = "Review the condition of publicly accessible station amenities with Service and, where necessary, Engineering. Identify verified maintenance defects, sanitation concerns, and proposed repairs without conducting unauthorized entry or equipment sabotage."
	department_reward_id = ACCOUNT_SRV
	additional_grant_departments = list(ACCOUNT_ENG)
	secondary_grant_factor = 0.6

/datum/ccpost_task_template/personnel_visitors
	template_id = "personnel_visitors"
	rotation_family = "personnel_visitors"
	any_station_staff = TRUE
	excluded_staff_accounts = list(ACCOUNT_CMD)
	category = "Personnel & Civilian Liaison"
	subject = "Visitor Relations Review"
	instruction = "Ask available station personnel how arrivals and authorized visitors receive directions, assistance, and access to public facilities. Record any confirmed points of confusion or unmet needs without collecting private visitor information."

/datum/ccpost_task_template/personnel_feedback
	template_id = "personnel_feedback"
	rotation_family = "personnel_feedback"
	any_station_staff = TRUE
	category = "Personnel & Civilian Liaison"
	subject = "Interdepartmental Personnel Feedback"
	instruction = "Gather feedback from available employees on how requests are handed between departments. Compare at least two perspectives when feasible; if only one employee is available, disclose that limitation and refrain from asserting stationwide consensus."

/datum/ccpost_task_template/engineering_preventive_maintenance
	template_id = "engineering_preventive_maintenance"
	rotation_family = "engineering_preventive_maintenance"
	required_staff_accounts = list(ACCOUNT_ENG)
	category = "Infrastructure Oversight"
	subject = "Preventive Maintenance Assessment"
	instruction = "Ask Engineering for evidence of scheduled inspections or maintenance affecting critical power, atmosphere, and structural systems. Compare preventive work with any recent reactive repairs and note maintenance obligations still outstanding."
	department_reward_id = ACCOUNT_ENG

/datum/ccpost_task_template/sector_record_certification
	template_id = "sector_record_certification"
	rotation_family = "sector_installations"
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
	rotation_family = "sector_installations"
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

// Self-contained administration tasks stay eligible when station staffing is low.
// These are records reviews, not invitations to fabricate incidents or personnel claims.
/datum/ccpost_task_template/sector_communications_audit
	template_id = "sector_communications_audit"
	rotation_family = "sector_installations"
	category = "Sector Records & Administration"
	subject = "Sector Communications Audit"
	selection_weight = 65
	instruction = "Use the Sector Communications Terminal to inspect recent regional messages, pending requests, and their recorded outcomes. Submit a stamped administrative report distinguishing outstanding requests from resolved work. State explicitly when no discrepancies are found; do not invent correspondence."

/datum/ccpost_task_template/installation_performance_review
	template_id = "installation_performance_review"
	rotation_family = "sector_installations"
	category = "Sector Records & Administration"
	subject = "Regional Installation Performance Review"
	selection_weight = 70
	instruction = "Review a regional installation's present condition, public administrative status and recorded history via Remote Oversight. Compare current findings with prior records and submit a stamped report identifying changes, unresolved concerns and any uncertainties."

/datum/ccpost_task_template/logistics_expenditure_review
	template_id = "logistics_expenditure_review"
	rotation_family = "outpost_internal"
	category = "Audits & Inspections"
	subject = "Outpost Logistics Expenditure Review"
	selection_weight = 55
	instruction = "Inspect the Outpost Logistics allocation ledger and shipment history. Reconcile recorded requisitions with operational needs and identify any unconfirmed or exceptional transactions. Submit stamped findings. No expenditure automatically implies misconduct."

/datum/ccpost_task_template/records_reconciliation
	template_id = "records_reconciliation"
	rotation_family = "outpost_internal"
	category = "Administrative Oversight"
	subject = "Administrative Records Reconciliation"
	selection_weight = 55
	instruction = "Compare completed Tasking Terminal records with relevant correspondence or regional installation records, where available. Check for unresolved references and inconsistent entries. Submit a stamped reconciliation report. Clearly identify records not available for verification."

/datum/ccpost_task_template/outpost_operational_readiness
	template_id = "outpost_operational_readiness"
	rotation_family = "outpost_internal"
	category = "Operational Oversight"
	subject = "Outpost Operational Readiness Assessment"
	selection_weight = 45
	instruction = "Inspect the outpost's communications, tasking, logistics, emergency access and visitor transport equipment using ordinary authorized controls. Document actual deficiencies and maintenance needs, or confirm readiness where observed. Submit a stamped report. Do not interfere with active security defenses to conduct this review."

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


// One record per authorized grant recipient. These records survive on the
// tasking circuit board with the rest of the order and are never inferred from
// eligible interview contacts.
/datum/ccpost_department_assessment
	var/department_id
	var/grant_amount_unrated = 0
	var/required = FALSE
	var/participated = FALSE
	var/rating
	var/assessed_by
	var/credited = 0
	var/grant_status = "Pending"
	var/radio_status = "Pending"

/datum/ccpost_department_assessment/New(_department_id, _amount, _required)
	. = ..()
	department_id = _department_id
	grant_amount_unrated = max(0, round(_amount))
	required = !!_required
	participated = required

/datum/ccpost_department_assessment/proc/adjusted_amount()
	if(!participated || !rating)
		return 0
	var/multiplier = 1
	switch(rating)
		if("Very Dissatisfied")
			multiplier = 0
		if("Dissatisfied")
			multiplier = 0.5
		if("Neutral")
			multiplier = 0.75
		if("Very Satisfied")
			multiplier = 1.25
	return round(grant_amount_unrated * multiplier)

/datum/ccpost_tasking_order
	var/order_code
	var/template_id
	var/rotation_family
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
	var/datum/weakref/assigned_contact_mind
	var/contact_unavailable = FALSE
	var/assigned_role
	var/assigned_department
	/// Number of times a current order has been temporarily deferred.
	var/deferral_count = 0
	var/deferred_at
	var/deferred_until = 0
	var/deferral_expires_at = 0
	var/deferral_expiry_paused_at = 0
	var/deferral_reason
	var/deferred_by
	var/status_before_deferral = CCPOST_TASK_STATUS_PENDING
	/// Event preemption is distinct from voluntary deferral. Held work never expires.
	var/status_before_hold = CCPOST_TASK_STATUS_PENDING
	var/held_at
	var/obj/item/paper/on_hold_report

	/// Each authorized grant recipient is evaluated independently.
	var/list/department_assessments = list()
	/// The start of the SSD grace period is recorded only upon a reassignment attempt.
	var/contact_ssd_grace_start = 0

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
	/// Assignment owner is the registered HR Liaison mind, not the physical console.
	var/assigned_to
	var/owner_key
	var/assigned_terminal
	/// Compact, server-authored audit events shared by all tasking consoles.
	var/list/audit_events = list()

/datum/ccpost_tasking_order/proc/record_action(event_name, actor, detail = null)
	var/list/record = list(
		"action" = event_name,
		"actor" = actor || "CENTRAL COMMAND",
		"at" = station_time_timestamp(),
		"detail" = detail || ""
	)
	audit_events += list(record)
	if(length(audit_events) > 30)
		audit_events.Cut(1, 2)

/datum/ccpost_tasking_order/New(_order_code, datum/ccpost_task_template/template)
	. = ..()

	order_code = _order_code
	template_id = template.template_id
	rotation_family = template.get_rotation_family()
	category = template.category
	subject = template.subject
	priority = template.priority
	instruction = template.instruction
	submission_type = template.submission_type
	issued_at = station_time_timestamp()
	department_assessments = list()
	if(template.department_reward_id)
		var/base_reward = get_department_reward()
		// Multi-department work may be handled by a secondary department alone.
		// Keep the principal recipient selected by default, but permit an
		// explicit opt-out when the template authorizes other grant recipients.
		var/datum/ccpost_department_assessment/primary_assessment = new /datum/ccpost_department_assessment(template.department_reward_id, base_reward * template.primary_grant_factor, !length(template.additional_grant_departments))
		primary_assessment.participated = TRUE
		department_assessments += primary_assessment
		if(length(template.additional_grant_departments))
			for(var/department_id in template.additional_grant_departments)
				if(department_id == template.department_reward_id)
					continue
				department_assessments += new /datum/ccpost_department_assessment(department_id, base_reward * template.secondary_grant_factor, FALSE)


/datum/ccpost_tasking_order/Destroy()
	QDEL_LIST(department_assessments)
	QDEL_NULL(archived_paper)
	QDEL_NULL(on_hold_report)
	return ..()

/// Returns the Operational Allocation reward for this task.
///
/// Task value is determined by its priority rather than being configured
/// individually on every assignment template.
/datum/ccpost_tasking_order/proc/get_allocation_reward()
	if(template_id in list("sector_communications_audit", "installation_performance_review", "logistics_expenditure_review", "records_reconciliation", "outpost_operational_readiness"))
		return 5
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

/datum/ccpost_tasking_order/proc/get_department_assessment(department_id)
	for(var/datum/ccpost_department_assessment/assessment as anything in department_assessments)
		if("[assessment.department_id]" == "[department_id]")
			return assessment
	return null

/datum/ccpost_tasking_order/proc/assessments_complete()
	var/has_participating_department = FALSE
	for(var/datum/ccpost_department_assessment/assessment as anything in department_assessments)
		if(!assessment.participated)
			continue
		has_participating_department = TRUE
		if(!assessment.rating)
			return FALSE
	// Grant-bearing assignments need at least one participating department;
	// tasks without departmental grants continue to complete normally.
	return has_participating_department || !length(department_assessments)

/obj/item/encryptionkey/ccpost_tasking_grants
	name = "Central Command departmental grant transceiver key"
	channels = list(
		RADIO_CHANNEL_COMMAND = 1,
		RADIO_CHANNEL_SECURITY = 1,
		RADIO_CHANNEL_ENGINEERING = 1,
		RADIO_CHANNEL_MEDICAL = 1,
		RADIO_CHANNEL_SUPPLY = 1,
		RADIO_CHANNEL_SERVICE = 1,
		RADIO_CHANNEL_SCIENCE = 1
	)

/obj/item/radio/headset/ccpost_tasking_grants
	name = "Central Command departmental grant transmitter"
	keyslot = /obj/item/encryptionkey/ccpost_tasking_grants
	keyslot2 = null


/obj/item/circuitboard/computer/ccpost_tasking
	name = "Central Command Tasking Terminal"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/ccpost_tasking

	/// Personal active assignment for this network-owned inbox state container.
	var/datum/ccpost_tasking_order/current_order

	/// Last three successfully issued randomly generated task templates only.
	var/list/recent_routine_templates = list()
	/// Last two random task families, used to prefer varied work even after cooldown.
	var/list/recent_routine_families = list()
	var/list/recent_interview_targets = list()
	/// Pending observable events are queued while Liaisons work on another order.
	var/list/event_task_queue = list()
	var/list/event_task_cooldowns = list()
	/// Ineligible event orders are retained only for a bounded amount of time.
	var/list/event_task_expires = list()
	/// Public observation context by queued template, never secret event internals.
	var/list/event_task_context = list()
	/// All distinct incident categories fit without preemptively deleting a lower-priority report.
	var/max_queued_incidents = 32
	var/last_significant_explosion_at = -10 MINUTES
	/// Deferred orders retain their identity, acceptance and reward flag.
	var/list/deferred_orders = list()
	/// Automatically interrupted work, distinct from time-limited manual deferrals.
	var/list/on_hold_orders = list()
	var/max_on_hold_orders = 6
	var/max_deferred_orders = 1
	var/max_deferrals_per_order = 2
	/// Completed reports can generate a bounded, single-stage follow-up.
	var/list/followup_orders = list()
	var/max_pending_followups = 2
	var/next_followup_allowed_at = 0
	/// Deadline preserved across sign-out and terminal replacement.
	var/next_dispatch_at = 0
	/// Last authenticated contact with the owner, for abandoned-work recovery.
	var/last_owner_activity_at = 0
	var/datum/mind/owner_mind

/obj/item/circuitboard/computer/ccpost_tasking/Destroy()
	QDEL_NULL(current_order)
	QDEL_LIST(deferred_orders)
	QDEL_LIST(on_hold_orders)
	QDEL_LIST(followup_orders)
	return ..()

// One round-long Tasking Network. Every authenticated Liaison has a personal
// inbox, while the audit archive, serial numbers, department cooldowns and
// incident de-duplication are outpost-wide. No payroll data is owned here.
/datum/ccpost_tasking_network
	var/list/inboxes = list() // REF(mind) -> private nonphysical tasking board
	var/list/shared_history = list() // completed/expired task records
	var/list/registered_terminals = list()
	var/list/family_next_dispatch = list()
	var/list/department_next_dispatch = list()
	/// Prevent repeated actual grants even from different incident template families.
	var/list/department_next_grant = list()
	var/list/event_next_dispatch = list()
	var/next_order_number = 1
	var/max_history = CCPOST_TASK_SHARED_ARCHIVE_LIMIT

/datum/ccpost_tasking_network/Destroy()
	QDEL_LIST_ASSOC_VAL(inboxes)
	QDEL_LIST(shared_history)
	return ..()

/datum/ccpost_tasking_network/proc/get_inbox(datum/mind/owner, create = FALSE)
	if(!owner)
		return null
	var/key = REF(owner)
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
	if(!inbox && create)
		// Store an inaccessible state container, NOT the machine's circuit board.
		inbox = new /obj/item/circuitboard/computer/ccpost_tasking
		inbox.owner_mind = owner
		inbox.last_owner_activity_at = world.time
		inboxes[key] = inbox
	return inbox

/datum/ccpost_tasking_network/proc/archive_order(datum/ccpost_tasking_order/order)
	if(!order || (order in shared_history))
		return
	shared_history.Insert(1, order)
	while(length(shared_history) > max_history)
		var/datum/ccpost_tasking_order/oldest = shared_history[length(shared_history)]
		shared_history.Cut(length(shared_history), length(shared_history) + 1)
		qdel(oldest)
	refresh_terminals()

/datum/ccpost_tasking_network/proc/refresh_terminals()
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
		if(!QDELETED(terminal))
			SStgui.update_uis(terminal)

/// A task is claimable only if its previous owner has been absent and inactive
/// for the entire grace window. No reassignment of deferred/on-hold work.
/datum/ccpost_tasking_network/proc/can_claim_inbox(obj/item/circuitboard/computer/ccpost_tasking/inbox, datum/mind/new_owner)
	if(!inbox || !inbox.owner_mind || inbox.owner_mind == new_owner || !inbox.current_order)
		return FALSE
	if(inbox.current_order.status == CCPOST_TASK_STATUS_COMPLETED)
		return FALSE
	if(world.time - inbox.last_owner_activity_at < CCPOST_TASK_REASSIGN_GRACE)
		return FALSE
	var/mob/old_body = inbox.owner_mind.current
	if(old_body?.client && ishuman(old_body))
		return FALSE
	return TRUE

/datum/ccpost_tasking_network/proc/list_claimable(datum/mind/new_owner)
	var/list/result = list()
	for(var/key in inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
		if(!can_claim_inbox(inbox, new_owner))
			continue
		result += list(list(
			"owner_key" = key,
			"order_code" = inbox.current_order.order_code,
			"subject" = inbox.current_order.subject,
			"assigned_to" = inbox.current_order.assigned_to,
			"priority" = inbox.current_order.priority
		))
	return result

/datum/ccpost_tasking_network/proc/claim_abandoned(mob/user, from_key, expected_code)
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user)
	if(!employee || employee.employee_role != "Central Command Liaison")
		return FALSE
	var/obj/item/circuitboard/computer/ccpost_tasking/from_inbox = inboxes["[from_key]"]
	var/obj/item/circuitboard/computer/ccpost_tasking/to_inbox = get_inbox(employee.employee_mind)
	if(!from_inbox || !to_inbox || to_inbox.current_order || length(to_inbox.on_hold_orders) || !can_claim_inbox(from_inbox, employee.employee_mind))
		return FALSE
	var/datum/ccpost_tasking_order/order = from_inbox.current_order
	if(order.order_code != expected_code)
		return FALSE
	// The old user's inserted physical report cannot be consumed by the new
	// owner. Ensure no terminal still holds an authenticated old session.
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
		if(terminal.tasking_session_mind == from_inbox.owner_mind)
			terminal.logout_tasking_session()
	from_inbox.current_order = null
	to_inbox.current_order = order
	var/old_owner = order.assigned_to
	order.assigned_to = employee.employee_name
	order.owner_key = REF(employee.employee_mind)
	order.record_action("Reassigned", user.name, "Previous assignee: [old_owner]. Inactive personnel transfer.")
	to_inbox.last_owner_activity_at = world.time
	refresh_terminals()
	return TRUE

/datum/ccpost_tasking_network/proc/has_outstanding_family(family, obj/item/circuitboard/computer/ccpost_tasking/except_inbox)
	if(!family)
		return FALSE
	for(var/key in inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
		if(inbox == except_inbox)
			continue
		if(inbox.current_order?.rotation_family == family && inbox.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
			return TRUE
		for(var/datum/ccpost_tasking_order/deferred as anything in inbox.deferred_orders)
			if(deferred.rotation_family == family)
				return TRUE
		for(var/datum/ccpost_tasking_order/held as anything in inbox.on_hold_orders)
			if(held.rotation_family == family)
				return TRUE
	return FALSE

/datum/ccpost_tasking_network/proc/has_outstanding_department(department_id, obj/item/circuitboard/computer/ccpost_tasking/except_inbox)
	if(!department_id)
		return FALSE
	for(var/key in inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
		if(inbox == except_inbox)
			continue
		var/list/orders = list()
		if(inbox.current_order)
			orders += inbox.current_order
		orders += inbox.deferred_orders
		orders += inbox.on_hold_orders
		for(var/datum/ccpost_tasking_order/order as anything in orders)
			if(order.status == CCPOST_TASK_STATUS_COMPLETED)
				continue
			if(order.get_department_assessment(department_id))
				return TRUE
	return FALSE

/datum/ccpost_tasking_network/proc/may_issue_template(datum/ccpost_task_template/template, obj/item/circuitboard/computer/ccpost_tasking/current_inbox)
	if(!template)
		return FALSE
	var/family = template.get_rotation_family()
	if(has_outstanding_family(family, current_inbox))
		return FALSE
	var/list/departments = list()
	if(template.department_reward_id)
		departments += template.department_reward_id
	if(length(template.additional_grant_departments))
		departments += template.additional_grant_departments
	for(var/department_id in departments)
		if(world.time < (department_next_dispatch["[department_id]"] || 0))
			return FALSE
		if(has_outstanding_department(department_id, current_inbox))
			return FALSE
	return TRUE

/datum/ccpost_tasking_network/proc/note_issued(datum/ccpost_tasking_order/order)
	if(!order)
		return
	for(var/datum/ccpost_department_assessment/assessment as anything in order.department_assessments)
		department_next_dispatch["[assessment.department_id]"] = world.time + CCPOST_TASK_DEPARTMENT_COOLDOWN

/// Select one operating Liaison terminal for an observed incident rather than
/// broadcasting the same task into every personal inbox.
/datum/ccpost_tasking_network/proc/incident_recipient(template_type)
	var/obj/machinery/computer/ccpost_tasking/best
	var/best_rank = INFINITY
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
		if(QDELETED(terminal) || (terminal.machine_stat & (BROKEN | NOPOWER)) || !terminal.tasking_session_mind)
			continue
		var/mob/living/carbon/human/active_employee = terminal.tasking_session_mind.current
		if(!active_employee?.client || !terminal.session_valid_for(active_employee))
			continue
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = terminal.get_tasking_board()
		if(!inbox)
			continue
		var/rank = inbox.current_order ? ccpost_incident_priority_rank(inbox.current_order.priority) : 0
		if(rank < best_rank)
			best = terminal
			best_rank = rank
	return best

GLOBAL_DATUM_INIT(ccpost_tasking_network, /datum/ccpost_tasking_network, new)

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
	var/next_assignment_attempt_at = 0
	var/obj/item/radio/headset/ccpost_tasking_grants/grant_radio
	/// Sign-in is bound to the server-side HR identity, never client-submitted text.
	var/datum/mind/tasking_session_mind
	var/tasking_session_name

	/// Physical report currently inserted for task completion.
	var/obj/item/paper/submitted_report

	/// Prevents repeated manual printing.
	COOLDOWN_DECLARE(print_cooldown)
	/// Only linked station telecomms hubs; register per machine instead of scanning each tick.
	var/list/monitored_telecomms_hubs = list()
	/// Prevent repeated outage reports from the same already-failed hub.
	var/list/failed_telecomms_hubs = list()
	/// Fire once for a cluster of active atmospheric alarms.
	var/list/recent_atmos_alarm_areas = list()
	var/last_atmos_alarm_at = -10 MINUTES

	/// Pool of Central Command assignments.
	/// Available task template types. Concrete content lives on template datums.
	var/static/list/assignment_template_types = subtypesof(/datum/ccpost_task_template)


/obj/machinery/computer/ccpost_tasking/item_interaction(
	mob/living/user,
	obj/item/tool,
	list/modifiers
)
	if(!istype(tool, /obj/item/paper))
		return NONE
	if(!session_valid_for(user))
		balloon_alert(user, "sign in as a Liaison first")
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

// Server-side session management. The HR roster is the authority for
// employee identity and prevents a stolen or mismatched card from taking
// ownership of another Liaison's inbox.
/obj/machinery/computer/ccpost_tasking/proc/session_valid_for(mob/user)
	if(!tasking_session_mind || !user?.mind || user.mind != tasking_session_mind)
		return FALSE
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user)
	return employee && employee.employee_role == "Central Command Liaison" && employee.employee_mind == tasking_session_mind

/obj/machinery/computer/ccpost_tasking/proc/logout_tasking_session()
	if(!tasking_session_mind)
		return
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = get_tasking_board()
	if(inbox && next_assignment_attempt_at)
		inbox.next_dispatch_at = next_assignment_attempt_at
	if(assignment_timer)
		deltimer(assignment_timer)
		assignment_timer = null
	next_assignment_attempt_at = 0
	if(submitted_report)
		submitted_report.forceMove(drop_location())
		submitted_report = null
	tasking_session_mind = null
	tasking_session_name = null
	SStgui.update_uis(src)

/obj/machinery/computer/ccpost_tasking/proc/login_tasking_session(mob/user)
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user)
	if(!employee || employee.employee_role != "Central Command Liaison")
		return FALSE
	if(tasking_session_mind && tasking_session_mind != employee.employee_mind)
		logout_tasking_session()
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	// Single active workstation per Liaison. A new sign-in transfers the
	// existing session but retains its personal inbox and dispatch deadline.
	for(var/obj/machinery/computer/ccpost_tasking/other as anything in network.registered_terminals)
		if(other != src && other.tasking_session_mind == employee.employee_mind)
			other.logout_tasking_session()
	tasking_session_mind = employee.employee_mind
	tasking_session_name = employee.employee_name
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = network.get_inbox(tasking_session_mind, TRUE)
	if(!inbox)
		return FALSE
	inbox.last_owner_activity_at = world.time
	if(!inbox.next_dispatch_at)
		schedule_next_assignment(CCPOST_TASK_FIRST_MIN, CCPOST_TASK_FIRST_MAX)
	else
		var/remaining = max(1 SECONDS, inbox.next_dispatch_at - world.time)
		schedule_next_assignment(remaining, remaining)
	SStgui.update_uis(src)
	return TRUE

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
	grant_radio = new(src)
	GLOB.ccpost_tasking_network.registered_terminals |= src

/obj/machinery/computer/ccpost_tasking/Destroy()
	logout_tasking_session()
	GLOB.ccpost_tasking_network.registered_terminals -= src
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)
	UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_ALARM_FIRE(ALARM_ATMOS), COMSIG_MAIN_SM_DELAMINATING, COMSIG_GLOB_NEW_MACHINE))
	for(var/obj/machinery/telecomms/hub/hub as anything in monitored_telecomms_hubs)
		if(!QDELETED(hub))
			UnregisterSignal(hub, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST, COMSIG_MACHINERY_POWER_RESTORED, COMSIG_QDELETING))
	monitored_telecomms_hubs = null
	failed_telecomms_hubs = null
	if(assignment_timer)
		deltimer(assignment_timer)
		assignment_timer = null
	QDEL_NULL(grant_radio)

	// Never destroy an inserted report when the machine is dismantled.
	if(submitted_report)
		submitted_report.forceMove(drop_location())
		submitted_report = null

	// Do NOT delete the current order or history here.
	// Those belong to the circuit board and survive deconstruction.

	return ..()


/// Announce one department's actual grant outcome over its own radio channel.
/// No case details or another department's rating are disclosed.
/obj/machinery/computer/ccpost_tasking/proc/announce_department_grant(datum/ccpost_tasking_order/order, datum/ccpost_department_assessment/assessment)
	if(!grant_radio || !order || !assessment || !assessment.participated)
		return FALSE
	var/channel
	switch(assessment.department_id)
		if(ACCOUNT_CMD)
			channel = RADIO_CHANNEL_COMMAND
		if(ACCOUNT_SEC)
			channel = RADIO_CHANNEL_SECURITY
		if(ACCOUNT_ENG)
			channel = RADIO_CHANNEL_ENGINEERING
		if(ACCOUNT_MED)
			channel = RADIO_CHANNEL_MEDICAL
		if(ACCOUNT_CAR)
			channel = RADIO_CHANNEL_SUPPLY
		if(ACCOUNT_SRV)
			channel = RADIO_CHANNEL_SERVICE
		if(ACCOUNT_SCI)
			channel = RADIO_CHANNEL_SCIENCE
	if(!channel)
		return FALSE
	var/outcome
	switch(assessment.grant_status)
		if("Credited")
			outcome = "[assessment.credited] credits credited to the departmental account."
		if("Withheld")
			outcome = "0 credits awarded. Departmental grant withheld following the cooperation assessment."
		if("Cooldown Withheld")
			outcome = "0 credits awarded. Departmental grant cooldown remains active."
		if("Processing Failed")
			outcome = "0 credits credited. Financial Administration requires follow-up."
		else
			return FALSE
	var/closing
	switch(assessment.rating)
		if("Very Dissatisfied")
			closing = "Cooperation assessed as unacceptable."
		if("Dissatisfied")
			closing = "Cooperation requires improvement."
		if("Neutral")
			closing = "Cooperation recorded without commendation."
		if("Satisfied")
			closing = "Central Command acknowledges satisfactory cooperation."
		if("Very Satisfied")
			closing = "Central Command commends exemplary departmental cooperation."
	var/assessor = assessment.assessed_by || "Central Command Liaison Office"
	var/department_name = department_grant_name(assessment.department_id)
	grant_radio.talk_into(src, "Central Command Financial Administration: Cooperation assessment for [order.order_code]. Department: [department_name]. Assessing Liaison: [assessor]. Rating: [assessment.rating]. Grant outcome: [outcome] [closing]", channel)
	return TRUE

/obj/machinery/computer/ccpost_tasking/proc/department_grant_name(department_id)
	switch(department_id)
		if(ACCOUNT_CMD)
			return "Command"
		if(ACCOUNT_SEC)
			return "Security"
		if(ACCOUNT_ENG)
			return "Engineering"
		if(ACCOUNT_MED)
			return "Medical"
		if(ACCOUNT_CAR)
			return "Cargo"
		if(ACCOUNT_SRV)
			return "Service"
		if(ACCOUNT_SCI)
			return "Science"
	return "Department"

/obj/machinery/computer/ccpost_tasking/proc/apply_task_rewards(
	datum/ccpost_tasking_order/order,
	mob/completing_user
)
	if(!order || order.rewards_issued)
		return
	if(!order.assessments_complete() && !(order.template_id == CCPOST_TASK_AUDIT_TEMPLATE_ID && order.audit_compliance_points > 0))
		say("Departmental cooperation assessments are required before grant processing.")
		return

	// Single guard covers all grants and the Liaison's Operational Allocation.
	order.rewards_issued = TRUE
	var/reward_actor = completing_user ? completing_user.name : "CENTRAL COMMAND TASKING"

	if(order.template_id == CCPOST_TASK_AUDIT_TEMPLATE_ID && order.audit_compliance_points > 0)
		apply_procurement_audit_finding(order, completing_user)
		return

	var/allocation_reward = order.get_allocation_reward()
	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network
	var/datum/ccpost_tasking_network/tasking_network = GLOB.ccpost_tasking_network
	if(logistics_network && allocation_reward > 0)
		var/credited_allocation = logistics_network.credit_allocation(
			allocation_reward,
			"Completed tasking order [order.order_code]: [order.subject]",
			reward_actor
		)
		if(credited_allocation > 0)
			logistics_network.refresh_registered_terminals()
			say("Tasking compensation authorized. [credited_allocation] CU has been credited to this installation's Operational Allocation.")
		else
			say("Tasking compensation processed. Operational Allocation is already at maximum capacity.")

	for(var/datum/ccpost_department_assessment/assessment as anything in order.department_assessments)
		if(!assessment.participated)
			assessment.grant_status = "Not Participating"
			assessment.radio_status = "Not Applicable"
			continue
		var/department_name = department_grant_name(assessment.department_id)
		var/authorized_amount = assessment.adjusted_amount()
		if(authorized_amount <= 0)
			assessment.grant_status = "Withheld"
			say("No departmental budget grant authorized for [department_name] on [order.order_code].")
		else if(world.time < (tasking_network.department_next_grant["[assessment.department_id]"] || 0))
			assessment.grant_status = "Cooldown Withheld"
			say("Departmental grant for [department_name] withheld: the shared 30-minute financial cooldown is active.")
		else
			var/datum/bank_account/department/department_account = SSeconomy.get_dep_account(assessment.department_id)
			if(!department_account)
				assessment.grant_status = "Processing Failed"
				say("Tasking grant processing failed: [department_name] account unavailable.")
			else
				var/reason = "Central Command Tasking Grant: [order.order_code] - [order.subject]"
				if(department_account.adjust_money(authorized_amount, reason))
					assessment.credited = authorized_amount
					assessment.grant_status = "Credited"
					tasking_network.department_next_grant["[assessment.department_id]"] = world.time + CCPOST_TASK_DEPARTMENT_COOLDOWN
					say("Central Command has credited [authorized_amount] credits to [department_name].")
				else
					assessment.grant_status = "Processing Failed"
					say("Tasking grant processing failed for [department_name].")
		assessment.radio_status = announce_department_grant(order, assessment) ? "Transmitted" : "Unavailable"

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


/obj/machinery/computer/ccpost_tasking/proc/get_tasking_board()
	if(!tasking_session_mind)
		return null
	return GLOB.ccpost_tasking_network.get_inbox(tasking_session_mind)


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


/// Recover from an SSD/departed contact without automatically completing the task.
/// Keeps the original assignment's evidence requirements, priority and payout.
/obj/machinery/computer/ccpost_tasking/proc/reassign_unavailable_contact(datum/ccpost_tasking_order/order)
	if(!order || !order.assigned_contact || order.status != CCPOST_TASK_STATUS_ACKNOWLEDGED)
		return "No acknowledged assignment with a designated contact."
	var/datum/mind/old_mind = order.assigned_contact_mind?.resolve()
	var/mob/living/carbon/human/old_person = old_mind?.current
	if(istype(old_person) && old_person.stat != DEAD && old_person.client)
		order.contact_ssd_grace_start = 0
		order.contact_unavailable = FALSE
		return "The assigned contact is still available."
	// A brief lost connection does not immediately displace the designated employee.
	if(istype(old_person) && old_person.stat != DEAD)
		if(!order.contact_ssd_grace_start)
			order.contact_ssd_grace_start = world.time
		if(world.time < order.contact_ssd_grace_start + CCPOST_TASK_CONTACT_SSD_GRACE)
			return "Contact temporarily unavailable. Allow 90 seconds for reconnection before reassignment."
	var/datum/ccpost_task_template/template
	for(var/template_type in assignment_template_types)
		var/datum/ccpost_task_template/candidate = new template_type
		if(candidate.template_id == order.template_id)
			template = candidate
			break
		qdel(candidate)
	if(!template)
		return "No staff eligibility data for this task. Document contact attempts in your report."
	var/list/alternatives = template.get_available_staff()
	qdel(template)
	for(var/mob/living/carbon/human/person as anything in alternatives.Copy())
		if(person.mind == old_mind)
			alternatives -= person
	if(!length(alternatives))
		order.contact_unavailable = TRUE
		order.instruction += "\n\nContact update: The original representative is unavailable and no suitable replacement is currently available for contact. Document genuine contact attempts and any limits on verification in the stamped report."
		return "No alternative representative available. Contact attempt recorded."
	alternatives = ccpost_prefer_contactable_staff(alternatives)
	var/mob/living/carbon/human/replacement = pick(alternatives)
	var/datum/job/job = replacement.mind?.assigned_role
	if(!job)
		return "Replacement no longer available."
	order.assigned_contact = replacement.real_name
	order.assigned_contact_mind = WEAKREF(replacement.mind)
	order.assigned_role = job.title
	order.assigned_department = job.paycheck_department
	order.contact_unavailable = !replacement.client
	order.contact_ssd_grace_start = 0
	order.instruction += "\n\nUpdated station contact: [replacement.real_name] ([job.title]). Verify findings with the replacement representative when available."
	return "Replacement contact assigned: [replacement.real_name]."

/obj/machinery/computer/ccpost_tasking/proc/attach_staffing_context(datum/ccpost_tasking_order/order, datum/ccpost_task_template/template)
	if(!order || !template || !(template.any_station_staff || length(template.required_staff_accounts) || length(template.excluded_staff_accounts)))
		return TRUE
	var/list/staff = template.get_available_staff()
	if(!length(staff))
		if(template.event_only)
			order.instruction += "\n\nStaffing note: No suitable departmental representative was immediately available for contact. Coordinate with departmental personnel or Command when practical, and document any unsuccessful contact attempts."
			return TRUE
		return FALSE
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	var/is_interview = template.template_id == "civilian_interview" || template.template_id == "departmental_compliance"
	if(is_interview && board)
		var/list/fresh_staff = list()
		for(var/mob/living/carbon/human/candidate as anything in staff)
			if(!(REF(candidate.mind) in board.recent_interview_targets))
				fresh_staff += candidate
		if(!length(fresh_staff))
			// Everyone available was recently interviewed; rotate rather than deadlock.
			board.recent_interview_targets.Cut()
		else
			staff = fresh_staff
	staff = ccpost_prefer_contactable_staff(staff)
	var/mob/living/carbon/human/employee = pick(staff)
	var/datum/job/job = employee.mind?.assigned_role
	if(!job)
		return FALSE
	if(is_interview && board)
		board.recent_interview_targets += REF(employee.mind)
		while(length(board.recent_interview_targets) > CCPOST_TASK_INTERVIEW_HISTORY)
			board.recent_interview_targets.Cut(1, 2)
	order.assigned_contact = employee.real_name
	order.assigned_contact_mind = WEAKREF(employee.mind)
	order.assigned_role = job.title
	order.assigned_department = job.paycheck_department
	order.contact_unavailable = !employee.client
	order.instruction += "\n\nStaffing verification at issue: [employee.real_name] ([job.title]) is assigned to the relevant department. If the employee is not immediately reachable, use Defer or document genuine contact attempts instead of inventing an interview."
	return TRUE

/// explicit allowlist for publicly announced, non-secret round events.
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
	if(!board || !template_type || (template_type in board.event_task_queue))
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

// Immediately dispatch the highest-priority queued incident if it can supersede
// the current order. This uses the same public-event and machine-signal hooks.
// Event orders do not require a specific online employee at the instant of issue.
/obj/machinery/computer/ccpost_tasking/proc/dispatch_queued_incident()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || (machine_stat & (NOPOWER | BROKEN)) || !length(board.event_task_queue))
		return FALSE
	if(board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		archive_finished_order()
	var/template_type = board.event_task_queue[1]
	var/datum/ccpost_task_template/incident = new template_type
	if(!incident)
		return FALSE
	var/new_rank = ccpost_incident_priority_rank(incident.priority)
	if(board.current_order && new_rank <= ccpost_incident_priority_rank(board.current_order.priority))
		qdel(incident)
		return FALSE
	if(board.current_order && length(board.on_hold_orders) >= board.max_on_hold_orders)
		qdel(incident)
		return FALSE
	var/datum/ccpost_tasking_order/new_order = create_task_order(incident)
	incident.configure_order(new_order, GLOB.ccpost_logistics_network)
	var/incident_observation = board.event_task_context["[template_type]"]
	if(incident_observation)
		new_order.instruction += "\n\nMonitoring record: [incident_observation]. Verify details with station personnel before reaching conclusions."
	if(!attach_staffing_context(new_order, incident))
		qdel(new_order)
		qdel(incident)
		return FALSE
	if(board.current_order)
		var/datum/ccpost_tasking_order/suspended = board.current_order
		suspended.status_before_hold = suspended.status
		suspended.status = CCPOST_TASK_STATUS_ON_HOLD
		suspended.held_at = station_time_timestamp()
		suspended.record_action("On Hold", "CENTRAL COMMAND", "Preempted by urgent incident")
		if(submitted_report)
			suspended.on_hold_report = submitted_report
			submitted_report.forceMove(null)
			submitted_report = null
		board.on_hold_orders += suspended
		board.current_order = null
	board.event_task_queue -= template_type
	board.event_task_expires -= "[template_type]"
	board.event_task_context -= "[template_type]"
	board.current_order = new_order
	GLOB.ccpost_tasking_network.note_issued(new_order)
	pause_deferred_expiration(board)
	qdel(incident)
	if(assignment_timer)
		deltimer(assignment_timer)
		assignment_timer = null
	playsound(src, 'sound/machines/terminal/terminal_alert.ogg', vol = 85, vary = FALSE)
	visible_message(span_warning("[src] sounds an urgent priority tasking alert."))
	print_order(new_order)
	SStgui.update_uis(src)
	schedule_next_assignment()
	return TRUE

/// Automatically restore the newest held order once higher-priority incidents are cleared.
/obj/machinery/computer/ccpost_tasking/proc/restore_on_hold_order()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || board.current_order || !length(board.on_hold_orders))
		return FALSE
	var/index = length(board.on_hold_orders)
	var/datum/ccpost_tasking_order/held = board.on_hold_orders[index]
	board.on_hold_orders.Cut(index, index + 1)
	held.status = held.status_before_hold
	board.current_order = held
	held.record_action("Resumed", tasking_session_name, "Previously interrupted order restored")
	pause_deferred_expiration(board)
	if(held.on_hold_report)
		held.on_hold_report.forceMove(src)
		submitted_report = held.on_hold_report
		held.on_hold_report = null
	visible_message(span_notice("[src] resumes an interrupted Central Command tasking order."))
	SStgui.update_uis(src)
	return TRUE

// No continuous scans. These signals queue at most one entry per incident category.
/obj/machinery/computer/ccpost_tasking/proc/queue_event_task(template_type, cooldown_duration = 12 MINUTES, observation = null)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!template_type)
		return
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	var/obj/machinery/computer/ccpost_tasking/recipient = network.incident_recipient(template_type)
	if(recipient && recipient != src)
		recipient.queue_event_task(template_type, cooldown_duration, observation)
		return
	if(recipient != src || !board)
		return
	if(world.time < (network.event_next_dispatch["[template_type]"] || 0))
		return
	var/last_queued = board.event_task_cooldowns["[template_type]"]
	if(last_queued && world.time < last_queued)
		return
	if(template_type in board.event_task_queue)
		return
	// Preserve existing queued incident work rather than evicting lower ranks.
	if(length(board.event_task_queue) >= board.max_queued_incidents)
		return
	var/datum/ccpost_task_template/queued_template = new template_type
	var/queued_id = queued_template.template_id
	qdel(queued_template)
	if(board.current_order?.template_id == queued_id)
		return
	for(var/datum/ccpost_tasking_order/held as anything in board.on_hold_orders)
		if(held.template_id == queued_id)
			return
	insert_event_task_by_priority(board, template_type)
	network.event_next_dispatch["[template_type]"] = world.time + cooldown_duration
	board.event_task_cooldowns["[template_type]"] = world.time + cooldown_duration
	board.event_task_expires["[template_type]"] = world.time + 60 MINUTES
	if(istext(observation) && length(observation))
		board.event_task_context["[template_type]"] = copytext(observation, 1, 301)
	// Dispatch on the next tick instead of waiting for the routine assignment cycle.
	addtimer(CALLBACK(src, PROC_REF(dispatch_queued_incident)), 1 SECONDS)

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
	queue_event_task(/datum/ccpost_task_template/explosions, 12 MINUTES, "Significant explosion indication near [get_area(epicenter)] at [station_time_timestamp()]")

/obj/machinery/computer/ccpost_tasking/proc/on_security_level_changed(datum/source, new_security_level)
	SIGNAL_HANDLER
	if(new_security_level >= SEC_LEVEL_RED)
		queue_event_task(/datum/ccpost_task_template/emergency_readiness, 15 MINUTES, "Station security level raised to red at [station_time_timestamp()]")


/obj/machinery/computer/ccpost_tasking/proc/on_atmospheric_alarm(datum/source, datum/alarm_handler/handler, alarm_type, area/alarmed_area, z_level)
	SIGNAL_HANDLER
	if(alarm_type != ALARM_ATMOS || !alarmed_area || !is_station_level(z_level))
		return
	if(STATION_TIME_PASSED() < CCPOST_TASK_ATMOS_GRACE)
		return
	if(("[alarmed_area]" in recent_atmos_alarm_areas) && world.time - last_atmos_alarm_at < 3 MINUTES)
		return
	if(world.time - last_atmos_alarm_at > 3 MINUTES)
		recent_atmos_alarm_areas.Cut()
	recent_atmos_alarm_areas += "[alarmed_area]"
	if(length(recent_atmos_alarm_areas) > 10)
		recent_atmos_alarm_areas.Cut(1, 2)
	last_atmos_alarm_at = world.time
	queue_event_task(/datum/ccpost_task_template/atmos_emergency, 8 MINUTES, "Atmospheric alarm indicated in [alarmed_area] at [station_time_timestamp()]")

/obj/machinery/computer/ccpost_tasking/proc/on_supermatter_delamination(datum/source, delaminating)
	SIGNAL_HANDLER
	if(!delaminating)
		return
	queue_event_task(/datum/ccpost_task_template/supermatter_incident, 20 MINUTES, "Supermatter delamination alert reported at [station_time_timestamp()]")

/obj/machinery/computer/ccpost_tasking/proc/register_existing_telecomms()
	if(QDELETED(src))
		return
	for(var/obj/machinery/telecomms/hub/hub as anything in GLOB.telecomms_list)
		if(istype(hub, /obj/machinery/telecomms/hub))
			register_telecomms_hub(hub)

/obj/machinery/computer/ccpost_tasking/proc/register_telecomms_hub(obj/machinery/telecomms/hub/hub)
	if(!hub || QDELETED(hub) || (hub in monitored_telecomms_hubs) || !is_station_level(hub.z))
		return
	monitored_telecomms_hubs += hub
	RegisterSignal(hub, COMSIG_MACHINERY_BROKEN, PROC_REF(on_telecomms_hub_failure))
	RegisterSignal(hub, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_telecomms_hub_failure))
	RegisterSignal(hub, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(on_telecomms_hub_power_restored))
	RegisterSignal(hub, COMSIG_QDELETING, PROC_REF(on_telecomms_hub_removed))

/obj/machinery/computer/ccpost_tasking/proc/on_new_machine(datum/source, obj/machinery/created_machine)
	SIGNAL_HANDLER
	if(istype(created_machine, /obj/machinery/telecomms/hub))
		register_telecomms_hub(created_machine)

/obj/machinery/computer/ccpost_tasking/proc/on_telecomms_hub_failure(datum/source)
	SIGNAL_HANDLER
	var/obj/machinery/telecomms/hub/hub = source
	if(!hub || !is_station_level(hub.z) || (hub in failed_telecomms_hubs))
		return
	var/outage_already_reported = length(failed_telecomms_hubs) > 0
	failed_telecomms_hubs += hub
	// Multiple hubs losing power in the same ongoing outage are one incident.
	if(!outage_already_reported)
		queue_event_task(/datum/ccpost_task_template/telecomms_incident, 15 MINUTES, "Station communications hub failure recorded at [station_time_timestamp()]")

/obj/machinery/computer/ccpost_tasking/proc/on_telecomms_hub_power_restored(datum/source)
	SIGNAL_HANDLER
	var/obj/machinery/telecomms/hub/hub = source
	if(hub && !(hub.machine_stat & (BROKEN | NOPOWER)))
		failed_telecomms_hubs -= hub

/obj/machinery/computer/ccpost_tasking/proc/on_telecomms_hub_removed(datum/source)
	SIGNAL_HANDLER
	var/obj/machinery/telecomms/hub/hub = source
	var/already_reported = FALSE
	if(hub in failed_telecomms_hubs)
		already_reported = TRUE
	failed_telecomms_hubs -= hub
	monitored_telecomms_hubs -= hub
	if(hub && !already_reported && is_station_level(hub.z))
		queue_event_task(/datum/ccpost_task_template/telecomms_incident, 15 MINUTES, "Station communications hub removal recorded at [station_time_timestamp()]")


/// A follow-up request retains the original order reference, not the confidential report text.
/datum/ccpost_task_followup
	var/source_order_code
	var/source_subject
	var/source_category
	var/source_rotation_family
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
	source_rotation_family = original.rotation_family
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
	// A deferred follow-up must block fresh random work about the same subject.
	order.rotation_family = followup.source_rotation_family
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
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	var/order_code = "CC-[round_identifier]-[network.next_order_number]"
	network.next_order_number++
	var/datum/ccpost_tasking_order/new_order = new /datum/ccpost_tasking_order(order_code, template)
	new_order.owner_key = REF(tasking_session_mind)
	new_order.assigned_to = tasking_session_name
	new_order.assigned_terminal = "[x],[y],[z]"
	new_order.record_action("Issued", "CENTRAL COMMAND", "Assigned to [tasking_session_name]")
	return new_order

/// Expire rather than silently deleting deferred paperwork. All results remain archived.
/obj/machinery/computer/ccpost_tasking/proc/pause_deferred_expiration(obj/item/circuitboard/computer/ccpost_tasking/board)
	if(!board)
		return
	for(var/datum/ccpost_tasking_order/order as anything in board.deferred_orders)
		if(!order.deferral_expiry_paused_at)
			order.deferral_expiry_paused_at = world.time

/obj/machinery/computer/ccpost_tasking/proc/expire_overdue_deferrals()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board)
		return
	for(var/datum/ccpost_tasking_order/order as anything in board.deferred_orders.Copy())
		if(board.current_order && board.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
			if(!order.deferral_expiry_paused_at)
				order.deferral_expiry_paused_at = world.time
			continue
		if(order.deferral_expiry_paused_at)
			order.deferral_expires_at += world.time - order.deferral_expiry_paused_at
			order.deferral_expiry_paused_at = 0
		if(world.time < order.deferral_expires_at)
			continue
		board.deferred_orders -= order
		order.status = CCPOST_TASK_STATUS_EXPIRED
		order.record_action("Expired", "CENTRAL COMMAND", "Deferred work expired")
		GLOB.ccpost_tasking_network.archive_order(order)

/obj/machinery/computer/ccpost_tasking/proc/activate_deferred_order(datum/ccpost_tasking_order/order)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !order || !(order in board.deferred_orders))
		return FALSE
	if(board.current_order && board.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
		return FALSE
	expire_overdue_deferrals()
	if(world.time < order.deferred_until || world.time >= order.deferral_expires_at)
		return FALSE
	if(board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		archive_finished_order()
	board.deferred_orders -= order
	order.status = order.status_before_deferral
	board.current_order = order
	order.record_action("Resumed", tasking_session_name, "Deferred order returned to inbox")
	pause_deferred_expiration(board)
	print_order(order)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/ccpost_tasking/proc/archive_finished_order()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board?.current_order || board.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
		return
	var/datum/ccpost_tasking_order/finished_order = board.current_order
	board.current_order = null
	GLOB.ccpost_tasking_network.archive_order(finished_order)


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
	minimum_delay = CCPOST_TASK_INTERVAL_MIN,
	maximum_delay = CCPOST_TASK_INTERVAL_MAX
)
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = get_tasking_board()
	if(!inbox)
		return
	if(assignment_timer)
		deltimer(assignment_timer)
	var/dispatch_delay = rand(minimum_delay, maximum_delay)
	next_assignment_attempt_at = world.time + dispatch_delay
	inbox.next_dispatch_at = next_assignment_attempt_at
	assignment_timer = addtimer(CALLBACK(src, PROC_REF(issue_assignment)), dispatch_delay, TIMER_STOPPABLE)

/obj/machinery/computer/ccpost_tasking/proc/issue_assignment()
	assignment_timer = null
	next_assignment_attempt_at = 0
	var/mob/living/carbon/human/assigned_liaison = tasking_session_mind?.current
	if(!assigned_liaison?.client || !session_valid_for(assigned_liaison))
		logout_tasking_session()
		return
	var/obj/item/circuitboard/computer/ccpost_tasking/active_inbox = get_tasking_board()
	if(active_inbox)
		active_inbox.next_dispatch_at = 0
	if(machine_stat & (NOPOWER | BROKEN))
		schedule_next_assignment(CCPOST_TASK_RETRY_MIN, CCPOST_TASK_RETRY_MAX)
		return
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board)
		return
	expire_overdue_deferrals()
	if(board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		archive_finished_order()
	if(length(board.event_task_queue) && dispatch_queued_incident())
		return
	if(board.current_order)
		schedule_next_assignment(CCPOST_TASK_RETRY_MIN, CCPOST_TASK_RETRY_MAX)
		return
	if(length(board.on_hold_orders) && restore_on_hold_order())
		schedule_next_assignment()
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
				board.event_task_context -= "[template_type]"
				continue
			var/datum/ccpost_task_template/event_template = new template_type
			if(event_template.event_only || event_template.is_eligible())
				template = event_template
				board.event_task_queue -= template_type
				board.event_task_expires -= "[template_type]"
				var/queued_observation = board.event_task_context["[template_type]"]
				if(queued_observation)
					event_template.instruction += "\n\nMonitoring record: [queued_observation]. Verify details before reaching conclusions."
				board.event_task_context -= "[template_type]"
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
			// Never issue another routine review of a family already awaiting resolution.
			// A deferred outpost readiness review therefore blocks a new outpost ledger
			// review; a deferred installation certification blocks a different
			// installation performance review, even though their template IDs differ.
			var/list/outstanding_families = list()
			for(var/datum/ccpost_tasking_order/deferred as anything in board.deferred_orders)
				if(deferred.rotation_family && !(deferred.rotation_family in outstanding_families))
					outstanding_families += deferred.rotation_family
			for(var/datum/ccpost_tasking_order/held as anything in board.on_hold_orders)
				if(held.rotation_family && !(held.rotation_family in outstanding_families))
					outstanding_families += held.rotation_family
			var/list/available_priorities = list()
			var/list/families_by_type = list()
			for(var/candidate_type in assignment_template_types)
				var/datum/ccpost_task_template/candidate = new candidate_type
				if(!candidate.event_only && candidate.selection_weight > 0 && GLOB.ccpost_task_category_weights[candidate.category] > 0)
					var/family = candidate.get_rotation_family()
					var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
					var/next_family_dispatch = network.family_next_dispatch[family]
					if(!(family in outstanding_families) && (!isnum(next_family_dispatch) || world.time >= next_family_dispatch) && network.may_issue_template(candidate, board) && candidate.is_eligible())
						var/list/types_for_priority = available_priorities[candidate.priority]
						if(!types_for_priority)
							types_for_priority = list()
							available_priorities[candidate.priority] = types_for_priority
						types_for_priority += candidate_type
						families_by_type["[candidate_type]"] = family
				qdel(candidate)
			// Prefer a task family absent from the last two random assignments.
			// If only one or two families are available, progressively relax that
			// preference, but NEVER bypass a family cooldown or deferred/held order.
			var/list/recent_families = board.recent_routine_families.Copy()
			var/last_family = length(recent_families) ? recent_families[length(recent_families)] : null
			var/list/family_filtered_priorities = list()
			for(var/family_pass in 1 to 3)
				family_filtered_priorities.Cut()
				for(var/priority_name in available_priorities)
					var/list/filtered_families = list()
					for(var/candidate_type in available_priorities[priority_name])
						var/family = families_by_type["[candidate_type]"]
						if(family_pass == 1 && (family in recent_families))
							continue
						if(family_pass == 2 && family == last_family)
							continue
						filtered_families += candidate_type
					if(length(filtered_families))
						family_filtered_priorities[priority_name] = filtered_families
				if(length(family_filtered_priorities))
					break
			// Apply exact-template rotation after family rotation; a small pool
			// may require relaxing the oldest template exclusion, not all families.
			var/list/recent_exclusions = board.recent_routine_templates.Copy()
			var/list/filtered_priorities = list()
			while(TRUE)
				filtered_priorities.Cut()
				for(var/priority_name in family_filtered_priorities)
					var/list/filtered = list()
					for(var/candidate_type in family_filtered_priorities[priority_name])
						if(!(candidate_type in recent_exclusions))
							filtered += candidate_type
					if(length(filtered))
						filtered_priorities[priority_name] = filtered
				if(length(filtered_priorities) || !length(recent_exclusions))
					break
				recent_exclusions.Cut(1, 2)
			var/list/priority_weights = list()
			for(var/priority_name in filtered_priorities)
				if(GLOB.ccpost_task_priority_weights[priority_name] > 0)
					priority_weights[priority_name] = GLOB.ccpost_task_priority_weights[priority_name]
			if(length(priority_weights))
				var/chosen_priority = pick_weight(priority_weights)
				var/list/categories = list()
				for(var/candidate_type in filtered_priorities[chosen_priority])
					var/datum/ccpost_task_template/eligible_template = new candidate_type
					var/list/category_templates = categories[eligible_template.category]
					if(!category_templates)
						category_templates = list()
						categories[eligible_template.category] = category_templates
					category_templates[candidate_type] = eligible_template.selection_weight
					qdel(eligible_template)
				var/list/category_weights = list()
				for(var/category_name in categories)
					var/base_weight = GLOB.ccpost_task_category_weights[category_name]
					if(base_weight <= 0)
						continue
					// Average weights prevent oversized families from winning by volume.
					var/list/weighted_templates = categories[category_name]
					var/total_weight = 0
					for(var/weighted_type in weighted_templates)
						total_weight += weighted_templates[weighted_type]
					var/average_weight = total_weight / max(1, length(weighted_templates))
					category_weights[category_name] = base_weight * average_weight / 100
				if(length(category_weights))
					var/chosen_category = pick_weight(category_weights)
					var/chosen_type = pick_weight(categories[chosen_category])
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
		else if(!template.event_only && template.type != /datum/ccpost_task_template/archived_followup)
			board.recent_routine_templates += template.type
			while(length(board.recent_routine_templates) > 3)
				board.recent_routine_templates.Cut(1, 2)
			var/family = template.get_rotation_family()
			board.recent_routine_families += family
			while(length(board.recent_routine_families) > CCPOST_TASK_FAMILY_HISTORY)
				board.recent_routine_families.Cut(1, 2)
			var/family_cooldown = CCPOST_TASK_FAMILY_COOLDOWN
			if(family == "outpost_internal" || family == "sector_installations")
				family_cooldown = CCPOST_TASK_INTERNAL_FAMILY_COOLDOWN
			GLOB.ccpost_tasking_network.family_next_dispatch[family] = world.time + family_cooldown
		qdel(template)
	if(!new_order)
		// No new meaningful routine work is available. Retry instead of
		// immediately recycling an unresolved or recently issued task family.
		schedule_next_assignment(CCPOST_TASK_VARIETY_RETRY_MIN, CCPOST_TASK_VARIETY_RETRY_MAX)
		return
	board.current_order = new_order
	GLOB.ccpost_tasking_network.note_issued(new_order)
	pause_deferred_expiration(board)
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
	if(isobserver(user))
		return UI_INTERACTIVE
	if(!ccpost_can_view_terminal(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/ccpost_tasking/ui_interact(mob/user, datum/tgui/ui)
	if(!ccpost_can_view_terminal(user))
		balloon_alert(user, "central command ID required")
		return
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostTasking", name)
		ui.open()

/obj/machinery/computer/ccpost_tasking/ui_data(mob/user)
	if(!ccpost_can_view_terminal(user))
		return list()
	var/list/data = list()
	data["read_only"] = isobserver(user)
	data["authenticated"] = isobserver(user) || !!session_valid_for(user)
	data["session_owner"] = isobserver(user) ? "Observer" : (tasking_session_name || "")
	var/datum/ccpost_hr_employee/login_employee = GLOB.ccpost_hr_service?.employee_for(user)
	data["identity_detected"] = !!(login_employee && login_employee.employee_role == "Central Command Liaison")
	if(!data["authenticated"])
		return data
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	data["network_terminals"] = length(network.registered_terminals)
	data["network_inboxes"] = length(network.inboxes)
	data["network_completed"] = length(network.shared_history)
	var/active_task_count = 0
	for(var/key in network.inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/other_inbox = network.inboxes[key]
		if(other_inbox.current_order && other_inbox.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
			active_task_count++
	data["network_active_tasks"] = active_task_count
	data["claimable_tasks"] = isobserver(user) ? list() : network.list_claimable(tasking_session_mind)
	data["dispatch_seconds"] = next_assignment_attempt_at ? max(0, round((next_assignment_attempt_at - world.time) / (1 SECONDS))) : 0
	data["dispatch_pending"] = !!next_assignment_attempt_at
	data["dispatch_machine_available"] = !(machine_stat & (NOPOWER | BROKEN))
	data["submitted_report"] = isobserver(user) ? null : report_to_ui_data(submitted_report)

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = isobserver(user) ? null : get_tasking_board()

	if(!tasking_board)
		data["current_order"] = null
		var/list/observer_history = list()
		for(var/datum/ccpost_tasking_order/archived as anything in network.shared_history)
			observer_history += list(order_to_ui_data(archived))
		data["history"] = observer_history
		data["deferred_orders"] = list()
		data["on_hold_orders"] = list()
		data["queued_events"] = 0
		data["queued_priorities"] = list("Critical" = 0, "Priority" = 0, "Elevated" = 0, "Routine" = 0)
		data["queued_events_ready"] = 0
		data["queued_followups"] = 0
		data["queued_incidents"] = list()
		return data

	data["current_order"] = tasking_board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED ? null : order_to_ui_data(tasking_board.current_order)

	expire_overdue_deferrals()
	var/list/history_data = list()
	if(tasking_board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		history_data += list(order_to_ui_data(tasking_board.current_order))

	for(var/datum/ccpost_tasking_order/order as anything in network.shared_history)
		history_data += list(order_to_ui_data(order))

	data["history"] = history_data
	var/list/deferred_data = list()
	for(var/datum/ccpost_tasking_order/deferred as anything in tasking_board.deferred_orders)
		var/list/serialized = order_to_ui_data(deferred)
		serialized["resume_in_seconds"] = max(0, round((deferred.deferred_until - world.time) / (1 SECONDS)))
		serialized["expires_in_seconds"] = max(0, round(((deferred.deferral_expiry_paused_at ? deferred.deferral_expires_at + world.time - deferred.deferral_expiry_paused_at : deferred.deferral_expires_at) - world.time) / (1 SECONDS)))
		deferred_data += list(serialized)
	data["deferred_orders"] = deferred_data
	var/list/on_hold_data = list()
	for(var/datum/ccpost_tasking_order/held as anything in tasking_board.on_hold_orders)
		on_hold_data += list(order_to_ui_data(held))
	data["on_hold_orders"] = on_hold_data
	data["queued_events"] = length(tasking_board.event_task_queue)
	// Reporting eligibility explains why a correctly hooked event can remain queued.
	// Do not reveal event identity or otherwise hidden round-event information.
	var/queued_events_ready = 0
	var/list/priority_counts = list("Critical" = 0, "Priority" = 0, "Elevated" = 0, "Routine" = 0)
	for(var/queued_type in tasking_board.event_task_queue)
		var/datum/ccpost_task_template/queued_template = new queued_type
		// Publicly announced incident orders may be issued with no named contact;
		// the report must instead document attempts to contact station departments.
		if(queued_template.event_only || queued_template.is_eligible())
			queued_events_ready++
		priority_counts[queued_template.priority] = (priority_counts[queued_template.priority] || 0) + 1
		qdel(queued_template)
	data["queued_events_ready"] = queued_events_ready
	var/list/queued_incidents = list()
	for(var/queued_type in tasking_board.event_task_queue)
		var/datum/ccpost_task_template/queued_template = new queued_type
		queued_incidents += list(list(
			"subject" = findtext(queued_template.template_id, "public_") == 1 ? queued_template.subject : "Internal incident review",
			"priority" = queued_template.priority,
			"reason" = tasking_board.current_order && ccpost_incident_priority_rank(tasking_board.current_order.priority) >= ccpost_incident_priority_rank(queued_template.priority) ? "Awaiting resolution of equal or higher priority assignment" : "Awaiting dispatch",
		))
		qdel(queued_template)
	data["queued_incidents"] = queued_incidents
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

	var/list/assessments_ui = list()
	for(var/datum/ccpost_department_assessment/assessment as anything in order.department_assessments)
		assessments_ui += list(list(
			"department_id" = "[assessment.department_id]",
			"department_name" = department_grant_name(assessment.department_id),
			"required" = assessment.required,
			"participated" = assessment.participated,
			"rating" = assessment.rating,
			"assessed_by" = assessment.assessed_by,
			"adjusted_amount" = assessment.participated && assessment.rating ? assessment.adjusted_amount() : null,
			"credited" = assessment.credited,
			"grant_status" = assessment.grant_status,
			"radio_status" = assessment.radio_status
		))

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
		"assigned_to" = order.assigned_to,
		"assigned_terminal" = order.assigned_terminal,
		"audit_events" = order.audit_events,
		"submission_type" = order.submission_type,
		"target_installation_code" = order.target_installation_code,
		"submitted_report_name" = order.submitted_report_name,
		"submitted_report_text" = order.submitted_report_text,
		"submitted_report_markup" = order.submitted_report_markup,
		"archived_paper" = ccpost_archived_paper_to_ui(order.archived_paper),
		"source_order_code" = order.source_order_code,
		"assigned_contact" = order.assigned_contact,
		"contact_unavailable" = order.contact_unavailable,
		"contact_reassignable" = !!order.assigned_contact_mind,
		"assigned_role" = order.assigned_role,
		"deferral_count" = order.deferral_count,
		"held_at" = order.held_at,
		"deferral_reason" = order.deferral_reason,
		"deferred_by" = order.deferred_by,
		"report_stamp_verified" = order.report_centcom_stamp_verified,
		"cooperation_available" = !!length(order.department_assessments),
		"assessments_complete" = order.assessments_complete(),
		"department_assessments" = assessments_ui
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
	if(action == "login")
		if(!login_tasking_session(user))
			balloon_alert(user, "registered Liaison ID required")
		return TRUE
	if(action == "logout")
		if(session_valid_for(user))
			logout_tasking_session()
		return TRUE
	if(!session_valid_for(user))
		return TRUE

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		return FALSE
	tasking_board.last_owner_activity_at = world.time

	switch(action)

		if("claim_abandoned")
			if(GLOB.ccpost_tasking_network.claim_abandoned(user, params["owner_key"], params["order_code"]))
				balloon_alert(user, "assignment transferred")
			else
				balloon_alert(user, "reassignment unavailable")
			return TRUE

		if("reassign_contact")
			var/message = reassign_unavailable_contact(tasking_board.current_order)
			balloon_alert(user, message)
			SStgui.update_uis(src)
			return TRUE

		if("set_cooperation")
			var/datum/ccpost_tasking_order/rated_order = tasking_board.current_order
			if(!rated_order || rated_order.status != CCPOST_TASK_STATUS_ACKNOWLEDGED || rated_order.rewards_issued)
				return TRUE
			var/datum/ccpost_department_assessment/assessment = rated_order.get_department_assessment(params["department_id"])
			if(!assessment || !assessment.participated)
				return TRUE
			var/rating = params["rating"]
			if(!(rating in list("Very Dissatisfied", "Dissatisfied", "Neutral", "Satisfied", "Very Satisfied")))
				return TRUE
			assessment.rating = rating
			assessment.assessed_by = user.name
			rated_order.record_action("Assessment", user.name, "[department_grant_name(assessment.department_id)]: [rating]")
			SStgui.update_uis(src)
			return TRUE

		if("set_department_participation")
			var/datum/ccpost_tasking_order/participation_order = tasking_board.current_order
			if(!participation_order || participation_order.status != CCPOST_TASK_STATUS_ACKNOWLEDGED || participation_order.rewards_issued)
				return TRUE
			var/datum/ccpost_department_assessment/participation_assessment = participation_order.get_department_assessment(params["department_id"])
			if(!participation_assessment || participation_assessment.required)
				return TRUE
			var/participation_choice = params["participating"]
			participation_assessment.participated = ("[participation_choice]" == "1")
			participation_order.record_action("Participation", user.name, "[department_grant_name(participation_assessment.department_id)]: [participation_assessment.participated ? "Yes" : "No"]")
			if(!participation_assessment.participated)
				participation_assessment.rating = null
				participation_assessment.assessed_by = null
			SStgui.update_uis(src)
			return TRUE

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
			order.deferral_expiry_paused_at = 0
			order.deferral_reason = reason
			order.status = CCPOST_TASK_STATUS_DEFERRED
			order.record_action("Deferred", user.name, reason)
			tasking_board.deferred_orders += order
			tasking_board.current_order = null
			if(length(tasking_board.event_task_queue))
				refresh_queued_incident_window()
				schedule_next_assignment(1 SECONDS, 2 SECONDS)
			else
				schedule_next_assignment(CCPOST_TASK_RETRY_MIN, CCPOST_TASK_RETRY_MAX)
			balloon_alert(user, "order deferred")
			SStgui.update_uis(src)
			return TRUE

		if("resume_on_hold")
			if(tasking_board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
				archive_finished_order()
			if(tasking_board.current_order || !length(tasking_board.on_hold_orders) || length(tasking_board.event_task_queue))
				balloon_alert(user, "higher-priority work outstanding")
				return TRUE
			var/datum/ccpost_tasking_order/next_held = tasking_board.on_hold_orders[length(tasking_board.on_hold_orders)]
			if(next_held.order_code != params["order_code"])
				balloon_alert(user, "resume the latest interrupted order first")
				return TRUE
			restore_on_hold_order()
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
			tasking_board.current_order.record_action("Acknowledged", user.name)

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

			// Every budget-bearing task requires a deliberate assessment; Neutral is
			// valid but must be explicitly selected, never assumed.
			if(!tasking_board.current_order.assessments_complete() && !(tasking_board.current_order.template_id == CCPOST_TASK_AUDIT_TEMPLATE_ID && tasking_board.current_order.audit_compliance_points > 0))
				balloon_alert(user, "choose cooperation assessment")
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
			tasking_board.current_order.record_action("Completed", user.name, "Stamped report accepted")
			// Resume deferred-expiry countdown now that the terminal is actionable.
			expire_overdue_deferrals()

			// Issue Operational Allocation and any applicable
			// departmental budget grant.
			apply_task_rewards(
				tasking_board.current_order,
				user
			)
			// CCPost HR: credit the submitting Liaison after rewards are issued.
			ccpost_hr_note_task_completion(user, tasking_board.current_order)
			// Publish immediately for other Liaisons instead of waiting for the next dispatch.
			archive_finished_order()
			if(length(tasking_board.event_task_queue) || length(tasking_board.on_hold_orders))
				// Urgent incident work and held tasks resolve promptly after completion.
				refresh_queued_incident_window()
				schedule_next_assignment(1 SECONDS, 2 SECONDS)
			else
				schedule_next_assignment()

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

	for(var/datum/ccpost_tasking_order/order as anything in GLOB.ccpost_tasking_network.shared_history)
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
#undef CCPOST_TASK_STATUS_ON_HOLD
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

#undef CCPOST_TASK_FIRST_MIN
#undef CCPOST_TASK_FIRST_MAX
#undef CCPOST_TASK_INTERVAL_MIN
#undef CCPOST_TASK_INTERVAL_MAX
#undef CCPOST_TASK_RETRY_MIN
#undef CCPOST_TASK_RETRY_MAX
#undef CCPOST_TASK_INCIDENT_MIN
#undef CCPOST_TASK_INCIDENT_MAX
#undef CCPOST_TASK_ATMOS_GRACE
#undef CCPOST_TASK_INTERVIEW_HISTORY

#undef CCPOST_TASK_FAMILY_COOLDOWN
#undef CCPOST_TASK_INTERNAL_FAMILY_COOLDOWN
#undef CCPOST_TASK_VARIETY_RETRY_MIN
#undef CCPOST_TASK_VARIETY_RETRY_MAX
#undef CCPOST_TASK_CONTACT_SSD_GRACE
#undef CCPOST_TASK_DEPARTMENT_COOLDOWN
#undef CCPOST_TASK_SHARED_ARCHIVE_LIMIT
#undef CCPOST_TASK_REASSIGN_GRACE
