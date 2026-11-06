///Stuff used in Central Command Liaison Outpost Ruin.

/obj/item/paper/fluff/ruins/ccpost/transmission
	default_raw_text = "Nothing of interest"

/// General assignment directive for Central Command Outpost personnel.
/obj/item/paper/fluff/ruins/ccpost/transmission/assignment
	name = "Central Command outpost assignment directive"
	default_raw_text = {"<center><table border="0" cellspacing="0" cellpadding="4" bgcolor="#0a1e2b" style="border: 4px solid white; border-radius: 10px; font-family: Bahnschrift, sans-serif;"><tr><td><font color="#f0f0f0" size="6"><b>&#9701;</b></font></td><td><font color="#f0f0f0" size="7"><b>N</b></font></td><td><font color="#f0f0f0" size="6"><b>&#9699;</b></font></td></tr></table></center>
	<br><center><small><i>Official transmission from Central Command</i></small></center><hr><hr><small>
	<br>Issued by: Nina C. Trayson
	<br>Position: Central Command Liaison Manager
	<br>Posting: Central Command Liaison Outpost
	<br>Recipients: All Assigned Outpost Personnel
	<br>Classification: Internal Administrative Directive
	<br>Status: Active
	<br>
	<br><b>SUBJECT: INSTALLATION DUTIES, AUTHORITY AND JURISDICTION</b>
	<br>
	<br>Effective immediately, all personnel assigned to this installation are reminded of their responsibilities as representatives of Central Command.
	<br>
	<br><b>1. INSTALLATION STATUS</b>
	<br>
	<br>This outpost is operated under the direct administration of Central Command. It is a separate corporate installation and does not fall under the operational chain of command of the nearby Nanotrasen station.
	<br>
	<br>Station-issued rank does not automatically confer command authority, unrestricted access or security jurisdiction within this facility. This applies equally to visiting members of Station Command and Security.
	<br>
	<br><b>2. LIAISON RESPONSIBILITIES</b>
	<br>
	<br>Central Command Liaisons are responsible for administrative oversight, sector communications, operational reporting, tasking assignments and management of the outpost's logistical allocation.
	<br>
	<br>Liaisons are expected to monitor relevant station activity, maintain professional contact with station Command, review incoming sector requests, verify information and submit accurate findings.
	<br>
	<br>This posting grants oversight responsibilities. It does not authorize Liaisons to assume operational command of station departments or interfere unnecessarily with station affairs.
	<br>
	<br><b>3. SECURITY RESPONSIBILITIES</b>
	<br>
	<br>The assigned Central Command Security Officer is responsible for maintaining the security of this installation, its personnel, restricted facilities and corporate property.
	<br>
	<br>The officer is authorized to establish reasonable access controls, screen visitors, inspect suspicious freight, investigate incidents and respond to threats occurring aboard the outpost.
	<br>
	<br>These responsibilities extend to all visitors, including station personnel and members of Station Command. Visitors must comply with legitimate installation security instructions regardless of their station rank.
	<br>
	<br>Where necessary, the officer may deny entry, remove unauthorized visitors or temporarily restrain individuals presenting a genuine security threat. Such actions must remain proportionate, documented and consistent with applicable regulations.
	<br>
	<br>The officer's jurisdiction is limited to legitimate matters concerning the outpost. This assignment does not grant command authority over station Security or permission to conduct unauthorized enforcement operations aboard the station.
	<br>
	<br><b>4. INTERNAL COORDINATION</b>
	<br>
	<br>The Liaison oversees the outpost's administrative operations and coordinates its official activities. The Security Officer exercises operational responsibility for installation security.
	<br>
	<br>Both positions are expected to cooperate, communicate significant incidents and respect their respective responsibilities. Disagreements requiring higher authorization are to be referred to Central Command.
	<br>
	<br><b>5. VISITORS AND CORPORATE PROPERTY</b>
	<br>
	<br>Visitors are guests of Central Command and remain subject to applicable access restrictions and security procedures. No station appointment, including Captain or Head of Security, independently grants authority to override these procedures.
	<br>
	<br>Legitimate directives from appropriately authorized Central Command personnel remain binding. All staff must comply with applicable corporate regulations.
	<br>
	<br><b>6. GENERAL CONDUCT</b>
	<br>
	<br>Remain aboard the installation unless official duties or an emergency reasonably require otherwise. Protect confidential information, preserve relevant records and avoid unnecessary interference with station operations.
	<br>
	<br>Professionalism, impartiality and proper documentation are expected at all times.
	<br>
	<br>Central Command has invested considerable resources in this installation. Please refrain from creating additional reasons for an expenditure review.
	<br>
	<br></small><hr><hr><small><i>Signed, Nina C. Trayson</i></small>
	<br>CENTRAL COMMAND
	<br>SECTOR OVERSIGHT DEPARTMENT
	"}

// Visitor pamphlet
/obj/item/paper/pamphlet/ccpost_visitor
	name = "pamphlet - 'Central Command Liaison Outpost Visitor Guide'"
	desc = "A neatly folded NanoTrasen pamphlet for visitors to the Sector Liaison Outpost."
	default_raw_text = @{"
<center><b><font size="4">NANOTRASEN CENTRAL COMMAND</font></b></center>
<center><b>SECTOR LIAISON OUTPOST</b></center>
<center><i>Visitor Information and Facility Guidance</i></center>
<br>
<b>WELCOME</b><br>
This installation serves as a regional Central Command liaison, communications, administrative oversight and logistics coordination facility. Our personnel can receive official correspondence, arrange meetings and request reports concerning station operations.<br><br>
<b>VISITING THE OUTPOST</b><br>
1. Arrange your visit with the Liaison or Outpost Security before approaching the installation.<br>
2. Report to reception and explain the purpose of your visit.<br>
3. Remain in public and escorted areas unless expressly authorized to enter elsewhere.<br>
4. Declare weapons or dangerous equipment to Outpost Security before entry. Follow local security instructions while on the premises.<br><br>
<b>IMPORTANT: AUTOMATED DEFENSES</b><br>
Exterior perimeter turrets may engage unidentified lifeforms and personnel without mindshield protection. Do not approach the perimeter without prior clearance. Visitors should request that Outpost Security disable defenses or arrange safe passage before arrival.<br><br>
<b>ABOUT LIAISON AUTHORITY</b><br>
Liaisons conduct administrative oversight and report findings to Central Command. They do not command station personnel, station security, or station leadership. Outpost Security authority applies to this installation and its immediate premises only.<br><br>
<b>IN AN EMERGENCY</b><br>
Follow Outpost Security instructions and keep clear of restricted compartments and exterior defenses. Contact the Liaison or Security Office for assistance.<br><br>
<center><i>NanoTrasen appreciates your cooperation. Unauthorized visits may be rescheduled indefinitely.</i></center>
"}

/obj/item/card/id/advanced/centcom/ccpost_liaison
	name = "Central Command Liaison ID"

/obj/item/card/id/advanced/centcom/ccpost_security
	name = "Central Command Outpost Security ID"

// ============================================================
// CentCom-funded personal payroll for the two outpost ghost IDs.
// Bank accounts are registered so card payments/ATMs can use them.
// ============================================================
/datum/bank_account/ccpost_personnel
	// Employee account. Keep registered for normal payment devices.

/datum/bank_account/ccpost_personnel/payday(amount_of_paychecks, free = FALSE, skippable = FALSE, event = "Payday")
	if(!account_job || amount_of_paychecks <= 0)
		return FALSE
	if(skippable && !free)
		while(paydays_to_skip > 0 && amount_of_paychecks > 0)
			paydays_to_skip--
			amount_of_paychecks--
	if(amount_of_paychecks <= 0)
		return FALSE
	var/credits = round(account_job.paycheck * payday_modifier * amount_of_paychecks)
	if(credits <= 0)
		return FALSE
	if(!adjust_money(credits, "Central Command: [event]"))
		return FALSE
	if(!free)
		bank_card_talk("Central Command payroll processed: +[credits] credits. Balance: [account_balance] credits.")
	return TRUE

// Called once when an outpost ghost-role ID first enters its owner's ID slot.
/proc/ccpost_initialize_personal_payroll(obj/item/card/id/employee_id, mob/user)
	var/mob/living/carbon/human/employee = user
	if(!istype(employee) || !istype(employee_id))
		return

	// Prevent repeated payday grants when an ID is unequipped and worn again.
	if(employee_id.registered_account && !employee_id.registered_account.replaceable)
		return

	var/datum/bank_account/account
	if(employee.account_id)
		account = SSeconomy.bank_accounts_by_id["[employee.account_id]"]

	// Most ghost roles have no real bank account on spawn.
	if(!account)
		var/datum/job/payroll_job = new /datum/job/ghost_role
		payroll_job.paycheck = PAYCHECK_CREW
		var/payday_modifier = employee.dna?.species?.payday_modifier
		if(isnull(payday_modifier) || payday_modifier <= 0)
			payday_modifier = 1
		var/datum/bank_account/ccpost_personnel/new_account = new(employee.real_name, payroll_job, payday_modifier, TRUE)
		new_account.replaceable = FALSE
		new_account.payday(STARTING_PAYCHECKS, free = TRUE, event = "Appointment Allowance")
		account = new_account
		employee.account_id = account.account_id
		employee.add_mob_memory(/datum/memory/key/account, remembered_id = account.account_id)

	if(employee_id.registered_account)
		employee_id.registered_account.bank_cards -= employee_id
	employee_id.registered_account = account
	account.bank_cards |= employee_id
	employee_id.registered_name = employee.real_name
	employee_id.update_label()

/obj/item/card/id/advanced/centcom/ccpost_liaison/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_ID)
		ccpost_initialize_personal_payroll(src, user)

/obj/item/card/id/advanced/centcom/ccpost_security/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_ID)
		ccpost_initialize_personal_payroll(src, user)


/obj/structure/closet/secure_closet/centcom_liaison
	name = "CentCom Liaison's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"

/obj/structure/closet/secure_closet/centcom_liaison/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest/nanotrasen_representative/bathrobe(src)
	new /obj/item/clothing/suit/toggle/centcom_jacket(src)
	new /obj/item/clothing/under/rank/centcom/official(src)
	new /obj/item/clothing/under/rank/centcom/official/skirt(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/binoculars(src)

/obj/structure/closet/secure_closet/centcom_security
	name = "CentCom Security Officer's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"

/obj/structure/closet/secure_closet/centcom_security/PopulateContents()
	..()
	new /obj/item/storage/box/handcuffs(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/lockbox/loyalty(src)
	new /obj/item/implanter/mindshield(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/under/rank/centcom/official(src)
	new /obj/item/clothing/under/rank/centcom/official/skirt(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/binoculars(src)


// LIAISON OUTPOST TELEPORT ACCESS
// Restrict the arrival point to a fixed lobby location, independently of station teleporters.

GLOBAL_VAR_INIT(ccpost_lobby_beacon, null)
GLOBAL_LIST_EMPTY(ccpost_beacon_status_displays)

/obj/item/beacon/ccpost_lobby
	name = "Central Command Liaison Outpost Lobby"
	desc = "A fixed arrival beacon controlled from the outpost communications room."
	anchored = TRUE
	enabled = FALSE

/obj/item/beacon/ccpost_lobby/Initialize(mapload)
	. = ..()
	GLOB.ccpost_lobby_beacon = src
	for(var/obj/machinery/status_display/ccpost_beacon_status/display as anything in GLOB.ccpost_beacon_status_displays)
		display.refresh_beacon_state()

/obj/item/beacon/ccpost_lobby/Destroy()
	if(GLOB.ccpost_lobby_beacon == src)
		GLOB.ccpost_lobby_beacon = null
	for(var/obj/machinery/status_display/ccpost_beacon_status/display as anything in GLOB.ccpost_beacon_status_displays)
		if(!QDELETED(display))
			display.refresh_beacon_state()
	return ..()

/obj/item/beacon/ccpost_lobby/attack_hand(mob/user, list/modifiers)
	to_chat(user, span_notice("The fixed arrival beacon is operated by the outpost teleport access switch."))
	return

/obj/item/beacon/ccpost_lobby/attack_self(mob/user)
	to_chat(user, span_warning("Local controls are locked. Use the outpost teleport access switch."))
	return

/obj/item/beacon/ccpost_lobby/proc/set_beacon_state(new_enabled)
	if(enabled == new_enabled)
		return FALSE
	enabled = new_enabled
	icon_state = enabled ? "beacon" : "beacon-off"
	if(enabled)
		GLOB.teleportbeacons |= src
	else
		GLOB.teleportbeacons -= src
	for(var/obj/machinery/status_display/ccpost_beacon_status/display as anything in GLOB.ccpost_beacon_status_displays)
		if(!QDELETED(display))
			display.refresh_beacon_state()
	return TRUE

/obj/machinery/button/ccpost_beacon_control
	name = "outpost teleport access control"
	desc = "An access-restricted switch controlling the lobby tracking beacon."
	skin = "-blue"
	can_alter_skin = FALSE
	req_access = list(ACCESS_NT_REPRESENTATVE)
	silicon_access_disabled = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/ccpost_beacon_control, 24)

/obj/machinery/button/ccpost_beacon_control/attack_hand(mob/user, list/modifiers)
	if(panel_open || (machine_stat & (NOPOWER | BROKEN)))
		return ..()
	if(!allowed(user))
		balloon_alert(user, "access denied")
		playsound(src, SFX_BUTTON_FAIL, vol = 45, vary = FALSE)
		return
	var/obj/item/beacon/ccpost_lobby/beacon = GLOB.ccpost_lobby_beacon
	if(!beacon || QDELETED(beacon))
		balloon_alert(user, "arrival beacon unavailable")
		return
	beacon.set_beacon_state(!beacon.enabled)
	playsound(src, SFX_BUTTON_CLICK, vol = 45, vary = FALSE)
	balloon_alert(user, beacon.enabled ? "teleport access enabled" : "teleport access disabled")
	visible_message(span_notice("[src] switches the outpost arrival beacon [beacon.enabled ? "online" : "offline"]."))
	return TRUE

/obj/machinery/status_display/ccpost_beacon_status
	name = "outpost teleport access display"
	desc = "Shows whether the outpost lobby is available as a teleporter destination."
	current_mode = SD_MESSAGE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ccpost_beacon_status, 32)

/obj/machinery/status_display/ccpost_beacon_status/Initialize(mapload)
	. = ..()
	GLOB.ccpost_beacon_status_displays |= src
	refresh_beacon_state()

/obj/machinery/status_display/ccpost_beacon_status/Destroy()
	GLOB.ccpost_beacon_status_displays -= src
	return ..()

/obj/machinery/status_display/ccpost_beacon_status/proc/refresh_beacon_state()
	var/obj/item/beacon/ccpost_lobby/beacon = GLOB.ccpost_lobby_beacon
	set_messages("TELEPORT LINK", beacon?.enabled ? "ACTIVE" : "OFFLINE")

// Central Command Advisor Hologram code

// Central Command Advisor Holopad

/obj/machinery/holopad/tutorial/ccpost_advisor
	play_once = FALSE
	proximity_range = 2
	COOLDOWN_DECLARE(advisor_playback_cooldown)
	var/advisor_playback_cooldown_duration = 3 MINUTES


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
	if(replay_mode || !COOLDOWN_FINISHED(src, advisor_playback_cooldown))
		return
	if(!disk?.record || !is_operational)
		return
	COOLDOWN_START(src, advisor_playback_cooldown, advisor_playback_cooldown_duration)
	var/obj/item/disk/holodisk/ruin/space/ccpost/advisor/advisor_disk = disk
	advisor_disk?.select_random_tip()
	return ..()

/obj/machinery/holopad/tutorial/ccpost_advisor/examine(mob/user)
	. = ..()
	. += span_notice("Advisory playback is limited to once every three minutes.")


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

#define CCPOST_TURRET_SHOOT_ANOMALOUS (1<<4)
#define CCPOST_TURRET_SHOOT_UNSHIELDED (1<<5)

/obj/machinery/porta_turret/ccpost/perimeter
	name = "Central Command perimeter turret"
	desc = "A nonlethal-ready perimeter defense turret, controlled by Central Command Security."
	installation = null
	uses_stored = FALSE
	use_power = NO_POWER_USE
	has_cover = FALSE
	always_up = TRUE
	max_integrity = 200
	scan_range = 7
	req_access = list(ACCESS_NT_REPRESENTATVE)
	turret_flags = CCPOST_TURRET_SHOOT_UNSHIELDED | CCPOST_TURRET_SHOOT_ANOMALOUS
	faction = list(FACTION_TURRET, FACTION_TAMED, FACTION_SILICON)
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/items/weapons/taser.ogg'
	lethal_projectile = /obj/projectile/beam/laser
	lethal_projectile_sound = 'sound/items/weapons/gun/energy/Laser1.ogg'
	mode = 0 // Stun; controller can switch to lethal.
	system_id = "ccpost_perimeter"

/obj/machinery/porta_turret/ccpost/perimeter/setup()
	return

/obj/machinery/porta_turret/ccpost/perimeter/assess_perp(mob/living/carbon/human/perp)
	// Command must NEVER be targeted by this outpost's native threat checks.
	var/datum/job/real_job = perp.mind?.assigned_role
	var/datum/job/apparent_job = SSjob.GetJob(perp.get_assignment())
	if((real_job?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) || (apparent_job?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
		return 0
	// Preserve access for this outpost's own Liaisons and Security personnel.
	var/obj/item/card/id/identification = perp.wear_id?.GetID()
	if(istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security))
		return 0
	return ..()

/obj/machinery/turretid/ccpost/perimeter
	name = "Central Command perimeter defense controller"
	desc = "Controls the external automated defense turrets of this Central Command outpost."
	req_access = list(ACCESS_NT_REPRESENTATVE)
	system_id = "ccpost_perimeter"
	enabled = TRUE
	lethal = FALSE
	// Prevent station AI from bypassing the outpost ID requirement.
	ailock = TRUE

/obj/machinery/turretid/ccpost/perimeter/proc/ccpost_authorized_id(obj/item/card/id/identification)
	return istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security)

/obj/machinery/turretid/ccpost/perimeter/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(machine_stat & BROKEN)
		return

	var/obj/item/card/id/identification = attacking_item.GetID()
	if(!identification)
		return ..()

	// This controller uses its own restricted ID check, rather than the
	// parent controller's ACCESS_NT_REPRESENTATVE check.
	if(!ccpost_authorized_id(identification))
		to_chat(user, span_warning("Access denied: authorized outpost identification required."))
		return

	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The turret control is unresponsive!"))
		return

	locked = !locked
	to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the panel."))
	SStgui.update_uis(src)

/obj/machinery/turretid/ccpost/perimeter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	// Unlocking is done by swiping an authorized outpost ID, never by UI action.
	if(action == "lock")
		return TRUE

	// Never trust the UI's disabled state as authorization.
	if(action in list("power", "mode", "shoot_silicons"))
		var/mob/living/carbon/human/human_user = ui?.user
		if(!istype(human_user) || locked || !ccpost_authorized_id(human_user.wear_id?.GetID()))
			return TRUE

	return ..()

/obj/machinery/turretid/ccpost/perimeter/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	// The system_id connects approved perimeter turrets automatically.
	// Do not permit the parent multitool handler to add unrelated turrets.
	balloon_alert(user, "automatic linking only")
	return ITEM_INTERACT_BLOCKING

/obj/machinery/turretid/ccpost/perimeter/post_machine_initialize()
	. = ..()
	// The vanilla controller also tries area-based linking during Initialize.
	// Restrict this subtype's final links to our matching perimeter turrets.
	var/list/valid_turrets = list()
	for(var/datum/weakref/turret_ref as anything in turrets)
		var/obj/machinery/porta_turret/turret = turret_ref.resolve()
		if(istype(turret, /obj/machinery/porta_turret/ccpost/perimeter) && turret.system_id == system_id)
			valid_turrets |= turret_ref
	turrets = valid_turrets

#undef CCPOST_TURRET_SHOOT_ANOMALOUS
#undef CCPOST_TURRET_SHOOT_UNSHIELDED

