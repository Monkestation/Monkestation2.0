///Stuff used in Central Command Liaison Outpost Ruin.

/obj/item/paper/fluff/ruins/ccpost/transmission
	default_raw_text = "Nothing of interest"

// Central Command Assignment for Liaison, also explains what's expected of them in more detail

/obj/item/paper/fluff/ruins/ccpost/transmission/assignment
	name = "liaison outpost assignment"
	default_raw_text = {"<center><table border="0" cellspacing="0" cellpadding="4" bgcolor="#0a1e2b" style="border: 4px solid white; border-radius: 10px; font-family: Bahnschrift, sans-serif;"><tr><td><font color="#f0f0f0" size="6"><b>&#9701;</b></font></td><td><font color="#f0f0f0" size="7"><b>N</b></font></td><td><font color="#f0f0f0" size="6"><b>&#9699;</b></font></td></tr></table></center>
	<br><center><small><i>This paper has been transmitted by Central Command</i></small></center><hr><hr><small>
	<br>
	<br>Name: Nina C. Trayson
	<br>Rank: CentCom Official
	<br>Position: Liaison Manager
	<br>
	<br>Posting: Central Command Liaison Outpost
	<br>Assigned Personnel: CentCom Liaisons
	<br>Priority: High
	<br>Status: Active
	<br>
	<br>Subject: OFFICIAL DUTY ASSIGNMENT
	<br>
	<br>You have been assigned to this installation on behalf of Central Command for the purpose of monitoring nearby Nanotrasen operations and maintaining an accurate record of station activity.
	<br>
	<br>Your primary responsibility is to act as Central Command's local eyes and ears within the sector.
	<br>
	<br>During your assignment, you are expected to:
	<br>
	<br>- Monitor station operations through available camera, telemetry, and communications systems.
	<br>- Maintain professional contact with the station's Command staff.
	<br>- Investigate significant irregularities, infrastructure failures, and other matters worthy of Central Command attention.
	<br>- Request clarification or departmental reports when available information is incomplete or contradictory.
	<br>- Record noteworthy events and preserve relevant communications for later review.
	<br>- Review and complete assignments coming in from the Central Command Tasking Terminal within your office.
	<br>- Maintain the outpost, its communications equipment, records, and monitoring systems in operational condition.
	<br>- Submit accurate reports to Central Command when requested, or when circumstances warrant escalation.
	<br>
	<br>You are reminded that this posting grants you oversight authority, not operational command of the station.
	<br>
	<br>The Captain remains responsible for station operations. You may provide recommendations, request information, and relay legitimate Central Command directives, but you are not authorized to assume command of station departments or interfere unnecessarily with routine operations.
	<br>
	<br>Remain professional. Remain objective. Verify information before reporting it as fact.
	<br>
	<br>Under ordinary circumstances, personnel assigned to this outpost are expected to remain aboard the installation. Direct intervention in station affairs is outside the scope of this assignment unless specifically authorized by Central Command.
	<br>
	<br>Information obtained through Central Command systems is to be treated as privileged corporate material and handled accordingly.
	<br>
	<br>At the conclusion of the operational period, personnel should be prepared to provide an assessment of the station's condition, significant incidents, Command response, and any matters requiring further Central review.
	<br>
	<br>Failure to maintain adequate oversight may result in reassignment to a position involving substantially fewer windows.
	<br>
	<br></small><hr><hr><small><i>Signed, Nina C. Trayson</i></small>
	<br>CENTRAL COMMAND
	<br>SECTOR OVERSIGHT DEPARTMENT
	"}

/obj/structure/closet/secure_closet/centcom_liaison
	name = "CentCom Liaison's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"

/obj/structure/closet/secure_closet/centcom_liaison/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest/nanotrasen_representative/bathrobe(src)
	new /obj/item/clothing/suit/armor/centcom_formal(src)
	new /obj/item/clothing/suit/toggle/centcom_jacket(src)
	new /obj/item/clothing/under/rank/centcom/official(src)
	new /obj/item/clothing/under/rank/centcom/official/skirt(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/binoculars(src)
	new /obj/item/implanter/mindshield(src)

// Central Command Advisor Hologram code

// Custom proximity monitor for the advisor.
// A player triggers once when entering the radius, and cannot trigger again
// until they have actually left the radius and re-entered.

/datum/proximity_monitor/ccpost_advisor
	/// Players who have triggered the advisor before.
	var/list/triggered_mobs = list()

/datum/proximity_monitor/ccpost_advisor/on_entered(
	atom/source,
	atom/movable/arrived,
	turf/old_loc
)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return

	var/mob/living/nearby_mob = arrived

	// Only actual player-controlled mobs trigger Nina.
	if(!nearby_mob.client)
		return

	var/turf/holopad_turf = get_turf(host)
	if(!holopad_turf)
		return

	var/turf/old_turf = get_turf(old_loc)

	// If this player has triggered Nina before, only allow another trigger
	// if they came from OUTSIDE the proximity radius.
	if(nearby_mob in triggered_mobs)
		if(old_turf && old_turf.z == holopad_turf.z && get_dist(old_turf, holopad_turf) <= current_range)
			return

	else
		triggered_mobs += nearby_mob
		RegisterSignal(
			nearby_mob,
			COMSIG_QDELETING,
			PROC_REF(clear_triggered_mob)
		)

	hasprox_receiver?.HasProximity(nearby_mob)

/datum/proximity_monitor/ccpost_advisor/proc/clear_triggered_mob(mob/living/tracked_mob)
	SIGNAL_HANDLER

	triggered_mobs -= tracked_mob
	UnregisterSignal(tracked_mob, COMSIG_QDELETING)

/datum/proximity_monitor/ccpost_advisor/Destroy()
	for(var/mob/living/tracked_mob as anything in triggered_mobs)
		UnregisterSignal(tracked_mob, COMSIG_QDELETING)

	triggered_mobs.Cut()

	return ..()


// Central Command Advisor Holopad

/obj/machinery/holopad/tutorial/ccpost_advisor
	play_once = FALSE
	proximity_range = 2

/obj/machinery/holopad/tutorial/ccpost_advisor/Initialize(mapload)
	// Prevent the parent tutorial holopad from creating its normal
	// proximity monitor.
	var/advisor_proximity_range = proximity_range
	proximity_range = 0

	. = ..()

	proximity_range = advisor_proximity_range

	// Install Nina's custom proximity monitor.
	if(proximity_range)
		proximity_monitor = new /datum/proximity_monitor/ccpost_advisor(src, proximity_range)

/obj/machinery/holopad/tutorial/ccpost_advisor/HasProximity(atom/movable/proximity_check_mob)
	if(!isliving(proximity_check_mob))
		return

	var/mob/living/nearby_mob = proximity_check_mob

	if(!nearby_mob.client)
		return

	if(replay_mode || !disk?.record)
		return

	replay_start()


// Central Command Advisor Holodisk

/obj/item/disk/holodisk/ruin/space/ccpost/advisor
	name = "Central Command Liaison Manager"
	preset_image_type = /datum/preset_holoimage/ccpost_advisor
	preset_record_text = {"
	NAME Liaison Manager Nina C. Trayson
	SAY Remember, you are here to observe, verify, communicate and record.
	DELAY 50
	"}

	var/static/list/advisor_tips = list(
		"Remember, you are here to observe, verify, communicate and record.",
		"A good report distinguishes confirmed information from speculation.",
		"The Captain commands the station. You advise, observe, and report.",
		"Not every irregularity requires Central Command intervention.",
		"Maintain accurate records. Your replacement will thank you.",
		"Professional communication is considerably cheaper than an Emergency Response Team.",
		"If you cannot verify it, do not report it as fact.",
		"Central Command appreciates concise reports. Central Command also appreciates correct reports.",
		"Central Command reminds you that 'I saw it on the cameras' is not a recognized investigative methodology.",
		"Your authority is derived from Central Command. Your good judgement, regrettably, is your own responsibility.",
		"If the Captain disagrees with your recommendation, document it. Do not start a constitutional crisis.",
		"Remember to take regular breaks. Fatigued bureaucrats produce approximately seventeen percent more paperwork.",
		"Remember: an unfiled incident is statistically indistinguishable from an incident that never occurred.",
		"Do not threaten the station with an Emergency Response Team. Emergency Response Teams are expensive.",
		"If three departments give you three different versions of the same incident, congratulations. You now have an investigation.",
		"Request clarification before requesting intervention.",
		"Repeatedly contacting the Captain does not make your request more official.",
		"Multiple explosions may indicate a developing situation.",
		"Take notes during major incidents. Human memory has repeatedly failed company quality assurance testing.",
		"Remain objective. The station is fully capable of embarrassing itself without your assistance.",
		"Please do not classify routine incompetence as sabotage without supporting evidence.",
		"Do not threaten people with paperwork unless you are prepared to actually complete it.",
		"If you write 'situation normal,' please include what definition of normal you are using.",
		"Please do not describe casualties as 'a staffing adjustment.'",
		"Central Command thanks you for your continued compliance with policies you were not consulted on.",
		"Please avoid referring to your assignment as 'remote isolation.' The approved term is 'independent operational posting.'",
		"Corporate policy exists to protect employees, assets, and corporate policy.",
		"Please refrain from describing company policy as 'inhuman' in official correspondence.",
		"Central Command appreciates solutions that fit within the existing budget.",
		"If Engineering has stopped answering, check whether Engineering still exists.",
		"Remember: a satisfied employee is productive. A dissatisfied employee is still scheduled.",
		"Central Command values transparency, provided it has been properly authorized.",
		"Corporate loyalty is its own reward. Additional rewards remain subject to budget approval.",
		"An employee who follows procedure has nothing to fear from an audit.",
		"Remember, Liaison: there is no greater service to Nanotrasen than making someone else's emergency less expensive.",
		"Central Command hears every concern eventually.",
		"An orderly station is a productive station. A productive station is a profitable station. A profitable station is a successful station.",
		"Remain vigilant. Inefficiency can emerge anywhere, at any time, in any department.",
		"Every accurate report is another victory for corporate order.",
		"Remember, Liaison: doubt is temporary. Central Command policy is permanent.",
		"The Logistics Terminal draws from this installation's Operational Allocation. A requisition being affordable does not necessarily make it necessary.",
		"Operational Allocation is finite. Completed tasking orders and approved sector work may replenish it. Poor purchasing decisions are not an emergency.",
		"Every Logistics requisition is recorded. This remains true when procurement safeguards have been bypassed.",
		"Empty Central Command freight containers may be returned for a small allocation credit. Central Command appreciates recycling when it is cheaper than replacement.",
		"Completed Tasking Terminal assignments provide Operational Allocation and may also authorize a grant to the relevant station department. Properly stamped paperwork can, on occasion, be profitable.",
		"The Tasking Terminal does not accept good intentions as supporting documentation. It accepts written reports bearing a Central Command stamp.",
		"The Sector Communications Terminal carries requests and operational updates from nearby installations. Read the transmission before authorizing expenditure.",
		"Authorizing sector assistance may cost Operational Allocation. Denying assistance may cost considerably more, although Finance prefers not to phrase it that way.",
		"Liaison, don't forget to regularly check the tasking terminal for new assignments."
	)

/obj/item/disk/holodisk/ruin/space/ccpost/advisor/proc/select_random_tip()
	if(!record)
		return

	record.caller_name = "Liaison Manager Nina C. Trayson"
	record.entries = list(
		list(HOLORECORD_SAY, pick(advisor_tips)),
		list(HOLORECORD_DELAY, 70)
	)

/obj/machinery/holopad/tutorial/ccpost_advisor/replay_start()
	var/obj/item/disk/holodisk/ruin/space/ccpost/advisor/advisor_disk = disk
	advisor_disk?.select_random_tip()

	return ..()


// Advisor Hologram Preset

/datum/preset_holoimage/ccpost_advisor
	outfit_type = /datum/outfit/centcom/ccpost_advisor
	species_type = /datum/species/human

/datum/preset_holoimage/ccpost_advisor/build_image()
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy("HOLODISK_PRESET")

	mannequin.set_species(species_type)

	// Character Appearance
	mannequin.gender = FEMALE
	mannequin.physique = FEMALE
	mannequin.skin_tone = "caucasian1"

	mannequin.set_haircolor("#443333", update = FALSE)
	mannequin.set_hairstyle("Long Side Part", update = FALSE)
	mannequin.set_hair_gradient_style("None", update = FALSE)

	mannequin.eye_color_left = "#447766"
	mannequin.eye_color_right = "#447766"

	mannequin.set_facial_hairstyle("Shaved", update = FALSE)
	mannequin.set_facial_hair_gradient_style("None", update = FALSE)

	mannequin.underwear = "Bikini"
	mannequin.underwear_color = "#333333"
	mannequin.socks = "Stockings (Fishnet)"
	mannequin.socks_color = "#902DD5"

	mannequin.update_body()

	// Mannequin Outfit
	if(outfit_type)
		mannequin.equipOutfit(outfit_type, TRUE)

	mannequin.setDir(SOUTH)

	. = image(mannequin)
	unset_busy_human_dummy("HOLODISK_PRESET")


// Advisor Hologram Outfit

/datum/outfit/centcom/ccpost_advisor
	name = "CentCom Liaison Manager"

	uniform = /obj/item/clothing/under/rank/centcom/commander/skirt
	shoes = /obj/item/clothing/shoes/jackboots/heel
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	head = /obj/item/clothing/head/beret/centcom_formal


// Central Command Escalation Request Button
// note: this button purposefully does nothing.

/obj/machinery/button/ccpost_escalation
	name = "Central Command escalation request"
	desc = "A secure priority request terminal intended for circumstances deemed worthy of direct Central Command attention. A small label reads: 'Submission does not constitute approval.'"

	icon_state = "button-warning"
	skin = "-warning"
	can_alter_skin = FALSE

	COOLDOWN_DECLARE(escalation_cooldown)
	var/escalation_cooldown_duration = 30 SECONDS

	var/static/list/escalation_responses = list(
		"Request received. Estimated review time: two to six business shifts.",
		"Request received. Please remain calm and avoid creating additional billable incidents.",
		"Request received. Please attempt local resolution before requesting additional resources.",
		"Request received. Your request has been forwarded to the appropriate department. The appropriate department has not been identified.",
		"Request received. Your concern has been assigned priority status: Routine.",
		"Request received. Please exhaust cheaper solutions before requesting trained personnel.",
		"Request received. If the station is no longer physically present, discontinue routine monitoring.",
		"Request received. Central Command recognizes the seriousness of the situation and will continue recognizing it.",
		"Request received. Your sense of urgency has not altered the budget.",
		"Request received. Further escalation has been deferred pending evidence of further escalation."
	)

/obj/machinery/button/ccpost_escalation/proc/escalation_authorized()
	return SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED

/obj/machinery/button/ccpost_escalation/attack_hand(mob/user, list/modifiers)
	if(!escalation_authorized())
		var/current_alert = uppertext(SSsecurity_level.get_current_level_as_text())

		balloon_alert(user, "escalation criteria not met")
		playsound(src, SFX_BUTTON_FAIL, vol = 45, vary = TRUE)

		say("Request rejected. Current station alert condition: [current_alert]. Escalation criteria have not been met. Continue routine monitoring.")
		return

	if(!COOLDOWN_FINISHED(src, escalation_cooldown))
		balloon_alert(user, "request already pending")
		playsound(src, SFX_BUTTON_FAIL, vol = 45, vary = TRUE)
		return

	. = ..()
	if(.)
		return

	COOLDOWN_START(src, escalation_cooldown, escalation_cooldown_duration)

	visible_message(
		span_notice("[user] submits a priority escalation request through [src].")
	)

	say("Escalation request transmitted.")

	addtimer(CALLBACK(src, PROC_REF(receive_escalation_response), user), 3 SECONDS)

/obj/machinery/button/ccpost_escalation/proc/receive_escalation_response(mob/user)
	if(QDELETED(user))
		return

	var/response = pick(escalation_responses)

	say("[response]")

	playsound(src, SFX_BUTTON_CLICK, vol = 35, vary = TRUE)

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

	var/status = "Pending"

	var/issued_at
	var/acknowledged_by
	var/acknowledged_at
	var/completed_by
	var/completed_at


/datum/ccpost_tasking_order/New(_order_code, list/template)
	. = ..()

	order_code = _order_code
	template_id = template["id"]
	category = template["category"]
	subject = template["subject"]
	priority = template["priority"]
	instruction = template["instruction"]

	department_reward_id = template["department_reward_id"]

	if(!isnull(template["audit_requisition_count"]))
		audit_requisition_count = template["audit_requisition_count"]

	if(!isnull(template["audit_compliance_points"]))
		audit_compliance_points = template["audit_compliance_points"]

	audit_severity = template["audit_severity"]

	issued_at = station_time_timestamp()


/// Returns the Operational Allocation reward for this task.
///
/// Task value is determined by its priority rather than being configured
/// individually on every assignment template.
/datum/ccpost_tasking_order/proc/get_allocation_reward()
	switch(priority)
		if("Routine")
			return 5

		if("Elevated")
			return 7

		if("Priority")
			return 10

		if("Critical")
			return 15

	return 5


/// Returns the station departmental budget grant for this task.
///
/// The amount is based on task priority. The assignment template decides
/// which department, if any, receives it.
/datum/ccpost_tasking_order/proc/get_department_reward()
	switch(priority)
		if("Routine")
			return 500

		if("Elevated")
			return 750

		if("Priority")
			return 1000

		if("Critical")
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
	var/last_template_id

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
	var/static/list/assignment_templates = list(
		list(
			"id" = "command_status",
			"category" = "Command Oversight",
			"subject" = "General Operational Status",
			"priority" = "Routine",
			"instruction" = "Contact station Command and request a general operational status report. Identify any unresolved matters which may warrant continued Central Command observation.",
			"department_reward_id" = ACCOUNT_CMD
		),
		list(
			"id" = "command_coordination",
			"category" = "Command Oversight",
			"subject" = "Departmental Coordination Review",
			"priority" = "Routine",
			"instruction" = "Assess whether station Command is maintaining effective communication and coordination between departments. Document any significant breakdowns in the chain of communication.",
			"department_reward_id" = ACCOUNT_CMD
		),
		list(
			"id" = "command_concern",
			"category" = "Command Oversight",
			"subject" = "Command Concern Inquiry",
			"priority" = "Routine",
			"instruction" = "Request that station Command identify its most significant current operational concern. Verify the matter where practical and record your assessment.",
			"department_reward_id" = ACCOUNT_CMD
		),
		list(
			"id" = "security_arrests",
			"category" = "Security Oversight",
			"subject" = "Arrest Procedure Review",
			"priority" = "Routine",
			"instruction" = "Review Security's handling of recent arrests and determine whether appropriate procedure appears to be followed. Distinguish confirmed information from allegation or speculation.",
			"department_reward_id" = ACCOUNT_SEC
		),
		list(
			"id" = "security_investigations",
			"category" = "Security Oversight",
			"subject" = "Unresolved Investigation Review",
			"priority" = "Routine",
			"instruction" = "Contact Security and request an overview of any unresolved high-priority investigations. Determine whether any require additional Central Command monitoring.",
			"department_reward_id" = ACCOUNT_SEC
		),
		list(
			"id" = "engineering_status",
			"category" = "Infrastructure Oversight",
			"subject" = "Engineering Status Assessment",
			"priority" = "Routine",
			"instruction" = "Contact Engineering and request an assessment of current station infrastructure, including any significant power, atmospheric, structural, or telecommunications concerns.",
			"department_reward_id" = ACCOUNT_ENG
		),
		list(
			"id" = "engineering_sustainability",
			"category" = "Infrastructure Oversight",
			"subject" = "Continued Operations Assessment",
			"priority" = "Routine",
			"instruction" = "Request an assessment from Engineering regarding the station's ability to sustain continued operations. Record any systems identified as vulnerable or degraded.",
			"department_reward_id" = ACCOUNT_ENG
		),
		list(
			"id" = "communications",
			"category" = "Communications Oversight",
			"subject" = "Communications Integrity Review",
			"priority" = "Routine",
			"instruction" = "Review recent station communications for conflicting, incomplete, or unverifiable information. Request clarification from relevant personnel where necessary.",
			"department_reward_id" = ACCOUNT_CMD
		),
		list(
			"id" = "communications_outage",
			"category" = "Communications Oversight",
			"subject" = "Communications Reliability Inquiry",
			"priority" = "Routine",
			"instruction" = "Determine whether the station has experienced any significant communications outages or disruptions. Establish their likely cause and operational impact.",
			"department_reward_id" = ACCOUNT_ENG
		),
		list(
			"id" = "medical_status",
			"category" = "Medical Oversight",
			"subject" = "Personnel Condition Report",
			"priority" = "Routine",
			"instruction" = "Request a personnel and casualty status report from Medical. Identify any unusual casualty trends or incidents requiring further review.",
			"department_reward_id" = ACCOUNT_MED
		),
		list(
			"id" = "casualty_review",
			"category" = "Medical Oversight",
			"subject" = "Casualty Review",
			"priority" = "Routine",
			"instruction" = "Determine whether any recent casualties warrant further Central Command review. Establish whether hostile action, negligence, or routine operational hazards were involved.",
			"department_reward_id" = ACCOUNT_MED
		),
		list(
			"id" = "explosions",
			"category" = "Incident Review",
			"subject" = "Explosive Incident Inquiry",
			"priority" = "Routine",
			"instruction" = "Request clarification regarding any significant explosions reported aboard the station. Determine their approximate cause, location, and effect on station operations.",
			"department_reward_id" = ACCOUNT_ENG
		),
		list(
			"id" = "sabotage_review",
			"category" = "Incident Review",
			"subject" = "Sabotage Assessment",
			"priority" = "Routine",
			"instruction" = "Review recent significant incidents and assess whether available evidence better supports deliberate sabotage, negligence, equipment failure, or routine operational error.",
			"department_reward_id" = ACCOUNT_SEC
		),
		list(
			"id" = "department_status",
			"category" = "Operational Oversight",
			"subject" = "Department Readiness Review",
			"priority" = "Routine",
			"instruction" = "Determine whether any station department is operating below acceptable staffing or operational levels. Document any significant deficiencies."
		),
		list(
			"id" = "emergency_readiness",
			"category" = "Operational Oversight",
			"subject" = "Emergency Preparedness Review",
			"priority" = "Routine",
			"instruction" = "Assess the station's present emergency preparedness. Identify any obvious deficiencies in coordination, staffing, equipment, or response capability.",
			"department_reward_id" = ACCOUNT_CMD
		),
		list(
			"id" = "conflicting_accounts",
			"category" = "Administrative Oversight",
			"subject" = "Report Consistency Review",
			"priority" = "Routine",
			"instruction" = "Review available departmental accounts of recent noteworthy incidents. Identify significant contradictions and request clarification where appropriate.",
			"department_reward_id" = ACCOUNT_CMD
		),
		list(
			"id" = "monitoring_assessment",
			"category" = "Administrative Oversight",
			"subject" = "Monitoring Requirement Assessment",
			"priority" = "Routine",
			"instruction" = "Determine whether current station conditions justify increased Central Command monitoring. Record the factors supporting your conclusion."
		),
		list(
			"id" = "outpost_audit",
			"category" = "Internal Compliance",
			"subject" = "Liaison Outpost Compliance Audit",
			"priority" = "Routine",
			"instruction" = "Central Command Internal Compliance has selected this installation for a routine audit. Review the outpost's Operational Allocation ledger, freight requisition history, recent Sector Communications responses, and completed tasking records. Submit a concise account of any discrepancies, unexplained expenditures, missing documentation, or procedural violations."
		),
		list(
			"id" = "developing_situation",
			"category" = "General Oversight",
			"subject" = "Developing Situation Review",
			"priority" = "Routine",
			"instruction" = "Identify any developing situation aboard the station which may require future Central Command attention. Verify available information and document your findings."
		)
	)

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

	if(tasking_board.current_order.status == "Pending")
		balloon_alert(user, "acknowledge order first")
		return ITEM_INTERACT_BLOCKING

	if(tasking_board.current_order.status == "Completed")
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
	if(order.template_id == "outpost_audit" && order.audit_compliance_points > 0)
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
		if("SIGNIFICANT")
			assessment = 8
			suspension_duration = 5 MINUTES

		if("SEVERE")
			assessment = 15
			suspension_duration = 10 MINUTES

		else
			severity = "MINOR"

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
	if(tasking_board.current_order && tasking_board.current_order.status != "Completed")
		playsound(src, 'sound/machines/terminal_alert.ogg', vol = 35, vary = TRUE)
		visible_message(
			span_notice("[src] emits a brief reminder tone. An active Central Command tasking order remains unresolved.")
		)
		schedule_next_assignment(5 MINUTES, 8 MINUTES)
		return

	// Move the previous completed task into the archive.
	if(tasking_board.current_order)
		tasking_board.order_history.Insert(
			1,
			tasking_board.current_order
		)

		tasking_board.current_order = null

	var/list/chosen_template
	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network

	// A restricted requisition flags the outpost for a compliance audit. The audit
	// becomes the next available assignment unless the previous assignment was
	// already an audit, in which case one normal task is allowed between them.
	if(logistics_network && logistics_network.contraband_audit_pending && tasking_board.last_template_id != "outpost_audit")
		for(var/list/template as anything in assignment_templates)
			if(template["id"] == "outpost_audit")
				chosen_template = template
				break

	if(!chosen_template)
		chosen_template = pick(assignment_templates)

		// Prevents immediate repeats.
		if(length(assignment_templates) > 1)
			while(chosen_template["id"] == tasking_board.last_template_id)
				chosen_template = pick(assignment_templates)

	// Work from a copy so the static template is never permanently modified by
	// the dynamic audit wording below.
	var/list/effective_template = chosen_template.Copy()

	if(effective_template["id"] == "outpost_audit" && logistics_network)
		var/new_restricted_requisitions = max(0, logistics_network.contraband_requisition_count - logistics_network.contraband_requisitions_at_last_audit)
		var/new_compliance_points = max(0, logistics_network.contraband_compliance_points - logistics_network.contraband_points_at_last_audit)

		if(new_restricted_requisitions > 0)
			var/requisition_label = "requisitions"
			if(new_restricted_requisitions == 1)
				requisition_label = "requisition"

			var/audit_severity = "MINOR"
			var/audit_priority = "Elevated"

			if(new_compliance_points >= 6)
				audit_severity = "SEVERE"
				audit_priority = "Critical"

			else if(new_compliance_points >= 3)
				audit_severity = "SIGNIFICANT"
				audit_priority = "Priority"

			effective_template["priority"] = audit_priority
			effective_template["subject"] = "Procurement Compliance Audit"
			effective_template["audit_requisition_count"] = new_restricted_requisitions
			effective_template["audit_compliance_points"] = new_compliance_points
			effective_template["audit_severity"] = audit_severity
			effective_template["instruction"] = "Central Command Internal Compliance has identified [new_restricted_requisitions] new restricted procurement [requisition_label] associated with this installation since its last review. Preliminary classification: [audit_severity]. Conduct an immediate audit of the Logistics Terminal and Operational Allocation ledger. Account for each restricted order, identify the requesting personnel and operational justification where available, verify the remaining allocation, and document any discrepancies or unauthorized material still held aboard the outpost. Be advised that confirmed violations may result in recovery assessments, withheld task compensation, and temporary suspension of restricted procurement privileges."

			logistics_network.contraband_requisitions_at_last_audit = logistics_network.contraband_requisition_count
			logistics_network.contraband_points_at_last_audit = logistics_network.contraband_compliance_points
			logistics_network.contraband_audit_pending = FALSE

	tasking_board.last_template_id = effective_template["id"]

	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/order_code = "CC-[round_identifier]-[tasking_board.next_order_number]"

	tasking_board.next_order_number++

	tasking_board.current_order = new /datum/ccpost_tasking_order(
		order_code,
		effective_template
	)

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

			if(tasking_board.current_order.status != "Pending")
				balloon_alert(
					user,
					"already acknowledged"
				)

				return TRUE

			tasking_board.current_order.status = "Acknowledged"
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

			if(tasking_board.current_order.status == "Pending")
				balloon_alert(
					user,
					"acknowledge order first"
				)

				return TRUE

			if(tasking_board.current_order.status == "Completed")
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

			tasking_board.current_order.status = "Completed"
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

// CENTRAL COMMAND REMOTE OVERSIGHT NETWORK

// Sector Notice

/datum/ccpost_sector_notice
	var/notice_code
	var/template_id
	var/category
	var/source
	var/priority
	var/title
	var/body
	var/issued_at

/// Optional logistics effects attached to this notice.
	var/logistics_effect_duration = 0
	var/logistics_effect_expires_at = 0

	var/logistics_authorization_delay = 0
	var/logistics_dispatch_delay = 0
	var/logistics_transit_multiplier = 1

	var/logistics_effect_summary

	/// When TRUE and the notice is active, the Liaison Logistics terminal must not offer routine medical resupply.
	var/blocks_medical_supplies = FALSE

/datum/ccpost_sector_notice/New(_notice_code, list/template)
	. = ..()

	notice_code = _notice_code
	template_id = template["id"]
	category = template["category"]
	source = template["source"]
	priority = template["priority"]
	title = template["title"]
	body = template["body"]
	issued_at = station_time_timestamp()

	if(!isnull(template["logistics_effect_duration"]))
		logistics_effect_duration = template["logistics_effect_duration"]

	if(!isnull(template["logistics_authorization_delay"]))
		logistics_authorization_delay = template["logistics_authorization_delay"]

	if(!isnull(template["logistics_dispatch_delay"]))
		logistics_dispatch_delay = template["logistics_dispatch_delay"]

	if(!isnull(template["logistics_transit_multiplier"]))
		logistics_transit_multiplier = template["logistics_transit_multiplier"]

	if(!isnull(template["logistics_effect_summary"]))
		logistics_effect_summary = template["logistics_effect_summary"]

	if(!isnull(template["blocks_medical_supplies"]))
		blocks_medical_supplies = template["blocks_medical_supplies"]

	if(logistics_effect_duration > 0)
		logistics_effect_expires_at = world.time + logistics_effect_duration

/datum/ccpost_sector_notice/proc/has_active_logistics_effect()
	if(!logistics_effect_expires_at)
		return FALSE

	if(world.time >= logistics_effect_expires_at)
		return FALSE

	return TRUE

// Sector Installation History

/// Compact administrative history entry retained on each remote installation.
/// This records operational changes and Liaison decisions without duplicating the
/// full Sector Communications archive.
/datum/ccpost_installation_history_entry
	var/timestamp
	var/category
	var/title
	var/details

/datum/ccpost_installation_history_entry/New(
	_category,
	_title,
	_details
)
	. = ..()

	timestamp = station_time_timestamp()
	category = _category
	title = _title
	details = _details


// Sector Installation

/datum/ccpost_sector_installation
	var/installation_code
	var/installation_name
	var/installation_function

	/// Broad operational status visible to Central Command.
	var/status

	/// Timestamp of the most recent status change.
	var/status_since

	/// Current physical or operational condition.
	var/condition = "OPERATIONAL"

	/// Current state of remote telemetry.
	var/telemetry = "ACTIVE"

	/// Additional information regarding the installation's condition.
	var/condition_details = "No structural concerns reported."

	/// Current or most recent major incident.
	var/incident_summary = "No active incident."

	/// Current Central Command response.
	var/response_status = "NONE"

	/// Whether an Emergency Response Team was dispatched.
	var/ert_dispatched = FALSE

	/// Original incident text for the current or most recent Critical event.
	/// This is kept separately so the visible incident can be marked CONTAINED
	/// during post-Critical recovery without losing the original description.
	var/critical_incident_original

	/// Whether Liaison-controlled emergency Operational Allocation was authorized
	/// during the current Critical incident.
	var/critical_aid_authorized = FALSE

	/// Administrative record of the most recent Critical aid authorization.
	var/critical_aid_authorized_by
	var/critical_aid_authorized_at

	/// Whether Liaison-controlled emergency assistance was explicitly denied
	/// during the current Critical incident.
	var/critical_aid_denied = FALSE

	/// Administrative record of the most recent Critical aid denial.
	var/critical_aid_denied_by
	var/critical_aid_denied_at

	/// TRUE while an installation is recovering from a successfully contained
	/// Critical incident but has not yet returned to green operation.
	var/critical_aftermath_active = FALSE

	/// Pool of personnel who may act as this installation's liaison contact.
	var/list/contact_pool = list()

	/// Primary installation representative selected for this shift.
	var/contact_name = "Unknown Personnel"

	/// Job title of the selected installation representative.
	var/contact_role = "Installation Duty Officer"

	/// Temporary percentage-point increase to this installation's escalation risk
	/// caused by denied Operational Allocation requests. This decays as the
	/// installation survives later status cycles and clears when assistance is
	/// authorized or the installation returns to green operation.
	var/aid_denial_risk = 0

	/// Number of Operational Allocation requests denied during this shift.
	var/aid_denial_count = 0

	/// Administrative record of the most recent denial.
	var/last_aid_denial_at
	var/last_aid_denial_by

	/// Liaison relationship score for this installation. Starts at a neutral 50
	/// and changes only after meaningful administrative or operational decisions.
	var/trust_score = 50

	/// Compact shift-local administrative history, newest entry first.
	var/list/history = list()

	/// At most one ordinary operational follow-up chain may be active for this
	/// installation at a time. The originating message code prevents stale timer
	/// callbacks from continuing an old chain after a newer one has replaced it.
	var/active_followup_origin_code
	var/active_followup_origin_title
	var/active_followup_start_status
	var/followup_chain_step = 0

	/// Destroyed installations are permanently removed from normal rotation.
	var/destroyed = FALSE

/datum/ccpost_sector_installation/New(list/template)
	. = ..()

	installation_code = template["code"]
	installation_name = template["name"]
	installation_function = template["function"]
	status = template["initial_status"]
	status_since = station_time_timestamp()

	var/list/template_contacts = template["contacts"]

	if(length(template_contacts))
		contact_pool = template_contacts.Copy()

		var/list/chosen_contact = pick(contact_pool)

		if(chosen_contact)
			if(chosen_contact["name"])
				contact_name = chosen_contact["name"]

			if(chosen_contact["role"])
				contact_role = chosen_contact["role"]

/datum/ccpost_sector_installation/Destroy()
	QDEL_LIST(history)
	return ..()


// SECTOR INSTALLATION COMMUNICATIONS

/datum/ccpost_sector_message
	var/message_code
	var/template_id

	var/installation_code
	var/installation_name

	var/sender_name
	var/sender_role

	/// UPDATE or REQUEST.
	var/message_type = "UPDATE"

	var/priority = "Routine"
	var/title
	var/body
	var/issued_at

	/// PENDING, ACKNOWLEDGED, AUTHORIZED, DENIED, or EXPIRED.
	var/resolution_status = "PENDING"

	var/responded_by
	var/responded_at
	var/response

	/// CU requested from the Liaison Outpost.
	var/allocation_cost = 0

	/// CU offered to the Liaison Outpost.
	var/allocation_reward = 0

	/// Actual CU change after resolution.
	var/allocation_change = 0

	/// Installation statuses for which this request remains valid.
	var/list/valid_statuses = list()

	/// Optional new installation status applied when authorized.
	var/success_status

	/// Optional condition-details override after authorization.
	var/success_details


/datum/ccpost_sector_message/New(
	_message_code,
	datum/ccpost_sector_installation/installation,
	list/template
)
	. = ..()

	message_code = _message_code
	template_id = template["id"]

	installation_code = installation.installation_code
	installation_name = installation.installation_name

	sender_name = installation.contact_name
	sender_role = installation.contact_role

	message_type = template["type"]
	priority = template["priority"]
	title = template["title"]
	body = template["body"]

	if(!isnull(template["allocation_cost"]))
		allocation_cost = template["allocation_cost"]

	if(!isnull(template["allocation_reward"]))
		allocation_reward = template["allocation_reward"]

	var/list/template_statuses = template["required_statuses"]

	if(length(template_statuses))
		valid_statuses = template_statuses.Copy()

	success_status = template["success_status"]
	success_details = template["success_details"]

	issued_at = station_time_timestamp()


// SECTOR ADMINISTRATIVE PAPERWORK

/// One active administrative document sent from a remote installation to the
/// Liaison Outpost for physical review, CentCom stamping, and return.
/datum/ccpost_sector_paperwork_request
	var/paperwork_code
	var/template_id

	var/installation_code
	var/installation_name
	var/sender_name
	var/sender_role

	var/priority = "Routine"
	var/title
	var/body
	var/issued_at

	/// AWAITING LIAISON REVIEW or TRANSMITTED - AWAITING RECEIPT.
	var/status = "AWAITING LIAISON REVIEW"

	var/submitted_by
	var/submitted_at

	/// Successful processing normally returns two CU to the Liaison Outpost.
	var/allocation_reward = 2

/datum/ccpost_sector_paperwork_request/New(
	_paperwork_code,
	datum/ccpost_sector_installation/installation,
	list/template
)
	. = ..()

	paperwork_code = _paperwork_code
	template_id = template["id"]

	installation_code = installation.installation_code
	installation_name = installation.installation_name
	sender_name = installation.contact_name
	sender_role = installation.contact_role

	title = template["title"]
	body = template["body"]
	issued_at = station_time_timestamp()


/// Physical, machine-identifiable paperwork generated by Sector Communications.
/// The hidden paperwork code prevents renamed, rewritten, or photocopied generic
/// paper from satisfying an active administrative request.
/obj/item/paper/ccpost_sector_paperwork
	name = "sector administrative document"
	desc = "An authenticated administrative document transmitted from a remote Nanotrasen installation for Central Command Liaison review."

	var/paperwork_code


// Shared Sector Network

/datum/ccpost_sector_network
	/// Prevents several displays from independently starting network timers.
	var/started = FALSE

	/// Every Remote Status Display connected to this shared network.
	var/list/registered_displays = list()

	/// Timer for ordinary Central Command sector notices.
	var/sector_notice_timer

	/// Timer for fictional sector installation updates.
	var/sector_installation_timer

	/// Current notice archive.
	var/list/sector_notices = list()

	/// Installations tracked by this network.
	var/list/sector_installations = list()

	/// Prevent immediately repeating the same random notice.
	var/last_sector_notice_id

	/// Prevent repeatedly selecting the same installation.
	var/last_updated_installation_code

	/// Sequential notice reference number.
	var/next_sector_notice_number = 1

	/// Maximum amount of sector notices retained.
	var/max_sector_notices = 20

	/// Sector Communications Terminals connected to this network.
	var/list/registered_comms_terminals = list()

	/// Timer controlling installation-originated messages.
	var/sector_message_timer

	/// Current and archived installation communications.
	var/list/sector_messages = list()

	/// Sequential identifier for sector communications.
	var/next_sector_message_number = 1

	/// Maximum communications retained.
	var/max_sector_messages = 100

	/// Maximum compact administrative-history entries retained per installation.
	var/max_installation_history_entries = 12

	/// Tracks whether at least one Medical Supply Recall is currently active so
	/// M-12 receives one clean history entry when the final active recall clears.
	var/medical_supply_recall_was_active = FALSE

	/// Prevents the exact same transmission template repeating immediately.
	var/last_sector_message_template_id

	/// Short rolling history used to keep ordinary installation traffic varied.
	var/list/recent_sector_message_template_ids = list()

	/// Number of recently issued ordinary templates avoided when alternatives exist.
	var/max_recent_sector_message_templates = 8


	/// Timer controlling installation-originated administrative paperwork.
	var/sector_paperwork_timer

	/// Only one sector paperwork request may exist at a time because the Sector
	/// Communications Terminal has one physical document slot.
	var/datum/ccpost_sector_paperwork_request/active_sector_paperwork

	/// Sequential identifier used for physical sector paperwork.
	var/next_sector_paperwork_number = 1

	/// Prevents the exact same administrative form repeating back-to-back.
	var/last_sector_paperwork_template_id

	// Ordinary Sector Notice Templates

	var/static/list/sector_notice_templates = list(
		list(
			"id" = "relay_maintenance",
			"category" = "Communications",
			"source" = "Central Communications Directorate",
			"priority" = "Advisory",
			"title" = "Scheduled Sector Relay Maintenance",
			"body" = "Routine calibration of long-range communications relays is scheduled within the sector. Brief transmission delays or duplicate routing acknowledgements may occur. No action is required unless communications are lost for an extended period."
		),
		list(
			"id" = "credential_audit",
			"category" = "Compliance",
			"source" = "Internal Compliance Division",
			"priority" = "Routine",
			"title" = "Quarterly Credential Review",
			"body" = "Sector installations are reminded to review locally issued access credentials and report unexplained discrepancies through the appropriate administrative channels. Do not submit duplicate reports for previously documented irregularities."
		),
		list(
			"id" = "freight_routing",
			"category" = "Logistics",
			"source" = "Sector Logistics Coordination",
			"priority" = "Advisory",
			"title" = "Temporary Freight Routing Revision",
			"body" = "Commercial and Nanotrasen freight traffic is being rerouted around a congested transit corridor. Minor delivery delays are expected. Priority medical and emergency shipments remain unaffected.",
			"logistics_effect_duration" = 12 MINUTES,
			"logistics_transit_multiplier" = 1.4,
			"logistics_effect_summary" = "Sector freight traffic is being rerouted around a congested transit corridor."
		),
		list(
			"id" = "document_retention",
			"category" = "Administration",
			"source" = "Central Records Administration",
			"priority" = "Routine",
			"title" = "Document Retention Reminder",
			"body" = "Operational reports, incident summaries, disciplinary records, and formal correspondence are to be retained according to current Nanotrasen document retention policy. Unofficial notes written on food packaging do not qualify as archival copies."
		),
		list(
			"id" = "priority_channels",
			"category" = "Communications",
			"source" = "Central Communications Directorate",
			"priority" = "Routine",
			"title" = "Priority Channel Usage",
			"body" = "Personnel are reminded that priority communications channels are reserved for operationally relevant traffic. Personal disputes, recreational broadcasts, and requests regarding payroll processing should be directed elsewhere."
		),
		list(
			"id" = "debris_advisory",
			"category" = "Navigation",
			"source" = "Sector Traffic Control",
			"priority" = "Advisory",
			"title" = "Orbital Debris Advisory",
			"body" = "Automated tracking systems have identified an increased concentration of non-hazardous debris within the sector. Navigational systems have been updated accordingly. Fixed installations are not presently considered at risk."
		),
		list(
			"id" = "staffing_review",
			"category" = "Personnel",
			"source" = "Central Personnel Administration",
			"priority" = "Routine",
			"title" = "Remote Installation Staffing Review",
			"body" = "Central Command is conducting a routine review of staffing allocations across remote installations. Requests for additional personnel should include an operational justification, current staffing figures, and an explanation of why existing personnel cannot simply work harder."
		),
		list(
			"id" = "budget_controls",
			"category" = "Finance",
			"source" = "Central Budgetary Oversight",
			"priority" = "Routine",
			"title" = "Discretionary Expenditure Controls",
			"body" = "Sector installations are reminded that discretionary purchases remain subject to departmental budget controls. Describing an expenditure as 'mission critical' does not automatically make it mission critical."
		),
		list(
			"id" = "medical_batch_recall",
			"category" = "Medical",
			"source" = "Central Medical Logistics",
			"priority" = "Important",
			"title" = "Medical Supply Batch Recall",
			"body" = "Central Medical Logistics has issued a precautionary recall covering selected field-medical supply batches distributed throughout the sector. Remote installations are instructed to quarantine affected stock and suspend routine medical resupply requests until the review window closes. Emergency care should continue from verified local inventory.",
			"logistics_effect_duration" = 10 MINUTES,
			"blocks_medical_supplies" = TRUE,
			"logistics_effect_summary" = "A Central Medical Logistics batch recall is temporarily suspending routine medical resupply requisitions."
		),
		list(
			"id" = "software_revision",
			"category" = "Systems",
			"source" = "Nanotrasen Systems Administration",
			"priority" = "Routine",
			"title" = "Administrative Software Revision",
			"body" = "A revised administrative software package is being distributed across sector infrastructure. Installations operating legacy systems may continue doing so until a scheduled maintenance period becomes available."
		),
		list(
			"id" = "incident_numbering",
			"category" = "Administration",
			"source" = "Central Records Administration",
			"priority" = "Routine",
			"title" = "Incident Reference Number Standardization",
			"body" = "All newly submitted sector incident reports should include a valid local reference number. Reports titled 'the thing from earlier' or 'you know what happened' may experience processing delays."
		),
		list(
			"id" = "emergency_readiness",
			"category" = "Operations",
			"source" = "Central Emergency Management",
			"priority" = "Advisory",
			"title" = "Emergency Readiness Review",
			"body" = "Remote installations are encouraged to confirm the availability of emergency communications, evacuation equipment, and current response documentation. This notice does not indicate the existence of a specific threat."
		),
		list(
			"id" = "network_latency",
			"category" = "Systems",
			"source" = "Sector Network Operations",
			"priority" = "Advisory",
			"title" = "Sector Network Latency",
			"body" = "Intermittent latency has been observed on several administrative network routes. Automated systems may take longer than usual to acknowledge submitted requests. Repeatedly submitting the same request will not improve processing speed.",
			"logistics_effect_duration" = 10 MINUTES,
			"logistics_authorization_delay" = 10 SECONDS,
			"logistics_effect_summary" = "Administrative network latency is delaying requisition authorization."
		),
		list(
			"id" = "form_revision",
			"category" = "Compliance",
			"source" = "Central Administrative Standards Office",
			"priority" = "Routine",
			"title" = "Administrative Form Revision",
			"body" = "Form CC-17B has been superseded by Form CC-17C. Existing copies of Form CC-17B may continue to be used until depleted, provided all references to Form CC-17B are amended to indicate that the form remains temporarily acceptable."
		),
		list(
			"id" = "patrol_adjustment",
			"category" = "Security",
			"source" = "Sector Security Coordination",
			"priority" = "Advisory",
			"title" = "Sector Patrol Scheduling Adjustment",
			"body" = "Routine Nanotrasen security patrol schedules have been adjusted in response to changing traffic patterns. This notice does not constitute a request for local security mobilization or increased alert status."
		),
		list(
			"id" = "freight_priority_window",
			"category" = "Logistics",
			"source" = "Sector Logistics Coordination",
			"priority" = "Advisory",
			"title" = "Temporary Freight Capacity Surplus",
			"body" = "Sector Logistics is reporting temporary surplus freight capacity. Eligible Nanotrasen installations may experience reduced delivery times while additional routing capacity remains available.",
			"logistics_effect_duration" = 10 MINUTES,
			"logistics_transit_multiplier" = 0.75,
			"logistics_effect_summary" = "Temporary surplus freight capacity is reducing transit times."
		),
		list(
			"id" = "personnel_records",
			"category" = "Personnel",
			"source" = "Central Personnel Administration",
			"priority" = "Routine",
			"title" = "Personnel Record Accuracy",
			"body" = "Supervisory personnel are reminded that staffing records should accurately reflect current assignments. Personnel who have been missing for several consecutive shifts should not continue to be recorded as 'temporarily unavailable' indefinitely."
		),
		list(
			"id" = "wizard_federation_activity",
			"category" = "Security",
			"source" = "Central Security Intelligence",
			"priority" = "Important",
			"title" = "Wizard Federation Activity Advisory",
			"body" = "Central Security Intelligence has received credible reports of Wizard Federation activity within neighboring transit routes. No hostile wizard presence has been confirmed at local Nanotrasen installations. Personnel are instructed to report unexplained teleportation, spontaneous transmutation, hostile spell effects, or individuals loudly declaring allegiance to the Federation."
		),
		list(
			"id" = "thaumaturgic_signal_interference",
			"category" = "Communications",
			"source" = "Central Communications Directorate",
			"priority" = "Advisory",
			"title" = "Unexplained Thaumaturgic Signal Interference",
			"body" = "Several sector relays have logged short-duration transmission distortions inconsistent with conventional electromagnetic interference. Central Communications is coordinating with Security Intelligence regarding possible Wizard Federation involvement. Do not attempt to reproduce anomalous signal patterns on operational equipment."
		),
		list(
			"id" = "arcane_contraband_reminder",
			"category" = "Compliance",
			"source" = "Internal Compliance Division",
			"priority" = "Routine",
			"title" = "Arcane Contraband Handling Reminder",
			"body" = "Personnel are reminded that unregistered enchanted artifacts, spellbooks, magical staves, and equipment associated with the Wizard Federation are not approved workplace materials. Recovered items are to be secured and reported through Security channels. Under no circumstances should personnel activate an unfamiliar artifact to determine what it does."
		),
		list(
			"id" = "arcane_displacement_advisory",
			"category" = "Navigation",
			"source" = "Sector Traffic Control",
			"priority" = "Advisory",
			"title" = "Localized Spatial Displacement Advisory",
			"body" = "Sector Traffic Control has received several reports of brief spatial displacement events affecting unmanned cargo and navigation beacons. Wizard Federation activity has not been ruled out. Installations should immediately report personnel, freight, or equipment appearing in locations they did not previously occupy."
		),
		list(
			"id" = "summoned_entity_guidance",
			"category" = "Emergency Operations",
			"source" = "Central Emergency Management",
			"priority" = "Advisory",
			"title" = "Summoned Entity Response Guidance",
			"body" = "In light of recent Wizard Federation activity, remote installations are reminded that unidentified creatures or objects appearing without a conventional arrival record are to be treated as potential hostile anomalies. Isolate the area where practical, avoid unnecessary physical contact, and request Security assessment before attempting containment or disposal."
		)
	)

	// Sector Installations

	var/static/list/sector_installation_templates = list(
		list(
			"code" = "NT-REL-A17",
			"name" = "Relay Station A-17",
			"function" = "Long-range communications relay",
			"initial_status" = "ONLINE",
			"contacts" = list(
				list(
					"name" = "Addust Johnson",
					"role" = "Communications Supervisor"
				),
				list(
					"name" = "Marcus Vale",
					"role" = "Senior Relay Technician"
				),
				list(
					"name" = "Talia Mercer",
					"role" = "Relay Operations Officer"
				),
				list(
					"name" = "DAV-714",
					"role" = "Relay Diagnostics Unit"
				)
			)
		),

		list(
			"code" = "NT-OUT-K04",
			"name" = "Outpost Kappa-4",
			"function" = "Administrative monitoring outpost",
			"initial_status" = "ROUTINE OPERATIONS",
			"contacts" = list(
				list(
					"name" = "Sasha Straljevic",
					"role" = "Outpost Administrator"
				),
				list(
					"name" = "Sian West",
					"role" = "Operations Coordinator"
				),
				list(
					"name" = "Amelia Trent",
					"role" = "Duty Officer"
				)
			)
		),

		list(
			"code" = "NT-MIN-RC12",
			"name" = "Mining Platform RC-12",
			"function" = "Mineral extraction and processing platform",
			"initial_status" = "ROUTINE OPERATIONS",
			"contacts" = list(
				list(
					"name" = "Imani Cross",
					"role" = "Platform Superintendent"
				),
				list(
					"name" = "Garrick Holt",
					"role" = "Senior Mining Foreman"
				),
				list(
					"name" = "Rhea Navarro",
					"role" = "Platform Operations Chief"
				)
			)
		),

		list(
			"code" = "NT-LP-D03",
			"name" = "Listening Post Delta-3",
			"function" = "Deep-space communications monitoring",
			"initial_status" = "ONLINE",
			"contacts" = list(
				list(
					"name" = "Sera Vale",
					"role" = "Watch Officer"
				),
				list(
					"name" = "Tomas Vek",
					"role" = "Senior Signal Analyst"
				),
				list(
					"name" = "Mira Kessler",
					"role" = "Monitoring Supervisor"
				)
			)
		),

		list(
			"code" = "NT-ADM-06",
			"name" = "Administrative Annex 6",
			"function" = "Regional records and compliance office",
			"initial_status" = "UNDER REVIEW",
			"contacts" = list(
				list(
					"name" = "Rinne Kudo",
					"role" = "Senior Records Officer"
				),
				list(
					"name" = "Adrian Vos",
					"role" = "Compliance Coordinator"
				),
				list(
					"name" = "Marianne Cole",
					"role" = "Administrative Supervisor"
				)
			)
		),

		list(
			"code" = "NT-LOG-H09",
			"name" = "Logistics Station H-9",
			"function" = "Freight routing and supply coordination",
			"initial_status" = "ROUTINE OPERATIONS",
			"contacts" = list(
				list(
					"name" = "Mara Venn",
					"role" = "Senior Freight Controller"
				),
				list(
					"name" = "Darius Cole",
					"role" = "Routing Supervisor"
				),
				list(
					"name" = "Erin Calder",
					"role" = "Logistics Operations Officer"
				),
				list(
					"name" = "Randolph P. Checkers Esq.",
					"role" = "Quartermaster"
				)
			)
		),

		list(
			"code" = "NT-MED-M12",
			"name" = "Medical Distribution Center M-12",
			"function" = "Regional medical supply and pharmaceutical distribution",
			"initial_status" = "ROUTINE OPERATIONS",
			"contacts" = list(
				list(
					"name" = "Frank DuFresne",
					"role" = "Medical Logistics Supervisor"
				),
				list(
					"name" = "Dr. Livia Serrano",
					"role" = "Pharmaceutical Compliance Officer"
				),
				list(
					"name" = "Owen Kess",
					"role" = "Cold-Chain Operations Coordinator"
				)
			)
		)
	)


	// Installation-originated administrative paperwork.
	//
	// Paperwork is intentionally low-stakes, physical office work. It is only
	// issued by installations which are ONLINE, conducting ROUTINE OPERATIONS,
	// or undergoing MAINTENANCE. CRITICAL, degraded, disconnected, offline,
	// destroyed, or UNDER REVIEW installations do not generate paperwork.

	var/static/list/sector_paperwork_templates = list(
		// Relay Station A-17
		list(
			"id" = "a17_relay_maintenance_certification",
			"installation_code" = "NT-REL-A17",
			"title" = "Relay Maintenance Certification Review",
			"body" = "A-17 has completed a scheduled certification pass on one of the long-range relay segments. Local Engineering has signed off on the hardware inspection, but regional procedure requires Central Liaison acknowledgment before the certification can be closed and returned to the maintenance archive."
		),
		list(
			"id" = "a17_routing_exception",
			"installation_code" = "NT-REL-A17",
			"title" = "Communications Routing Exception",
			"body" = "A burst of civilian and corporate traffic was temporarily routed through a secondary trunk during scheduled synchronization work. No messages are reported lost. A-17 requests Liaison review of the routing exception before the record is closed."
		),
		list(
			"id" = "a17_signal_retention",
			"installation_code" = "NT-REL-A17",
			"title" = "Signal Retention Authorization",
			"body" = "A-17 has retained a routine diagnostic signal capture beyond the normal automated purge window because the recording may be useful for future alignment work. Central Liaison authorization is requested to retain the file in the regional technical archive."
		),

		// Outpost Kappa-4
		list(
			"id" = "kappa4_monitoring_coverage",
			"installation_code" = "NT-OUT-K04",
			"title" = "Monitoring Coverage Review",
			"body" = "Kappa-4 has adjusted several observation packages to remove overlapping coverage and improve monitoring of a previously low-priority approach corridor. The revised coverage map requires Central Liaison acknowledgment before the local watch schedule is finalized."
		),
		list(
			"id" = "kappa4_equipment_custody",
			"installation_code" = "NT-OUT-K04",
			"title" = "Monitoring Equipment Custody Record",
			"body" = "A portable monitoring package has been transferred between secured equipment lockers following a local inventory reconciliation. No equipment is missing. Kappa-4 requests Liaison authorization to close the custody-transfer record."
		),
		list(
			"id" = "kappa4_watch_variance",
			"installation_code" = "NT-OUT-K04",
			"title" = "Observation Schedule Variance",
			"body" = "Kappa-4 temporarily consolidated two low-traffic observation periods after a routine staffing adjustment. Required monitoring coverage was maintained. Central Liaison acknowledgment is requested before the variance is entered into the permanent watch record."
		),

		// Mining Platform RC-12
		list(
			"id" = "rc12_production_variance",
			"installation_code" = "NT-MIN-RC12",
			"title" = "Production Variance Certification",
			"body" = "RC-12 reports a minor production variance after one processing line operated below projected throughput for part of the shift. Recovered output remains within contract tolerance. Liaison review is requested before the variance is certified and closed."
		),
		list(
			"id" = "rc12_safety_acknowledgement",
			"installation_code" = "NT-MIN-RC12",
			"title" = "Industrial Safety Acknowledgment",
			"body" = "A scheduled safety inspection identified a restricted-access industrial area requiring updated hazard markings and revised maintenance signage. Corrective work has been completed. Central Liaison acknowledgment is requested for the compliance record."
		),
		list(
			"id" = "rc12_shipment_discrepancy",
			"installation_code" = "NT-MIN-RC12",
			"title" = "Mineral Shipment Discrepancy Review",
			"body" = "A routine shipment reconciliation found a small difference between automated ore-weight records and the final freight manifest. Local staff attribute the variance to processing residue and container calibration. Liaison review is requested before the manifest is finalized."
		),

		// Listening Post Delta-3
		list(
			"id" = "delta3_intercept_retention",
			"installation_code" = "NT-LP-D03",
			"title" = "Classified Intercept Retention",
			"body" = "Delta-3 has flagged an otherwise low-priority encrypted intercept for extended retention because its transmission pattern may assist future signal comparison. No immediate threat is indicated. Central Liaison authorization is requested to retain the recording."
		),
		list(
			"id" = "delta3_sensor_anomaly",
			"installation_code" = "NT-LP-D03",
			"title" = "Sensor Anomaly Disposition",
			"body" = "A short-lived sensor contact could not be reproduced during follow-up sweeps and is presently assessed as instrumentation noise. Delta-3 requests Liaison review before the event is reclassified and removed from active monitoring."
		),
		list(
			"id" = "delta3_log_release",
			"installation_code" = "NT-LP-D03",
			"title" = "Monitoring Log Release Authorization",
			"body" = "A completed monitoring log has reached the end of its restricted local review period. Delta-3 requests Central Liaison authorization to release the record into the standard classified archive and close the local handling entry."
		),

		// Administrative Annex 6
		list(
			"id" = "annex6_personnel_discrepancy",
			"installation_code" = "NT-ADM-06",
			"title" = "Regional Personnel Record Discrepancy Review",
			"body" = "A discrepancy has been identified between archived personnel-transfer records and current regional assignment records. The affected entries have been isolated from automated processing. Central Liaison review is requested before the records are returned to active circulation."
		),
		list(
			"id" = "annex6_archive_release",
			"installation_code" = "NT-ADM-06",
			"title" = "Archive Release Authorization",
			"body" = "A closed regional operations file has completed its required retention hold and is eligible for transfer into the general corporate archive. Annex 6 requests Liaison authorization before the file is released from restricted archival status."
		),
		list(
			"id" = "annex6_compliance_closure",
			"installation_code" = "NT-ADM-06",
			"title" = "Compliance File Closure",
			"body" = "A routine regional compliance review has been completed with no outstanding corrective actions. Annex 6 requests Central Liaison acknowledgment before the review file is formally closed and removed from the active docket."
		),

		// Logistics Station H-9
		list(
			"id" = "h09_freight_exception",
			"installation_code" = "NT-LOG-H09",
			"title" = "Freight Routing Exception Authorization",
			"body" = "Three freight consignments were manually rerouted around a temporary automated scheduling conflict. All consignments reached their intended destinations. H-9 requests Liaison acknowledgment before the routing exception is closed."
		),
		list(
			"id" = "h09_cargo_loss_declaration",
			"installation_code" = "NT-LOG-H09",
			"title" = "Minor Cargo Loss Declaration",
			"body" = "A freight container arrived with a small quantity of low-value packing material missing from the recorded load. No controlled or operationally significant cargo is affected. Central Liaison review is requested before the loss declaration is finalized."
		),
		list(
			"id" = "h09_dispatch_reconciliation",
			"installation_code" = "NT-LOG-H09",
			"title" = "Dispatch Reconciliation Record",
			"body" = "H-9 has reconciled a set of manual dispatch entries created during routine controller maintenance. All referenced freight has been accounted for. Liaison authorization is requested to merge the manual record into the automated routing archive."
		),

		// Medical Distribution Center M-12
		list(
			"id" = "med12_quarantine_release",
			"installation_code" = "NT-MED-M12",
			"title" = "Medical Stock Quarantine Release",
			"body" = "A routine quality-control hold on a medical supply batch has concluded with no contamination or storage defects identified. M-12 requests Central Liaison authorization before the batch is released back into regional distribution inventory."
		),
		list(
			"id" = "med12_coldchain_variance",
			"installation_code" = "NT-MED-M12",
			"title" = "Cold-Chain Variance Review",
			"body" = "One monitored shipment briefly approached the upper limit of its approved storage range during transfer. Local validation indicates the stock remains usable. Liaison review is requested before the variance is closed and the shipment cleared."
		),
		list(
			"id" = "med12_inventory_certification",
			"installation_code" = "NT-MED-M12",
			"title" = "Regional Medical Inventory Certification",
			"body" = "M-12 has completed a routine reconciliation of controlled regional medical stock. Physical counts and distribution records are within acceptable tolerance. Central Liaison acknowledgment is requested before the certification is entered into the permanent inventory record."
		)
	)

	// Installation-originated communications.
	//
	// Ordinary messages are handled by the recurring Sector Communications
	// timer. Templates marked reactive_aid are instead considered when an
	// installation actually drops below green operational status.

	var/static/list/sector_message_templates = list(
		// --------------------------------------------------------
		// RELAY STATION A-17 - ROUTINE / GREEN TRAFFIC
		// --------------------------------------------------------

		list(
			"id" = "relay_nominal_update",
			"installation_code" = "NT-REL-A17",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Relay Operations Update",
			"body" = "Primary and secondary relay channels are holding synchronization. We completed the scheduled alignment pass without finding anything that requires intervention. Traffic remains steady and, for once, uneventful.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS")
		),
		list(
			"id" = "a17_bandwidth_credit",
			"installation_code" = "NT-REL-A17",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Unused Relay Capacity Reconciliation",
			"body" = "Commercial routing demand came in below forecast this cycle. The unused relay reservation has been released and Sector Communications has approved a small transfer back to Liaison-controlled operational funds.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_reward" = 2
		),
		list(
			"id" = "a17_preventative_parts",
			"installation_code" = "NT-REL-A17",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Preventative Transmitter Service",
			"body" = "Diagnostics are still green, but two transmitter couplings are approaching their recommended service limit. I'd rather replace them during a quiet window than explain why we waited until one failed. Requesting a small preventative maintenance allocation.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 2,
			"success_details" = "Preventative transmitter servicing has been completed ahead of the next maintenance threshold."
		),
		list(
			"id" = "a17_capacitor_reserve",
			"installation_code" = "NT-REL-A17",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Emergency Capacitor Reserve",
			"body" = "Our spare pulse-capacitor stock is below the recommended reserve after last cycle's replacements. Nothing is failing right now. I am requesting authorization to replenish the reserve before that sentence becomes less reassuring.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 3,
			"success_details" = "Emergency capacitor reserves have been replenished to recommended levels."
		),

		// --------------------------------------------------------
		// OUTPOST KAPPA-4 - ROUTINE / GREEN TRAFFIC
		// --------------------------------------------------------

		list(
			"id" = "kappa4_quiet_shift",
			"installation_code" = "NT-OUT-K04",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Monitoring Shift Summary",
			"body" = "The current watch has been quiet. No abnormal traffic, no unscheduled dockings, and no equipment alarms worth elevating. The night crew has asked me to formally note that this is not a complaint.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS")
		),
		list(
			"id" = "kappa4_budget_return",
			"installation_code" = "NT-OUT-K04",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Monitoring Budget Adjustment",
			"body" = "A scheduled sensor package replacement was completed below projected cost. The unused portion has been cleared for return to sector operational allocation rather than being consumed by the end-of-cycle spending requirement.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_reward" = 1
		),
		list(
			"id" = "kappa4_sensor_refresh",
			"installation_code" = "NT-OUT-K04",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Remote Sensor Refresh",
			"body" = "Three external observation packages are still functional but have exceeded their preferred deployment hours. Replacing them now would avoid losing coverage one sensor at a time over the next few shifts. Requesting authorization for a refresh package.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 3,
			"success_details" = "A replacement set of remote monitoring packages has been deployed."
		),
		list(
			"id" = "kappa4_backup_batteries",
			"installation_code" = "NT-OUT-K04",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Backup Power Reserve",
			"body" = "Our emergency battery rack passed inspection, but reserve capacity is lower than I'd like after repeated charge cycling. The outpost can continue normally without replacement. I'd prefer not to discover how long 'normally' lasts during an actual outage.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 2,
			"success_details" = "Backup power reserves have been restored to full rated capacity."
		),

		// --------------------------------------------------------
		// MINING PLATFORM RC-12 - ROUTINE / GREEN TRAFFIC
		// --------------------------------------------------------

		list(
			"id" = "rc12_production_update",
			"installation_code" = "NT-MIN-RC12",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Production Shift Report",
			"body" = "Processing throughput is on target and the extraction crews are ahead of quota. The only unplanned downtime this shift involved a jammed ore gate and one supervisor insisting that kicking it counted as a repair procedure.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS")
		),
		list(
			"id" = "rc12_export_credit",
			"installation_code" = "NT-MIN-RC12",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Production Surplus Reconciliation",
			"body" = "Processed-material output exceeded the contracted requirement this cycle. A portion of the resulting operational surplus has been approved for redistribution to sector administrative support.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_reward" = 2
		),
		list(
			"id" = "rc12_drill_spares",
			"installation_code" = "NT-MIN-RC12",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Extraction Head Spare Stock",
			"body" = "We've used the last two spare extraction heads from local stores. The active units are fine, but the next hard failure will stop a line until replacement freight arrives. Requesting funding to restore minimum spare stock.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 4,
			"success_details" = "Critical extraction-head spares have been restored to platform inventory."
		),
		list(
			"id" = "rc12_dust_filters",
			"installation_code" = "NT-MIN-RC12",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Industrial Filtration Resupply",
			"body" = "Ore dust loading is higher than forecast and we're consuming filtration cartridges faster than planned. There is no immediate atmospheric concern. I'd like to keep it that way. Requesting a replacement filter shipment.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 3,
			"success_details" = "Industrial filtration reserves have been replenished."
		),

		// --------------------------------------------------------
		// LISTENING POST DELTA-3 - ROUTINE / GREEN TRAFFIC
		// --------------------------------------------------------

		list(
			"id" = "delta3_watch_update",
			"installation_code" = "NT-LP-D03",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Deep-Space Watch Update",
			"body" = "The current watch remains uneventful. No significant unidentified transmissions or anomalous traffic have been detected. We did isolate a repeating carrier burst, but it turned out to be a commercial beacon with a damaged timing circuit.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS")
		),
		list(
			"id" = "delta3_analysis_credit",
			"installation_code" = "NT-LP-D03",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Signal Analysis Resource Release",
			"body" = "A scheduled high-load analysis block was cancelled after the target signal was identified by another sector asset. The reserved processing allocation has been released for reassignment.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_reward" = 1
		),
		list(
			"id" = "delta3_receiver_service",
			"installation_code" = "NT-LP-D03",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Receiver Cooling Service",
			"body" = "Receiver bank two is within tolerance, but coolant efficiency has been trending down for three shifts. We can keep watching the sector as-is. I'm requesting service parts now so we don't have to choose between thermal limits and signal coverage later.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 2,
			"success_details" = "Receiver-bank cooling efficiency has been restored to nominal levels."
		),
		list(
			"id" = "delta3_storage_array",
			"installation_code" = "NT-LP-D03",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Telemetry Archive Expansion",
			"body" = "We're retaining more raw traffic captures than projected after the recent sector anomalies. I can start purging older low-priority recordings, or you can authorize another archive module and let us keep the full comparison set.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 3,
			"success_details" = "Additional telemetry archive capacity has been installed."
		),

		// --------------------------------------------------------
		// ADMINISTRATIVE ANNEX 6 - ROUTINE / GREEN TRAFFIC
		// --------------------------------------------------------

		list(
			"id" = "annex6_records_update",
			"installation_code" = "NT-ADM-06",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Records Processing Update",
			"body" = "The current filing backlog is within acceptable limits and all priority submissions have been indexed. Sixteen duplicate requisition forms were also identified and returned to their originating offices with professionally restrained annotations.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS")
		),
		list(
			"id" = "annex6_efficiency_credit",
			"installation_code" = "NT-ADM-06",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Administrative Cost Reconciliation",
			"body" = "A records-storage contract was consolidated ahead of renewal and the resulting savings have been approved for partial return to sector operational allocation. Please do not interpret this as precedent for future procurement requests.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_reward" = 1
		),
		list(
			"id" = "annex6_archive_media",
			"installation_code" = "NT-ADM-06",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Archival Media Replenishment",
			"body" = "Long-term archival media is below our preferred reserve after an unusually document-heavy cycle. We can continue by rotating older media early, but that creates exactly the kind of audit trail I would rather not explain later. Requesting replenishment.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 2,
			"success_details" = "Long-term archival media reserves have been restored."
		),
		list(
			"id" = "annex6_scanner_service",
			"installation_code" = "NT-ADM-06",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Bulk Scanner Service Contract",
			"body" = "Two high-volume document scanners are beginning to misfeed under sustained load. They are technically still operational, which is accounting language for 'someone else will suffer later.' Requesting approval for preventative servicing.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 2,
			"success_details" = "High-volume records scanners have completed preventative servicing."
		),

		// --------------------------------------------------------
		// LOGISTICS STATION H-9 - ROUTINE / GREEN TRAFFIC
		// --------------------------------------------------------

		list(
			"id" = "h09_lane_update",
			"installation_code" = "NT-LOG-H09",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Freight Lane Status",
			"body" = "All assigned freight lanes are processing within forecast tolerances. We cleared the morning queue early and have enough spare routing capacity to absorb normal fluctuations without touching contingency lanes.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS")
		),
		list(
			"id" = "h09_capacity_credit",
			"installation_code" = "NT-LOG-H09",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Freight Capacity Reconciliation",
			"body" = "Our latest routing reconciliation identified unused operational capacity allocated to this installation. Sector Logistics approved transfer of the surplus back to Liaison-controlled operational funds.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_reward" = 3
		),
		list(
			"id" = "h09_preventative_actuators",
			"installation_code" = "NT-LOG-H09",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Dock Actuator Preventative Service",
			"body" = "Two freight-dock actuators are starting to lag under load. They still pass inspection, but not by enough that I want to bet next week's traffic on them. Requesting replacement assemblies while we can schedule the work instead of reacting to it.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 3,
			"success_details" = "Freight-dock actuators have completed preventative replacement."
		),
		list(
			"id" = "h09_tracking_beacons",
			"installation_code" = "NT-LOG-H09",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Freight Beacon Replacement",
			"body" = "Our reserve pallet of short-range cargo beacons is nearly empty after a bad batch was pulled from service. We can operate without a refill, but manual tagging will slow every exception case. Requesting authorization for replacement stock.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 2,
			"success_details" = "Freight tracking beacon reserves have been replenished."
		),

		// --------------------------------------------------------
		// MEDICAL DISTRIBUTION CENTER M-12 - ROUTINE / GREEN TRAFFIC
		// --------------------------------------------------------

		list(
			"id" = "med12_inventory_update",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Regional Medical Inventory Update",
			"body" = "Regional medical inventory is within target range. Cold storage is stable, controlled stock reconciled cleanly, and the outgoing queue is moving without exceptions. I am documenting that now before something decides to become interesting.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS")
		),
		list(
			"id" = "med12_surplus_credit",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Medical Logistics Surplus Release",
			"body" = "A planned emergency restock was cancelled after local demand came in below forecast. Central Medical Logistics has approved release of the unused operational allocation back into the sector pool.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_reward" = 2
		),
		list(
			"id" = "med12_cold_chain_service",
			"installation_code" = "NT-MED-M12",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Cold-Chain Preventative Service",
			"body" = "Two pharmaceutical cold-storage compressors are still within tolerance, but their duty cycle is climbing faster than expected. I would rather service them while the medicine is cold and the technicians are calm. Requesting preventative maintenance allocation.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 3,
			"success_details" = "Preventative service has restored the pharmaceutical cold-chain system to preferred operating margins."
		),
		list(
			"id" = "med12_sterile_packaging",
			"installation_code" = "NT-MED-M12",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Sterile Packaging Reserve",
			"body" = "Our sterile packaging reserve has fallen below the regional target after a larger-than-expected emergency shipment. Current orders are unaffected. Requesting a small replenishment before the next priority dispatch turns that into a problem.",
			"required_statuses" = list("ONLINE", "ROUTINE OPERATIONS"),
			"allocation_cost" = 2,
			"success_details" = "Sterile packaging reserves have been replenished to regional target levels."
		),

		// --------------------------------------------------------
		// OPERATIONAL STATUS UPDATES
		// These add more non-financial traffic while installations are below green.
		// Several are inspired by antagonist roles that exist in SS13/MonkeStation.
		// They describe incidents at fictional remote installations and do not inspect
		// or reveal antagonist roles from the live station round.
		// --------------------------------------------------------

		list(
			"id" = "a17_encrypted_uplink_anomaly",
			"installation_code" = "NT-REL-A17",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Encrypted Uplink Interference",
			"body" = "We are tracing short encrypted bursts riding the edge of our commercial bands. The traffic pattern resembles known Syndicate uplink activity, but I do not have enough to call it a confirmed traitor channel. We have isolated the affected repeater and are watching for another handshake.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "a17_alignment_fault",
			"installation_code" = "NT-REL-A17",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Relay Alignment Drift",
			"body" = "Array three has drifted out of preferred alignment twice this watch. Local technicians are compensating manually while diagnostics work through the actuator chain. Traffic is still moving, just with less redundancy than I would like.",
			"required_statuses" = list("MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "kappa4_identity_discrepancy",
			"installation_code" = "NT-OUT-K04",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Personnel Identity Discrepancy",
			"body" = "We have two contradictory biometric records for the same member of staff and neither one is obviously corrupted. Until Security finishes the comparison, I have ordered controlled access and paired movement. Yes, someone already said 'changeling.' No, that does not make it confirmed.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "kappa4_sensor_blindspot",
			"installation_code" = "NT-OUT-K04",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "External Sensor Blind Spot",
			"body" = "A cluster of remote observation packages has dropped from the network. We still have overlapping coverage, but one approach corridor is being watched by fewer eyes than policy prefers. Local repair drones are en route.",
			"required_statuses" = list("MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "rc12_cult_markings",
			"installation_code" = "NT-MIN-RC12",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Unauthorized Ritual Activity",
			"body" = "Maintenance found fresh geometric markings, blood residue, and an improvised ritual site inside a disused extraction gallery. Security is treating it as possible cultist or heretic activity until proven otherwise. The gallery is sealed and nobody is volunteering to clean it.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE")
		),
		list(
			"id" = "rc12_labor_unrest",
			"installation_code" = "NT-MIN-RC12",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Organized Labor Disruption",
			"body" = "A group of workers attempted to seize a processing control room after distributing anti-corporate material across the lower decks. Security has contained the immediate disturbance. Central has asked us to treat the matter as possible revolutionary activity pending investigation.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "delta3_nukeop_chatter",
			"installation_code" = "NT-LP-D03",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Hostile Burst-Traffic Intercept",
			"body" = "We intercepted a tightly compressed burst sequence using authentication behavior associated with hostile Syndicate field teams. It could be spoofed traffic. It could also be nuclear operative chatter. We are preserving the raw capture and narrowing the bearing now.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "delta3_receiver_noise",
			"installation_code" = "NT-LP-D03",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Receiver Noise Excursion",
			"body" = "Receiver bank four is showing a persistent noise floor above calibration limits. We have moved priority watch traffic onto the cleaner arrays while engineering checks shielding and local power conditioning.",
			"required_statuses" = list("MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "annex6_revolutionary_material",
			"installation_code" = "NT-ADM-06",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Unauthorized Political Material Review",
			"body" = "Internal Compliance found coordinated anti-corporate material embedded in staff bulletins and payroll notices. The wording matches several known revolutionary recruitment patterns. Access to the publishing queue has been restricted while Personnel works out who approved any of it.",
			"required_statuses" = list("UNDER REVIEW")
		),
		list(
			"id" = "annex6_archive_mismatch",
			"installation_code" = "NT-ADM-06",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Archive Reconciliation Delay",
			"body" = "Three regional record sets disagree on personnel transfer dates and nobody has yet found the original source document. The records are not lost, but they are currently proving that having three copies does not guarantee having one correct copy.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE")
		),
		list(
			"id" = "h09_manifest_sabotage",
			"installation_code" = "NT-LOG-H09",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Freight Manifest Sabotage Review",
			"body" = "Someone altered routing tags on six outbound containers and tried to bury the changes inside an automated reconciliation batch. Security is treating it as deliberate sabotage and possible traitor activity. The affected freight is isolated while we rebuild the manifests by hand.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "h09_conveyor_fault",
			"installation_code" = "NT-LOG-H09",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Freight Conveyor Isolation",
			"body" = "One of the transfer conveyors has been isolated after repeated motor faults. We are routing around it with manual handling and the secondary lane. Throughput is down, but nothing is stranded yet.",
			"required_statuses" = list("MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "med12_recall_operations",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Medical Recall Operations",
			"body" = "We are working the active batch recall now. Affected lots are being quarantined, shipment records are being cross-checked, and verified emergency stock remains available locally. Do not restart routine medical resupply from our channel until Central Medical Logistics clears the notice.",
			"required_statuses" = list("UNDER REVIEW")
		),
		list(
			"id" = "med12_bloodsucker_investigation",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Unexplained Blood-Loss Cluster",
			"body" = "Medical has admitted three staff with unexplained blood loss and matching puncture trauma. Security has restricted access to the residential wing while we rule out equipment injury, assault, or bloodsucker activity. I would prefer the boring explanation.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE")
		),
		list(
			"id" = "med12_changeling_quarantine",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Biometric Quarantine Protocol",
			"body" = "We have conflicting tissue and identity records from a restricted treatment room. The wing is under quarantine while pathology repeats the tests. Changeling contamination is one of the scenarios on the checklist, not a confirmed diagnosis.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "med12_cold_storage_variance",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Routine",
			"title" = "Cold Storage Temperature Variance",
			"body" = "One pharmaceutical vault is fluctuating outside preferred temperature margins. Nothing has crossed discard thresholds, but the affected stock is being held while engineering checks the cooling loop and calibration sensors.",
			"required_statuses" = list("MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),

		list(
			"id" = "a17_credential_spoof",
			"installation_code" = "NT-REL-A17",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Credential-Spoofed Relay Traffic",
			"body" = "We caught a maintenance authorization using a valid employee credential several hours after that employee was confirmed off-station. Security is treating it as possible traitor access or identity theft while we revoke the affected keys and rebuild the relay permissions.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "a17_identity_voice_mismatch",
			"installation_code" = "NT-REL-A17",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Authenticated Voiceprint Mismatch",
			"body" = "A priority call arrived with valid credentials but a voiceprint that does not match the registered operator. The sender disconnected when challenged. Changeling impersonation is on the threat checklist, though a stolen credential remains the simpler explanation.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "kappa4_revolutionary_meeting",
			"installation_code" = "NT-OUT-K04",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Unauthorized Staff Assembly",
			"body" = "Security broke up an unauthorized staff meeting after anti-corporate slogans and improvised recruitment sheets were found in the room. No command personnel were harmed. We are reviewing the attendees for possible revolutionary organization rather than assuming every angry employee is part of a cell.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "kappa4_ritual_material",
			"installation_code" = "NT-OUT-K04",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Restricted Occult Materials",
			"body" = "A routine locker inspection turned up blood-marked diagrams, a ceremonial blade, and several pages of material that Security cannot identify. Possible cultist or heretic involvement has been referred upward. The owner insists it is a hobby. Nobody has found that reassuring.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE")
		),
		list(
			"id" = "rc12_bloodless_casualty",
			"installation_code" = "NT-MIN-RC12",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Unexplained Exsanguination Case",
			"body" = "A miner was recovered alive but severely blood-depleted from a locked auxiliary tunnel with no equipment failure sufficient to explain it. Medical is stabilizing them while Security checks the access logs. Bloodsucker activity is one possibility under review.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "rc12_syndicate_explosive",
			"installation_code" = "NT-MIN-RC12",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Unauthorized Demolition Charge",
			"body" = "Engineering recovered an improvised charge from a conveyor junction before it detonated. Several components resemble Syndicate procurement patterns. Security is treating this as deliberate sabotage and possible traitor activity while the processing line remains isolated.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "delta3_occult_signal",
			"installation_code" = "NT-LP-D03",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Nonstandard Ritual Broadcast",
			"body" = "One receiver bank captured a repeating transmission made up of spoken phrases, geometric image bursts, and a carrier pattern with no recognized commercial purpose. Analysts flagged similarities to archived cultist and heretic incidents. We have isolated the recording from the general network.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "delta3_syndicate_dead_drop",
			"installation_code" = "NT-LP-D03",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Suspected Syndicate Dead-Drop Traffic",
			"body" = "We identified a burst schedule consistent with one-way dead-drop traffic: very short transmissions, irregular timing, and no acknowledgement packets. It may be a traitor uplink or contractor channel. Direction finding is in progress.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "annex6_credential_forgery",
			"installation_code" = "NT-ADM-06",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Command Credential Forgery Review",
			"body" = "Records staff found a command-level approval attached to a transfer order that the listed signatory denies issuing. The signature chain is technically valid. Internal Compliance is treating the case as possible traitor credential compromise until the signing key is accounted for.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE")
		),
		list(
			"id" = "annex6_duplicate_employee",
			"installation_code" = "NT-ADM-06",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Duplicate Personnel Record Escalation",
			"body" = "Two active personnel files now contain the same biometric identifiers but different assignment histories. Neither file appears to be a simple duplicate. Compliance has locked both records while Security investigates possible changeling impersonation or deliberate database tampering.",
			"required_statuses" = list("UNDER REVIEW")
		),
		list(
			"id" = "h09_revolutionary_slowdown",
			"installation_code" = "NT-LOG-H09",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Coordinated Freight Work Stoppage",
			"body" = "Several freight teams abandoned assigned lanes simultaneously after receiving identical anti-corporate messages over local headsets. Supervisors are restoring minimum throughput while Security checks whether this is ordinary labor action or organized revolutionary activity.",
			"required_statuses" = list("UNDER REVIEW", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "h09_syndicate_cache",
			"installation_code" = "NT-LOG-H09",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Unregistered Tactical Cargo Cache",
			"body" = "A container entered our holding stack under a valid freight code but contained unregistered tactical equipment instead of the declared machine parts. The packing pattern resembles Syndicate field logistics. We are checking whether this was a traitor shipment or preparation for a larger hostile team.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),
		list(
			"id" = "med12_occult_trauma",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Important",
			"title" = "Anomalous Trauma Review",
			"body" = "Medical received two patients with matching wounds that do not correspond to any tool or industrial process logged on-site. One patient keeps describing impossible geometric structures. Security has opened a possible heretic or cultist incident review while treatment continues.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE")
		),
		list(
			"id" = "med12_syndicate_toxin",
			"installation_code" = "NT-MED-M12",
			"type" = "UPDATE",
			"priority" = "Priority",
			"title" = "Unregistered Toxin Exposure",
			"body" = "Toxicology identified an exposure pattern inconsistent with anything stocked by the facility. The compound profile overlaps with substances recovered in previous Syndicate sabotage cases. Pharmacy access is frozen while Security checks for a traitor or compromised shipment.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE", "COMMUNICATIONS DEGRADED")
		),

		// --------------------------------------------------------
		// REACTIVE AID REQUESTS
		// These are not selected by the normal communications timer.
		// They are rolled when the installation itself falls below green.
		// --------------------------------------------------------

		// Relay Station A-17
		list(
			"id" = "a17_relay_repairs",
			"installation_code" = "NT-REL-A17",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Relay Array Component Request",
			"body" = "We've lost redundancy across part of the long-range array. The remaining transmitters are carrying the traffic, but I am not comfortable leaving them there. I need replacement couplings and a clean transmitter module before one failure becomes several.",
			"required_statuses" = list("MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED"),
			"allocation_cost" = 5,
			"success_status" = "ONLINE",
			"success_details" = "Replacement transmitter components have restored full long-range relay capability.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "a17_emergency_power",
			"installation_code" = "NT-REL-A17",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Emergency Relay Power Support",
			"body" = "This message was queued on the emergency burst channel before the primary link dropped. We are running the relay core from backup distribution and I cannot guarantee another restart. If you can release emergency power-control hardware, do it now.",
			"required_statuses" = list("NO CONTACT", "OFFLINE"),
			"allocation_cost" = 7,
			"success_status" = "MAINTENANCE",
			"success_details" = "Emergency power-control hardware has restored limited relay operation while local repairs continue.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "a17_critical_stabilization",
			"installation_code" = "NT-REL-A17",
			"type" = "REQUEST",
			"priority" = "Important",
			"title" = "Immediate Relay Stabilization Request",
			"body" = "Liaison, A-17 is in emergency operation. We are isolating damaged relay sections faster than we can bring backup systems online. I need authorization for emergency components and contractor routing before we lose the remaining trunk entirely.",
			"required_statuses" = list("CRITICAL"),
			"allocation_cost" = 10,
			"success_details" = "Emergency relay resources have been committed to authenticated communications, emergency power, and isolation of damaged or compromised relay sections.",
			"reactive_aid" = TRUE
		),

		// Outpost Kappa-4
		list(
			"id" = "kappa4_monitoring_repairs",
			"installation_code" = "NT-OUT-K04",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Monitoring Equipment Replacement",
			"body" = "Our observation coverage is thinning out. Several packages are failing diagnostics and I am running the remaining units harder to compensate. We can continue like this, but every failed sensor leaves a larger blind spot. Requesting replacements.",
			"required_statuses" = list("MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED"),
			"allocation_cost" = 4,
			"success_status" = "ROUTINE OPERATIONS",
			"success_details" = "Replacement monitoring packages have restored normal observation capability.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "kappa4_life_support_backup",
			"installation_code" = "NT-OUT-K04",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Outpost Continuity Support",
			"body" = "If this gets through, our main systems are already down or close to it. The outpost is operating from local emergency power and we have started shutting nonessential monitoring racks off to preserve life support. Requesting backup distribution and environmental-control parts.",
			"required_statuses" = list("NO CONTACT", "OFFLINE"),
			"allocation_cost" = 6,
			"success_status" = "MAINTENANCE",
			"success_details" = "Emergency continuity supplies have restored basic outpost systems while repairs continue.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "kappa4_critical_continuity",
			"installation_code" = "NT-OUT-K04",
			"type" = "REQUEST",
			"priority" = "Important",
			"title" = "Critical Outpost Continuity Request",
			"body" = "We're past routine maintenance. I have staff consolidating into the protected section and stripping power from everything we can afford to lose. I need emergency continuity funding if Central still expects this outpost to remain occupied.",
			"required_statuses" = list("CRITICAL"),
			"allocation_cost" = 9,
			"success_details" = "Emergency continuity resources have been committed to protected areas, life support, emergency power, and local command continuity.",
			"reactive_aid" = TRUE
		),

		// Mining Platform RC-12
		list(
			"id" = "rc12_processing_repairs",
			"installation_code" = "NT-MIN-RC12",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Processing Equipment Assistance",
			"body" = "One primary processor is down and the secondary line is swallowing the entire shift's load. I can keep production moving, but not at this rate for long. Requesting replacement bearings, drive assemblies, and enough contractor time to fit them properly.",
			"required_statuses" = list("MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED"),
			"allocation_cost" = 7,
			"success_status" = "ROUTINE OPERATIONS",
			"success_details" = "Replacement processing assemblies have restored normal mineral-processing throughput.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "rc12_pressure_seals",
			"installation_code" = "NT-MIN-RC12",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Emergency Pressure-Seal Resupply",
			"body" = "This was sent through the platform's emergency queue. We have isolated two industrial sections after repeated seal failures and our local repair stock is almost gone. Send pressure hardware and patch material before I have to shut another processing deck.",
			"required_statuses" = list("NO CONTACT", "OFFLINE"),
			"allocation_cost" = 8,
			"success_status" = "MAINTENANCE",
			"success_details" = "Emergency seal and patch supplies have restored limited platform operation.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "rc12_critical_stabilization",
			"installation_code" = "NT-MIN-RC12",
			"type" = "REQUEST",
			"priority" = "Important",
			"title" = "Critical Platform Stabilization",
			"body" = "RC-12 is in a full operational emergency. I have crews abandoning damaged machinery and focusing on atmosphere, structural isolation, and keeping people alive. Release emergency industrial support now and we may still have a platform to repair afterward.",
			"required_statuses" = list("CRITICAL"),
			"allocation_cost" = 11,
			"success_details" = "Emergency industrial resources have been committed to life support, structural isolation, damage control, and essential platform systems.",
			"reactive_aid" = TRUE
		),

		// Listening Post Delta-3
		list(
			"id" = "delta3_signal_repair",
			"installation_code" = "NT-LP-D03",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Signal Monitoring Array Assistance",
			"body" = "Our secondary array keeps dropping synchronization. I can hold the primary watch, but every correction cycle narrows our usable coverage. Requesting a replacement processing rack before we become very good at listening to only one direction.",
			"required_statuses" = list("MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED"),
			"allocation_cost" = 4,
			"success_status" = "ONLINE",
			"success_details" = "Replacement signal-processing hardware has restored full monitoring coverage.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "delta3_backup_power",
			"installation_code" = "NT-LP-D03",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Emergency Monitoring Power Request",
			"body" = "This is a buffered transmission from Delta-3. The primary monitoring bus has failed and the post is cycling receivers to stay within emergency power limits. We need power-conditioning hardware if you want continuous sector coverage restored.",
			"required_statuses" = list("NO CONTACT", "OFFLINE"),
			"allocation_cost" = 6,
			"success_status" = "MAINTENANCE",
			"success_details" = "Emergency power-conditioning hardware has restored limited monitoring capability.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "delta3_critical_stabilization",
			"installation_code" = "NT-LP-D03",
			"type" = "REQUEST",
			"priority" = "Important",
			"title" = "Critical Listening Post Support",
			"body" = "We are losing systems faster than I can isolate them. Most of the array is dark and the remaining equipment is running from emergency feeds. I need immediate stabilization resources or Delta-3 is going to stop being a listening post and start being debris.",
			"required_statuses" = list("CRITICAL"),
			"allocation_cost" = 10,
			"success_details" = "Emergency listening-post resources have been committed to protected systems, emergency power, secure communications, and local containment efforts.",
			"reactive_aid" = TRUE
		),

		// Administrative Annex 6
		list(
			"id" = "annex6_records_repair",
			"installation_code" = "NT-ADM-06",
			"type" = "REQUEST",
			"priority" = "Routine",
			"title" = "Records Infrastructure Assistance",
			"body" = "The Annex is processing a growing backlog after another archival server failure. The records are intact, but the remaining systems are well beyond comfortable load. I need replacement storage hardware before the backlog becomes a compliance incident of its own.",
			"required_statuses" = list("UNDER REVIEW", "MAINTENANCE", "COMMUNICATIONS DEGRADED"),
			"allocation_cost" = 3,
			"success_status" = "ROUTINE OPERATIONS",
			"success_details" = "Supplemental archival hardware has restored normal regional records processing.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "annex6_cooling_support",
			"installation_code" = "NT-ADM-06",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Emergency Archive Cooling Support",
			"body" = "This message is coming through the Annex emergency transmitter. Environmental control in the primary records room is offline and we are moving active media by hand into the secondary vault. Requesting portable cooling and power-control hardware immediately.",
			"required_statuses" = list("NO CONTACT", "OFFLINE"),
			"allocation_cost" = 5,
			"success_status" = "MAINTENANCE",
			"success_details" = "Emergency environmental-control equipment has stabilized the Annex records environment.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "annex6_critical_preservation",
			"installation_code" = "NT-ADM-06",
			"type" = "REQUEST",
			"priority" = "Important",
			"title" = "Critical Records Preservation Request",
			"body" = "I am authorizing manual continuity procedures. Staff are evacuating priority archives from damaged storage areas and we are running the secondary vault independently. If Central wants the regional record set preserved, I need emergency preservation resources now.",
			"required_statuses" = list("CRITICAL"),
			"allocation_cost" = 8,
			"success_details" = "Emergency preservation resources have been committed to priority archives, personnel-control continuity, protected storage, and local containment efforts.",
			"reactive_aid" = TRUE
		),

		// Logistics Station H-9
		list(
			"id" = "h09_freight_repairs",
			"installation_code" = "NT-LOG-H09",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Freight Routing Repair Assistance",
			"body" = "A routing controller has failed and the remaining unit is carrying the full automated handoff load. We are keeping traffic moving, but I am not going to pretend this is sustainable. Requesting replacement hardware before the surviving controller joins it.",
			"required_statuses" = list("MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED"),
			"allocation_cost" = 6,
			"success_status" = "ROUTINE OPERATIONS",
			"success_details" = "Supplemental Central Command resources have restored primary freight-routing capability.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "h09_emergency_routing",
			"installation_code" = "NT-LOG-H09",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Emergency Freight Control Support",
			"body" = "If you are reading this, H-9's normal telemetry is already gone. We have dropped to local freight control and manual lane assignment. I need emergency routing hardware and power distribution before the queue becomes impossible to recover.",
			"required_statuses" = list("NO CONTACT", "OFFLINE"),
			"allocation_cost" = 8,
			"success_status" = "MAINTENANCE",
			"success_details" = "Emergency freight-control hardware has restored limited routing capability.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "h09_critical_stabilization",
			"installation_code" = "NT-LOG-H09",
			"type" = "REQUEST",
			"priority" = "Important",
			"title" = "Critical Logistics Stabilization",
			"body" = "We are in a sector logistics emergency. Automated routing is collapsing, local power is unstable, and I am assigning freight by hand where I still have a live console. Release emergency support now or H-9 is going to stop moving anything at all.",
			"required_statuses" = list("CRITICAL"),
			"allocation_cost" = 12,
			"success_details" = "Emergency logistics resources have been committed to manual routing, emergency power, secured freight, and local damage-control operations.",
			"reactive_aid" = TRUE
		),

		// Medical Distribution Center M-12
		list(
			"id" = "med12_storage_repair",
			"installation_code" = "NT-MED-M12",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Medical Storage Recovery Assistance",
			"body" = "We have isolated one distribution vault after repeated cooling and inventory-control faults. Verified stock is safe, but our redundancy is disappearing quickly. Requesting replacement refrigeration controls, validation sensors, and contractor time before another vault has to come offline.",
			"required_statuses" = list("MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED"),
			"allocation_cost" = 5,
			"success_status" = "ROUTINE OPERATIONS",
			"success_details" = "Replacement medical-storage controls have restored validated regional distribution capacity.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "med12_emergency_coldchain",
			"installation_code" = "NT-MED-M12",
			"type" = "REQUEST",
			"priority" = "Priority",
			"title" = "Emergency Cold-Chain Support",
			"body" = "This is an emergency distribution message from M-12. Primary cold storage is unavailable and staff are moving verified stock into portable units by hand. I need emergency refrigeration and power-conditioning support before we start losing supplies that cannot be replaced locally.",
			"required_statuses" = list("NO CONTACT", "OFFLINE"),
			"allocation_cost" = 7,
			"success_status" = "MAINTENANCE",
			"success_details" = "Emergency cold-chain equipment has restored limited medical distribution capability.",
			"reactive_aid" = TRUE
		),
		list(
			"id" = "med12_critical_stabilization",
			"installation_code" = "NT-MED-M12",
			"type" = "REQUEST",
			"priority" = "Important",
			"title" = "Critical Medical Distribution Stabilization",
			"body" = "M-12 is in a full operational emergency. We are consolidating viable stock, abandoning damaged storage areas, and running essential refrigeration from emergency feeds. Release stabilization resources now or this sector loses a major part of its medical supply chain.",
			"required_statuses" = list("CRITICAL"),
			"allocation_cost" = 10,
			"success_details" = "Emergency medical-logistics resources have been committed to essential refrigeration, verified stock, protected treatment areas, and local containment efforts.",
			"reactive_aid" = TRUE
		)
	)

	// Possible Critical Incidents
	// Critical incidents are mostly installation-specific so failures better match each site's function.
	// Roughly 70% of CRITICAL escalations use the installation pool; the remainder use a common sector emergency.

	var/static/list/critical_incidents_common = list(
		"a cascading primary power failure",
		"a major atmospheric containment failure",
		"multiple structural integrity failures",
		"unidentified external impacts causing severe structural damage",
		"a widespread internal systems failure",
		"an unresolved station-wide security emergency",
		"a cascading life-support systems failure",
		"coordinated Syndicate sabotage affecting primary installation infrastructure"
	)

	var/static/list/critical_incidents_by_installation = list(
		"NT-REL-A17" = list(
			"catastrophic failure across the long-range relay array",
			"a hostile Syndicate signal intrusion overriding authenticated relay traffic",
			"suspected changeling infiltration following conflicting operator voiceprints and access records",
			"a coordinated communications blackout preceding suspected hostile boarding activity",
			"severe thaumaturgic interference consistent with Wizard Federation manipulation of the relay network",
			"an unauthorized Wizard Federation transmission forcing repeated spatial and signal anomalies through the primary array"
		),
		"NT-OUT-K04" = list(
			"armed revolutionary activity resulting in loss of local administrative control",
			"suspected changeling infiltration compromising the outpost command roster",
			"violent cultist activity compromising monitoring and security spaces",
			"a heretic-related anomaly spreading through occupied administrative areas",
			"a hostile infiltrator incident involving Syndicate equipment and multiple casualties",
			"an unauthorized Wizard Federation teleportation event depositing hostile arcane phenomena inside the outpost"
		),
		"NT-MIN-RC12" = list(
			"an uncontrolled industrial accident causing cascading processing-line failures",
			"coordinated Syndicate sabotage affecting excavation and ore-processing infrastructure",
			"violent revolutionary activity resulting in seizure of primary industrial controls",
			"cultist or heretic activity discovered within active excavation sectors",
			"a suspected bloodsucker attack producing multiple exsanguinated casualties in maintenance tunnels",
			"large-scale arcane transmutation associated with suspected Wizard Federation activity destabilizing stored mineral stock"
		),
		"NT-LP-D03" = list(
			"a confirmed nuclear operative incursion against the listening post",
			"a hostile Syndicate boarding action following interception of classified burst traffic",
			"a total monitoring blackout coinciding with unidentified encrypted transmissions",
			"a heretic-related signal anomaly producing persistent nonstandard sensor returns",
			"suspected changeling infiltration following conflicting watch-officer biometric records",
			"a Wizard Federation transmission event causing repeated impossible sensor contacts and localized spatial distortion"
		),
		"NT-ADM-06" = list(
			"armed revolutionary activity resulting in seizure of records and personnel-control systems",
			"coordinated Syndicate infiltration compromising secure corporate records",
			"suspected changeling infiltration following extensive duplicate personnel records and biometric conflicts",
			"violent cultist activity inside restricted archival areas",
			"a heretic-related containment incident involving anomalous records, structures, and missing personnel",
			"a suspected Wizard Federation raid resulting in the disappearance and reappearance of secured archival material"
		),
		"NT-LOG-H09" = list(
			"coordinated Syndicate sabotage collapsing automated freight routing",
			"an armed hostile raid targeting secured freight and supply reserves",
			"revolutionary activity resulting in seizure of cargo control and dispatch systems",
			"suspected changeling infiltration among routing personnel during a major freight emergency",
			"a chain reaction involving misrouted hazardous freight and damaged loading infrastructure",
			"Wizard Federation spatial interference repeatedly displacing freight containers and personnel between secured routing zones"
		),
		"NT-MED-M12" = list(
			"a cascading medical cold-chain and life-support infrastructure failure",
			"suspected changeling infiltration following severe tissue, identity, and casualty discrepancies",
			"a suspected bloodsucker attack producing multiple unexplained exsanguinated casualties",
			"violent cultist or heretic activity compromising treatment and storage areas",
			"coordinated Syndicate sabotage involving contaminated or deliberately compromised medical stock",
			"an apparent Wizard Federation transmutation event rendering multiple secured medical supply batches biologically unrecognizable"
		)
	)
	// Post-Critical aftermath metadata.
	// Every possible Critical incident maps to a logical non-green recovery state
	// and incident-specific remarks. The incident remains visible as CONTAINED
	// until the installation later returns to green operation.
	var/static/list/critical_incident_aftermath = list(
		"a cascading primary power failure" = list(
			"status" = "MAINTENANCE",
			"details" = "Emergency generation and distribution have restored essential power. Damaged primary systems remain isolated while engineering repairs continue.",
			"request" = "Primary distribution is cascading out across the installation. We are shedding nonessential loads and moving occupied sections onto emergency feeds, but the remaining buses are failing faster than we can isolate them. We need emergency power-control hardware and replacement distribution components now.",
			"aid_details" = "Emergency power-control hardware, replacement distribution components, and technical support have been committed to keep essential systems energized while local crews isolate the cascade."
		),
		"a major atmospheric containment failure" = list(
			"status" = "MAINTENANCE",
			"details" = "Atmospheric containment has been restored around occupied sections. Damaged compartments remain sealed while environmental repairs continue.",
			"request" = "We have lost atmospheric containment across multiple sections and are sealing compartments as fast as pressure allows. Personnel are being moved into the remaining safe areas, but our emergency seals and environmental reserves are running down. We need containment hardware and life-support support immediately.",
			"aid_details" = "Emergency containment hardware, environmental-control equipment, and life-support resources have been committed to preserve occupied sections and reinforce failing atmospheric boundaries."
		),
		"multiple structural integrity failures" = list(
			"status" = "MAINTENANCE",
			"details" = "Further structural collapse has been arrested and unsafe sections have been isolated. Engineering recovery operations remain underway.",
			"request" = "Structural alarms are propagating through multiple sections and we have already abandoned areas we cannot safely brace. Crews are trying to stop a local failure from becoming a full collapse. We need emergency structural material, remote handling equipment, and engineering support now.",
			"aid_details" = "Emergency structural materials, bracing equipment, and engineering support have been committed to arrest further collapse and preserve safe access routes."
		),
		"unidentified external impacts causing severe structural damage" = list(
			"status" = "MAINTENANCE",
			"details" = "Damage-control teams have stabilized the affected structure. Impact-damaged sections remain restricted pending repair and investigation.",
			"request" = "We have taken repeated external impacts and several sections are no longer structurally trustworthy. Damage-control teams are sealing breaches and evacuating exposed compartments, but we do not know whether the impacts are finished. We need emergency structural and casualty-support resources immediately.",
			"aid_details" = "Emergency structural repair material, damage-control equipment, and casualty-support resources have been committed while personnel stabilize the impact-damaged sections."
		),
		"a widespread internal systems failure" = list(
			"status" = "MAINTENANCE",
			"details" = "Essential control systems have been restored at reduced capacity. Failed subsystems remain under repair.",
			"request" = "Control systems are failing across unrelated departments and local resets are no longer holding. We are running essential functions manually where we still can, but every new failure is narrowing what the installation can keep alive. We need replacement control hardware and emergency technical support now.",
			"aid_details" = "Replacement control hardware, emergency technical support, and continuity resources have been committed to keep essential services operating while failed subsystems are isolated."
		),
		"an unresolved station-wide security emergency" = list(
			"status" = "UNDER REVIEW",
			"details" = "Local control has been restored and the immediate security emergency has been contained. Central Security review and personnel accounting remain underway.",
			"request" = "We have an active security emergency across the installation and local control is breaking down in multiple areas. Personnel are consolidating behind secured access points while Security tries to regain control. We need emergency medical, communications, and continuity resources immediately.",
			"aid_details" = "Emergency medical, communications, access-control, and continuity resources have been committed to support local containment and preserve secured operating areas."
		),
		"a cascading life-support systems failure" = list(
			"status" = "MAINTENANCE",
			"details" = "Essential life-support services have been restored. Damaged environmental systems remain under emergency operating restrictions.",
			"request" = "Life-support failures are spreading faster than our technicians can stabilize them. We are shutting down nonessential sections and concentrating personnel where atmosphere and temperature are still controllable. We need emergency environmental-control and power resources before the remaining safe areas become untenable.",
			"aid_details" = "Emergency environmental-control, power, and life-support resources have been committed to preserve the remaining habitable sections while damaged systems are isolated."
		),
		"coordinated Syndicate sabotage affecting primary installation infrastructure" = list(
			"status" = "UNDER REVIEW",
			"details" = "Sabotaged systems have been isolated and essential operations restored. A Central Security investigation into the hostile action remains active.",
			"request" = "We have confirmed coordinated sabotage across primary infrastructure and cannot assume the remaining failures are accidental. Critical systems are being isolated while verified personnel work under restricted access. We need emergency repair, security, and continuity resources now before the sabotage takes the installation with it.",
			"aid_details" = "Emergency repair, access-control, and continuity resources have been committed to isolate sabotaged systems and keep verified personnel in control of essential infrastructure."
		),
		"catastrophic failure across the long-range relay array" = list(
			"status" = "MAINTENANCE",
			"details" = "Emergency relay repairs have restored limited long-range capability. Damaged array sections remain isolated pending full repair.",
			"request" = "The long-range array is collapsing section by section. We have already isolated damaged emitters and the remaining trunk is carrying traffic without meaningful redundancy. I need emergency relay components and contractor routing now, before the last stable path fails with everything still on it.",
			"aid_details" = "Emergency relay components, power-control hardware, and contractor support have been committed to preserve the remaining trunk and isolate failing array sections."
		),
		"a hostile Syndicate signal intrusion overriding authenticated relay traffic" = list(
			"status" = "UNDER REVIEW",
			"details" = "Compromised relay channels have been isolated and authenticated traffic restored through secured routing. Security specialists continue tracing the hostile intrusion.",
			"request" = "Our authenticated traffic is being overwritten by a hostile Syndicate signal and we can no longer trust every route leaving this station. We are cutting compromised channels and forcing verified traffic through isolated hardware, but the clean paths are disappearing. I need secure routing equipment and emergency processing support immediately.",
			"aid_details" = "Secure routing hardware, authentication support, and replacement processing equipment have been committed to isolate compromised channels and preserve verified relay traffic."
		),
		"suspected changeling infiltration following conflicting operator voiceprints and access records" = list(
			"status" = "UNDER REVIEW",
			"details" = "Conflicting operator identities have been isolated from privileged access and verified personnel have resumed essential relay operations. Identity review remains active.",
			"request" = "We have conflicting operator voiceprints, contradictory access records, and personnel we cannot reliably identify. Privileged relay controls are being locked down to the few identities we can verify, but that is leaving critical systems understaffed. I need continuity resources, secure authentication support, and emergency staffing capacity now.",
			"aid_details" = "Secure authentication, continuity, and emergency operating resources have been committed so verified personnel can maintain essential relay control while identity checks continue."
		),
		"a coordinated communications blackout preceding suspected hostile boarding activity" = list(
			"status" = "UNDER REVIEW",
			"details" = "Limited communications have been restored and the immediate boarding threat has been contained. Security sweeps and access review remain underway.",
			"request" = "The blackout was not random. We lost external communications immediately before suspected hostile boarding activity and several internal routes are now contested or silent. We are holding the relay core and restoring one secure path at a time. I need emergency communications, access-control, and casualty-support resources now.",
			"aid_details" = "Emergency communications, access-control, and casualty-support resources have been committed to preserve the relay core and support local containment of the suspected boarding action."
		),
		"severe thaumaturgic interference consistent with Wizard Federation manipulation of the relay network" = list(
			"status" = "COMMUNICATIONS DEGRADED",
			"details" = "Affected relay segments have been isolated and stable traffic restored through alternate channels. Thaumaturgic interference persists at reduced intensity.",
			"request" = "The relay network is being hit by interference that does not behave like any conventional fault. Channels are distorting, rerouting themselves, and dropping synchronization faster than we can isolate them. I need redundant processing, protected power, and replacement relay hardware before the interference takes the remaining stable paths.",
			"aid_details" = "Redundant processing, protected power, and replacement relay hardware have been committed to isolate affected segments and preserve stable communications during the thaumaturgic interference."
		),
		"an unauthorized Wizard Federation transmission forcing repeated spatial and signal anomalies through the primary array" = list(
			"status" = "COMMUNICATIONS DEGRADED",
			"details" = "Primary anomalous signal paths have been isolated and normal traffic rerouted. Residual spatial and signal anomalies remain under observation.",
			"request" = "An unauthorized Wizard transmission is driving spatial and signal anomalies through the primary array. Hardware is reporting from impossible locations and traffic is appearing on paths we physically disconnected. We are isolating the primary sections, but I need redundant relay equipment and emergency power support before the anomaly spreads through the remaining network.",
			"aid_details" = "Redundant relay hardware, emergency power support, and isolated processing resources have been committed to preserve alternate traffic paths while anomalous primary-array sections are contained."
		),
		"armed revolutionary activity resulting in loss of local administrative control" = list(
			"status" = "UNDER REVIEW",
			"details" = "Verified Nanotrasen personnel have regained control of critical administrative and life-support areas. Remaining revolutionary activity is being contained and the outpost is under security review.",
			"request" = "Armed revolutionaries have taken administrative spaces and we have lost local control of several access and monitoring systems. Verified personnel are consolidating in the protected section and shutting hostile users out wherever we still can. We need emergency continuity, medical, and secure-control resources now or we may lose the outpost entirely.",
			"aid_details" = "Emergency continuity, medical, and secure-control resources have been committed to support verified personnel holding protected sections and restoring local administrative control."
		),
		"suspected changeling infiltration compromising the outpost command roster" = list(
			"status" = "UNDER REVIEW",
			"details" = "Verified personnel have re-established local command access and suspected compromised staff have been isolated. Identity verification remains underway.",
			"request" = "We cannot trust the command roster. Biometric records and personnel identities are conflicting, and at least one privileged account may belong to someone who is not who they claim to be. Verified staff are restricting access and operating from a reduced chain of command. We need secure authentication and continuity resources immediately.",
			"aid_details" = "Secure authentication, access-control, and continuity resources have been committed so verified personnel can maintain the outpost while suspected compromised staff are isolated."
		),
		"violent cultist activity compromising monitoring and security spaces" = list(
			"status" = "UNDER REVIEW",
			"details" = "Immediate cultist activity has been contained and compromised monitoring and security spaces have been secured. Central Security review continues.",
			"request" = "Cultist activity has breached monitoring and Security spaces and we are losing reliable coverage of occupied sections. Surviving personnel are abandoning compromised rooms and trying to hold the protected administrative core. We need emergency medical, security, and continuity resources now.",
			"aid_details" = "Emergency medical, access-control, and continuity resources have been committed to reinforce protected areas and support containment of the cultist activity."
		),
		"a heretic-related anomaly spreading through occupied administrative areas" = list(
			"status" = "UNDER REVIEW",
			"details" = "The affected administrative areas have been isolated and the immediate anomalous threat contained. Specialist review remains in progress.",
			"request" = "An anomalous event linked to suspected heretic activity is spreading through occupied administrative areas. We are evacuating personnel and sealing sections as soon as the anomaly reaches them, but we are running out of uncontaminated space and equipment. We need emergency isolation and continuity resources immediately.",
			"aid_details" = "Emergency isolation, continuity, and protected-power resources have been committed to keep occupied sections functional while the anomalous areas are contained."
		),
		"a hostile infiltrator incident involving Syndicate equipment and multiple casualties" = list(
			"status" = "UNDER REVIEW",
			"details" = "Local security has restored control of critical areas. Casualty treatment, evidence recovery, and hostile-infiltration review remain underway.",
			"request" = "We have a hostile infiltrator using Syndicate equipment inside the outpost and multiple personnel are already down. Local Security is trying to hold the remaining controlled spaces while Medical works from improvised positions. We need emergency medical, access-control, and continuity resources now.",
			"aid_details" = "Emergency medical, access-control, and continuity resources have been committed to support surviving personnel and reinforce local containment of the hostile infiltrator."
		),
		"an unauthorized Wizard Federation teleportation event depositing hostile arcane phenomena inside the outpost" = list(
			"status" = "UNDER REVIEW",
			"details" = "Hostile arcane phenomena have been contained or isolated from occupied sections. Affected areas remain restricted pending specialist assessment.",
			"request" = "A Wizard Federation teleportation event has deposited hostile arcane phenomena inside occupied sections. Personnel and equipment are being displaced and we cannot guarantee that a secured room will remain secured. We need emergency isolation, redundant systems, and protected power immediately.",
			"aid_details" = "Emergency isolation equipment, redundant systems, and protected-power resources have been committed to preserve safe operating areas while hostile arcane phenomena are contained."
		),
		"an uncontrolled industrial accident causing cascading processing-line failures" = list(
			"status" = "MAINTENANCE",
			"details" = "Damaged processing lines have been isolated and essential platform services stabilized. Industrial repair operations remain underway.",
			"request" = "The processing lines are failing in sequence and we have crews abandoning machinery just to stay ahead of the cascade. Atmosphere, power, and structural isolation are now taking priority over production. We need emergency industrial repair material and life-support support now or there may not be a platform left to restart.",
			"aid_details" = "Emergency industrial repair material, structural support, and life-support resources have been committed to isolate failed processing lines and preserve occupied platform sections."
		),
		"coordinated Syndicate sabotage affecting excavation and ore-processing infrastructure" = list(
			"status" = "UNDER REVIEW",
			"details" = "Sabotaged excavation and processing systems have been isolated and local control restored. Repairs and a security investigation remain active.",
			"request" = "We have confirmed coordinated Syndicate sabotage across excavation and processing infrastructure. Controls we thought were safe are failing under load, and verified crews are working around systems we can no longer trust. We need emergency repair, security, and isolation resources immediately.",
			"aid_details" = "Emergency repair, access-control, and isolation resources have been committed to preserve verified industrial controls and contain sabotaged infrastructure."
		),
		"violent revolutionary activity resulting in seizure of primary industrial controls" = list(
			"status" = "UNDER REVIEW",
			"details" = "Primary industrial controls have been retaken or isolated from hostile personnel. Production remains restricted while security review continues.",
			"request" = "Revolutionary personnel have seized primary industrial controls and several processing areas are no longer answering to verified supervisors. Loyal crews are isolating power and trying to prevent hostile control from reaching life-support and pressure systems. We need emergency continuity and secure-control resources now.",
			"aid_details" = "Emergency continuity, secure-control, and industrial isolation resources have been committed to help verified crews deny hostile access to essential platform systems."
		),
		"cultist or heretic activity discovered within active excavation sectors" = list(
			"status" = "UNDER REVIEW",
			"details" = "Affected excavation sectors have been sealed and the immediate hostile activity contained. Specialist investigation remains underway.",
			"request" = "Hostile cultist or heretic activity has been confirmed inside active excavation sectors. We are sealing shafts and pulling crews back, but some personnel are still unaccounted for and industrial systems remain exposed. We need emergency medical, isolation, and continuity resources immediately.",
			"aid_details" = "Emergency medical, isolation, and continuity resources have been committed to support evacuated crews and secure affected excavation sectors."
		),
		"a suspected bloodsucker attack producing multiple exsanguinated casualties in maintenance tunnels" = list(
			"status" = "UNDER REVIEW",
			"details" = "Maintenance sectors have been secured and surviving personnel consolidated into controlled areas. Casualty and security review continue.",
			"request" = "We have multiple exsanguinated casualties in the maintenance tunnels and a suspected bloodsucker is still unaccounted for. Crews are abandoning isolated passages and consolidating around lit, controlled areas. We need emergency medical, security, and portable power resources now.",
			"aid_details" = "Emergency medical, portable-power, access-control, and security-support resources have been committed to reinforce controlled areas and treat surviving personnel."
		),
		"large-scale arcane transmutation associated with suspected Wizard Federation activity destabilizing stored mineral stock" = list(
			"status" = "MAINTENANCE",
			"details" = "Unstable mineral stock has been isolated and affected processing lines shut down. Controlled industrial recovery remains underway.",
			"request" = "Stored mineral stock is undergoing large-scale transmutation and we cannot predict which material is stable enough to move. Processing lines are being shut down around affected storage, but the unstable stock is threatening nearby infrastructure. We need emergency containment, handling, and industrial support immediately.",
			"aid_details" = "Emergency containment, remote-handling, and industrial support resources have been committed to isolate unstable mineral stock and protect nearby platform systems."
		),
		"a confirmed nuclear operative incursion against the listening post" = list(
			"status" = "UNDER REVIEW",
			"details" = "The hostile nuclear operative incursion has been repelled or contained and surviving personnel have regained local control. Classified systems remain locked down during security sweeps and damage assessment.",
			"request" = "Liaison, this is Delta-3. We have confirmed nuclear operatives inside the post. Several secure sections are already lost and surviving personnel are consolidating around the monitoring core while classified systems are locked down. We need emergency medical, secure-power, and communications support immediately. If we lose this position, there may not be another transmission.",
			"aid_details" = "Emergency medical, secure-power, communications, and continuity resources have been committed to help surviving personnel hold the monitoring core and protect classified systems during the nuclear operative incursion."
		),
		"a hostile Syndicate boarding action following interception of classified burst traffic" = list(
			"status" = "UNDER REVIEW",
			"details" = "The boarding action has been repelled or contained and classified systems remain secured. Security sweeps and intelligence review continue.",
			"request" = "We intercepted classified hostile traffic and were boarded almost immediately afterward. Multiple access points are compromised and surviving personnel are falling back around the secure monitoring core. We need emergency medical, access-control, and protected communications support now.",
			"aid_details" = "Emergency medical, access-control, and protected communications resources have been committed to reinforce the secure core and support containment of the Syndicate boarding action."
		),
		"a total monitoring blackout coinciding with unidentified encrypted transmissions" = list(
			"status" = "COMMUNICATIONS DEGRADED",
			"details" = "Emergency monitoring has been restored through isolated systems. The origin of the encrypted traffic remains unresolved and full coverage is not yet available.",
			"request" = "Our monitoring array went completely dark while unidentified encrypted transmissions appeared across emergency channels. We are bringing receivers back one isolated rack at a time, but we cannot tell what happened outside our remaining local sensors. We need emergency processing, power-conditioning, and secure communications support now.",
			"aid_details" = "Emergency processing, power-conditioning, and secure communications resources have been committed to restore isolated monitoring coverage and investigate the encrypted traffic."
		),
		"a heretic-related signal anomaly producing persistent nonstandard sensor returns" = list(
			"status" = "COMMUNICATIONS DEGRADED",
			"details" = "The affected monitoring array has been isolated and limited coverage restored. Persistent anomalous sensor returns remain under investigation.",
			"request" = "We have persistent sensor returns that do not match any physical contact and the anomaly is spreading across monitoring channels. Operators are isolating affected racks, but we are losing sector coverage with every system we disconnect. We need redundant processing and protected monitoring hardware immediately.",
			"aid_details" = "Redundant processing, protected monitoring hardware, and isolated power resources have been committed to preserve usable coverage while anomalous sensor channels are contained."
		),
		"suspected changeling infiltration following conflicting watch-officer biometric records" = list(
			"status" = "UNDER REVIEW",
			"details" = "Verified personnel have regained control of the listening post and biometric revalidation is underway. Classified access remains restricted.",
			"request" = "Watch-officer biometrics are conflicting and we can no longer trust every person with access to classified monitoring systems. Verified personnel are locking down credentials and operating with a reduced watch team. We need secure authentication, medical, and continuity resources now.",
			"aid_details" = "Secure authentication, medical, and continuity resources have been committed so verified personnel can maintain classified monitoring while suspected compromised staff are isolated."
		),
		"a Wizard Federation transmission event causing repeated impossible sensor contacts and localized spatial distortion" = list(
			"status" = "COMMUNICATIONS DEGRADED",
			"details" = "Affected monitoring systems have been isolated and partial coverage restored. Residual spatial and signal distortion remains under observation.",
			"request" = "A Wizard Federation transmission is producing impossible sensor contacts and localized spatial distortion throughout the post. Equipment is reporting movement where nothing exists and some compartments are no longer spatially consistent. We need redundant monitoring, protected power, and emergency isolation resources immediately.",
			"aid_details" = "Redundant monitoring hardware, protected power, and emergency isolation resources have been committed to preserve a stable watch capability while spatial and signal anomalies are contained."
		),
		"armed revolutionary activity resulting in seizure of records and personnel-control systems" = list(
			"status" = "UNDER REVIEW",
			"details" = "Verified Nanotrasen personnel have regained access to priority archives and personnel-control systems. Remaining revolutionary activity is being contained and the Annex is under security review.",
			"request" = "Liaison, armed personnel have seized part of the Annex and we have lost access to several records and personnel-control systems. Loyal staff are evacuating priority archives and sealing the sections we still hold. Authorize emergency continuity, medical, and secure-records resources now or we risk losing both the facility and the records inside it.",
			"aid_details" = "Emergency continuity, medical, and secure-records resources have been committed to protect priority archives and support verified personnel holding the remaining controlled sections."
		),
		"coordinated Syndicate infiltration compromising secure corporate records" = list(
			"status" = "UNDER REVIEW",
			"details" = "Compromised systems have been isolated and priority archives secured. The extent of hostile access and data exposure remains under investigation.",
			"request" = "We have confirmed coordinated Syndicate access to secure corporate records and cannot yet determine how much data has been exposed. Priority archives are being isolated from the network while verified staff work from sealed systems. We need emergency secure-storage, authentication, and continuity resources immediately.",
			"aid_details" = "Emergency secure-storage, authentication, and continuity resources have been committed to isolate compromised records systems and preserve priority corporate archives."
		),
		"suspected changeling infiltration following extensive duplicate personnel records and biometric conflicts" = list(
			"status" = "UNDER REVIEW",
			"details" = "Personnel records have been frozen for reconciliation and verified staff have restored control of critical archive functions. Identity verification remains underway.",
			"request" = "Personnel records are duplicating, biometrics are conflicting, and we no longer know which identities inside the Annex can be trusted. Verified staff are freezing personnel-control changes and moving priority records onto isolated systems. We need secure authentication and continuity resources now.",
			"aid_details" = "Secure authentication, isolated records-processing, and continuity resources have been committed so verified personnel can protect priority archives while identity verification continues."
		),
		"violent cultist activity inside restricted archival areas" = list(
			"status" = "UNDER REVIEW",
			"details" = "Restricted archival areas have been secured and compromised records or materials isolated. Central Security and specialist review continue.",
			"request" = "Cultist activity has breached restricted archival areas and several secure collections are no longer under verified control. Staff are evacuating irreplaceable records and sealing contaminated sections wherever possible. We need emergency medical, secure-storage, and access-control resources immediately.",
			"aid_details" = "Emergency medical, secure-storage, and access-control resources have been committed to preserve priority archives and reinforce containment of compromised archival areas."
		),
		"a heretic-related containment incident involving anomalous records, structures, and missing personnel" = list(
			"status" = "UNDER REVIEW",
			"details" = "The immediate anomalous activity has been contained and affected records and structures sealed. Missing-personnel and specialist investigations remain active.",
			"request" = "We have anomalous records and structures inside secured archival space, and personnel are missing from areas that should be physically accounted for. Staff are withdrawing from affected sections and sealing every boundary that still behaves normally. We need emergency isolation and continuity resources now.",
			"aid_details" = "Emergency isolation, secure-storage, and continuity resources have been committed to protect unaffected archives and support containment of anomalous sections."
		),
		"a suspected Wizard Federation raid resulting in the disappearance and reappearance of secured archival material" = list(
			"status" = "UNDER REVIEW",
			"details" = "Displaced archival material has been quarantined and priority records secured. Provenance and integrity verification remain underway.",
			"request" = "Secured archival material is disappearing and reappearing in locations it was never transferred to, and we have evidence of a Wizard Federation raid. We cannot certify the integrity of anything that has been displaced. We need emergency quarantine, secure-storage, and verification resources immediately.",
			"aid_details" = "Emergency quarantine, secure-storage, and verification resources have been committed to protect unaffected archives and isolate displaced material pending integrity checks."
		),
		"coordinated Syndicate sabotage collapsing automated freight routing" = list(
			"status" = "MAINTENANCE",
			"details" = "Emergency manual routing has been established and damaged automation isolated. Freight operations remain reduced while repairs and security review continue.",
			"request" = "Automated freight routing is collapsing under confirmed Syndicate sabotage. We are assigning lanes manually where consoles still answer, but compromised controllers are creating dangerous movements faster than staff can catch them. We need emergency routing hardware, protected power, and security support now.",
			"aid_details" = "Emergency routing hardware, protected power, and security-support resources have been committed to establish controlled manual freight movement while sabotaged automation is isolated."
		),
		"an armed hostile raid targeting secured freight and supply reserves" = list(
			"status" = "UNDER REVIEW",
			"details" = "The hostile raid has been repelled or contained and secured reserves are being accounted for. Security sweeps and loss assessment remain underway.",
			"request" = "Armed hostiles are inside the freight complex and targeting secured reserves. Several storage areas are contested and routing staff are falling back behind hardened access points. We need emergency medical, access-control, and continuity resources now before the remaining reserves and dispatch systems are lost.",
			"aid_details" = "Emergency medical, access-control, and continuity resources have been committed to reinforce protected freight areas and support containment of the armed raid."
		),
		"revolutionary activity resulting in seizure of cargo control and dispatch systems" = list(
			"status" = "UNDER REVIEW",
			"details" = "Dispatch control has been restored to verified personnel and compromised cargo lanes locked down. Security review remains active.",
			"request" = "Revolutionary personnel have seized cargo control and parts of dispatch. Verified routing staff are cutting compromised lanes and trying to keep hostile users away from hazardous and secured freight. We need emergency secure-control, continuity, and access resources immediately.",
			"aid_details" = "Emergency secure-control, continuity, and access resources have been committed to help verified routing personnel isolate seized dispatch systems and protect secured freight."
		),
		"suspected changeling infiltration among routing personnel during a major freight emergency" = list(
			"status" = "UNDER REVIEW",
			"details" = "Verified routing personnel have resumed restricted operations while identity checks continue. Privileged freight-control access remains limited.",
			"request" = "We have conflicting identities among routing staff during an active freight emergency and cannot trust every person with dispatch access. Verified personnel are restricting controls while trying to keep essential cargo moving. We need secure authentication, emergency staffing, and continuity resources now.",
			"aid_details" = "Secure authentication, emergency staffing, and continuity resources have been committed so verified personnel can maintain restricted freight operations while identity checks continue."
		),
		"a chain reaction involving misrouted hazardous freight and damaged loading infrastructure" = list(
			"status" = "MAINTENANCE",
			"details" = "Hazardous freight has been contained and damaged loading areas isolated. Controlled routing has resumed at reduced capacity.",
			"request" = "Misrouted hazardous freight has triggered a chain reaction across damaged loading infrastructure. We are evacuating lanes, isolating cargo we can still identify, and fighting secondary failures around the docks. We need emergency containment, handling, and structural resources immediately.",
			"aid_details" = "Emergency containment, remote-handling, and structural resources have been committed to isolate hazardous freight and stabilize damaged loading areas."
		),
		"Wizard Federation spatial interference repeatedly displacing freight containers and personnel between secured routing zones" = list(
			"status" = "MAINTENANCE",
			"details" = "Spatial events have subsided enough for controlled routing to resume. Affected lanes remain closed while displaced freight and personnel are accounted for.",
			"request" = "Spatial interference is moving freight containers and personnel between secured routing zones without any valid transfer path. We have suspended automated routing, but cargo is still appearing where it should not exist. We need emergency isolation, tracking, and protected-power resources now.",
			"aid_details" = "Emergency isolation, tracking, and protected-power resources have been committed to preserve controlled freight zones while spatial displacement events are contained."
		),
		"a cascading medical cold-chain and life-support infrastructure failure" = list(
			"status" = "MAINTENANCE",
			"details" = "Essential refrigeration and environmental control have been restored. Some medical stock remains quarantined or unavailable while validation continues.",
			"request" = "Cold storage and life-support failures are cascading through M-12. Staff are moving viable stock by hand and abandoning storage areas as environmental control drops out. We need emergency refrigeration, power-conditioning, and life-support resources now or the sector is going to lose critical medical inventory with this facility.",
			"aid_details" = "Emergency refrigeration, power-conditioning, and life-support resources have been committed to preserve viable medical stock and occupied distribution areas."
		),
		"suspected changeling infiltration following severe tissue, identity, and casualty discrepancies" = list(
			"status" = "UNDER REVIEW",
			"details" = "Suspect personnel and biological material have been isolated. Identity verification, casualty review, and medical containment remain underway.",
			"request" = "We have tissue, identity, and casualty records that no longer agree with each other, and suspected changeling infiltration inside a medical distribution center. Verified staff are isolating personnel and biological material while keeping critical stock secured. We need emergency quarantine, authentication, and continuity resources now.",
			"aid_details" = "Emergency quarantine, secure authentication, and continuity resources have been committed to protect verified medical stock and support isolation of suspect personnel and biological material."
		),
		"a suspected bloodsucker attack producing multiple unexplained exsanguinated casualties" = list(
			"status" = "UNDER REVIEW",
			"details" = "Treatment and storage areas have been secured and surviving personnel consolidated. Casualty investigation and security review remain active.",
			"request" = "We have multiple unexplained exsanguinated casualties and a suspected bloodsucker still active somewhere inside M-12. Personnel are consolidating treatment and storage into controlled areas while unsecured corridors are abandoned. We need emergency medical, security, and portable-power resources immediately.",
			"aid_details" = "Emergency medical, access-control, security-support, and portable-power resources have been committed to reinforce controlled treatment and storage areas."
		),
		"violent cultist or heretic activity compromising treatment and storage areas" = list(
			"status" = "UNDER REVIEW",
			"details" = "Compromised treatment and storage areas have been sealed and viable stock transferred to secured sections. Specialist review continues.",
			"request" = "Cultist or heretic activity has compromised treatment and medical-storage areas. Staff are moving patients and verified stock into the remaining secured sections while hostile or anomalous areas are sealed off. We need emergency medical continuity, isolation, and protected-power resources now.",
			"aid_details" = "Emergency medical continuity, isolation, and protected-power resources have been committed to preserve viable treatment capacity and secured medical stock."
		),
		"coordinated Syndicate sabotage involving contaminated or deliberately compromised medical stock" = list(
			"status" = "UNDER REVIEW",
			"details" = "Suspect medical stock has been quarantined and verified inventory moved into secured storage. Sabotage and contamination review remain active.",
			"request" = "We have confirmed coordinated sabotage involving contaminated or deliberately compromised medical stock. Distribution is being halted batch by batch while verified inventory is moved behind controlled access. We need emergency quarantine, validation, and secure-storage resources immediately.",
			"aid_details" = "Emergency quarantine, validation, and secure-storage resources have been committed to isolate compromised stock and protect verified medical inventory."
		),
		"an apparent Wizard Federation transmutation event rendering multiple secured medical supply batches biologically unrecognizable" = list(
			"status" = "UNDER REVIEW",
			"details" = "Transmuted stock has been quarantined and unaffected supplies transferred into validated storage. Specialist analysis remains underway.",
			"request" = "Multiple secured medical batches have been transmuted into material our systems cannot biologically identify. We are quarantining everything affected and transferring untouched stock away from the event, but validated storage is running out. We need emergency quarantine, analysis, and secure-storage resources now.",
			"aid_details" = "Emergency quarantine, analysis, and secure-storage resources have been committed to isolate transmuted stock and preserve unaffected medical inventory."
		)
	)


GLOBAL_DATUM_INIT(ccpost_sector_network, /datum/ccpost_sector_network, new)

// NETWORK REGISTRATION

/datum/ccpost_sector_network/proc/register_display(obj/machinery/status_display/ccpost_remote_status/display)
	if(!display)
		return

	registered_displays |= display

	ensure_started()


/datum/ccpost_sector_network/proc/unregister_display(obj/machinery/status_display/ccpost_remote_status/display)
	if(!display)
		return

	registered_displays -= display


/datum/ccpost_sector_network/proc/ensure_started()
	if(started)
		return

	started = TRUE

	initialize_sector_installations()

	// Give the system one existing archived notice when it first comes online.
	issue_sector_notice(TRUE)

	schedule_next_sector_installation_update()

	schedule_next_sector_message()

	schedule_next_sector_paperwork()

// SECTOR INSTALLATION MESSAGE GENERATION

/datum/ccpost_sector_network/proc/schedule_next_sector_message(
	minimum_delay = 4 MINUTES,
	maximum_delay = 7 MINUTES
)
	if(sector_message_timer)
		deltimer(sector_message_timer)

	sector_message_timer = addtimer(CALLBACK(src, PROC_REF(issue_sector_message)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)



// SECTOR ADMINISTRATIVE PAPERWORK GENERATION

/datum/ccpost_sector_network/proc/schedule_next_sector_paperwork(
	minimum_delay = 8 MINUTES,
	maximum_delay = 15 MINUTES
)
	if(sector_paperwork_timer)
		deltimer(sector_paperwork_timer)

	sector_paperwork_timer = addtimer(CALLBACK(src, PROC_REF(issue_sector_paperwork)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)


/// Administrative paperwork is only generated while an installation is stable
/// enough to perform ordinary office work. Maintenance remains eligible.
/datum/ccpost_sector_network/proc/can_issue_sector_paperwork(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return FALSE

	return installation.status == "ONLINE" || installation.status == "ROUTINE OPERATIONS" || installation.status == "MAINTENANCE"


/// Removes the active paperwork request if its source can no longer conduct
/// normal administrative business. Physical copies become invalid immediately.
/datum/ccpost_sector_network/proc/expire_active_sector_paperwork(reason = "Source installation is no longer available for routine administrative processing.", refresh_ui = TRUE)
	if(!active_sector_paperwork)
		return FALSE

	var/expired_code = active_sector_paperwork.paperwork_code

	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal))
			continue

		if(terminal.submitted_paperwork?.paperwork_code == expired_code)
			terminal.eject_sector_paperwork()

	qdel(active_sector_paperwork)
	active_sector_paperwork = null

	// An invalidated document should not block later routine paperwork forever.
	schedule_next_sector_paperwork(4 MINUTES, 7 MINUTES)

	if(refresh_ui)
		refresh_comms_terminals()

	return TRUE


/datum/ccpost_sector_network/proc/expire_sector_paperwork_for_installation(
	datum/ccpost_sector_installation/installation,
	reason = "Source installation is no longer available for routine administrative processing."
)
	if(!installation || !active_sector_paperwork)
		return FALSE

	if(active_sector_paperwork.installation_code != installation.installation_code)
		return FALSE

	return expire_active_sector_paperwork(reason)


/// Confirms that the current paperwork still belongs to an eligible installation.
/// UI reads may suppress the extra refresh because the interface is already updating.
/datum/ccpost_sector_network/proc/validate_active_sector_paperwork(refresh_ui = TRUE)
	if(!active_sector_paperwork)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		active_sector_paperwork.installation_code
	)

	if(!can_issue_sector_paperwork(installation))
		expire_active_sector_paperwork(
			"Source installation left routine administrative availability.",
			refresh_ui
		)
		return FALSE

	return TRUE


/datum/ccpost_sector_network/proc/issue_sector_paperwork()
	sector_paperwork_timer = null

	// One physical document slot means one active paperwork request at a time.
	if(active_sector_paperwork)
		if(validate_active_sector_paperwork())
			return

	var/list/eligible_templates = list()

	for(var/list/template as anything in sector_paperwork_templates)
		var/datum/ccpost_sector_installation/installation = get_installation_by_code(
			template["installation_code"]
		)

		if(!can_issue_sector_paperwork(installation))
			continue

		eligible_templates += list(template)

	if(!length(eligible_templates))
		schedule_next_sector_paperwork(4 MINUTES, 7 MINUTES)
		return

	// Avoid immediately repeating the same form when alternatives exist.
	if(length(eligible_templates) > 1 && last_sector_paperwork_template_id)
		var/list/non_repeating_templates = list()

		for(var/list/template as anything in eligible_templates)
			if(template["id"] == last_sector_paperwork_template_id)
				continue

			non_repeating_templates += list(template)

		if(length(non_repeating_templates))
			eligible_templates = non_repeating_templates

	var/list/chosen_template = pick(eligible_templates)
	var/datum/ccpost_sector_installation/source_installation = get_installation_by_code(
		chosen_template["installation_code"]
	)

	if(!can_issue_sector_paperwork(source_installation))
		schedule_next_sector_paperwork(4 MINUTES, 7 MINUTES)
		return

	var/paperwork_code = "[source_installation.installation_code]/PR-[next_sector_paperwork_number]"
	next_sector_paperwork_number++

	active_sector_paperwork = new /datum/ccpost_sector_paperwork_request(
		paperwork_code,
		source_installation,
		chosen_template
	)

	last_sector_paperwork_template_id = chosen_template["id"]

	var/printed = FALSE

	// The first available Sector Communications Terminal physically prints the
	// incoming form. Other terminals can still display or reprint the same request.
	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal) || terminal.machine_stat & (NOPOWER | BROKEN))
			continue

		if(terminal.print_sector_paperwork(active_sector_paperwork))
			terminal.say("Incoming administrative document from [source_installation.installation_name]. Sender: [source_installation.contact_role] [source_installation.contact_name].")
			printed = TRUE
			break

	if(!printed)
		// The request remains available in TGUI and can be reprinted when a terminal
		// becomes functional again.
		refresh_comms_terminals()
	else
		refresh_comms_terminals()


/datum/ccpost_sector_network/proc/get_paperwork_receipt_body(
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_paperwork_request/paperwork,
	reward_text
)
	if(!installation || !paperwork)
		return "Document receipt confirmed. [reward_text]"

	var/relationship = get_installation_trust_label(installation)

	switch(relationship)
		if("TRUSTED")
			return "Received, thank you. Liaison review [paperwork.paperwork_code] has been entered into our local administrative record. [reward_text] I appreciate the quick turnaround."
		if("COOPERATIVE")
			return "Liaison review [paperwork.paperwork_code] has been received and entered into the local administrative record. [reward_text] Thank you for the prompt review."
		if("GUARDED")
			return "Receipt confirmed for Liaison review [paperwork.paperwork_code]. The document has been entered into the local administrative record. [reward_text]"
		if("STRAINED")
			return "For record: Liaison review [paperwork.paperwork_code] has been received and entered locally. [reward_text] No further action is required from the Liaison office."

	return "Liaison review [paperwork.paperwork_code] has been received and entered into the local administrative record. [reward_text] Thank you for the timely review."


/// Completes a transmitted form after a short simulated routing delay, credits
/// the Liaison Outpost, and creates an ordinary Sector Communications receipt.
/datum/ccpost_sector_network/proc/complete_sector_paperwork(paperwork_code)
	if(!active_sector_paperwork || active_sector_paperwork.paperwork_code != paperwork_code)
		return

	if(active_sector_paperwork.status != "TRANSMITTED - AWAITING RECEIPT")
		return

	if(!validate_active_sector_paperwork())
		return

	var/datum/ccpost_sector_paperwork_request/completed_paperwork = active_sector_paperwork
	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		completed_paperwork.installation_code
	)

	if(!can_issue_sector_paperwork(installation))
		expire_active_sector_paperwork("Receiving installation became unavailable before document receipt.")
		return

	var/credited_amount = 0
	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network

	if(logistics_network)
		credited_amount = logistics_network.credit_allocation(
			completed_paperwork.allocation_reward,
			"Completed sector paperwork [completed_paperwork.paperwork_code]: [completed_paperwork.title]",
			"CENTRAL COMMAND SECTOR ADMINISTRATION"
		)
		logistics_network.refresh_logistics_outputs()

	var/reward_text

	if(credited_amount >= completed_paperwork.allocation_reward)
		reward_text = "Administrative processing compensation of [credited_amount] CU has been credited to Liaison Operational Allocation."
	else if(credited_amount > 0)
		reward_text = "[credited_amount] CU of the [completed_paperwork.allocation_reward] CU administrative processing compensation was credited before local Operational Allocation reached capacity."
	else
		reward_text = "Administrative processing compensation was approved, but local Operational Allocation is already at maximum capacity."

	var/paperwork_processor = completed_paperwork.submitted_by ? completed_paperwork.submitted_by : "UNKNOWN LIAISON"

	adjust_installation_trust(
		installation,
		2,
		"ADMINISTRATION",
		"Paperwork processed: [completed_paperwork.title]",
		"[completed_paperwork.sender_role] [completed_paperwork.sender_name] confirmed receipt of [completed_paperwork.paperwork_code], processed by [paperwork_processor]."
	)

	var/list/confirmation_template = list(
		"id" = "paperwork_receipt_[completed_paperwork.paperwork_code]",
		"installation_code" = completed_paperwork.installation_code,
		"type" = "UPDATE",
		"priority" = "Routine",
		"title" = "Document Receipt Confirmation - [completed_paperwork.paperwork_code]",
		"body" = get_paperwork_receipt_body(installation, completed_paperwork, reward_text)
	)

	var/datum/ccpost_sector_message/confirmation = create_sector_message(
		installation,
		confirmation_template
	)

	if(confirmation)
		// Preserve the original sender identity used on the paperwork itself.
		confirmation.sender_name = completed_paperwork.sender_name
		confirmation.sender_role = completed_paperwork.sender_role
		confirmation.allocation_change = credited_amount
		notify_comms_terminals(confirmation)

	active_sector_paperwork = null
	qdel(completed_paperwork)

	schedule_next_sector_paperwork()
	refresh_comms_terminals()


/datum/ccpost_sector_network/proc/is_installation_green(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return FALSE

	return installation.status == "ONLINE" || installation.status == "ROUTINE OPERATIONS"


/// Selects another surviving sector installation to receive CU which cannot fit
/// inside the Liaison Outpost's Operational Allocation.
/datum/ccpost_sector_network/proc/get_allocation_reroute_recipient(excluded_installation_code)
	var/list/candidates = list()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(QDELETED(installation) || installation.destroyed)
			continue

		if(installation.installation_code == excluded_installation_code)
			continue

		candidates += installation

	if(!length(candidates))
		return null

	return pick(candidates)


/datum/ccpost_sector_network/proc/has_pending_sector_message_template(template_id)
	if(!template_id)
		return FALSE

	for(var/datum/ccpost_sector_message/existing_message as anything in sector_messages)
		if(QDELETED(existing_message))
			continue

		if(existing_message.resolution_status != "PENDING")
			continue

		if(existing_message.template_id == template_id)
			return TRUE

	return FALSE


/datum/ccpost_sector_network/proc/has_pending_sector_request_for_installation(installation_code)
	if(!installation_code)
		return FALSE

	for(var/datum/ccpost_sector_message/existing_message as anything in sector_messages)
		if(QDELETED(existing_message))
			continue

		if(existing_message.resolution_status != "PENDING")
			continue

		if(existing_message.installation_code != installation_code)
			continue

		if(existing_message.message_type == "REQUEST")
			return TRUE

	return FALSE


/datum/ccpost_sector_network/proc/get_eligible_sector_message_templates()
	var/list/eligible_templates = list()

	for(var/list/template as anything in sector_message_templates)
		// Reactive aid requests are rolled when an installation's status changes.
		// The ordinary communications timer should not generate them on its own.
		if(template["reactive_aid"])
			continue

		var/template_id = template["id"]

		if(has_pending_sector_message_template(template_id))
			continue

		var/installation_code = template["installation_code"]
		var/datum/ccpost_sector_installation/installation = get_installation_by_code(installation_code)

		if(!installation || installation.destroyed)
			continue

		var/list/required_statuses = template["required_statuses"]

		if(length(required_statuses))
			if(!(installation.status in required_statuses))
				continue

		// Installations may only transfer CU while they are fully green.
		// This is intentionally enforced here even if a template's status list
		// is later edited incorrectly.
		var/allocation_reward = template["allocation_reward"]

		if(!isnull(allocation_reward) && allocation_reward > 0)
			if(!is_installation_green(installation))
				continue

		eligible_templates += list(template)

	return eligible_templates


// INSTALLATION HISTORY / RELATIONSHIP / FOLLOW-UP CHAINS

/datum/ccpost_sector_network/proc/get_installation_trust_label(datum/ccpost_sector_installation/installation)
	if(!installation)
		return "UNKNOWN"

	if(installation.trust_score >= 80)
		return "TRUSTED"
	if(installation.trust_score >= 60)
		return "COOPERATIVE"
	if(installation.trust_score >= 40)
		return "PROFESSIONAL"
	if(installation.trust_score >= 20)
		return "GUARDED"

	return "STRAINED"


/datum/ccpost_sector_network/proc/add_installation_history(
	datum/ccpost_sector_installation/installation,
	category,
	title,
	details
)
	if(!installation || !title)
		return

	var/datum/ccpost_installation_history_entry/entry = new(
		category || "GENERAL",
		title,
		details || "No additional details recorded."
	)

	installation.history.Insert(1, entry)

	while(length(installation.history) > max_installation_history_entries)
		var/datum/ccpost_installation_history_entry/oldest = installation.history[length(installation.history)]
		installation.history.Cut(length(installation.history), length(installation.history) + 1)
		qdel(oldest)

	notify_registered_displays()


/// Clears only the retained administrative history for one installation. This
/// does not alter its hidden relationship score, operational state, or active
/// follow-up chain.
/datum/ccpost_sector_network/proc/clear_installation_history(datum/ccpost_sector_installation/installation)
	if(!installation)
		return FALSE

	QDEL_LIST(installation.history)
	installation.history = list()
	notify_registered_displays()

	return TRUE


/datum/ccpost_sector_network/proc/adjust_installation_trust(
	datum/ccpost_sector_installation/installation,
	amount,
	category,
	title,
	details
)
	if(!installation || !amount)
		return 0

	var/old_score = installation.trust_score
	installation.trust_score = min(100, max(0, installation.trust_score + amount))
	var/actual_change = installation.trust_score - old_score

	if(!actual_change)
		return 0

	add_installation_history(
		installation,
		category,
		title,
		details
	)

	refresh_comms_terminals()

	return actual_change


/datum/ccpost_sector_network/proc/get_installation_status_severity(status)
	switch(status)
		if("ONLINE", "ROUTINE OPERATIONS")
			return 0
		if("MAINTENANCE", "UNDER REVIEW")
			return 1
		if("COMMUNICATIONS DEGRADED")
			return 2
		if("NO CONTACT")
			return 3
		if("OFFLINE")
			return 4
		if("CRITICAL")
			return 5

	return 0


/// Relationship affects how willing an installation is to volunteer continuing
/// context after a non-green operational update. It intentionally changes
/// information flow rather than raw survival odds or status-change rolls.
/datum/ccpost_sector_network/proc/get_installation_followup_chance(datum/ccpost_sector_installation/installation)
	if(!installation)
		return 0

	var/chance = 45 + round((installation.trust_score - 50) / 2)
	return min(70, max(25, chance))


/datum/ccpost_sector_network/proc/get_installation_followup_body(
	datum/ccpost_sector_installation/installation,
	origin_title,
	outcome
)
	if(!installation)
		return "Central Command is advised that the previously reported matter remains under local review."

	var/relationship = get_installation_trust_label(installation)
	var/current_status = installation.status

	switch(outcome)
		if("RESOLVED")
			switch(relationship)
				if("TRUSTED")
					return "Wanted to keep you personally informed: the matter we reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed. Your office has the update before we close the local file."
				if("COOPERATIVE")
					return "A quick follow-up for the Liaison office: the matter previously reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed. Thank you for keeping the line open."
				if("GUARDED")
					return "As required, this office is advising Central Command that the matter previously reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed."
				if("STRAINED")
					return "For mandatory record: local personnel have stabilized '[origin_title]' and normal operations have resumed. No further Liaison action is requested. The originating correspondence remains attached to our local file."
			return "For Central Command situational awareness, the matter previously reported as '[origin_title]' has stabilized. Local personnel have closed the immediate issue and normal operations have resumed."

		if("ESCALATED")
			switch(relationship)
				if("TRUSTED")
					return "I wanted you to have this before the next formal reporting cycle: conditions associated with '[origin_title]' have deteriorated and we are now at [current_status]. Local personnel are continuing containment. We will keep your office informed of any material change."
				if("COOPERATIVE")
					return "Please note that conditions associated with '[origin_title]' have deteriorated since our previous transmission. Current installation status is [current_status]. Local personnel are continuing containment and we will forward another update if the situation changes materially."
				if("GUARDED")
					return "Central Command is advised that conditions associated with '[origin_title]' have deteriorated. Current installation status is [current_status]. Local containment remains in progress; further reporting will follow if required."
				if("STRAINED")
					return "For mandatory record: conditions associated with '[origin_title]' have deteriorated to [current_status]. Local personnel are proceeding with containment. Further transmissions will be made only on material change."
			return "For Central Command situational awareness, conditions associated with '[origin_title]' have deteriorated since our previous transmission. Current installation status is [current_status]. Local personnel are continuing containment and will report any further material change."

		if("CONTINUING_FINAL")
			switch(relationship)
				if("TRUSTED")
					return "One last update for your desk: '[origin_title]' remains unresolved at [current_status], but local personnel have the matter under observation and there is no additional request for Central Command action right now. We'll reopen contact if that changes."
				if("COOPERATIVE")
					return "For continued Liaison awareness, '[origin_title]' remains unresolved and the installation remains at [current_status]. Local personnel are monitoring the issue. No additional Central Command action is requested at this time."
				if("GUARDED")
					return "As required, this office confirms that '[origin_title]' remains unresolved. Current installation status is [current_status]. No additional Central Command action is requested; local observation continues."
				if("STRAINED")
					return "For mandatory record: '[origin_title]' remains unresolved at [current_status]. Local personnel retain responsibility for observation. No further Liaison action is requested at this time."
			return "For Central Command situational awareness, the matter previously reported as '[origin_title]' remains unresolved. Current installation status is [current_status]. No additional Central Command action is requested at this time, but the issue remains under local observation."

		if("CONTINUING")
			switch(relationship)
				if("TRUSTED")
					return "Keeping you in the loop: '[origin_title]' is still active and we remain at [current_status]. Local teams are continuing investigation and containment. I'll forward the next useful update rather than make you wait on the routine cycle."
				if("COOPERATIVE")
					return "For continued Liaison awareness, '[origin_title]' remains active and the installation is still at [current_status]. Local personnel are continuing investigation and containment; another update will follow if the matter remains unresolved."
				if("GUARDED")
					return "Central Command is advised that '[origin_title]' remains active. Current installation status is [current_status]. Local investigation and containment continue; a further report will be transmitted if required."
				if("STRAINED")
					return "For mandatory record: '[origin_title]' remains active at [current_status]. Local personnel are continuing containment. Further correspondence will be limited to material developments."
			return "For Central Command situational awareness, the matter previously reported as '[origin_title]' remains active. Current installation status is [current_status]. Local personnel are continuing investigation and containment; a final status update will follow if the situation remains unresolved."

	return "Central Command is advised that '[origin_title]' remains under local review at [current_status]."


/// Ordinary non-green UPDATE messages can begin a short two-stage follow-up
/// chain. Aid requests and automatic denial follow-ups use their own systems and
/// are intentionally excluded.
/datum/ccpost_sector_network/proc/maybe_start_installation_followup(datum/ccpost_sector_message/message)
	if(!message || message.message_type != "UPDATE" || message.allocation_reward > 0)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(message.installation_code)

	if(!installation || installation.destroyed || installation.status == "CRITICAL")
		return FALSE

	if(is_installation_green(installation))
		return FALSE

	if(installation.active_followup_origin_code)
		return FALSE

	if(!prob(get_installation_followup_chance(installation)))
		return FALSE

	installation.active_followup_origin_code = message.message_code
	installation.active_followup_origin_title = message.title
	installation.active_followup_start_status = installation.status
	installation.followup_chain_step = 0

	var/minimum_delay = 3 MINUTES
	var/maximum_delay = 5 MINUTES

	if(installation.trust_score >= 80)
		minimum_delay = 2 MINUTES
		maximum_delay = 4 MINUTES
	else if(installation.trust_score < 20)
		minimum_delay = 4 MINUTES
		maximum_delay = 7 MINUTES

	add_installation_history(
		installation,
		"COMMUNICATIONS",
		"Follow-up opened: [message.title]",
		"[message.sender_role] [message.sender_name] indicated that additional information may follow regarding [message.title]."
	)

	addtimer(CALLBACK(src, PROC_REF(issue_installation_followup), installation.installation_code, message.message_code, 1), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)

	return TRUE


/datum/ccpost_sector_network/proc/clear_installation_followup(datum/ccpost_sector_installation/installation)
	if(!installation)
		return

	installation.active_followup_origin_code = null
	installation.active_followup_origin_title = null
	installation.active_followup_start_status = null
	installation.followup_chain_step = 0


/// Human-readable follow-up state for Liaison-facing records. Internal chain
/// step numbers remain backend-only.
/datum/ccpost_sector_network/proc/get_installation_followup_status_text(datum/ccpost_sector_installation/installation)
	if(!installation || !installation.active_followup_origin_code)
		return "No active case."

	if(installation.followup_chain_step <= 0)
		return "Awaiting first follow-up."

	return "Latest update received - further follow-up pending."


/datum/ccpost_sector_network/proc/issue_installation_followup(
	installation_code,
	origin_message_code,
	step
)
	var/datum/ccpost_sector_installation/installation = get_installation_by_code(installation_code)

	if(!installation || installation.destroyed)
		return

	if(installation.active_followup_origin_code != origin_message_code)
		return

	if(installation.status == "CRITICAL")
		add_installation_history(
			installation,
			"COMMUNICATIONS",
			"Follow-up superseded by Critical incident",
			"The continuing matter associated with [installation.active_followup_origin_title] was superseded when the installation entered CRITICAL status."
		)
		clear_installation_followup(installation)
		return

	installation.followup_chain_step = step

	var/origin_title = installation.active_followup_origin_title
	var/start_status = installation.active_followup_start_status
	var/current_severity = get_installation_status_severity(installation.status)
	var/start_severity = get_installation_status_severity(start_status)
	var/followup_title
	var/followup_body
	var/followup_priority = "Routine"
	var/chain_complete = FALSE

	if(is_installation_green(installation))
		followup_title = "Resolution Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "RESOLVED")
		chain_complete = TRUE
	else if(current_severity > start_severity)
		followup_title = "Escalation Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "ESCALATED")
		followup_priority = "Priority"
	else if(step >= 2)
		followup_title = "Continuing Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "CONTINUING_FINAL")
		chain_complete = TRUE
	else
		followup_title = "Continuing Follow-Up - [origin_title]"
		followup_body = get_installation_followup_body(installation, origin_title, "CONTINUING")

	var/list/followup_template = list(
		"id" = "installation_followup_[installation.installation_code]_[step]",
		"type" = "UPDATE",
		"priority" = followup_priority,
		"title" = followup_title,
		"body" = followup_body,
		"required_statuses" = list()
	)

	var/datum/ccpost_sector_message/followup_message = create_sector_message(installation, followup_template)

	if(followup_message)
		notify_comms_terminals(followup_message)

	add_installation_history(
		installation,
		"COMMUNICATIONS",
		followup_title,
		followup_body
	)

	if(chain_complete)
		clear_installation_followup(installation)
		return

	addtimer(CALLBACK(src, PROC_REF(issue_installation_followup), installation.installation_code, origin_message_code, 2), rand(3 MINUTES, 5 MINUTES), TIMER_STOPPABLE)


// AID DENIAL CONSEQUENCES

/// Returns the escalation-risk penalty created by denying an installation's
/// Operational Allocation request. Green requests carry only a small future
/// risk, while refusing support to an already failing installation is a much
/// more serious gamble.
/datum/ccpost_sector_network/proc/get_aid_denial_risk(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return 0

	// Denials now carry substantially more operational weight. The value is
	// both added to later CRITICAL escalation rolls and used to bias ordinary
	// status updates toward deterioration.
	switch(installation.status)
		if("ONLINE", "ROUTINE OPERATIONS")
			return 6
		if("MAINTENANCE", "UNDER REVIEW")
			return 10
		if("COMMUNICATIONS DEGRADED")
			return 16
		if("NO CONTACT")
			return 22
		if("OFFLINE")
			return 28
		if("CRITICAL")
			return 30

	return 0


/// Percentage chance that an unresolved denial penalty forces an ordinary
/// installation update to move in a worse direction instead of using the
/// normal mixed recovery/deterioration table.
/datum/ccpost_sector_network/proc/get_aid_denial_worsening_chance(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed || installation.aid_denial_risk <= 0)
		return 0

	return min(75, installation.aid_denial_risk * 2)


/// Picks an explicitly worse non-CRITICAL state. OFFLINE has no lower ordinary
/// state, so its denial pressure is represented by its increased CRITICAL roll.
/datum/ccpost_sector_network/proc/get_denial_worsened_status(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return null

	switch(installation.status)
		if("ONLINE", "ROUTINE OPERATIONS")
			return pick("MAINTENANCE", "MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED")

		if("MAINTENANCE")
			return pick("COMMUNICATIONS DEGRADED", "COMMUNICATIONS DEGRADED", "NO CONTACT")

		if("UNDER REVIEW")
			return pick("MAINTENANCE", "COMMUNICATIONS DEGRADED", "NO CONTACT")

		if("COMMUNICATIONS DEGRADED")
			return pick("NO CONTACT", "NO CONTACT", "OFFLINE")

		if("NO CONTACT")
			return "OFFLINE"

	return null


/// Records the mechanical and narrative consequences of refusing an
/// installation's request for Operational Allocation. No immediate status
/// damage is inflicted; instead the denied installation becomes more likely to
/// deteriorate during later sector simulation cycles.
/datum/ccpost_sector_network/proc/register_aid_denial(
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_message/message,
	mob/denying_user
)
	if(!installation || installation.destroyed || !message)
		return

	if(message.allocation_cost <= 0)
		return

	var/added_risk = get_aid_denial_risk(installation)

	installation.aid_denial_risk = min(45, installation.aid_denial_risk + added_risk)
	installation.aid_denial_count++
	installation.last_aid_denial_at = station_time_timestamp()
	installation.last_aid_denial_by = denying_user ? denying_user.name : "UNKNOWN"

	// Track an explicit denial made during the current Critical incident so
	// later recovery/loss reports can distinguish it from older denial risk.
	if(installation.status == "CRITICAL" && ("CRITICAL" in message.valid_statuses))
		installation.critical_aid_denied = TRUE
		installation.critical_aid_denied_by = denying_user ? denying_user.name : "UNKNOWN"
		installation.critical_aid_denied_at = station_time_timestamp()

	if(added_risk > 0)
		installation.condition_details += " A recent request for external operational support was denied; local recovery capacity is reduced."
		notify_registered_displays()

	schedule_denial_followup(installation, message)


/// Schedules a short acknowledgement from the same named installation contact.
/// The follow-up is informational only and does not create another spending
/// decision.
/datum/ccpost_sector_network/proc/schedule_denial_followup(
	datum/ccpost_sector_installation/installation,
	datum/ccpost_sector_message/message
)
	if(!installation || !message)
		return

	addtimer(CALLBACK(src, PROC_REF(issue_denial_followup), installation.installation_code, message.title, installation.status), rand(2 MINUTES, 4 MINUTES), TIMER_STOPPABLE)


/datum/ccpost_sector_network/proc/get_denial_followup_body(
	datum/ccpost_sector_installation/installation,
	request_title,
	denied_status
)
	if(!installation)
		return "Assistance denial received. Local personnel will continue without the requested support."

	var/base_body

	if(is_installation_green(installation))
		base_body = pick("We managed to stabilize the problem locally. The refusal and additional maintenance burden have been logged for the next shift.", "Local staff have brought the installation back within normal parameters. The deferred work has not disappeared.", "We recovered without the allocation this time. The original request remains attached to our maintenance record in case the same fault returns.")
	else if(denied_status == "CRITICAL" || installation.status == "CRITICAL")
		base_body = pick("We are proceeding without the requested emergency allocation. Personnel are being moved onto survival priorities and anything we cannot keep running safely is being abandoned.", "Emergency support is not coming. We will use what remains on-site and concentrate on keeping the installation intact long enough for the next response window.", "No additional allocation has been authorized. Nonessential systems are being cut now and the duty staff are working with what remains.")
	else if(denied_status == "NO CONTACT" || denied_status == "OFFLINE" || installation.status == "NO CONTACT" || installation.status == "OFFLINE")
		base_body = pick("We are staying on emergency procedures and local reserves. I cannot promise the next transmission will make it out if the remaining systems continue to degrade.", "The remaining staff are keeping essential systems alive manually; anything beyond that is being deferred.", "The team has been told to conserve spares and power until we either recover locally or lose the link again.")
	else if(denied_status == "COMMUNICATIONS DEGRADED" || installation.status == "COMMUNICATIONS DEGRADED")
		base_body = pick("We will stretch the remaining hardware and continue local repairs. If telemetry drops further, the original request should explain why.", "The degraded systems will remain in service and we will attempt to keep the temporary fixes alive under load.", "We will work around the fault without outside support. The affected systems are now marked as operating without normal redundancy.")
	else
		base_body = pick("We will continue with local maintenance and existing reserves. External assistance was requested and declined.", "We will defer the requested work and keep the installation operating with what we have on hand.", "No additional allocation has been authorized. Local staff will continue the repair effort and adjust operations as necessary.")

	var/relationship = get_installation_trust_label(installation)

	switch(relationship)
		if("TRUSTED")
			return "I wanted to answer you directly rather than leave this to the automated record. The denial regarding '[request_title]' came through. [base_body] We'll keep your office informed if the situation materially changes."
		if("COOPERATIVE")
			return "Your response regarding '[request_title]' was received. [base_body] We will forward another update if circumstances change."
		if("GUARDED")
			return "Decision logged regarding '[request_title]'. [base_body] Further correspondence will be limited to operationally relevant changes."
		if("STRAINED")
			return "For mandatory record, Liaison denial of '[request_title]' has been logged. [base_body] Local personnel will proceed without assuming further discretionary support."

	return "Denial received regarding '[request_title]'. [base_body]"


/datum/ccpost_sector_network/proc/issue_denial_followup(installation_code, request_title, denied_status)
	var/datum/ccpost_sector_installation/installation = get_installation_by_code(installation_code)

	if(!installation || installation.destroyed)
		return

	var/followup_priority = "Routine"

	// Match the follow-up priority to the installation's condition when the
	// response is actually sent. A denial made during a lesser incident can
	// therefore become a Priority or Important transmission if conditions worsen.
	if(is_installation_green(installation))
		followup_priority = "Routine"

	else if(denied_status == "CRITICAL" || installation.status == "CRITICAL")
		followup_priority = "Important"

	else if(denied_status == "NO CONTACT" || denied_status == "OFFLINE" || denied_status == "COMMUNICATIONS DEGRADED" || installation.status == "NO CONTACT" || installation.status == "OFFLINE" || installation.status == "COMMUNICATIONS DEGRADED")
		followup_priority = "Priority"

	var/list/followup_template = list(
		"id" = "aid_denial_followup",
		"type" = "UPDATE",
		"priority" = followup_priority,
		"title" = "Assistance Denial Acknowledged",
		"body" = get_denial_followup_body(installation, request_title, denied_status),
		"required_statuses" = list()
	)

	var/datum/ccpost_sector_message/followup_message = create_sector_message(installation, followup_template)

	if(followup_message)
		notify_comms_terminals(followup_message)


/datum/ccpost_sector_network/proc/get_installation_aid_request_chance(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return 0

	switch(installation.status)
		if("MAINTENANCE")
			return 35

		if("UNDER REVIEW")
			return 25

		if("COMMUNICATIONS DEGRADED")
			return 55

		if("NO CONTACT")
			// Represents a buffered or emergency-burst transmission that was
			// queued immediately before normal contact was lost.
			return 40

		if("OFFLINE")
			return 70

		if("CRITICAL")
			return 90

	return 0


/datum/ccpost_sector_network/proc/maybe_issue_installation_aid_request(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return FALSE

	if(is_installation_green(installation))
		return FALSE

	if(has_pending_sector_request_for_installation(installation.installation_code))
		return FALSE

	var/aid_chance = get_installation_aid_request_chance(installation)

	if(aid_chance <= 0 || !prob(aid_chance))
		return FALSE

	var/list/eligible_aid_templates = list()

	for(var/list/template as anything in sector_message_templates)
		if(!template["reactive_aid"])
			continue

		if(template["installation_code"] != installation.installation_code)
			continue

		if(has_pending_sector_message_template(template["id"]))
			continue

		var/list/required_statuses = template["required_statuses"]

		if(length(required_statuses))
			if(!(installation.status in required_statuses))
				continue

		eligible_aid_templates += list(template)

	if(!length(eligible_aid_templates))
		return FALSE

	var/list/chosen_template = pick(eligible_aid_templates)
	var/datum/ccpost_sector_message/new_message = create_sector_message(installation, chosen_template)

	if(!new_message)
		return FALSE

	notify_comms_terminals(new_message)

	return TRUE


/datum/ccpost_sector_network/proc/create_sector_message(
	datum/ccpost_sector_installation/installation,
	list/template
)
	if(!installation || !template)
		return null

	var/message_code = "CC-SC-[next_sector_message_number]"

	next_sector_message_number++

	// CRITICAL aid requests use the actual active incident rather than the
	// installation's generic emergency request text. Work from a copy so the
	// static template is never modified for later messages.
	var/list/effective_template = template
	var/list/required_statuses = template["required_statuses"]

	if(installation.status == "CRITICAL" && template["reactive_aid"] && length(required_statuses) && ("CRITICAL" in required_statuses))
		effective_template = template.Copy()
		effective_template["body"] = get_critical_aid_request_body(installation)

	var/datum/ccpost_sector_message/new_message = new(
		message_code,
		installation,
		effective_template
	)

	sector_messages.Insert(1, new_message)

	if(length(sector_messages) > max_sector_messages)
		var/removal_index = 0

		// Preserve unresolved transmissions. Remove the oldest resolved
		// message instead so an unanswered request is never silently lost.
		for(var/index in 1 to length(sector_messages))
			var/datum/ccpost_sector_message/archive_message = sector_messages[index]

			if(QDELETED(archive_message))
				continue

			if(archive_message.resolution_status != "PENDING")
				removal_index = index

		if(removal_index)
			var/datum/ccpost_sector_message/oldest_resolved_message = sector_messages[removal_index]

			sector_messages.Cut(
				removal_index,
				removal_index + 1
			)

			qdel(oldest_resolved_message)

	return new_message

/datum/ccpost_sector_network/proc/issue_sector_message()
	sector_message_timer = null

	var/list/eligible_templates = get_eligible_sector_message_templates()

	if(!length(eligible_templates))
		schedule_next_sector_message()
		return

	var/list/candidates = eligible_templates.Copy()
	var/list/fresh_candidates = list()

	// Prefer templates which have not appeared in the recent rolling history.
	// If current installation states leave no fresh alternatives, fall back to
	// the full eligible pool so communications never stall.
	for(var/list/template as anything in candidates)
		if(template["id"] in recent_sector_message_template_ids)
			continue

		fresh_candidates += list(template)

	if(length(fresh_candidates))
		candidates = fresh_candidates
	else if(length(candidates) > 1 && last_sector_message_template_id)
		for(var/list/template as anything in candidates)
			if(template["id"] != last_sector_message_template_id)
				continue

			candidates.Remove(template)
			break

	var/list/chosen_template = pick(candidates)
	var/chosen_template_id = chosen_template["id"]

	last_sector_message_template_id = chosen_template_id
	recent_sector_message_template_ids.Insert(1, chosen_template_id)

	if(length(recent_sector_message_template_ids) > max_recent_sector_message_templates)
		recent_sector_message_template_ids.Cut(max_recent_sector_message_templates + 1)

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		chosen_template["installation_code"]
	)

	if(!installation)
		schedule_next_sector_message()
		return

	var/datum/ccpost_sector_message/new_message = create_sector_message(
		installation,
		chosen_template
	)

	notify_comms_terminals(new_message)
	maybe_start_installation_followup(new_message)

	schedule_next_sector_message()


/datum/ccpost_sector_network/proc/find_sector_message(message_code)
	if(!message_code)
		return null

	for(var/datum/ccpost_sector_message/message as anything in sector_messages)
		if(QDELETED(message))
			continue

		if(message.message_code == message_code)
			return message

	return null


/datum/ccpost_sector_network/proc/sector_message_still_valid(
	datum/ccpost_sector_message/message
)
	if(!message)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		message.installation_code
	)

	if(!installation || installation.destroyed)
		return FALSE

	if(length(message.valid_statuses))
		if(!(installation.status in message.valid_statuses))
			return FALSE

	return TRUE


/datum/ccpost_sector_network/proc/apply_authorized_sector_request(
	datum/ccpost_sector_message/message
)
	if(!message)
		return FALSE

	var/datum/ccpost_sector_installation/installation = get_installation_by_code(
		message.installation_code
	)

	if(!installation || installation.destroyed)
		return FALSE

	// Once assistance is actually authorized, the unresolved risk created by
	// previous refusals is considered addressed. Historical denial count remains.
	installation.aid_denial_risk = 0

	// Critical assistance is support, not an instant resolution. The installation
	// remains CRITICAL and the original incident stays active until the later
	// Critical recovery roll determines whether the installation survives.
	if(installation.status == "CRITICAL" && ("CRITICAL" in message.valid_statuses))
		installation.critical_aid_authorized = TRUE
		installation.critical_aid_authorized_by = message.responded_by
		installation.critical_aid_authorized_at = station_time_timestamp()
		installation.critical_aid_denied = FALSE
		installation.critical_aid_denied_by = null
		installation.critical_aid_denied_at = null

		if(installation.ert_dispatched)
			installation.response_status = "ERT + LIAISON AID"
		else
			installation.response_status = "LIAISON AID AUTHORIZED"

		var/critical_aid_details = get_critical_aid_authorization_details(installation)

		if(critical_aid_details)
			installation.condition_details = "[critical_aid_details] The wider critical incident remains unresolved."
		else if(message.success_details)
			installation.condition_details = "[message.success_details] The wider critical incident remains unresolved."
		else
			installation.condition_details = "Emergency Central Command resources have been authorized. The wider critical incident remains unresolved."

		if(installation.ert_dispatched)
			installation.condition_details += " Emergency Response Team operations are also active."
		else
			installation.condition_details += " Local personnel remain responsible for containing the incident."

		message.response = "Emergency assistance authorized. Installation remains CRITICAL pending incident resolution."

		notify_registered_displays(
			null,
			FALSE,
			30,
			"chimes. Emergency Liaison assistance has been authorized for a critical sector installation."
		)

		return TRUE

	// Non-Critical assistance retains its existing immediate operational effect.
	if(message.success_status)
		installation.status = message.success_status
		installation.status_since = station_time_timestamp()

		apply_installation_status_metadata(installation)

	if(message.success_details)
		installation.condition_details = message.success_details

	validate_active_sector_paperwork()

	// A post-Critical incident remains on the record until the installation
	// actually returns to green operation, even if later routine aid is approved.
	if(installation.critical_aftermath_active)
		if(is_installation_green(installation))
			clear_critical_aftermath(installation)
	else
		installation.incident_summary = "No active incident."

	notify_registered_displays(
		null,
		FALSE,
		25,
		"chimes. Sector installation telemetry has been updated following Liaison authorization."
	)

	return TRUE

// SECTOR COMMUNICATIONS ARCHIVE MANAGEMENT

/// Removes resolved communications while preserving every unresolved inbox
/// transmission. Returns the number of archived records cleared.
/datum/ccpost_sector_network/proc/clear_resolved_sector_messages()
	var/cleared_count = 0
	var/index = length(sector_messages)

	while(index >= 1)
		var/datum/ccpost_sector_message/message = sector_messages[index]

		if(QDELETED(message))
			sector_messages.Cut(index, index + 1)
			index--
			continue

		if(message.resolution_status != "PENDING")
			sector_messages.Cut(index, index + 1)
			qdel(message)
			cleared_count++

		index--

	refresh_comms_terminals()

	return cleared_count


// CENTRAL COMMAND SECTOR COMMUNICATIONS TERMINAL CIRCUIT BOARD

/obj/item/circuitboard/computer/ccpost_sector_comms
	name = "Central Command Sector Communications Terminal"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/ccpost_sector_comms


// CENTRAL COMMAND SECTOR COMMUNICATIONS TERMINAL

/obj/machinery/computer/ccpost_sector_comms
	name = "Central Command sector communications terminal"
	desc = "A secure Central Command terminal used to receive and respond to authenticated communications and administrative paperwork from remote Nanotrasen installations."

	icon_screen = "comm_logs"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_GREEN

	circuit = /obj/item/circuitboard/computer/ccpost_sector_comms

	/// Single physical slot used for the one active administrative document.
	var/obj/item/paper/ccpost_sector_paperwork/submitted_paperwork

	COOLDOWN_DECLARE(paperwork_print_cooldown)


/obj/machinery/computer/ccpost_sector_comms/Initialize(mapload)
	. = ..()

	GLOB.ccpost_sector_network.register_comms_terminal(src)


/obj/machinery/computer/ccpost_sector_comms/Destroy()
	if(submitted_paperwork)
		eject_sector_paperwork()

	GLOB.ccpost_sector_network.unregister_comms_terminal(src)

	return ..()



// ADMINISTRATIVE PAPERWORK SLOT

/obj/machinery/computer/ccpost_sector_comms/item_interaction(
	mob/living/user,
	obj/item/tool,
	list/modifiers
)
	if(!istype(tool, /obj/item/paper/ccpost_sector_paperwork))
		return NONE

	var/obj/item/paper/ccpost_sector_paperwork/paperwork = tool

	if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork())
		balloon_alert(user, "no active paperwork request")
		return ITEM_INTERACT_BLOCKING

	var/datum/ccpost_sector_paperwork_request/request = GLOB.ccpost_sector_network.active_sector_paperwork

	if(!request || request.status != "AWAITING LIAISON REVIEW")
		balloon_alert(user, "document no longer accepted")
		return ITEM_INTERACT_BLOCKING

	if(paperwork.paperwork_code != request.paperwork_code)
		balloon_alert(user, "document does not match active request")
		return ITEM_INTERACT_BLOCKING

	if(submitted_paperwork)
		balloon_alert(user, "document slot occupied")
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(paperwork, src))
		balloon_alert(user, "unable to insert document")
		return ITEM_INTERACT_BLOCKING

	submitted_paperwork = paperwork

	playsound(src, 'sound/machines/terminal_alert.ogg', vol = 20, vary = TRUE)
	balloon_alert(user, "document inserted")
	SStgui.update_uis(src)

	return ITEM_INTERACT_SUCCESS


/obj/machinery/computer/ccpost_sector_comms/proc/eject_sector_paperwork(mob/living/user)
	if(!submitted_paperwork)
		return FALSE

	var/obj/item/paper/ccpost_sector_paperwork/ejected_paperwork = submitted_paperwork
	submitted_paperwork = null

	ejected_paperwork.forceMove(drop_location())

	if(user)
		user.put_in_hands(ejected_paperwork)

	SStgui.update_uis(src)
	return TRUE


/obj/machinery/computer/ccpost_sector_comms/proc/paperwork_has_centcom_stamp(obj/item/paper/ccpost_sector_paperwork/paperwork)
	if(!paperwork)
		return FALSE

	var/datum/asset/spritesheet/sheet = get_asset_datum(
		/datum/asset/spritesheet/simple/paper
	)

	var/centcom_stamp_class = sheet.icon_class_name("stamp-centcom")

	for(var/datum/paper_stamp/stamp as anything in paperwork.raw_stamp_data)
		if(stamp.class == centcom_stamp_class)
			return TRUE

	return FALSE


/obj/machinery/computer/ccpost_sector_comms/proc/build_sector_paperwork_print_text(datum/ccpost_sector_paperwork_request/request)
	if(!request)
		return ""

	var/print_text = "<center><b>[request.installation_name]</b></center><br>"
	print_text += "<center><small><i>Authenticated Sector Administrative Document</i></small></center><hr><hr><small>"
	print_text += "<b>Reference:</b> [request.paperwork_code]<br>"
	print_text += "<b>Installation:</b> [request.installation_name] ([request.installation_code])<br>"
	print_text += "<b>Sender:</b> [request.sender_role] [request.sender_name]<br>"
	print_text += "<b>Type:</b> ADMINISTRATIVE DOCUMENT<br>"
	print_text += "<b>Priority:</b> [request.priority]<br>"
	print_text += "<b>Issued:</b> [request.issued_at]<br>"
	print_text += "<hr><br>"
	print_text += "<b>[request.title]</b><br><br>"
	print_text += "[request.body]<br><br>"
	print_text += "<hr>"
	print_text += "<b>Required Action:</b> Review this document, apply an official Central Command authorization stamp, and return it through the Sector Communications Terminal.<br><br>"
	print_text += "<i>Machine reference: [request.paperwork_code]</i></small>"

	return print_text


/obj/machinery/computer/ccpost_sector_comms/proc/print_sector_paperwork(datum/ccpost_sector_paperwork_request/request)
	if(!request || request.status != "AWAITING LIAISON REVIEW")
		return FALSE

	var/obj/item/paper/ccpost_sector_paperwork/paperwork = new /obj/item/paper/ccpost_sector_paperwork(
		drop_location()
	)

	paperwork.paperwork_code = request.paperwork_code
	paperwork.name = "administrative document [request.paperwork_code]"
	paperwork.add_raw_text(build_sector_paperwork_print_text(request))
	paperwork.update_appearance()

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice("[src] prints an incoming sector administrative document."))

	return TRUE


/obj/machinery/computer/ccpost_sector_comms/proc/paperwork_to_ui_data()
	if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork(FALSE))
		return null

	var/datum/ccpost_sector_paperwork_request/request = GLOB.ccpost_sector_network.active_sector_paperwork

	if(!request)
		return null

	var/datum/ccpost_sector_installation/installation = GLOB.ccpost_sector_network.get_installation_by_code(
		request.installation_code
	)

	if(!GLOB.ccpost_sector_network.can_issue_sector_paperwork(installation))
		return null

	return list(
		"paperwork_code" = request.paperwork_code,
		"installation_code" = request.installation_code,
		"installation_name" = request.installation_name,
		"installation_status" = installation.status,
		"installation_trust_label" = GLOB.ccpost_sector_network.get_installation_trust_label(installation),
		"sender_name" = request.sender_name,
		"sender_role" = request.sender_role,
		"type" = "ADMINISTRATIVE DOCUMENT",
		"priority" = request.priority,
		"title" = request.title,
		"body" = request.body,
		"issued_at" = request.issued_at,
		"status" = request.status,
		"submitted_by" = request.submitted_by,
		"submitted_at" = request.submitted_at,
		"allocation_reward" = request.allocation_reward,
		"document_inserted" = submitted_paperwork ? TRUE : FALSE,
		"document_name" = submitted_paperwork?.name,
		"stamp_verified" = paperwork_has_centcom_stamp(submitted_paperwork)
	)


/obj/machinery/computer/ccpost_sector_comms/ui_interact(
	mob/user,
	datum/tgui/ui
)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(
			user,
			src,
			"CCPostSectorComms",
			name
		)

		ui.open()


/// Builds a printable Central Command record for a single communication.
/obj/machinery/computer/ccpost_sector_comms/proc/build_sector_message_print_text(datum/ccpost_sector_message/message)
	if(!message)
		return ""

	var/response_text = "No recorded response."
	var/responded_by = "N/A"
	var/responded_at = "N/A"

	if(message.response)
		response_text = message.response

	if(message.responded_by)
		responded_by = message.responded_by

	if(message.responded_at)
		responded_at = message.responded_at

	var/print_text = "<center><b>Central Command Sector Communications Record</b></center><br>"
	print_text += "<hr>"
	print_text += "<b>Reference:</b> [message.message_code]<br>"
	print_text += "<b>Installation:</b> [message.installation_name] ([message.installation_code])<br>"
	print_text += "<b>Sender:</b> [message.sender_role] [message.sender_name]<br>"
	print_text += "<b>Type:</b> [message.message_type]<br>"
	print_text += "<b>Priority:</b> [message.priority]<br>"
	print_text += "<b>Issued:</b> [message.issued_at]<br>"
	print_text += "<b>Resolution:</b> [message.resolution_status]<br>"
	print_text += "<b>Responded By:</b> [responded_by]<br>"
	print_text += "<b>Responded At:</b> [responded_at]<br>"

	if(message.allocation_cost > 0)
		print_text += "<b>Requested Allocation:</b> [message.allocation_cost] CU<br>"

	if(message.allocation_reward > 0)
		print_text += "<b>Offered Transfer:</b> [message.allocation_reward] CU<br>"

	if(message.allocation_change)
		print_text += "<b>Recorded Liaison Allocation Change:</b> [message.allocation_change] CU<br>"

	print_text += "<hr>"
	print_text += "<b>[message.title]</b><br><br>"
	print_text += "[message.body]<br><br>"
	print_text += "<hr>"
	print_text += "<b>Recorded Response:</b> [response_text]<br>"
	print_text += "<hr>"
	print_text += "<small><i>Central Command Sector Liaison Communications Archive</i></small>"

	return print_text


/obj/machinery/computer/ccpost_sector_comms/proc/print_sector_message_record(datum/ccpost_sector_message/message)
	if(!message || message.resolution_status == "PENDING")
		return FALSE

	var/obj/item/paper/record = new /obj/item/paper(get_turf(src))
	record.name = "sector communication [message.message_code]"
	record.add_raw_text(build_sector_message_print_text(message))
	record.update_appearance()

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice("[src] prints a Central Command sector communications record."))

	return TRUE


/// Prints the entire resolved communications archive in manageable batches.
/obj/machinery/computer/ccpost_sector_comms/proc/print_sector_archive()
	var/list/archive_messages = list()

	for(var/datum/ccpost_sector_message/message as anything in GLOB.ccpost_sector_network.sector_messages)
		if(QDELETED(message) || message.resolution_status == "PENDING")
			continue

		archive_messages += message

	if(!length(archive_messages))
		return 0

	var/messages_per_page = 10
	var/page_number = 1
	var/page_message_count = 0
	var/page_text = "<center><b>Central Command Sector Communications Archive</b></center><br><hr>"
	var/printed_pages = 0

	for(var/datum/ccpost_sector_message/message as anything in archive_messages)
		if(page_message_count >= messages_per_page)
			var/obj/item/paper/archive_page = new /obj/item/paper(get_turf(src))
			archive_page.name = "sector communications archive page [page_number]"
			archive_page.add_raw_text(page_text)
			archive_page.update_appearance()

			printed_pages++
			page_number++
			page_message_count = 0
			page_text = "<center><b>Central Command Sector Communications Archive</b></center><br><hr>"

		page_text += build_sector_message_print_text(message)
		page_text += "<br><br>"
		page_message_count++

	if(page_message_count > 0)
		var/obj/item/paper/final_archive_page = new /obj/item/paper(get_turf(src))
		final_archive_page.name = "sector communications archive page [page_number]"
		final_archive_page.add_raw_text(page_text)
		final_archive_page.update_appearance()
		printed_pages++

	if(printed_pages > 0)
		playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
		visible_message(span_notice("[src] prints a Central Command sector communications archive."))

	return printed_pages


/obj/machinery/computer/ccpost_sector_comms/proc/message_to_ui_data(
	datum/ccpost_sector_message/message
)
	if(!message)
		return null

	var/datum/ccpost_sector_installation/installation = GLOB.ccpost_sector_network.get_installation_by_code(
		message.installation_code
	)

	var/current_status = "UNKNOWN"
	var/current_trust_label = "UNKNOWN"

	if(installation)
		current_status = installation.status
		current_trust_label = GLOB.ccpost_sector_network.get_installation_trust_label(installation)

	return list(
		"message_code" = message.message_code,
		"installation_code" = message.installation_code,
		"installation_name" = message.installation_name,
		"installation_status" = current_status,
		"installation_trust_label" = current_trust_label,

		"sender_name" = message.sender_name,
		"sender_role" = message.sender_role,

		"message_type" = message.message_type,
		"priority" = message.priority,
		"title" = message.title,
		"body" = message.body,
		"issued_at" = message.issued_at,

		"resolution_status" = message.resolution_status,

		"responded_by" = message.responded_by,
		"responded_at" = message.responded_at,
		"response" = message.response,

		"allocation_cost" = message.allocation_cost,
		"allocation_reward" = message.allocation_reward,
		"allocation_change" = message.allocation_change
	)


/obj/machinery/computer/ccpost_sector_comms/ui_data(mob/user)
	GLOB.ccpost_sector_network.ensure_started()

	var/list/data = list()

	var/datum/ccpost_logistics_network/logistics_network = GLOB.ccpost_logistics_network

	if(logistics_network)
		data["allocation"] = logistics_network.allocation
		data["available_allocation"] = logistics_network.get_available_allocation()
		data["max_allocation"] = logistics_network.max_allocation

	else
		data["allocation"] = 0
		data["available_allocation"] = 0
		data["max_allocation"] = 0

	var/list/inbox_data = list()
	var/list/archive_data = list()

	for(var/datum/ccpost_sector_message/message as anything in GLOB.ccpost_sector_network.sector_messages)
		if(QDELETED(message))
			continue

		var/list/message_data = message_to_ui_data(message)

		if(message.resolution_status == "PENDING")
			inbox_data += list(message_data)

		else
			archive_data += list(message_data)

	data["inbox"] = inbox_data
	data["archive"] = archive_data
	data["archive_count"] = length(archive_data)
	data["paperwork"] = paperwork_to_ui_data()

	return data


/obj/machinery/computer/ccpost_sector_comms/ui_act(
	action,
	list/params,
	datum/tgui/ui,
	datum/ui_state/state
)
	. = ..()

	if(.)
		return

	var/mob/user = ui.user

	// Archive-wide controls do not target an individual transmission.
	switch(action)
		if("print_archive")
			var/printed_pages = print_sector_archive()
			if(printed_pages <= 0)
				balloon_alert(user, "archive is empty")
			else
				balloon_alert(user, "[printed_pages] archive pages printed")
			return TRUE

		if("clear_archive")
			var/cleared_count = GLOB.ccpost_sector_network.clear_resolved_sector_messages()
			if(cleared_count <= 0)
				balloon_alert(user, "archive is empty")
			else
				balloon_alert(user, "[cleared_count] records cleared")
			return TRUE

		if("reprint_paperwork")
			if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork())
				balloon_alert(user, "no active paperwork request")
				return TRUE

			var/datum/ccpost_sector_paperwork_request/reprint_request = GLOB.ccpost_sector_network.active_sector_paperwork

			if(reprint_request.status != "AWAITING LIAISON REVIEW")
				balloon_alert(user, "document already transmitted")
				return TRUE

			if(submitted_paperwork)
				balloon_alert(user, "document slot occupied")
				return TRUE

			if(!COOLDOWN_FINISHED(src, paperwork_print_cooldown))
				balloon_alert(user, "printer cooling down")
				return TRUE

			COOLDOWN_START(src, paperwork_print_cooldown, 5 SECONDS)

			if(print_sector_paperwork(reprint_request))
				balloon_alert(user, "document reprinted")
			else
				balloon_alert(user, "unable to print document")

			return TRUE

		if("eject_paperwork")
			if(!eject_sector_paperwork(user))
				balloon_alert(user, "document slot empty")
			else
				balloon_alert(user, "document ejected")

			return TRUE

		if("transmit_paperwork")
			if(!GLOB.ccpost_sector_network.validate_active_sector_paperwork())
				balloon_alert(user, "paperwork request no longer valid")
				return TRUE

			var/datum/ccpost_sector_paperwork_request/transmit_request = GLOB.ccpost_sector_network.active_sector_paperwork

			if(!transmit_request || transmit_request.status != "AWAITING LIAISON REVIEW")
				balloon_alert(user, "document already transmitted")
				return TRUE

			if(!submitted_paperwork)
				balloon_alert(user, "insert document first")
				return TRUE

			if(submitted_paperwork.paperwork_code != transmit_request.paperwork_code)
				balloon_alert(user, "incorrect document inserted")
				return TRUE

			if(!paperwork_has_centcom_stamp(submitted_paperwork))
				balloon_alert(user, "CentCom stamp required")
				return TRUE

			var/obj/item/paper/ccpost_sector_paperwork/transmitted_document = submitted_paperwork
			submitted_paperwork = null

			transmit_request.status = "TRANSMITTED - AWAITING RECEIPT"
			transmit_request.submitted_by = user.name
			transmit_request.submitted_at = station_time_timestamp()

			qdel(transmitted_document)

			playsound(src, 'sound/machines/terminal_alert.ogg', vol = 30, vary = TRUE)
			balloon_alert(user, "document transmitted")
			say("Administrative document [transmit_request.paperwork_code] transmitted. Awaiting receiving-installation confirmation.")

			addtimer(CALLBACK(GLOB.ccpost_sector_network, TYPE_PROC_REF(/datum/ccpost_sector_network, complete_sector_paperwork), transmit_request.paperwork_code), rand(20 SECONDS, 45 SECONDS))

			GLOB.ccpost_sector_network.refresh_comms_terminals()
			return TRUE

	var/message_code = params["message_code"]
	var/datum/ccpost_sector_message/message = GLOB.ccpost_sector_network.find_sector_message(message_code)

	if(!message)
		balloon_alert(user, "transmission not found")
		return TRUE

	// Archived messages may be printed individually, but cannot be acted upon.
	if(action == "print_message")
		if(message.resolution_status == "PENDING")
			balloon_alert(user, "resolve transmission first")
			return TRUE

		if(print_sector_message_record(message))
			balloon_alert(user, "record printed")
		else
			balloon_alert(user, "unable to print record")
		return TRUE

	if(message.resolution_status != "PENDING")
		balloon_alert(user, "transmission already resolved")
		return TRUE

	switch(action)
		if("acknowledge")
			if(message.message_type != "UPDATE")
				return TRUE

			var/acknowledgement_response = "Transmission acknowledged."

			if(message.allocation_reward > 0)
				var/datum/ccpost_sector_installation/reward_installation = GLOB.ccpost_sector_network.get_installation_by_code(message.installation_code)

				if(!GLOB.ccpost_sector_network.is_installation_green(reward_installation))
					message.resolution_status = "EXPIRED"
					message.responded_by = "SYSTEM"
					message.responded_at = station_time_timestamp()
					message.response = "Sector transfer withdrawn after the installation left green operational status."
					GLOB.ccpost_sector_network.refresh_comms_terminals()
					balloon_alert(user, "transfer withdrawn")
					return TRUE

				var/credited_amount = GLOB.ccpost_logistics_network.credit_allocation(
					message.allocation_reward,
					"Sector transfer [message.message_code]: [message.installation_name]",
					message.sender_name
				)

				message.allocation_change = credited_amount
				GLOB.ccpost_logistics_network.refresh_logistics_outputs()

				var/rerouted_amount = message.allocation_reward - credited_amount

				if(rerouted_amount > 0)
					var/datum/ccpost_sector_installation/reroute_recipient = GLOB.ccpost_sector_network.get_allocation_reroute_recipient(message.installation_code)

					if(reroute_recipient)
						if(credited_amount > 0)
							acknowledgement_response = "[credited_amount] CU was credited to Liaison Operational Allocation. The remaining [rerouted_amount] CU exceeded local capacity and was rerouted to [reroute_recipient.installation_name] ([reroute_recipient.installation_code]) for local operational use."
							balloon_alert(user, "[credited_amount] CU received; remainder rerouted")
						else
							acknowledgement_response = "Liaison Operational Allocation is at maximum capacity. The full [rerouted_amount] CU transfer was rerouted to [reroute_recipient.installation_name] ([reroute_recipient.installation_code]) for local operational use."
							balloon_alert(user, "transfer rerouted")

					else
						if(credited_amount > 0)
							acknowledgement_response = "[credited_amount] CU was credited to Liaison Operational Allocation. The remaining [rerouted_amount] CU could not be placed with another surviving sector installation and was returned to Sector Accounting."
							balloon_alert(user, "[credited_amount] CU received")
						else
							acknowledgement_response = "Liaison Operational Allocation is at maximum capacity. No alternate surviving sector installation was available, so the [rerouted_amount] CU transfer was returned to Sector Accounting."
							balloon_alert(user, "allocation at capacity")

				else if(credited_amount > 0)
					acknowledgement_response = "Sector transfer acknowledged. [credited_amount] CU was credited to Liaison Operational Allocation."
					balloon_alert(user, "[credited_amount] CU received")

			message.resolution_status = "ACKNOWLEDGED"
			message.responded_by = user.name
			message.responded_at = station_time_timestamp()
			message.response = acknowledgement_response
			GLOB.ccpost_sector_network.refresh_comms_terminals()
			return TRUE

		if("authorize")
			if(message.message_type != "REQUEST")
				return TRUE

			if(!GLOB.ccpost_sector_network.sector_message_still_valid(message))
				message.resolution_status = "EXPIRED"
				message.responded_by = "SYSTEM"
				message.responded_at = station_time_timestamp()
				message.response = "Installation conditions changed before authorization could be processed."
				GLOB.ccpost_sector_network.refresh_comms_terminals()
				balloon_alert(user, "request no longer applicable")
				return TRUE

			if(message.allocation_cost > 0)
				if(!GLOB.ccpost_logistics_network.spend_allocation(message.allocation_cost, "Sector assistance [message.message_code]: [message.installation_name]", user.name))
					balloon_alert(user, "insufficient allocation")
					return TRUE

				message.allocation_change = -message.allocation_cost
				GLOB.ccpost_logistics_network.refresh_logistics_outputs()

			message.resolution_status = "AUTHORIZED"
			message.responded_by = user.name
			message.responded_at = station_time_timestamp()
			message.response = "Requested operational assistance authorized."

			var/datum/ccpost_sector_installation/authorized_installation = GLOB.ccpost_sector_network.get_installation_by_code(message.installation_code)
			var/authorized_critical = authorized_installation?.status == "CRITICAL"

			if(GLOB.ccpost_sector_network.apply_authorized_sector_request(message) && authorized_installation)
				var/trust_gain = authorized_critical ? 8 : 4
				GLOB.ccpost_sector_network.adjust_installation_trust(
					authorized_installation,
					trust_gain,
					"LIAISON ACTION",
					"Assistance authorized: [message.title]",
					"[user.name] authorized [message.allocation_cost] CU of requested operational assistance. The decision was recorded by [message.sender_role] [message.sender_name]."
				)

			GLOB.ccpost_sector_network.refresh_comms_terminals()
			balloon_alert(user, "request authorized")
			return TRUE

		if("deny")
			if(message.message_type != "REQUEST")
				return TRUE

			message.resolution_status = "DENIED"
			message.responded_by = user.name
			message.responded_at = station_time_timestamp()
			message.response = "Requested operational assistance denied."

			var/datum/ccpost_sector_installation/denied_installation = GLOB.ccpost_sector_network.get_installation_by_code(message.installation_code)

			if(denied_installation && message.allocation_cost > 0)
				var/denied_critical = denied_installation.status == "CRITICAL"
				GLOB.ccpost_sector_network.register_aid_denial(denied_installation, message, user)
				GLOB.ccpost_sector_network.adjust_installation_trust(
					denied_installation,
					denied_critical ? -10 : -6,
					"LIAISON ACTION",
					"Assistance denied: [message.title]",
					"[user.name] denied [message.allocation_cost] CU of requested operational assistance. The denial remains part of the installation's Liaison record."
				)

			GLOB.ccpost_sector_network.refresh_comms_terminals()
			balloon_alert(user, "request denied")
			return TRUE

	return FALSE

// DISPLAY NOTIFICATIONS

/datum/ccpost_sector_network/proc/notify_registered_displays(spoken_message = null, urgent = FALSE, sound_volume = 0, physical_message = null)
	for(var/obj/machinery/status_display/ccpost_remote_status/display as anything in registered_displays)
		if(QDELETED(display))
			continue

		SStgui.update_uis(display)

		if(display.machine_stat & (NOPOWER | BROKEN))
			continue

		if(sound_volume > 0)
			playsound(display, 'sound/machines/terminal_alert.ogg', vol = sound_volume, vary = !urgent)

		if(physical_message)
			if(urgent)
				display.visible_message(span_warning("[display] [physical_message]"))
			else
				display.visible_message(span_notice("[display] [physical_message]"))

		if(spoken_message)
			display.say(spoken_message)

// SECTOR NOTICE HANDLING

/datum/ccpost_sector_network/proc/is_medical_supply_recall_active()
	for(var/datum/ccpost_sector_notice/notice as anything in sector_notices)
		if(QDELETED(notice))
			continue

		if(!notice.blocks_medical_supplies)
			continue

		if(notice.has_active_logistics_effect())
			return TRUE

	return FALSE


/datum/ccpost_sector_network/proc/apply_sector_notice_installation_effects(datum/ccpost_sector_notice/notice)
	if(!notice)
		return

	if(notice.template_id != "medical_batch_recall")
		return

	var/datum/ccpost_sector_installation/medical_center = get_installation_by_code("NT-MED-M12")

	if(!medical_center || medical_center.destroyed)
		return

	if(!medical_supply_recall_was_active)
		add_installation_history(
			medical_center,
			"MEDICAL LOGISTICS",
			"Medical Supply Recall Issued",
			"Central Medical Logistics issued a sector medical-supply recall. Routine medical resupply is suspended while M-12 quarantines affected stock and validates outgoing inventory."
		)

	medical_supply_recall_was_active = TRUE

	// A recall places an otherwise functioning distribution center under review.
	// More serious existing states are never overwritten by the recall.
	if(is_installation_green(medical_center) || medical_center.status == "MAINTENANCE")
		medical_center.status = "UNDER REVIEW"
		medical_center.status_since = station_time_timestamp()
		apply_installation_status_metadata(medical_center)

	if(medical_center.status != "CRITICAL" && medical_center.status != "NO CONTACT" && medical_center.status != "OFFLINE")
		medical_center.condition_details = "Central Medical Logistics has placed affected supply batches under recall. M-12 is quarantining stock and validating outgoing inventory."
		medical_center.incident_summary = "An active sector medical-supply batch recall is being coordinated through M-12."

	notify_registered_displays(null, FALSE, 25, "chimes. Medical Distribution Center M-12 has entered recall review procedures.")


/datum/ccpost_sector_network/proc/refresh_notice_dependent_systems()
	if(GLOB.ccpost_logistics_network)
		GLOB.ccpost_logistics_network.refresh_logistics_outputs()

	var/recall_active = is_medical_supply_recall_active()
	var/datum/ccpost_sector_installation/medical_center = get_installation_by_code("NT-MED-M12")

	if(recall_active)
		medical_supply_recall_was_active = TRUE

	// Record the end of the continuous recall window exactly once, even if M-12
	// changed operational state while the recall was active.
	else if(medical_supply_recall_was_active)
		if(medical_center && !medical_center.destroyed)
			add_installation_history(
				medical_center,
				"MEDICAL LOGISTICS",
				"Medical Supply Recall Lifted",
				"Central Medical Logistics lifted the sector medical-supply recall. Normal medical distribution authorization has been restored."
			)

		medical_supply_recall_was_active = FALSE

	// Clear recall-specific display text after the final active recall expires.
	if(!recall_active && medical_center && !medical_center.destroyed && medical_center.status == "UNDER REVIEW")
		if(findtext(medical_center.incident_summary, "medical-supply batch recall"))
			apply_installation_status_metadata(medical_center)
			medical_center.incident_summary = "No active incident."

	notify_registered_displays()


/datum/ccpost_sector_network/proc/create_sector_notice(list/template)
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/notice_code = "CC-SN-[round_identifier]-[next_sector_notice_number]"

	next_sector_notice_number++

	var/datum/ccpost_sector_notice/new_notice = new(notice_code, template)

	sector_notices.Insert(1, new_notice)

	if(length(sector_notices) > max_sector_notices)
		var/datum/ccpost_sector_notice/oldest_notice = sector_notices[length(sector_notices)]

		sector_notices.Cut(
			length(sector_notices),
			length(sector_notices) + 1
		)

		qdel(oldest_notice)

	return new_notice

/datum/ccpost_sector_network/proc/schedule_next_sector_notice(minimum_delay = 10 MINUTES, maximum_delay = 18 MINUTES)
	if(sector_notice_timer)
		deltimer(sector_notice_timer)

	sector_notice_timer = addtimer(CALLBACK(src, PROC_REF(issue_sector_notice)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)


/datum/ccpost_sector_network/proc/issue_sector_notice(silent = FALSE)
	sector_notice_timer = null

	var/list/chosen_template = pick(sector_notice_templates)

	if(length(sector_notice_templates) > 1)
		while(chosen_template["id"] == last_sector_notice_id)
			chosen_template = pick(sector_notice_templates)

	last_sector_notice_id = chosen_template["id"]

	var/datum/ccpost_sector_notice/new_notice = create_sector_notice(chosen_template)

	apply_sector_notice_installation_effects(new_notice)

	if(GLOB.ccpost_logistics_network)
		GLOB.ccpost_logistics_network.refresh_logistics_outputs()

	if(new_notice && new_notice.logistics_effect_duration > 0)
		addtimer(CALLBACK(src, PROC_REF(refresh_notice_dependent_systems)), new_notice.logistics_effect_duration)

	if(silent)
		notify_registered_displays()
	else
		notify_registered_displays(
			null,
			FALSE,
			30,
			"emits a brief notification tone. A new Central Command sector notice has been received."
		)

	schedule_next_sector_notice()

// INSTALLATION INITIALIZATION

/datum/ccpost_sector_network/proc/initialize_sector_installations()
	if(length(sector_installations))
		return

	for(var/list/installation_template as anything in sector_installation_templates)
		var/datum/ccpost_sector_installation/new_installation = new(installation_template)

		apply_installation_status_metadata(new_installation)

		sector_installations += new_installation

/datum/ccpost_sector_network/proc/get_installation_by_code(installation_code)
	if(!installation_code)
		return null

	ensure_started()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(installation.installation_code == installation_code)
			return installation

	return null

// NORMAL INSTALLATION STATUS

/datum/ccpost_sector_network/proc/apply_installation_status_metadata(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	switch(installation.status)
		if("ONLINE", "ROUTINE OPERATIONS")
			installation.condition = "OPERATIONAL"
			installation.telemetry = "ACTIVE"
			installation.condition_details = "No structural concerns reported."

		if("MAINTENANCE")
			installation.condition = "OPERATIONAL"
			installation.telemetry = "ACTIVE"
			installation.condition_details = "Local maintenance activity is currently registered."

		if("UNDER REVIEW")
			installation.condition = "OPERATIONAL"
			installation.telemetry = "ACTIVE"
			installation.condition_details = "The installation is subject to an active Central Command administrative review."

		if("COMMUNICATIONS DEGRADED")
			installation.condition = "DEGRADED"
			installation.telemetry = "DEGRADED"
			installation.condition_details = "Intermittent telemetry and communications loss has been detected."

		if("NO CONTACT")
			installation.condition = "UNKNOWN"
			installation.telemetry = "SIGNAL LOST"
			installation.condition_details = "The installation is not responding to routine communications requests."

		if("OFFLINE")
			installation.condition = "NON-OPERATIONAL"
			installation.telemetry = "INACTIVE"
			installation.condition_details = "The installation is reporting an offline operational state."


/datum/ccpost_sector_network/proc/get_next_installation_status(datum/ccpost_sector_installation/installation)
	switch(installation.status)
		if("ONLINE")
			return pick("ONLINE", "ROUTINE OPERATIONS", "ROUTINE OPERATIONS", "MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED")

		if("ROUTINE OPERATIONS")
			return pick("ONLINE", "ROUTINE OPERATIONS", "ROUTINE OPERATIONS", "MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED")

		if("MAINTENANCE")
			return pick("ONLINE", "ROUTINE OPERATIONS", "MAINTENANCE", "COMMUNICATIONS DEGRADED", "OFFLINE")

		if("UNDER REVIEW")
			return pick("ONLINE", "ROUTINE OPERATIONS", "MAINTENANCE", "UNDER REVIEW", "COMMUNICATIONS DEGRADED")

		if("COMMUNICATIONS DEGRADED")
			return pick("ONLINE", "ROUTINE OPERATIONS", "COMMUNICATIONS DEGRADED", "NO CONTACT", "OFFLINE")

		if("NO CONTACT")
			return pick("ONLINE", "COMMUNICATIONS DEGRADED", "NO CONTACT", "OFFLINE")

		if("OFFLINE")
			return pick("ONLINE", "MAINTENANCE", "COMMUNICATIONS DEGRADED", "NO CONTACT", "OFFLINE")

	return "ROUTINE OPERATIONS"


/datum/ccpost_sector_network/proc/get_critical_chance(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return 0

	var/base_chance = 0

	switch(installation.status)
		if("ONLINE", "ROUTINE OPERATIONS")
			base_chance = 3

		if("MAINTENANCE", "UNDER REVIEW")
			base_chance = 8

		if("COMMUNICATIONS DEGRADED")
			base_chance = 30

		if("NO CONTACT")
			base_chance = 45

		if("OFFLINE")
			base_chance = 55

	if(base_chance <= 0)
		return 0

	return min(95, base_chance + installation.aid_denial_risk)

// NO CONTACT / OFFLINE NOTICES

/datum/ccpost_sector_network/proc/create_installation_status_notice(datum/ccpost_sector_installation/installation)
	var/list/status_template
	var/spoken_update

	if(installation.status == "NO CONTACT")
		status_template = list(
			"id" = "installation_no_contact_[installation.installation_code]",
			"category" = "Sector Operations",
			"source" = "Sector Network Operations",
			"priority" = "Advisory",
			"title" = "Communications Lost: [installation.installation_name]",
			"body" = "Routine communications with [installation.installation_name] ([installation.installation_code]) have been lost. Automated systems will continue attempting to re-establish contact. No emergency response has been authorized at this time."
		)

		spoken_update = "Sector advisory. Routine communications with [installation.installation_name] have been lost. Automated reconnection attempts are ongoing."

	else if(installation.status == "OFFLINE")
		status_template = list(
			"id" = "installation_offline_[installation.installation_code]",
			"category" = "Sector Operations",
			"source" = "Sector Network Operations",
			"priority" = "Advisory",
			"title" = "Installation Offline: [installation.installation_name]",
			"body" = "[installation.installation_name] ([installation.installation_code]) is presently reporting an offline operational state. Remote monitoring will continue pending restoration of normal systems."
		)

		spoken_update = "Sector advisory. [installation.installation_name] is reporting an offline operational state. Remote monitoring will continue."

	if(!status_template)
		return

	create_sector_notice(status_template)

	notify_registered_displays(
		spoken_update,
		FALSE,
		30,
		"emits a notification tone. A sector installation advisory has been received."
	)

// CRITICAL INSTALLATION STATE

/datum/ccpost_sector_network/proc/get_critical_incident_for_installation(datum/ccpost_sector_installation/installation)
	if(installation)
		var/list/installation_incidents = critical_incidents_by_installation[installation.installation_code]

		if(length(installation_incidents) && prob(70))
			return pick(installation_incidents)

	if(length(critical_incidents_common))
		return pick(critical_incidents_common)

	return "an unresolved station-wide security emergency"


/// Builds the urgent, incident-specific request used when a CRITICAL installation
/// asks the Liaison Outpost for Operational Allocation. The incident-specific
/// section explains what is actually happening; the final sentence reflects
/// whether an Emergency Response Team is already on the way.
/datum/ccpost_sector_network/proc/get_critical_aid_request_body(datum/ccpost_sector_installation/installation)
	if(!installation)
		return "Liaison, this installation is in a critical emergency. We need immediate Operational Allocation to keep essential systems and personnel alive."

	var/list/incident_data = get_critical_aftermath_data(installation)
	var/request_text

	if(islist(incident_data))
		request_text = incident_data["request"]

	if(!request_text)
		request_text = "Liaison, the installation is in a critical emergency and local personnel are losing the ability to contain it. We need immediate Operational Allocation for emergency continuity resources."

	if(installation.ert_dispatched)
		return "[request_text] Emergency Response Team deployment is confirmed. We need this allocation to hold the situation together until they can take over."

	return "[request_text] No Emergency Response Team has been assigned. If Central is not sending personnel, authorize the resources we need now or this installation may be lost before the next update."


/// Returns incident-specific Remarks text after the Liaison authorizes a CRITICAL
/// aid request. This describes what the CU is actually supporting without
/// implying that the underlying emergency has been resolved.
/datum/ccpost_sector_network/proc/get_critical_aid_authorization_details(datum/ccpost_sector_installation/installation)
	if(!installation)
		return null

	var/list/incident_data = get_critical_aftermath_data(installation)
	var/aid_details

	if(islist(incident_data))
		aid_details = incident_data["aid_details"]

	if(aid_details)
		return aid_details

	return "Emergency Central Command continuity resources have been committed to support local containment and preserve essential operations."


/// Returns the intended post-Critical status and remarks for the installation's
/// current incident. Every configured Critical incident has an explicit entry,
/// with a conservative fallback for future incidents added without metadata.
/datum/ccpost_sector_network/proc/get_critical_aftermath_data(datum/ccpost_sector_installation/installation)
	if(!installation)
		return null

	var/incident_text = installation.critical_incident_original

	if(!incident_text)
		incident_text = installation.incident_summary

	var/list/aftermath = critical_incident_aftermath[incident_text]

	if(islist(aftermath))
		return aftermath

	return list(
		"status" = "UNDER REVIEW",
		"details" = "The immediate critical incident has been contained. Central Command review and local recovery operations remain underway."
	)


/// Clears the retained record of a contained Critical incident once an
/// installation has genuinely returned to green operation.
/datum/ccpost_sector_network/proc/clear_critical_aftermath(datum/ccpost_sector_installation/installation)
	if(!installation)
		return

	if(installation.critical_aftermath_active)
		add_installation_history(
			installation,
			"OPERATIONS",
			"Critical incident record closed",
			"Post-incident recovery concluded after the installation returned to green operational status."
		)

	installation.critical_aftermath_active = FALSE
	installation.critical_incident_original = null

	installation.critical_aid_authorized = FALSE
	installation.critical_aid_authorized_by = null
	installation.critical_aid_authorized_at = null
	installation.critical_aid_denied = FALSE
	installation.critical_aid_denied_by = null
	installation.critical_aid_denied_at = null

	installation.ert_dispatched = FALSE
	installation.response_status = "NONE"
	installation.incident_summary = "No active incident."
	installation.aid_denial_risk = 0


/datum/ccpost_sector_network/proc/set_installation_critical(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	installation.status = "CRITICAL"
	clear_installation_followup(installation)
	expire_sector_paperwork_for_installation(installation, "Source installation entered CRITICAL status.")
	installation.condition = "CRITICAL"
	installation.telemetry = "EMERGENCY"

	installation.critical_incident_original = get_critical_incident_for_installation(installation)
	installation.incident_summary = installation.critical_incident_original
	installation.status_since = station_time_timestamp()

	// A new Critical incident begins with no Liaison emergency allocation
	// committed to it. Previous post-incident state is superseded.
	installation.critical_aid_authorized = FALSE
	installation.critical_aid_authorized_by = null
	installation.critical_aid_authorized_at = null
	installation.critical_aid_denied = FALSE
	installation.critical_aid_denied_by = null
	installation.critical_aid_denied_at = null
	installation.critical_aftermath_active = FALSE

	if(prob(65))
		installation.ert_dispatched = TRUE
		installation.response_status = "ERT DISPATCHED"
		installation.condition_details = "Emergency containment procedures are active. An Emergency Response Team has been dispatched while local personnel attempt to maintain essential operations."
	else
		installation.ert_dispatched = FALSE
		installation.response_status = "NO ERT DISPATCHED"
		installation.condition_details = "Emergency containment procedures are active. No external response team has been dispatched; local personnel are attempting to maintain essential operations."

	var/ert_history_text = installation.ert_dispatched ? "Emergency Response Team deployment was authorized." : "No Emergency Response Team was dispatched at declaration."
	add_installation_history(
		installation,
		"EMERGENCY",
		"CRITICAL incident declared",
		"[installation.critical_incident_original]. [ert_history_text]"
	)

	create_installation_critical_notice(installation)

	var/spoken_update

	if(installation.ert_dispatched)
		spoken_update = "Central Command sector alert. [installation.installation_name] has entered a CRITICAL operational state. Emergency Response Team deployment has been authorized."
	else
		spoken_update = "Central Command sector alert. [installation.installation_name] has entered a CRITICAL operational state. No Emergency Response Team has been authorized at this time."

	notify_registered_displays(
		spoken_update,
		TRUE,
		45,
		"emits an urgent notification tone."
	)

	// A critical installation has the highest chance of directly requesting
	// Liaison-controlled emergency allocation.
	maybe_issue_installation_aid_request(installation)

	// Critical incidents receive a faster follow-up.
	schedule_next_sector_installation_update(4 MINUTES, 6 MINUTES)


/datum/ccpost_sector_network/proc/create_installation_critical_notice(datum/ccpost_sector_installation/installation)
	var/response_text

	if(installation.ert_dispatched)
		response_text = "Central Command has authorized deployment of an Emergency Response Team to the installation."
	else
		response_text = "No Emergency Response Team has been dispatched at this time. Remote monitoring remains active."

	var/list/critical_template = list(
		"id" = "installation_critical_[installation.installation_code]",
		"category" = "Emergency Operations",
		"source" = "Central Emergency Management",
		"priority" = "Important",
		"title" = "Critical Installation Status: [installation.installation_name]",
		"body" = "[installation.installation_name] ([installation.installation_code]) has been designated CRITICAL following reports of [installation.incident_summary]. [response_text] Nearby Nanotrasen installations are instructed to maintain present operations unless otherwise directed."
	)

	create_sector_notice(critical_template)

// CRITICAL INCIDENT RESOLUTION

/datum/ccpost_sector_network/proc/resolve_critical_installation(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed || installation.status != "CRITICAL")
		return

	var/recovery_chance

	if(installation.ert_dispatched)
		recovery_chance = 70
	else
		recovery_chance = 35

	// Liaison-authorized emergency allocation improves the chance that the
	// installation survives the incident, but it never guarantees recovery.
	if(installation.critical_aid_authorized)
		recovery_chance += 20

	// Denying emergency assistance does not doom an installation outright,
	// but it reduces the chance that the remaining local/ERT response succeeds.
	if(installation.aid_denial_risk > 0)
		var/denial_recovery_penalty = round(installation.aid_denial_risk / 2)
		recovery_chance -= denial_recovery_penalty

	// Every Critical incident retains at least some possibility of either
	// recovery or installation loss.
	recovery_chance = min(95, max(5, recovery_chance))

	if(prob(recovery_chance))
		resolve_critical_installation_success(installation)
	else
		destroy_sector_installation(installation)


/datum/ccpost_sector_network/proc/resolve_critical_installation_success(datum/ccpost_sector_installation/installation)
	if(!installation)
		return

	var/incident_text = installation.critical_incident_original

	if(!incident_text)
		incident_text = installation.incident_summary

	var/list/aftermath = get_critical_aftermath_data(installation)
	var/aftermath_status = aftermath["status"]
	var/aftermath_details = aftermath["details"]

	if(!aftermath_status)
		aftermath_status = "UNDER REVIEW"

	if(!aftermath_details)
		aftermath_details = "The immediate critical incident has been contained. Recovery operations remain underway."

	installation.status = aftermath_status
	installation.status_since = station_time_timestamp()
	installation.critical_aftermath_active = TRUE

	apply_installation_status_metadata(installation)

	var/support_text

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		installation.response_status = "ERT + LIAISON RECOVERY"
		support_text = "Emergency Response Team intervention and Liaison-authorized emergency resources contributed to stabilization."
	else if(installation.ert_dispatched && installation.critical_aid_denied)
		installation.response_status = "ERT RECOVERY / AID DENIED"
		support_text = "Emergency Response Team intervention contained the incident after Liaison emergency assistance was denied."
	else if(installation.ert_dispatched)
		installation.response_status = "ERT OPERATION COMPLETE"
		support_text = "Emergency Response Team intervention contributed to stabilization."
	else if(installation.critical_aid_authorized)
		installation.response_status = "LIAISON-SUPPORTED RECOVERY"
		support_text = "Liaison-authorized emergency resources contributed to stabilization."
	else if(installation.critical_aid_denied)
		installation.response_status = "RECOVERY DESPITE AID DENIAL"
		support_text = "Local installation personnel contained the immediate emergency despite Liaison emergency assistance being denied."
	else
		installation.response_status = "INCIDENT STABILIZED"
		support_text = "Local installation personnel contained the immediate emergency without external response."

	installation.incident_summary = "CONTAINED - [incident_text]"
	installation.condition_details = "[aftermath_details] [support_text]"

	add_installation_history(
		installation,
		"EMERGENCY",
		"Critical incident contained",
		"[incident_text]. The installation entered [installation.status] for post-incident recovery. [support_text]"
	)

	create_installation_recovery_notice(installation, incident_text)

	var/spoken_update = "Sector update. The critical incident at [installation.installation_name] has been contained. The installation remains at [installation.status] while recovery operations continue."

	notify_registered_displays(
		spoken_update,
		FALSE,
		35,
		"chimes. A previously critical sector installation has entered post-incident recovery."
	)

// Recovery Sector Notice

/datum/ccpost_sector_network/proc/create_installation_recovery_notice(
	datum/ccpost_sector_installation/installation,
	incident_text
)
	if(!installation)
		return

	if(!incident_text)
		incident_text = installation.critical_incident_original

	var/recovery_text

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		recovery_text = "Emergency Response Team intervention and Liaison-authorized emergency support contributed to successful containment."
	else if(installation.ert_dispatched && installation.critical_aid_denied)
		recovery_text = "Emergency Response Team operations contained the incident after Liaison emergency assistance was denied."
	else if(installation.ert_dispatched)
		recovery_text = "Emergency Response Team operations contributed to successful containment."
	else if(installation.critical_aid_authorized)
		recovery_text = "Liaison-authorized emergency support contributed to successful containment."
	else if(installation.critical_aid_denied)
		recovery_text = "Local installation personnel contained the incident despite Liaison emergency assistance being denied."
	else
		recovery_text = "Local installation personnel contained the immediate emergency without external response."

	var/list/recovery_template = list(
		"id" = "installation_recovery_[installation.installation_code]",
		"category" = "Emergency Operations",
		"source" = "Central Emergency Management",
		"priority" = "Advisory",
		"title" = "Critical Incident Contained: [installation.installation_name]",
		"body" = "[installation.installation_name] ([installation.installation_code]) is no longer classified as CRITICAL following [incident_text]. [recovery_text] Current operational status: [installation.status]. Continued recovery and monitoring are required before the incident can be closed."
	)

	create_sector_notice(recovery_template)


// INSTALLATION DESTRUCTION

/datum/ccpost_sector_network/proc/destroy_sector_installation(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	installation.destroyed = TRUE
	expire_sector_paperwork_for_installation(installation, "Source installation has been destroyed.")
	installation.status = "OFFLINE"
	installation.condition = "DESTROYED"
	installation.telemetry = "TERMINATED"
	installation.critical_aftermath_active = FALSE
	installation.condition_details = "Confirmed installation loss following [installation.incident_summary]."
	installation.status_since = station_time_timestamp()

	var/spoken_update

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		installation.response_status = "ERT + AID FAILED"
		installation.condition_details += " Emergency Response Team intervention and Liaison-authorized emergency support were insufficient to prevent the loss."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. Emergency Response Team intervention and Liaison-authorized emergency support were unsuccessful. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.ert_dispatched && installation.critical_aid_denied)
		installation.response_status = "ERT FAILED / AID DENIED"
		installation.condition_details += " Emergency Response Team intervention failed after Liaison emergency assistance was denied."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. Emergency Response Team intervention failed after Liaison emergency assistance was denied. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.ert_dispatched)
		installation.response_status = "ERT OPERATION FAILED"
		installation.condition_details += " Emergency Response Team intervention was unsuccessful."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. Emergency Response Team intervention was unsuccessful. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.critical_aid_authorized)
		installation.response_status = "LIAISON AID INSUFFICIENT"
		installation.condition_details += " Liaison-authorized emergency support was insufficient to prevent the loss."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost despite Liaison-authorized emergency support. The installation is classified as destroyed. All remote telemetry has terminated."

	else if(installation.critical_aid_denied)
		installation.response_status = "AID DENIED / INSTALLATION LOST"
		installation.condition_details += " Liaison emergency assistance was denied before the installation was lost."

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost after Liaison emergency assistance was denied. The installation is classified as destroyed. All remote telemetry has terminated."

	else
		installation.response_status = "INSTALLATION LOST"

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. The installation is classified as destroyed. All remote telemetry has terminated."

	clear_installation_followup(installation)
	add_installation_history(
		installation,
		"EMERGENCY",
		"Installation confirmed lost",
		"Remote telemetry terminated following [installation.incident_summary]. Final recorded Central response: [installation.response_status]."
	)

	create_installation_loss_notice(installation)

	notify_registered_displays(
		spoken_update,
		TRUE,
		45,
		"emits an urgent priority alarm."
	)

// Installation Loss Sector Notice

/datum/ccpost_sector_network/proc/create_installation_loss_notice(datum/ccpost_sector_installation/installation)
	var/response_text

	if(installation.ert_dispatched && installation.critical_aid_authorized)
		response_text = "Emergency Response Team intervention and Liaison-authorized emergency support were unsuccessful."
	else if(installation.ert_dispatched && installation.critical_aid_denied)
		response_text = "Emergency Response Team intervention was unsuccessful after Liaison emergency assistance was denied."
	else if(installation.ert_dispatched)
		response_text = "Emergency Response Team intervention was unsuccessful."
	else if(installation.critical_aid_authorized)
		response_text = "Liaison-authorized emergency support was insufficient to prevent the loss."
	else if(installation.critical_aid_denied)
		response_text = "Liaison emergency assistance was denied prior to the confirmed loss."
	else
		response_text = "No Emergency Response Team or Liaison emergency allocation was committed prior to the confirmed loss."

	var/list/loss_template = list(
		"id" = "installation_loss_[installation.installation_code]",
		"category" = "Emergency Operations",
		"source" = "Central Emergency Management",
		"priority" = "Important",
		"title" = "Confirmed Installation Loss: [installation.installation_name]",
		"body" = "[installation.installation_name] ([installation.installation_code]) has been confirmed destroyed following [installation.incident_summary]. [response_text] The installation is classified as permanently non-operational and all remote telemetry has terminated. Nearby Nanotrasen installations are instructed to maintain present operations and await further direction. Unscheduled recovery operations are not authorized."
	)

	create_sector_notice(loss_template)


// INSTALLATION UPDATE TIMER

/datum/ccpost_sector_network/proc/schedule_next_sector_installation_update(minimum_delay = 7 MINUTES, maximum_delay = 12 MINUTES)
	if(sector_installation_timer)
		deltimer(sector_installation_timer)

	sector_installation_timer = addtimer(CALLBACK(src, PROC_REF(update_sector_installation)), rand(minimum_delay, maximum_delay), TIMER_STOPPABLE)

// Installation Update

/datum/ccpost_sector_network/proc/update_sector_installation()
	sector_installation_timer = null

	if(!length(sector_installations))
		initialize_sector_installations()

	// Critical incidents take priority over ordinary network updates.
	var/list/critical_installations = list()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(installation.destroyed)
			continue

		if(installation.status == "CRITICAL")
			critical_installations += installation

	if(length(critical_installations))
		var/datum/ccpost_sector_installation/critical_installation = pick(critical_installations)

		resolve_critical_installation(critical_installation)

		var/remaining_critical = FALSE

		for(var/datum/ccpost_sector_installation/check_installation as anything in sector_installations)
			if(check_installation.destroyed)
				continue

			if(check_installation.status == "CRITICAL")
				remaining_critical = TRUE
				break

		if(remaining_critical)
			schedule_next_sector_installation_update(4 MINUTES, 6 MINUTES)
		else
			schedule_next_sector_installation_update()

		return

	// Select a valid non-destroyed installation.
	var/list/available_installations = list()

	for(var/datum/ccpost_sector_installation/installation as anything in sector_installations)
		if(installation.destroyed)
			continue

		if(installation.status == "CRITICAL")
			continue

		available_installations += installation

	if(!length(available_installations))
		schedule_next_sector_installation_update()
		return

	var/datum/ccpost_sector_installation/selected_installation = pick(available_installations)

	if(length(available_installations) > 1 && last_updated_installation_code)
		while(selected_installation.installation_code == last_updated_installation_code)
			selected_installation = pick(available_installations)

	last_updated_installation_code = selected_installation.installation_code

	// Status determines the chance of escalation to CRITICAL.
	var/critical_chance = get_critical_chance(selected_installation)

	if(critical_chance && prob(critical_chance))
		set_installation_critical(selected_installation)
		return

	// Otherwise perform a normal status change. An unresolved denied aid
	// request can now directly bias this cycle toward a worse operational state,
	// in addition to increasing the separate CRITICAL escalation roll above.
	var/new_status
	var/denial_worsening_chance = get_aid_denial_worsening_chance(selected_installation)

	if(denial_worsening_chance > 0 && prob(denial_worsening_chance))
		new_status = get_denial_worsened_status(selected_installation)

	if(!new_status)
		new_status = get_next_installation_status(selected_installation)

	var/previous_status = selected_installation.status
	var/status_changed = new_status != previous_status

	if(status_changed)
		selected_installation.status = new_status
		selected_installation.status_since = station_time_timestamp()

	apply_installation_status_metadata(selected_installation)

	if(status_changed)
		add_installation_history(
			selected_installation,
			"OPERATIONS",
			"Status changed: [previous_status] -> [selected_installation.status]",
			selected_installation.condition_details
		)

	// Routine paperwork disappears as soon as its source leaves an eligible
	// administrative state.
	validate_active_sector_paperwork()

	// A contained Critical incident remains visible through its aftermath.
	// Only returning to green operation fully closes the incident record.
	if(selected_installation.critical_aftermath_active)
		if(is_installation_green(selected_installation))
			clear_critical_aftermath(selected_installation)
		else
			var/list/aftermath = get_critical_aftermath_data(selected_installation)
			var/aftermath_details = aftermath["details"]

			if(aftermath_details)
				selected_installation.condition_details = "[aftermath_details] Post-incident recovery remains ongoing."
			else
				selected_installation.condition_details += " Post-incident recovery from the contained Critical event remains ongoing."

	// A denial penalty is temporary. Returning to green operation clears it;
	// otherwise the extra escalation risk decays as the installation survives
	// additional operational cycles without Central assistance.
	if(is_installation_green(selected_installation))
		selected_installation.aid_denial_risk = 0
	else if(selected_installation.aid_denial_risk > 0)
		selected_installation.aid_denial_risk = max(0, selected_installation.aid_denial_risk - 3)

	// Any status below green gets a severity-based chance to generate a
	// direct aid request from the installation's named contact.
	maybe_issue_installation_aid_request(selected_installation)

	if(status_changed)
		if(selected_installation.status == "NO CONTACT" || selected_installation.status == "OFFLINE")
			create_installation_status_notice(selected_installation)
		else
			notify_registered_displays(
				null,
				FALSE,
				25,
				"chimes. Sector installation telemetry has been updated."
			)

	schedule_next_sector_installation_update()

// SECTOR COMMUNICATIONS TERMINAL REGISTRATION

/datum/ccpost_sector_network/proc/register_comms_terminal(
	obj/machinery/computer/ccpost_sector_comms/terminal
)
	if(!terminal)
		return

	registered_comms_terminals |= terminal

	ensure_started()


/datum/ccpost_sector_network/proc/unregister_comms_terminal(
	obj/machinery/computer/ccpost_sector_comms/terminal
)
	if(!terminal)
		return

	registered_comms_terminals -= terminal


/datum/ccpost_sector_network/proc/refresh_comms_terminals()
	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal))
			continue

		SStgui.update_uis(terminal)


/datum/ccpost_sector_network/proc/notify_comms_terminals(
	datum/ccpost_sector_message/message
)
	if(!message)
		return

	for(var/obj/machinery/computer/ccpost_sector_comms/terminal as anything in registered_comms_terminals)
		if(QDELETED(terminal))
			continue

		SStgui.update_uis(terminal)

		if(terminal.machine_stat & (NOPOWER | BROKEN))
			continue

		var/urgent = message.priority == "Priority" || message.priority == "Important"

		playsound(
			terminal,
			'sound/machines/terminal_alert.ogg',
			vol = urgent ? 45 : 30,
			vary = !urgent
		)

		terminal.say(
			"Incoming authenticated transmission from [message.installation_name]. Sender: [message.sender_role] [message.sender_name]."
		)

// CENTRAL COMMAND REMOTE STATUS DISPLAY

/obj/machinery/status_display/ccpost_remote_status
	name = "Central Command remote status display"
	desc = "A secure Central Command display receiving read-only operational telemetry from nearby Nanotrasen installations. A label beneath the screen reads: 'INFORMATION IS NOT A SUBSTITUTE FOR VERIFICATION.'"

	current_mode = SD_MESSAGE
	text_color = COLOR_DISPLAY_CYAN
	header_text_color = COLOR_DISPLAY_BLUE

	/// Frequency of nearby station telemetry refreshes.
	var/refresh_interval = 10 SECONDS

	/// Next world.time at which telemetry refreshes.
	var/next_status_refresh = 0

	/// Timestamp of the last station telemetry update.
	var/last_status_update = "N/A"

	/// Prevents repeated installation-record printing.
	COOLDOWN_DECLARE(record_print_cooldown)


/obj/machinery/status_display/ccpost_remote_status/Initialize(mapload, ndir, building)
	. = ..()

	GLOB.ccpost_sector_network.register_display(src)

	update()


/obj/machinery/status_display/ccpost_remote_status/Destroy()
	GLOB.ccpost_sector_network.unregister_display(src)

	return ..()


/obj/machinery/status_display/ccpost_remote_status/process()
	if(machine_stat & NOPOWER)
		update_appearance()
		return PROCESS_KILL

	if(machine_stat & BROKEN)
		update_appearance()
		return

	if(world.time < next_status_refresh)
		return

	next_status_refresh = world.time + refresh_interval

	refresh_station_status()


/obj/machinery/status_display/ccpost_remote_status/proc/refresh_station_status()
	var/station = station_name()
	var/alert_level = uppertext(SSsecurity_level.get_current_level_as_text())

	set_messages(station, "ALERT: [alert_level]")

	last_status_update = station_time_timestamp()

	SStgui.update_uis(src)

// STATION COMMAND ROSTER

/obj/machinery/status_display/ccpost_remote_status/proc/get_command_roster()
	var/static/list/command_positions = list(
		"Captain" = JOB_CAPTAIN,
		"Head of Personnel" = JOB_HEAD_OF_PERSONNEL,
		"Head of Security" = JOB_HEAD_OF_SECURITY,
		"Chief Engineer" = JOB_CHIEF_ENGINEER,
		"Chief Medical Officer" = JOB_CHIEF_MEDICAL_OFFICER,
		"Research Director" = JOB_RESEARCH_DIRECTOR,
		"Nanotrasen Representative" = JOB_NANOTRASEN_REPRESENTATIVE
	)

	var/list/command_roster = list()

	for(var/display_name in command_positions)
		var/job_title = command_positions[display_name]
		var/registered_name = "UNSTAFFED"

		for(var/datum/record/crew/crew_record as anything in GLOB.manifest.general)
			if(crew_record.trim != job_title)
				continue

			registered_name = crew_record.name
			break

		command_roster += list(
			list(
				"role" = display_name,
				"name" = registered_name
			)
		)

	return command_roster

// EMERGENCY SHUTTLE INFORMATION

/obj/machinery/status_display/ccpost_remote_status/proc/get_emergency_shuttle_data()
	var/list/shuttle_data = list(
		"status" = "NOT CALLED",
		"timer" = 0
	)

	if(!SSshuttle?.emergency)
		shuttle_data["status"] = "UNAVAILABLE"
		return shuttle_data

	switch(SSshuttle.emergency.mode)
		if(SHUTTLE_IDLE, SHUTTLE_RECALL)
			shuttle_data["status"] = "NOT CALLED"

		if(SHUTTLE_CALL)
			shuttle_data["status"] = "EN ROUTE"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_DOCKED)
			shuttle_data["status"] = "DOCKED"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_IGNITING)
			shuttle_data["status"] = "DEPARTURE IMMINENT"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_ESCAPE)
			shuttle_data["status"] = "IN TRANSIT TO CENTRAL COMMAND"
			shuttle_data["timer"] = SSshuttle.emergency.timeLeft()

		if(SHUTTLE_STRANDED)
			shuttle_data["status"] = "STRANDED"

		if(SHUTTLE_DISABLED)
			shuttle_data["status"] = "UNAVAILABLE"

		if(SHUTTLE_ENDGAME)
			shuttle_data["status"] = "EVACUATION COMPLETE"

	return shuttle_data

// INSTALLATION RECORD PRINTING

/obj/machinery/status_display/ccpost_remote_status/proc/build_installation_record_print_text(datum/ccpost_sector_installation/installation)
	if(!installation)
		return ""

	var/contact_name = sanitize(installation.contact_name)
	var/contact_role = sanitize(installation.contact_role)
	var/relationship = GLOB.ccpost_sector_network.get_installation_trust_label(installation)
	var/followup_state = GLOB.ccpost_sector_network.get_installation_followup_status_text(installation)
	var/followup_text = followup_state

	if(installation.active_followup_origin_code)
		followup_text = "[installation.active_followup_origin_title] - [followup_state]"

	var/print_text = "<center><b>Central Command Installation Administrative Record</b></center><br>"
	print_text += "<hr>"
	print_text += "<b>Installation:</b> [installation.installation_name] ([installation.installation_code])<br>"
	print_text += "<b>Function:</b> [installation.installation_function]<br>"
	print_text += "<b>Named Contact:</b> [contact_role] [contact_name]<br>"
	print_text += "<b>Relationship Assessment:</b> [relationship]<br>"
	print_text += "<b>Operational Status:</b> [installation.status]<br>"
	print_text += "<b>Condition:</b> [installation.condition]<br>"
	print_text += "<b>Telemetry:</b> [installation.telemetry]<br>"
	print_text += "<b>Last Status Change:</b> [installation.status_since]<br>"
	print_text += "<b>Central Response:</b> [installation.response_status]<br>"
	print_text += "<b>Active Follow-Up:</b> [followup_text]<br>"
	print_text += "<hr>"
	print_text += "<b>Incident:</b> [installation.incident_summary]<br>"
	print_text += "<b>Remarks:</b> [installation.condition_details]<br>"
	print_text += "<hr>"
	print_text += "<b>Retained Administrative History</b><br><br>"

	if(!length(installation.history))
		print_text += "No notable history is currently retained for this installation.<br>"
	else
		for(var/datum/ccpost_installation_history_entry/entry as anything in installation.history)
			if(QDELETED(entry))
				continue
			print_text += "<b>[entry.timestamp] - [entry.category]: [entry.title]</b><br>"
			print_text += "[entry.details]<br><br>"

	print_text += "<hr><small><i>Central Command Remote Oversight Network - Shift administrative record</i></small>"

	return print_text


/obj/machinery/status_display/ccpost_remote_status/proc/print_installation_record(datum/ccpost_sector_installation/installation)
	if(!installation)
		return FALSE

	var/obj/item/paper/record = new /obj/item/paper(drop_location())
	record.name = "Central Command Installation Record - [installation.installation_code]"
	record.add_raw_text(build_installation_record_print_text(installation))
	record.update_appearance()

	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice("[src] prints a Central Command installation record."))

	return TRUE


//TGUI

/obj/machinery/status_display/ccpost_remote_status/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CCPostRemoteStatus", name)
		ui.open()


/obj/machinery/status_display/ccpost_remote_status/ui_act(
	action,
	list/params,
	datum/tgui/ui,
	datum/ui_state/state
)
	. = ..()

	if(.)
		return

	var/mob/user = ui.user
	var/installation_code = params["installation_code"]
	var/datum/ccpost_sector_installation/installation = GLOB.ccpost_sector_network.get_installation_by_code(installation_code)

	if(!installation)
		balloon_alert(user, "installation record not found")
		return TRUE

	switch(action)
		if("print_installation_record")
			if(!COOLDOWN_FINISHED(src, record_print_cooldown))
				balloon_alert(user, "printer cooling down")
				return TRUE

			COOLDOWN_START(src, record_print_cooldown, 5 SECONDS)

			if(print_installation_record(installation))
				balloon_alert(user, "installation record printed")
			else
				balloon_alert(user, "unable to print record")

			return TRUE

		if("clear_installation_history")
			if(!length(installation.history))
				balloon_alert(user, "history already empty")
				return TRUE

			GLOB.ccpost_sector_network.clear_installation_history(installation)
			balloon_alert(user, "installation history cleared")
			SStgui.update_uis(src)
			return TRUE

	return FALSE


/obj/machinery/status_display/ccpost_remote_status/ui_data(mob/user)
	GLOB.ccpost_sector_network.ensure_started()

	var/list/data = list()

	data["station_name"] = station_name()
	data["alert_level"] = SSsecurity_level.get_current_level_as_text()
	data["registered_crew"] = length(GLOB.manifest.general)
	data["last_update"] = last_status_update
	data["command_roster"] = get_command_roster()
	data["shuttle"] = get_emergency_shuttle_data()

	var/list/sector_notice_data = list()

	for(var/datum/ccpost_sector_notice/notice as anything in GLOB.ccpost_sector_network.sector_notices)
		sector_notice_data += list(
			list(
				"notice_code" = notice.notice_code,
				"category" = notice.category,
				"source" = notice.source,
				"priority" = notice.priority,
				"title" = notice.title,
				"body" = notice.body,
				"issued_at" = notice.issued_at
			)
		)

	data["sector_notices"] = sector_notice_data

	var/list/sector_installation_data = list()

	for(var/datum/ccpost_sector_installation/installation as anything in GLOB.ccpost_sector_network.sector_installations)
		var/list/history_data = list()

		for(var/datum/ccpost_installation_history_entry/entry as anything in installation.history)
			if(QDELETED(entry))
				continue

			history_data += list(
				list(
					"timestamp" = entry.timestamp,
					"category" = entry.category,
					"title" = entry.title,
					"details" = entry.details
				)
			)

		sector_installation_data += list(
			list(
				"code" = installation.installation_code,
				"name" = installation.installation_name,
				"function" = installation.installation_function,
				"contact_name" = installation.contact_name,
				"contact_role" = installation.contact_role,
				"status" = installation.status,
				"status_since" = installation.status_since,
				"condition" = installation.condition,
				"telemetry" = installation.telemetry,
				"condition_details" = installation.condition_details,
				"incident_summary" = installation.incident_summary,
				"response_status" = installation.response_status,
				"ert_dispatched" = installation.ert_dispatched,
				"destroyed" = installation.destroyed,
				"trust_label" = GLOB.ccpost_sector_network.get_installation_trust_label(installation),
				"followup_active" = installation.active_followup_origin_code ? TRUE : FALSE,
				"followup_subject" = installation.active_followup_origin_title,
				"followup_status" = GLOB.ccpost_sector_network.get_installation_followup_status_text(installation),
				"history" = history_data
			)
		)

	data["sector_installations"] = sector_installation_data

	return data


MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ccpost_remote_status, 32)

// CENTRAL COMMAND OUTPOST LOGISTICS

#define CCPOST_FREIGHT_INBOUND_ID "ccpost_freight_in"
#define CCPOST_FREIGHT_OUTBOUND_ID "ccpost_freight_out"

#define CCPOST_STARTING_ALLOCATION 20
#define CCPOST_MAX_ALLOCATION 80
#define CCPOST_FREIGHT_RETURN_VALUE 1


// LOGISTICS NETWORK

#define CCPOST_SHIPMENT_QUEUED "QUEUED"
#define CCPOST_SHIPMENT_AUTHORIZED "AUTHORIZED"
#define CCPOST_SHIPMENT_IN_TRANSIT "IN TRANSIT"
#define CCPOST_SHIPMENT_DELIVERED "DELIVERED"
#define CCPOST_SHIPMENT_FAILED "FAILED"

#define CCPOST_MAX_ACTIVE_SHIPMENTS 2

// Base freight processing timing. Sector conditions may modify these values.
#define CCPOST_BASE_AUTHORIZATION_DELAY 30 SECONDS
#define CCPOST_BASE_DISPATCH_DELAY 45 SECONDS
#define CCPOST_BASE_TRANSIT_DELAY 60 SECONDS

#define CCPOST_SHIPMENT_RETRY_DELAY 5 SECONDS


/datum/ccpost_freight_conditions
	var/status = "NORMAL"

	var/authorization_delay = CCPOST_BASE_AUTHORIZATION_DELAY
	var/dispatch_delay = CCPOST_BASE_DISPATCH_DELAY
	var/transit_multiplier = 1

	var/list/reasons = list()


/datum/ccpost_freight_conditions/proc/add_reason(reason)
	if(!reason)
		return

	reasons += reason


/datum/ccpost_freight_conditions/proc/get_transit_delay()
	return max(
		5 SECONDS,
		round(CCPOST_BASE_TRANSIT_DELAY * transit_multiplier, 1 SECONDS)
	)


/datum/ccpost_freight_conditions/proc/finalize_status()
	var/degraded = FALSE
	var/priority = FALSE

	if(authorization_delay > CCPOST_BASE_AUTHORIZATION_DELAY)
		degraded = TRUE

	if(dispatch_delay > CCPOST_BASE_DISPATCH_DELAY)
		degraded = TRUE

	if(transit_multiplier > 1)
		degraded = TRUE

	if(authorization_delay < CCPOST_BASE_AUTHORIZATION_DELAY)
		priority = TRUE

	if(dispatch_delay < CCPOST_BASE_DISPATCH_DELAY)
		priority = TRUE

	if(transit_multiplier < 1)
		priority = TRUE

	if(degraded && priority)
		status = "MIXED"

	else if(degraded)
		status = "DEGRADED"

	else if(priority)
		status = "PRIORITY"

	else
		status = "NORMAL"

// Checks conditions of other installations within the sector, which has an affect on freight

/datum/ccpost_logistics_network/proc/get_current_freight_conditions()
	var/datum/ccpost_freight_conditions/conditions = new

	var/datum/ccpost_sector_network/sector_network = GLOB.ccpost_sector_network

	if(!sector_network)
		conditions.finalize_status()
		return conditions

	sector_network.ensure_started()

	// --------------------------------------------------------
	// RELAY STATION A-17
	// Communications reliability affects authorization.
	// --------------------------------------------------------

	var/datum/ccpost_sector_installation/relay = sector_network.get_installation_by_code("NT-REL-A17")

	if(relay)
		if(relay.destroyed)
			conditions.authorization_delay += 15 SECONDS
			conditions.add_reason("Relay Station A-17 has been lost. Administrative traffic is being rerouted.")

		else
			switch(relay.status)
				if("COMMUNICATIONS DEGRADED")
					conditions.authorization_delay += 5 SECONDS
					conditions.add_reason("Relay Station A-17 is reporting degraded communications.")

				if("NO CONTACT", "OFFLINE")
					conditions.authorization_delay += 10 SECONDS
					conditions.add_reason("Relay Station A-17 is unavailable. Authorization traffic is using alternate routes.")

				if("CRITICAL")
					conditions.authorization_delay += 15 SECONDS
					conditions.add_reason("Relay Station A-17 is experiencing a critical operational incident.")


	// --------------------------------------------------------
	// ADMINISTRATIVE ANNEX 6
	// Administrative processing affects authorization.
	// --------------------------------------------------------

	var/datum/ccpost_sector_installation/administrative_annex = sector_network.get_installation_by_code("NT-ADM-06")

	if(administrative_annex)
		if(administrative_annex.destroyed)
			conditions.authorization_delay += 15 SECONDS
			conditions.add_reason("Administrative Annex 6 has been lost. Requisitions are being processed through alternate administrative channels.")

		else
			switch(administrative_annex.status)
				if("UNDER REVIEW")
					conditions.authorization_delay += 5 SECONDS
					conditions.add_reason("Administrative Annex 6 is under Central Command review.")

				if("COMMUNICATIONS DEGRADED")
					conditions.authorization_delay += 5 SECONDS
					conditions.add_reason("Administrative Annex 6 is experiencing communications degradation.")

				if("NO CONTACT", "OFFLINE")
					conditions.authorization_delay += 10 SECONDS
					conditions.add_reason("Administrative Annex 6 is unavailable. Requisition processing has been rerouted.")

				if("CRITICAL")
					conditions.authorization_delay += 15 SECONDS
					conditions.add_reason("Administrative Annex 6 is experiencing a critical operational incident.")


	// --------------------------------------------------------
	// LOGISTICS STATION H-9
	// This is the installation most directly involved in freight.
	// --------------------------------------------------------

	var/datum/ccpost_sector_installation/logistics_station = sector_network.get_installation_by_code("NT-LOG-H09")

	if(logistics_station)
		if(logistics_station.destroyed)
			conditions.dispatch_delay += 20 SECONDS
			conditions.transit_multiplier *= 1.75
			conditions.add_reason("Logistics Station H-9 has been lost. Freight is being routed through distant sector infrastructure.")

		else
			switch(logistics_station.status)
				if("MAINTENANCE")
					conditions.dispatch_delay += 5 SECONDS
					conditions.transit_multiplier *= 1.15
					conditions.add_reason("Logistics Station H-9 is undergoing maintenance.")

				if("COMMUNICATIONS DEGRADED")
					conditions.dispatch_delay += 5 SECONDS
					conditions.transit_multiplier *= 1.25
					conditions.add_reason("Logistics Station H-9 is reporting degraded communications.")

				if("NO CONTACT")
					conditions.dispatch_delay += 10 SECONDS
					conditions.transit_multiplier *= 1.4
					conditions.add_reason("Contact with Logistics Station H-9 has been lost. Freight is being rerouted.")

				if("OFFLINE")
					conditions.dispatch_delay += 15 SECONDS
					conditions.transit_multiplier *= 1.5
					conditions.add_reason("Logistics Station H-9 is offline. Alternate freight infrastructure is in use.")

				if("CRITICAL")
					conditions.dispatch_delay += 20 SECONDS
					conditions.transit_multiplier *= 1.75
					conditions.add_reason("Logistics Station H-9 is experiencing a critical operational incident.")


	// --------------------------------------------------------
	// ACTIVE SECTOR NOTICES
	// --------------------------------------------------------

	for(var/datum/ccpost_sector_notice/notice as anything in sector_network.sector_notices)
		if(!notice.has_active_logistics_effect())
			continue

		conditions.authorization_delay += notice.logistics_authorization_delay
		conditions.dispatch_delay += notice.logistics_dispatch_delay
		conditions.transit_multiplier *= notice.logistics_transit_multiplier

		if(notice.logistics_effect_summary)
			conditions.add_reason("[notice.title]: [notice.logistics_effect_summary]")


	// Prevent ridiculous stacking if several incidents overlap.
	conditions.authorization_delay = clamp(
		conditions.authorization_delay,
		15 SECONDS,
		90 SECONDS
	)

	conditions.dispatch_delay = clamp(
		conditions.dispatch_delay,
		15 SECONDS,
		90 SECONDS
	)

	conditions.transit_multiplier = clamp(
		conditions.transit_multiplier,
		0.5,
		2.5
	)

	conditions.finalize_status()

	return conditions

/datum/ccpost_logistics_network
	/// Total Central Command Operational Allocation currently owned by the outpost.
	var/allocation = CCPOST_STARTING_ALLOCATION

	/// Allocation currently committed to pending orders.
	var/reserved_allocation = 0

	/// Maximum allocation the outpost may hold.
	var/max_allocation = CCPOST_MAX_ALLOCATION

	/// Incrementing number used for shipment IDs.
	var/next_shipment_number = 1

	/// Round-long record of actual allocation gains and expenditures.
	var/list/allocation_ledger = list()

	/// Registered inbound freight spawn locations.
	var/list/inbound_spawns = list()

	/// Registered inbound unloading sensors.
	var/list/unload_points = list()

	/// Registered outbound freight loading points.
	var/list/outbound_load_points = list()

	/// Registered outbound freight return receivers.
	var/list/return_receivers = list()

	/// Registered Central Command Logistics Terminals.
	var/list/registered_terminals = list()

	/// Wall-mounted freight status displays connected to the outpost logistics network.
	var/list/registered_status_displays = list()

	/// Available Central Command procurement packages.
	var/list/supply_catalog = list()

	/// Current and historical freight requisitions.
	var/list/shipments = list()

	/// Number of restricted/contraband requisitions submitted this round.
	var/contraband_requisition_count = 0

	/// TRUE when new restricted procurement activity should trigger an outpost audit.
	var/contraband_audit_pending = FALSE

	/// Restricted requisition count already covered by the most recently issued audit.
	var/contraband_requisitions_at_last_audit = 0

	/// Weighted compliance risk generated by restricted requisitions.
	var/contraband_compliance_points = 0

	/// Compliance points already covered by the most recently issued audit.
	var/contraband_points_at_last_audit = 0

	/// World time until which Restricted procurement is blocked by Internal Compliance.
	var/restricted_procurement_suspended_until = 0

	/// Maximum unfinished requisitions allowed simultaneously.
	var/max_active_shipments = CCPOST_MAX_ACTIVE_SHIPMENTS

	/// TRUE while a freight container is physically travelling along the inbound lane.
	var/inbound_lane_busy = FALSE

	/// TRUE while a freight container is physically travelling along the outbound return lane.
	var/outbound_lane_busy = FALSE


/datum/ccpost_logistics_network/Destroy()
	inbound_spawns = null
	unload_points = null
	outbound_load_points = null
	return_receivers = null
	allocation_ledger = null
	registered_terminals = null
	supply_catalog = null
	shipments = null
	registered_status_displays = null

	return ..()

/datum/ccpost_logistics_network/proc/is_restricted_procurement_suspended()
	return restricted_procurement_suspended_until > world.time


/datum/ccpost_logistics_network/proc/get_restricted_procurement_suspension_remaining()
	if(!is_restricted_procurement_suspended())
		return 0

	return max(0, restricted_procurement_suspended_until - world.time)


/datum/ccpost_logistics_network/proc/suspend_restricted_procurement(duration)
	if(duration <= 0)
		return

	restricted_procurement_suspended_until = max(restricted_procurement_suspended_until, world.time + duration)

	refresh_logistics_outputs()
	addtimer(CALLBACK(src, PROC_REF(clear_restricted_procurement_suspension_if_expired)), duration + 1 SECONDS)


/datum/ccpost_logistics_network/proc/clear_restricted_procurement_suspension_if_expired()
	if(world.time < restricted_procurement_suspended_until)
		return

	restricted_procurement_suspended_until = 0
	refresh_logistics_outputs()


// Freight Status Display

/datum/ccpost_logistics_network/proc/register_status_display(obj/machinery/status_display/ccpost_logistics/display)
	if(!display)
		return

	registered_status_displays |= display

	display.update()


/datum/ccpost_logistics_network/proc/unregister_status_display(obj/machinery/status_display/ccpost_logistics/display)
	if(!display)
		return

	registered_status_displays -= display

/// Returns the amount of allocation which is actually available to spend.
/datum/ccpost_logistics_network/proc/get_available_allocation()
	return max(0, allocation - reserved_allocation)


/// Records an actual financial transaction in the allocation ledger.
/datum/ccpost_logistics_network/proc/record_ledger_entry(amount, reason = "Unspecified transaction", actor = "SYSTEM")
	allocation_ledger.Insert(1, list(list(
		"time" = station_time_timestamp(),
		"amount" = amount,
		"reason" = reason,
		"actor" = actor
	)))

	if(length(allocation_ledger) > 100)
		allocation_ledger.Cut(101)


/// Adds operational allocation to the outpost.
///
/// Returns the amount which was actually credited after applying the maximum balance.
/datum/ccpost_logistics_network/proc/credit_allocation(amount, reason = "Central Command allocation credit", actor = "CENTRAL COMMAND")
	if(amount <= 0)
		return 0

	var/available_capacity = max_allocation - allocation

	if(available_capacity <= 0)
		return 0

	var/applied_amount = min(amount, available_capacity)

	allocation += applied_amount

	record_ledger_entry(applied_amount, reason, actor)

	return applied_amount


/// Immediately spends unreserved allocation.
///
/// Returns TRUE if the payment succeeded.
/datum/ccpost_logistics_network/proc/spend_allocation(amount, reason = "Operational expenditure", actor = "SYSTEM")
	if(amount <= 0)
		return FALSE

	if(amount > get_available_allocation())
		return FALSE

	allocation -= amount

	record_ledger_entry(-amount, reason, actor)

	return TRUE


/// Reserves allocation for an order which has been placed but not yet finalized.
///
/// Reserved allocation remains part of the total balance but cannot be spent elsewhere.
/datum/ccpost_logistics_network/proc/reserve_allocation(amount)
	if(amount <= 0)
		return FALSE

	if(amount > get_available_allocation())
		return FALSE

	reserved_allocation += amount

	return TRUE


/// Releases previously reserved allocation.
///
/// Used if an order is cancelled or otherwise fails before expenditure.
/datum/ccpost_logistics_network/proc/release_reserved_allocation(amount)
	if(amount <= 0)
		return 0

	var/released_amount = min(amount, reserved_allocation)

	reserved_allocation -= released_amount

	return released_amount


/// Converts reserved allocation into an actual expenditure.
///
/// Used when a requisition becomes financially committed.
/datum/ccpost_logistics_network/proc/commit_reserved_allocation(amount, reason = "Operational expenditure", actor = "SYSTEM")
	if(amount <= 0)
		return FALSE

	if(amount > reserved_allocation)
		return FALSE

	if(amount > allocation)
		return FALSE

	reserved_allocation -= amount
	allocation -= amount

	record_ledger_entry(-amount, reason, actor)

	return TRUE

/datum/ccpost_logistics_network/New()
	. = ..()

	build_supply_catalog()


/datum/ccpost_logistics_network/proc/build_supply_catalog()
	for(var/datum/ccpost_supply_package/package_type as anything in subtypesof(/datum/ccpost_supply_package))
		var/datum/ccpost_supply_package/package = new package_type

		if(!package.id || package.id == "undefined")
			qdel(package)
			continue

		supply_catalog[package.id] = package


/datum/ccpost_logistics_network/proc/get_supply_package(package_id)
	return supply_catalog[package_id]


/datum/ccpost_logistics_network/proc/get_active_shipment_count()
	var/count = 0

	for(var/datum/ccpost_shipment/shipment as anything in shipments)
		if(QDELETED(shipment))
			continue

		if(shipment.status == CCPOST_SHIPMENT_DELIVERED)
			continue

		if(shipment.status == CCPOST_SHIPMENT_FAILED)
			continue

		count++

	return count


/datum/ccpost_logistics_network/proc/find_shipment(shipment_code)
	if(!shipment_code)
		return null

	for(var/datum/ccpost_shipment/shipment as anything in shipments)
		if(QDELETED(shipment))
			continue

		if(shipment.shipment_code == shipment_code)
			return shipment

	return null

/datum/ccpost_logistics_network/proc/refresh_logistics_outputs()
	refresh_registered_terminals()

	for(var/obj/machinery/status_display/ccpost_logistics/display as anything in registered_status_displays)
		if(QDELETED(display))
			continue

		display.update()


/datum/ccpost_logistics_network/proc/refresh_registered_terminals()
	for(var/obj/machinery/computer/ccpost_logistics/terminal as anything in registered_terminals)
		if(QDELETED(terminal))
			continue

		SStgui.update_uis(terminal)

/// Freight status announcement system
//
/// Makes the terminal say the status of the freight via worldspeech
/datum/ccpost_logistics_network/proc/announce_freight_status(message, play_alert = TRUE)
	if(!message)
		return

	for(var/obj/machinery/computer/ccpost_logistics/terminal as anything in registered_terminals)
		if(QDELETED(terminal))
			continue

		if(terminal.machine_stat & (NOPOWER | BROKEN))
			continue

		if(play_alert)
			playsound(terminal, 'sound/machines/terminal_alert.ogg', 30, TRUE)

		terminal.say(message)


/// Generates the next unique Central Command freight shipment number.
/datum/ccpost_logistics_network/proc/generate_shipment_code()
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/shipment_code = "CC-LG-[round_identifier]-[next_shipment_number]"

	next_shipment_number++

	return shipment_code


GLOBAL_DATUM_INIT(ccpost_logistics_network, /datum/ccpost_logistics_network, new)



// CONVEYOR CONTROL

/// Changes the operating state of every conveyor belt sharing a given ID.
///
/// Examples:
/// set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, FALSE)
/// set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, FALSE)
/proc/set_ccpost_conveyor_state(conveyor_id, operating_state)
	var/list/linked_conveyors = GLOB.conveyors_by_id[conveyor_id]

	if(!length(linked_conveyors))
		return FALSE

	for(var/obj/machinery/conveyor/belt as anything in linked_conveyors)
		if(QDELETED(belt))
			continue

		belt.set_operating(operating_state)

	return TRUE


// CENTRAL COMMAND FREIGHT CONTAINER

/obj/structure/closet/crate/ccpost_freight
	name = "Central Command freight container"
	desc = "A reusable freight container belonging to Central Command Logistics. A notice requests that empty containers be returned through an authorized freight receiver."

	/// Shipment number associated with this container.
	var/shipment_code

	/// Whether this container is eligible to be returned through the outpost freight network.
	var/returnable = TRUE

	/// Allocation returned when this empty container is successfully processed.
	var/return_value = CCPOST_FREIGHT_RETURN_VALUE


/obj/structure/closet/crate/ccpost_freight/examine(mob/user)
	. = ..()

	if(shipment_code)
		. += span_notice("Its freight identification number is [shipment_code].")

	if(returnable)
		. += span_notice("The container is marked as reusable Central Command freight property.")


// FREIGHT MAP POINTS

/obj/effect/ccpost_freight_point
	name = "CCPOST freight point"
	desc = "A mapping point used by the Central Command Liaison Outpost freight system."

	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"

	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


// INBOUND FREIGHT SPAWN

/// Place this on the furthest hidden inbound conveyor tile.
///
/// Ordered freight will initially appear here and travel toward the visible cargo bay.

/obj/effect/ccpost_freight_point/inbound_spawn
	name = "CCPOST inbound freight spawn"


/obj/effect/ccpost_freight_point/inbound_spawn/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.inbound_spawns |= src


/obj/effect/ccpost_freight_point/inbound_spawn/Destroy()
	GLOB.ccpost_logistics_network.inbound_spawns -= src

	return ..()

// INBOUND UNLOAD SENSOR

/// Place this on the final inbound conveyor tile inside the usable cargo bay.
///
/// When a Central Command freight container reaches this tile,
/// the inbound conveyor line stops automatically.

/obj/effect/ccpost_freight_point/inbound_unload
	name = "CCPOST inbound freight unload point"


/obj/effect/ccpost_freight_point/inbound_unload/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.unload_points |= src

	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/ccpost_freight_point/inbound_unload/Destroy()
	GLOB.ccpost_logistics_network.unload_points -= src

	return ..()


/obj/effect/ccpost_freight_point/inbound_unload/proc/on_entered(datum/source, atom/movable/entering_atom)
	SIGNAL_HANDLER

	if(!istype(entering_atom, /obj/structure/closet/crate/ccpost_freight))
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = entering_atom

	set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, FALSE)

	GLOB.ccpost_logistics_network.mark_shipment_delivered(freight_crate.shipment_code)

	playsound(src, 'sound/machines/terminal_alert.ogg', vol = 25, vary = TRUE)

// OUTBOUND LOAD POINT

/// Place this on the first outbound conveyor tile inside the usable cargo bay.
///
/// Empty, returnable Central Command freight containers placed on this tile
/// automatically start the outbound freight conveyor.

/obj/effect/ccpost_freight_point/outbound_load
	name = "CCPOST outbound freight loading point"


/obj/effect/ccpost_freight_point/outbound_load/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.outbound_load_points |= src

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)

	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/ccpost_freight_point/outbound_load/Destroy()
	GLOB.ccpost_logistics_network.outbound_load_points -= src

	return ..()


/obj/effect/ccpost_freight_point/outbound_load/proc/on_entered(
	datum/source,
	atom/movable/entering_atom
)
	SIGNAL_HANDLER

	// Only Central Command freight containers can use the return system.
	if(!istype(entering_atom, /obj/structure/closet/crate/ccpost_freight))
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = entering_atom
	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return

	// Prevent multiple returns from entering the outbound lane simultaneously.
	if(network.outbound_lane_busy)
		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("[freight_crate] is rejected by the freight return system. The return lane is currently occupied.")
		)

		return

	// Only designated reusable freight containers may be returned.
	if(!freight_crate.returnable)
		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("[freight_crate] is rejected by the freight return system.")
		)

		return

	// Containers must be completely empty before Sector Logistics will accept them.
	if(length(freight_crate.contents))
		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("[freight_crate] is rejected by the freight return system. The container must be empty.")
		)

		return

	network.outbound_lane_busy = TRUE

	if(!set_ccpost_conveyor_state(CCPOST_FREIGHT_OUTBOUND_ID, TRUE))
		network.outbound_lane_busy = FALSE

		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("The freight return system fails to engage.")
		)

		return

	playsound(src, 'sound/machines/terminal_alert.ogg', vol = 20, vary = TRUE)

	freight_crate.visible_message(
		span_notice("[freight_crate] is accepted for return to Sector Logistics.")
	)


// OUTBOUND RETURN RECEIVER

/// Place this on the furthest hidden outbound conveyor tile.
///
/// Empty Central Command freight containers which reach this point
/// are returned to Sector Logistics and provide a small allocation refund.

/obj/effect/ccpost_freight_point/return_receiver
	name = "CCPOST outbound freight receiver"


/obj/effect/ccpost_freight_point/return_receiver/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.return_receivers |= src

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)

	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/ccpost_freight_point/return_receiver/Destroy()
	GLOB.ccpost_logistics_network.return_receivers -= src

	return ..()


/obj/effect/ccpost_freight_point/return_receiver/proc/on_entered(
	datum/source,
	atom/movable/entering_atom
)
	SIGNAL_HANDLER

	if(!istype(entering_atom, /obj/structure/closet/crate/ccpost_freight))
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = entering_atom
	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return

	// Something has reached the end of the outbound lane, so stop it
	// and release the lane regardless of whether processing succeeds.
	set_ccpost_conveyor_state(CCPOST_FREIGHT_OUTBOUND_ID, FALSE)
	network.outbound_lane_busy = FALSE

	// Safety validation. Normally these checks are already performed
	// by the outbound loading point.
	if(!freight_crate.returnable)
		return

	if(length(freight_crate.contents))
		return

	var/credited_amount = network.credit_allocation(
		freight_crate.return_value,
		"Reusable freight container returned to Sector Logistics",
		"AUTOMATED FREIGHT RECEIVER"
	)

	if(credited_amount)
		playsound(src, 'sound/machines/terminal_alert.ogg', vol = 30, vary = TRUE)

		network.refresh_registered_terminals()

	qdel(freight_crate)

// CENTRAL COMMAND LOGISTICS TERMINAL CIRCUIT BOARD

/obj/item/circuitboard/computer/ccpost_logistics
	name = "Central Command Logistics Terminal"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/ccpost_logistics

// CENTRAL COMMAND LOGISTICS TERMINAL

/obj/machinery/computer/ccpost_logistics
	name = "Central Command logistics terminal"
	desc = "A secure Central Command procurement terminal used to manage operational allocation, freight requisitions, and remote installation logistics."

	icon_screen = "request"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_ORANGE

	circuit = /obj/item/circuitboard/computer/ccpost_logistics
	var/contraband_unlocked = FALSE

	/// Prevents audit printing from being spammed.
	COOLDOWN_DECLARE(audit_print_cooldown)

/obj/machinery/computer/ccpost_logistics/examine(mob/user)
	. = ..()

	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return

	. += span_notice("Operational Allocation: [network.allocation] / [network.max_allocation] CU.")
	. += span_notice("Available Allocation: [network.get_available_allocation()] CU.")

	if(contraband_unlocked)
		. += span_warning("Its procurement authorization safeguards appear to have been bypassed.")

/obj/machinery/computer/ccpost_logistics/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.registered_terminals |= src


/obj/machinery/computer/ccpost_logistics/Destroy()
	GLOB.ccpost_logistics_network.registered_terminals -= src

	return ..()

/obj/machinery/computer/ccpost_logistics/multitool_act(mob/living/user, obj/item/tool)
	if(contraband_unlocked)
		balloon_alert(user, "routing override already active")
		return

	contraband_unlocked = TRUE

	tool.play_tool_sound(src, 35)

	balloon_alert(user, "procurement safeguards bypassed")

	say("WARNING: Procurement authorization matrix compromised. Unregistered vendor routes are now accessible.")

	SStgui.update_uis(src)

	return TRUE

// TGUI

/obj/machinery/computer/ccpost_logistics/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CCPostLogistics", name)
		ui.open()


/obj/machinery/computer/ccpost_logistics/ui_data(mob/user)
	var/list/data = list()

	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return data

	data["allocation"] = network.allocation
	data["reserved_allocation"] = network.reserved_allocation
	data["available_allocation"] = network.get_available_allocation()
	data["max_allocation"] = network.max_allocation
	data["contraband_unlocked"] = contraband_unlocked

	data["active_shipments"] = network.get_active_shipment_count()
	data["max_active_shipments"] = network.max_active_shipments

	var/datum/ccpost_freight_conditions/current_conditions = network.get_current_freight_conditions()

	data["freight_status"] = current_conditions.status
	data["authorization_delay"] = round(current_conditions.authorization_delay / (1 SECONDS))
	data["dispatch_delay"] = round(current_conditions.dispatch_delay / (1 SECONDS))
	data["transit_delay"] = round(current_conditions.get_transit_delay() / (1 SECONDS))
	data["freight_reasons"] = current_conditions.reasons.Copy()

	qdel(current_conditions)

	var/list/catalog_data = list()
	var/medical_recall_active = GLOB.ccpost_sector_network.is_medical_supply_recall_active()

	data["medical_recall_active"] = medical_recall_active
	data["restricted_procurement_suspended"] = network.is_restricted_procurement_suspended()
	data["restricted_procurement_seconds"] = round(network.get_restricted_procurement_suspension_remaining() / (1 SECONDS))

	for(var/package_id in network.supply_catalog)
		var/datum/ccpost_supply_package/package = network.supply_catalog[package_id]

		if(!package)
			continue

		// Restricted packages are never sent to an unhacked terminal.
		if(package.contraband && !contraband_unlocked)
			continue

		// Medical stock remains visible during a recall, but every package in
		// the Medical category is locked until Central Medical Logistics clears it.
		var/recall_locked = FALSE
		if(package.category == "Medical" && medical_recall_active)
			recall_locked = TRUE

		var/can_order_package = package.cost <= network.get_available_allocation() && network.get_active_shipment_count() < network.max_active_shipments

		if(recall_locked)
			can_order_package = FALSE

		if(package.contraband && network.is_restricted_procurement_suspended())
			can_order_package = FALSE

		catalog_data += list(list(
			"id" = package.id,
			"name" = package.name,
			"description" = package.desc,
			"category" = package.category,
			"cost" = package.cost,
			"contraband" = package.contraband,
			"recall_locked" = recall_locked,
			"can_order" = can_order_package
		))

	data["catalog"] = catalog_data

	var/list/shipment_data = list()

	for(var/datum/ccpost_shipment/shipment as anything in network.shipments)
		if(QDELETED(shipment))
			continue

		shipment_data += list(list(
			"code" = shipment.shipment_code,
			"package_name" = shipment.package?.name,
			"cost" = shipment.package?.cost,
			"contraband" = shipment.package?.contraband,
			"requested_by" = shipment.requested_by,
			"requested_at" = shipment.requested_at,
			"status" = shipment.status,
			"updated_at" = shipment.status_updated_at,
			"authorization_delay" = round(shipment.authorization_delay / (1 SECONDS)),
			"dispatch_delay" = round(shipment.dispatch_delay / (1 SECONDS)),
			"transit_delay" = round(shipment.transit_delay / (1 SECONDS)),
			"freight_condition_status" = shipment.freight_condition_status,
			"freight_condition_reasons" = shipment.freight_condition_reasons,
			"failure_reason" = shipment.failure_reason
		))

	data["shipments"] = shipment_data

	var/list/ledger_data = list()

	for(var/list/ledger_entry as anything in network.allocation_ledger)
		ledger_data += list(list(
			"time" = ledger_entry["time"],
			"amount" = ledger_entry["amount"],
			"reason" = ledger_entry["reason"],
			"actor" = ledger_entry["actor"]
		))

	data["ledger"] = ledger_data

	return data

// LOGISTICS TERMINAL ACTIONS


/obj/machinery/computer/ccpost_logistics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	var/mob/user = ui.user
	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return FALSE

	switch(action)
		if("order_package")
			var/package_id = params["package_id"]
			var/datum/ccpost_supply_package/package = network.get_supply_package(package_id)

			if(!package)
				balloon_alert(user, "invalid requisition")
				return TRUE

			if(package.contraband && !contraband_unlocked)
				balloon_alert(user, "requisition authorization denied")
				return TRUE

			if(package.contraband && network.is_restricted_procurement_suspended())
				balloon_alert(user, "restricted procurement suspended")
				return TRUE

			if(package.category == "Medical" && GLOB.ccpost_sector_network.is_medical_supply_recall_active())
				balloon_alert(user, "medical supply recall active")
				return TRUE

			if(network.get_active_shipment_count() >= network.max_active_shipments)
				balloon_alert(user, "shipment queue full")
				return TRUE

			if(package.cost > network.get_available_allocation())
				balloon_alert(user, "insufficient allocation")
				return TRUE

			var/datum/ccpost_shipment/shipment = network.create_shipment(
				package_id,
				user.name,
				contraband_unlocked
			)

			if(!shipment)
				balloon_alert(user, "requisition failed")
				return TRUE

			balloon_alert(user, "requisition queued")
			return TRUE

		if("print_shipment")
			var/shipment_code = params["shipment_code"]

			var/datum/ccpost_shipment/shipment = network.find_shipment(
				shipment_code
			)

			if(!shipment)
				balloon_alert(
					user,
					"shipment record not found"
				)

				return TRUE

			if(!COOLDOWN_FINISHED(src, audit_print_cooldown))
				balloon_alert(
					user,
					"printer cooling down"
				)

				return TRUE

			COOLDOWN_START(src, audit_print_cooldown, 5 SECONDS)

			playsound(
				src,
				'sound/machines/printer.ogg',
				vol = 50,
				vary = FALSE
			)

			visible_message(
				span_notice("[src] prints a freight requisition record.")
			)

			print_shipment_record(
				shipment,
				user.name
			)

			balloon_alert(
				user,
				"shipment record printed"
			)

			return TRUE


		if("print_shipment_log")
			if(!COOLDOWN_FINISHED(src, audit_print_cooldown))
				balloon_alert(
					user,
					"printer cooling down"
				)

				return TRUE

			COOLDOWN_START(src, audit_print_cooldown, 5 SECONDS)

			playsound(
				src,
				'sound/machines/printer.ogg',
				vol = 50,
				vary = FALSE
			)

			visible_message(
				span_notice("[src] prints a Central Command shipment audit.")
			)

			print_shipment_audit(
				network,
				user.name
			)

			balloon_alert(
				user,
				"shipment audit printed"
			)

			return TRUE


		if("print_ledger")
			if(!COOLDOWN_FINISHED(src, audit_print_cooldown))
				balloon_alert(
					user,
					"printer cooling down"
				)

				return TRUE

			COOLDOWN_START(src, audit_print_cooldown, 5 SECONDS)

			playsound(
				src,
				'sound/machines/printer.ogg',
				vol = 50,
				vary = FALSE
			)

			visible_message(
				span_notice("[src] prints an operational allocation audit.")
			)

			print_allocation_ledger(
				network,
				user.name
			)

			balloon_alert(
				user,
				"allocation audit printed"
			)

			return TRUE


	return FALSE

// ////////////////////////////////////
// Logistics Package System
// ////////////////////////////////////

/// Creates one physical audit paper at the logistics terminal.
/obj/machinery/computer/ccpost_logistics/proc/print_audit_page(
	paper_name,
	paper_text
)
	var/obj/item/paper/audit_page = new /obj/item/paper(
		drop_location()
	)

	audit_page.name = paper_name
	audit_page.add_raw_text(paper_text)
	audit_page.update_appearance()

	return audit_page


/// Prints a detailed record for one freight requisition.
/obj/machinery/computer/ccpost_logistics/proc/print_shipment_record(
	datum/ccpost_shipment/shipment,
	generated_by
)
	if(!shipment || QDELETED(shipment))
		return

	var/package_name = "UNKNOWN PACKAGE"
	var/package_cost = 0
	var/procurement_class = "UNKNOWN"

	if(shipment.package)
		package_name = sanitize(shipment.package.name)
		package_cost = shipment.package.cost

		if(shipment.package.contraband)
			procurement_class = "RESTRICTED PROCUREMENT"
		else
			procurement_class = "STANDARD PROCUREMENT"

	var/requested_by = shipment.requested_by ? sanitize(shipment.requested_by) : "UNKNOWN"
	var/requested_at = shipment.requested_at ? shipment.requested_at : "N/A"

	var/authorized_at = shipment.authorized_at ? shipment.authorized_at : "N/A"
	var/dispatched_at = shipment.dispatched_at ? shipment.dispatched_at : "N/A"
	var/delivered_at = shipment.delivered_at ? shipment.delivered_at : "N/A"

	var/updated_at = shipment.status_updated_at ? shipment.status_updated_at : "N/A"

	var/safe_generated_by = generated_by ? sanitize(generated_by) : "UNKNOWN"

	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"

	var/report_text = "<center><b>CENTRAL COMMAND LOGISTICS</b></center>"
	report_text += "<center><b>FREIGHT REQUISITION RECORD</b></center><hr>"

	report_text += "<b>Reference:</b> [shipment.shipment_code]<br>"
	report_text += "<b>Classification:</b> [procurement_class]<br>"
	report_text += "<b>Package:</b> [package_name]<br>"
	report_text += "<b>Allocation Cost:</b> [package_cost] CU<br><br>"

	report_text += "<b>Requested By:</b> [requested_by]<br>"
	report_text += "<b>Requested At:</b> [requested_at]<br>"
	report_text += "<b>Authorized At:</b> [authorized_at]<br>"
	report_text += "<b>Dispatched At:</b> [dispatched_at]<br>"
	report_text += "<b>Delivered At:</b> [delivered_at]<br><br>"

	report_text += "<b>Status:</b> [shipment.status]<br>"
	report_text += "<b>Last Status Update:</b> [updated_at]<br><br>"

	report_text += "<b>Sector Freight Profile:</b> [shipment.freight_condition_status]<br>"
	report_text += "<b>Authorization Delay:</b> [round(shipment.authorization_delay / (1 SECONDS))] seconds<br>"
	report_text += "<b>Dispatch Delay:</b> [round(shipment.dispatch_delay / (1 SECONDS))] seconds<br>"
	report_text += "<b>Transit Delay:</b> [round(shipment.transit_delay / (1 SECONDS))] seconds<br>"

	if(length(shipment.freight_condition_reasons))
		report_text += "<br><b>Applied Sector Factors:</b><br>"

		for(var/reason in shipment.freight_condition_reasons)
			report_text += "- [sanitize("[reason]")]<br>"

	else
		report_text += "<br><b>Applied Sector Factors:</b> None<br>"

	if(shipment.failure_reason)
		report_text += "<br><b>Failure Reason:</b> [sanitize(shipment.failure_reason)]<br>"

	report_text += "<br><hr>"
	report_text += "<b>Terminal Status:</b> [terminal_status]<br>"
	report_text += "<b>Audit Generated:</b> [station_time_timestamp()]<br>"
	report_text += "<b>Generated By:</b> [safe_generated_by]<br>"
	report_text += "<br><i>Central Command Sector Logistics Coordination</i>"

	print_audit_page(
		"Freight Requisition Record - [shipment.shipment_code]",
		report_text
	)


/// Prints the complete shipment history in pages of ten requisitions.
/obj/machinery/computer/ccpost_logistics/proc/print_shipment_audit(
	datum/ccpost_logistics_network/network,
	generated_by
)
	if(!network)
		return

	var/safe_generated_by = generated_by ? sanitize(generated_by) : "UNKNOWN"

	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"

	var/page_size = 10
	var/page_number = 1

	if(!length(network.shipments))
		var/empty_text = "<center><b>CENTRAL COMMAND LOGISTICS</b></center>"
		empty_text += "<center><b>SHIPMENT AUDIT RECORD</b></center><hr>"
		empty_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		empty_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		empty_text += "<b>Terminal Status:</b> [terminal_status]<br><br>"
		empty_text += "No freight requisitions have been recorded.<br>"
		empty_text += "<br><hr><i>Central Command Sector Logistics Coordination</i>"

		print_audit_page(
			"Central Command Shipment Audit",
			empty_text
		)

		return

	var/start_index = 1

	while(start_index <= length(network.shipments))
		var/end_index = min(
			start_index + page_size - 1,
			length(network.shipments)
		)

		var/report_text = "<center><b>CENTRAL COMMAND LOGISTICS</b></center>"
		report_text += "<center><b>SHIPMENT AUDIT RECORD - PAGE [page_number]</b></center><hr>"

		report_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		report_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		report_text += "<b>Terminal Status:</b> [terminal_status]<br>"
		report_text += "<b>Recorded Shipments:</b> [length(network.shipments)]<br><hr><br>"

		for(var/index in start_index to end_index)
			var/datum/ccpost_shipment/shipment = network.shipments[index]

			if(!shipment || QDELETED(shipment))
				continue

			var/package_name = "UNKNOWN PACKAGE"
			var/package_cost = 0
			var/restricted_marker = ""

			if(shipment.package)
				package_name = sanitize(shipment.package.name)
				package_cost = shipment.package.cost

				if(shipment.package.contraband)
					restricted_marker = " <b>RESTRICTED</b>"

			var/requested_by = shipment.requested_by ? sanitize(shipment.requested_by) : "UNKNOWN"
			var/requested_at = shipment.requested_at ? shipment.requested_at : "N/A"
			var/updated_at = shipment.status_updated_at ? shipment.status_updated_at : "N/A"

			report_text += "<b>[shipment.shipment_code]</b>[restricted_marker]<br>"
			report_text += "Package: [package_name]<br>"
			report_text += "Cost: [package_cost] CU<br>"
			report_text += "Requested By: [requested_by]<br>"
			report_text += "Requested At: [requested_at]<br>"
			report_text += "Status: [shipment.status]<br>"
			report_text += "Last Update: [updated_at]<br>"

			if(shipment.failure_reason)
				report_text += "Failure: [sanitize(shipment.failure_reason)]<br>"

			report_text += "<br>"

		report_text += "<hr><i>Central Command Sector Logistics Coordination</i>"

		print_audit_page(
			"Central Command Shipment Audit - Page [page_number]",
			report_text
		)

		start_index = end_index + 1
		page_number++


/// Prints the allocation ledger in pages of fifteen transactions.
/obj/machinery/computer/ccpost_logistics/proc/print_allocation_ledger(
	datum/ccpost_logistics_network/network,
	generated_by
)
	if(!network)
		return

	var/safe_generated_by = generated_by ? sanitize(generated_by) : "UNKNOWN"

	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"

	var/page_size = 15
	var/page_number = 1

	if(!length(network.allocation_ledger))
		var/empty_text = "<center><b>CENTRAL COMMAND</b></center>"
		empty_text += "<center><b>OPERATIONAL ALLOCATION AUDIT</b></center><hr>"

		empty_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		empty_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		empty_text += "<b>Terminal Status:</b> [terminal_status]<br><br>"

		empty_text += "<b>Current Allocation:</b> [network.allocation] / [network.max_allocation] CU<br>"
		empty_text += "<b>Reserved Allocation:</b> [network.reserved_allocation] CU<br>"
		empty_text += "<b>Available Allocation:</b> [network.get_available_allocation()] CU<br><br>"

		empty_text += "No allocation transactions have been recorded.<br>"
		empty_text += "<br><hr><i>Central Command Financial Oversight</i>"

		print_audit_page(
			"Central Command Allocation Audit",
			empty_text
		)

		return

	var/start_index = 1

	while(start_index <= length(network.allocation_ledger))
		var/end_index = min(
			start_index + page_size - 1,
			length(network.allocation_ledger)
		)

		var/report_text = "<center><b>CENTRAL COMMAND</b></center>"
		report_text += "<center><b>OPERATIONAL ALLOCATION AUDIT - PAGE [page_number]</b></center><hr>"

		report_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		report_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		report_text += "<b>Terminal Status:</b> [terminal_status]<br><br>"

		report_text += "<b>Current Allocation:</b> [network.allocation] / [network.max_allocation] CU<br>"
		report_text += "<b>Reserved Allocation:</b> [network.reserved_allocation] CU<br>"
		report_text += "<b>Available Allocation:</b> [network.get_available_allocation()] CU<br>"
		report_text += "<b>Recorded Transactions:</b> [length(network.allocation_ledger)]<br><hr><br>"

		for(var/index in start_index to end_index)
			var/list/ledger_entry = network.allocation_ledger[index]

			if(!ledger_entry)
				continue

			var/entry_time = "N/A"
			var/entry_amount = 0
			var/entry_reason = "Unspecified transaction"
			var/entry_actor = "SYSTEM"
			var/amount_prefix = ""

			var/raw_time = ledger_entry["time"]
			var/raw_amount = ledger_entry["amount"]
			var/raw_reason = ledger_entry["reason"]
			var/raw_actor = ledger_entry["actor"]

			if(raw_time)
				entry_time = "[raw_time]"

			if(isnum(raw_amount))
				entry_amount = raw_amount

			if(raw_reason)
				entry_reason = sanitize("[raw_reason]")

			if(raw_actor)
				entry_actor = sanitize("[raw_actor]")

			if(entry_amount > 0)
				amount_prefix = "+"

			report_text += "<b>[entry_time] | [amount_prefix][entry_amount] CU</b><br>"
			report_text += "Reason: [entry_reason]<br>"
			report_text += "Recorded By: [entry_actor]<br><br>"

		report_text += "<hr><i>Central Command Financial Oversight</i>"

		print_audit_page(
			"Central Command Allocation Audit - Page [page_number]",
			report_text
		)

		start_index = end_index + 1
		page_number++

/datum/ccpost_supply_package
	var/id = "undefined"
	var/name = "Undefined Supply Package"
	var/desc = "No package description available."
	var/category = "General"
	var/cost = 0

	/// Restricted packages are only visible and orderable through a compromised terminal.
	var/contraband = FALSE

	/// Internal Compliance risk weighting used when restricted procurement is audited.
	/// Harmless novelty contraband is low-risk; tactical or hostile equipment is higher-risk.
	var/audit_risk = 0

	var/list/contains = list()


/datum/ccpost_supply_package/proc/fill_crate(obj/structure/closet/crate/ccpost_freight/freight_crate)
	if(!freight_crate)
		return

	for(var/item_type in contains)
		var/amount = contains[item_type]

		if(!isnum(amount) || amount < 1)
			amount = 1

		for(var/i in 1 to amount)
			new item_type(freight_crate)

// ////////////////////////////////////
// Logistics CATALOG START
// ////////////////////////////////////

// ADMINISTRATION

/datum/ccpost_supply_package/administrative
	id = "administrative"
	name = "Administrative Supplies"
	desc = "Replacement paperwork, writing implements, and general administrative equipment."
	category = "Administration"
	cost = 4

	contains = list(
		/obj/item/paper_bin = 1,
		/obj/item/pen = 2,
		/obj/item/stamp/granted = 1,
		/obj/item/stamp/denied = 1,
		/obj/item/stamp/centcom = 1
	)

/datum/ccpost_supply_package/administrative/records
	id = "records_filing"
	name = "Records & Filing Package"
	desc = "Expanded records-management supplies for installations experiencing dangerous levels of unfiled paperwork."
	cost = 6

	contains = list(
		/obj/structure/filingcabinet/chestdrawer/wheeled = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/hand_labeler_refill = 2,
		/obj/item/paper_bin = 1,
		/obj/item/paper_bin/carbon = 1,
		/obj/item/folder/blue = 1,
		/obj/item/folder/red = 1,
		/obj/item/folder/yellow = 1,
		/obj/item/clipboard = 2,
		/obj/item/storage/box/fountainpens = 1
	)


// SUSTENANCE

/datum/ccpost_supply_package/sustenance
	id = "sustenance"
	name = "Basic Sustenance Package"
	desc = "A modest selection of pre-approved meals for remote installation personnel."
	category = "Sustenance"
	cost = 5

	contains = list(
		/obj/item/food/vendor_tray_meal/side = 2,
		/obj/item/food/vendor_tray_meal/side/crackers_and_cheese = 2,
		/obj/item/food/vendor_tray_meal/sushi = 2,
		/obj/item/food/vendor_tray_meal/side/rice = 2,
		/obj/item/food/vendor_tray_meal/burger = 2,
		/obj/item/food/vendor_tray_meal/chicken_sandwich = 2,
		/obj/item/food/vendor_tray_meal = 2
	)

/datum/ccpost_supply_package/sustenance/rations
	id = "emergency_rations"
	name = "Emergency Ration Package"
	desc = "Three sealed surplus ration boxes intended for extended isolation, delayed freight, or culinary emergencies."
	cost = 4

	contains = list(
		/obj/item/storage/box/mothic_rations = 3
	)

/datum/ccpost_supply_package/sustenance/coffee
	id = "coffee_refreshments"
	name = "Coffee & Refreshments Package"
	desc = "A complete coffee-service restock for maintaining alertness, morale, and the appearance of productivity."
	cost = 6

	contains = list(
		/obj/item/storage/box/coffeepack/robusta = 1,
		/obj/item/storage/box/coffeepack = 1,
		/obj/item/reagent_containers/cup/coffeepot = 1,
		/obj/item/storage/fancy/coffee_condi_display = 1,
		/obj/item/reagent_containers/cup/glass/bottle/juice/cream = 1,
		/obj/item/reagent_containers/condiment/milk = 1,
		/obj/item/reagent_containers/condiment/soymilk = 1,
		/obj/item/reagent_containers/condiment/sugar = 1,
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel = 1
	)

/datum/ccpost_supply_package/sustenance/luxury
	id = "luxury_goods"
	name = "Luxury Goods Crate"
	desc = "A curated assortment of premium consumables intended for executive hospitality, visiting officials, and approved morale expenditure."
	cost = 11

	contains = list(
		/obj/item/food/moonfish_caviar = 2,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 1,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 2,
		/obj/item/food/pistachios = 2
	)


// MEDICAL

/datum/ccpost_supply_package/medical
	id = "medical"
	name = "Medical Resupply Package"
	desc = "Basic medical supplies intended for routine injuries and oxygen-related emergencies."
	category = "Medical"
	cost = 8

	contains = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/o2 = 1,
		/obj/item/storage/medkit/fire = 1
	)

/datum/ccpost_supply_package/medical/trauma
	id = "medical_trauma"
	name = "Trauma Treatment Package"
	desc = "Rapid-response medication and wound-care supplies for stabilizing serious injuries before evacuation or surgery."
	cost = 7

	contains = list(
		/obj/item/reagent_containers/medipen = 2,
		/obj/item/reagent_containers/medipen/ekit = 3,
		/obj/item/reagent_containers/medipen/blood_loss = 3,
		/obj/item/stack/medical/gauze = 2
	)

/datum/ccpost_supply_package/medical/blood_fluids
	id = "medical_blood_fluids"
	name = "Blood & Fluid Resupply"
	desc = "A compact blood and saline reserve for treating blood loss and supporting emergency transfusion procedures."
	cost = 7

	contains = list(
		/obj/item/reagent_containers/blood/o_minus = 3,
		/obj/item/reagent_containers/blood/a_plus = 1,
		/obj/item/reagent_containers/blood/b_plus = 1,
		/obj/item/reagent_containers/chem_pack/saline = 3
	)

/datum/ccpost_supply_package/medical/defibrillators
	id = "medical_defibrillators"
	name = "Defibrillator Package"
	desc = "Two loaded defibrillators for installations expecting cardiac emergencies, major trauma, or questionable workplace decisions."
	cost = 9

	contains = list(
		/obj/item/defibrillator/loaded = 2
	)

/datum/ccpost_supply_package/medical/surgery
	id = "medical_surgical"
	name = "Surgical Support Package"
	desc = "A compact set of surgical supplies for emergency procedures when routine medical support is unavailable."
	cost = 10

	contains = list(
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/emergency_bed = 1
	)

// ENGINEERING

/datum/ccpost_supply_package/engineering
	id = "engineering"
	name = "Engineering Maintenance Package"
	desc = "Tools and replacement materials for routine outpost maintenance."
	category = "Engineering"
	cost = 9

	contains = list(
		/obj/item/stack/sheet/mineral/plasma/twenty = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/storage/box/lights/tubes = 1,
		/obj/item/storage/box/lights/bulbs = 1
	)

/datum/ccpost_supply_package/engineering/toolboxes
	id = "engineering_toolboxes"
	name = "Toolbox Package"
	desc = "A reserve of electrical and mechanical toolboxes for repairs, maintenance, and emergency improvisation."
	cost = 7

	contains = list(
		/obj/item/storage/toolbox/electrical = 2,
		/obj/item/storage/toolbox/mechanical = 2
	)

/datum/ccpost_supply_package/engineering/electrical
	id = "engineering_electrical"
	name = "Electrical Repair Package"
	desc = "Insulated gloves, replacement power cells, and cable for restoring damaged electrical systems."
	cost = 9

	contains = list(
		/obj/item/clothing/gloves/color/yellow = 2,
		/obj/item/stock_parts/power_store/cell/high = 3,
		/obj/item/stack/cable_coil = 2
	)

/datum/ccpost_supply_package/engineering/atmos
	id = "engineering_atmos"
	name = "Atmospheric Recovery Package"
	desc = "Portable atmospheric equipment for recovering air, clearing contaminants, and repairing avoidable ventilation mistakes."
	cost = 12

	contains = list(
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1
	)

/datum/ccpost_supply_package/engineering/breach
	id = "engineering_breach"
	name = "Hull Breach Response Package"
	desc = "Anti-breach shield projectors and metal-foam supplies for rapid containment of structural damage."
	cost = 14

	contains = list(
		/obj/machinery/shieldgen = 2,
		/obj/item/storage/box/metalfoam = 1
	)

/datum/ccpost_supply_package/engineering/power
	id = "engineering_power"
	name = "Portable Power Package"
	desc = "Portable power-induction equipment and high-capacity cells for keeping essential systems running away from fixed chargers."
	cost = 10

	contains = list(
		/obj/item/inducer/orderable = 2,
		/obj/item/stock_parts/power_store/cell/high = 2
	)


// MATERIALS

/datum/ccpost_supply_package/materials/construction
	id = "materials_construction"
	name = "Construction Materials Package"
	desc = "Bulk iron, glass, and plastic stock for routine construction, repairs, and approved installation improvements."
	category = "Materials"
	cost = 10

	contains = list(
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/plastic/fifty = 1
	)

/datum/ccpost_supply_package/materials/emergency
	id = "materials_emergency"
	name = "Emergency Repair Materials"
	desc = "Reinforced construction stock and breach-control supplies intended for significant structural damage."
	category = "Materials"
	cost = 12

	contains = list(
		/obj/item/stack/sheet/plasteel/twenty = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/storage/box/metalfoam = 2
	)


// TECHNICAL

/datum/ccpost_supply_package/technical/advanced_parts
	id = "technical_parts"
	name = "Advanced Parts Package"
	desc = "Contains a rapid part exchanger and supporting equipment for maintaining damaged machinery."
	category = "Technical"
	cost = 12

	contains = list(
		/obj/item/storage/part_replacer = 1,
		/obj/item/stock_parts/power_store/cell/high = 5,
		/obj/item/stock_parts/matter_bin/super = 10,
		/obj/item/stock_parts/micro_laser/quadultra = 10,
		/obj/item/stock_parts/manipulator/nano = 10,
		/obj/item/stock_parts/capacitor/quadratic = 10
	)

/datum/ccpost_supply_package/technical/robotics
	id = "technical_robotics"
	name = "Robotics Utility Package"
	desc = "Basic bot assemblies, sensors, and robotic components for constructing simple support machines."
	category = "Technical"
	cost = 15

	contains = list(
		/obj/item/assembly/prox_sensor = 4,
		/obj/item/bodypart/arm/left/robot = 4,
		/obj/item/healthanalyzer = 1,
		/obj/item/clothing/head/utility/hardhat = 1,
		/obj/item/bot_assembly/floorbot = 1,
		/obj/item/bot_assembly/firebot = 1,
		/obj/item/bot_assembly/medbot = 1,
		/obj/item/bot_assembly/cleanbot = 1
	)


// EMERGENCY

/datum/ccpost_supply_package/eva
	id = "eva"
	name = "Emergency EVA Package"
	desc = "Basic equipment for emergency operations in depressurized environments."
	category = "Emergency"
	cost = 12

	contains = list(
		/obj/item/clothing/suit/space = 1,
		/obj/item/clothing/head/helmet/space = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/clothing/mask/breath = 1
	)

/datum/ccpost_supply_package/emergency/firefighting
	id = "emergency_firefighting"
	name = "Firefighting Package"
	desc = "Protective equipment and extinguishing gear for responding to major fires and heat hazards."
	category = "Emergency"
	cost = 10

	contains = list(
		/obj/item/clothing/suit/utility/fire/firefighter = 2,
		/obj/item/clothing/mask/gas = 2,
		/obj/item/flashlight = 2,
		/obj/item/tank/internals/oxygen/yellow = 2,
		/obj/item/extinguisher/advanced = 2,
		/obj/item/clothing/head/utility/hardhat/fire = 2,
		/obj/item/clothing/gloves/color/black = 2
	)

/datum/ccpost_supply_package/emergency/internals
	id = "emergency_internals"
	name = "Emergency Internals Package"
	desc = "Breathing masks and portable oxygen supplies for atmospheric emergencies and evacuation."
	category = "Emergency"
	cost = 7

	contains = list(
		/obj/item/clothing/mask/gas = 3,
		/obj/item/clothing/mask/breath = 3,
		/obj/item/tank/internals/emergency_oxygen = 3,
		/obj/item/tank/internals/oxygen = 3
	)

/datum/ccpost_supply_package/emergency/mass_casualty
	id = "emergency_mass_casualty"
	name = "Mass Casualty Package"
	desc = "A broad medical reserve intended for incidents producing more casualties than the outpost's routine stock can comfortably support."
	category = "Emergency"
	cost = 15

	contains = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/o2 = 1,
		/obj/item/storage/medkit/toxin = 1,
		/obj/item/storage/medkit/brute = 1,
		/obj/item/storage/medkit/fire = 1,
		/obj/item/defibrillator/loaded = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/stack/medical/gauze = 2
	)


// SECURITY

/datum/ccpost_supply_package/security
	id = "security"
	name = "Security Support Package"
	desc = "Limited defensive equipment intended for protection of Central Command personnel and property."
	category = "Security"
	cost = 18

	contains = list(
		/obj/item/clothing/suit/armor/vest/alt/sec/private = 2,
		/obj/item/clothing/head/helmet/swat/nanotrasen = 2,
		/obj/item/gun/energy/e_gun/mini = 2,
		/obj/item/clothing/gloves/combat = 2
	)

/datum/ccpost_supply_package/security/nonlethal
	id = "security_nonlethal"
	name = "Non-Lethal Response Package"
	desc = "Additional restraint and incapacitation equipment intended for defensive response without lethal escalation."
	cost = 12

	contains = list(
		/obj/item/gun/energy/disabler = 2,
		/obj/item/melee/baton/security/loaded = 2,
		/obj/item/storage/box/handcuffs = 1
	)

/datum/ccpost_supply_package/security/protective
	id = "security_protective"
	name = "Protective Equipment Package"
	desc = "Standard armor and protective equipment for reinforcing outpost security during elevated threats."
	cost = 15

	contains = list(
		/obj/item/clothing/suit/armor/vest = 2,
		/obj/item/clothing/head/helmet/sec = 2,
		/obj/item/clothing/gloves/combat = 2
	)

/datum/ccpost_supply_package/security/containment
	id = "security_containment"
	name = "Biological Containment Package"
	desc = "Protective suits, pathology equipment, and portable barriers for isolating suspected biological hazards."
	cost = 14

	contains = list(
		/obj/item/clothing/head/bio_hood/security = 2,
		/obj/item/clothing/suit/bio_suit/security = 2,
		/obj/item/reagent_containers/syringe/antiviral = 2,
		/obj/item/clothing/gloves/latex/nitrile = 2,
		/obj/item/clothing/glasses/pathology = 2,
		/obj/item/holosign_creator/medical = 2
	)


// ENTERTAINMENT

/datum/ccpost_supply_package/entertainment/bunny
	id = "entertainment_centcom_bunny"
	name = "CentCom Bunny Attire Package"
	desc = "A complete set of approved Central Command hospitality attire for formal receptions, morale initiatives, and other duties which Human Resources has declined to explain."
	category = "Entertainment"
	cost = 8

	contains = list(
		/obj/item/clothing/under/costume/playbunny/centcom = 1,
		/obj/item/clothing/suit/jacket/tailcoat/centcom = 1,
		/obj/item/clothing/shoes/heels/centcom = 1,
		/obj/item/clothing/head/playbunnyears/centcom = 1,
		/obj/item/clothing/neck/tie/bunnytie/centcom/tied = 1,
		/obj/item/clothing/gloves/color/white = 1
	)

/datum/ccpost_supply_package/entertainment/cards
	id = "entertainment_cards"
	name = "Card & Table Games Package"
	desc = "Cards, dice, and a company-approved tabletop diversion for personnel with sufficient unallocated time."
	category = "Entertainment"
	cost = 4

	contains = list(
		/obj/item/toy/cards/deck = 2,
		/obj/item/dice/d6 = 12,
		/obj/item/paper/guides/knucklebone = 1,
		/obj/item/toy/crayon/white = 1
	)

/datum/ccpost_supply_package/entertainment/lasertag
	id = "entertainment_lasertag"
	name = "Laser Tag Recreation Package"
	desc = "Two complete opposing laser-tag teams for structured recreational conflict that is considerably cheaper than actual security incidents."
	category = "Entertainment"
	cost = 7

	contains = list(
		/obj/item/gun/energy/laser/redtag = 2,
		/obj/item/gun/energy/laser/bluetag = 2,
		/obj/item/clothing/suit/redtag = 2,
		/obj/item/clothing/suit/bluetag = 2,
		/obj/item/clothing/head/helmet/redtaghelm = 2,
		/obj/item/clothing/head/helmet/bluetaghelm = 2
	)

/datum/ccpost_supply_package/entertainment/morale
	id = "entertainment_morale"
	name = "Corporate Morale Package"
	desc = "A pre-approved assortment of recreational materials intended to maintain employee morale without meaningfully impacting productivity."
	category = "Entertainment"
	cost = 6

	contains = list(
		/obj/item/storage/box/balloons = 1,
		/obj/item/pinata = 1,
		/obj/item/melee/baseball_bat = 1,
		/obj/item/clothing/glasses/blindfold = 1,
		/obj/item/flashlight/glowstick = 2,
		/obj/item/flashlight/glowstick/blue = 1,
		/obj/item/flashlight/glowstick/cyan = 1
	)

/datum/ccpost_supply_package/entertainment/music
	id = "entertainment_music"
	name = "Music & Leisure Package"
	desc = "A selection of portable musical instruments for sanctioned recreation and unsanctioned hallway concerts."
	category = "Entertainment"
	cost = 8

	contains = list(
		/obj/item/instrument/violin = 1,
		/obj/item/instrument/guitar = 1,
		/obj/item/instrument/accordion = 1,
		/obj/item/instrument/saxophone = 1,
		/obj/item/instrument/recorder = 1,
		/obj/item/instrument/harmonica = 1
	)

/datum/ccpost_supply_package/entertainment/formal
	id = "entertainment_formal"
	name = "Formal Social Package"
	desc = "A small wardrobe of formal clothing suitable for receptions, ceremonies, and meetings where appearing expensive is operationally useful."
	category = "Entertainment"
	cost = 8

	contains = list(
		/obj/item/clothing/under/suit/black_really = 2,
		/obj/item/clothing/under/suit/black_really/skirt = 2,
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/clothing/neck/tie/blue = 1,
		/obj/item/clothing/neck/tie/red = 1,
		/obj/item/clothing/neck/tie/black = 1,
		/obj/item/clothing/head/hats/bowler = 1,
		/obj/item/clothing/head/hats/tophat = 1,
		/obj/item/clothing/shoes/laceup = 2
	)

/datum/ccpost_supply_package/entertainment/costumes
	id = "entertainment_costumes"
	name = "Costume Package"
	desc = "An assortment of harmless theatrical costumes for morale events, dramatic reenactments, and regrettable photographs."
	category = "Entertainment"
	cost = 6

	contains = list(
		/obj/item/clothing/head/costume/snowman = 1,
		/obj/item/clothing/suit/costume/snowman = 1,
		/obj/item/clothing/head/costume/chicken = 1,
		/obj/item/clothing/suit/costume/chickensuit = 1,
		/obj/item/clothing/mask/gas/monkeymask = 1,
		/obj/item/clothing/suit/costume/monkeysuit = 1,
		/obj/item/clothing/suit/hooded/bee_costume = 1
	)

/datum/ccpost_supply_package/entertainment/plushies
	id = "entertainment_plushies"
	name = "Plushie Assortment"
	desc = "A selection of soft corporate-approved companions for isolated personnel, decorative use, and entirely professional desk arrangements."
	category = "Entertainment"
	cost = 5

	contains = list(
		/obj/item/toy/plush/carpplushie = 1,
		/obj/item/toy/plush/slimeplushie = 1,
		/obj/item/toy/plush/lizard_plushie/greyscale = 1,
		/obj/item/toy/plush/snakeplushie = 1,
		/obj/item/toy/plush/moth = 1,
		/obj/item/toy/plush/beeplushie = 1
	)


// CONTRABAND

/datum/ccpost_supply_package/contraband
	category = "Restricted"
	contraband = TRUE

/datum/ccpost_supply_package/contraband/ert_equipment
	audit_risk = 5
	id = "ert_equipment"
	name = "Emergency Response Team Equipment"
	desc = "Unregistered Emergency Response Team equipment routed through an unauthorized Central Command procurement channel."
	cost = 45
	contains = list(
		/obj/item/storage/box/emps = 1,
		/obj/item/storage/belt/security = 1,
		/obj/item/gun/ballistic/revolver/mateba = 1,
		/obj/item/ammo_box/a357 = 1,
		/obj/item/clothing/glasses/hud/security/night = 1,
		/obj/item/restraints/handcuffs = 2,
		/obj/item/clothing/gloves/combat = 1,
		/obj/item/clothing/suit/space/ert = 1,
		/obj/item/clothing/head/helmet/space/ert = 1
	)

/datum/ccpost_supply_package/contraband/restricted_uniform
	audit_risk = 3
	id = "restricted_uniform"
	name = "Restricted Personnel Uniforms"
	desc = "Personnel Uniforms absent from the installation's approved equipment manifest."
	cost = 30

	contains = list(
		/obj/item/clothing/under/rank/centcom/admiral = 1,
		/obj/item/clothing/suit/armor/centcom_admiral = 1,
		/obj/item/clothing/head/hats/warden/drill/centcom_admiral = 1,
		/obj/item/clothing/shoes/combat/swat/admiral = 2,
		/obj/item/clothing/gloves/tackler/combat/insulated/admiral = 2,
		/obj/item/clothing/head/hats/centcom_cap = 1,
		/obj/item/clothing/under/rank/centcom/commander = 1,
		/obj/item/clothing/under/rank/centcom/commander/skirt = 1
	)

/datum/ccpost_supply_package/contraband/restricted_costume
	audit_risk = 1
	id = "restricted_costume"
	name = "Black-Market Costume Crate"
	desc = "An assortment of unlicensed, politically questionable, and otherwise unauthorized costumes acquired through procurement channels that officially do not exist. Central Command assumes no responsibility for disciplinary action, mistaken identity, or hostile reactions resulting from their use."
	cost = 10
	contains = list(
		/obj/item/clothing/head/syndicatefake = 1,
		/obj/item/clothing/suit/syndicatefake = 1,
		/obj/item/disk/nuclear/fake/obvious = 1,
		/obj/item/clothing/head/wizard/fake = 1,
		/obj/item/clothing/suit/wizrobe/fake = 1,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/poster/random_contraband = 5
	)

/datum/ccpost_supply_package/contraband/restricted_exec
	audit_risk = 1
	id = "restricted_exec"
	name = "Executive Vice Package"
	desc = "A discreet selection of premium indulgences intended for executives, dignitaries, and personnel with sufficiently flexible expense accounts. Contents may include comforts not covered under standard operational provisioning."
	cost = 8

	contains = list(
		/obj/item/storage/fancy/cigarettes/cigars/havana = 1,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba = 1,
		/obj/item/storage/pipebox/fancy = 1,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium = 1,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 1,
		/obj/item/reagent_containers/cup/glass/bottle/cognac = 1,
		/obj/item/reagent_containers/cup/glass/bottle/navy_rum = 1,
		/obj/item/reagent_containers/cup/glass/bottle/applejack = 1
	)

/datum/ccpost_supply_package/contraband/restricted_decor
	audit_risk = 1
	id = "restricted_decor"
	name = "Unapproved Exotic Decor"
	desc = "A collection of lavish and impractical furnishings sourced through unapproved procurement channels. Perfect for personnel who believe operational efficiency improves dramatically when surrounded by expensive carpet, questionable art, and décor that definitely was not included in the original budget."
	cost = 8

	contains = list(
		/obj/item/stack/tile/carpet/executive/thirty = 1,
		/obj/item/stack/tile/carpet/royalblack/fifty = 1,
		/obj/item/stack/tile/carpet/royalblue/fifty = 1,
		/obj/item/stack/tile/carpet/stellar/thirty = 1,
		/obj/item/statuebust = 2,
		/obj/item/cardboard_cutout = 3,
		/obj/item/storage/crayons = 1,
		/obj/item/wallframe/painting/eldritch/weeping = 1,
		/obj/item/wallframe/painting/eldritch/beauty = 1
	)

/datum/ccpost_supply_package/contraband/restricted_recovequip
	audit_risk = 6
	id = "restricted_recovequip"
	name = "Recovered Syndicate Equipment"
	desc = "A sealed assortment of equipment recovered from Syndicate personnel, caches, and compromised operations. Items have been cleared for controlled redistribution through channels that Internal Security would strongly prefer you not ask about."
	cost = 50

	contains = list(
		/obj/item/clothing/mask/gas/syndicate = 1,
		/obj/item/clothing/under/syndicate/unarmoured = 1,
		/obj/item/clothing/under/syndicate/unarmoured/skirt = 1,
		/obj/item/storage/medkit/hypospray/syndicate = 1,
		/obj/item/storage/toolbox/syndicate = 1,
		/obj/item/toy/cards/deck/syndicate = 1,
		/obj/item/toy/balloon/syndicate = 1,
		/obj/item/autosurgeon/syndicate/thermal_eyes = 1,
		/obj/item/card/id/advanced/chameleon = 1
	)

/datum/ccpost_supply_package/contraband/restricted_party
	audit_risk = 2
	id = "restricted_party"
	name = "Unauthorized Party Supplies"
	desc = "An unapproved assortment of celebratory supplies acquired outside standard procurement channels. Contents are intended for morale events, unofficial gatherings, and other festivities that Finance has already declined to reimburse."
	cost = 8

	contains = list(
		/obj/item/storage/box/party_poppers = 1,
		/obj/item/gun/ballistic/revolver/russian = 1,
		/obj/item/pneumatic_cannon/pie = 1,
		/obj/item/food/pie/cream = 3,
		/obj/item/bot_assembly/honkbot = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/bikehorn = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/arm/left/robot = 1,
		/obj/effect/spawner/random/decoration/glowstick = 3,
		/obj/machinery/jukebox/disco = 1,
		/obj/item/storage/box/balloons = 1
	)


// ////////////////////////////////////
// Logistics CATALOG END
// ////////////////////////////////////

/datum/ccpost_shipment
	var/shipment_code
	var/datum/ccpost_supply_package/package

	var/requested_by = "UNKNOWN"
	var/requested_at

	var/status = CCPOST_SHIPMENT_QUEUED
	var/status_updated_at

	var/authorized_at
	var/dispatched_at
	var/delivered_at

	var/authorization_delay
	var/dispatch_delay
	var/transit_delay

	/// World time at which the current shipment stage should finish.
	var/stage_ends_at = 0

	var/freight_condition_status = "NORMAL"
	var/list/freight_condition_reasons = list()

	var/freight_spawned = FALSE
	var/failure_reason

// Actual sector-aware order lifecycle

/datum/ccpost_logistics_network/proc/get_status_display_shipment()
	var/datum/ccpost_shipment/selected_shipment
	var/selected_priority = 0
	var/selected_stage_end = 0

	for(var/datum/ccpost_shipment/shipment as anything in shipments)
		if(QDELETED(shipment))
			continue

		if(shipment.status == CCPOST_SHIPMENT_DELIVERED)
			continue

		if(shipment.status == CCPOST_SHIPMENT_FAILED)
			continue

		var/shipment_priority = 0

		if(shipment.freight_spawned)
			shipment_priority = 4

		else
			switch(shipment.status)
				if(CCPOST_SHIPMENT_IN_TRANSIT)
					shipment_priority = 3

				if(CCPOST_SHIPMENT_AUTHORIZED)
					shipment_priority = 2

				if(CCPOST_SHIPMENT_QUEUED)
					shipment_priority = 1

		if(!shipment_priority)
			continue

		if(!selected_shipment)
			selected_shipment = shipment
			selected_priority = shipment_priority
			selected_stage_end = shipment.stage_ends_at
			continue

		if(shipment_priority > selected_priority)
			selected_shipment = shipment
			selected_priority = shipment_priority
			selected_stage_end = shipment.stage_ends_at
			continue

		if(shipment_priority == selected_priority)
			if(shipment.stage_ends_at && (!selected_stage_end || shipment.stage_ends_at < selected_stage_end))
				selected_shipment = shipment
				selected_stage_end = shipment.stage_ends_at

	return selected_shipment

// CENTRAL COMMAND LOGISTICS STATUS DISPLAY

/obj/machinery/status_display/ccpost_logistics
	name = "Central Command freight display"
	desc = "A wall-mounted Central Command Logistics display showing the status of incoming freight requisitions."
	current_mode = SD_MESSAGE
	text_color = COLOR_DISPLAY_ORANGE
	header_text_color = COLOR_DISPLAY_YELLOW

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ccpost_logistics, 32)

/obj/machinery/status_display/ccpost_logistics/Initialize(mapload)
	. = ..()
	GLOB.ccpost_logistics_network.register_status_display(src)

/obj/machinery/status_display/ccpost_logistics/Destroy()
	GLOB.ccpost_logistics_network.unregister_status_display(src)
	return ..()

/obj/machinery/status_display/ccpost_logistics/process()
	if(machine_stat & (NOPOWER | BROKEN))
		update_appearance()
		return PROCESS_KILL

	var/datum/ccpost_shipment/shipment = GLOB.ccpost_logistics_network.get_status_display_shipment()

	if(!shipment)
		set_messages("CC LOGISTICS", "STANDBY")
		return PROCESS_KILL

	var/line1
	var/line2

	switch(shipment.status)
		if(CCPOST_SHIPMENT_QUEUED)
			line1 = "QUEUED"
			line2 = get_shipment_timer_text(shipment)

		if(CCPOST_SHIPMENT_AUTHORIZED)
			line1 = "AUTHORIZED"
			line2 = get_shipment_timer_text(shipment)

		if(CCPOST_SHIPMENT_IN_TRANSIT)
			if(shipment.freight_spawned)
				line1 = "ARRIVING"
				line2 = "FREIGHT BAY"
			else
				line1 = "IN TRANSIT"
				line2 = get_shipment_timer_text(shipment)

		else
			line1 = "CC LOGISTICS"
			line2 = "STANDBY"

	set_messages(line1, line2)

/obj/machinery/status_display/ccpost_logistics/proc/get_shipment_timer_text(datum/ccpost_shipment/shipment)
	if(!shipment || !shipment.stage_ends_at)
		return "--:--"

	var/time_remaining = max(0, round((shipment.stage_ends_at - world.time) / (1 SECONDS)))
	var/seconds = time_remaining % 60
	var/minutes = (time_remaining - seconds) / 60

	return "[add_leading(num2text(minutes), 2, "0")]:[add_leading(num2text(seconds), 2, "0")]"

/datum/ccpost_logistics_network/proc/create_shipment(package_id, requester_name, allow_contraband = FALSE)
	var/datum/ccpost_supply_package/package = get_supply_package(package_id)

	if(!package)
		return null

	if(package.contraband && !allow_contraband)
		return null

	if(package.contraband && is_restricted_procurement_suspended())
		return null

	if(get_active_shipment_count() >= max_active_shipments)
		return null

	if(!reserve_allocation(package.cost))
		return null

	var/datum/ccpost_freight_conditions/current_conditions = get_current_freight_conditions()

	var/datum/ccpost_shipment/shipment = new

	shipment.shipment_code = generate_shipment_code()
	shipment.package = package
	shipment.requested_by = requester_name
	shipment.requested_at = station_time_timestamp()
	shipment.status = CCPOST_SHIPMENT_QUEUED
	shipment.status_updated_at = station_time_timestamp()

	shipment.authorization_delay = current_conditions.authorization_delay
	shipment.dispatch_delay = current_conditions.dispatch_delay
	shipment.transit_delay = current_conditions.get_transit_delay()
	shipment.stage_ends_at = world.time + shipment.authorization_delay

	shipment.freight_condition_status = current_conditions.status
	shipment.freight_condition_reasons = current_conditions.reasons.Copy()

	qdel(current_conditions)

	shipments.Insert(1, shipment)

	// Restricted procurement is still recorded by the logistics network even
	// when the local terminal safeguards have been bypassed. The next available
	// tasking cycle will schedule a compliance audit.
	if(package.contraband)
		contraband_requisition_count++
		contraband_compliance_points += max(1, package.audit_risk)
		contraband_audit_pending = TRUE

	var/sector_suffix = ""

	if(shipment.freight_condition_status != "NORMAL")
		sector_suffix = " Current sector freight status: [shipment.freight_condition_status]."

	announce_freight_status("Requisition [shipment.shipment_code] for [package.name] has been queued for review.[sector_suffix]")

	refresh_logistics_outputs()

	addtimer(CALLBACK(src, PROC_REF(authorize_shipment), shipment), shipment.authorization_delay)

	return shipment


/datum/ccpost_logistics_network/proc/authorize_shipment(datum/ccpost_shipment/shipment)
	if(QDELETED(shipment))
		return

	if(shipment.status != CCPOST_SHIPMENT_QUEUED)
		return

	if(!shipment.package)
		return

	if(!commit_reserved_allocation(
		shipment.package.cost,
		"Requisition [shipment.shipment_code]: [shipment.package.name]",
		shipment.requested_by
	))
		shipment.status = CCPOST_SHIPMENT_FAILED
		shipment.failure_reason = "Operational allocation could not be committed."
		shipment.status_updated_at = station_time_timestamp()
		shipment.stage_ends_at = 0

		announce_freight_status("Requisition [shipment.shipment_code] could not be authorized due to an allocation processing error.")

		refresh_logistics_outputs()

		return

	shipment.status = CCPOST_SHIPMENT_AUTHORIZED
	shipment.authorized_at = station_time_timestamp()
	shipment.status_updated_at = station_time_timestamp()
	shipment.stage_ends_at = world.time + shipment.dispatch_delay

	announce_freight_status("Requisition [shipment.shipment_code] has been authorized. [shipment.package.cost] CU has been committed.")

	refresh_logistics_outputs()

	addtimer(CALLBACK(src, PROC_REF(mark_shipment_in_transit), shipment), shipment.dispatch_delay)


/datum/ccpost_logistics_network/proc/mark_shipment_in_transit(datum/ccpost_shipment/shipment)
	if(QDELETED(shipment))
		return

	if(shipment.status != CCPOST_SHIPMENT_AUTHORIZED)
		return

	shipment.status = CCPOST_SHIPMENT_IN_TRANSIT
	shipment.dispatched_at = station_time_timestamp()
	shipment.status_updated_at = station_time_timestamp()
	shipment.stage_ends_at = world.time + shipment.transit_delay

	var/transit_seconds = round(shipment.transit_delay / (1 SECONDS))

	announce_freight_status("Shipment [shipment.shipment_code] is now in transit to this installation. Estimated freight routing time: [transit_seconds] seconds.")

	refresh_logistics_outputs()

	addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), shipment.transit_delay)


/datum/ccpost_logistics_network/proc/dispatch_inbound_freight(datum/ccpost_shipment/shipment)
	if(QDELETED(shipment))
		return

	if(shipment.status != CCPOST_SHIPMENT_IN_TRANSIT)
		return

	if(shipment.freight_spawned)
		return

	if(inbound_lane_busy)
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	if(!length(inbound_spawns))
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	var/obj/effect/ccpost_freight_point/inbound_spawn/spawn_point = pick(inbound_spawns)

	if(QDELETED(spawn_point))
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	var/turf/spawn_turf = get_turf(spawn_point)

	if(!spawn_turf)
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = new(spawn_turf)

	freight_crate.shipment_code = shipment.shipment_code
	freight_crate.name = "Central Command freight container ([shipment.shipment_code])"

	shipment.package.fill_crate(freight_crate)

	inbound_lane_busy = TRUE

	if(!set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, TRUE))
		inbound_lane_busy = FALSE
		qdel(freight_crate)

		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)

		return

	shipment.freight_spawned = TRUE
	shipment.stage_ends_at = 0

	refresh_logistics_outputs()


/datum/ccpost_logistics_network/proc/mark_shipment_delivered(shipment_code)
	var/datum/ccpost_shipment/shipment = find_shipment(shipment_code)

	if(!shipment)
		return FALSE

	if(shipment.status != CCPOST_SHIPMENT_IN_TRANSIT)
		return FALSE

	shipment.status = CCPOST_SHIPMENT_DELIVERED
	shipment.delivered_at = station_time_timestamp()
	shipment.status_updated_at = station_time_timestamp()
	shipment.stage_ends_at = 0

	inbound_lane_busy = FALSE

	announce_freight_status("Shipment [shipment.shipment_code], [shipment.package.name], has arrived at the designated freight intake.")

	refresh_logistics_outputs()

	return TRUE


