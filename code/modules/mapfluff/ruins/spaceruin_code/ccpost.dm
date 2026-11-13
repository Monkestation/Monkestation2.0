///Stuff used in Central Command Liaison Outpost Ruin.

// Outpost-specific pulse weapons. Native pulse weapons remain unchanged.
// Use a plain beam parent so the native pulse explosion-on-impact is not inherited.
/obj/projectile/beam/ccpost_pulse
	name = "corporate pulse"
	icon_state = "u_laser"
	damage = 35
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	wound_bonus = 10
	demolition_mod = 0
	damage_walls = FALSE

/obj/projectile/beam/ccpost_pulse/carbine
	damage = 45

/obj/item/ammo_casing/energy/laser/pulse/ccpost
	projectile_type = /obj/projectile/beam/ccpost_pulse

/obj/item/ammo_casing/energy/laser/pulse/ccpost/carbine
	projectile_type = /obj/projectile/beam/ccpost_pulse/carbine

// Standard laser mode also avoids direct structural damage.
/obj/projectile/beam/laser/ccpost
	demolition_mod = 0
	damage_walls = FALSE

/obj/item/ammo_casing/energy/laser/ccpost
	projectile_type = /obj/projectile/beam/laser/ccpost

/obj/item/stock_parts/power_store/cell/pulse/pistol/ccpost
	name = "corporate pulse pistol power cell"
	maxcharge = 6 * LASER_SHOTS(200, STANDARD_CELL_CHARGE * 40)

/obj/item/gun/energy/pulse/pistol/m1911/ccpost
	name = "\improper NT-P6 corporate pulse sidearm"
	desc = "A reduced-output pulse handgun issued to Central Command liaison personnel. Its compact power cell slowly recovers charge."
	cell_type = /obj/item/stock_parts/power_store/cell/pulse/pistol/ccpost
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse/ccpost, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser/ccpost)
	selfcharge = TRUE
	charge_delay = 20

// The parent multiplies charge by the subsystem tick length. Recover one fixed
// pulse shot per 20 seconds instead, independent of subsystem tick frequency.
/obj/item/gun/energy/pulse/pistol/m1911/ccpost/process(seconds_per_tick)
	if(!cell || cell.percent() >= 100)
		charge_timer = 0
		return
	charge_timer += seconds_per_tick
	if(charge_timer < charge_delay)
		return
	var/charge_ticks = FLOOR(charge_timer / charge_delay, 1)
	charge_timer -= charge_ticks * charge_delay
	cell.give(charge_ticks * LASER_SHOTS(200, STANDARD_CELL_CHARGE * 40))
	if(!chambered)
		recharge_newshot(TRUE)
	update_appearance()

/obj/item/gun/energy/pulse/carbine/ccpost
	name = "\improper NT-PC corporate security pulse carbine"
	desc = "A regulated pulse carbine issued to Central Command installation security. Its reduced-output pulse mode is designed to protect personnel without demolishing the facility."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse/ccpost/carbine, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser/ccpost)

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
	<br>This posting grants oversight responsibilities. It does not authorize Liaisons to assume operational command of station departments or interfere unnecessarily with station affairs. Consult existing records before requesting information. A request is not an order. Do not duplicate inquiries or interrupt essential operations; document unavailable cooperation and defer nonessential requests.
	<br>
	<br><b>3. SECURITY RESPONSIBILITIES</b>
	<br>
	<br>The assigned Central Command Security Officer is responsible for maintaining the security of this installation, its personnel, restricted facilities and corporate property.
	<br>
	<br>The officer is authorized to establish reasonable access controls, screen visitors, inspect regional freight and suspicious deliveries, investigate incidents and respond to threats occurring aboard the outpost.
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
	<br>Both positions are expected to cooperate, communicate significant incidents and respect their respective responsibilities. Emergency armory equipment is reserved for legitimate defense and should be returned when no longer required. Disagreements requiring higher authorization are to be referred to Central Command.
	<br>
	<br><b>5. VISITORS AND CORPORATE PROPERTY</b>
	<br>
	<br>Visitors are guests of Central Command and remain subject to applicable access restrictions and security procedures. No station appointment, including Captain or Head of Security, independently grants authority to override these procedures.
	<br>
	<br>Legitimate directives from appropriately authorized Central Command personnel remain binding. All staff must comply with applicable corporate regulations.
	<br>
	<br>Visitor retrieval is voluntary. Respect declined invitations and do not repeatedly solicit the same individual. Protect confidential credentials and records.
	<br>
	<br><b>6. REGIONAL FREIGHT INSPECTION</b>
	<br>Security shall compare incoming inspection consignments against the official manifest. Remove undeclared goods and secure them as evidence; do not appropriate them. Stamp the original manifest, return it inside the crate with the declared goods, and certify the consignment with your registered Security identification before dispatching it through the outbound freight lane. These consignments are not discretionary supplies.
	<br>
	<br><b>7. CLASSIFIED ASSET DENIAL CONTINGENCY</b>
	<br>The NT-ADP-7 Asset Denial Device is a classified emergency contingency intended to prevent unauthorized acquisition of sensitive corporate assets. The authentication disk must remain secured at all times in the personal custody of authorized personnel. Do not leave it unattended. Keep associated authorization information separately secured and report suspected loss, theft or compromise immediately.
	<br>Asset denial is a measure of last resort. Activation is prohibited during ordinary security incidents, administrative disputes or routine evacuation. If the device is activated without authorization, prioritize preventing detonation where safely practicable, notify Central Command and prepare for emergency evacuation.
	<br>
	<br><b>8. GENERAL CONDUCT</b>
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

// Recovered lower-deck data printout from the destroyed Syndicate vessel.
// Place /obj/item/paper/fluff/ruins/ccpost/syndicate_wreck_log on a turf
// beside the damaged terminal in the surviving lower half of the wreck.
/obj/item/paper/fluff/ruins/ccpost/syndicate_wreck_log
	name = "recovered SSV EAVESDROPPER mission log"
	desc = "A damaged Syndicate operations printout recovered from a wrecked vessel. The bottom of the record is scorched and abruptly cut off."

/obj/item/paper/fluff/ruins/ccpost/syndicate_wreck_log/Initialize(mapload)
	. = ..()
	add_raw_text({"<center><b>SYNDICATE OPERATIONS DIVISION</b><br><b>RECOVERED MISSION LOG: SSV EAVESDROPPER</b></center><hr>
	<b>Operation:</b> SILENT EMBER<br>
	<b>Target:</b> NanoTrasen Central Command Liaison Outpost<br>
	<b>Objective:</b> Infiltrate installation, recover classified intelligence, and deploy nuclear payload.<br><br>
	<b>Assigned Operatives:</b><br>
	Agent Crimson, Team Leader<br>
	Agent Crowbar, Demolitions Specialist<br>
	Agent Cobalt, Infiltration Specialist<br>
	Agent Dagger, Weapons Specialist<br>
	Agent Wrench, Pilot and Engineer<br><hr>
	<b>23:43 | Agent Wrench:</b> Approach vector confirmed. Outpost looks lightly staffed. Awaiting final order to breach.<br>
	<b>23:45 | Agent Crimson:</b> No open broadcasts. We take the records first, then plant the charge. Maintain radio discipline.<br>
	<b>23:47 | Agent Cobalt:</b> Automated perimeter defenses just acquired us. Multiple turret contacts. This is NOT a passive installation.<br>
	<b>23:48 | Agent Wrench:</b> First impacts across upper gun deck. Returning fire. Control link still responding.<br>
	<b>23:49 | Agent Dagger:</b> They're tracking our course correction. Crowbar, Cobalt, answer your damn radios.<br>
	<b>23:50 | Agent Crimson:</b> Upper hull is gone. Crowbar and Cobalt are unresponsive. Abort the boarding plan. Wrench, get us out.<br>
	<b>23:51 | Agent Wrench:</b> ANOTHER SALVO INCOMING! BRACE FOR IMPA :::<br><hr>
	<small>DATA EXTRACTION INCOMPLETE. ORIGINAL SOURCE MEDIUM LOST.</small>"})
	update_appearance()

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
Visitor retrieval is voluntary. Declining an invitation does not affect your standing. Security may inspect declared equipment and require an escort. Liaisons conduct administrative oversight and report findings to Central Command. They do not command station personnel, station security, or station leadership. Outpost Security authority applies to this installation and its immediate premises only.<br><br>
<b>IN AN EMERGENCY</b><br>
Follow Outpost Security instructions and keep clear of restricted compartments and exterior defenses. Contact the Liaison or Security Office for assistance.<br><br>
<center><i>NanoTrasen appreciates your cooperation. Unauthorized visits may be rescheduled indefinitely.</i></center>
"}

/obj/item/radio/headset/headset_cent/alt/ccpost
	keyslot = /obj/item/encryptionkey/headset_cent
	keyslot2 = null

/obj/item/radio/headset/headset_cent/alt/ccpost/talk_into_impl(atom/movable/talking_movable, message, channel, list/spans, datum/language/language, list/message_mods)
	if(channel != RADIO_CHANNEL_CENTCOM && !(channel == MODE_DEPARTMENT && channels[1] == RADIO_CHANNEL_CENTCOM))
		return
	return ..()

/obj/item/radio/headset/headset_cent/alt/ccpost/liaison
	name = "Central Command Liaison headset"
	desc = "A secure headset for Central Command Liaisons. Monitors station communications and protects against flashbangs."

/obj/item/radio/headset/headset_cent/alt/ccpost/security
	name = "Central Command Outpost Security headset"
	desc = "A secure headset for Outpost Security personnel. Monitors station communications and protects against flashbangs."
	keyslot = /obj/item/encryptionkey/headset_cent
	keyslot2 = null

/obj/item/card/id/advanced/centcom/ccpost_liaison
	name = "Central Command Liaison ID"

/obj/item/card/id/advanced/centcom/ccpost_security
	name = "Central Command Outpost Security ID"

// CentCom-funded personal payroll for the two outpost ghost IDs.
// Bank accounts are registered so card payments/ATMs can use them.
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
		ccpost_hr_register_employee(user, src)

/obj/item/card/id/advanced/centcom/ccpost_security/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_ID)
		ccpost_initialize_personal_payroll(src, user)
		ccpost_hr_register_employee(user, src)


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
	new /obj/item/detective_scanner(src)
	new /obj/item/storage/box/evidence(src)
	new /obj/item/clipboard(src)
	new /obj/item/stamp/centcom(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/lockbox/loyalty/ccpost(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/under/rank/centcom/official(src)
	new /obj/item/clothing/under/rank/centcom/official/skirt(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/binoculars(src)


/// Mindshield supplies accessible to authorized outpost personnel, not station Security.
/// Contents inherit vanilla loyalty lockbox population (three implants and one implanter).
/obj/item/storage/lockbox/loyalty/ccpost
	name = "Central Command mindshield implant lockbox"
	desc = "A secured set of mindshield implants for Central Command outpost personnel."
	req_access = list(ACCESS_NT_REPRESENTATVE)

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
		"Liaison, don't forget to regularly check the tasking terminal for new assignments.",
		"Oversight is not command. Requests for cooperation do not constitute orders.",
		"Review existing records before requesting paperwork. An engineer's time during a reactor emergency is not inexpensive.",
		"A department preventing a catastrophe may be excused from explaining the catastrophe in writing.",
		"A report explaining why information could not be obtained remains a report. Inventing it is a disciplinary matter.",
		"Do not penalize unavailable departments for attending to essential duties.",
		"A concise inquiry is usually preferable to three separate inquiries on the same subject.",
		"Regional records and correspondence are also legitimate administrative work.",
		"Installation Security is responsible for this facility. Station Security remains responsible for the station.",
		"Visiting personnel are entitled to professional treatment, not the contents of our armory.",
		"The emergency armory exists for emergencies. A disagreement over paperwork does not qualify.",
		"Compare inspection consignments with their manifest before returning them to Sector Logistics.",
		"Undeclared equipment belongs in evidence storage, not your personal collection.",
		"A clean freight inspection is a successful inspection. Please do not invent discrepancies.",
		"The original inspection manifest must accompany its declared contents upon return.",
		"A stamped manifest and Security certification are required for onward dispatch.",
		"The NT-ADP-7 authentication disk must remain in the personal custody of authorized personnel.",
		"An unattended authentication disk is not adequately secured, even inside a locker.",
		"Asset denial is a contingency of last resort. It is not an approved method of resolving complaints.",
		"Report missing restricted authentication material immediately.",
		"Keep the authentication disk and authorization information separate. One mistake should not become two.",
		"Should asset denial commence without authorization, prioritize personnel safety and notify Central Command.",
		"Respect a declined visitor invitation. Consent is not an administrative obstacle to be overcome.",
		"Restore power before attempting to recalibrate an unpowered administrative server.",
		"Human Resources records are private. Curiosity does not constitute authorization.",
		"Central Command approves recreational fishing, provided installation readiness is maintained.",
		"The fish have not received security clearance. Their access should remain limited to the aquarium.",
		"Fishing equipment is recreational equipment. A colleague's belongings are not a fishing destination.",
		"Before committing allocation to a requisition, review the installation's actual needs."
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

/obj/projectile/beam/ccpost_perimeter_pulse
	name = "Central Command perimeter pulse"
	icon_state = "u_laser"
	damage = 32
	range = 50
	damage_walls = FALSE
	ricochets_max = 0
	ricochet_chance = 0
	reflectable = FALSE
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/energy/electrode/ccpost_perimeter
	range = 9

/obj/structure/barricade/security/ccpost
	name = "Central Command security barrier"

/obj/structure/barricade/security/ccpost/attackby(obj/item/tool, mob/living/user, params)
	var/obj/item/card/id/identification = tool.GetID()
	if(istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security))
		toggle_lock(user)
		return
	return ..()

/obj/structure/barricade/security/ccpost/attack_hand_secondary(mob/living/user, list/modifiers)
	var/obj/item/card/id/identification = user.get_idcard()
	if(istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security))
		toggle_lock(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/grenade/ccpost_barrier
	name = "Central Command barrier grenade"
	desc = "Deploys Central Command security barricades authorized for outpost personnel."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "wallbang"
	inhand_icon_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = "single"

/obj/item/grenade/ccpost_barrier/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/grenade/ccpost_barrier/examine(mob/user)
	. = ..()
	. += span_notice("Current Mode: [capitalize(mode)]. Alt-click to switch the current mode.")

/obj/item/grenade/ccpost_barrier/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "wallbang-[mode]")
	. += emissive_appearance(icon, "wallbang-[mode]", src, alpha = src.alpha)

/obj/item/grenade/ccpost_barrier/click_alt(mob/living/carbon/user)
	toggle_mode(user)
	return CLICK_ACTION_SUCCESS

/obj/item/grenade/ccpost_barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if("single")
			mode = "vertical"
		if("vertical")
			mode = "horizontal"
		else
			mode = "single"
	playsound(src, 'sound/machines/click.ogg', 50)
	to_chat(user, span_notice("[src] is now in [mode] mode."))
	update_appearance(UPDATE_OVERLAYS)

/obj/item/grenade/ccpost_barrier/ui_action_click(mob/user)
	toggle_mode(user)

/obj/item/grenade/ccpost_barrier/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	var/turf/center = get_turf(src)
	if(!center)
		qdel(src)
		return
	new /obj/structure/barricade/security/ccpost(center)
	var/list/directions = list()
	switch(mode)
		if("vertical")
			directions = list(NORTH, SOUTH)
		if("horizontal")
			directions = list(EAST, WEST)
	for(var/direction in directions)
		var/turf/target = get_step(center, direction)
		if(target && !target.is_blocked_turf())
			new /obj/structure/barricade/security/ccpost(target)
	qdel(src)

/obj/structure/closet/secure_closet/ccpost_armory
	name = "Central Command emergency armory"
	desc = "A limited emergency weapons and barricade reserve for Central Command outpost personnel."
	icon_state = "armory"
	req_access = list(ACCESS_NT_REPRESENTATVE, ACCESS_CENT_LIVING)
	anchored = TRUE

/obj/structure/closet/secure_closet/ccpost_armory/can_unlock(mob/living/user, obj/item/card/id/player_id, obj/item/card/id/registered_id)
	if(isAdminGhostAI(user))
		return TRUE
	return istype(player_id, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(player_id, /obj/item/card/id/advanced/centcom/ccpost_security)

/obj/structure/closet/secure_closet/ccpost_armory/PopulateContents()
	..()
	new /obj/item/gun/ballistic/automatic/wt550(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/storage/box/lethalshot(src)
	new /obj/item/grenade/ccpost_barrier(src)
	new /obj/item/grenade/ccpost_barrier(src)
	new /obj/item/stack/sheet/mineral/sandbags(src, 3)
	new /obj/item/gun/energy/ionrifle(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/storage/box/beanbag(src)
	new /obj/item/storage/box/rubbershot(src)
	new /obj/item/shield/riot(src)
	new /obj/item/shield/riot(src)
	new /obj/item/door_seal(src)
	new /obj/item/door_seal(src)
	new /obj/item/grenade/ccpost_barrier(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet/sec(src)
		new /obj/item/clothing/gloves/combat(src)

/obj/structure/closet/secure_closet/ccpost_armory/populate_contents_immediate()
	. = ..()
	new /obj/item/gun/ballistic/shotgun/riot(src)
	new /obj/item/gun/energy/e_gun(src)
	new /obj/item/gun/energy/disabler(src)

#define CCPOST_TURRET_SHOOT_ANOMALOUS (1<<4)
#define CCPOST_TURRET_SHOOT_UNSHIELDED (1<<5)

/obj/machinery/porta_turret/ccpost/perimeter
	name = "Central Command perimeter turret"
	base_icon_state = "syndie"
	icon_state = "syndie_off"
	desc = "An automated lethal-ready pulse defense turret controlled by Central Command Security."
	installation = null
	uses_stored = FALSE
	use_power = NO_POWER_USE
	has_cover = FALSE
	always_up = TRUE
	max_integrity = 200
	scan_range = 9
	shot_delay = 10
	req_access = list(ACCESS_NT_REPRESENTATVE)
	turret_flags = CCPOST_TURRET_SHOOT_UNSHIELDED | CCPOST_TURRET_SHOOT_ANOMALOUS
	faction = list(FACTION_TURRET, FACTION_TAMED, FACTION_SILICON)
	stun_projectile = /obj/projectile/energy/electrode/ccpost_perimeter
	stun_projectile_sound = 'sound/items/weapons/taser.ogg'
	lethal_projectile = /obj/projectile/beam/ccpost_perimeter_pulse
	lethal_projectile_sound = 'sound/items/weapons/pulse.ogg'
	mode = 1
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
	if(istype(identification, /obj/item/card/id/advanced/centcom))
		return 0
	return ..()

/obj/machinery/turretid/ccpost/perimeter
	name = "Central Command perimeter defense controller"
	desc = "Controls the external automated defense turrets of this Central Command outpost."
	req_access = list(ACCESS_NT_REPRESENTATVE)
	system_id = "ccpost_perimeter"
	enabled = TRUE
	lethal = TRUE
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

/obj/machinery/porta_turret/ccpost/perimeter/vault
	name = "Central Command vault defense turret"
	desc = "An automated pulse defense turret assigned to protect classified Central Command assets and records."
	system_id = "ccpost_vault"
	scan_range = 6
	max_integrity = 250

// Dedicated vault turret controller.
// Inherits the existing outpost's restricted ID authentication.

/obj/machinery/turretid/ccpost/perimeter/vault
	name = "Central Command vault defense controller"
	desc = "Controls the automated security turrets protecting classified Central Command assets."
	system_id = "ccpost_vault"
	enabled = TRUE
	lethal = TRUE
	ailock = TRUE

// CENTRAL COMMAND VISITOR RETURN TRANSPORT
// Map one shared visitor pad and the separate departure and retrieval consoles.
// Both consoles discover the same nearby pad; no station teleporter is required for retrieval.
#define CCPOST_VISITOR_CHARGE 5 SECONDS
#define CCPOST_VISITOR_COOLDOWN 5 SECONDS

/// Only a Liaison or Outpost Security credential can operate the console.
/proc/ccpost_visitor_transport_authorized(mob/user)
	var/mob/living/carbon/human/human = user
	if(!istype(human))
		return FALSE
	var/obj/item/card/id/card = human.wear_id?.GetID()
	return istype(card, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(card, /obj/item/card/id/advanced/centcom/ccpost_security)

/// Prevent staff from abusing the visitor shuttle even after dropping their ID.
/// Both authenticated role IDs and mind-bound outpost HR enrollment are checked.
/proc/ccpost_is_outpost_personnel(mob/living/carbon/human/person)
	if(!istype(person))
		return FALSE
	var/obj/item/card/id/card = person.wear_id?.GetID()
	if(istype(card, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(card, /obj/item/card/id/advanced/centcom/ccpost_security))
		return TRUE
	if(!person.mind || !GLOB.ccpost_hr_service)
		return FALSE
	var/datum/ccpost_hr_employee/rostered = GLOB.ccpost_hr_service.roster[REF(person.mind)]
	return rostered?.employee_mind == person.mind && (rostered.employee_role == "Central Command Liaison" || rostered.employee_role == "Outpost Security Officer")

/// Distinguishes an invalid tracking beacon from a temporarily blocked landing site.
/// State is recalculated, so a visitor standing on the beacon does not erase its selection.
/proc/ccpost_visitor_beacon_state(obj/item/beacon/beacon)
	if(QDELETED(beacon))
		return "missing"
	if(!beacon.enabled || !(beacon in GLOB.teleportbeacons))
		return "disabled"
	var/turf/center = get_turf(beacon)
	if(!center || !is_station_level(center.z))
		return "offstation"
	var/area/landing_area = get_area(center)
	if(!landing_area || (landing_area.area_flags & NOTELEPORT))
		return "restricted"
	if(is_safe_turf(center, no_teleport = TRUE))
		return "ready"
	// The same environmental checks, without atom density, differentiate crowding
	// from vacuum, fire, invalid floor tiles, and otherwise unsafe destinations.
	if(!is_safe_turf(center, dense_atoms = TRUE, no_teleport = TRUE))
		return "unsafe"
	for(var/direction in GLOB.cardinals)
		var/turf/adjacent = get_step(center, direction)
		if(!adjacent || adjacent.z != center.z || get_area(adjacent) != landing_area)
			continue
		if(is_safe_turf(adjacent, no_teleport = TRUE))
			return "adjacent"
	return "occupied"

/// Prefer the registered beacon tile; use only cardinal tiles in the same station
/// area as a fallback. No diagonal jumps or landing outside the beacon's room.
/proc/ccpost_visitor_landing_turf(obj/item/beacon/beacon)
	var/state = ccpost_visitor_beacon_state(beacon)
	if(state == "ready")
		return get_turf(beacon)
	if(state != "adjacent")
		return null
	var/turf/center = get_turf(beacon)
	var/area/landing_area = get_area(center)
	for(var/direction in GLOB.cardinals)
		var/turf/adjacent = get_step(center, direction)
		if(!adjacent || adjacent.z != center.z || get_area(adjacent) != landing_area)
			continue
		if(is_safe_turf(adjacent, no_teleport = TRUE))
			return adjacent
	return null

/proc/ccpost_visitor_beacon_status_text(state)
	switch(state)
		if("ready")
			return "Beacon landing tile available."
		if("adjacent")
			return "Beacon landing tile occupied. Safe adjacent landing available."
		if("occupied")
			return "Landing area temporarily occupied. Destination remains selected."
		if("disabled")
			return "Tracking beacon disabled or deregistered."
		if("offstation")
			return "Tracking beacon is outside the station."
		if("restricted")
			return "Tracking beacon is in a restricted teleportation area."
		if("unsafe")
			return "Landing area unsafe. Check atmosphere and obstructions."
	return "Tracking beacon no longer exists. Select another destination."

/obj/effect/temp_visual/teleport_abductor/ccpost_departure
	duration = CCPOST_VISITOR_CHARGE

/obj/machinery/ccpost_visitor_pad
	name = "Central Command visitor telepad"
	desc = "A bluespace visitor pad used for supervised arrivals and departures at the outpost."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcast receiver"
	density = FALSE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/mob/living/carbon/human/charging_passenger
	var/obj/machinery/computer/ccpost_visitor_transport/controlling_console
	/// One reservation for inbound and outbound operations across all linked consoles.
	var/obj/machinery/reserved_by

/obj/machinery/ccpost_visitor_pad/Destroy()
	if(controlling_console?.linked_pad == src)
		controlling_console.linked_pad = null
	controlling_console = null
	charging_passenger = null
	reserved_by = null
	return ..()

/obj/machinery/computer/ccpost_visitor_transport
	name = "Central Command visitor transport console"
	desc = "Authorizes supervised departure of station visitors to an active station tracking beacon."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	light_color = LIGHT_COLOR_BLUE
	/// The closest compatible pad is discovered automatically.
	var/obj/machinery/ccpost_visitor_pad/linked_pad
	/// Station teleporter registry, with weak reference to avoid stale destinations.
	var/datum/weakref/selected_beacon
	var/charging = FALSE
	var/next_transport_allowed = 0
	/// Unique sequence prevents cancelled timers from completing a later transport.
	var/transport_sequence = 0
	var/status_message = "Transport system initialized."
	var/destination_refresh_scheduled = FALSE

/obj/machinery/computer/ccpost_visitor_transport/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ccpost_visitor_transport/LateInitialize(mapload_arg)
	link_visitor_pad()

/obj/machinery/computer/ccpost_visitor_transport/Destroy()
	if(linked_pad?.reserved_by == src)
		linked_pad.reserved_by = null
	if(linked_pad?.controlling_console == src)
		linked_pad.controlling_console = null
	linked_pad = null
	selected_beacon = null
	return ..()

/obj/machinery/computer/ccpost_visitor_transport/proc/link_visitor_pad()
	if(linked_pad && !QDELETED(linked_pad))
		return linked_pad
	var/obj/machinery/ccpost_visitor_pad/best_pad
	var/best_distance = INFINITY
	for(var/obj/machinery/ccpost_visitor_pad/pad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ccpost_visitor_pad))
		if(QDELETED(pad) || pad.z != z || (pad.controlling_console && pad.controlling_console != src))
			continue
		var/distance = get_dist(src, pad)
		if(distance > 8 || distance >= best_distance)
			continue
		best_pad = pad
		best_distance = distance
	if(best_pad)
		linked_pad = best_pad
		best_pad.controlling_console = src
	return linked_pad

/obj/machinery/computer/ccpost_visitor_transport/proc/collect_station_beacons()
	var/list/available = list()
	for(var/obj/item/beacon/beacon as anything in GLOB.teleportbeacons)
		if(ccpost_visitor_beacon_state(beacon) in list("missing", "disabled", "offstation", "restricted", "unsafe"))
			continue
		available += beacon
	return available

/obj/machinery/computer/ccpost_visitor_transport/ui_status(mob/user)
	if(isobserver(user))
		return UI_INTERACTIVE
	if(!ccpost_visitor_transport_authorized(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/ccpost_visitor_transport/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user) && !ccpost_visitor_transport_authorized(user))
		balloon_alert(user, "outpost personnel ID required")
		return
	. = ..()
	link_visitor_pad()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostVisitorTransport", name)
		ui.open()

/obj/machinery/computer/ccpost_visitor_transport/ui_data(mob/user)
	if(!isobserver(user) && !ccpost_visitor_transport_authorized(user))
		return list()
	link_visitor_pad()
	var/list/data = list()
	data["read_only"] = isobserver(user)
	data["outpost_offline"] = GLOB.ccpost_outpost_signal_lost
	data["pad_linked"] = !!linked_pad
	data["charging"] = charging
	data["pad_busy"] = !!linked_pad?.reserved_by && linked_pad.reserved_by != src
	data["cooldown_seconds"] = max(0, round((next_transport_allowed - world.time) / (1 SECONDS)))
	data["console_operational"] = !(machine_stat & (BROKEN | NOPOWER))
	data["status_message"] = status_message

	var/mob/living/carbon/human/passenger = get_single_visitor()
	var/passenger_eligible = passenger && passenger.stat != DEAD && !passenger.buckled
	data["passenger_available"] = !!passenger_eligible
	data["passenger_name"] = passenger_eligible ? passenger.name : "No eligible passenger detected on the pad."

	var/obj/item/beacon/selected = selected_beacon?.resolve()
	data["destination_name"] = selected ? selected.name : "No destination selected"
	data["destination_area"] = selected ? "[get_area(selected)]" : ""
	var/turf/selected_turf = get_turf(selected)
	data["destination_coordinates"] = selected_turf ? "[selected_turf.x], [selected_turf.y], z[selected_turf.z]" : ""
	var/destination_state = selected ? ccpost_visitor_beacon_state(selected) : "missing"
	data["destination_valid"] = !!ccpost_visitor_landing_turf(selected)
	data["destination_state"] = destination_state
	data["destination_status_text"] = selected ? ccpost_visitor_beacon_status_text(destination_state) : "Select a station tracking beacon."
	if(selected && destination_state == "occupied")
		schedule_destination_refresh()
	data["destination_ref"] = selected ? REF(selected) : null

	var/list/available = list()
	for(var/obj/item/beacon/beacon as anything in collect_station_beacons())
		var/turf/position = get_turf(beacon)
		var/area/beacon_area = get_area(beacon)
		available += list(list(
			"ref" = REF(beacon),
			"name" = beacon.name,
			"area" = beacon_area.name,
			"coordinates" = "[position.x], [position.y], z[position.z]",
			"availability" = ccpost_visitor_beacon_state(beacon)
		))
	data["beacons"] = available
	return data

/obj/machinery/computer/ccpost_visitor_transport/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(GLOB.ccpost_outpost_signal_lost)
		return TRUE
	// Enforce permissions at the server, including stale windows and crafted TGUI actions.
	var/mob/user = ui?.user
	if(isobserver(user) || !ccpost_visitor_transport_authorized(user) || !user.can_perform_action(src))
		return TRUE
	if(machine_stat & (BROKEN | NOPOWER))
		return TRUE
	. = ..()
	if(.)
		return
	if(action == "clear_beacon")
		if(charging)
			status_message = "Cannot deselect a destination during an active transport."
			return TRUE
		selected_beacon = null
		status_message = "Tracking beacon selection cleared."
		add_fingerprint(user)
		SStgui.update_uis(src)
		return TRUE
	link_visitor_pad()
	if(!linked_pad)
		status_message = "Transport unavailable: No linked visitor pad detected."
		return TRUE
	switch(action)
		if("select_beacon")
			if(charging)
				status_message = "Destination locked while transport is in progress."
				return TRUE
			var/obj/item/beacon/choice = locate(params["beacon_ref"])
			if(!(choice in collect_station_beacons()))
				status_message = "Destination unavailable: Select an active station beacon."
				return TRUE
			selected_beacon = WEAKREF(choice)
			status_message = "Destination locked: [choice.name]. [ccpost_visitor_beacon_status_text(ccpost_visitor_beacon_state(choice))]"
			add_fingerprint(user)
			log_game("CCPost visitor transport destination selected by [key_name(user)]: [choice] at [loc_name(choice)].")
			return TRUE
		if("begin_transport")
			begin_transport(user)
			return TRUE
		if("cancel_transport")
			if(charging)
				cancel_transport(user)
			return TRUE
	return FALSE

/// A single bounded recheck updates an open interface after the destination clears.
/obj/machinery/computer/ccpost_visitor_transport/proc/schedule_destination_refresh()
	if(destination_refresh_scheduled)
		return
	destination_refresh_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(refresh_destination_status)), 3 SECONDS)

/obj/machinery/computer/ccpost_visitor_transport/proc/refresh_destination_status()
	destination_refresh_scheduled = FALSE
	if(QDELETED(src))
		return
	SStgui.update_uis(src)
	var/obj/item/beacon/beacon = selected_beacon?.resolve()
	if(beacon && ccpost_visitor_beacon_state(beacon) == "occupied")
		schedule_destination_refresh()

/obj/machinery/computer/ccpost_visitor_transport/proc/cancel_transport(mob/user)
	if(!charging)
		return
	charging = FALSE
	transport_sequence++
	if(linked_pad)
		linked_pad.charging_passenger = null
		if(linked_pad.reserved_by == src)
			linked_pad.reserved_by = null
	next_transport_allowed = world.time + CCPOST_VISITOR_COOLDOWN
	status_message = "Transport sequence cancelled."
	visible_message(span_notice("[src] aborts its visitor transport sequence."))
	log_game("CCPost visitor transport cancelled by [key_name(user)].")
	SStgui.update_uis(src)

/obj/machinery/computer/ccpost_visitor_transport/proc/get_single_visitor()
	if(!linked_pad || QDELETED(linked_pad))
		return null
	var/turf/pad_turf = get_turf(linked_pad)
	var/mob/living/carbon/human/passenger
	for(var/mob/living/carbon/human/candidate in pad_turf)
		if(candidate.stat == DEAD || ccpost_is_outpost_personnel(candidate))
			continue
		if(passenger)
			return null // Pad is occupied by more than one eligible visitor.
		passenger = candidate
	return passenger

/obj/machinery/computer/ccpost_visitor_transport/proc/begin_transport(mob/user)
	if(linked_pad?.reserved_by && linked_pad.reserved_by != src)
		status_message = "The telepad is reserved for another transport operation."
		return
	if(charging || world.time < next_transport_allowed)
		status_message = "Transport is charging or cooling down."
		balloon_alert(user, "transport cooling down")
		return
	var/obj/item/beacon/beacon = selected_beacon?.resolve()
	if(!ccpost_visitor_landing_turf(beacon))
		status_message = ccpost_visitor_beacon_status_text(ccpost_visitor_beacon_state(beacon))
		balloon_alert(user, "landing area unavailable")
		return
	var/mob/living/carbon/human/passenger = get_single_visitor()
	if(!passenger || passenger.buckled || passenger == user)
		status_message = "Transport unavailable: No eligible passenger detected on the pad."
		balloon_alert(user, "no eligible passenger detected")
		return
	charging = TRUE
	linked_pad.reserved_by = src
	transport_sequence++
	status_message = "Charging: [passenger.name] to [beacon.name]."
	linked_pad.charging_passenger = passenger
	visible_message(span_notice("[src] initiates visitor transport. The telepad charges."))
	new /obj/effect/temp_visual/teleport_abductor/ccpost_departure(get_turf(linked_pad))
	playsound(linked_pad, 'sound/machines/terminal/terminal_alert.ogg', vol = 65, vary = TRUE)
	log_game("CCPost visitor transport initiated by [key_name(user)] for [key_name(passenger)] to [beacon].")
	addtimer(CALLBACK(src, PROC_REF(finish_transport), WEAKREF(passenger), WEAKREF(beacon), transport_sequence), CCPOST_VISITOR_CHARGE)
	SStgui.update_uis(src)

/obj/machinery/computer/ccpost_visitor_transport/proc/finish_transport(datum/weakref/passenger_ref, datum/weakref/beacon_ref, expected_sequence)
	if(!charging || expected_sequence != transport_sequence)
		return
	charging = FALSE
	next_transport_allowed = world.time + CCPOST_VISITOR_COOLDOWN
	var/mob/living/carbon/human/passenger = passenger_ref?.resolve()
	if(linked_pad)
		linked_pad.charging_passenger = null
		if(linked_pad.reserved_by == src)
			linked_pad.reserved_by = null
	if(QDELETED(passenger) || !linked_pad || QDELETED(linked_pad) || passenger.stat == DEAD || passenger.buckled || ccpost_is_outpost_personnel(passenger) || get_turf(passenger) != get_turf(linked_pad))
		status_message = "Transport cancelled: No eligible passenger detected on the pad."
		say(status_message)
		SStgui.update_uis(src)
		return
	var/obj/item/beacon/beacon = beacon_ref?.resolve()
	if(beacon != selected_beacon?.resolve())
		status_message = "Transport cancelled: Destination was changed."
		say(status_message)
		SStgui.update_uis(src)
		return
	var/turf/landing = ccpost_visitor_landing_turf(beacon)
	if(!landing || (machine_stat & (BROKEN | NOPOWER)))
		status_message = "Transport cancelled: [ccpost_visitor_beacon_status_text(ccpost_visitor_beacon_state(beacon))]"
		say(status_message)
		SStgui.update_uis(src)
		return
	var/turf/departure = get_turf(passenger)
	if(!do_teleport(passenger, landing, channel = TELEPORT_CHANNEL_BLUESPACE))
		status_message = "Transport failed: Bluespace interference detected."
		say(status_message)
		SStgui.update_uis(src)
		return
	new /obj/effect/temp_visual/dir_setting/ninja(departure, passenger.dir)
	new /obj/effect/temp_visual/dir_setting/ninja(landing, passenger.dir)
	playsound(departure, SFX_PORTAL_ENTER, 50, TRUE)
	playsound(landing, SFX_PORTAL_ENTER, 50, TRUE)
	log_game("CCPost visitor transport completed for [key_name(passenger)] from [loc_name(departure)] to [loc_name(landing)].")
	status_message = "Transport successful: [passenger.name] to [beacon.name]."
	if(ccpost_visitor_beacon_state(beacon) == "occupied")
		schedule_destination_refresh()
	visible_message(span_notice("[src] completes the visitor transport sequence."))
	SStgui.update_uis(src)


// CENTRAL COMMAND VISITOR RETRIEVAL
// Separate physical camera console, using the same Visitor Transport TGUI and telepad.
// Does not depend on the station's teleporter, its hub, or a station tracking beacon.
#define CCPOST_RETRIEVAL_INVITATION_TIMEOUT 20 SECONDS
#define CCPOST_RETRIEVAL_DECLINE_COOLDOWN 3 MINUTES
#define CCPOST_RETRIEVAL_TIMEOUT_COOLDOWN 2 MINUTES
#define CCPOST_RETRIEVAL_SHARED_COOLDOWN 30 SECONDS

/// Round-local per-person invitation state shared across every retrieval console.
/// Reference-string keys prevent different consoles from bypassing the same-person cooldown.
GLOBAL_LIST_EMPTY(ccpost_visitor_retrieval_pending)
GLOBAL_LIST_EMPTY(ccpost_visitor_retrieval_cooldowns)
/// Shared by all visitor retrieval consoles so moving to a second desk cannot
/// bypass the administrative recalibration window. Outbound transport is separate.
GLOBAL_VAR_INIT(ccpost_visitor_retrieval_next_allowed, 0)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval
	name = "Central Command visitor retrieval console"
	desc = "Selects station visitors through the camera network and invites them to Central Command's reception telepad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	light_color = LIGHT_COLOR_BLUE
	networks = list(CAMERANET_NETWORK_SS13)
	lock_override = CAMERA_LOCK_STATION
	var/obj/machinery/ccpost_visitor_pad/linked_pad
	var/datum/weakref/selected_visitor
	var/awaiting_consent = FALSE
	var/charging = FALSE
	var/transport_sequence = 0
	var/next_transport_allowed = 0
	var/status_message = "Visitor retrieval system initialized."

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/Initialize(mapload)
	. = ..()
	actions += new /datum/action/innate/ccpost_select_retrieval_visitor(src)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/LateInitialize(mapload_arg)
	link_retrieval_pad()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/Destroy()
	transport_sequence++
	// A dismantled console must not leave a phantom network-wide pending invite.
	for(var/person_key in GLOB.ccpost_visitor_retrieval_pending)
		if(GLOB.ccpost_visitor_retrieval_pending[person_key] == REF(src))
			GLOB.ccpost_visitor_retrieval_pending -= person_key
	if(linked_pad?.reserved_by == src)
		linked_pad.reserved_by = null
	linked_pad = null
	selected_visitor = null
	return ..()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/link_retrieval_pad()
	if(linked_pad && !QDELETED(linked_pad))
		return linked_pad
	linked_pad = null
	var/best_distance = INFINITY
	for(var/obj/machinery/ccpost_visitor_pad/pad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ccpost_visitor_pad))
		if(QDELETED(pad) || pad.z != z)
			continue
		var/distance = get_dist(src, pad)
		if(distance >= best_distance)
			continue
		best_distance = distance
		linked_pad = pad
	return linked_pad

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/visitor_eligible(mob/living/carbon/human/person)
	// A station employee remains camera-selectable while SSD. They still
	// require explicit consent after reconnecting; no automatic transport.
	if(!istype(person) || QDELETED(person) || person.stat == DEAD || person.buckled || ccpost_is_outpost_personnel(person))
		return FALSE
	var/turf/origin = get_turf(person)
	if(!origin || !is_station_level(origin.z))
		return FALSE
	var/area/origin_area = get_area(origin)
	if(!origin_area || (origin_area.area_flags & (NOTELEPORT | ABDUCTOR_PROOF)))
		return FALSE
	if(!is_safe_turf(origin, dense_atoms = TRUE, no_teleport = TRUE))
		return FALSE
	return camnet && camnet.turf_visible_by_cameras(origin)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/can_use(mob/living/user)
	return ccpost_visitor_transport_authorized(user) && ..()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_status(mob/user)
	if(isobserver(user))
		return UI_INTERACTIVE
	if(!ccpost_visitor_transport_authorized(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/attack_hand(mob/user, list/modifiers)
	if(!isobserver(user) && !ccpost_visitor_transport_authorized(user))
		balloon_alert(user, "outpost ID required")
		return
	ui_interact(user)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user) && !ccpost_visitor_transport_authorized(user))
		return
	. = ..()
	link_retrieval_pad()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostVisitorTransport", name)
		ui.open()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_data(mob/user)
	if(!isobserver(user) && !ccpost_visitor_transport_authorized(user))
		return list()
	link_retrieval_pad()
	var/mob/living/carbon/human/person = selected_visitor?.resolve()
	var/list/data = list(
		"retrieval_mode" = TRUE,
		"outpost_offline" = GLOB.ccpost_outpost_signal_lost,
		"read_only" = isobserver(user),
		"console_operational" = !(machine_stat & (BROKEN | NOPOWER)),
		"pad_linked" = !!linked_pad,
		"pad_busy" = !!linked_pad?.reserved_by && linked_pad.reserved_by != src,
		"charging" = charging,
		"request_pending" = awaiting_consent,
		"cooldown_seconds" = max(0, round((max(next_transport_allowed, GLOB.ccpost_visitor_retrieval_next_allowed) - world.time) / (1 SECONDS))),
		"camera_active" = !!current_user,
		"status_message" = status_message,
		"selected_target_name" = person ? person.name : "No visitor selected",
		"selected_target_area" = person ? get_area_name(person) : "",
		"selected_target_valid" = visitor_eligible(person),
		"invitation_cooldown_seconds" = person ? max(0, round((GLOB.ccpost_visitor_retrieval_cooldowns[REF(person)] - world.time) / (1 SECONDS))) : 0
	)
	return data

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(GLOB.ccpost_outpost_signal_lost)
		return TRUE
	var/mob/user = ui?.user
	if(isobserver(user) || !ccpost_visitor_transport_authorized(user) || !user.can_perform_action(src))
		return TRUE
	if(machine_stat & (BROKEN | NOPOWER))
		return TRUE
	. = ..()
	if(.)
		return
	switch(action)
		if("open_camera")
			open_station_camera(user)
			return TRUE
		if("clear_target")
			if(!awaiting_consent && !charging)
				selected_visitor = null
				status_message = "Visitor selection cleared."
			return TRUE
		if("request_retrieval")
			if(!awaiting_consent && !charging)
				INVOKE_ASYNC(src, PROC_REF(request_visitor_consent), WEAKREF(user))
			return TRUE
		if("cancel_retrieval")
			if(charging)
				abort_retrieval("Retrieval cancelled by outpost operator.")
			return TRUE
	return FALSE

/// The normal advanced-camera eye is reused. The console itself has a distinct
/// TGUI, while the eye has a single new selection action.
/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/open_station_camera(mob/living/user)
	if(awaiting_consent || charging || !can_use(user) || !user.client)
		return
	if(current_user)
		status_message = "Camera console already in use."
		return
	if(!eyeobj && !CreateEye())
		return
	var/turf/start_turf
	for(var/obj/machinery/camera/camera as anything in camnet.cameras)
		if(!camera.can_use() || !is_station_level(camera.z) || !length(networks & camera.network))
			continue
		start_turf = get_turf(camera)
		break
	if(!start_turf)
		status_message = "No connected station cameras are available."
		return
	give_eye_control(user)
	eyeobj.setLoc(start_turf, TRUE)
	status_message = "Station camera active. Use the Select Visitor action to designate a person."
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/select_camera_visitor(mob/living/user)
	if(user != current_user || !can_use(user) || awaiting_consent || charging)
		return
	var/mob/eye/camera/remote/camera_eye = user.remote_control
	if(camera_eye != eyeobj || !is_station_level(camera_eye.z))
		return
	var/list/possible_visitors = list()
	for(var/mob/living/carbon/human/person in view(5, camera_eye))
		if(visitor_eligible(person))
			possible_visitors += person
	if(!length(possible_visitors))
		to_chat(user, span_warning("No eligible camera-visible station visitors are nearby."))
		return
	var/mob/living/carbon/human/choice = tgui_input_list(user, "Select a camera-visible visitor to invite.", "Visitor Retrieval", possible_visitors, timeout = 20 SECONDS)
	if(!choice || QDELETED(src) || user != current_user || camera_eye != eyeobj || !can_use(user))
		return
	// A stale input window cannot confer eligibility or reach a different subject.
	if(!(choice in possible_visitors) || !visitor_eligible(choice) || get_dist(choice, camera_eye) > 5)
		to_chat(user, span_warning("Selected visitor is no longer in camera view."))
		return
	selected_visitor = WEAKREF(choice)
	status_message = "Selected [choice.name]. Return to the console to send an invitation."
	remove_eye_control(user)
	ui_interact(user)
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/request_visitor_consent(datum/weakref/operator_ref)
	if(awaiting_consent || charging || world.time < max(next_transport_allowed, GLOB.ccpost_visitor_retrieval_next_allowed) || (machine_stat & (BROKEN | NOPOWER)))
		return
	link_retrieval_pad()
	if(!linked_pad || linked_pad.reserved_by)
		status_message = "Visitor telepad is disconnected or occupied."
		return
	var/mob/living/operator = operator_ref?.resolve()
	var/mob/living/carbon/human/person = selected_visitor?.resolve()
	if(!operator || !ccpost_visitor_transport_authorized(operator) || !visitor_eligible(person))
		status_message = "Select a valid camera-visible visitor before requesting retrieval."
		return
	var/person_key = REF(person)
	if(GLOB.ccpost_visitor_retrieval_pending[person_key])
		status_message = "This person already has a pending retrieval invitation."
		return
	if(length(GLOB.ccpost_visitor_retrieval_pending))
		status_message = "A visitor invitation is already pending on the retrieval network."
		return
	var/decline_until = GLOB.ccpost_visitor_retrieval_cooldowns[person_key]
	if(decline_until && world.time < decline_until)
		status_message = "This person has declined recently. Please wait before requesting again."
		return
	awaiting_consent = TRUE
	GLOB.ccpost_visitor_retrieval_pending[person_key] = REF(src)
	var/invitation_expires = world.time + CCPOST_RETRIEVAL_INVITATION_TIMEOUT
	status_message = "Invitation registered for [person.name]. Awaiting voluntary confirmation (20 seconds)."
	log_game("CCPost visitor retrieval invitation sent by [key_name(operator)] to [key_name(person)].")
	SStgui.update_uis(src)
	// An SSD target cannot receive a TGUI alert yet. Keep their invitation
	// pending until they reconnect, or until the original expiry is reached.
	// No auto-accept, admin bypass, or timer reset on reconnection.
	while(!QDELETED(src) && !QDELETED(person) && !person.client && world.time < invitation_expires)
		sleep(5)
	var/choice
	if(!QDELETED(src) && !QDELETED(person) && person.client && world.time < invitation_expires)
		choice = tgui_alert(person, "Central Command Liaison [operator.name] invites you to the Liaison Outpost visitor reception. Accepting begins a five-second bluespace transport charge. This invitation is voluntary.", "Central Command Transport Request", list("Accept Transport", "Decline"), timeout = max(1, invitation_expires - world.time))
	if(GLOB.ccpost_visitor_retrieval_pending[person_key] == REF(src))
		GLOB.ccpost_visitor_retrieval_pending -= person_key
	if(QDELETED(src))
		return
	awaiting_consent = FALSE
	if(choice != "Accept Transport")
		GLOB.ccpost_visitor_retrieval_cooldowns[person_key] = world.time + (choice == "Decline" ? CCPOST_RETRIEVAL_DECLINE_COOLDOWN : CCPOST_RETRIEVAL_TIMEOUT_COOLDOWN)
		GLOB.ccpost_visitor_retrieval_next_allowed = world.time + CCPOST_RETRIEVAL_SHARED_COOLDOWN
		status_message = "Invitation declined or expired. Respect the visitor's decision; another invitation is temporarily unavailable."
		log_game("CCPost visitor retrieval invitation declined or expired for [key_name(person)].")
		SStgui.update_uis(src)
		return
	if(!ccpost_visitor_transport_authorized(operator) || !operator.can_perform_action(src) || selected_visitor?.resolve() != person)
		status_message = "Retrieval authorization expired."
	else
		begin_retrieval(person, operator)
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/begin_retrieval(mob/living/carbon/human/person, mob/living/operator)
	link_retrieval_pad()
	if(charging || !linked_pad || linked_pad.reserved_by || world.time < max(next_transport_allowed, GLOB.ccpost_visitor_retrieval_next_allowed) || !visitor_eligible(person))
		status_message = "Retrieval cancelled: target or telepad is no longer available."
		return
	var/turf/origin = get_turf(person)
	var/turf/destination = get_turf(linked_pad)
	if(!is_safe_turf(destination, dense_atoms = TRUE, no_teleport = TRUE))
		status_message = "Retrieval cancelled: the outpost landing pad is obstructed or unsafe."
		return
	charging = TRUE
	transport_sequence++
	linked_pad.reserved_by = src
	status_message = "Charging retrieval of [person.name] (five seconds)."
	new /obj/effect/temp_visual/teleport_abductor/ccpost_departure(origin)
	playsound(linked_pad, 'sound/machines/terminal/terminal_alert.ogg', vol = 65, vary = TRUE)
	log_game("CCPost visitor retrieval accepted: [key_name(person)], operator [key_name(operator)], source [loc_name(origin)].")
	addtimer(CALLBACK(src, PROC_REF(finish_retrieval), WEAKREF(person), origin, transport_sequence), CCPOST_VISITOR_CHARGE)
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/abort_retrieval(message)
	if(!charging)
		return
	transport_sequence++
	charging = FALSE
	if(linked_pad?.reserved_by == src)
		linked_pad.reserved_by = null
	next_transport_allowed = world.time + CCPOST_VISITOR_COOLDOWN
	status_message = message
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/finish_retrieval(datum/weakref/person_ref, turf/origin, expected_sequence)
	if(!charging || expected_sequence != transport_sequence)
		return
	charging = FALSE
	var/mob/living/carbon/human/person = person_ref?.resolve()
	if(!linked_pad || QDELETED(linked_pad) || linked_pad.reserved_by != src)
		status_message = "Retrieval cancelled: outpost telepad unavailable."
		SStgui.update_uis(src)
		return
	linked_pad.reserved_by = null
	var/turf/arrival = get_turf(linked_pad)
	if(!visitor_eligible(person) || get_turf(person) != origin || !is_safe_turf(arrival, dense_atoms = TRUE, no_teleport = TRUE) || (machine_stat & (BROKEN | NOPOWER)))
		status_message = "Retrieval cancelled: visitor moved, lost camera coverage, or the landing pad is unsafe."
		SStgui.update_uis(src)
		return
	if(!do_teleport(person, arrival, 0, channel = TELEPORT_CHANNEL_BLUESPACE))
		status_message = "Retrieval failed: bluespace interference detected."
		SStgui.update_uis(src)
		return
	// There is no adjacent-tile fallback for incoming outpost retrievals.
	// If the underlying teleport implementation redirects unexpectedly,
	// fail the retrieval and restore the visitor to their safe origin.
	if(get_turf(person) != arrival)
		if(is_safe_turf(origin, dense_atoms = TRUE, no_teleport = TRUE))
			person.forceMove(origin)
		status_message = "Retrieval failed: the receiver pad tile could not be reached precisely."
		SStgui.update_uis(src)
		return
	new /obj/effect/temp_visual/dir_setting/ninja(origin, person.dir)
	new /obj/effect/temp_visual/dir_setting/ninja(arrival, person.dir)
	playsound(origin, SFX_PORTAL_ENTER, 50, TRUE)
	playsound(arrival, SFX_PORTAL_ENTER, 50, TRUE)
	GLOB.ccpost_visitor_retrieval_next_allowed = world.time + CCPOST_RETRIEVAL_SHARED_COOLDOWN
	next_transport_allowed = world.time + CCPOST_RETRIEVAL_SHARED_COOLDOWN
	status_message = "Retrieved [person.name] to the outpost reception pad. Retrieval systems recalibrating for 25 seconds."
	selected_visitor = null
	log_game("CCPost visitor retrieval completed for [key_name(person)] from [loc_name(origin)] to [loc_name(arrival)].")
	visible_message(span_notice("[src] completes its visitor retrieval sequence."))
	SStgui.update_uis(src)

/datum/action/innate/ccpost_select_retrieval_visitor
	name = "Select Visitor"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_up"

/datum/action/innate/ccpost_select_retrieval_visitor/Activate()
	var/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/console = target
	if(!console || !isliving(owner))
		return
	console.select_camera_visitor(owner)

#undef CCPOST_RETRIEVAL_INVITATION_TIMEOUT
#undef CCPOST_RETRIEVAL_DECLINE_COOLDOWN

#undef CCPOST_VISITOR_CHARGE
#undef CCPOST_VISITOR_COOLDOWN


/// CENTRAL COMMAND OUTPOST ASSET DENIAL DEVICE
/// Reuses the station self-destruct terminal sprites and interface.
/// This device is independent of the station's nuclear systems.

GLOBAL_VAR_INIT(ccpost_adp7_authorization_code, null)
/// Central Command loses contact with the Liaison Outpost only after confirmed ADP-7 detonation.
/// Round-local flag also prevents duplicate station announcements if an admin spawns multiple devices.
GLOBAL_VAR_INIT(ccpost_outpost_signal_lost, FALSE)

/proc/ccpost_adp7_get_authorization_code()
	if(!GLOB.ccpost_adp7_authorization_code)
		GLOB.ccpost_adp7_authorization_code = random_nukecode()
	return GLOB.ccpost_adp7_authorization_code


// MAP-PLACEABLE ASSET DENIAL BLAST ORIGINS
// Marker placement is intentionally left to the mapper. Register on creation
// so successful detonation never needs to iterate over every world atom.
GLOBAL_LIST_EMPTY(ccpost_primary_blast_markers)
GLOBAL_LIST_EMPTY(ccpost_secondary_blast_markers)
GLOBAL_VAR_INIT(ccpost_adp7_station_update_sent, FALSE)

/obj/effect/landmark/ccpost_blast_center
	name = "NT-ADP-7 primary blast center (map marker)"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/ccpost_blast_center/Initialize(mapload)
	. = ..()
	GLOB.ccpost_primary_blast_markers |= src

/obj/effect/landmark/ccpost_blast_center/Destroy()
	GLOB.ccpost_primary_blast_markers -= src
	return ..()

/obj/effect/landmark/ccpost_blast_secondary
	name = "NT-ADP-7 secondary blast (map marker)"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/ccpost_blast_secondary/Initialize(mapload)
	. = ..()
	GLOB.ccpost_secondary_blast_markers |= src

/obj/effect/landmark/ccpost_blast_secondary/Destroy()
	GLOB.ccpost_secondary_blast_markers -= src
	return ..()

/// Non-visible, localized radiation source, with two step-downs and cleanup.
/// Native radioactive_emitter handles shielding, radiation scanners and pulses.
/obj/effect/ccpost_fallout_hotspot
	name = "residual nuclear fallout"
	desc = "Invisible residual contamination from the NT-ADP-7 detonation."
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/primary_source = FALSE
	var/fallout_stage = 0

/obj/effect/ccpost_fallout_hotspot/proc/activate(primary = FALSE)
	primary_source = primary
	fallout_stage = 0
	update_fallout()
	addtimer(CALLBACK(src, PROC_REF(decay_fallout)), 5 MINUTES)

/obj/effect/ccpost_fallout_hotspot/proc/update_fallout()
	var/range = primary_source ? 8 : 6
	if(fallout_stage == 1)
		range = primary_source ? 6 : 4
	else if(fallout_stage >= 2)
		range = primary_source ? 4 : 2
	// The existing component updates its arguments via UNIQUE_PASSARGS.
	var/pulse_delay = (primary_source ? (6 + fallout_stage * 3) : (10 + fallout_stage * 4)) * (1 SECONDS)
	AddComponent(/datum/component/radioactive_emitter, pulse_delay, range, RAD_LIGHT_INSULATION, "A radiation counter reports residual nuclear fallout nearby.")

/obj/effect/ccpost_fallout_hotspot/proc/decay_fallout()
	fallout_stage++
	if(fallout_stage >= 3)
		qdel(src)
		return
	update_fallout()
	addtimer(CALLBACK(src, PROC_REF(decay_fallout)), 5 MINUTES)

/// One controller per successful nuke activation. Coordinates are snapshotted
/// before any turf changes, so secondary blasts still work after the primary.
/datum/ccpost_detonation_sequence
	var/list/primary_position
	var/list/secondary_positions = list()
	var/announced = FALSE

/datum/ccpost_detonation_sequence/proc/position_for(turf/location)
	return list("x" = location.x, "y" = location.y, "z" = location.z)

/datum/ccpost_detonation_sequence/proc/turf_for(list/position)
	if(!position)
		return null
	return locate(position["x"], position["y"], position["z"])

/datum/ccpost_detonation_sequence/proc/begin(turf/device_turf)
	if(!device_turf)
		qdel(src)
		return
	var/turf/primary_turf = device_turf
	for(var/obj/effect/landmark/ccpost_blast_center/marker as anything in GLOB.ccpost_primary_blast_markers)
		if(QDELETED(marker))
			continue
		var/turf/candidate = get_turf(marker)
		if(candidate?.z != device_turf.z || get_dist(candidate, device_turf) > 70)
			continue
		primary_turf = candidate
		break
	primary_position = position_for(primary_turf)
	for(var/obj/effect/landmark/ccpost_blast_secondary/marker as anything in GLOB.ccpost_secondary_blast_markers)
		if(length(secondary_positions) >= 4)
			break
		if(QDELETED(marker))
			continue
		var/turf/candidate = get_turf(marker)
		if(candidate?.z != primary_turf.z || get_dist(candidate, primary_turf) > 55)
			continue
		secondary_positions += list(position_for(candidate))
	log_game("NT-ADP-7 blast sequence: primary [primary_turf.x],[primary_turf.y],[primary_turf.z], secondary markers [length(secondary_positions)].")
	// Lock the administrative installation before the blast. The station-wide
	// announcement is intentionally delayed until after the last explosion.
	GLOB.ccpost_outpost_signal_lost = TRUE
	GLOB.ccpost_tasking_network?.note_admin_server_state()
	explosion(primary_turf, devastation_range = 15, heavy_impact_range = 27, light_impact_range = 42, flame_range = 30, flash_range = 46, adminlog = TRUE, ignorecap = TRUE)
	if(length(secondary_positions))
		for(var/index in 1 to length(secondary_positions))
			addtimer(CALLBACK(src, PROC_REF(detonate_secondary), index), index * 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_sequence)), (length(secondary_positions) + 1) * 2 SECONDS)

/datum/ccpost_detonation_sequence/proc/detonate_secondary(index)
	if(index < 1 || index > length(secondary_positions))
		return
	var/turf/location = turf_for(secondary_positions[index])
	if(!location)
		return
	explosion(location, devastation_range = 7, heavy_impact_range = 13, light_impact_range = 20, flame_range = 15, flash_range = 24, adminlog = TRUE, ignorecap = TRUE)

/datum/ccpost_detonation_sequence/proc/complete_sequence()
	var/turf/primary_turf = turf_for(primary_position)
	if(primary_turf)
		var/obj/effect/ccpost_fallout_hotspot/primary_hotspot = new(primary_turf)
		primary_hotspot.activate(TRUE)
	for(var/list/position as anything in secondary_positions)
		var/turf/location = turf_for(position)
		if(!location)
			continue
		var/obj/effect/ccpost_fallout_hotspot/secondary_hotspot = new(location)
		secondary_hotspot.activate(FALSE)
	if(!announced && !GLOB.ccpost_adp7_station_update_sent)
		announced = TRUE
		GLOB.ccpost_adp7_station_update_sent = TRUE
		priority_announce(
			"Central Command has lost all communications and telemetry from the Central Command Liaison Outpost following a major energy event. The installation is now considered OFFLINE. Further information will be provided once the situation has been verified.",
			"Liaison Outpost Communications Lost",
			sender_override = "Central Command Update",
			has_important_message = TRUE,
			color_override = "blue"
		)
		log_game("NT-ADP-7: Primary and [length(secondary_positions)] secondary blasts completed. Outpost offline; station notification sent.")
	qdel(src)

// NT-ADP-7 AUTHENTICATION DISK AND TRACKING SYSTEM


// Dedicated registry for ADP-7 authentication disks.
// Separate from the station's nuclear disk tracking.
GLOBAL_LIST_EMPTY(ccpost_adp7_disks)


// NT-ADP-7 AUTHENTICATION DISK

/obj/item/disk/nuclear/ccpost_nuke
	name = "NT-ADP-7 authentication disk"
	desc = "A classified Central Command authentication disk intended exclusively for the NT-ADP-7 Asset Denial Device."
	icon_state = "nucleardisk"

	// Prevent normal nuclear disk operative-related behavior.
	fake = TRUE


/obj/item/disk/nuclear/ccpost_nuke/Initialize(mapload)
	// Preserve the mapped location before parent initialization.
	var/atom/original_location = loc

	. = ..()

	// Nuclear disks receive stationloving even with fake = TRUE.
	// Remove it so this disk can exist on the outpost z-level.
	var/datum/component/stationloving/location_restriction = GetComponent(/datum/component/stationloving)

	if(location_restriction)
		qdel(location_restriction)

	// Restore its original location if parent initialization
	// relocated the disk to the station.
	if(original_location && loc != original_location)
		forceMove(original_location)

	// Register the disk exclusively with ADP-7 trackers.
	GLOB.ccpost_adp7_disks += src


/obj/item/disk/nuclear/ccpost_nuke/Destroy()
	// Prevent trackers from retaining deleted disk references.
	GLOB.ccpost_adp7_disks -= src

	return ..()

/obj/item/pinpointer/ccpost_adp7
	name = "NT-ADP-7 authentication pinpointer"
	desc = "A classified NanoTrasen tracking device calibrated exclusively to NT-ADP-7 authentication disks."
	icon_state = "pinpointer"
	worn_icon_state = "pinpointer"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	// Continuously updates its target while activated.
	process_scan = TRUE


/obj/item/pinpointer/ccpost_adp7/scan_for_target()
	target = null

	var/turf/scanner_turf = get_turf(src)
	if(!scanner_turf)
		return

	var/closest_distance = INFINITY

	// Only search the dedicated ADP-7 disk registry.
	// Never consult the station's nuclear disk registry.
	for(var/obj/item/disk/nuclear/ccpost_nuke/disk as anything in GLOB.ccpost_adp7_disks)
		if(QDELETED(disk))
			continue

		var/turf/disk_turf = get_turf(disk)
		if(!disk_turf)
			continue

		// Native pinpointers track within the same z-level.
		if(scanner_turf.z != disk_turf.z)
			continue

		var/distance = get_dist(scanner_turf, disk_turf)

		if(distance < closest_distance)
			closest_distance = distance
			target = disk


/obj/item/pinpointer/ccpost_adp7/examine(mob/user)
	. = ..()

	. += span_notice("Tracking frequency: NT-ADP-7 classified authentication signal.")

	if(!active)
		. += span_notice("The tracker is currently inactive.")
	else if(target)
		. += span_notice("An NT-ADP-7 authentication signal has been acquired.")
	else
		. += span_warning("No NT-ADP-7 authentication signal detected on this level.")

/obj/item/pinpointer/ccpost_adp7/syndicate
	name = "Syndicate asset-denial pinpointer"
	desc = "A modified Syndicate tracking device calibrated to intercept the authentication signature of NanoTrasen's NT-ADP-7 Asset Denial Device."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"

/obj/item/pinpointer/ccpost_adp7/syndicate/examine(mob/user)
	. = ..()
	. += span_warning("Its tracking hardware bears unauthorized Syndicate modifications.")

// Classified authorization paper.
// Place this separately from the authentication disk.

/obj/item/paper/fluff/ruins/ccpost/adp7_authorization
	name = "NT-ADP-7 authorization directive"
	desc = "A classified NanoTrasen document containing asset-denial authorization procedures."

/obj/item/paper/fluff/ruins/ccpost/adp7_authorization/Initialize(mapload)
	default_raw_text = {"<center><b>NANOTRASEN CENTRAL COMMAND</b><br><b>CLASSIFIED: ASSET DENIAL CONTINGENCY</b></center><hr>
	<br><b>Device:</b> NT-ADP-7 Asset Denial Device
	<br><b>Installation:</b> Central Command Liaison Outpost
	<br><b>Authorization Code:</b> [ccpost_adp7_get_authorization_code()]
	<br><br>Both the authentication disk and authorization code are required before activation.
	<br><br><b>WARNING:</b> Activation initiates destruction of the installation.
	<br><br><i>Corporate confidentiality takes precedence over corporate property.</i>"}
	return ..()


// Asset Denial Terminal.
// This is deliberately NOT a /selfdestruct subtype.
// Station nuclear code requests therefore cannot overwrite
// its separate authorization code.

/obj/machinery/nuclearbomb/ccpost_nuke
	name = "NT-ADP-7 Asset Denial Device"
	desc = "A classified NanoTrasen contingency device designed to prevent sensitive corporate intelligence from falling into unauthorized hands. Do not taunt."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	anchored = TRUE
	timer_set = 180
	minimum_timer_set = 90
	maximum_timer_set = 600
	/// Dedicated NT-ADP-7 CentCom transmitter; never interacts with station nuclear alerts.
	var/obj/item/radio/ccpost_warning_radio
	/// Prevent duplicate transmissions from repeated arming calls.
	var/ccpost_arm_announcement_sent = FALSE

/obj/machinery/nuclearbomb/ccpost_nuke/Initialize(mapload)
	. = ..()
	r_code = ccpost_adp7_get_authorization_code()
	ccpost_warning_radio = new(src)
	ccpost_warning_radio.set_frequency(FREQ_CENTCOM)
	ccpost_warning_radio.independent = TRUE
	ccpost_warning_radio.ignores_radio_jammers = TRUE
	ccpost_warning_radio.canhear_range = 0
	ccpost_warning_radio.set_listening(FALSE)
	ccpost_warning_radio.command = TRUE
	ccpost_warning_radio.use_command = TRUE


// Only the dedicated ADP-7 disk is accepted.

/obj/machinery/nuclearbomb/ccpost_nuke/disk_check(obj/item/disk/nuclear/inserted_disk)
	if(!istype(inserted_disk, /obj/item/disk/nuclear/ccpost_nuke))
		say("Authentication failure: NT-ADP-7 disk required.")
		return FALSE

	auth = inserted_disk
	return TRUE


// The device cannot be moved.

/obj/machinery/nuclearbomb/ccpost_nuke/set_anchor(mob/anchorer)
	return


// Use the original keypad, countdown, and safety controls.
// Do not trigger the station's nuclear alert or round-end systems.

/obj/machinery/nuclearbomb/ccpost_nuke/arm_nuke(mob/armer)
	if(!istype(auth, /obj/item/disk/nuclear/ccpost_nuke) || !yes_code || safety || !timing)
		timing = FALSE
		return

	// Independent Gorlex contract tracking; the main station's nuclear state is untouched.
	var/obj/effect/landmark/ccpost_gorlex_director/gorlex_director = GLOB.ccpost_gorlex_director
	if(gorlex_director)
		gorlex_director.note_arming(armer)
	detonation_timer = world.time + (timer_set * 10)
	countdown.start()
	update_appearance()

	var/turf/device_turf = get_turf(src)

	message_admins("[src] armed by [armer ? ADMIN_LOOKUPFLW(armer) : "unknown"] at [ADMIN_VERBOSEJMP(device_turf)].")
	log_game("NT-ADP-7 armed by [armer ? key_name(armer) : "unknown"] at [loc_name(device_turf)].")

	visible_message(span_bolddanger("[src] begins its asset-denial countdown!"))

	playsound(src, 'sound/announcer/alarm/nuke_alarm.ogg', 65, FALSE)

	// High-volume radio warning on CentCom frequency. Other departments do not receive it.
	// We use the same wording as the existing local warning for consistency.
	if(!ccpost_arm_announcement_sent && ccpost_warning_radio)
		ccpost_arm_announcement_sent = TRUE
		ccpost_warning_radio.talk_into(src, "CENTRAL COMMAND ALERT: NT-ADP-7 ASSET DENIAL ACTIVE. EVACUATE THE OUTPOST. DETONATION IN [timer_set] SECONDS.", RADIO_CHANNEL_CENTCOM)

	for(var/mob/living/person as anything in GLOB.mob_living_list)
		var/turf/person_turf = get_turf(person)
		if(person_turf && istype(get_area(person_turf), /area/ruin/space/has_grav/ccpost))
			to_chat(person, span_boldannounce("CENTRAL COMMAND ALERT: NT-ADP-7 ASSET DENIAL ACTIVE. EVACUATE THE OUTPOST. DETONATION IN [timer_set] SECONDS."))


// Disarming remains possible through the normal interface.

/obj/machinery/nuclearbomb/ccpost_nuke/disarm_nuke(mob/disarmer, change_level_back = TRUE)
	var/obj/effect/landmark/ccpost_gorlex_director/gorlex_director = GLOB.ccpost_gorlex_director
	if(gorlex_director)
		gorlex_director.armed_by_gorlex = FALSE
	ccpost_arm_announcement_sent = FALSE
	detonation_timer = null
	countdown.stop()
	update_appearance()

	if(disarmer)
		message_admins("[src] disarmed by [ADMIN_LOOKUPFLW(disarmer)].")
		log_game("NT-ADP-7 disarmed by [key_name(disarmer)].")

	visible_message(span_notice("[src] aborts its asset-denial countdown."))


// Local explosion only.
// Prevent station nuclear cinematics, round-ending effects,
// and modifications to global station nuclear state.

/obj/machinery/nuclearbomb/ccpost_nuke/explode()
	if(exploded || !timing || safety)
		return FALSE

	if(!core)
		timing = FALSE
		safety = TRUE
		yes_code = FALSE
		detonation_timer = null
		countdown.stop()
		update_ui_mode()
		update_appearance()
		visible_message(span_warning("[src] aborts detonation: the fissile core is missing."))
		return FALSE

	exploding = TRUE
	exploded = TRUE
	timing = FALSE
	safety = TRUE
	yes_code = FALSE
	detonation_timer = null

	countdown.stop()
	update_appearance()

	var/turf/device_turf = get_turf(src)
	if(!device_turf)
		qdel(src)
		return TRUE

	message_admins("[src] DETONATED at [ADMIN_VERBOSEJMP(device_turf)]. Local outpost blast only.")
	log_game("NT-ADP-7 detonated at [loc_name(device_turf)].")

	var/obj/effect/landmark/ccpost_gorlex_director/gorlex_director = GLOB.ccpost_gorlex_director
	if(gorlex_director)
		gorlex_director.note_detonation()
	var/datum/ccpost_detonation_sequence/sequence = new
	sequence.begin(device_turf)
	// The controller owns secondary blasts, fallout and the delayed station notice.
	qdel(src)
	return TRUE
