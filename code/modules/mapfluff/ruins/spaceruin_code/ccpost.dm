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
	new /obj/item/implantcase/mindshield(src)

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

// Central Command Tasking System

/datum/ccpost_tasking_order
	var/order_code
	var/template_id
	var/category
	var/subject
	var/priority
	var/instruction

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

	issued_at = station_time_timestamp()

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
	light_color = LIGHT_COLOR_BLUE

	circuit = /obj/item/circuitboard/computer/ccpost_tasking

	/// Current automatic assignment timer.
	var/assignment_timer

	/// Prevents repeated manual printing.
	COOLDOWN_DECLARE(print_cooldown)

	/// Pool of Central Command assignments.
	var/static/list/assignment_templates = list(
		list(
			"id" = "command_status",
			"category" = "Command Oversight",
			"subject" = "General Operational Status",
			"priority" = "Routine",
			"instruction" = "Contact station Command and request a general operational status report. Identify any unresolved matters which may warrant continued Central Command observation."
		),
		list(
			"id" = "command_coordination",
			"category" = "Command Oversight",
			"subject" = "Departmental Coordination Review",
			"priority" = "Routine",
			"instruction" = "Assess whether station Command is maintaining effective communication and coordination between departments. Document any significant breakdowns in the chain of communication."
		),
		list(
			"id" = "command_concern",
			"category" = "Command Oversight",
			"subject" = "Command Concern Inquiry",
			"priority" = "Routine",
			"instruction" = "Request that station Command identify its most significant current operational concern. Verify the matter where practical and record your assessment."
		),
		list(
			"id" = "security_arrests",
			"category" = "Security Oversight",
			"subject" = "Arrest Procedure Review",
			"priority" = "Routine",
			"instruction" = "Review Security's handling of recent arrests and determine whether appropriate procedure appears to be followed. Distinguish confirmed information from allegation or speculation."
		),
		list(
			"id" = "security_investigations",
			"category" = "Security Oversight",
			"subject" = "Unresolved Investigation Review",
			"priority" = "Routine",
			"instruction" = "Contact Security and request an overview of any unresolved high-priority investigations. Determine whether any require additional Central Command monitoring."
		),
		list(
			"id" = "engineering_status",
			"category" = "Infrastructure Oversight",
			"subject" = "Engineering Status Assessment",
			"priority" = "Routine",
			"instruction" = "Contact Engineering and request an assessment of current station infrastructure, including any significant power, atmospheric, structural, or telecommunications concerns."
		),
		list(
			"id" = "engineering_sustainability",
			"category" = "Infrastructure Oversight",
			"subject" = "Continued Operations Assessment",
			"priority" = "Routine",
			"instruction" = "Request an assessment from Engineering regarding the station's ability to sustain continued operations. Record any systems identified as vulnerable or degraded."
		),
		list(
			"id" = "communications",
			"category" = "Communications Oversight",
			"subject" = "Communications Integrity Review",
			"priority" = "Routine",
			"instruction" = "Review recent station communications for conflicting, incomplete, or unverifiable information. Request clarification from relevant personnel where necessary."
		),
		list(
			"id" = "communications_outage",
			"category" = "Communications Oversight",
			"subject" = "Communications Reliability Inquiry",
			"priority" = "Routine",
			"instruction" = "Determine whether the station has experienced any significant communications outages or disruptions. Establish their likely cause and operational impact."
		),
		list(
			"id" = "medical_status",
			"category" = "Medical Oversight",
			"subject" = "Personnel Condition Report",
			"priority" = "Routine",
			"instruction" = "Request a personnel and casualty status report from Medical. Identify any unusual casualty trends or incidents requiring further review."
		),
		list(
			"id" = "casualty_review",
			"category" = "Medical Oversight",
			"subject" = "Casualty Review",
			"priority" = "Routine",
			"instruction" = "Determine whether any recent casualties warrant further Central Command review. Establish whether hostile action, negligence, or routine operational hazards were involved."
		),
		list(
			"id" = "explosions",
			"category" = "Incident Review",
			"subject" = "Explosive Incident Inquiry",
			"priority" = "Routine",
			"instruction" = "Request clarification regarding any significant explosions reported aboard the station. Determine their approximate cause, location, and effect on station operations."
		),
		list(
			"id" = "sabotage_review",
			"category" = "Incident Review",
			"subject" = "Sabotage Assessment",
			"priority" = "Routine",
			"instruction" = "Review recent significant incidents and assess whether available evidence better supports deliberate sabotage, negligence, equipment failure, or routine operational error."
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
			"instruction" = "Assess the station's present emergency preparedness. Identify any obvious deficiencies in coordination, staffing, equipment, or response capability."
		),
		list(
			"id" = "conflicting_accounts",
			"category" = "Administrative Oversight",
			"subject" = "Report Consistency Review",
			"priority" = "Routine",
			"instruction" = "Review available departmental accounts of recent noteworthy incidents. Identify significant contradictions and request clarification where appropriate."
		),
		list(
			"id" = "monitoring_assessment",
			"category" = "Administrative Oversight",
			"subject" = "Monitoring Requirement Assessment",
			"priority" = "Routine",
			"instruction" = "Determine whether current station conditions justify increased Central Command monitoring. Record the factors supporting your conclusion."
		),
		list(
			"id" = "developing_situation",
			"category" = "General Oversight",
			"subject" = "Developing Situation Review",
			"priority" = "Routine",
			"instruction" = "Identify any developing situation aboard the station which may require future Central Command attention. Verify available information and document your findings."
		)
	)

// Initialization

/obj/machinery/computer/ccpost_tasking/Initialize(mapload)
	. = ..()

	//Give the round time to develop before an assignment is sent to the terminal
	schedule_next_assignment(10 SECONDS, 20 SECONDS)

/obj/machinery/computer/ccpost_tasking/Destroy()
	if(assignment_timer)
		deltimer(assignment_timer)
		assignment_timer = null

	// Do NOT delete the current order or history here.
	// Those belong to the circuit board and survive deconstruction.

	return ..()


// CIRCUIT BOARD ACCESS

/obj/machinery/computer/ccpost_tasking/proc/get_tasking_board()
	var/obj/item/circuitboard/computer/ccpost_tasking/tasking_board = circuit
	return tasking_board

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

	var/list/chosen_template = pick(assignment_templates)

	// Prevents immediate repeats
	if(length(assignment_templates) > 1)
		while(chosen_template["id"] == tasking_board.last_template_id)
			chosen_template = pick(assignment_templates)

	tasking_board.last_template_id = chosen_template["id"]

	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/order_code = "CC-[round_identifier]-[tasking_board.next_order_number]"

	tasking_board.next_order_number++

	tasking_board.current_order = new /datum/ccpost_tasking_order(
		order_code,
		chosen_template
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

			tasking_board.current_order.status = "Completed"
			tasking_board.current_order.completed_by = user.name
			tasking_board.current_order.completed_at = station_time_timestamp()

			playsound(src, 'sound/machines/terminal_alert.ogg', vol = 25, vary = TRUE)

			balloon_alert(user, "order marked complete")

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
				balloon_alert(user, "order not found")

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

	var/obj/item/paper/assignment_paper = new /obj/item/paper(
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

	/// Destroyed installations are permanently removed from normal rotation.
	var/destroyed = FALSE

/datum/ccpost_sector_installation/New(list/template)
	. = ..()

	installation_code = template["code"]
	installation_name = template["name"]
	installation_function = template["function"]
	status = template["initial_status"]
	status_since = station_time_timestamp()


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
	var/max_sector_notices = 10

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
			"body" = "Commercial and Nanotrasen freight traffic is being rerouted around a congested transit corridor. Minor delivery delays are expected. Priority medical and emergency shipments remain unaffected."
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
			"id" = "medical_batch_review",
			"category" = "Medical",
			"source" = "Central Medical Logistics",
			"priority" = "Advisory",
			"title" = "Medical Supply Batch Review",
			"body" = "Central Medical Logistics is conducting a routine documentation review of selected pharmaceutical shipments distributed throughout the sector. No general recall has been issued. Continue normal inventory procedures."
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
			"body" = "Intermittent latency has been observed on several administrative network routes. Automated systems may take longer than usual to acknowledge submitted requests. Repeatedly submitting the same request will not improve processing speed."
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
			"id" = "personnel_records",
			"category" = "Personnel",
			"source" = "Central Personnel Administration",
			"priority" = "Routine",
			"title" = "Personnel Record Accuracy",
			"body" = "Supervisory personnel are reminded that staffing records should accurately reflect current assignments. Personnel who have been missing for several consecutive shifts should not continue to be recorded as 'temporarily unavailable' indefinitely."
		)
	)

	// Sector Installations

	var/static/list/sector_installation_templates = list(
		list(
			"code" = "NT-REL-A17",
			"name" = "Relay Station A-17",
			"function" = "Long-range communications relay",
			"initial_status" = "ONLINE"
		),
		list(
			"code" = "NT-OUT-K04",
			"name" = "Outpost Kappa-4",
			"function" = "Administrative monitoring outpost",
			"initial_status" = "ROUTINE OPERATIONS"
		),
		list(
			"code" = "NT-MIN-RC12",
			"name" = "Mining Platform RC-12",
			"function" = "Mineral extraction and processing platform",
			"initial_status" = "ROUTINE OPERATIONS"
		),
		list(
			"code" = "NT-LP-D03",
			"name" = "Listening Post Delta-3",
			"function" = "Deep-space communications monitoring",
			"initial_status" = "ONLINE"
		),
		list(
			"code" = "NT-ADM-06",
			"name" = "Administrative Annex 6",
			"function" = "Regional records and compliance office",
			"initial_status" = "UNDER REVIEW"
		),
		list(
			"code" = "NT-LOG-H09",
			"name" = "Logistics Station H-9",
			"function" = "Freight routing and supply coordination",
			"initial_status" = "ROUTINE OPERATIONS"
		)
	)

	// Possible Critical Incidents

	var/static/list/critical_incidents = list(
		"a cascading primary power failure",
		"severe reactor containment instability",
		"a major atmospheric containment failure",
		"multiple structural integrity failures",
		"unidentified external impacts causing severe structural damage",
		"a widespread internal systems failure",
		"an unresolved station-wide security emergency",
		"an uncontrolled industrial accident",
		"a cascading life-support systems failure",
		"a major communications and power infrastructure failure"
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

	create_sector_notice(chosen_template)

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
	switch(installation.status)
		if("ONLINE", "ROUTINE OPERATIONS")
			return 2

		if("MAINTENANCE", "UNDER REVIEW")
			return 6

		if("COMMUNICATIONS DEGRADED")
			return 15

		if("NO CONTACT")
			return 35

		if("OFFLINE")
			return 45

	return 0

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

/datum/ccpost_sector_network/proc/set_installation_critical(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	installation.status = "CRITICAL"
	installation.condition = "CRITICAL"
	installation.telemetry = "EMERGENCY"
	installation.incident_summary = pick(critical_incidents)
	installation.condition_details = installation.incident_summary
	installation.status_since = station_time_timestamp()

	if(prob(65))
		installation.ert_dispatched = TRUE
		installation.response_status = "ERT DISPATCHED"
	else
		installation.ert_dispatched = FALSE
		installation.response_status = "NO ERT DISPATCHED"

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

	// Critical incidents receive a faster follow-up.
	schedule_next_sector_installation_update(4 MINUTES, 7 MINUTES)


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

	if(prob(recovery_chance))
		resolve_critical_installation_success(installation)
	else
		destroy_sector_installation(installation)


/datum/ccpost_sector_network/proc/resolve_critical_installation_success(datum/ccpost_sector_installation/installation)
	if(!installation)
		return

	installation.status = pick("ONLINE", "ROUTINE OPERATIONS")

	installation.condition = "OPERATIONAL"
	installation.telemetry = "ACTIVE"

	var/spoken_update

	if(installation.ert_dispatched)
		installation.condition_details = "Emergency Response Team intervention has stabilized the installation."
		installation.response_status = "ERT OPERATION COMPLETE"

		spoken_update = "Sector update. Emergency Response Team operations at [installation.installation_name] have concluded successfully. The installation has returned to operational status."
	else
		installation.condition_details = "Installation personnel have restored operational stability without external intervention."
		installation.response_status = "INCIDENT STABILIZED"

		spoken_update = "Sector update. [installation.installation_name] is no longer classified as CRITICAL. Local personnel have restored operational stability."

	installation.status_since = station_time_timestamp()

	create_installation_recovery_notice(installation)

	notify_registered_displays(
		spoken_update,
		FALSE,
		35,
		"chimes. A previously critical sector installation has returned to operational status."
	)

// Recovery Sector Notice

/datum/ccpost_sector_network/proc/create_installation_recovery_notice(datum/ccpost_sector_installation/installation)
	var/recovery_text

	if(installation.ert_dispatched)
		recovery_text = "Emergency Response Team operations have concluded successfully. The installation has returned to acceptable operational condition."
	else
		recovery_text = "Local installation personnel have restored operational stability. External response is no longer considered necessary."

	var/list/recovery_template = list(
		"id" = "installation_recovery_[installation.installation_code]",
		"category" = "Emergency Operations",
		"source" = "Central Emergency Management",
		"priority" = "Advisory",
		"title" = "Installation Stabilized: [installation.installation_name]",
		"body" = "[installation.installation_name] ([installation.installation_code]) is no longer classified as CRITICAL following [installation.incident_summary]. [recovery_text] Routine monitoring may resume."
	)

	create_sector_notice(recovery_template)

// INSTALLATION DESTRUCTION

/datum/ccpost_sector_network/proc/destroy_sector_installation(datum/ccpost_sector_installation/installation)
	if(!installation || installation.destroyed)
		return

	installation.destroyed = TRUE
	installation.status = "OFFLINE"
	installation.condition = "DESTROYED"
	installation.telemetry = "TERMINATED"
	installation.condition_details = "Confirmed installation loss following [installation.incident_summary]."
	installation.status_since = station_time_timestamp()

	var/spoken_update

	if(installation.ert_dispatched)
		installation.response_status = "ERT OPERATION FAILED"

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. Emergency Response Team intervention was unsuccessful. The installation is classified as destroyed. All remote telemetry has terminated."
	else
		installation.response_status = "INSTALLATION LOST"

		spoken_update = "Central Command priority alert. [installation.installation_name] has been confirmed lost. The installation is classified as destroyed. All remote telemetry has terminated."

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

	if(installation.ert_dispatched)
		response_text = "Emergency Response Team intervention was unsuccessful."
	else
		response_text = "No Emergency Response Team was deployed prior to the confirmed loss."

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

/datum/ccpost_sector_network/proc/schedule_next_sector_installation_update(minimum_delay = 8 MINUTES, maximum_delay = 14 MINUTES)
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
			schedule_next_sector_installation_update(4 MINUTES, 7 MINUTES)
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

	// Otherwise perform a normal status change.
	var/new_status = get_next_installation_status(selected_installation)

	while(new_status == selected_installation.status)
		new_status = get_next_installation_status(selected_installation)

	selected_installation.status = new_status
	selected_installation.status_since = station_time_timestamp()

	// Once the recovered installation enters another ordinary status cycle,
	// clear the previous emergency response information.
	if(selected_installation.response_status == "ERT OPERATION COMPLETE" || selected_installation.response_status == "INCIDENT STABILIZED")
		selected_installation.response_status = "NONE"
		selected_installation.ert_dispatched = FALSE
		selected_installation.incident_summary = "No active incident."

	apply_installation_status_metadata(selected_installation)

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

//TGUI

/obj/machinery/status_display/ccpost_remote_status/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CCPostRemoteStatus", name)
		ui.open()


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
		sector_installation_data += list(
			list(
				"code" = installation.installation_code,
				"name" = installation.installation_name,
				"function" = installation.installation_function,
				"status" = installation.status,
				"status_since" = installation.status_since,
				"condition" = installation.condition,
				"telemetry" = installation.telemetry,
				"condition_details" = installation.condition_details,
				"incident_summary" = installation.incident_summary,
				"response_status" = installation.response_status,
				"ert_dispatched" = installation.ert_dispatched,
				"destroyed" = installation.destroyed
			)
		)

	data["sector_installations"] = sector_installation_data

	return data


MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ccpost_remote_status, 32)