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


// Central Command Advisor Hologram code

// Central Command Advisor Holopad

/obj/machinery/holopad/tutorial/ccpost_advisor
	play_once = FALSE
	proximity_range = 2


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

/datum/preset_holoimage/ccpost_advisor/customize_human(mob/living/carbon/human/mannequin)
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

	addtimer(CALLBACK(src, PROC_REF(receive_escalation_response)), 3 SECONDS)

/obj/machinery/button/ccpost_escalation/proc/receive_escalation_response()
	var/response = pick(escalation_responses)

	say(response)

	playsound(src, SFX_BUTTON_CLICK, vol = 35, vary = TRUE)

