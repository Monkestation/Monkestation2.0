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

#define CCPOST_TASK_FIRST_MIN 30 SECONDS
#define CCPOST_TASK_FIRST_MAX 60 SECONDS
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
	"Command Oversight" = 4,
	"Security Oversight" = 4,
	"Infrastructure Oversight" = 8,
	"Communications Oversight" = 5,
	"Medical Oversight" = 5,
	"Operational Oversight" = 12,
	"Administrative Oversight" = 11,
	"General Oversight" = 4,
	"Audits & Inspections" = 8,
	"Personnel & Civilian Liaison" = 5,
	"Sector Records & Administration" = 24,
	"Research Oversight" = 3,
	"Supply Chain Oversight" = 5,
	"Service Oversight" = 2
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

/datum/ccpost_task_template/proc/is_station_facing()
	return any_station_staff || length(required_staff_accounts) || length(excluded_staff_accounts) || department_reward_id || length(additional_grant_departments)

/proc/ccpost_active_station_population()
	var/count = 0
	for(var/mob/living/carbon/human/person as anything in GLOB.mob_living_list)
		if(!ishuman(person) || QDELETED(person) || !person.client || person.stat == DEAD || !is_station_level(person.z))
			continue
		var/datum/job/job = person.mind?.assigned_role
		if(job?.faction == FACTION_STATION && person.mind.current == person)
			count++
	return count

/datum/ccpost_task_template/proc/contact_candidates()
	var/list/staff = get_available_staff()
	var/list/reachable = list()
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	for(var/mob/living/carbon/human/person as anything in staff)
		var/datum/job/job = person.mind?.assigned_role
		if(!person.client || world.time < (network.contact_next_dispatch[REF(person.mind)] || 0))
			continue
		if(network.department_standdown_active() || SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
			continue
		if(world.time < (network.department_next_dispatch["[job.paycheck_department]"] || 0) || network.has_outstanding_department(job.paycheck_department, null))
			continue
		reachable += person
	return reachable

/datum/ccpost_task_template/proc/is_eligible()
	if(is_station_facing() && !event_only)
		var/minimum_population = 10
		if(length(additional_grant_departments) || template_id == "departmental_compliance" || template_id == "conflicting_accounts")
			minimum_population = 25
		else if(category == "Audits & Inspections" || category == "Security Oversight")
			minimum_population = 20
		else if(template_id == "civilian_interview" || template_id == "personnel_feedback" || template_id == "personnel_visitors")
			minimum_population = 15
		if(ccpost_active_station_population() < minimum_population)
			return FALSE
		if(department_reward_id && (minimum_population >= 25 || category == "Audits & Inspections" || category == "Security Oversight"))
			var/list/department_counts = list()
			for(var/mob/living/carbon/human/person as anything in GLOB.mob_living_list)
				if(!ishuman(person) || !person.client || person.stat == DEAD || !is_station_level(person.z))
					continue
				var/datum/job/job = person.mind?.assigned_role
				if(job?.faction == FACTION_STATION && person.mind.current == person)
					department_counts["[job.paycheck_department]"] = (department_counts["[job.paycheck_department]"] || 0) + 1
			if((department_counts["[department_reward_id]"] || 0) < 2)
				return FALSE
			for(var/department_id in additional_grant_departments)
				if(!(department_counts["[department_id]"] || 0))
					return FALSE
		if(any_station_staff || length(required_staff_accounts) || length(excluded_staff_accounts))
			return length(contact_candidates()) > 0
	return TRUE

/datum/ccpost_task_template/proc/configure_order(datum/ccpost_tasking_order/order, datum/ccpost_logistics_network/logistics_network)
	return

/datum/ccpost_task_template/command_status
	template_id = "command_status"
	rotation_family = "station_command"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "General Operational Status"
	instruction = "Consult existing records or request a concise verbal shift-status update from Command identifying the station alert posture, unresolved critical concerns, and whether any departments need administrative support. Record one confirmed priority or explicitly report that none was identified."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_coordination
	template_id = "command_coordination"
	rotation_family = "station_command"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "Departmental Coordination Review"
	instruction = "Review existing correspondence or ask for one concise example of interdepartmental coordination this shift. Assess whether escalation channels and response responsibilities were clear, and document specific communication failures only where supported by evidence."
	department_reward_id = ACCOUNT_CMD

/datum/ccpost_task_template/command_concern
	template_id = "command_concern"
	rotation_family = "station_command"
	required_staff_accounts = list(ACCOUNT_CMD)
	category = "Command Oversight"
	subject = "Command Concern Inquiry"
	instruction = "Ask Command whether any significant operational risk remains unresolved. If one exists, identify its follow-up owner and the conditions for resolution. Otherwise, record a no-outstanding-concerns result. Corroborate key details where practical and distinguish plans from completed action."
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
	instruction = "Consult available Engineering readings or request a concise verbal account for power, atmosphere, hull integrity, and telecommunications. Identify confirmed deficiencies, current mitigations, and which systems require follow-up."
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
	rotation_family = "outpost_compliance"
	priority = CCPOST_TASK_PRIORITY_ELEVATED
	category = "Internal Compliance"
	subject = "Liaison Outpost Compliance Audit"
	instruction = "Central Command Internal Compliance has selected this installation for a routine audit. Review the outpost's Operational Allocation ledger, freight requisition history, recent Sector Communications responses, and completed tasking records. Submit a concise account of any discrepancies, unexplained expenditures, missing documentation, or procedural violations."

/datum/ccpost_task_template/developing_situation
	template_id = "developing_situation"
	rotation_family = "station_developing_situation"
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

/// Legacy hardware-only incident; never dispatch. Public announcements use public_communications_blackout.
/datum/ccpost_task_template/telecomms_incident
	template_id = "telecomms_incident"
	selection_weight = 0
	rotation_family = "station_communications"
	category = "Infrastructure Oversight"
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
	category = "Infrastructure Oversight"
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
	subject = "Personnel Services Interview"
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
	instruction = "Request a Robotics status report covering current cyborg availability, maintenance needs, service interruptions, and any properly documented safety incidents. If Robotics has no active cyborgs or projects, document readiness and any actual resource constraints rather than inventing an incident. Distinguish equipment issues from unverified misconduct claims."
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


// Expanded routine work pool for the centralized three-Liaison dispatcher.
// Every new family covers a distinct observable review activity and does not
// require an unavailable station department unless explicitly specified.
/datum/ccpost_task_template/outpost_paperwork_quality
	template_id = "outpost_paperwork_quality"
	rotation_family = "outpost_records"
	category = "Administrative Oversight"
	subject = "Administrative Paperwork Quality Review"
	instruction = "Sample the outpost's accessible, nonconfidential tasking or correspondence records. Check whether references, issue dates, stamps, and conclusions are legible and internally consistent. Record concrete documentation gaps and proposed filing improvements. Do not alter or destroy original records."
	selection_weight = 85

/datum/ccpost_task_template/outpost_radio_readiness
	template_id = "outpost_radio_readiness"
	rotation_family = "outpost_radio_readiness"
	category = "Communications Oversight"
	subject = "Outpost Communications Readiness Check"
	instruction = "Check the outpost's official communications equipment, channel reference and current status using ordinary authorized controls. Identify any inaccessible terminals, unanswered procedural questions or observed malfunctions. Do not transmit fake distress messages or interfere with station traffic."
	selection_weight = 85

/datum/ccpost_task_template/outpost_asset_inventory
	template_id = "outpost_asset_inventory"
	rotation_family = "outpost_equipment"
	category = "Operational Oversight"
	subject = "Outpost Equipment Accountability"
	instruction = "Inspect publicly accessible outpost office and logistics equipment against reasonable operational needs. Record missing, damaged or incorrectly stored items, and identify which discrepancies need follow-up with Logistics. No private searches or confiscations are authorized."
	selection_weight = 90

/datum/ccpost_task_template/sector_contact_protocol
	template_id = "sector_contact_protocol"
	rotation_family = "sector_communications"
	category = "Sector Records & Administration"
	subject = "Regional Contact Procedure Verification"
	instruction = "Review the available Sector Communications installation directory and recent nonconfidential correspondence. Confirm that installation contacts, response priorities and escalation procedures are understandable. Document gaps without sending unnecessary requests to remote installations."
	selection_weight = 95

/datum/ccpost_task_template/outpost_supply_contingency
	template_id = "outpost_supply_contingency"
	rotation_family = "outpost_supply_contingency"
	category = "Supply Chain Oversight"
	subject = "Outpost Supply Contingency Assessment"
	instruction = "Use the Logistics Terminal and available supply records to evaluate whether a realistic shortage or delivery disruption could affect outpost operations. If none is currently evident, record existing supplies and one plausible contingency without claiming a shortage occurred. Describe available mitigations; no purchase or restricted requisition is required."
	selection_weight = 85

/datum/ccpost_task_template/outpost_visitor_wayfinding
	template_id = "outpost_visitor_wayfinding"
	rotation_family = "personnel_visitors"
	category = "Personnel & Civilian Liaison"
	subject = "Visitor Reception and Wayfinding Review"
	instruction = "Inspect the outpost's visitor reception guidance, informational pamphlet and authorized visitor approach. Identify unclear directions, accessibility concerns or missing safety instructions. Where no visitors are present, assess the published guidance without inventing an interview."
	selection_weight = 90

/datum/ccpost_task_template/engineering_workorder_coordination
	template_id = "engineering_workorder_coordination"
	rotation_family = "engineering_preventive_maintenance"
	category = "Infrastructure Oversight"
	required_staff_accounts = list(ACCOUNT_ENG)
	department_reward_id = ACCOUNT_ENG
	subject = "Engineering Work Order Coordination"
	instruction = "Contact Engineering about how maintenance requests are received, prioritized and closed during the shift. If available, verify one actual maintenance request or repair, whether documented formally or reported by the responsible Engineer. If none exists, describe the normal process and explicitly record that no example could be verified. Note any genuine need for escalation without directing repairs or inventing defects."
	selection_weight = 90

/datum/ccpost_task_template/medical_communication_review
	template_id = "medical_communication_review"
	rotation_family = "medical_preparedness"
	category = "Medical Oversight"
	required_staff_accounts = list(ACCOUNT_MED)
	department_reward_id = ACCOUNT_MED
	subject = "Medical Department Communications Review"
	instruction = "Ask Medical about general procedures for routing urgent patient requests and communicating treatment availability to Command or other departments. Assess clarity and delays using confirmed operational examples without collecting confidential patient records."
	selection_weight = 85

/datum/ccpost_task_template/sector_record_certification
	template_id = "sector_record_certification"
	rotation_family = "sector_records"
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
	rotation_family = "sector_status"
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
	rotation_family = "sector_communications"
	category = "Sector Records & Administration"
	subject = "Sector Communications Audit"
	selection_weight = 65
	instruction = "Use the Sector Communications Terminal to inspect recent regional messages, pending requests, and their recorded outcomes. Submit a stamped administrative report distinguishing outstanding requests from resolved work. State explicitly when no discrepancies are found; do not invent correspondence."

/datum/ccpost_task_template/installation_performance_review
	template_id = "installation_performance_review"
	rotation_family = "sector_status"
	category = "Sector Records & Administration"
	subject = "Regional Installation Performance Review"
	selection_weight = 70
	instruction = "Review a regional installation's present condition, public administrative status and recorded history via Remote Oversight. Compare current findings with prior records and submit a stamped report identifying changes, unresolved concerns and any uncertainties."

/datum/ccpost_task_template/logistics_expenditure_review
	template_id = "logistics_expenditure_review"
	rotation_family = "outpost_financial"
	category = "Audits & Inspections"
	subject = "Outpost Logistics Expenditure Review"
	selection_weight = 55
	instruction = "Inspect the Outpost Logistics allocation ledger and shipment history. Reconcile recorded requisitions with operational needs and identify any unconfirmed or exceptional transactions. Submit stamped findings. No expenditure automatically implies misconduct."

/datum/ccpost_task_template/records_reconciliation
	template_id = "records_reconciliation"
	rotation_family = "outpost_records"
	category = "Administrative Oversight"
	subject = "Administrative Records Reconciliation"
	selection_weight = 55
	instruction = "Compare completed Tasking Terminal records with relevant correspondence or regional installation records, where available. Check for unresolved references and inconsistent entries. Submit a stamped reconciliation report. Clearly identify records not available for verification."

/datum/ccpost_task_template/outpost_operational_readiness
	template_id = "outpost_operational_readiness"
	rotation_family = "outpost_equipment"
	category = "Operational Oversight"
	subject = "Outpost Operational Readiness Assessment"
	selection_weight = 45
	instruction = "Inspect the outpost's communications, tasking, logistics, emergency access and visitor transport equipment using ordinary authorized controls. Document actual deficiencies and maintenance needs, or confirm readiness where observed. Submit a stamped report. Do not interfere with active security defenses to conduct this review."

/datum/ccpost_task_template/outpost_emergency_readiness
	template_id = "outpost_emergency_readiness"
	rotation_family = "outpost_emergency_readiness"
	category = "Operational Oversight"
	subject = "Installation Emergency Preparedness"
	instruction = "Review available evacuation routes, emergency equipment and published emergency procedures. Record readiness and any practical improvements. Do not open restricted compartments or operate defensive equipment."

/datum/ccpost_task_template/outpost_freight_readiness
	template_id = "outpost_freight_readiness"
	rotation_family = "outpost_freight_readiness"
	category = "Supply Chain Oversight"
	subject = "Regional Freight Readiness"
	instruction = "Review freight intake, outbound routing and available manifests. Check for blocked access or unresolved freight records. Coordinate findings with local Security without interrupting active inspections."

/datum/ccpost_task_template/sector_continuity
	template_id = "sector_continuity"
	rotation_family = "sector_continuity"
	category = "Sector Records & Administration"
	subject = "Regional Continuity Assessment"
	instruction = "Compare the regional facility status records and freight advisories. Identify a dependency that could affect the outpost and recommend a proportionate contingency. No additional correspondence is required."

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
	if(!participated || !rating || rating == "Not Assessed")
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
	/// A report inserted while this order was active and later switched into standby.
	var/obj/item/paper/standby_report

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
	/// Stable identity for a single genuine emergency; not its display template.
	var/incident_key
	/// Offer remains associated with the assignment, not the physical terminal.
	var/voluntary_offer_expires_at = 0
	/// One successful voluntary transfer per assignment; abandoned recovery is separate.
	var/voluntary_transfer_count = 0
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
	QDEL_NULL(standby_report)
	return ..()

/// Returns the Operational Allocation reward for this task.
///
/// Task value is determined by its priority rather than being configured
/// individually on every assignment template.
/datum/ccpost_tasking_order/proc/get_allocation_reward()
	if(template_id == "security_freight")
		return 0
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
	for(var/datum/ccpost_department_assessment/assessment as anything in department_assessments)
		if(assessment.participated && !assessment.rating)
			return FALSE
	return TRUE

/obj/item/encryptionkey/ccpost_tasking_grants
	name = "Central Command departmental grant transceiver key"
	SETUP_MAP_ICONS("cypherkey_basic", "/obj/item/encryptionkey/ccpost_tasking_grants")
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
	/// One additional assigned investigation. Only one slot is operational at once.
	var/datum/ccpost_tasking_order/standby_order

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
	var/max_deferred_orders = 2
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
	QDEL_NULL(standby_order)
	QDEL_LIST(deferred_orders)
	QDEL_LIST(on_hold_orders)
	QDEL_LIST(followup_orders)
	return ..()

// One round-long Tasking Network. Every authenticated Liaison has a personal
// inbox, while the audit archive, serial numbers, department cooldowns and
// incident de-duplication are outpost-wide. No payroll data is owned here.
/datum/ccpost_tasking_network
	var/list/inboxes = list() // REF(mind) -> private nonphysical tasking board
	var/obj/item/circuitboard/computer/ccpost_tasking/security_board
	var/list/security_history = list()
	var/list/security_terminals = list()
	var/list/security_completed_templates = list()
	var/security_next_routine_at = 0
	var/security_freight_reference
	var/security_freight_arrived_at_bay = FALSE
	var/security_compromise_pending = FALSE
	var/list/shared_history = list() // completed/expired task records
	var/list/registered_terminals = list()
	var/list/family_next_dispatch = list()
	var/list/department_next_dispatch = list()
	var/list/contact_next_dispatch = list()
	var/next_station_dispatch = 0
	/// Outpost-wide pause on new departmental paperwork, shared by every Liaison.
	var/department_standdown_until = 0
	var/first_routine_intake_at = 0
	/// Prevent repeated actual grants even from different incident template families.
	var/list/department_next_grant = list()
	var/list/event_next_dispatch = list()
	var/next_order_number = 1
	var/max_history = CCPOST_TASK_SHARED_ARCHIVE_LIMIT
	var/obj/machinery/ccpost_tasking_server/server
	var/list/pending_requests = list()
	var/list/dispatch_log = list()
	var/list/recent_routine_templates = list()
	var/list/recent_routine_families = list()
	var/list/recent_routine_categories = list()
	var/list/routine_dispatch_counts = list()
	/// Recently completed work blocks ONLY new routine assignments for this mind.
	var/list/routine_cooldown_until = list()
	var/last_routine_recipient_key
	/// Routine intake and allocation are separate network-wide timers.
	var/routine_timer
	var/next_routine_at = 0
	var/routine_dispatch_timer
	var/next_routine_dispatch_at = 0
	/// Lightweight queued routine work, allocated one at a time rather than issuing immediately.
	var/routine_queue_count = 0
	var/initial_routine_batch_sent = FALSE
	/// Only the most recent 20 minutes affect routine assignment fairness.
	var/list/recent_routine_dispatches = list()
	var/routine_dispatch_active = FALSE
	/// Shared availability check for both administrative networks.
	var/admin_network_was_online = FALSE
	var/admin_outage_started_at = 0
	var/total_dispatches = 0
	var/total_faults = 0
	/// Exactly one naturally occurring server fault per round, even after replacement.
	var/natural_fault_occurred = FALSE
	var/list/telemetry_history = list()

/datum/ccpost_tasking_network/Destroy()
	if(routine_timer)
		deltimer(routine_timer)
	if(routine_dispatch_timer)
		deltimer(routine_dispatch_timer)
	QDEL_LIST(pending_requests)
	QDEL_LIST_ASSOC_VAL(inboxes)
	QDEL_NULL(security_board)
	QDEL_LIST(security_history)
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
	if(!inbox || !inbox.owner_mind || inbox.owner_mind == new_owner)
		return FALSE
	if(!inbox.standby_order && (!inbox.current_order || inbox.current_order.status == CCPOST_TASK_STATUS_COMPLETED))
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
		var/list/transferable = list()
		if(inbox.current_order && inbox.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
			transferable += inbox.current_order
		if(inbox.standby_order && !inbox.standby_order.standby_report)
			transferable += inbox.standby_order
		for(var/datum/ccpost_tasking_order/order as anything in transferable)
			result += list(list(
				"owner_key" = key,
				"order_code" = order.order_code,
				"subject" = order.subject,
				"assigned_to" = order.assigned_to,
				"priority" = order.priority
			))
	return result

/datum/ccpost_tasking_network/proc/claim_abandoned(mob/user, from_key, expected_code)
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	if(!employee || employee.employee_role != "Central Command Liaison")
		return FALSE
	var/obj/item/circuitboard/computer/ccpost_tasking/from_inbox = inboxes["[from_key]"]
	var/obj/item/circuitboard/computer/ccpost_tasking/to_inbox = get_inbox(employee.employee_mind)
	if(!from_inbox || !to_inbox || to_inbox.current_order || to_inbox.standby_order || length(to_inbox.on_hold_orders) || !can_claim_inbox(from_inbox, employee.employee_mind))
		return FALSE
	var/datum/ccpost_tasking_order/order
	if(from_inbox.current_order?.order_code == expected_code)
		order = from_inbox.current_order
	else if(from_inbox.standby_order?.order_code == expected_code)
		order = from_inbox.standby_order
	if(!order || order.status == CCPOST_TASK_STATUS_COMPLETED || order.standby_report)
		return FALSE
	// The old user's inserted physical report cannot be consumed by the new
	// owner. Ensure no terminal still holds an authenticated old session.
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
		if(terminal.tasking_session_mind == from_inbox.owner_mind)
			terminal.logout_tasking_session()
	if(from_inbox.current_order == order)
		from_inbox.current_order = null
	else
		from_inbox.standby_order = null
	to_inbox.current_order = order
	// Invalidate any voluntary offer from the prior owner during recovery.
	order.voluntary_offer_expires_at = 0
	var/old_owner = order.assigned_to
	order.assigned_to = employee.employee_name
	order.owner_key = REF(employee.employee_mind)
	order.record_action("Reassigned", user.name, "Previous assignee: [old_owner]. Inactive personnel transfer.")
	to_inbox.last_owner_activity_at = world.time
	refresh_terminals()
	return TRUE

// Voluntary reassignment is an offered transfer, NOT abandonment recovery.
// All ownership, evidence, and recipient checks are repeated at claim time.
/datum/ccpost_tasking_network/proc/voluntary_order_from_inbox(obj/item/circuitboard/computer/ccpost_tasking/inbox, expected_code)
	if(!inbox || !istext(expected_code))
		return null
	if(inbox.current_order?.order_code == expected_code && inbox.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
		return inbox.current_order
	if(inbox.standby_order?.order_code == expected_code)
		return inbox.standby_order
	for(var/datum/ccpost_tasking_order/deferred as anything in inbox.deferred_orders)
		if(deferred.order_code == expected_code && deferred.status == CCPOST_TASK_STATUS_DEFERRED)
			return deferred
	return null

/datum/ccpost_tasking_network/proc/voluntary_order_can_transfer(obj/item/circuitboard/computer/ccpost_tasking/inbox, datum/ccpost_tasking_order/order)
	if(!inbox || !order || order.owner_key != REF(inbox.owner_mind) || order.rewards_issued || order.voluntary_transfer_count)
		return FALSE
	if(order.priority == CCPOST_TASK_PRIORITY_PRIORITY || order.priority == CCPOST_TASK_PRIORITY_CRITICAL || order.template_id == CCPOST_TASK_AUDIT_TEMPLATE_ID)
		return FALSE
	if(order.on_hold_report || order.standby_report || order.status == CCPOST_TASK_STATUS_COMPLETED)
		return FALSE
	// Do not let a transfer steal paper physically inserted in a signed-in desk.
	if(inbox.current_order == order)
		for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
			if(terminal.tasking_session_mind == inbox.owner_mind && terminal.submitted_report)
				return FALSE
	return TRUE

/datum/ccpost_tasking_network/proc/offer_voluntary_order(mob/user, expected_code)
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	if(!employee || employee.employee_role != "Central Command Liaison")
		return FALSE
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = get_inbox(employee.employee_mind)
	var/datum/ccpost_tasking_order/order = voluntary_order_from_inbox(inbox, expected_code)
	if(!voluntary_order_can_transfer(inbox, order))
		return FALSE
	if(order.status == CCPOST_TASK_STATUS_DEFERRED)
		var/effective_deadline = order.deferral_expires_at + (order.deferral_expiry_paused_at ? world.time - order.deferral_expiry_paused_at : 0)
		if(world.time >= effective_deadline)
			return FALSE
	// One outstanding offer per Liaison, regardless of which slot holds it.
	var/list/my_orders = list()
	if(inbox.current_order)
		my_orders += inbox.current_order
	if(inbox.standby_order)
		my_orders += inbox.standby_order
	my_orders += inbox.deferred_orders
	for(var/datum/ccpost_tasking_order/other as anything in my_orders)
		if(other != order && other.voluntary_offer_expires_at > world.time)
			return FALSE
	if(order.voluntary_offer_expires_at > world.time)
		return FALSE
	order.voluntary_offer_expires_at = world.time + 10 MINUTES
	order.record_action("Transfer Offered", user.name, "Voluntary reassignment offered for ten minutes")
	addtimer(CALLBACK(src, PROC_REF(expire_voluntary_offer), REF(employee.employee_mind), order.order_code, order.voluntary_offer_expires_at), 10 MINUTES)
	refresh_terminals()
	return TRUE

/datum/ccpost_tasking_network/proc/expire_voluntary_offer(owner_key, expected_code, expected_expiry)
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes["[owner_key]"]
	var/datum/ccpost_tasking_order/order = voluntary_order_from_inbox(inbox, expected_code)
	if(!order || order.voluntary_offer_expires_at != expected_expiry || world.time < expected_expiry)
		return
	order.voluntary_offer_expires_at = 0
	order.record_action("Offer Expired", "CENTRAL COMMAND", "No Liaison claimed the voluntary transfer")
	refresh_terminals()

/datum/ccpost_tasking_network/proc/cancel_voluntary_offer(mob/user, expected_code)
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	if(!employee || employee.employee_role != "Central Command Liaison")
		return FALSE
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = get_inbox(employee.employee_mind)
	var/datum/ccpost_tasking_order/order = voluntary_order_from_inbox(inbox, expected_code)
	if(!order || order.voluntary_offer_expires_at <= world.time)
		return FALSE
	order.voluntary_offer_expires_at = 0
	order.record_action("Offer Withdrawn", user.name)
	refresh_terminals()
	return TRUE

/datum/ccpost_tasking_network/proc/list_voluntary_offers(datum/mind/requester, own_offers = FALSE)
	var/list/result = list()
	for(var/key in inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
		if(!inbox?.owner_mind || (own_offers ? inbox.owner_mind != requester : inbox.owner_mind == requester))
			continue
		var/list/potential = list()
		if(inbox.current_order)
			potential += inbox.current_order
		if(inbox.standby_order)
			potential += inbox.standby_order
		potential += inbox.deferred_orders
		for(var/datum/ccpost_tasking_order/order as anything in potential)
			if(order.voluntary_offer_expires_at <= world.time || (!own_offers && !voluntary_order_can_transfer(inbox, order)))
				continue
			result += list(list(
				"owner_key" = key,
				"order_code" = order.order_code,
				"subject" = order.subject,
				"priority" = order.priority,
				"assigned_to" = order.assigned_to,
				"origin" = inbox.current_order == order ? "Active" : (inbox.standby_order == order ? "Standby" : "Deferred"),
				"expires_in_seconds" = max(0, round((order.voluntary_offer_expires_at - world.time) / (1 SECONDS)))
			))
	return result

/datum/ccpost_tasking_network/proc/claim_voluntary_order(obj/machinery/computer/ccpost_tasking/receiving_terminal, mob/user, from_key, expected_code)
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	if(!employee || employee.employee_role != "Central Command Liaison" || receiving_terminal.tasking_session_mind != employee.employee_mind || !receiving_terminal.tasking_desk_access(user))
		return FALSE
	if(receiving_terminal.submitted_report)
		return FALSE
	var/obj/item/circuitboard/computer/ccpost_tasking/from_inbox = inboxes["[from_key]"]
	var/obj/item/circuitboard/computer/ccpost_tasking/to_inbox = get_inbox(employee.employee_mind)
	if(!from_inbox || !to_inbox || from_inbox == to_inbox || to_inbox.current_order || to_inbox.standby_order || length(to_inbox.on_hold_orders) || length(to_inbox.event_task_queue))
		return FALSE
	var/datum/ccpost_tasking_order/order = voluntary_order_from_inbox(from_inbox, expected_code)
	if(!order || order.voluntary_offer_expires_at <= world.time || !voluntary_order_can_transfer(from_inbox, order))
		return FALSE
	// A deferred order may only be claimed while its original, effective
	// deferral deadline is still valid. Transfers cannot resurrect expired work.
	var/was_deferred = (order in from_inbox.deferred_orders)
	if(was_deferred)
		var/obj/machinery/computer/ccpost_tasking/old_terminal
		for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
			if(terminal.tasking_session_mind == from_inbox.owner_mind)
				old_terminal = terminal
				break
		if(old_terminal)
			old_terminal.expire_overdue_deferrals()
		if(!(order in from_inbox.deferred_orders))
			return FALSE
		var/effective_deadline = order.deferral_expires_at + (order.deferral_expiry_paused_at ? world.time - order.deferral_expiry_paused_at : 0)
		if(world.time >= effective_deadline)
			return FALSE
	// Single-threaded ownership transition: remove from original slot before
	// exposing the assignment in the claimant's inbox.
	if(from_inbox.current_order == order)
		from_inbox.current_order = null
	else if(from_inbox.standby_order == order)
		from_inbox.standby_order = null
	else
		from_inbox.deferred_orders -= order
	if(was_deferred)
		order.status = order.status_before_deferral
		order.deferral_expiry_paused_at = 0
		order.deferral_expires_at = 0
		order.deferred_until = 0
	order.voluntary_offer_expires_at = 0
	order.voluntary_transfer_count++
	var/previous_owner = order.assigned_to
	order.assigned_to = employee.employee_name
	order.owner_key = REF(employee.employee_mind)
	order.assigned_terminal = "[receiving_terminal.x],[receiving_terminal.y],[receiving_terminal.z]"
	order.record_action("Reassigned", user.name, "Voluntary transfer from [previous_owner] to [employee.employee_name]; prior deferral retained in audit")
	to_inbox.current_order = order
	to_inbox.last_owner_activity_at = world.time
	// Ownership changes are not new assignments: no new reward, serial, grant
	// cooldown, or additional routine-dispatch count is issued.
	routine_cooldown_until[REF(from_inbox.owner_mind)] = max(routine_cooldown_until[REF(from_inbox.owner_mind)] || 0, world.time + 2 MINUTES)
	log_dispatch("TRANSFER", "[order.order_code] voluntarily transferred from [previous_owner] to [employee.employee_name].")
	for(var/obj/machinery/computer/ccpost_tasking/sender_terminal as anything in registered_terminals)
		if(sender_terminal.tasking_session_mind != from_inbox.owner_mind)
			continue
		// The sender may still have a previously assigned standby task.
		if(!from_inbox.current_order && from_inbox.standby_order)
			sender_terminal.activate_standby_order()
		sender_terminal.expire_overdue_deferrals()
		break
	receiving_terminal.print_order(order)
	refresh_terminals()
	return TRUE

/datum/ccpost_tasking_network/proc/has_outstanding_family(family, obj/item/circuitboard/computer/ccpost_tasking/except_inbox)
	if(!family)
		return FALSE
	for(var/datum/ccpost_dispatch_request/pending as anything in pending_requests)
		var/datum/ccpost_task_template/queued_template = new pending.template_type
		var/matching_family = queued_template.get_rotation_family() == family
		qdel(queued_template)
		if(matching_family)
			return TRUE
	for(var/key in inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
		if(inbox == except_inbox)
			continue
		if(inbox.current_order?.rotation_family == family && inbox.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
			return TRUE
		if(inbox.standby_order?.rotation_family == family)
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
		if(inbox.standby_order)
			orders += inbox.standby_order
		orders += inbox.deferred_orders
		orders += inbox.on_hold_orders
		for(var/datum/ccpost_tasking_order/order as anything in orders)
			if(order.status == CCPOST_TASK_STATUS_COMPLETED)
				continue
			if(order.assigned_department == department_id || order.get_department_assessment(department_id))
				return TRUE
	return FALSE

/datum/ccpost_tasking_network/proc/begin_department_standdown()
	department_standdown_until = max(department_standdown_until, world.time + 10 MINUTES)

/datum/ccpost_tasking_network/proc/department_standdown_active()
	return world.time < department_standdown_until

/// Internal work remains available. Only genuinely urgent incident reviews,
/// which attach_staffing_context makes records-only, bypass the shared pause.
/datum/ccpost_tasking_network/proc/department_dispatch_allowed(datum/ccpost_task_template/template)
	if(!template || template.type == /datum/ccpost_task_template/telecomms_incident)
		return FALSE
	if(!template.is_station_facing())
		return TRUE
	if(template.event_only && ccpost_incident_priority_rank(template.priority) >= 3)
		return TRUE
	return !department_standdown_active() && SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED

/datum/ccpost_tasking_network/proc/may_issue_template(datum/ccpost_task_template/template, obj/item/circuitboard/computer/ccpost_tasking/current_inbox)
	if(!department_dispatch_allowed(template))
		return FALSE
	if(template.is_station_facing() && !template.event_only)
		if(!first_routine_intake_at || world.time < first_routine_intake_at + 10 MINUTES || world.time < next_station_dispatch || SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
			return FALSE
		if(count_station_orders() >= 2)
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
		if(has_outstanding_department(department_id, null))
			return FALSE
	return TRUE

/datum/ccpost_tasking_network/proc/count_station_orders()
	var/count = 0
	for(var/key in inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
		var/list/orders = list()
		if(inbox.current_order)
			orders += inbox.current_order
		if(inbox.standby_order)
			orders += inbox.standby_order
		orders += inbox.deferred_orders
		orders += inbox.on_hold_orders
		for(var/datum/ccpost_tasking_order/order as anything in orders)
			if(order.status != CCPOST_TASK_STATUS_COMPLETED && order.assigned_contact_mind && !order.source_order_code)
				count++
	return count

/datum/ccpost_tasking_network/proc/note_issued(datum/ccpost_tasking_order/order, start_standdown = TRUE)
	if(!order)
		return
	if(order.assigned_contact_mind)
		next_station_dispatch = world.time + 10 MINUTES
	if(start_standdown && (order.assigned_contact_mind || order.assigned_department || length(order.department_assessments)))
		begin_department_standdown()
	if(order.assigned_department)
		department_next_dispatch["[order.assigned_department]"] = world.time + CCPOST_TASK_DEPARTMENT_COOLDOWN
	var/datum/mind/contact = order.assigned_contact_mind?.resolve()
	if(contact)
		contact_next_dispatch[REF(contact)] = world.time + 30 MINUTES
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

// Server-owned dispatch requests have absolute deadlines. Removing a queued
// request never deletes a Liaison's assigned order or the incident record.
/datum/ccpost_dispatch_request
	var/template_type
	var/incident_key
	var/priority
	var/priority_rank
	var/received_at
	var/expires_at
	var/observation

/datum/ccpost_dispatch_request/New(_template_type, _incident_key, _priority, _observation, lifetime)
	. = ..()
	template_type = _template_type
	incident_key = _incident_key
	priority = _priority
	priority_rank = ccpost_incident_priority_rank(_priority)
	received_at = world.time
	expires_at = world.time + lifetime
	observation = _observation

// All actual generation and assignment distribution is coordinated here. The
// physical server is an operational gateway; network records survive its loss.
/datum/ccpost_tasking_network/proc/server_online()
	return !GLOB.ccpost_outpost_signal_lost && server && !QDELETED(server) && server.operational()

/datum/ccpost_tasking_network/proc/server_status()
	if(GLOB.ccpost_outpost_signal_lost)
		return "INSTALLATION OFFLINE"
	if(!server || QDELETED(server))
		return "SERVER MISSING"
	if(server.machine_stat & BROKEN)
		return "SERVER DAMAGED"
	if(server.machine_stat & NOPOWER)
		return "POWER INTERRUPTED"
	if(server.recalibrating)
		return "RECALIBRATING"
	if(server.faulted)
		return "SYNCHRONIZATION FAULT"
	if(server.calibrating)
		return "INITIALIZING"
	return "ONLINE"

/datum/ccpost_tasking_network/proc/refresh_admin_terminals()
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
		if(!QDELETED(terminal))
			SStgui.update_uis(terminal)
	if(GLOB.ccpost_sector_network)
		GLOB.ccpost_sector_network.refresh_comms_terminals()
	if(server && !QDELETED(server))
		SStgui.update_uis(server)

/// Run on availability transitions, not every tick. All personal and shared
/// records remain in their owning datums when hardware is unavailable.
/datum/ccpost_tasking_network/proc/note_admin_server_state()
	var/current_online = server_online()
	if(current_online == admin_network_was_online)
		return
	admin_network_was_online = current_online
	if(!current_online)
		admin_outage_started_at = world.time
		if(routine_timer)
			deltimer(routine_timer)
			routine_timer = null
		next_routine_at = 0
		if(routine_dispatch_timer)
			deltimer(routine_dispatch_timer)
			routine_dispatch_timer = null
		next_routine_dispatch_at = 0
		GLOB.ccpost_sector_network?.pause_administrative_network()
		log_dispatch("NETWORK OFFLINE", "Local administrative server: [server_status()].")
	else
		if(admin_outage_started_at)
			var/outage_duration = max(0, world.time - admin_outage_started_at)
			for(var/datum/ccpost_dispatch_request/request as anything in pending_requests)
				request.expires_at += outage_duration
			for(var/key in inboxes)
				var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
				if(!inbox)
					continue
				for(var/datum/ccpost_tasking_order/deferred as anything in inbox.deferred_orders)
					if(deferred.deferred_until)
						deferred.deferred_until += outage_duration
					if(deferred.deferral_expires_at)
						deferred.deferral_expires_at += outage_duration
			admin_outage_started_at = 0
		GLOB.ccpost_sector_network?.resume_administrative_network()
		log_dispatch("NETWORK ONLINE", "Administrative routing restored.")
	refresh_admin_terminals()

/datum/ccpost_tasking_network/proc/record_server_telemetry()
	telemetry_history += list(list(
		"time" = station_time_timestamp(),
		"queue" = length(pending_requests) + routine_queue_count,
		"dispatched" = total_dispatches,
		"online" = server_online() ? 1 : 0
	))
	if(length(telemetry_history) > 30)
		telemetry_history.Cut(1, 2)

/datum/ccpost_tasking_network/proc/log_dispatch(event_name, details)
	if(event_name == "DISPATCHED" || event_name == "ROUTINE")
		total_dispatches++
	dispatch_log.Insert(1, "[station_time_timestamp()] | [event_name] | [details]")
	if(length(dispatch_log) > 35)
		dispatch_log.Cut(36)
	if(server && !QDELETED(server))
		SStgui.update_uis(server)

/datum/ccpost_tasking_network/proc/prune_queue()
	// Keep queued incident deadlines frozen throughout recoverable outages.
	// Time is added back by note_admin_server_state() on recovery.
	if(!server_online())
		return
	// Incident keys are often unique to an alarm cycle. Expired cooldowns
	// have no reason to accumulate for an entire round.
	for(var/incident_key in event_next_dispatch.Copy())
		if(world.time >= event_next_dispatch[incident_key])
			event_next_dispatch -= incident_key
	for(var/datum/ccpost_dispatch_request/request as anything in pending_requests.Copy())
		if(request.template_type != /datum/ccpost_task_template/telecomms_incident && world.time < request.expires_at)
			continue
		pending_requests -= request
		log_dispatch("EXPIRED", "Unassigned [request.priority] request [request.incident_key] expired after its distribution window.")
		qdel(request)

/datum/ccpost_tasking_network/proc/has_outstanding_incident(incident_key)
	if(!incident_key)
		return FALSE
	for(var/key in inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = inboxes[key]
		if(inbox.current_order?.incident_key == incident_key && inbox.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
			return TRUE
		if(inbox.standby_order?.incident_key == incident_key)
			return TRUE
		for(var/datum/ccpost_tasking_order/held as anything in inbox.on_hold_orders)
			if(held.incident_key == incident_key)
				return TRUE
		for(var/datum/ccpost_tasking_order/deferred as anything in inbox.deferred_orders)
			if(deferred.incident_key == incident_key)
				return TRUE
	return FALSE

/datum/ccpost_tasking_network/proc/queue_event_task(template_type, cooldown_duration = 12 MINUTES, observation = null, incident_key = null)
	if(!template_type || template_type == /datum/ccpost_task_template/telecomms_incident)
		return FALSE
	prune_queue()
	var/datum/ccpost_task_template/template = new template_type
	if(!template)
		return FALSE
	var/template_id = template.template_id
	var/priority = template.priority
	var/rank = ccpost_incident_priority_rank(priority)
	var/key = incident_key || "[template_id]"
	var/departmental_incident = template.is_station_facing()
	qdel(template)
	if(world.time < (event_next_dispatch[key] || 0))
		return FALSE
	if(has_outstanding_incident(key))
		return FALSE
	for(var/datum/ccpost_dispatch_request/existing as anything in pending_requests)
		if(existing.incident_key == key)
			// The first detection determines expiry; repeated alarms cannot prolong it.
			return FALSE
	// Reserve two of the six slots for urgent work. An existing urgent
	// request does NOT count against the four nonurgent slots.
	var/nonurgent_count = 0
	var/datum/ccpost_dispatch_request/lowest
	for(var/datum/ccpost_dispatch_request/candidate as anything in pending_requests)
		if(candidate.priority_rank <= 2)
			nonurgent_count++
		if(candidate.priority_rank < rank && (!lowest || candidate.priority_rank < lowest.priority_rank))
			lowest = candidate
	var/nonurgent_limit_reached = rank <= 2 && nonurgent_count >= 4
	var/total_limit_reached = length(pending_requests) >= 6
	if(nonurgent_limit_reached || total_limit_reached)
		// Never displace urgent work to make space for a nonurgent request.
		if(!lowest || (rank <= 2 && lowest.priority_rank > 2))
			log_dispatch("REJECTED", "Queue capacity reached; [key] has no lower-priority request to replace.")
			return FALSE
		pending_requests -= lowest
		log_dispatch("SUPERSEDED", "[lowest.incident_key] replaced by [key].")
		qdel(lowest)
	var/lifetime = rank >= 3 ? 20 MINUTES : 15 MINUTES
	var/datum/ccpost_dispatch_request/request = new(template_type, key, priority, istext(observation) ? copytext(observation, 1, 301) : null, lifetime)
	pending_requests += request
	// Only a newly accepted incident starts the pause; duplicate observations
	// cannot refresh it or the original request deadline.
	if(departmental_incident)
		begin_department_standdown()
	// Keep the combined six-slot ceiling AND two emergency-reserved slots.
	var/nonurgent_pending = 0
	for(var/datum/ccpost_dispatch_request/queued_request as anything in pending_requests)
		if(queued_request.priority_rank <= 2)
			nonurgent_pending++
	while(routine_queue_count > 0 && (length(pending_requests) + routine_queue_count > 6 || nonurgent_pending + routine_queue_count > 4))
		routine_queue_count--
		log_dispatch("SUPERSEDED", "Routine request displaced by incoming incident [key].")
	event_next_dispatch[key] = world.time + cooldown_duration
	log_dispatch("RECEIVED", "[priority] incident [key] entered the central queue.")
	// Event callbacks only queue work; dispatch occurs on the following tick.
	addtimer(CALLBACK(src, PROC_REF(dispatch_pending)), 1 SECONDS)
	return TRUE

/datum/ccpost_tasking_network/proc/select_terminal(priority_rank = 1, preemption_allowed = FALSE, list/excluded_terminals = null, routine_only = FALSE)
	var/obj/machinery/computer/ccpost_tasking/best
	var/best_score = INFINITY
	var/best_is_busy = FALSE
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
		if(QDELETED(terminal) || (terminal.machine_stat & (BROKEN | NOPOWER)) || !terminal.tasking_session_mind)
			continue
		// A dispatch pass can issue at most one assignment to each workstation.
		if(excluded_terminals && (terminal in excluded_terminals))
			continue
		var/mob/living/carbon/human/person = terminal.tasking_session_mind.current
		if(!person?.client || !terminal.session_valid_for(person))
			continue
		var/identity_key = REF(terminal.tasking_session_mind)
		if(routine_only && world.time < (routine_cooldown_until[identity_key] || 0))
			continue
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = terminal.get_tasking_board()
		if(!inbox)
			continue
		var/active_rank = inbox.current_order ? ccpost_incident_priority_rank(inbox.current_order.priority) : 0
		if(inbox.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
			active_rank = 0
		if(routine_only)
			// Only one additional ordinary assignment may wait in standby.
			// Emergency and preempted work are not candidates for multitasking.
			if(inbox.standby_order || length(inbox.on_hold_orders) || active_rank >= ccpost_incident_priority_rank(CCPOST_TASK_PRIORITY_PRIORITY))
				continue
		else if(active_rank && (!preemption_allowed || priority_rank <= active_rank || length(inbox.on_hold_orders) >= inbox.max_on_hold_orders))
			continue
		var/score = (active_rank ? 1500 + active_rank * 150 : 0) + get_recent_routine_count(identity_key) * 15 + length(inbox.on_hold_orders) * 40 + length(inbox.deferred_orders) * 20
		// A Liaison with incoming Sector Communications should be less likely
		// to receive new routine paperwork while another Liaison is free.
		if(routine_only && GLOB.ccpost_sector_network)
			for(var/datum/ccpost_sector_message/sector_message as anything in GLOB.ccpost_sector_network.sector_messages)
				if(sector_message.resolution_status == "PENDING" && sector_message.assigned_mind == terminal.tasking_session_mind)
					score += sector_message.message_type == "REQUEST" ? 100 : 50
			if(GLOB.ccpost_sector_network.active_sector_paperwork?.assigned_mind == terminal.tasking_session_mind)
				score += 150
		if(routine_only && identity_key == last_routine_recipient_key)
			score += 500
		// An idle Liaison ALWAYS outranks a standby candidate, regardless
		// of cumulative historic task counts or category weights.
		var/is_busy = !!active_rank
		if(routine_only && best)
			if(is_busy && !best_is_busy)
				continue
			if(!is_busy && best_is_busy)
				best_score = INFINITY
		if(score < best_score)
			best = terminal
			best_score = score
			best_is_busy = is_busy
	return best

/datum/ccpost_tasking_network/proc/dispatch_pending()
	prune_queue()
	if(!server_online() || !length(pending_requests))
		return
	// A failed staffing check for one request must not stall the other queued
	// requests. Never retry the same failed request indefinitely in this pass.
	// Each terminal receives at most one new incident during the pass.
	var/list/skipped_requests = list()
	var/list/used_terminals = list()
	var/dispatches = 0
	while(dispatches < 3)
		var/datum/ccpost_dispatch_request/best_request
		var/obj/machinery/computer/ccpost_tasking/best_terminal
		for(var/datum/ccpost_dispatch_request/request as anything in pending_requests)
			if(request in skipped_requests)
				continue
			var/datum/ccpost_task_template/queued_template = new request.template_type
			var/allowed = department_dispatch_allowed(queued_template)
			qdel(queued_template)
			if(!allowed)
				continue
			var/obj/machinery/computer/ccpost_tasking/candidate = select_terminal(request.priority_rank, request.priority_rank >= 3, used_terminals)
			if(!candidate)
				continue
			if(!best_request || request.priority_rank > best_request.priority_rank)
				best_request = request
				best_terminal = candidate
		if(!best_request || !best_terminal)
			break
		var/obj/item/circuitboard/computer/ccpost_tasking/inbox = best_terminal.get_tasking_board()
		if(best_request.template_type in inbox.event_task_queue)
			// A preexisting terminal-side request must resolve separately.
			skipped_requests += best_request
			continue
		best_terminal.insert_event_task_by_priority(inbox, best_request.template_type)
		inbox.event_task_expires["[best_request.template_type]"] = best_request.expires_at
		if(best_request.observation)
			inbox.event_task_context["[best_request.template_type]"] = best_request.observation
		if(!best_terminal.dispatch_queued_incident(best_request.template_type))
			// Keep this request in the central queue with its ORIGINAL deadline.
			// Another eligible request may still be dispatchable this tick.
			inbox.event_task_queue -= best_request.template_type
			inbox.event_task_expires -= "[best_request.template_type]"
			inbox.event_task_context -= "[best_request.template_type]"
			skipped_requests += best_request
			continue
		var/obj/item/circuitboard/computer/ccpost_tasking/dispatched_inbox = best_terminal.get_tasking_board()
		if(dispatched_inbox?.current_order)
			dispatched_inbox.current_order.incident_key = best_request.incident_key
		pending_requests -= best_request
		log_dispatch("DISPATCHED", "[best_request.incident_key] sent to [best_terminal.tasking_session_name].")
		qdel(best_request)
		used_terminals += best_terminal
		dispatches++

/// Recent activity provides fairer dispatch than all-round counts.
/datum/ccpost_tasking_network/proc/get_recent_routine_count(owner_key)
	var/total = 0
	for(var/list/entry as anything in recent_routine_dispatches.Copy())
		if(world.time - entry["at"] >= 20 MINUTES)
			recent_routine_dispatches -= list(entry)
			continue
		if(entry["owner"] == owner_key)
			total++
	return total

/// Routine work may occupy at most four slots. Two remain reserved for
/// incoming Priority/Critical requests in the six-slot incident network.
/datum/ccpost_tasking_network/proc/get_routine_capacity()
	var/nonurgent_incidents = 0
	for(var/datum/ccpost_dispatch_request/request as anything in pending_requests)
		if(request.priority_rank <= 2)
			nonurgent_incidents++
	return max(0, min(4 - nonurgent_incidents, 6 - length(pending_requests)) - routine_queue_count)

/datum/ccpost_tasking_network/proc/get_active_liaison_count()
	var/list/unique_personnel = list()
	for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in registered_terminals)
		if(QDELETED(terminal) || (terminal.machine_stat & (BROKEN | NOPOWER)) || !terminal.tasking_session_mind)
			continue
		var/mob/living/carbon/human/person = terminal.tasking_session_mind.current
		if(person?.client && terminal.session_valid_for(person))
			unique_personnel |= REF(terminal.tasking_session_mind)
	return length(unique_personnel)

/// Schedule intake without resetting an already earlier arrival deadline.
/datum/ccpost_tasking_network/proc/schedule_routine(minimum_delay = 0, maximum_delay = 0)
	if(!server_online())
		if(routine_timer)
			deltimer(routine_timer)
		routine_timer = null
		next_routine_at = 0
		return
	if(!get_active_liaison_count())
		if(routine_timer)
			deltimer(routine_timer)
		routine_timer = null
		next_routine_at = 0
		return
	if(!minimum_delay || !maximum_delay)
		minimum_delay = 4 MINUTES
		maximum_delay = 6 MINUTES
	var/new_deadline = world.time + rand(minimum_delay, maximum_delay)
	if(routine_timer && next_routine_at && next_routine_at <= new_deadline)
		return
	if(routine_timer)
		deltimer(routine_timer)
	next_routine_at = new_deadline
	routine_timer = addtimer(CALLBACK(src, PROC_REF(run_routine)), max(1 SECONDS, new_deadline - world.time), TIMER_STOPPABLE)

/// An idle eligible Liaison should not wait through a stale long intake timer.
/datum/ccpost_tasking_network/proc/accelerate_routine_intake()
	if(server_online() && !routine_queue_count && select_terminal(routine_only = TRUE))
		if(initial_routine_batch_sent)
			schedule_routine(2 MINUTES, 3 MINUTES)
		else
			schedule_routine(30 SECONDS, 45 SECONDS)

/// Create a bounded reserve only when there are people who can work on it.
/datum/ccpost_tasking_network/proc/run_routine()
	routine_timer = null
	next_routine_at = 0
	if(!server_online())
		return
	dispatch_pending()
	var/staffed = get_active_liaison_count()
	if(!staffed)
		return
	var/capacity = get_routine_capacity()
	var/obj/machinery/computer/ccpost_tasking/recipient = select_terminal(routine_only = TRUE)
	if(capacity > 0 && recipient)
		if(!first_routine_intake_at)
			first_routine_intake_at = world.time
		var/initial_batch = !initial_routine_batch_sent
		var/batch = 1
		if(initial_batch)
			// The opening intake can supply each of the three available Liaisons.
			batch = min(3, staffed)
			initial_routine_batch_sent = TRUE

		// An occupied team with full standby slots cannot build a backlog.
		batch = min(batch, capacity, max(0, (initial_batch ? 3 : 2) - routine_queue_count))
		if(batch > 0)
			routine_queue_count += batch
			log_dispatch("INTAKE", "[batch] routine assignment request(s) accepted; [routine_queue_count] awaiting dispatch.")
			schedule_routine_dispatch()
	schedule_routine()

/datum/ccpost_tasking_network/proc/schedule_routine_dispatch(delay = 30 SECONDS)
	if(!server_online() || !routine_queue_count || routine_dispatch_timer)
		return
	next_routine_dispatch_at = world.time + delay
	routine_dispatch_timer = addtimer(CALLBACK(src, PROC_REF(dispatch_routine_queue)), delay, TIMER_STOPPABLE)

/datum/ccpost_tasking_network/proc/dispatch_routine_queue()
	routine_dispatch_timer = null
	next_routine_dispatch_at = 0
	if(!server_online() || !routine_queue_count)
		return
	// Give event-driven incidents precedence over ordinary administration.
	dispatch_pending()
	var/obj/machinery/computer/ccpost_tasking/recipient = select_terminal(routine_only = TRUE)
	if(!recipient)
		schedule_routine_dispatch(45 SECONDS)
		return
	var/obj/item/circuitboard/computer/ccpost_tasking/before = recipient.get_tasking_board()
	var/datum/ccpost_tasking_order/previous_active = before?.current_order
	var/datum/ccpost_tasking_order/previous_standby = before?.standby_order
	routine_dispatch_active = TRUE
	recipient.issue_assignment()
	routine_dispatch_active = FALSE
	var/obj/item/circuitboard/computer/ccpost_tasking/board = recipient.get_tasking_board()
	if(board && (board.current_order != previous_active || board.standby_order != previous_standby))
		routine_queue_count--
	else
		// Template/staffing requirements may make this attempt ineligible.
		log_dispatch("RETRY", "Routine request retained; no eligible template could be issued.")
	if(routine_queue_count)
		schedule_routine_dispatch(board && (board.current_order != previous_active || board.standby_order != previous_standby) ? 30 SECONDS : 60 SECONDS)
	else if(get_active_liaison_count() && select_terminal(routine_only = TRUE))
		accelerate_routine_intake()

/datum/ccpost_tasking_network/proc/note_routine_issued(obj/machinery/computer/ccpost_tasking/terminal, datum/ccpost_task_template/template)
	if(!template || !terminal?.tasking_session_mind)
		return
	var/key = REF(terminal.tasking_session_mind)
	routine_dispatch_counts[key] = (routine_dispatch_counts[key] || 0) + 1
	last_routine_recipient_key = key
	recent_routine_dispatches += list(list("owner" = key, "at" = world.time))
	recent_routine_templates += template.type
	while(length(recent_routine_templates) > 5)
		recent_routine_templates.Cut(1, 2)
	recent_routine_families += template.get_rotation_family()
	while(length(recent_routine_families) > 3)
		recent_routine_families.Cut(1, 2)
	recent_routine_categories += template.category
	while(length(recent_routine_categories) > 4)
		recent_routine_categories.Cut(1, 2)
	log_dispatch("ROUTINE", "[template.template_id] distributed to [terminal.tasking_session_name].")

/// Protect a Liaison from immediately receiving new routine work after completing
/// an assignment. Real emergency dispatch deliberately ignores this cooldown.
/// Hidden Severance signal: available work, not mere online presence or clicking.
/proc/ccpost_has_pending_admin_work()
	if(GLOB.ccpost_tasking_network?.server_online())
		var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
		for(var/key in network.inboxes)
			var/obj/item/circuitboard/computer/ccpost_tasking/inbox = network.inboxes[key]
			if(inbox?.current_order && (inbox.current_order.status in list(CCPOST_TASK_STATUS_PENDING, CCPOST_TASK_STATUS_ACKNOWLEDGED)))
				return TRUE
		if(network.routine_queue_count || length(network.pending_requests))
			return TRUE
	return GLOB.ccpost_sector_network?.has_pending_admin_work()

/datum/ccpost_tasking_network/proc/note_task_completed(datum/mind/owner)
	if(!owner)
		return
	routine_cooldown_until[REF(owner)] = world.time + 2 MINUTES
	// Resume accelerated intake only after a completion has freed a slot.
	addtimer(CALLBACK(src, PROC_REF(accelerate_routine_intake)), 2 SECONDS)

// A reconstructible dedicated board avoids affecting live PDA message servers.
/obj/item/circuitboard/machine/ccpost_tasking_server
	name = "Central Command Tasking Distribution Server"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/ccpost_tasking_server
	req_components = list(
		/datum/stock_part/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/datum/stock_part/filter = 3
	)

// Physical Tasking Distribution Server. Its machinery availability controls
// processing, never the lifetime of archived and personally assigned records.
/obj/machinery/ccpost_tasking_server
	name = "Central Command Tasking Distribution Server"
	desc = "A hardened administrative dispatch server coordinating the outpost's personnel tasking network."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "message_server"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/ccpost_tasking_server
	use_power = ACTIVE_POWER_USE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	processing_flags = NONE
	var/calibrating = TRUE
	var/list/active_atmos_areas = list()
	var/atmos_incident_open = FALSE
	var/atmos_incident_sequence = 0
	var/next_atmos_incident_at = 0
	var/last_significant_explosion_at = -10 MINUTES
	/// Rare maintenance fault, separate from the original 15-second boot calibration.
	var/faulted = FALSE
	var/recalibrating = FALSE
	var/recalibration_ends_at = 0
	/// Invalidates callbacks from interrupted recalibration cycles.
	var/recalibration_generation = 0
	var/next_fault_check_at = 0
	/// Server-side intrusion session; never affects ordinary assignment processing.
	var/datum/mind/intrusion_mind
	var/intrusion_serial = 0
	var/intrusion_started_at = 0
	var/last_intrusion_radio_at = -10 MINUTES
	var/list/intrusion_audit = list()
	var/obj/item/radio/intrusion_radio
	/// Physically inserted original Operation Severance cartridge.
	var/obj/item/ccpost_classified_cartridge/inserted_cartridge

/obj/machinery/ccpost_tasking_server/proc/operational()
	return !calibrating && !faulted && !recalibrating && !GLOB.ccpost_outpost_signal_lost && !(machine_stat & (BROKEN | NOPOWER)) && GLOB.ccpost_tasking_network.server == src

/obj/machinery/ccpost_tasking_server/Initialize(mapload)
	. = ..()
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	if(network.server && !QDELETED(network.server))
		// Multiple mapped servers may exist, but only one is authoritative.
		return
	network.server = src
	intrusion_radio = new(src)
	intrusion_radio.set_frequency(FREQ_CENTCOM)
	intrusion_radio.independent = TRUE
	intrusion_radio.ignores_radio_jammers = TRUE
	intrusion_radio.canhear_range = 0
	intrusion_radio.set_listening(FALSE)
	intrusion_radio.command = TRUE
	intrusion_radio.use_command = TRUE
	next_fault_check_at = world.time + 30 MINUTES
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(on_station_explosion))
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_changed))
	RegisterSignal(SSdcs, COMSIG_GLOB_ALARM_FIRE(ALARM_ATMOS), PROC_REF(on_atmospheric_alarm))
	RegisterSignal(SSdcs, COMSIG_GLOB_ALARM_CLEAR(ALARM_ATMOS), PROC_REF(on_atmospheric_alarm_cleared))
	RegisterSignal(SSdcs, COMSIG_MAIN_SM_DELAMINATING, PROC_REF(on_supermatter_delamination))
	addtimer(CALLBACK(src, PROC_REF(complete_calibration)), 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(maintenance_tick)), 1 MINUTES)
	update_appearance()

/obj/machinery/ccpost_tasking_server/proc/complete_calibration()
	calibrating = FALSE
	update_appearance()
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	network.note_admin_server_state()
	if(network.server == src && operational())
		network.log_dispatch("ONLINE", "Central Tasking Server operational.")
		network.dispatch_pending()
		if(!network.routine_timer)
			network.schedule_routine(CCPOST_TASK_FIRST_MIN, CCPOST_TASK_FIRST_MAX)
		if(network.routine_queue_count)
			network.schedule_routine_dispatch()

/obj/machinery/ccpost_tasking_server/proc/maintenance_tick()
	if(QDELETED(src))
		return
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	if(network.server == src)
		if(world.time >= next_fault_check_at && !network.natural_fault_occurred)
			next_fault_check_at = world.time + 15 MINUTES
			if(operational() && length(GLOB.ccpost_hr_service?.roster))
				var/critical_work = FALSE
				for(var/datum/ccpost_dispatch_request/request as anything in network.pending_requests)
					if(request.priority == "Critical")
						critical_work = TRUE
						break
				if(!critical_work)
					for(var/inbox_key in network.inboxes)
						var/obj/item/circuitboard/computer/ccpost_tasking/inbox = network.inboxes[inbox_key]
						if(inbox?.current_order?.priority == "Critical" || inbox?.standby_order?.priority == "Critical")
							critical_work = TRUE
							break
				if(!critical_work && prob(15))
					faulted = TRUE
					network.natural_fault_occurred = TRUE
					network.total_faults++
					update_appearance()
					network.log_dispatch("FAULT", "Administrative synchronization failure. Recalibration required.")
		network.note_admin_server_state()
		network.record_server_telemetry()
		if(operational())
			network.prune_queue()
			GLOB.ccpost_tasking_network.dispatch_pending()
			if(!GLOB.ccpost_tasking_network.routine_timer)
				GLOB.ccpost_tasking_network.schedule_routine()
			if(GLOB.ccpost_tasking_network.routine_queue_count)
				GLOB.ccpost_tasking_network.schedule_routine_dispatch()
	addtimer(CALLBACK(src, PROC_REF(maintenance_tick)), 1 MINUTES)

/obj/machinery/ccpost_tasking_server/power_change()
	. = ..()
	if(intrusion_mind && (machine_stat & (BROKEN | NOPOWER)))
		abort_intrusion("Unauthorized transfer lost server power or integrity.")
	if(recalibrating && (machine_stat & (BROKEN | NOPOWER)))
		recalibration_generation++
		recalibrating = FALSE
		recalibration_ends_at = 0
		faulted = TRUE
	update_appearance()
	GLOB.ccpost_tasking_network.note_admin_server_state()
	if(operational())
		GLOB.ccpost_tasking_network.dispatch_pending()
		if(!GLOB.ccpost_tasking_network.routine_timer)
			GLOB.ccpost_tasking_network.schedule_routine()
		if(GLOB.ccpost_tasking_network.routine_queue_count)
			GLOB.ccpost_tasking_network.schedule_routine_dispatch()

// Operation Severance: physically inserted single-use storage, then an asynchronous
// 45-second download. The operative is free to move while the server transfers data.
/obj/machinery/ccpost_tasking_server/attack_hand(mob/user, list/modifiers)
	if(!user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex))
		return ..()
	if(!panel_open)
		balloon_alert(user, "open the maintenance panel first")
		return TRUE
	ui_interact(user)
	return TRUE

/obj/machinery/ccpost_tasking_server/proc/insert_classified_cartridge(obj/item/ccpost_classified_cartridge/cartridge, mob/living/user)
	if(!user || !user.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) || !user.Adjacent(src) || !user.is_holding(cartridge))
		return FALSE
	if(!panel_open || !operational() || inserted_cartridge || intrusion_mind || cartridge.data_complete)
		balloon_alert(user, "storage port unavailable")
		return FALSE
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!director || director.contract_kind != "data" || director.data_downloaded || director.data_cartridge_ref?.resolve() != cartridge)
		balloon_alert(user, "cartridge not authorized for this contract")
		return FALSE
	cartridge.forceMove(src)
	inserted_cartridge = cartridge
	record_intrusion("STORAGE MOUNTED", "Unknown operator mounted removable encrypted storage.")
	balloon_alert_to_viewers("cartridge inserted")
	playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 45, FALSE)
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/ccpost_tasking_server/proc/start_classified_export(mob/user)
	if(!user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) || !user.Adjacent(src) || !panel_open)
		return FALSE
	if(!operational())
		balloon_alert(user, "server unavailable")
		return FALSE
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!director)
		balloon_alert(user, "operation director not registered")
		return FALSE
	if(director.contract_kind != "data")
		balloon_alert(user, "not assigned to this contract")
		return FALSE
	if(director.data_downloaded)
		balloon_alert(user, "classified data already extracted")
		return FALSE
	if(!inserted_cartridge || inserted_cartridge.loc != src || inserted_cartridge.data_complete || director.data_cartridge_ref?.resolve() != inserted_cartridge)
		balloon_alert(user, "insert original blank cartridge")
		return FALSE
	if(intrusion_mind)
		balloon_alert(user, "export already running")
		return FALSE
	intrusion_mind = user.mind
	intrusion_started_at = world.time
	intrusion_serial++
	var/this_transfer = intrusion_serial
	balloon_alert_to_viewers("downloading classified data...")
	playsound(src, 'sound/machines/terminal/terminal_prompt_confirm.ogg', 40, FALSE)
	record_intrusion("UNAUTHORIZED EXTRACTION", "Classified Tasking Server database transfer initiated.")
	transmit_intrusion("Warning. Unauthorized data extraction detected within the Central Command Tasking Network. Classified records are being accessed without authorization. Immediate investigation is advised.")
	SStgui.update_uis(src)
	to_chat(user, span_warning("GORLEX MARAUDERS: Data extraction initiated. Transfer time: 45 seconds. Return to eject your cartridge."))
	addtimer(CALLBACK(src, PROC_REF(complete_classified_export), this_transfer, user.mind), 45 SECONDS)
	return TRUE

/obj/machinery/ccpost_tasking_server/proc/complete_classified_export(transfer_serial, datum/mind/download_mind)
	if(QDELETED(src) || intrusion_serial != transfer_serial || intrusion_mind != download_mind)
		return
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!operational() || !director || director.data_downloaded || !inserted_cartridge || inserted_cartridge.loc != src)
		abort_intrusion("Server authorization or removable storage became unavailable.")
		return
	if(!director.note_data_downloaded(download_mind, inserted_cartridge))
		abort_intrusion("Data transfer failed contract identity verification.")
		return
	inserted_cartridge.downloaded_by = download_mind
	inserted_cartridge.data_complete = TRUE
	inserted_cartridge.name = "encrypted Central Command tasking data cartridge"
	inserted_cartridge.desc = "The sole encrypted physical copy of classified Central Command tasking records. Recovery priority: critical."
	intrusion_mind = null
	intrusion_started_at = 0
	intrusion_serial++
	balloon_alert_to_viewers("download complete!")
	playsound(src, 'sound/machines/terminal/terminal_success.ogg', 50, FALSE)
	record_intrusion("DATA COMPROMISED", "Classified tasking records copied into inserted cartridge. Cartridge remains in storage port.")
	transmit_intrusion("Critical alert. Classified Central Command tasking records compromised. Unauthorized data extraction completed.", TRUE)
	SStgui.update_uis(src)

/obj/machinery/ccpost_tasking_server/proc/eject_classified_cartridge(mob/user)
	if(!inserted_cartridge || !user || !user.Adjacent(src))
		return FALSE
	if(intrusion_mind)
		abort_intrusion("Removable storage ejected during unauthorized transfer.")
	var/obj/item/ccpost_classified_cartridge/cartridge = inserted_cartridge
	inserted_cartridge = null
	cartridge.forceMove(get_turf(src))
	if(!user.put_in_hands(cartridge))
		to_chat(user, span_notice("The data cartridge was ejected onto the floor beside the server."))
	balloon_alert_to_viewers("cartridge removed")
	playsound(src, 'sound/items/handling/disk_pickup.ogg', 45, FALSE)
	record_intrusion("STORAGE EJECTED", "Removable encrypted cartridge removed from the Tasking Server.")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/ccpost_tasking_server/proc/record_intrusion(event, detail)
	var/entry = "[station_time_timestamp()] / [event] / [detail]"
	intrusion_audit.Insert(1, entry)
	if(length(intrusion_audit) > 16)
		intrusion_audit.Cut(17)
	GLOB.ccpost_tasking_network.log_dispatch("SECURITY", "[event]: [detail]")
	log_game("CCPost Tasking Server: [entry]")

/obj/machinery/ccpost_tasking_server/proc/transmit_intrusion(message, force = FALSE)
	// Rate-limit repeated starts, but always announce completed or interrupted transfers.
	if(!intrusion_radio || (!force && world.time < last_intrusion_radio_at + 5 SECONDS))
		return
	last_intrusion_radio_at = world.time
	intrusion_radio.talk_into(src, "CENTCOM TASKING SERVER: [message]", RADIO_CHANNEL_CENTCOM)

/obj/machinery/ccpost_tasking_server/proc/abort_intrusion(reason)
	if(!intrusion_mind)
		return
	intrusion_mind = null
	intrusion_started_at = 0
	intrusion_serial++
	balloon_alert_to_viewers("download interrupted!")
	playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
	record_intrusion("EXTRACTION INTERRUPTED", reason)
	transmit_intrusion("Unauthorized data transfer interrupted. Tasking network security intervention recorded.", TRUE)
	SStgui.update_uis(src)

/obj/machinery/ccpost_tasking_server/screwdriver_act(mob/living/user, obj/item/tool)
	toggle_panel_open()
	tool.play_tool_sound(src)
	balloon_alert(user, panel_open ? "panel opened" : "panel closed")
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ccpost_tasking_server/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/ccpost_tasking_server/update_icon_state()
	icon_state = ((machine_stat & (NOPOWER | BROKEN)) || calibrating || faulted || recalibrating) ? (panel_open ? "message_server_o_off" : "message_server_off") : (panel_open ? "message_server_o" : "message_server")
	return ..()

/obj/machinery/ccpost_tasking_server/update_overlays()
	. = ..()
	if(calibrating || recalibrating)
		. += "message_server_calibrate"

/obj/machinery/ccpost_tasking_server/Destroy()
	if(intrusion_mind)
		abort_intrusion("Tasking Server destroyed during unauthorized transfer.")
	if(inserted_cartridge)
		var/obj/item/ccpost_classified_cartridge/cartridge = inserted_cartridge
		inserted_cartridge = null
		cartridge.forceMove(get_turf(src))
	QDEL_NULL(intrusion_radio)
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	if(network.server == src)
		network.server = null
		network.note_admin_server_state()
		if(network.routine_timer)
			deltimer(network.routine_timer)
			network.routine_timer = null
		network.next_routine_at = 0
		if(network.routine_dispatch_timer)
			deltimer(network.routine_dispatch_timer)
			network.routine_dispatch_timer = null
		network.next_routine_dispatch_at = 0
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_EXPLOSION, COMSIG_GLOB_ALARM_FIRE(ALARM_ATMOS), COMSIG_GLOB_ALARM_CLEAR(ALARM_ATMOS), COMSIG_MAIN_SM_DELAMINATING))
	UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	return ..()

/obj/machinery/ccpost_tasking_server/proc/finish_recalibration(generation)
	if(QDELETED(src) || !recalibrating || generation != recalibration_generation)
		return
	recalibrating = FALSE
	recalibration_ends_at = 0
	if(machine_stat & (BROKEN | NOPOWER) || GLOB.ccpost_outpost_signal_lost)
		GLOB.ccpost_tasking_network.log_dispatch("RECOVERY ABORTED", "Power, hardware, or installation state prevented recovery.")
	else
		faulted = FALSE
		GLOB.ccpost_tasking_network.log_dispatch("RECALIBRATED", "60-second administrative synchronization restored.")
	update_appearance()
	GLOB.ccpost_tasking_network.note_admin_server_state()
	if(operational())
		GLOB.ccpost_tasking_network.dispatch_pending()
	SStgui.update_uis(src)

/obj/machinery/ccpost_tasking_server/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/mob/user = ui?.user
	if(!ccpost_terminal_in_range(src, user))
		return TRUE
	var/is_liaison = ccpost_has_centcom_id(user)
	var/is_breaching_gorlex = panel_open && !!user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex)
	if(action == "start_classified_export")
		if(is_breaching_gorlex && user.can_perform_action(src))
			start_classified_export(user)
		return TRUE
	if(action == "eject_classified_cartridge")
		if((is_liaison || is_breaching_gorlex) && user?.can_perform_action(src))
			eject_classified_cartridge(user)
		return TRUE
	if(!is_liaison)
		return TRUE
	. = ..()
	if(.)
		return
	if(action == "interrupt_intrusion")
		if(!ui?.user?.can_perform_action(src) || !intrusion_mind)
			return TRUE
		abort_intrusion("Central Command personnel terminated the unauthorized transfer.")
		to_chat(ui.user, span_boldnotice("Central Command Tasking Server: Unauthorized data export terminated."))
		return TRUE
	if(action != "start_recalibration")
		return FALSE
	if(!faulted || recalibrating || calibrating || GLOB.ccpost_outpost_signal_lost || (machine_stat & (BROKEN | NOPOWER)))
		balloon_alert(ui.user, "server not ready for recalibration")
		return TRUE
	recalibration_generation++
	recalibrating = TRUE
	recalibration_ends_at = world.time + 60 SECONDS
	GLOB.ccpost_tasking_network.log_dispatch("RECALIBRATING", "Manual 60-second synchronization cycle started by [key_name(ui.user)].")
	GLOB.ccpost_tasking_network.note_admin_server_state()
	GLOB.ccpost_tasking_network.refresh_admin_terminals()
	addtimer(CALLBACK(src, PROC_REF(finish_recalibration), recalibration_generation), 60 SECONDS)
	update_appearance()
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/ccpost_tasking_server/proc/queue_event_task(template_type, cooldown_duration = 12 MINUTES, observation = null, incident_key = null)
	return GLOB.ccpost_tasking_network.queue_event_task(template_type, cooldown_duration, observation, incident_key)

/obj/machinery/ccpost_tasking_server/ui_status(mob/user, datum/ui_state/state)
	if(!isobserver(user) && (!ccpost_terminal_in_range(src, user) || (!ccpost_has_centcom_id(user) && !(panel_open && user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex)))))
		return UI_CLOSE
	return ..()

/obj/machinery/ccpost_tasking_server/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user) && !ccpost_terminal_in_range(src, user))
		return
	if(!ccpost_can_view_terminal(user) && !(panel_open && user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex)))
		balloon_alert(user, "central command ID or breached maintenance access required")
		return
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostTasking", name)
		ui.open()

/obj/machinery/ccpost_tasking_server/ui_data(mob/user)
	if(!isobserver(user) && !ccpost_terminal_in_range(src, user))
		return list()
	if(!ccpost_can_view_terminal(user) && !(panel_open && user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex)))
		return list()
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	network.prune_queue()
	var/list/data = list("is_server" = TRUE, "server_online" = operational(), "server_calibrating" = calibrating || recalibrating, "server_panel_open" = panel_open)
	data["server_status"] = network.server_status()
	data["server_intrusion_active"] = !!intrusion_mind
	data["server_intrusion_seconds"] = intrusion_mind ? max(0, round(((intrusion_started_at + 45 SECONDS) - world.time) / (1 SECONDS))) : 0
	data["server_intrusion_history"] = intrusion_audit.Copy()
	data["server_storage_inserted"] = !!inserted_cartridge
	data["server_storage_status"] = inserted_cartridge ? (inserted_cartridge.data_complete ? "CLASSIFIED DATA COMPLETE" : "BLANK ENCRYPTED CARTRIDGE") : "NO CARTRIDGE"
	data["server_can_export"] = !!(panel_open && user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) && inserted_cartridge && !inserted_cartridge.data_complete && !intrusion_mind && operational())
	data["server_can_eject"] = !!inserted_cartridge && (!!ccpost_has_centcom_id(user) || (panel_open && !!user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex)))
	data["server_is_gorlex"] = !!user?.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex)
	data["server_liaison_authorized"] = !!ccpost_has_centcom_id(user)
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	data["server_data_compromised"] = !!director?.data_downloaded
	data["server_initializing"] = calibrating
	data["server_faulted"] = faulted
	data["server_recalibrating"] = recalibrating
	data["server_recalibration_seconds"] = recalibrating ? max(0, round((recalibration_ends_at - world.time) / (1 SECONDS))) : 0
	data["server_can_recalibrate"] = faulted && !recalibrating && !calibrating && !(machine_stat & (BROKEN | NOPOWER)) && !GLOB.ccpost_outpost_signal_lost && !isobserver(user)
	data["server_history"] = network.telemetry_history.Copy()
	data["server_total_faults"] = network.total_faults
	data["server_total_dispatches"] = network.total_dispatches
	data["server_queue_capacity"] = 6
	data["server_queue_size"] = length(network.pending_requests)
	data["server_intake_seconds"] = network.next_routine_at ? max(0, round((network.next_routine_at - world.time) / (1 SECONDS))) : 0
	data["server_dispatch_seconds"] = network.next_routine_dispatch_at ? max(0, round((network.next_routine_dispatch_at - world.time) / (1 SECONDS))) : 0
	data["server_routine_queue_size"] = network.routine_queue_count
	data["server_queue_size"] += network.routine_queue_count
	data["server_log"] = network.dispatch_log.Copy()
	data["server_queue"] = list()
	for(var/datum/ccpost_dispatch_request/request as anything in network.pending_requests)
		var/datum/ccpost_task_template/template = new request.template_type
		data["server_queue"] += list(list("subject" = template.subject, "priority" = request.priority, "expires_in_seconds" = max(0, round((request.expires_at - world.time) / (1 SECONDS)))))
		qdel(template)
	data["server_liaisons"] = list()
	var/datum/ccpost_hr_service/hr_service = GLOB.ccpost_hr_service
	if(hr_service)
		for(var/employee_key in hr_service.roster)
			var/datum/ccpost_hr_employee/employee = hr_service.roster[employee_key]
			if(!employee || employee.employee_role != "Central Command Liaison")
				continue
			var/obj/item/circuitboard/computer/ccpost_tasking/board = network.get_inbox(employee.employee_mind)
			var/session_online = FALSE
			for(var/obj/machinery/computer/ccpost_tasking/terminal as anything in network.registered_terminals)
				if(QDELETED(terminal) || terminal.tasking_session_mind != employee.employee_mind)
					continue
				var/mob/living/carbon/human/person = employee.employee_mind?.current
				if(person?.client && terminal.session_valid_for(person) && !(terminal.machine_stat & (BROKEN | NOPOWER)))
					session_online = TRUE
				break
			var/assignment_label = board?.current_order?.subject || (session_online ? "Available" : "Offline / Not signed in")
			if(board?.standby_order)
				assignment_label += " (+1 standby)"
			data["server_liaisons"] += list(list("name" = employee.employee_name, "assignment" = assignment_label, "held" = board ? length(board.on_hold_orders) : 0))
	return data


// One authoritative signal listener. Only real observed alarms are turned into
// task requests. Repeated atmospheric area alarms are part of one incident.
/obj/machinery/ccpost_tasking_server/proc/on_station_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range)
	SIGNAL_HANDLER
	if(!epicenter || !is_station_level(epicenter.z) || max(devastation_range, heavy_impact_range) < 2)
		return
	if(world.time - last_significant_explosion_at < 5 MINUTES)
		queue_event_task(/datum/ccpost_task_template/sabotage_review)
	last_significant_explosion_at = world.time
	queue_event_task(/datum/ccpost_task_template/explosions, 12 MINUTES, "Significant explosion indication near [get_area(epicenter)] at [station_time_timestamp()]")

/obj/machinery/ccpost_tasking_server/proc/on_security_level_changed(datum/source, new_security_level)
	SIGNAL_HANDLER
	if(new_security_level >= SEC_LEVEL_RED)
		queue_event_task(/datum/ccpost_task_template/emergency_readiness, 15 MINUTES, "Station security level raised to red at [station_time_timestamp()]")

/obj/machinery/ccpost_tasking_server/proc/on_atmospheric_alarm(datum/source, datum/alarm_handler/handler, alarm_type, area/alarmed_area, z_level)
	SIGNAL_HANDLER
	if(alarm_type != ALARM_ATMOS || !alarmed_area || !is_station_level(z_level))
		return
	if(!(alarmed_area in active_atmos_areas))
		active_atmos_areas += alarmed_area
	if(atmos_incident_open || STATION_TIME_PASSED() < CCPOST_TASK_ATMOS_GRACE)
		return
	atmos_incident_open = TRUE
	if(world.time < next_atmos_incident_at)
		return
	atmos_incident_sequence++
	queue_event_task(/datum/ccpost_task_template/atmos_emergency, 0, "Atmospheric alarm detected in [alarmed_area] at [station_time_timestamp()]", "station_atmospheric_incident_[atmos_incident_sequence]")

/obj/machinery/ccpost_tasking_server/proc/on_atmospheric_alarm_cleared(datum/source, datum/alarm_handler/handler, alarm_type, area/alarmed_area)
	SIGNAL_HANDLER
	if(alarm_type != ALARM_ATMOS || !alarmed_area)
		return
	if((alarmed_area.active_alarms[ALARM_ATMOS] || 0) > 0)
		return
	active_atmos_areas -= alarmed_area
	if(!length(active_atmos_areas))
		atmos_incident_open = FALSE
		// Avoid new requests from alarms rapidly flapping on the same equipment.
		next_atmos_incident_at = world.time + 3 MINUTES

/obj/machinery/ccpost_tasking_server/proc/on_supermatter_delamination(datum/source, delaminating)
	SIGNAL_HANDLER
	if(delaminating)
		queue_event_task(/datum/ccpost_task_template/supermatter_incident, 20 MINUTES, "Supermatter delamination alert reported at [station_time_timestamp()]")

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
	var/tasking_desk_unlocked = FALSE
	var/datum/weakref/tasking_desk_body

	/// Physical report currently inserted for task completion.
	var/obj/item/paper/submitted_report

	/// Prevents repeated manual printing.
	COOLDOWN_DECLARE(print_cooldown)
	// Incident signals and atmospheric clustering now live
	// on the physical Tasking Distribution Server, not individual workstations.

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
	if(!tasking_desk_access(user))
		balloon_alert(user, "sign in first")
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
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	return employee && employee.employee_role == "Central Command Liaison" && employee.employee_mind == tasking_session_mind && employee.original_body?.resolve() == user && user.client

/// The login remains a routing subscription; only the physical desk locks on departure.
/obj/machinery/computer/ccpost_tasking/proc/tasking_desk_access(mob/user)
	return tasking_desk_unlocked && tasking_desk_body?.resolve() == user && session_valid_for(user) && ccpost_terminal_in_range(src, user)

/obj/machinery/computer/ccpost_tasking/proc/tasking_lock_desk()
	tasking_desk_unlocked = FALSE
	var/mob/old_body = tasking_desk_body?.resolve()
	if(old_body)
		UnregisterSignal(old_body, COMSIG_MOVABLE_MOVED)
	tasking_desk_body = null

/obj/machinery/computer/ccpost_tasking/proc/tasking_desk_moved(datum/source)
	SIGNAL_HANDLER
	var/mob/moving_user = source
	if(!ccpost_terminal_in_range(src, moving_user))
		tasking_lock_desk()
		SStgui.close_user_uis(moving_user, src)

/obj/machinery/computer/ccpost_tasking/proc/tasking_unlock_desk(mob/user)
	tasking_lock_desk()
	tasking_desk_body = WEAKREF(user)
	tasking_desk_unlocked = TRUE
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(tasking_desk_moved))

/obj/machinery/computer/ccpost_tasking/proc/logout_tasking_session()
	tasking_lock_desk()
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
	if(GLOB.ccpost_tasking_network?.server)
		GLOB.ccpost_tasking_network.schedule_routine()

/obj/machinery/computer/ccpost_tasking/proc/login_tasking_session(mob/user)
	if(!ccpost_terminal_in_range(src, user) || !user.client)
		return FALSE
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
	tasking_unlock_desk(user)
	var/obj/item/circuitboard/computer/ccpost_tasking/inbox = network.get_inbox(tasking_session_mind, TRUE)
	if(!inbox)
		return FALSE
	inbox.last_owner_activity_at = world.time
	// The physical server schedules shared routine work. A new login can also
	// receive an urgent request already waiting in the central queue.
	if(!network.routine_timer)
		network.schedule_routine(CCPOST_TASK_FIRST_MIN, CCPOST_TASK_FIRST_MAX)
	addtimer(CALLBACK(network, TYPE_PROC_REF(/datum/ccpost_tasking_network, dispatch_pending)), 1 SECONDS)
	if(network.routine_queue_count)
		network.schedule_routine_dispatch()
	SStgui.update_uis(src)
	return TRUE

// Initialization

/obj/machinery/computer/ccpost_tasking/Initialize(mapload)
	. = ..()

	// Issue the first assignment shortly after initialization.
	grant_radio = new(src)
	GLOB.ccpost_tasking_network.registered_terminals |= src

/obj/machinery/computer/ccpost_tasking/Destroy()
	logout_tasking_session()
	GLOB.ccpost_tasking_network.registered_terminals -= src
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
	if(order.assigned_contact_mind)
		tasking_network.note_issued(order, FALSE)
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
		if(assessment.rating == "Not Assessed")
			assessment.grant_status = "Not Assessed"
			assessment.radio_status = "Not Applicable"
			continue
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
	if(GLOB.ccpost_tasking_network.department_standdown_active() || SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		return "Departmental contact is temporarily suspended. Review available records and defer nonessential inquiries until operations stabilize."
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
		// Follow-ups use a generic template. Replacements must come from the
		// original assigned department, not an arbitrary station employee.
		if(!person.client || person.mind == old_mind || (order.assigned_department && person.mind?.assigned_role?.paycheck_department != order.assigned_department) || world.time < (GLOB.ccpost_tasking_network.contact_next_dispatch[REF(person.mind)] || 0))
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
	GLOB.ccpost_tasking_network.note_issued(order)
	order.instruction += "\n\nUpdated station contact: [replacement.real_name] ([job.title]). Verify findings with the replacement representative when available."
	return "Replacement contact assigned: [replacement.real_name]."

/obj/machinery/computer/ccpost_tasking/proc/attach_staffing_context(datum/ccpost_tasking_order/order, datum/ccpost_task_template/template)
	if(!order || !template)
		return TRUE
	if(template.event_only)
		var/observation_start = findtext(order.instruction, "\n\nMonitoring record:")
		var/observation = observation_start ? copytext(order.instruction, observation_start) : ""
		order.instruction = "Review available monitoring records, public announcements and existing correspondence about [order.subject]. Record confirmed observations and uncertainties. Do not interrupt emergency responders; obtain clarification only after operations stabilize and when genuinely necessary. A stamped report based on available records is sufficient.[observation]"
		for(var/datum/ccpost_department_assessment/assessment as anything in order.department_assessments)
			assessment.rating = "Not Assessed"
		return TRUE
	if(!template.is_station_facing())
		return TRUE
	var/list/staff = template.contact_candidates()
	if(!length(staff))
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
	order.instruction += "\n\nUse existing records first. One concise request is sufficient; do not demand additional paperwork or interrupt essential duties. If cooperation is impracticable, record the reason and mark the department Not Assessed.\n\nStaffing verification at issue: [employee.real_name] ([job.title]) is assigned to the relevant department. If the employee is not immediately reachable, use Defer or document genuine contact attempts instead of inventing an interview."
	return TRUE

/// explicit allowlist for publicly announced, non-secret round events.
/// Event definitions invoke this immediately AFTER issuing a stationwide announcement.
/// Internal event creation, start, and unannounced incidents never invoke this proc.
/// The optional fake-event flag is checked by each caller before invoking this bridge.
/proc/ccpost_note_public_round_event(event_id)
	var/template_type
	var/cooldown_duration = 15 MINUTES
	var/observation
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
			observation = "Public communications disruption warning issued at [station_time_timestamp()]. The warning alone does not establish that an outage occurred."
		if("supermatter_surge")
			template_type = /datum/ccpost_task_template/public_supermatter_surge
			observation = "Public supermatter surge alert issued at [station_time_timestamp()]. Review the announced surge; do not infer delamination or unrelated infrastructure failures."
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
	// One central intake prevents duplicate incident requests per workstation.
	GLOB.ccpost_tasking_network.queue_event_task(template_type, cooldown_duration, observation)

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
/obj/machinery/computer/ccpost_tasking/proc/dispatch_queued_incident(expected_template_type = null)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || (machine_stat & (NOPOWER | BROKEN)) || !length(board.event_task_queue))
		return FALSE
	// The central server must never record an unrelated legacy terminal
	// incident as the request it just selected.
	if(expected_template_type && board.event_task_queue[1] != expected_template_type)
		return FALSE
	if(board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED)
		archive_finished_order()
	var/template_type = board.event_task_queue[1]
	var/datum/ccpost_task_template/incident = new template_type
	if(!incident)
		return FALSE
	if(!GLOB.ccpost_tasking_network.department_dispatch_allowed(incident))
		qdel(incident)
		return FALSE
	var/new_rank = ccpost_incident_priority_rank(incident.priority)
	// Non-event templates can be used as public-alert reviews, but may still
	// require a live departmental contact. Avoid consuming a serial number
	// when their ordinary eligibility check has not passed.
	if(!incident.event_only && !incident.is_eligible())
		qdel(incident)
		return FALSE
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
		new_order.instruction += "\n\nMonitoring record: [incident_observation]. Treat this observation as preliminary; corroborate it with available records."
	if(!attach_staffing_context(new_order, incident))
		qdel(new_order)
		qdel(incident)
		return FALSE
	if(board.current_order)
		var/datum/ccpost_tasking_order/suspended = board.current_order
		suspended.status_before_hold = suspended.status
		if(suspended.voluntary_offer_expires_at > world.time)
			suspended.voluntary_offer_expires_at = 0
			suspended.record_action("Offer Withdrawn", "CENTRAL COMMAND", "Emergency preemption")
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
	ccpost_notify_liaison(tasking_session_mind, "tasking", new_order.order_code, new_order.subject)
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

/// Switch between two assigned investigations without deferring either order.
/// The physical report in the single machine slot follows its own order.
/obj/machinery/computer/ccpost_tasking/proc/switch_investigation(expected_order_code)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board?.standby_order || !board.current_order || board.current_order.status == CCPOST_TASK_STATUS_COMPLETED || board.standby_order.order_code != expected_order_code)
		return FALSE
	if(ccpost_incident_priority_rank(board.current_order.priority) >= ccpost_incident_priority_rank(CCPOST_TASK_PRIORITY_PRIORITY))
		return FALSE
	var/datum/ccpost_tasking_order/old_active = board.current_order
	var/datum/ccpost_tasking_order/new_active = board.standby_order
	if(submitted_report)
		if(old_active.standby_report)
			return FALSE
		old_active.standby_report = submitted_report
		submitted_report.forceMove(null)
		submitted_report = null
	board.standby_order = old_active
	board.current_order = new_active
	if(new_active.standby_report)
		new_active.standby_report.forceMove(src)
		submitted_report = new_active.standby_report
		new_active.standby_report = null
	pause_deferred_expiration(board)
	old_active.record_action("Standby", tasking_session_name, "Investigation temporarily switched")
	new_active.record_action("Resumed", tasking_session_name, "Investigation activated from standby")
	SStgui.update_uis(src)
	return TRUE

/// A standby order is already assigned and therefore bypasses the new-work cooldown.
/// It must never take precedence over higher-priority queued or held incidents.
/obj/machinery/computer/ccpost_tasking/proc/activate_standby_order()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || board.current_order || !board.standby_order || length(board.on_hold_orders) || length(board.event_task_queue))
		return FALSE
	var/datum/ccpost_tasking_order/returning_order = board.standby_order
	board.standby_order = null
	board.current_order = returning_order
	if(returning_order.standby_report)
		returning_order.standby_report.forceMove(src)
		submitted_report = returning_order.standby_report
		returning_order.standby_report = null
	pause_deferred_expiration(board)
	returning_order.record_action("Resumed", tasking_session_name, "Standby investigation activated")
	SStgui.update_uis(src)
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
	return GLOB.ccpost_tasking_network.queue_event_task(template_type, cooldown_duration, observation)

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
	ready_at = world.time + rand(25 MINUTES, 40 MINUTES)
	assigned_contact = original.assigned_contact
	assigned_role = original.assigned_role
	assigned_department = original.assigned_department

/obj/machinery/computer/ccpost_tasking/proc/queue_report_followup(datum/ccpost_tasking_order/order)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !order?.submitted_report_text || order.source_order_code)
		return
	if(!(order.category in list("Audits & Inspections", "Incident Review", "Infrastructure Oversight", "Communications Oversight", "Sector Records & Administration", "Administrative Oversight", "Operational Oversight", "Supply Chain Oversight", "Personnel & Civilian Liaison")))
		return
	if(length(board.followup_orders) >= board.max_pending_followups)
		return
	/// Not every completed report needs revisiting. Selection never invents a finding.
	if(world.time < board.next_followup_allowed_at || !prob(20))
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
	order.assigned_department = null
	order.assigned_contact = null
	order.assigned_role = null
	order.subject = "Follow-Up: [followup.source_subject]"
	var/is_simulated_installation_task = followup.source_category == "Sector Records & Administration"
	if(is_simulated_installation_task)
		order.target_installation_code = followup.source_installation_code
		order.instruction = "Central Command requests an updated administrative review of archived order [followup.source_order_code] ([followup.source_subject]). Consult its retained documentation in Previous Orders. Recheck current installation status and history through the Remote Oversight Network and review applicable Sector Communications. Submit a stamped report identifying changes, unresolved questions, and recommended administrative action. This remote review does not require direct contact with installation personnel."
	else
		order.instruction = "Central Command requests an updated review of archived order [followup.source_order_code] ([followup.source_subject]). Consult its retained documentation in Previous Orders and review current outpost records or existing station correspondence. Do not request a new interview or additional paperwork. Submit a stamped report of verified changes, outstanding concerns and any unsuccessful contact attempts. Do not treat prior allegations as established findings."
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
	// Treat a currently actionable investigation or urgent held work as busy.
	// A completed order awaiting archive does not extend deferral deadlines.
	var/occupied = (board.current_order && board.current_order.status != CCPOST_TASK_STATUS_COMPLETED) || length(board.on_hold_orders) || length(board.event_task_queue)
	for(var/datum/ccpost_tasking_order/order as anything in board.deferred_orders)
		if(occupied)
			if(!order.deferral_expiry_paused_at)
				order.deferral_expiry_paused_at = world.time
		else if(order.deferral_expiry_paused_at)
			order.deferral_expires_at += world.time - order.deferral_expiry_paused_at
			order.deferral_expiry_paused_at = 0

/obj/machinery/computer/ccpost_tasking/proc/expire_overdue_deferrals()
	if(!GLOB.ccpost_tasking_network.server_online())
		return
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board)
		return
	pause_deferred_expiration(board)
	for(var/datum/ccpost_tasking_order/order as anything in board.deferred_orders.Copy())
		if(order.deferral_expiry_paused_at || world.time < order.deferral_expires_at)
			continue
		board.deferred_orders -= order
		order.voluntary_offer_expires_at = 0
		order.status = CCPOST_TASK_STATUS_EXPIRED
		order.record_action("Expired", "CENTRAL COMMAND", "Deferred work expired")
		GLOB.ccpost_tasking_network.archive_order(order)

/obj/machinery/computer/ccpost_tasking/proc/activate_deferred_order(datum/ccpost_tasking_order/order)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(!board || !order || !(order in board.deferred_orders))
		return FALSE
	if((board.current_order && board.current_order.status != CCPOST_TASK_STATUS_COMPLETED) || length(board.on_hold_orders) || length(board.event_task_queue))
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
	// Legacy terminal requests must not outlive the 20-minute central
	// emergency deadline or be refreshed indefinitely after each completion.
	for(var/template_type in board.event_task_queue)
		var/key = "[template_type]"
		var/existing_expiry = board.event_task_expires[key]
		if(!existing_expiry || existing_expiry > world.time + 20 MINUTES)
			board.event_task_expires[key] = world.time + 20 MINUTES

/obj/machinery/computer/ccpost_tasking/proc/schedule_next_assignment(
	minimum_delay = CCPOST_TASK_INTERVAL_MIN,
	maximum_delay = CCPOST_TASK_INTERVAL_MAX
)
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	if(network.routine_dispatch_active)
		return
	if(!network.routine_timer)
		network.schedule_routine()

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
	if(!board.current_order && board.standby_order && !length(board.on_hold_orders))
		activate_standby_order()
	if(board.current_order && (board.standby_order || length(board.on_hold_orders) || ccpost_incident_priority_rank(board.current_order.priority) >= ccpost_incident_priority_rank(CCPOST_TASK_PRIORITY_PRIORITY)))
		schedule_next_assignment(CCPOST_TASK_RETRY_MIN, CCPOST_TASK_RETRY_MAX)
		return
	var/reserve_standby = !!board.current_order
	if(!reserve_standby && length(board.on_hold_orders) && restore_on_hold_order())
		schedule_next_assignment()
		return

	var/datum/ccpost_tasking_order/new_order
	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network
	var/datum/ccpost_task_template/template
	if(!reserve_standby && logistics_network?.contraband_audit_pending)
		var/datum/ccpost_task_template/audit = new /datum/ccpost_task_template/outpost_audit
		new_order = create_task_order(audit)
		audit.configure_order(new_order, logistics_network)
		qdel(audit)
	else
		// Elevated requests outrank resumed deferrals; expired events are never immortal.
		var/list/queued_events = reserve_standby ? list() : board.event_task_queue.Copy()
		for(var/template_type in queued_events)
			var/expiry = board.event_task_expires["[template_type]"]
			if(!expiry || world.time >= expiry)
				board.event_task_queue -= template_type
				board.event_task_expires -= "[template_type]"
				board.event_task_context -= "[template_type]"
				continue
			var/datum/ccpost_task_template/event_template = new template_type
			if(GLOB.ccpost_tasking_network.department_dispatch_allowed(event_template) && (event_template.event_only || event_template.is_eligible()))
				template = event_template
				board.event_task_queue -= template_type
				board.event_task_expires -= "[template_type]"
				var/queued_observation = board.event_task_context["[template_type]"]
				if(queued_observation)
					event_template.instruction += "\n\nMonitoring record: [queued_observation]. Verify details before reaching conclusions."
				board.event_task_context -= "[template_type]"
				break
			qdel(event_template)
		if(!template && !reserve_standby)
			for(var/datum/ccpost_tasking_order/deferred as anything in board.deferred_orders.Copy())
				if(world.time >= deferred.deferred_until && world.time < deferred.deferral_expires_at)
					board.deferred_orders -= deferred
					deferred.status = deferred.status_before_deferral
					new_order = deferred
					break
		// Keep new follow-ups queued until their individual 25-40 minute waiting
		// periods have passed. A new routine assignment may issue in the meantime.
		if(!reserve_standby && !template && !new_order && length(board.followup_orders))
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
			if(board.current_order?.rotation_family)
				outstanding_families += board.current_order.rotation_family
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
				if(!candidate.event_only && (!reserve_standby || candidate.priority == CCPOST_TASK_PRIORITY_ROUTINE) && candidate.selection_weight > 0 && GLOB.ccpost_task_category_weights[candidate.category] > 0)
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
			var/list/recent_families = GLOB.ccpost_tasking_network.recent_routine_families.Copy()
			var/last_family = length(recent_families) ? recent_families[length(recent_families)] : null
			var/last_personal_family = length(board.recent_routine_families) ? board.recent_routine_families[length(board.recent_routine_families)] : null
			var/list/family_filtered_priorities = list()
			for(var/family_pass in 1 to 2)
				family_filtered_priorities.Cut()
				for(var/priority_name in available_priorities)
					var/list/filtered_families = list()
					for(var/candidate_type in available_priorities[priority_name])
						var/family = families_by_type["[candidate_type]"]
						// The immediately previous routine family is a hard exclusion.
						if(family == last_family || family == last_personal_family)
							continue
						if(family_pass == 1 && (family in recent_families))
							continue
						filtered_families += candidate_type
					if(length(filtered_families))
						family_filtered_priorities[priority_name] = filtered_families
				if(length(family_filtered_priorities))
					break
			// Apply exact-template rotation after family rotation; a small pool
			// may require relaxing the oldest template exclusion, not all families.
			var/list/recent_exclusions = GLOB.ccpost_tasking_network.recent_routine_templates.Copy()
			// Personal recent-template history was already collected. Include it
			// as a SOFT exclusion so that one Liaison does not repeatedly get
			// the same exact assignment after another Liaison receives work.
			for(var/personal_type in board.recent_routine_templates)
				if(!(personal_type in recent_exclusions))
					recent_exclusions += personal_type
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
					var/rotation_factor = (category_name in GLOB.ccpost_tasking_network.recent_routine_categories) ? 0.55 : 1
					category_weights[category_name] = base_weight * average_weight * rotation_factor / 100
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
				board.event_task_expires["[template.type]"] = world.time + 20 MINUTES
			qdel(new_order)
			new_order = null
		else if(!template.event_only && template.type != /datum/ccpost_task_template/archived_followup)
			GLOB.ccpost_tasking_network.note_routine_issued(src, template)
			board.recent_routine_templates += template.type
			while(length(board.recent_routine_templates) > 3)
				board.recent_routine_templates.Cut(1, 2)
			var/family = template.get_rotation_family()
			board.recent_routine_families += family
			while(length(board.recent_routine_families) > CCPOST_TASK_FAMILY_HISTORY)
				board.recent_routine_families.Cut(1, 2)
			var/family_cooldown = CCPOST_TASK_FAMILY_COOLDOWN
			if(!template.is_station_facing())
				family_cooldown = CCPOST_TASK_INTERNAL_FAMILY_COOLDOWN
			GLOB.ccpost_tasking_network.family_next_dispatch[family] = world.time + family_cooldown
		qdel(template)
	if(!new_order)
		// No new meaningful routine work is available. Retry instead of
		// immediately recycling an unresolved or recently issued task family.
		schedule_next_assignment(CCPOST_TASK_VARIETY_RETRY_MIN, CCPOST_TASK_VARIETY_RETRY_MAX)
		return
	if(reserve_standby)
		board.standby_order = new_order
	else
		board.current_order = new_order
	GLOB.ccpost_tasking_network.note_issued(new_order)
	ccpost_notify_liaison(tasking_session_mind, "tasking", new_order.order_code, new_order.subject)
	pause_deferred_expiration(board)
	playsound(src, 'sound/machines/terminal/terminal_alert.ogg', vol = 45, vary = TRUE)
	var/dispatch_message = reserve_standby ? "[src] chimes. A second investigation has been assigned to standby." : "[src] chimes. A Central Command tasking order is ready."
	visible_message(span_notice(dispatch_message))
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

/obj/machinery/computer/ccpost_tasking/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return UI_INTERACTIVE
	if(!ccpost_terminal_in_range(src, user))
		if(tasking_session_mind == user?.mind)
			tasking_lock_desk()
		return UI_CLOSE
	return ..()

/obj/machinery/computer/ccpost_tasking/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user) && !ccpost_terminal_in_range(src, user))
		return
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostTasking", name)
		ui.open()

/obj/machinery/computer/ccpost_tasking/ui_data(mob/user)
	if(!isobserver(user) && !ccpost_terminal_in_range(src, user))
		return list()
	var/list/data = list()
	data["read_only"] = isobserver(user)
	data["authenticated"] = isobserver(user) || !!tasking_desk_access(user)
	data["session_owner"] = isobserver(user) ? "Observer" : (data["authenticated"] ? (tasking_session_name || "") : "")
	var/datum/ccpost_hr_employee/login_employee = GLOB.ccpost_hr_service?.employee_for(user)
	data["identity_detected"] = !!(login_employee && login_employee.employee_role == "Central Command Liaison")
	data["identity_portrait"] = data["identity_detected"] ? login_employee.portrait_base64 : null
	data["admin_server_online"] = GLOB.ccpost_tasking_network.server_online() && !(machine_stat & (BROKEN | NOPOWER))
	data["admin_server_status"] = GLOB.ccpost_tasking_network.server_status()
	data["identity_issue"] = data["identity_detected"] ? "" : "No authorized Central Command Liaison ID detected. Hold or equip your registered ID to authenticate."
	if(!data["authenticated"])
		return data
	var/datum/ccpost_hr_employee/session_employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	data["pda_notifications"] = !!session_employee?.tasking_pda_notifications
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	data["network_terminals"] = length(network.registered_terminals)
	data["network_inboxes"] = length(network.inboxes)
	data["network_completed"] = length(network.shared_history)
	var/active_task_count = 0
	for(var/key in network.inboxes)
		var/obj/item/circuitboard/computer/ccpost_tasking/other_inbox = network.inboxes[key]
		if(other_inbox.current_order && other_inbox.current_order.status != CCPOST_TASK_STATUS_COMPLETED)
			active_task_count++
		if(other_inbox.standby_order)
			active_task_count++
	data["network_active_tasks"] = active_task_count
	data["claimable_tasks"] = isobserver(user) ? list() : network.list_claimable(tasking_session_mind)
	data["my_reassignment_offers"] = isobserver(user) ? list() : network.list_voluntary_offers(tasking_session_mind, TRUE)
	data["available_reassignment_offers"] = isobserver(user) ? list() : network.list_voluntary_offers(tasking_session_mind)
	data["routine_cooldown_seconds"] = isobserver(user) ? 0 : max(0, round(((network.routine_cooldown_until[REF(tasking_session_mind)] || 0) - world.time) / (1 SECONDS)))
	data["dispatch_seconds"] = network.next_routine_dispatch_at ? max(0, round((network.next_routine_dispatch_at - world.time) / (1 SECONDS))) : 0
	data["dispatch_pending"] = !!network.routine_dispatch_timer
	data["intake_seconds"] = network.next_routine_at ? max(0, round((network.next_routine_at - world.time) / (1 SECONDS))) : 0
	data["queued_routine_requests"] = network.routine_queue_count
	data["dispatch_machine_available"] = network.server_online() && !(machine_stat & (NOPOWER | BROKEN))
	data["submitted_report"] = isobserver(user) ? null : report_to_ui_data(submitted_report)

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = isobserver(user) ? null : get_tasking_board()

	if(!tasking_board)
		data["current_order"] = null
		data["standby_order"] = null
		data["can_switch_investigation"] = FALSE
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
		data["pending_followups"] = list()
		data["queued_incidents"] = list()
		return data

	data["current_order"] = tasking_board.current_order?.status == CCPOST_TASK_STATUS_COMPLETED ? null : order_to_ui_data(tasking_board.current_order)
	data["standby_order"] = order_to_ui_data(tasking_board.standby_order)
	data["can_switch_investigation"] = !!tasking_board.standby_order && (!tasking_board.current_order || (tasking_board.current_order.status != CCPOST_TASK_STATUS_COMPLETED && ccpost_incident_priority_rank(tasking_board.current_order.priority) < ccpost_incident_priority_rank(CCPOST_TASK_PRIORITY_PRIORITY)))

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
		serialized["deferral_paused"] = !!deferred.deferral_expiry_paused_at
		deferred_data += list(serialized)
	data["deferred_orders"] = deferred_data
	data["max_deferred_orders"] = tasking_board.max_deferred_orders
	var/list/on_hold_data = list()
	for(var/datum/ccpost_tasking_order/held as anything in tasking_board.on_hold_orders)
		on_hold_data += list(order_to_ui_data(held))
	data["on_hold_orders"] = on_hold_data
	data["queued_events"] = length(network.pending_requests)
	// The physical server owns incident requests; only dispatched work is held
	// within the individual inbox. Do not expose hidden antagonist information.
	var/list/priority_counts = list("Critical" = 0, "Priority" = 0, "Elevated" = 0, "Routine" = 0)
	var/list/queued_incidents = list()
	for(var/datum/ccpost_dispatch_request/request as anything in network.pending_requests)
		var/datum/ccpost_task_template/queued_template = new request.template_type
		priority_counts[request.priority] = (priority_counts[request.priority] || 0) + 1
		queued_incidents += list(list(
			"subject" = findtext(queued_template.template_id, "public_") == 1 ? queued_template.subject : "Internal incident review",
			"priority" = request.priority,
			"reason" = "Central queue; expires in [max(0, round((request.expires_at - world.time) / (1 MINUTES)))] minutes"
		))
		qdel(queued_template)
	data["queued_events_ready"] = length(network.pending_requests)
	data["queued_incidents"] = queued_incidents
	data["queued_priorities"] = priority_counts
	data["queued_followups"] = length(tasking_board.followup_orders)
	data["pending_followups"] = list()
	for(var/datum/ccpost_task_followup/followup as anything in tasking_board.followup_orders)
		data["pending_followups"] += list(list(
			"subject" = followup.source_subject,
			"source_order_code" = followup.source_order_code,
			"ready_in_seconds" = max(0, round((followup.ready_at - world.time) / (1 SECONDS)))
		))
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
		"allocation_reward" = order.get_allocation_reward(),
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
		"standby_report_retained" = !!order.standby_report,
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
	if(!ccpost_terminal_in_range(src, ui?.user) || isobserver(ui?.user))
		return TRUE
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(action == "login")
		if(!GLOB.ccpost_tasking_network.server_online())
			balloon_alert(user, "local administrative server unavailable")
			return TRUE
		if(!login_tasking_session(user))
			balloon_alert(user, "registered personnel ID required")
		return TRUE
	if(action == "logout")
		if(tasking_desk_access(user))
			logout_tasking_session()
		return TRUE
	if(!tasking_desk_access(user))
		return TRUE
	if(action == "toggle_pda_notifications")
		var/datum/ccpost_hr_employee/session_employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
		if(session_employee)
			session_employee.tasking_pda_notifications = !session_employee.tasking_pda_notifications
			SStgui.update_uis(src)
		return TRUE
	if(!GLOB.ccpost_tasking_network.server_online())
		balloon_alert(user, "local administrative server unavailable")
		return TRUE

	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = get_tasking_board()

	if(!tasking_board)
		return FALSE
	tasking_board.last_owner_activity_at = world.time

	switch(action)

		if("switch_investigation")
			var/switch_code = params["order_code"]
			if(!istext(switch_code) || !tasking_board.standby_order || tasking_board.standby_order.order_code != switch_code)
				return TRUE
			var/switched = tasking_board.current_order ? switch_investigation(switch_code) : activate_standby_order()
			balloon_alert(user, switched ? "investigation switched" : "switch unavailable")
			return TRUE

		if("offer_reassignment")
			balloon_alert(user, GLOB.ccpost_tasking_network.offer_voluntary_order(user, params["order_code"]) ? "transfer offer posted" : "cannot offer this order")
			return TRUE

		if("withdraw_reassignment")
			balloon_alert(user, GLOB.ccpost_tasking_network.cancel_voluntary_offer(user, params["order_code"]) ? "offer withdrawn" : "offer unavailable")
			return TRUE

		if("claim_reassignment")
			balloon_alert(user, GLOB.ccpost_tasking_network.claim_voluntary_order(src, user, params["owner_key"], params["order_code"]) ? "assignment transferred" : "unable to claim")
			return TRUE

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
			if(!(rating in list("Very Dissatisfied", "Dissatisfied", "Neutral", "Satisfied", "Very Satisfied", "Not Assessed")))
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
			order.deferral_expires_at = world.time + 15 MINUTES
			order.deferral_expiry_paused_at = 0
			order.deferral_reason = reason
			order.status = CCPOST_TASK_STATUS_DEFERRED
			order.record_action("Deferred", user.name, reason)
			tasking_board.deferred_orders += order
			tasking_board.current_order = null
			if(!length(tasking_board.event_task_queue) && !length(tasking_board.on_hold_orders))
				activate_standby_order()
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
			// Deferred deadlines are synchronized after queued/held/standby work
			// has been restored; no gap is charged during the transition.

			// Issue Operational Allocation and any applicable
			// departmental budget grant.
			apply_task_rewards(
				tasking_board.current_order,
				user
			)
			// CCPost HR: credit the submitting Liaison after rewards are issued.
			ccpost_hr_note_task_completion(user, tasking_board.current_order)
			// Publish immediately for other Liaisons instead of waiting for the next dispatch.
			ccpost_record_admin_activity("task:[tasking_board.current_order.order_code]", 2)
			GLOB.ccpost_tasking_network.note_task_completed(tasking_session_mind)
			archive_finished_order()
			// Freeing this inbox may permit a pending emergency to dispatch now,
			// without making everyone wait for the next global scheduler tick.
			GLOB.ccpost_tasking_network.dispatch_pending()
			// If no new emergency took this slot, restore interrupted work to
			// the same Liaison immediately instead of waiting for their next
			// turn in the shared routine rotation.
			if(!tasking_board.current_order && length(tasking_board.on_hold_orders))
				restore_on_hold_order()
			if(!tasking_board.current_order && !length(tasking_board.event_task_queue))
				activate_standby_order()
			expire_overdue_deferrals()
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
	if(tasking_board.standby_order?.order_code == order_code)
		return tasking_board.standby_order

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

	assignment_text += ccpost_paper_section(istype(src, /obj/machinery/computer/ccpost_tasking/security) ? "Instructions to Security Personnel" : "Instructions to Liaison Personnel")
	assignment_text += replacetext(html_encode(order.instruction), "\n", "<br>")
	assignment_text += "<br><br>Verify available information and record findings impartially for Central Command review.<br>"
	if(order.template_id == "security_freight")
		assignment_text += "<br><b>Completion Requirement:</b> Clear and return the referenced consignment through Regional Logistics. Completion is recorded automatically.<br>"
	else if(order.submission_type == CCPOST_TASK_SUBMISSION_INSTALLATION_RECORD)
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

// -------------------------------------------------------------------------
// Dedicated installation Security tasking. Same UI and physical report workflow,
// but no membership in the Liaison dispatch pool, inboxes, or archive.
// -------------------------------------------------------------------------
/obj/item/circuitboard/computer/ccpost_tasking/security
	name = "Central Command Security Tasking Terminal"
	build_path = /obj/machinery/computer/ccpost_tasking/security

/obj/machinery/computer/ccpost_tasking/security
	name = "Central Command security tasking terminal"
	desc = "A secure workstation for installation Security directives, prototype inspections and regional freight clearance."
	circuit = /obj/item/circuitboard/computer/ccpost_tasking/security
	var/security_tick_timer

/obj/machinery/computer/ccpost_tasking/security/Initialize(mapload)
	. = ..()
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	network.registered_terminals -= src
	network.security_terminals |= src
	if(!network.security_board)
		network.security_board = new /obj/item/circuitboard/computer/ccpost_tasking
	security_tick_timer = addtimer(CALLBACK(src, PROC_REF(security_tick)), 30 SECONDS, TIMER_STOPPABLE)

/obj/machinery/computer/ccpost_tasking/security/Destroy()
	if(security_tick_timer)
		deltimer(security_tick_timer)
	GLOB.ccpost_tasking_network.security_terminals -= src
	return ..()

/obj/machinery/computer/ccpost_tasking/security/get_tasking_board()
	return GLOB.ccpost_tasking_network.security_board

/obj/machinery/computer/ccpost_tasking/security/session_valid_for(mob/user)
	if(!tasking_session_mind || user?.mind != tasking_session_mind || !user.client)
		return FALSE
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	return employee && employee.employee_role == "Outpost Security Officer" && employee.employee_mind == tasking_session_mind && employee.original_body?.resolve() == user

/obj/machinery/computer/ccpost_tasking/security/login_tasking_session(mob/user)
	if(!ccpost_terminal_in_range(src, user) || !user.client)
		return FALSE
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user)
	if(!employee || employee.employee_role != "Outpost Security Officer")
		return FALSE
	if(tasking_session_mind && tasking_session_mind != employee.employee_mind)
		logout_tasking_session()
	for(var/obj/machinery/computer/ccpost_tasking/security/other as anything in GLOB.ccpost_tasking_network.security_terminals)
		if(other != src && other.tasking_session_mind == employee.employee_mind)
			other.logout_tasking_session()
	tasking_session_mind = employee.employee_mind
	tasking_session_name = employee.employee_name
	tasking_unlock_desk(user)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(board?.current_order)
		board.current_order.assigned_to = employee.employee_name
	if(board?.standby_order)
		board.standby_order.assigned_to = employee.employee_name
	GLOB.ccpost_tasking_network.security_sync_freight()
	security_restore_report()
	SStgui.update_uis(src)
	return TRUE

// Never enter the inherited Liaison dispatcher, even if a generic timer or
// incident callback encounters this subtype.
/obj/machinery/computer/ccpost_tasking/security/schedule_next_assignment(minimum_delay, maximum_delay)
	return

/obj/machinery/computer/ccpost_tasking/security/issue_assignment()
	return

/obj/machinery/computer/ccpost_tasking/security/queue_event_task(template_type, cooldown_duration, observation)
	return

/obj/machinery/computer/ccpost_tasking/security/proc/security_tick()
	security_tick_timer = null
	if(QDELETED(src))
		return
	security_tick_timer = addtimer(CALLBACK(src, PROC_REF(security_tick)), 30 SECONDS, TIMER_STOPPABLE)
	if(GLOB.ccpost_outpost_signal_lost || !SSticker.IsRoundInProgress())
		return
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	if(!network.server_online())
		return
	network.security_sync_freight()
	if(!(machine_stat & (BROKEN | NOPOWER)))
		network.security_issue_routine()
	SStgui.update_uis(src)

/datum/ccpost_tasking_network/proc/security_new_order(template_id, subject, instruction, priority = CCPOST_TASK_PRIORITY_ROUTINE)
	var/datum/ccpost_task_template/template = new
	template.template_id = template_id
	template.category = "Installation Security"
	template.subject = subject
	template.instruction = instruction
	template.priority = priority
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/order_code = "SEC-[round_identifier]-[next_order_number]"
	next_order_number++
	var/datum/ccpost_tasking_order/order = new(order_code, template)
	qdel(template)
	order.assigned_to = "Outpost Security Officer"
	for(var/obj/machinery/computer/ccpost_tasking/security/terminal as anything in security_terminals)
		if(terminal.tasking_session_mind)
			order.assigned_to = terminal.tasking_session_name
			break
	order.record_action("Issued", "CENTRAL COMMAND", "Installation Security directive")
	return order

/datum/ccpost_tasking_network/proc/security_notify(reference, subject, urgent = FALSE)
	// Physical tasking alerts mirror Liaison terminals; the balloon is private
	// and follows the registered Security Officer even when the desk is locked.
	for(var/obj/machinery/computer/ccpost_tasking/security/terminal as anything in security_terminals)
		if(QDELETED(terminal) || (terminal.machine_stat & (BROKEN | NOPOWER)))
			continue
		playsound(terminal, 'sound/machines/terminal/terminal_alert.ogg', vol = urgent ? 85 : 45, vary = !urgent)
		terminal.visible_message(urgent ? span_warning("[terminal] sounds an urgent priority tasking alert.") : span_notice("[terminal] chimes. A Central Command security tasking order is ready."))
	for(var/mob/living/carbon/human/officer as anything in GLOB.mob_living_list)
		if(!ishuman(officer) || !officer.client || officer.stat == DEAD)
			continue
		var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(officer, FALSE)
		if(employee?.employee_role != "Outpost Security Officer")
			continue
		officer.balloon_alert(officer, urgent ? "priority security notice!" : "new security assignment")
		ccpost_notify_liaison(employee.employee_mind, "tasking", reference, subject)

/datum/ccpost_tasking_network/proc/security_refresh()
	for(var/obj/machinery/computer/ccpost_tasking/security/terminal as anything in security_terminals)
		if(!QDELETED(terminal))
			SStgui.update_uis(terminal)

/datum/ccpost_tasking_network/proc/security_archive(datum/ccpost_tasking_order/order)
	if(!order || order in security_history)
		return
	security_history.Insert(1, order)
	while(length(security_history) > max_history)
		var/datum/ccpost_tasking_order/oldest = security_history[length(security_history)]
		security_history.Cut(length(security_history), length(security_history) + 1)
		qdel(oldest)
	security_refresh()

/datum/ccpost_tasking_network/proc/security_freight_dispatched(reference)
	if(!reference || GLOB.ccpost_outpost_signal_lost || security_freight_reference == reference)
		return
	security_freight_reference = reference
	security_freight_arrived_at_bay = FALSE
	security_notify("freight:[reference]", "Regional Freight Inspection: [reference]", TRUE)
	security_refresh()

/datum/ccpost_tasking_network/proc/security_freight_arrived(reference)
	if(security_freight_reference != reference || security_freight_arrived_at_bay)
		return
	security_freight_arrived_at_bay = TRUE
	security_refresh()

/datum/ccpost_tasking_network/proc/security_freight_resolved(reference, result)
	if(!reference || security_freight_reference != reference)
		return
	security_freight_reference = null
	security_freight_arrived_at_bay = FALSE
	// Logistics owns certification, the inspection record and the CU reward.
	if(result == "Cleared")
		ccpost_record_admin_activity("security-freight:[reference]", 2)
	security_refresh()

/datum/ccpost_tasking_network/proc/security_sync_freight()
	var/obj/structure/closet/crate/ccpost_freight/inspection/crate = GLOB.ccpost_logistics_network?.active_inspection?.resolve()
	if(crate && !QDELETED(crate))
		security_freight_dispatched(crate.shipment_code)
		if(crate.inspection_arrived)
			security_freight_arrived(crate.shipment_code)
	else if(security_freight_reference)
		security_freight_resolved(security_freight_reference, "Unavailable")

/datum/ccpost_tasking_network/proc/security_issue_routine()
	if(!security_board || security_board.current_order || security_board.standby_order || !length(security_terminals))
		return
	// Security work is available only when a real registered officer is present.
	var/mob/living/carbon/human/officer
	for(var/mob/living/carbon/human/person as anything in GLOB.mob_living_list)
		if(!ishuman(person) || !person.client || person.stat == DEAD || !istype(get_area(person), /area/ruin/space/has_grav/ccpost))
			continue
		var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(person, FALSE)
		if(employee?.employee_role == "Outpost Security Officer")
			officer = person
			break
	if(!officer)
		return
	if(!security_next_routine_at)
		security_next_routine_at = world.time + 1 MINUTES
		return
	if(world.time < security_next_routine_at)
		return
	var/obj/item/prototype
	for(var/datum/weakref/reference as anything in GLOB.ccpost_severance_prototypes)
		var/obj/item/candidate = reference.resolve()
		if(istype(candidate, /obj/item/gun/energy/modular_laser_rifle/ccpost_chimera))
			prototype = candidate
			break
	if(!prototype && !security_compromise_pending)
		return
	var/datum/ccpost_tasking_order/order
	if(security_compromise_pending)
		security_compromise_pending = FALSE
		order = security_new_order("security_compromise", "Experimental Asset Compromise", "Investigate the previously reported prototype custody discrepancy. Record the last confirmed custody, known circumstances, recovery efforts and any remaining security concerns. Do not pursue beyond authorized installation duties or invent information. Submit a stamped incident report.", CCPOST_TASK_PRIORITY_ELEVATED)
	else
		var/list/pool = list("security_inventory", "security_thermal", "security_discharge", "security_accountability")
		pool -= security_completed_templates
		if(!length(pool))
			return
		var/template_id = !("security_inventory" in security_completed_templates) ? "security_inventory" : pick(pool)
		switch(template_id)
			if("security_inventory")
				order = security_new_order(template_id, "NT-X01 Experimental Asset Inventory", "Inspect the original NT-X01 Chimera prototype. Confirm its condition, authorized custody and storage arrangements. Record the weapon designation, observed condition, and any discrepancy. Return it to the secure armory when finished and submit a stamped report.")
			if("security_thermal")
				order = security_new_order(template_id, "NT-X01 Reactor and Thermal Safety Evaluation", "Inspect Chimera's charge, heat and manual venting procedure. Review the classified dossier. If an approved safe test area is available, conduct a controlled discharge and venting test; otherwise document a non-firing inspection and any limitations. Do not deliberately overheat the prototype. Submit a stamped report.")
			if("security_discharge")
				var/mode = pick("Pulse", "Lance", "Suppression", "Graviton", "Cataclysm")
				order = security_new_order(template_id, "NT-X01 Configuration Evaluation: [mode]", "Evaluate the [mode] configuration using the dossier and, only if safe and authorized, a controlled test away from personnel and critical equipment. Record observed or documented behavior, risks and suitability for installation defense. Do not discharge Graviton or Cataclysm inside occupied spaces. Return the weapon and submit a stamped report.")
			if("security_accountability")
				order = security_new_order(template_id, "NT-X01 Classified Technology Accountability", "Review the prototype dossier, access controls, custody procedures and armory arrangements. Verify that authorized handling and return procedures are understood. Document actual discrepancies or explicitly record none. Submit a stamped report.")
	if(!order)
		return
	order.assigned_to = officer.real_name
	security_board.current_order = order
	security_notify(order.order_code, order.subject, order.priority != CCPOST_TASK_PRIORITY_ROUTINE)
	security_refresh()

/obj/machinery/computer/ccpost_tasking/security/proc/security_restore_report()
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	var/datum/ccpost_tasking_order/order = board?.current_order
	if(order?.standby_report && !submitted_report)
		submitted_report = order.standby_report
		order.standby_report = null
		submitted_report.forceMove(src)

/obj/machinery/computer/ccpost_tasking/security/ui_data(mob/user)
	var/list/data = list("security_tasking" = TRUE)
	if(!isobserver(user) && !ccpost_terminal_in_range(src, user))
		return data
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(user)
	data["read_only"] = isobserver(user)
	data["authenticated"] = isobserver(user) || !!tasking_desk_access(user)
	data["identity_detected"] = !!(employee && employee.employee_role == "Outpost Security Officer")
	data["identity_portrait"] = data["identity_detected"] ? employee.portrait_base64 : null
	data["identity_issue"] = data["identity_detected"] ? "" : "No authorized Outpost Security ID detected. Hold or equip your registered ID to authenticate."
	data["session_owner"] = isobserver(user) ? "Observer" : (data["authenticated"] ? (tasking_session_name || "") : "")
	data["admin_server_online"] = network.server_online() && !(machine_stat & (BROKEN | NOPOWER))
	data["admin_server_status"] = network.server_status()
	if(!data["authenticated"])
		return data
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	data["current_order"] = order_to_ui_data(board?.current_order)
	data["standby_order"] = order_to_ui_data(board?.standby_order)
	var/datum/ccpost_hr_employee/session_employee = GLOB.ccpost_hr_service?.employee_for(user, FALSE)
	data["pda_notifications"] = !!session_employee?.tasking_pda_notifications
	data["security_freight_reference"] = network.security_freight_reference
	data["security_freight_arrived"] = network.security_freight_arrived_at_bay
	data["security_can_report_compromise"] = (board?.current_order?.template_id in list("security_inventory", "security_accountability"))
	data["can_switch_investigation"] = FALSE
	data["submitted_report"] = isobserver(user) ? null : report_to_ui_data(submitted_report)
	var/list/history = list()
	for(var/datum/ccpost_tasking_order/order as anything in network.security_history)
		history += list(order_to_ui_data(order))
	data["history"] = history
	data["deferred_orders"] = list()
	data["on_hold_orders"] = list()
	data["queued_incidents"] = list()
	data["pending_followups"] = list()
	return data

/obj/machinery/computer/ccpost_tasking/security/find_order(order_code)
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	if(board?.current_order?.order_code == order_code)
		return board.current_order
	if(board?.standby_order?.order_code == order_code)
		return board.standby_order
	for(var/datum/ccpost_tasking_order/order as anything in GLOB.ccpost_tasking_network.security_history)
		if(order.order_code == order_code)
			return order
	return null

/obj/machinery/computer/ccpost_tasking/security/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// Reuse existing acknowledgement, printing and report ejection, but never
	// invoke the Liaison completion, transfer, deferral or grant handlers.
	if(action in list("login", "logout", "acknowledge", "eject_report", "print_order", "print_template", "print_archived_report", "toggle_pda_notifications"))
		return ..()
	if(action != "complete" && action != "complete_compromise")
		return TRUE
	var/mob/user = ui?.user
	if(!tasking_desk_access(user) || !GLOB.ccpost_tasking_network.server_online() || (machine_stat & (BROKEN | NOPOWER)))
		return TRUE
	var/datum/ccpost_tasking_network/network = GLOB.ccpost_tasking_network
	var/obj/item/circuitboard/computer/ccpost_tasking/board = get_tasking_board()
	var/datum/ccpost_tasking_order/order = board?.current_order
	if(!order || order.template_id == "security_freight" || order.status != CCPOST_TASK_STATUS_ACKNOWLEDGED)
		return TRUE
	if(action == "complete_compromise" && !(order.template_id in list("security_inventory", "security_accountability")))
		return TRUE
	var/rejection = report_validation_issue(submitted_report)
	if(rejection)
		balloon_alert(user, rejection)
		return TRUE
	var/obj/item/paper/report = submitted_report
	submitted_report = null
	archive_submitted_report(order, report)
	order.status = CCPOST_TASK_STATUS_COMPLETED
	order.completed_by = user.name
	order.completed_at = station_time_timestamp()
	order.record_action("Completed", user.name, "Stamped Security report accepted")
	if(action == "complete_compromise")
		network.security_compromise_pending = TRUE
		order.record_action("Discrepancy reported", user.name, "Security requested follow-up investigation")
	if(order.template_id != "security_compromise")
		network.security_completed_templates |= order.template_id
	// Use the same priority-based CU rewards as Liaison tasking, but no departmental grants.
	if(!order.rewards_issued)
		order.rewards_issued = TRUE
		var/datum/ccpost_logistics_network/logistics = GLOB.ccpost_logistics_network
		if(logistics)
			var/credited = logistics.credit_allocation(order.get_allocation_reward(), "Completed security order [order.order_code]: [order.subject]", user.name)
			if(credited > 0)
				logistics.refresh_registered_terminals()
				say("Security tasking compensation authorized. [credited] CU has been credited to this installation's Operational Allocation.")
			else
				say("Security tasking compensation processed. Operational Allocation is already at maximum capacity.")
	ccpost_record_admin_activity("security-task:[order.order_code]", 2)
	board.current_order = null
	network.security_archive(order)
	network.security_next_routine_at = world.time + (network.security_compromise_pending ? 30 SECONDS : rand(12 MINUTES, 18 MINUTES))
	qdel(report)
	balloon_alert(user, "security report accepted")
	network.security_refresh()
	return TRUE

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

