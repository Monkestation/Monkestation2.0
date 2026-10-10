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

/obj/machinery/button/ccpost_escalation/attack_hand(mob/user, list/modifiers)
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
