/*
 * Central Command Liaison Outpost - Operation Severance
 * All Gorlex event, antagonist, armament and field-requisition code is here.
 * Does not inherit normal nuclear-operative teams, uplinks or station victory.
 * Map owner places the director, insertion, disk return and retrieval/deployment landmarks.
 */

#define CCPOST_GORLEX_TC 5
#define CCPOST_CYBERSUN_TC 12
#define CCPOST_GORLEX_NEGLECT_WINDOW (5 MINUTES)
#define CCPOST_GORLEX_NEGLECT_ESCALATION (20 MINUTES)
#define CCPOST_GORLEX_NEGLECT_MAX (35 MINUTES)
#define CCPOST_GORLEX_FIRST_GUARDED_CHECK (20 MINUTES)
#define CCPOST_GORLEX_ROLL_COOLDOWN (15 MINUTES)
#define CCPOST_GORLEX_MAX_GUARDED_ROLLS 3
#define CCPOST_GORLEX_RECRUITMENT_RETRY_DELAY (5 MINUTES)
#define CCPOST_GORLEX_PREPARATION_TIME (2 MINUTES)
#define CCPOST_GORLEX_MAX_RECRUITMENT_ATTEMPTS 3
#define CCPOST_GORLEX_PLASTIC_LIMIT 4
#define CCPOST_CYBERSUN_RETRY_DELAY (5 MINUTES)
#define CCPOST_GORLEX_SECURITY_POLL (5 SECONDS)
#define CCPOST_GORLEX_PROTOTYPE_NEGLECT (5 MINUTES)
#define CCPOST_GORLEX_PROTOTYPE_ESCALATION (15 MINUTES)

GLOBAL_VAR_INIT(ccpost_gorlex_director, null)
GLOBAL_LIST_EMPTY(ccpost_gorlex_disk_returns)
GLOBAL_LIST_EMPTY(ccpost_gorlex_insertions)
GLOBAL_LIST_EMPTY(ccpost_gorlex_extraction_landmarks)
GLOBAL_LIST_EMPTY(ccpost_cybersun_insertions)
GLOBAL_LIST_EMPTY(ccpost_severance_prototypes)

#define CCPOST_GORLEX_EXTRACTION_TIME (80 SECONDS)
#define CCPOST_GORLEX_WARRANT_GRACE (15 SECONDS)
#define CCPOST_CYBERSUN_RECALL_TIME (15 SECONDS)
#define CCPOST_GORLEX_FAILSAFE_TIME (20 MINUTES)
#define CCPOST_CYBERSUN_MISSION_TIME (15 MINUTES)
#define CCPOST_CYBERSUN_FORCED_RECALL_TIME (3 SECONDS)
#define CCPOST_GORLEX_OPERATION_RADIUS 60

// -------------------------------------------------------------------------
// MAP LANDMARKS AND NEGLECT-TRIGGERED EVENT DIRECTOR
// -------------------------------------------------------------------------

/obj/effect/landmark/ccpost_gorlex_insertion
	name = "Gorlex Marauders insertion point"

/obj/effect/landmark/ccpost_gorlex_insertion/Initialize(mapload)
	. = ..()
	GLOB.ccpost_gorlex_insertions += src

/obj/effect/landmark/ccpost_gorlex_insertion/Destroy()
	GLOB.ccpost_gorlex_insertions -= src
	return ..()

/obj/effect/landmark/ccpost_gorlex_disk_return
	name = "NT-ADP-7 disk emergency relocation"

/obj/effect/landmark/ccpost_gorlex_disk_return/Initialize(mapload)
	. = ..()
	GLOB.ccpost_gorlex_disk_returns += src

/obj/effect/landmark/ccpost_gorlex_disk_return/Destroy()
	GLOB.ccpost_gorlex_disk_returns -= src
	return ..()

/// Map one controller per Liaison Outpost. Keeps the event independent of station random events.
/obj/effect/landmark/ccpost_gorlex_director
	name = "Operation Severance event director"
	var/unsecured_since = 0
	var/last_security_scan = 0
	/// Accumulated time with eligible staffing; pauses when prerequisites are lost.
	var/eligible_staffing_time = 0
	var/last_eligible_scan = 0
	/// Guarded checks use eligible time, not round age.
	var/next_guarded_check = CCPOST_GORLEX_FIRST_GUARDED_CHECK
	var/guarded_rolls = 0
	/// Hidden rolling administration history, bounded by the 20-minute lookback.
	var/list/admin_activity = list()
	var/admin_pending_since = 0
	/// The original experimental asset, independent of the eventual contract selection.
	var/datum/weakref/prototype_risk_ref
	var/prototype_unsecured_since = 0
	/// All automatic rolls share this real-time cooldown, including across custody changes.
	var/next_deployment_roll = 0
	/// A successful automatic roll permanently consumes further automatic deployment rolls.
	var/automatic_deployment_authorized = FALSE
	var/automatic_recruitment_attempts = 0
	var/next_recruitment_retry = 0
	var/event_started = FALSE
	/// Includes the pre-recruitment preparation window, preventing overlapping requests.
	var/polling_ghosts = FALSE
	/// Set once per director; retries never repeat the advisory.
	var/security_advisory_issued = FALSE
	/// Dedicated CentCom transmitter for the pre-deployment security advisory.
	var/obj/item/radio/security_advisory_radio
	var/armed_by_gorlex = FALSE
	/// Classified records were fully copied from the Central Command Tasking Server.
	var/data_downloaded = FALSE
	/// The contract is selected once, immediately before deployment.
	var/contract_kind
	var/contract_asset_name = "classified intelligence cartridge"
	var/datum/weakref/contract_prototype_ref
	var/asset_acquired = FALSE
	var/turf/last_valid_prototype_turf
	var/prototype_original_resistance
	var/last_boundary_reminder = 0
	/// The physical copy must still reach the Gorlex retrieval pod.
	var/datum/weakref/data_cartridge_ref
	/// Nuclear authorization is recorded separately from a later disarm.
	var/nuke_ever_armed = FALSE
	var/nuke_detonated = FALSE
	/// Set only on authorized boarding with the original completed cartridge.
	var/gorlex_victory = FALSE
	var/datum/weakref/operative_ref
	/// Last safe off-station location of the one contract cartridge.
	var/turf/last_valid_cartridge_turf
	var/last_cartridge_scan = 0
	var/black_warrant = FALSE
	var/warrant_deadline = 0
	/// A sequence ID invalidates pending callbacks when a warning is cleared or restarted.
	var/warrant_warning_generation = 0
	var/warrant_warning_channel = 0
	var/client/warrant_warning_listener
	var/warrant_target_name
	var/warrant_target_dead = FALSE
	var/warrant_poll_started = FALSE
	var/enforcer_retry_scheduled = FALSE
	var/datum/mind/enforcer_mind
	var/enforcer_recalled = FALSE
	var/implant_deadline = 0
	var/implant_detonated = FALSE
	var/failsafe_beeps_started = FALSE
	var/enforcer_mission_deadline = 0
	var/enforcer_forced_pending = FALSE
	var/enforcer_forced_withdrawal = FALSE
	var/enforcer_termination_at_withdrawal = FALSE
	var/enforcer_recovery_at_expiry = FALSE
	var/last_implant_remaining = CCPOST_GORLEX_FAILSAFE_TIME + 1
	var/last_enforcer_remaining = CCPOST_CYBERSUN_MISSION_TIME + 1
	var/datum/weakref/manual_charge_ref
	var/datum/weakref/forced_charge_ref
	var/enforcer_poll_active = FALSE
	/// Objective cues are server-owned and play only once per completed milestone.
	var/enforcer_termination_cue_sent = FALSE
	var/datum/weakref/gorlex_withdrawn_ghost_ref
	var/datum/weakref/extraction_marker_ref
	var/extraction_departing = FALSE
	var/cybersun_recovered = FALSE
	var/extraction_deadline = 0
	var/turf/extraction_turf
	var/datum/weakref/extraction_pod_ref
	var/extraction_status = "NOT REQUESTED"
	var/datum/weakref/operative_mind_ref
	/// Editable in StrongDMM if the mapped operational sector needs a different radius.
	var/operational_radius = CCPOST_GORLEX_OPERATION_RADIUS

/obj/effect/landmark/ccpost_gorlex_director/Initialize(mapload)
	. = ..()
	var/obj/effect/landmark/ccpost_gorlex_director/existing_director = GLOB.ccpost_gorlex_director
	if(existing_director && !QDELETED(existing_director))
		log_game("CCPost Gorlex: duplicate event director ignored at [AREACOORD(src)].")
		return
	GLOB.ccpost_gorlex_director = src
	START_PROCESSING(SSobj, src)

/obj/effect/landmark/ccpost_gorlex_director/Destroy()
	var/obj/item/prototype = contract_prototype_ref?.resolve()
	if(prototype && !QDELETED(prototype))
		prototype.resistance_flags = prototype_original_resistance
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(security_advisory_radio)
	clear_warrant_warning()
	var/obj/effect/ccpost_recall_charge/manual_charge = manual_charge_ref?.resolve()
	var/obj/effect/ccpost_recall_charge/forced_charge = forced_charge_ref?.resolve()
	if(manual_charge)
		qdel(manual_charge)
	if(forced_charge)
		qdel(forced_charge)
	clear_landing_marker()
	var/obj/structure/ccpost_gorlex_retrieval_pod/pod = extraction_pod_ref?.resolve()
	if(pod)
		qdel(pod)
	if(GLOB.ccpost_gorlex_director == src)
		GLOB.ccpost_gorlex_director = null
	return ..()

/obj/effect/landmark/ccpost_gorlex_director/proc/get_disk()
	for(var/obj/item/disk/nuclear/ccpost_nuke/disk as anything in GLOB.ccpost_adp7_disks)
		if(!QDELETED(disk))
			return disk
	return null

/obj/effect/landmark/ccpost_gorlex_director/proc/get_return_turf()
	var/list/possible = list()
	for(var/obj/effect/landmark/ccpost_gorlex_disk_return/marker as anything in GLOB.ccpost_gorlex_disk_returns)
		if(QDELETED(marker))
			continue
		var/turf/T = get_turf(marker)
		if(T && istype(get_area(T), /area/ruin/space/has_grav/ccpost) && is_safe_turf(T, no_teleport = TRUE))
			possible += T
	if(length(possible))
		return pick(possible)
	return null

/obj/effect/landmark/ccpost_gorlex_director/proc/return_disk_if_offsite(obj/item/disk/nuclear/ccpost_nuke/disk)
	if(!disk || QDELETED(disk))
		return FALSE
	var/turf/T = get_turf(disk)
	if(!T || istype(get_area(T), /area/ruin/space/has_grav/ccpost))
		return FALSE
	var/turf/return_turf = get_return_turf()
	if(!return_turf)
		return FALSE
	disk.forceMove(return_turf)
	log_game("CCPost Gorlex: NT-ADP-7 disk restored to outpost at [AREACOORD(return_turf)].")
	return TRUE

/// Any living, connected, mind-owning registered employee on the outpost can count.
/obj/effect/landmark/ccpost_gorlex_director/proc/active_outpost_personnel()
	var/count = 0
	for(var/mob/living/carbon/human/person as anything in GLOB.mob_living_list)
		if(!ishuman(person) || QDELETED(person) || person.stat == DEAD || !person.client || !person.mind)
			continue
		if(!istype(get_area(person), /area/ruin/space/has_grav/ccpost))
			continue
		if(!ccpost_is_outpost_personnel(person))
			continue
		count++
	return count

/// A connected living human physically carrying the disk secures it, even while stationary.
/// Inventory containers count; unattended lockers, dragging and standing nearby do not.
/obj/effect/landmark/ccpost_gorlex_director/proc/disk_is_actively_guarded(obj/item/disk/nuclear/ccpost_nuke/disk)
	var/atom/current_container = disk?.loc
	while(ismovable(current_container))
		if(ishuman(current_container))
			var/mob/living/carbon/human/carrier = current_container
			return !!(carrier.client && carrier.stat != DEAD)
		current_container = current_container.loc
	return FALSE

/// Reset continuous neglect without resetting staffing progress or the roll cooldown.
/obj/effect/landmark/ccpost_gorlex_director/proc/reset_neglect()
	unsecured_since = 0

/// Custody is assessed from the original item's containment chain, not nearby players.
/obj/effect/landmark/ccpost_gorlex_director/proc/prototype_is_secured(obj/item/prototype)
	var/turf/location = get_turf(prototype)
	var/turf/origin = get_turf(src)
	if(!location || !origin || location.z != origin.z)
		return FALSE
	var/atom/current_container = prototype.loc
	while(ismovable(current_container))
		if(istype(current_container, /obj/structure/closet/secure_closet/ccpost_armory))
			var/obj/structure/closet/secure_closet/ccpost_armory/armory = current_container
			if(armory.locked && !armory.opened && istype(get_area(armory), /area/ruin/space/has_grav/ccpost))
				return TRUE
		if(ishuman(current_container))
			var/mob/living/carbon/human/carrier = current_container
			if(!carrier.client || carrier.stat == DEAD)
				return FALSE
			var/datum/ccpost_hr_employee/employee = GLOB.ccpost_hr_service?.employee_for(carrier, FALSE)
			return employee && (employee.employee_role == "Central Command Liaison" || employee.employee_role == "Outpost Security Officer")
		current_container = current_container.loc
	return FALSE

/// Track one original armory-issued asset. Missing/destroyed assets give no bonus.
/// A temporary drop is harmless; secure custody resets continuous neglect.
/obj/effect/landmark/ccpost_gorlex_director/proc/update_prototype_risk()
	var/obj/item/prototype = prototype_risk_ref?.resolve()
	if(!prototype || QDELETED(prototype) || !(prototype_risk_ref in GLOB.ccpost_severance_prototypes))
		prototype_risk_ref = null
		prototype_unsecured_since = 0
		prototype = null
		for(var/datum/weakref/reference as anything in GLOB.ccpost_severance_prototypes)
			var/obj/item/candidate = reference.resolve()
			if(candidate && !QDELETED(candidate))
				prototype = candidate
				prototype_risk_ref = reference
				break
	if(!prototype || !get_turf(prototype) || prototype_is_secured(prototype))
		prototype_unsecured_since = 0
		return
	if(!prototype_unsecured_since)
		prototype_unsecured_since = world.time

/obj/effect/landmark/ccpost_gorlex_director/proc/prototype_risk_modifier()
	if(!prototype_unsecured_since)
		return 0
	var/neglect_duration = world.time - prototype_unsecured_since
	if(neglect_duration >= CCPOST_GORLEX_PROTOTYPE_ESCALATION)
		return 10
	if(neglect_duration >= CCPOST_GORLEX_PROTOTYPE_NEGLECT)
		return 5
	return 0

/// Only original armory-spawned, still-present prototypes may enter a contract.
/obj/effect/landmark/ccpost_gorlex_director/proc/eligible_prototypes()
	var/list/eligible = list()
	for(var/datum/weakref/reference as anything in GLOB.ccpost_severance_prototypes.Copy())
		var/obj/item/prototype = reference.resolve()
		if(!prototype || QDELETED(prototype))
			GLOB.ccpost_severance_prototypes -= reference
			continue
		var/turf/location = get_turf(prototype)
		if(location && istype(get_area(location), /area/ruin/space/has_grav/ccpost))
			eligible += prototype
	return eligible

/obj/effect/landmark/ccpost_gorlex_director/proc/data_contract_available()
	var/obj/machinery/ccpost_tasking_server/server = GLOB.ccpost_tasking_network?.server
	return server && !QDELETED(server) && server.operational() && istype(get_area(server), /area/ruin/space/has_grav/ccpost)

/obj/effect/landmark/ccpost_gorlex_director/proc/contract_available()
	return data_contract_available() || length(eligible_prototypes())

/obj/effect/landmark/ccpost_gorlex_director/proc/select_contract()
	var/list/choices = list()
	var/list/prototypes = eligible_prototypes()
	if(data_contract_available())
		choices += "data"
	if(length(prototypes))
		choices += "prototype"
	if(!length(choices))
		return FALSE
	contract_kind = pick(choices)
	if(contract_kind == "prototype")
		var/obj/item/prototype = pick(prototypes)
		contract_prototype_ref = WEAKREF(prototype)
		contract_asset_name = prototype.name
		last_valid_prototype_turf = get_turf(prototype)
		// Only the assigned original is protected during this contract, as with the cartridge.
		prototype_original_resistance = prototype.resistance_flags
		prototype.resistance_flags |= INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	else
		contract_asset_name = "classified intelligence cartridge"
	log_game("CCPost Gorlex: selected contract [contract_kind], asset [contract_asset_name].")
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/contract_asset()
	if(contract_kind == "prototype")
		return contract_prototype_ref?.resolve()
	return data_cartridge_ref?.resolve()

/obj/effect/landmark/ccpost_gorlex_director/proc/primary_target()
	if(contract_kind == "data" && !data_downloaded)
		return GLOB.ccpost_tasking_network?.server
	return contract_asset()

/obj/effect/landmark/ccpost_gorlex_director/proc/primary_instruction()
	if(contract_kind == "prototype")
		return "Recover the original experimental prototype [contract_asset_name] from the Liaison Outpost."
	return "Download classified Central Command Tasking Server records to the physical encrypted data cartridge."

/obj/effect/landmark/ccpost_gorlex_director/proc/get_contract_nuke()
	var/turf/origin = get_turf(src)
	if(!origin)
		return null
	for(var/obj/machinery/nuclearbomb/ccpost_nuke/device as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb/ccpost_nuke))
		if(QDELETED(device))
			continue
		var/turf/device_turf = get_turf(device)
		if(device_turf && device_turf.z == origin.z)
			return device
	return null

/// Shared predicate for automatic deployment rolls and recruitment revalidation.
/obj/effect/landmark/ccpost_gorlex_director/proc/deployment_eligible(obj/item/disk/nuclear/ccpost_nuke/disk)
	if(GLOB.ccpost_outpost_signal_lost || active_outpost_personnel() < 2 || !disk || QDELETED(disk))
		return FALSE
	var/turf/current_location = get_turf(disk)
	return current_location && istype(get_area(current_location), /area/ruin/space/has_grav/ccpost)

/obj/effect/landmark/ccpost_gorlex_director/process(seconds_per_tick)
	// Keep the stolen cartridge off the main station even after deployment.
	if(world.time >= last_cartridge_scan + CCPOST_GORLEX_SECURITY_POLL)
		last_cartridge_scan = world.time
		var/obj/item/ccpost_classified_cartridge/contract_cartridge = data_cartridge_ref?.resolve()
		if(contract_cartridge)
			secure_cartridge(contract_cartridge)
		if(contract_kind == "prototype")
			secure_prototype()
	if(event_started)
		process_contract()
		if(!GLOB.ccpost_outpost_signal_lost && world.time >= last_security_scan + CCPOST_GORLEX_SECURITY_POLL)
			last_security_scan = world.time
			return_disk_if_offsite(get_disk())
		return
	if(world.time < last_security_scan + CCPOST_GORLEX_SECURITY_POLL)
		return
	last_security_scan = world.time
	var/obj/item/disk/nuclear/ccpost_nuke/disk = get_disk()
	if(!GLOB.ccpost_outpost_signal_lost)
		return_disk_if_offsite(disk)
	if(!SSticker.IsRoundInProgress())
		return
	var/eligible = deployment_eligible(disk)
	if(automatic_deployment_authorized)
		if(!next_recruitment_retry || polling_ghosts || world.time < next_recruitment_retry)
			return
		next_recruitment_retry = 0
		if(!eligible || !pick_landing(GLOB.ccpost_gorlex_insertions, TRUE))
			cancel_automatic_recruitment("deployment prerequisites no longer met")
			return
		if(!start_gorlex_poll())
			cancel_automatic_recruitment("retry could not start")
		return
	process_deployment_checks(disk, eligible)

/// A validated completion is recorded once. No UI data or player-facing risk score.
/obj/effect/landmark/ccpost_gorlex_director/proc/record_admin_activity(reference, weight = 1)
	if(!reference || admin_activity[reference])
		return
	admin_activity[reference] = list("at" = world.time, "weight" = clamp(weight, 1, 2))

/obj/effect/landmark/ccpost_gorlex_director/proc/admin_activity_modifier()
	var/score = 0
	for(var/reference in admin_activity.Copy())
		var/list/entry = admin_activity[reference]
		if(world.time - entry["at"] >= 20 MINUTES)
			admin_activity -= reference
		else
			score += entry["weight"]
	if(score >= 3)
		return -5
	if(score > 0)
		return 0
	if(admin_pending_since && world.time - admin_pending_since >= 10 MINUTES)
		return 5
	return 0

/proc/ccpost_record_admin_activity(reference, weight = 1)
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director && !QDELETED(director))
		director.record_admin_activity(reference, weight)

/// Rolling, outpost-relative security checks. No catch-up bursts or round-age cutoffs.
/obj/effect/landmark/ccpost_gorlex_director/proc/process_deployment_checks(obj/item/disk/nuclear/ccpost_nuke/disk, eligible)
	if(!eligible)
		last_eligible_scan = 0
		admin_pending_since = 0
		prototype_unsecured_since = 0
		reset_neglect()
		return

	// Accumulate eligible staffing time, but never count the gap before staffing resumes.
	if(last_eligible_scan)
		eligible_staffing_time += world.time - last_eligible_scan
	last_eligible_scan = world.time

	// Only prolonged available work can count as neglect. A quiet, empty inbox is neutral.
	var/pending_work = ccpost_has_pending_admin_work()
	if(pending_work && !admin_pending_since)
		admin_pending_since = world.time
	else if(!pending_work)
		admin_pending_since = 0

	var/guarded = disk_is_actively_guarded(disk)
	if(guarded)
		reset_neglect()
	else if(!unsecured_since)
		unsecured_since = world.time

	// Sample on every eligible security scan, including grace period and cooldown.
	update_prototype_risk()

	// Custody changes, staffing changes and admin polls cannot reset the shared cooldown.
	if(!SSticker.round_start_time || world.time < SSticker.round_start_time + 20 MINUTES || polling_ghosts || world.time < next_deployment_roll)
		return
	var/chance = 0
	var/neglect_duration = unsecured_since ? world.time - unsecured_since : 0
	if(!guarded)
		// Even a fully staffed outpost must have five continuous minutes of neglect.
		if(neglect_duration < CCPOST_GORLEX_NEGLECT_WINDOW)
			return
		if(neglect_duration >= CCPOST_GORLEX_NEGLECT_MAX)
			chance = 40
		else if(neglect_duration >= CCPOST_GORLEX_NEGLECT_ESCALATION)
			chance = 30
		else
			chance = 20
	else
		if(guarded_rolls >= CCPOST_GORLEX_MAX_GUARDED_ROLLS || eligible_staffing_time < next_guarded_check)
			return
		chance = 5

	var/staff_count = active_outpost_personnel()
	var/staff_modifier = staff_count >= 4 ? 5 : (staff_count == 3 ? 3 : 0)
	var/activity_modifier = admin_activity_modifier()
	var/prototype_modifier = prototype_risk_modifier()
	chance = clamp(chance + staff_modifier + activity_modifier + prototype_modifier, 2, 60)
	// An unavailable insertion does not consume a roll or start its cooldown.
	if(!pick_landing(GLOB.ccpost_gorlex_insertions, TRUE) || !contract_available())
		return
	if(guarded)
		guarded_rolls++
		next_guarded_check = eligible_staffing_time + CCPOST_GORLEX_ROLL_COOLDOWN
	next_deployment_roll = world.time + CCPOST_GORLEX_ROLL_COOLDOWN
	var/successful_roll = prob(chance)
	log_game("CCPost Gorlex: rolling deployment check, guarded=[guarded], neglect_seconds=[round(neglect_duration / (1 SECONDS))], eligible_seconds=[round(eligible_staffing_time / (1 SECONDS))], guarded_rolls=[guarded_rolls]/[CCPOST_GORLEX_MAX_GUARDED_ROLLS], staff_modifier=[staff_modifier], activity_modifier=[activity_modifier], prototype_modifier=[prototype_modifier], chance=[chance]%, success=[successful_roll].")
	if(successful_roll)
		automatic_deployment_authorized = TRUE
		// Authorization owns all subsequent recruitment; securing the disk cannot undo it.
		if(!start_gorlex_poll())
			cancel_automatic_recruitment("initial poll could not start")

/// End automatic recruitment without reopening consumed deployment opportunities.
/obj/effect/landmark/ccpost_gorlex_director/proc/cancel_automatic_recruitment(reason)
	next_recruitment_retry = 0
	log_game("CCPost Gorlex: automatic recruitment closed ([reason]); attempts=[automatic_recruitment_attempts].")

/// Only failed automatic polls receive retries. Admin polls remain single attempts.
/obj/effect/landmark/ccpost_gorlex_director/proc/handle_failed_gorlex_recruitment(admin_forced, reason)
	if(admin_forced || !automatic_deployment_authorized || event_started)
		return
	if(automatic_recruitment_attempts >= CCPOST_GORLEX_MAX_RECRUITMENT_ATTEMPTS)
		cancel_automatic_recruitment("recruitment attempts exhausted: [reason]")
		return
	next_recruitment_retry = world.time + CCPOST_GORLEX_RECRUITMENT_RETRY_DELAY
	log_game("CCPost Gorlex: recruitment attempt [automatic_recruitment_attempts] failed ([reason]); retry in five minutes.")

/// Use existing faction artwork rather than weapon silhouettes for both ghost-poll surfaces.
/proc/ccpost_poll_faction_icon(cybersun = FALSE)
	var/icon/insignia
	if(cybersun)
		insignia = icon('icons/obj/clothing/modsuit/mod_clothing.dmi', "cybersun-helmet-sealed", SOUTH)
		insignia.Scale(32, 32)
	else
		insignia = icon('icons/effects/96x96.dmi', "traitor_rune_outline", SOUTH)
		insignia.Scale(32, 32)
	return insignia

/// Shared entry point; reserve recruitment before warning or polling.
/obj/effect/landmark/ccpost_gorlex_director/proc/start_gorlex_poll(admin_forced = FALSE)
	if(event_started || polling_ghosts || GLOB.ccpost_outpost_signal_lost || !pick_landing(GLOB.ccpost_gorlex_insertions, TRUE) || !contract_available())
		return FALSE
	if(!get_disk() || (!admin_forced && (!automatic_deployment_authorized || automatic_recruitment_attempts >= CCPOST_GORLEX_MAX_RECRUITMENT_ATTEMPTS || !SSticker.IsRoundInProgress() || !deployment_eligible(get_disk()))))
		return FALSE
	polling_ghosts = TRUE
	if(!security_advisory_issued)
		security_advisory_issued = TRUE
		issue_security_advisory()
		log_game("CCPost Gorlex: security advisory issued; ghost recruitment opens in two minutes.")
		addtimer(CALLBACK(src, PROC_REF(begin_gorlex_recruitment), admin_forced), CCPOST_GORLEX_PREPARATION_TIME)
	else
		// A previous recruitment already gave the outpost its preparation window.
		begin_gorlex_recruitment(admin_forced)
	return TRUE

/// Revalidate after preparation, before exposing the role to ghosts.
/obj/effect/landmark/ccpost_gorlex_director/proc/begin_gorlex_recruitment(admin_forced = FALSE)
	if(QDELETED(src) || !polling_ghosts)
		return
	if(event_started || GLOB.ccpost_outpost_signal_lost || !get_disk() || !pick_landing(GLOB.ccpost_gorlex_insertions, TRUE) || !contract_available() || (!admin_forced && (!automatic_deployment_authorized || automatic_recruitment_attempts >= CCPOST_GORLEX_MAX_RECRUITMENT_ATTEMPTS || !SSticker.IsRoundInProgress() || !deployment_eligible(get_disk()))))
		polling_ghosts = FALSE
		if(!admin_forced)
			cancel_automatic_recruitment("deployment prerequisites lost before recruitment")
		else
			message_admins("Operation Severance: Gorlex recruitment cancelled; deployment prerequisites no longer met.")
		return
	if(!admin_forced)
		automatic_recruitment_attempts++
		next_recruitment_retry = 0
		log_game("CCPost Gorlex: automatic recruitment attempt [automatic_recruitment_attempts]/[CCPOST_GORLEX_MAX_RECRUITMENT_ATTEMPTS].")
	INVOKE_ASYNC(src, PROC_REF(poll_and_deploy), admin_forced)

/obj/effect/landmark/ccpost_gorlex_director/proc/poll_and_deploy(admin_forced = FALSE)
	var/icon/faction_icon = ccpost_poll_faction_icon(FALSE)
	var/list/candidates = SSpolling.poll_ghost_candidates(
		"Take a Gorlex Marauders contract targeting the Central Command Liaison Outpost?",
		check_jobban = ROLE_OPERATIVE,
		role = ROLE_LONE_OPERATIVE,
		alert_pic = faction_icon,
		chat_text_border_icon = image(faction_icon),
		role_name_text = "Gorlex Marauders operative"
	)
	if(QDELETED(src))
		return
	polling_ghosts = FALSE
	if(event_started)
		return
	if(GLOB.ccpost_outpost_signal_lost || !get_disk() || !contract_available() || (!admin_forced && (!SSticker.IsRoundInProgress() || !deployment_eligible(get_disk()))))
		if(!admin_forced)
			cancel_automatic_recruitment("deployment prerequisites lost during poll")
		return
	var/turf/T = pick_landing(GLOB.ccpost_gorlex_insertions, TRUE)
	if(!T)
		log_game("CCPost Gorlex: no eligible insertion landmark; poll ended without deployment.")
		if(!admin_forced)
			cancel_automatic_recruitment("insertion unavailable after poll")
		return
	// A volunteer may disconnect or leave their ghost before the poll resolves.
	var/list/valid_candidates = list()
	for(var/mob/dead/observer/candidate as anything in candidates)
		if(!QDELETED(candidate) && candidate.client && candidate.key)
			valid_candidates += candidate
	if(!length(valid_candidates))
		handle_failed_gorlex_recruitment(admin_forced, "no eligible volunteers")
		return
	var/mob/dead/observer/selected = pick(valid_candidates)
	var/mob/living/carbon/human/operative = new(T)
	operative.randomize_human_appearance(~RANDOMIZE_SPECIES)
	operative.dna.update_dna_identity()
	var/datum/mind/operative_mind = new /datum/mind(selected.key)
	operative_mind.set_assigned_role(SSjob.GetJobType(/datum/job/ghost_role))
	operative_mind.special_role = "Gorlex Marauders Operative"
	operative_mind.active = TRUE
	operative_mind.transfer_to(operative)
	if(!operative.mind)
		qdel(operative)
		handle_failed_gorlex_recruitment(admin_forced, "operative mind transfer failed")
		return
	if(!select_contract())
		// No objective is available: return the transferred volunteer to observer state.
		operative.ghostize(FALSE)
		qdel(operative)
		handle_failed_gorlex_recruitment(admin_forced, "no valid recovery objective")
		return
	event_started = TRUE
	next_recruitment_retry = 0
	operative_ref = WEAKREF(operative)
	operative_mind_ref = WEAKREF(operative_mind)
	operative_mind.add_antag_datum(/datum/antagonist/ccpost_gorlex)
	message_admins("[ADMIN_LOOKUPFLW(operative)] has accepted Operation Severance.")
	log_game("CCPost Gorlex: Operation Severance operative deployed at [AREACOORD(T)].")

/// A single local readiness advisory, never a station-wide announcement or an operative reveal.
/obj/effect/landmark/ccpost_gorlex_director/proc/issue_security_advisory()
	for(var/mob/living/carbon/human/person as anything in GLOB.mob_living_list)
		if(!ishuman(person) || QDELETED(person) || person.stat == DEAD || !person.client || !ccpost_is_outpost_personnel(person) || !istype(get_area(person), /area/ruin/space/has_grav/ccpost))
			continue
		SEND_SOUND(person, sound('sound/announcer/notice/notice3.ogg', volume = 65))
	// Use the same independent CentCom radio transport as NT-ADP-7.
	// Keep the transmitter alive for the asynchronous radio broadcast.
	if(!security_advisory_radio)
		security_advisory_radio = new(src)
		security_advisory_radio.name = "Central Command"
		security_advisory_radio.set_frequency(FREQ_CENTCOM)
		security_advisory_radio.independent = TRUE
		security_advisory_radio.ignores_radio_jammers = TRUE
		security_advisory_radio.canhear_range = 0
		security_advisory_radio.set_listening(FALSE)
		security_advisory_radio.command = TRUE
		security_advisory_radio.use_command = TRUE
	security_advisory_radio.talk_into(security_advisory_radio, "Unusual activity detected near your installation. Security, conduct perimeter checks. Liaisons, secure sensitive materials. All personnel, maintain heightened vigilance.", RADIO_CHANNEL_CENTCOM)

/// Reject station-level transfers without teleporting the cartridge back to the operative.
/// Also runs periodically so nested inventory/containers cannot bypass direct Moved().
/obj/effect/landmark/ccpost_gorlex_director/proc/secure_cartridge(obj/item/ccpost_classified_cartridge/cartridge)
	if(gorlex_victory || cybersun_recovered || !cartridge || QDELETED(cartridge) || data_cartridge_ref?.resolve() != cartridge)
		return
	var/turf/current = get_turf(cartridge)
	if(!current)
		return
	if(!is_station_level(current.z))
		last_valid_cartridge_turf = current
		return
	var/turf/safe = last_valid_cartridge_turf
	if(!safe || is_station_level(safe.z))
		safe = get_return_turf()
	if(!safe || is_station_level(safe.z))
		return
	cartridge.forceMove(safe)
	log_game("CCPost Gorlex: classified cartridge containment returned item to off-station [AREACOORD(safe)].")

/// The assigned original may travel between off-station levels, never to the main station.
/obj/effect/landmark/ccpost_gorlex_director/proc/secure_prototype()
	if(gorlex_victory || cybersun_recovered)
		return
	var/obj/item/prototype = contract_prototype_ref?.resolve()
	if(!prototype || QDELETED(prototype))
		return
	var/turf/current = get_turf(prototype)
	if(!current)
		return
	if(!is_station_level(current.z))
		last_valid_prototype_turf = current
		return
	var/turf/safe = last_valid_prototype_turf
	if(!safe || is_station_level(safe.z))
		safe = get_return_turf()
	if(safe && !is_station_level(safe.z))
		prototype.forceMove(safe)
		log_game("CCPost Gorlex: original prototype returned from the station to [AREACOORD(safe)].")

/// Private feedback works in vacuum and never broadcasts the operative's position.
/proc/ccpost_private_feedback(mob/recipient, sound_file, volume = 35)
	if(!recipient?.client || QDELETED(recipient))
		return
	recipient.playsound_local(null, sound_file, volume, FALSE, pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_SOUND_EFFECTS)

/proc/ccpost_objective_feedback(mob/recipient)
	ccpost_private_feedback(recipient, 'sound/effects/achievement/beeps_jingle.ogg', 50)

/obj/effect/landmark/ccpost_gorlex_director/proc/note_data_downloaded(datum/mind/downloader, obj/item/ccpost_classified_cartridge/cartridge)
	if(contract_kind != "data" || data_downloaded || !downloader || !cartridge || data_cartridge_ref?.resolve() != cartridge)
		return FALSE
	var/mob/living/operative = operative_ref?.resolve()
	if(!operative || operative.mind != downloader)
		return FALSE
	data_downloaded = TRUE
	asset_acquired = TRUE
	data_cartridge_ref = WEAKREF(cartridge)
	ccpost_objective_feedback(operative)
	to_chat(operative, span_boldnotice("GORLEX MARAUDERS: Classified tasking data acquired. Eject and retain the original cartridge. Proceed to NT-ADP-7, or deliberately abandon your contract by leaving the operational level with the asset without authorized retrieval. Desertion may trigger an irreversible Black Warrant and explosive implant countdown."))
	log_game("CCPost Gorlex: Operation Severance classified Tasking Server records stolen by [key_name(operative)].")
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/note_arming(mob/armer)
	armed_by_gorlex = !!(armer?.mind && armer.mind == operative_mind_ref?.resolve() && armer.mind.has_antag_datum(/datum/antagonist/ccpost_gorlex))
	if(armed_by_gorlex && !nuke_ever_armed)
		nuke_ever_armed = TRUE
		ccpost_objective_feedback(armer)

/obj/effect/landmark/ccpost_gorlex_director/proc/note_detonation()
	if(!event_started || !armed_by_gorlex || nuke_detonated)
		return
	nuke_detonated = TRUE
	// Detonation is an additional sabotage objective, not an automatic extraction victory.
	// The Gorlex player wins on authorized boarding with the intelligence.
	var/mob/living/operative = operative_ref?.resolve()
	if(operative && operative.client)
		ccpost_objective_feedback(operative)
		to_chat(operative, span_boldannounce("GORLEX MARAUDERS: NT-ADP-7 detonation confirmed. Asset-denial objective complete."))
	else
		var/mob/dead/observer/withdrawn_ghost = gorlex_withdrawn_ghost_ref?.resolve()
		if(withdrawn_ghost?.client && !withdrawn_ghost.mind)
			ccpost_objective_feedback(withdrawn_ghost)
	message_admins("Operation Severance: Gorlex-authorized NT-ADP-7 detonation recorded; extraction evaluated independently.")
	log_game("CCPost Gorlex: NT-ADP-7 sabotage objective completed.")

// Direct disk moves are checked immediately. Nested inventory movements are
// additionally covered by the director's five-second reconciliation pass.
/obj/item/disk/nuclear/ccpost_nuke/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director && !GLOB.ccpost_outpost_signal_lost)
		director.return_disk_if_offsite(src)

// Physical, uniquely identifiable intelligence. The download is performed on the Tasking
// Server, but its payload is a real object which can be dropped, stolen or recovered.
/obj/item/ccpost_classified_cartridge
	name = "blank encrypted tasking data cartridge"
	desc = "A single-use Cybersun encrypted storage cartridge, issued for Operation Severance. Its memory is empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	var/datum/mind/downloaded_by
	var/data_complete = FALSE

/obj/item/ccpost_classified_cartridge/ex_act(severity, target)
	return

/obj/item/ccpost_classified_cartridge/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/ccpost_tasking_server))
		return ..()
	var/obj/machinery/ccpost_tasking_server/server = interacting_with
	server.insert_classified_cartridge(src, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/ccpost_classified_cartridge/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director)
		director.secure_cartridge(src)

/obj/item/ccpost_classified_cartridge/examine(mob/user)
	. = ..()
	if(data_complete)
		. += span_notice("The cartridge indicates a completed encrypted data transfer.")
	else
		. += span_notice("The cartridge is empty and requires an authorized data port.")

// -------------------------------------------------------------------------
// ANTAGONIST: INDEPENDENT OF NORMAL NUCLEAR OPERATIVE ROUND-END SYSTEMS
// -------------------------------------------------------------------------

/datum/antagonist/ccpost_gorlex
	name = "Gorlex Marauders Operative"
	roundend_category = "Gorlex Operatives"
	antagpanel_category = ANTAG_GROUP_SYNDICATE
	antag_hud_name = "synd"
	show_to_ghosts = TRUE
	remove_from_manifest = TRUE
	stinger_sound = 'sound/music/antag/traitor/tatoralert.ogg'
	var/turf/insertion_turf
	var/last_recall_warning = 0
	var/withdrawal_identity
	/// Round-local, mind-owned allocation and spending records.
	var/loadout_id
	var/loadout_claiming = FALSE
	var/requisition_balance = 0
	var/list/requisition_purchased = list()
	var/list/requisition_history = list()
	var/list/loadout_issued = list()

// Genuine objective datums power the antagonist HUD and the round-end report.
// The four objectives are tracked independently by the event director.
/datum/objective/ccpost_gorlex_data
	name = "assigned asset acquisition"
	explanation_text = "Download classified Central Command Tasking Server records to the physical encrypted data cartridge."

/datum/objective/ccpost_gorlex_data/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	return director && director.asset_acquired

/datum/objective/ccpost_gorlex_arm
	name = "NT-ADP-7 authorization"
	explanation_text = "Acquire the NT-ADP-7 authentication disk and arm the Asset Denial Device using your issued authorization code."

/datum/objective/ccpost_gorlex_arm/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	return director && director.nuke_ever_armed

/datum/objective/ccpost_gorlex_extract
	name = "authorized retrieval"
	explanation_text = "Board your assigned Gorlex retrieval pod with the encrypted data cartridge and escape the sector."

/datum/objective/ccpost_gorlex_extract/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	return director && director.gorlex_victory

/datum/objective/ccpost_gorlex_sabotage
	name = "asset denial"
	explanation_text = "Ensure NT-ADP-7 successfully detonates and destroys the Liaison Outpost. Additional sabotage result."

/datum/objective/ccpost_gorlex_sabotage/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	return director && director.nuke_detonated

/datum/antagonist/ccpost_gorlex/forge_objectives()
	if(length(objectives))
		return
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	var/datum/objective/ccpost_gorlex_data/steal = new
	steal.owner = owner
	steal.explanation_text = director?.primary_instruction() || steal.explanation_text
	objectives += steal
	var/datum/objective/ccpost_gorlex_arm/arm = new
	arm.owner = owner
	objectives += arm
	var/datum/objective/ccpost_gorlex_extract/escape = new
	escape.owner = owner
	escape.explanation_text = "Board your assigned Gorlex retrieval pod with the original [director?.contract_asset_name || "designated asset"] and escape the sector."
	objectives += escape
	var/datum/objective/ccpost_gorlex_sabotage/sabotage = new
	sabotage.owner = owner
	objectives += sabotage

/datum/antagonist/ccpost_gorlex/on_gain()
	forge_objectives()
	. = ..()
	var/mob/living/carbon/human/operative = owner.current
	if(!ishuman(operative))
		return
	insertion_turf = get_turf(operative)
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!director || director.operative_mind_ref?.resolve() != owner || director.operative_ref?.resolve() != operative)
		return
	operative.equipOutfit(/datum/outfit/ccpost_gorlex)
	operative.faction |= ROLE_SYNDICATE
	RegisterSignal(operative, COMSIG_MOVABLE_MOVED, PROC_REF(on_operative_moved))
	RegisterSignal(operative, COMSIG_LIVING_DEATH, PROC_REF(on_operative_death))

/datum/antagonist/ccpost_gorlex/on_removal()
	if(owner?.current)
		UnregisterSignal(owner.current, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH))
	return ..()

/datum/antagonist/ccpost_gorlex/proc/on_operative_death(datum/source)
	SIGNAL_HANDLER
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director && director.operative_mind_ref?.resolve() == owner)
		var/mob/living/operative = source
		director.clear_warrant_warning()
		director.release_contract_asset(operative)
		if(director.black_warrant)
			director.warrant_target_dead = TRUE

/datum/antagonist/ccpost_gorlex/greet()
	. = ..() // Native antagonist greeting plays stinger_sound privately.
	to_chat(owner.current, span_boldwarning("GORLEX MARAUDERS // OPERATION SEVERANCE"))
	to_chat(owner.current, span_boldnotice("Cybersun Industries has authorized your deployment under Operation Severance."))
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	to_chat(owner.current, span_notice("[director?.primary_instruction() || "Recover the assigned asset."] Then arm NT-ADP-7 and complete authorized retrieval."))
	if(director?.operative_mind_ref?.resolve() == owner)
		to_chat(owner.current, span_boldnotice("GORLEX COMMAND: NT-ADP-7 authorization code: [ccpost_adp7_get_authorization_code()]. Recover the physical authentication disk. Your uplink retains a copy of the code."))
	to_chat(owner.current, span_notice("Your contract requires extraction with the original assigned asset. You may go rogue by leaving the operational z-level carrying that asset without authorized retrieval. This can trigger an irreversible Black Warrant and a non-removable explosive implant countdown."))
	to_chat(owner.current, span_boldnotice("Select your permanent loadout in Field Requisitions before approaching the outpost. Keep one hand free to receive your equipment bag. Your uplink also contains contract details and extraction instructions."))
	to_chat(owner.current, span_notice("The primary Nanotrasen station is outside your authorized operational zone. Entry, interference and unrelated personnel engagement are prohibited."))
	owner.announce_objectives()

/datum/antagonist/ccpost_gorlex/roundend_report()
	var/list/result = list()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	result += withdrawal_identity ? withdrawal_identity : ccpost_roundend_identity(owner, "Gorlex Operative")
	result += printobjectives(objectives)
	result += "<b>Black Warrant:</b> [director?.black_warrant ? "Issued" : "Not issued"]"
	if(director?.black_warrant)
		result += "<b>Contract status:</b> Terminated"
		if(director.implant_detonated)
			result += "<b>Corporate failsafe:</b> Detonated after authorization expired."
	if(director?.gorlex_victory)
		result += "<span class='greentext big'>Operation Severance contract fulfilled!</span>"
	else
		result += "<span class='redtext big'>Operation Severance contract unfulfilled.</span>"
	return result.Join("<br>")

/datum/antagonist/ccpost_gorlex/proc/on_operative_moved(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/operative = source
	// Cancel immediately on return, even between director processing ticks.
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!operative || !get_turf(operative))
		return
	if(!is_station_level(operative.z))
		if(director?.operative_ref?.resolve() == operative)
			director.check_contract_boundary(operative)
		return
	var/turf/return_turf = insertion_turf
	if(!return_turf || is_station_level(return_turf.z))
		return
	operative.forceMove(return_turf)
	if(world.time >= last_recall_warning + (8 SECONDS))
		last_recall_warning = world.time
		var/handler_message
		switch(rand(1, 3))
			if(1)
				handler_message = "GORLEX MARAUDERS: The main station is outside your authorized contract area. Return to permitted off-station operations."
			if(2)
				handler_message = "GORLEX MARAUDERS: Contract restrictions prohibit entering the main station. Returning you to the authorized sector."
			if(3)
				handler_message = "GORLEX COMMAND: Contract violation, operative. Your authorization excludes the main station. Return to the approved operational area."
		to_chat(operative, span_danger(handler_message))

/// Pre-deployment intelligence; separate from NanoTrasen's original directive.
/obj/item/paper/fluff/ruins/ccpost/gorlex_adp7_intelligence
	name = "Gorlex classified authorization intelligence"
	desc = "An intercepted NT-ADP-7 authorization code issued to an Operation Severance operative."

/obj/item/paper/fluff/ruins/ccpost/gorlex_adp7_intelligence/Initialize(mapload)
	default_raw_text = {"<center><b>GORLEX MARAUDERS</b><br><b>CLASSIFIED: OPERATION SEVERANCE</b></center><hr>
	<br><b>Device:</b> NT-ADP-7 Asset Denial Device
	<br><b>Authorization Code:</b> [ccpost_adp7_get_authorization_code()]
	<br><br>Authorization intelligence was acquired before deployment. Recover the physical NT-ADP-7 authentication disk from the Liaison Outpost and use the issued code to arm the device.
	<br><br>A duplicate of this code is available under Contract Details in your Gorlex uplink."}
	return ..()

/datum/outfit/ccpost_gorlex
	name = "Gorlex Marauders Field Operative"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	mask = /obj/item/clothing/mask/gas/syndicate
	id = /obj/item/card/id/advanced
	back = /obj/item/mod/control/pre_equipped/ccpost_gorlex
	belt = /obj/item/storage/belt/military
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	l_pocket = /obj/item/pinpointer/ccpost_adp7/syndicate
	box = /obj/item/storage/box/survival/syndie

/// Store issued equipment without silently deleting it when a slot is unavailable.
/proc/ccpost_issue_gear(mob/living/carbon/human/recipient, obj/item/item, prefer_belt = FALSE)
	var/obj/item/storage/gear_belt = recipient.get_item_by_slot(ITEM_SLOT_BELT)
	if(prefer_belt && gear_belt?.atom_storage?.attempt_insert(item, recipient))
		return TRUE
	var/obj/item/mod/control/mod = recipient.back
	if(istype(mod) && mod.atom_storage?.attempt_insert(item, recipient))
		return TRUE
	if(!prefer_belt && gear_belt?.atom_storage?.attempt_insert(item, recipient))
		return TRUE
	if(recipient.equip_to_slot_if_possible(item, ITEM_SLOT_BACKPACK, qdel_on_fail = FALSE, disable_warning = TRUE))
		return TRUE
	if(recipient.put_in_hands(item))
		return TRUE
	item.forceMove(get_turf(recipient))
	return FALSE

/proc/ccpost_install_augment(mob/living/carbon/human/recipient, path)
	var/obj/item/organ/internal/augment = new path()
	augment.Insert(recipient, drop_if_replaced = FALSE)

/proc/ccpost_prepare_mod(mob/living/carbon/human/recipient)
	var/obj/item/mod/control/mod = recipient.back
	if(!istype(mod))
		return
	var/obj/item/mod/module/dna_lock/lock = locate(/obj/item/mod/module/dna_lock) in mod.modules
	if(lock)
		lock.dna = recipient.dna.unique_enzymes
	mod.quick_activation()

/datum/outfit/ccpost_gorlex/post_equip(mob/living/carbon/human/operative, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director?.contract_kind == "data" && operative.mind && director.operative_mind_ref?.resolve() == operative.mind && director.operative_ref?.resolve() == operative && !director.data_cartridge_ref)
		var/obj/item/ccpost_classified_cartridge/cartridge = new(operative)
		director.data_cartridge_ref = WEAKREF(cartridge)
		director.last_valid_cartridge_turf = get_turf(operative)
		ccpost_issue_gear(operative, cartridge)
	var/obj/item/ccpost_gorlex_uplink/uplink = new(operative)
	uplink.owner_mind = operative.mind
	ccpost_issue_gear(operative, uplink)
	var/obj/item/paper/fluff/ruins/ccpost/gorlex_adp7_intelligence/intelligence = new(operative)
	ccpost_issue_gear(operative, intelligence)
	ccpost_install_microbomb(operative, TRUE)
	ccpost_issue_gear(operative, new /obj/item/pen/edagger(operative), prefer_belt = TRUE)
	for(var/path in list(/obj/item/grenade/empgrenade, /obj/item/grenade/smokebomb))
		var/obj/item/supply = new path(operative)
		ccpost_issue_gear(operative, supply, prefer_belt = TRUE)
	for(var/path in list(/obj/item/organ/internal/cyberimp/eyes/hud/medical, /obj/item/organ/internal/cyberimp/mouth/breathing_tube))
		ccpost_install_augment(operative, path)
	ccpost_prepare_mod(operative)
	var/obj/item/radio/radio = operative.ears
	if(radio)
		radio.set_frequency(FREQ_SYNDICATE)

/// Isolated theme: retain Syndicate armor and visuals, not its combat utility modules.
/datum/mod_theme/syndicate/ccpost_gorlex
	inbuilt_modules = list(/obj/item/mod/module/welding/syndicate)

/obj/item/mod/control/pre_equipped/ccpost_gorlex
	name = "Gorlex field operations MODsuit"
	desc = "An EVA-capable field suit with standardized Syndicate hardpoints."
	theme = /datum/mod_theme/syndicate/ccpost_gorlex
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock
	)

// -------------------------------------------------------------------------
// DEDICATED ALLOWLIST UPLINK. NO GENERAL SYNDICATE UPLINK ACCESS.
// -------------------------------------------------------------------------

/obj/item/ccpost_gorlex_uplink
	name = "Gorlex field operations uplink"
	desc = "An encrypted contractor procurement terminal. Access restricted to the assigned Gorlex Marauder."
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	w_class = WEIGHT_CLASS_SMALL
	var/datum/mind/owner_mind
	var/telecrystals = 0
	var/list/purchased = list()
	var/list/purchase_history = list()
	/// The Cybersun uplink uses the identical TGUI and server purchase handler.
	var/cybersun_brand = FALSE

/obj/item/ccpost_gorlex_uplink/cybersun
	name = "Cybersun Industries enforcement uplink"
	desc = "Cybersun Industries secure corporate enforcement and field requisition interface."
	cybersun_brand = TRUE
	telecrystals = CCPOST_CYBERSUN_TC

/obj/item/ccpost_gorlex_uplink/cybersun/catalogue()
	return list(
		"sonar" = list("Tracking & Pursuit", "Active Sonar Module", "Audible short-range life-detection pulse.", 5, 1, /obj/item/mod/module/active_sonar, 1),
		"thermal" = list("Tracking & Pursuit", "Thermal Optics Upgrade", "See mobs through walls; replaces tactical optics.", 7, 1, /obj/item/autosurgeon/syndicate/thermal_eyes, 1),
		"tether" = list("Tracking & Pursuit", "Tether Module", "Exterior mobility assistance.", 3, 1, /obj/item/mod/module/tether, 1),
		"combat_shield" = list("Advanced Armaments", "Combat Energy Shield", "Collapsible handheld energy shield for close-quarters protection.", 5, 1, /obj/item/shield/energy, 1),
		"esword" = list("Advanced Armaments", "Energy Sword", "Independent melee backup.", 4, 1, /obj/item/melee/energy/sword, 1),
		"mantis" = list("Advanced Armaments", "Syndicate Mantis Blade", "Arm-mounted melee augmentation.", 6, 1, /obj/item/autosurgeon/syndicate/syndie_mantis, 1),
		"shield" = list("Enforcement Systems", "Energy Shield Module", "Three rechargeable attack-blocking charges.", 7, 1, /obj/item/mod/module/energy_shield, 1),
		"bulwark" = list("Enforcement Systems", "Bulwark Module", "Resists shoves.", 4, 1, /obj/item/mod/module/shove_blocker, 1),
		"noslip" = list("Enforcement Systems", "Anti-Slip Module", "Prevents ordinary wet-floor slips.", 3, 1, /obj/item/mod/module/noslip, 1),
		"cuffs" = list("Enforcement Systems", "Restraints", "Secure incapacitated targets.", 1, 1, /obj/item/restraints/handcuffs, 2),
		"flash" = list("Tactical Operations", "Flashbang Package", "Two flashbangs.", 3, 1, /obj/item/grenade/flashbang, 2),
		"smoke" = list("Tactical Operations", "Smoke Package", "Two smoke grenades.", 2, 1, /obj/item/grenade/smokebomb, 2),
		"emp_grenade" = list("Tactical Operations", "EMP Grenade", "Electronic disruption.", 3, 2, /obj/item/grenade/empgrenade, 1),
		"medkit" = list("Medical & Recovery", "Spare Combat Medical Kit", "Emergency treatment; one kit already issued.", 3, 1, /obj/item/storage/medkit/combat, 1),
		"reviver" = list("Medical & Recovery", "Reviver Implant", "Emergency medical recovery.", 6, 1, /obj/item/autosurgeon/syndicate/reviver, 1),
		"stimulant" = list("Medical & Recovery", "Combat Stimulant Injector", "Short-term combat assistance.", 3, 1, /obj/item/reagent_containers/medipen/stimulants, 1),
		"oxygen" = list("Medical & Recovery", "Spare Oxygen", "Extended EVA operation.", 1, 2, /obj/item/tank/internals/emergency_oxygen/engi, 1)
	)

/obj/item/ccpost_gorlex_uplink/proc/has_access(mob/user)
	return user && user.mind && user.mind == owner_mind

/obj/item/ccpost_gorlex_uplink/attack_self(mob/user)
	ui_interact(user)

/obj/item/ccpost_gorlex_uplink/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/ccpost_gorlex_uplink/ui_interact(mob/user, datum/tgui/ui)
	if(!has_access(user))
		to_chat(user, span_warning("ENCRYPTED REQUISITIONS: Unauthorized operator."))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostGorlexUplink", name)
		ui.open()
	ui.set_autoupdate(TRUE)

/// Each server-owned entry is ID -> category, name, description, TC, max stock, type, quantity.
/// All actual purchase checks use this function, never a client-supplied item path.

/obj/item/knife/combat/ccpost_gorlex
	name = "Gorlex tactical combat knife"
	desc = "A reinforced mercenary field knife. Its edge is designed for close-quarters combat."
	force = 20
	armour_penetration = 20

/// Keep the native compact shotgun capacity, but issue lethal ammunition to Breacher.
/obj/item/ammo_box/magazine/internal/shot/com/compact/ccpost_gorlex
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/ccpost_gorlex
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/com/compact/ccpost_gorlex

/obj/item/storage/backpack/duffelbag/syndie/ccpost_loadout
	name = "Gorlex field equipment bag"
	desc = "A sealed contractor equipment allocation bag. Keep it in your hand or transfer its contents to your MODsuit."

/// No client-supplied item paths. Loadout identifiers are fixed server-side.
/obj/item/ccpost_gorlex_uplink/proc/gorlex_antag()
	if(cybersun_brand)
		return null
	var/datum/antagonist/ccpost_gorlex/antag = owner_mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex)
	return antag

/obj/item/ccpost_gorlex_uplink/proc/sync_gorlex_requisitions()
	var/datum/antagonist/ccpost_gorlex/antag = gorlex_antag()
	if(!antag)
		return
	telecrystals = antag.requisition_balance
	purchased = antag.requisition_purchased
	purchase_history = antag.requisition_history

/obj/item/ccpost_gorlex_uplink/proc/claim_loadout(mob/living/carbon/human/user, id)
	var/datum/antagonist/ccpost_gorlex/antag = gorlex_antag()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!antag || antag.loadout_id || antag.loadout_claiming || !director || director.black_warrant || director.operative_ref?.resolve() != user || director.operative_mind_ref?.resolve() != user.mind || !ishuman(user) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_INCAPACITATED))
		return FALSE
	if(!(id in list("WRAITH", "VANGUARD", "BREACHER", "NOMAD")))
		return FALSE
	var/obj/item/mod/control/pre_equipped/ccpost_gorlex/mod = user.back
	if(!istype(mod) || !mod.active || !length(user.get_empty_held_indexes()))
		to_chat(user, span_warning("GORLEX: Wear and activate your issued MODsuit and free one hand to accept your equipment bag."))
		return FALSE
	antag.loadout_claiming = TRUE
	var/obj/item/storage/backpack/duffelbag/syndie/ccpost_loadout/bag = new(user)
	if(!user.put_in_hands(bag, del_on_fail = TRUE))
		antag.loadout_claiming = FALSE
		return FALSE
	// Fit only the chosen modules; pressure seals, internals and the control unit remain intact.
	var/list/module_paths = list()
	var/obj/item/mod/module/jetpack/old_jetpack
	switch(id)
		if("WRAITH")
			module_paths += /obj/item/mod/module/stealth
		if("VANGUARD")
			module_paths += /obj/item/mod/module/magnetic_harness
		if("NOMAD")
			module_paths += /obj/item/mod/module/night
			module_paths += /obj/item/mod/module/jetpack/advanced
			old_jetpack = locate(/obj/item/mod/module/jetpack) in mod.modules
			if(!old_jetpack || istype(old_jetpack, /obj/item/mod/module/jetpack/advanced))
				qdel(bag)
				antag.loadout_claiming = FALSE
				return FALSE
	var/list/installed = list()
	var/failed = FALSE
	var/jetpack_was_active = FALSE
	var/obj/item/mod/module/jetpack/advanced/new_jetpack
	for(var/path in module_paths)
		if(path == /obj/item/mod/module/jetpack/advanced)
			jetpack_was_active = old_jetpack.active
			mod.uninstall(old_jetpack)
		var/obj/item/mod/module/module = new path(mod)
		mod.install(module, null)
		if(!(module in mod.modules))
			qdel(module)
			failed = TRUE
			break
		installed += module
		if(istype(module, /obj/item/mod/module/jetpack/advanced))
			new_jetpack = module
	if(failed)
		for(var/obj/item/mod/module/module as anything in installed)
			mod.uninstall(module)
			qdel(module)
		if(old_jetpack && !(old_jetpack in mod.modules))
			mod.install(old_jetpack, null)
			if(jetpack_was_active && (old_jetpack in mod.modules))
				old_jetpack.activate()
		qdel(bag)
		antag.loadout_claiming = FALSE
		to_chat(user, span_warning("GORLEX: Module fitting failed. Restore your suit's original configuration and retry."))
		return FALSE
	if(old_jetpack)
		qdel(old_jetpack)
	if(jetpack_was_active && new_jetpack)
		new_jetpack.activate()
	// Native modules are installed, not issued as duplicates.
	switch(id)
		if("WRAITH")
			var/obj/item/gun/ballistic/automatic/pistol/clandestine/pistol = new(bag)
			var/obj/item/suppressor/suppressor = new(pistol)
			pistol.install_suppressor(suppressor)
			new /obj/item/ammo_box/magazine/m10mm(bag)
			new /obj/item/card/emag/doorjack(bag)
			new /obj/item/grenade/smokebomb(bag)
			antag.loadout_issued["doorjack"] = 1
			antag.loadout_issued["cloak"] = 1
		if("VANGUARD")
			new /obj/item/gun/energy/modular_laser_rifle/carbine(bag)
			new /obj/item/knife/combat/ccpost_gorlex(bag)
			new /obj/item/grenade/flashbang(bag)
			new /obj/item/grenade/flashbang(bag)
			antag.loadout_issued["knife"] = 1
			antag.loadout_issued["magnetic"] = 1
			antag.loadout_issued["flash"] = 2
		if("BREACHER")
			new /obj/item/gun/ballistic/shotgun/automatic/combat/compact/ccpost_gorlex(bag)
			new /obj/item/ammo_box/advanced/s12gauge(bag)
			new /obj/item/grenade/c4(bag)
			new /obj/item/grenade/c4/x4(bag)
			new /obj/item/storage/toolbox/syndicate(bag)
			antag.loadout_issued["c4"] = 1
			antag.loadout_issued["x4"] = 1
			antag.loadout_issued["toolbox"] = 1
		if("NOMAD")
			new /obj/item/gun/ballistic/automatic/pistol(bag)
			new /obj/item/ammo_box/magazine/m9mm(bag)
			new /obj/item/storage/medkit/combat(bag)
			antag.loadout_issued["jetpack"] = 1
			antag.loadout_issued["night"] = 1
	antag.loadout_id = id
	antag.requisition_balance = CCPOST_GORLEX_TC
	antag.loadout_claiming = FALSE
	sync_gorlex_requisitions()
	to_chat(user, span_boldnotice("GORLEX: [id] loadout allocated. Your equipment bag is in your hand. 5 TC discretionary reserve authorized."))
	if(jetpack_was_active && !new_jetpack?.active)
		to_chat(user, span_notice("GORLEX: Advanced propulsion fitted. Re-enable your jetpack using the MODsuit controls."))
	log_game("CCPost Gorlex: [key_name(user)] selected [id].")
	return TRUE

/// Restriction and issued status are authoritative, including when equipment is lost.
/obj/item/ccpost_gorlex_uplink/proc/gorlex_requisition_status(id)
	var/datum/antagonist/ccpost_gorlex/antag = gorlex_antag()
	if(!antag?.loadout_id)
		return "Restricted"
	var/required_loadout
	switch(id)
		if("doorjack", "cloak")
			required_loadout = "WRAITH"
		if("knife", "magnetic")
			required_loadout = "VANGUARD"
		if("x4", "shotgun_ammo")
			required_loadout = "BREACHER"
		if("jetpack", "night", "nomad_ammo")
			required_loadout = "NOMAD"
		if("pistol_mag")
			required_loadout = "WRAITH"
	if(required_loadout && antag.loadout_id != required_loadout)
		return "Restricted"
	if(id in list("pistol_mag", "nomad_ammo", "shotgun_ammo", "medkit", "stimulant", "c4", "x4"))
		return "Available"
	if(antag.loadout_issued[id] || antag.requisition_purchased[id])
		return "Issued"
	return "Available"

/obj/item/ccpost_gorlex_uplink/proc/catalogue()
	return list(
		"jammer" = list("Utility", "Radio Jammer", "Local radio interference.", 2, 1, /obj/item/jammer, 1),
		"doorjack" = list("Specialist Equipment", "Airlock Override Card", "WRAITH only; issued with loadout.", 3, 1, /obj/item/card/emag/doorjack, 1),
		"cloak" = list("Specialist Equipment", "Prototype Cloaking Module", "WRAITH only; fitted at allocation.", 7, 1, /obj/item/mod/module/stealth, 1),
		"knife" = list("Specialist Equipment", "Gorlex Tactical Combat Knife", "VANGUARD only; issued with loadout.", 3, 1, /obj/item/knife/combat/ccpost_gorlex, 1),
		"magnetic" = list("Specialist Equipment", "Magnetic Harness", "VANGUARD only; fitted at allocation.", 2, 1, /obj/item/mod/module/magnetic_harness, 1),
		"jetpack" = list("Specialist Equipment", "Advanced Jetpack", "NOMAD only; fitted at allocation.", 3, 1, /obj/item/mod/module/jetpack/advanced, 1),
		"night" = list("Specialist Equipment", "Night Vision Module", "NOMAD only; fitted at allocation.", 3, 1, /obj/item/mod/module/night, 1),
		"flash" = list("Utility", "Flashbang", "One flashbang; Vanguard already issued.", 2, 1, /obj/item/grenade/flashbang, 1),
		"toolbox" = list("Utility", "Syndicate Toolbox", "Field engineering tools.", 2, 1, /obj/item/storage/toolbox/syndicate, 1),
		"pistol_mag" = list("Ammunition", "10mm Magazine", "WRAITH Ansem ammunition.", 2, 2, /obj/item/ammo_box/magazine/m10mm, 1),
		"nomad_ammo" = list("Ammunition", "9mm Magazine", "NOMAD pistol ammunition.", 2, 2, /obj/item/ammo_box/magazine/m9mm, 1),
		"shotgun_ammo" = list("Ammunition", "Shotgun Slugs", "BREACHER shotgun ammunition.", 2, 2, /obj/item/ammo_box/advanced/s12gauge, 1),
		"c4" = list("Sabotage", "C-4 Charge", "General demolition; shared four-charge allocation.", 2, CCPOST_GORLEX_PLASTIC_LIMIT, /obj/item/grenade/c4, 1),
		"x4" = list("Sabotage", "X-4 Shaped Charge", "BREACHER only; shared four-charge allocation.", 4, CCPOST_GORLEX_PLASTIC_LIMIT, /obj/item/grenade/c4/x4, 1),
		"emp_shield" = list("MOD Systems", "EMP Shielding", "Electronic protection.", 3, 1, /obj/item/mod/module/emp_shield, 1),
		"hearing" = list("MOD Systems", "Hearing Protection", "Protects hearing.", 2, 1, /obj/item/mod/module/hearing_protection, 1),
		"holster" = list("MOD Systems", "Holster Module", "Rapid weapon storage.", 2, 1, /obj/item/mod/module/holster, 1),
		"noslip" = list("MOD Systems", "Anti-Slip Module", "Prevents ordinary wet-floor slips.", 3, 1, /obj/item/mod/module/noslip, 1),
		"medkit" = list("Medical & Survival", "Combat Medical Kit", "Emergency treatment.", 3, 2, /obj/item/storage/medkit/combat, 1),
		"stimulant" = list("Medical & Survival", "Combat Stimulant Injector", "Reduced-dose stimulant and omnizine.", 4, 1, /obj/item/reagent_containers/medipen/stimpack/traitor, 1)
	)

/// The same authoritative stock calculation drives the UI and purchase validation.
/obj/item/ccpost_gorlex_uplink/proc/requisition_stock(id, list/entry)
	if(!cybersun_brand)
		if(gorlex_requisition_status(id) != "Available")
			return 0
		var/datum/antagonist/ccpost_gorlex/antag = gorlex_antag()
		if(id == "c4" || id == "x4")
			return max(0, CCPOST_GORLEX_PLASTIC_LIMIT - (antag.loadout_issued["c4"] || 0) - (antag.loadout_issued["x4"] || 0) - (purchased["c4"] || 0) - (purchased["x4"] || 0))
	if(id == "c4" || id == "x4")
		return max(0, CCPOST_GORLEX_PLASTIC_LIMIT - (purchased["c4"] || 0) - (purchased["x4"] || 0))
	return max(0, entry[5] - (purchased[id] || 0))

/// Cache native sprites by type; never instantiate equipment just to render the catalogue.
/proc/ccpost_requisition_sprite(path)
	var/static/list/sprites = list()
	if(path in sprites)
		return sprites[path]
	var/obj/item/item_path = path
	var/icon_file = initial(item_path.icon)
	var/state = initial(item_path.icon_state)
	if(initial(item_path.greyscale_config) && initial(item_path.greyscale_colors))
		icon_file = SSgreyscale.GetColoredIconByType(initial(item_path.greyscale_config), initial(item_path.greyscale_colors))
	var/sprite = null
	if(icon_file && (state in icon_states(icon_file)))
		sprite = icon2base64(icon(icon_file, icon_state = state, dir = SOUTH, frame = 1))
	sprites[path] = sprite || ""
	return sprites[path]

/obj/item/ccpost_gorlex_uplink/ui_static_data(mob/user)
	if(!has_access(user))
		return list()
	var/list/entries = catalogue()
	var/list/sprites = list()
	for(var/id in entries)
		var/list/entry = entries[id]
		sprites[id] = ccpost_requisition_sprite(entry[6])
	return list("equipment_icons" = sprites)

/// Cross-level status without inventing a direction across unrelated Z levels.
/proc/ccpost_tracking_readout(atom/target, mob/user, label)
	var/turf/current = get_turf(user)
	var/turf/destination = QDELETED(target) ? null : get_turf(target)
	if(!destination || is_station_level(destination.z))
		return list("label" = label, "signal" = "UNAVAILABLE", "sector" = null, "current_sector" = current?.z, "same_level" = FALSE)
	return list("label" = label, "signal" = "ACQUIRED", "sector" = destination.z, "current_sector" = current?.z, "same_level" = !!(current && current.z == destination.z))

/obj/item/ccpost_gorlex_uplink/ui_data(mob/user)
	if(!has_access(user))
		return list("authorized" = FALSE)
	sync_gorlex_requisitions()
	var/datum/antagonist/ccpost_gorlex/gorlex = gorlex_antag()
	var/list/items = list()
	var/list/entries = catalogue()
	for(var/id in entries)
		var/list/entry = entries[id]
		var/path = entry[6]
		var/module_complexity = null
		if(ispath(path, /obj/item/mod/module))
			var/obj/item/mod/module/module_path = path
			module_complexity = initial(module_path.complexity)
		items += list(list(
			"id" = id,
			"category" = entry[1],
			"name" = entry[2],
			"description" = entry[3],
			"cost" = entry[4],
			"limit" = entry[5],
			"purchased" = purchased[id] || 0,
			"stock" = requisition_stock(id, entry),
			"quantity" = entry[7],
			"shared_stock" = (id == "c4" || id == "x4"),
			"allocation_status" = cybersun_brand ? null : gorlex_requisition_status(id),
			"complexity" = module_complexity
		))
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	var/obj/item/ccpost_classified_cartridge/cartridge = director?.data_cartridge_ref?.resolve()
	var/datum/antagonist/ccpost_cybersun/enforcer = user.mind?.has_antag_datum(/datum/antagonist/ccpost_cybersun)
	var/list/stages = list(
		"data" = !!director?.data_downloaded,
		"asset_acquired" = !!director?.asset_acquired,
		"armed" = !!director?.nuke_ever_armed,
		"detonated" = !!director?.nuke_detonated,
		"extracted" = !!director?.gorlex_victory,
		"data_present" = !!cartridge && !QDELETED(cartridge),
		"cartridge_complete" = !!cartridge?.data_complete,
		"black_warrant" = !!director?.black_warrant,
	)
	var/list/personnel = list()
	if(!cybersun_brand)
		var/datum/ccpost_hr_service/hr_service = GLOB.ccpost_hr_service
		if(hr_service)
			for(var/employee_key in hr_service.roster)
				var/datum/ccpost_hr_employee/employee = hr_service.roster[employee_key]
				if(!employee || employee.employee_role != "Central Command Liaison")
					continue
				var/mob/living/carbon/human/subject = employee.employee_mind?.current
				var/medical_status = "SIGNAL UNAVAILABLE"
				if(istype(subject))
					if(subject.stat == DEAD)
						medical_status = "DECEASED"
					else if(!subject.client)
						medical_status = "SIGNAL UNAVAILABLE"
					else if(subject.health <= 0)
						medical_status = "CRITICAL"
					else if(subject.health < subject.maxHealth * 0.6)
						medical_status = "INJURED"
					else
						medical_status = "STABLE"
				personnel += list(list("name" = employee.employee_name, "role" = employee.employee_role, "portrait" = employee.portrait_base64, "medical" = medical_status))
	var/list/tracking = list()
	if(cybersun_brand)
		if(director?.black_warrant && director.enforcer_mind == user.mind && !director.enforcer_recalled)
			var/datum/mind/warrant_mind = director.operative_mind_ref?.resolve()
			var/atom/subject = warrant_mind?.current
			if(!isliving(subject))
				subject = director.operative_ref?.resolve()
			tracking += list(ccpost_tracking_readout(subject, user, "Warrant subject"))
			tracking += list(ccpost_tracking_readout(director.contract_asset(), user, director.contract_asset_name))
	else if(director?.operative_mind_ref?.resolve() == user.mind)
		var/atom/asset = director.primary_target()
		var/asset_label = director.contract_kind == "data" && !director.data_downloaded ? "Tasking Distribution Server" : director.contract_asset_name
		tracking += list(ccpost_tracking_readout(asset, user, asset_label))
		tracking += list(ccpost_tracking_readout(director.get_disk(), user, "NT-ADP-7 authentication disk"))
		tracking += list(ccpost_tracking_readout(director.get_contract_nuke(), user, "NT-ADP-7 device"))
		if(director.extraction_turf)
			tracking += list(ccpost_tracking_readout(director.extraction_turf, user, "Retrieval site"))
	var/requisitions_locked = director && ((!cybersun_brand && director.black_warrant) || (cybersun_brand && director.enforcer_mission_deadline && world.time >= director.enforcer_mission_deadline))
	return list(
		"requisitions_locked" = !!requisitions_locked,
		"implant_duration" = CCPOST_GORLEX_FAILSAFE_TIME / 10,
		"mission_duration" = CCPOST_CYBERSUN_MISSION_TIME / 10,
		"implant_seconds" = director && director.implant_deadline ? CEILING(max(0, director.implant_deadline - world.time) / 10, 1) : 0,
		"mission_seconds" = director && director.enforcer_mission_deadline ? CEILING(max(0, director.enforcer_mission_deadline - world.time) / 10, 1) : 0,
		"mission_timer_active" = !!(director && director.enforcer_mission_deadline && !director.enforcer_recalled && !director.enforcer_forced_withdrawal),
		"forced_recall" = !!director?.enforcer_forced_pending,
		"authorized" = TRUE,
		"brand" = cybersun_brand ? "cybersun" : "gorlex",
		"adp7_authorization_code" = (!cybersun_brand && director?.operative_mind_ref?.resolve() == user.mind) ? "[ccpost_adp7_get_authorization_code()]" : null,
		"loadout" = gorlex?.loadout_id,
		"telecrystals" = telecrystals,
		"catalogue" = requisitions_locked ? list() : items,
		"history" = purchase_history,
		"mission" = stages,
		"tracking" = tracking,
		"contract_kind" = director?.contract_kind,
		"contract_asset_name" = director?.contract_asset_name,
		"primary_instruction" = director?.primary_instruction(),
		"asset_held" = !!director?.holds_contract_asset(user),
		"personnel" = personnel,
		"target" = list("name" = director?.warrant_target_name || "UNASSIGNED SUBJECT", "status" = director?.black_warrant ? (director.refresh_warrant_target() ? "DECEASED" : "ACTIVE WARRANT") : "NO WARRANT SUBJECT"),
		"recall_implemented" = TRUE,
		"extraction_implemented" = TRUE,
		"extraction_status" = director?.extraction_status || "DIRECTOR OFFLINE",
		"extraction_seconds" = director ? CEILING(max(0, director.extraction_deadline - world.time) / 10, 1) : 0,
		"extraction_location" = director?.extraction_turf ? AREACOORD(director.extraction_turf) : "UNASSIGNED",
		"extraction_ready" = !cybersun_brand && !!director?.can_request_extraction(user),
		"landing_available" = !!director?.pick_landing(GLOB.ccpost_gorlex_extraction_landmarks),
		"warrant_seconds" = director ? CEILING(max(0, director.warrant_deadline - world.time) / 10, 1) : 0,
		"cartridge_held" = !!director?.holds_contract_asset(user),
		"recall_ready" = cybersun_brand && !!director?.can_recall(user),
		"cybersun_recovered" = !!director?.cybersun_recovered,
		"recalled" = !!(director && (user.mind == director.enforcer_mind && director.enforcer_recalled)),
		"recall_pending" = !!enforcer?.recall_pending
	)

/obj/item/ccpost_gorlex_uplink/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!(action in list("purchase", "request_extraction", "request_recall", "claim_loadout")))
		return FALSE
	var/mob/user = ui?.user
	if(!has_access(user) || !user.can_perform_action(src))
		return TRUE
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(action == "request_extraction")
		if(!cybersun_brand && director)
			director.request_extraction(user)
		SStgui.update_uis(src)
		return TRUE
	if(action == "request_recall")
		if(cybersun_brand && director)
			director.request_recall(user)
		SStgui.update_uis(src)
		return TRUE
	if(director && ((!cybersun_brand && director.black_warrant) || (cybersun_brand && director.enforcer_mission_deadline && world.time >= director.enforcer_mission_deadline)))
		to_chat(user, span_warning("REQUISITIONS: Operational authorization revoked."))
		SStgui.update_uis(src)
		return TRUE
	var/id = params["id"]
	if(!istext(id))
		return TRUE
	if(action == "claim_loadout")
		if(!cybersun_brand && ishuman(user))
			claim_loadout(user, id)
		SStgui.update_uis(src)
		return TRUE
	sync_gorlex_requisitions()
	var/datum/antagonist/ccpost_gorlex/gorlex = gorlex_antag()
	if(!cybersun_brand && (!gorlex?.loadout_id || director?.operative_ref?.resolve() != user || gorlex_requisition_status(id) != "Available"))
		return TRUE
	var/list/entries = catalogue()
	var/list/entry = entries[id]
	if(!islist(entry))
		return TRUE
	var/cost = entry[4]
	var/used = purchased[id] || 0
	if(cost > telecrystals || requisition_stock(id, entry) <= 0)
		return TRUE
	var/path = entry[6]
	var/amount = entry[7]
	if(!cybersun_brand)
		// All supplementary entries issue one object. Require a free hand, never drop into space.
		if(!length(user.get_empty_held_indexes()))
			to_chat(user, span_warning("GORLEX: Free one hand to receive requisitions."))
			return TRUE
		var/obj/item/supply = new path(user)
		if(!user.put_in_hands(supply, del_on_fail = TRUE))
			return TRUE
		telecrystals -= cost
		gorlex.requisition_balance = telecrystals
		purchased[id] = used + 1
	else
		telecrystals -= cost
		purchased[id] = used + 1
		for(var/i in 1 to amount)
			var/obj/item/supply = new path(user.drop_location())
			user.put_in_hands(supply)
	purchase_history.Insert(1, "[station_time_timestamp()] / [entry[2]] / -[cost] TC")
	if(length(purchase_history) > 12)
		purchase_history.Cut(13)
	to_chat(user, span_notice("[cybersun_brand ? "Cybersun" : "Gorlex"] requisition issued: [entry[2]] for [cost] TC. [telecrystals] TC remaining."))
	log_game("[cybersun_brand ? "Cybersun" : "Gorlex"] uplink purchase: [key_name(user)] bought [entry[2]] for [cost] TC.")
	SStgui.update_uis(src)
	return TRUE

// Extraction, Black Warrant and enforcement.
/obj/effect/landmark/ccpost_gorlex_extraction
	name = "Gorlex retrieval pod landing (map marker)"

/obj/effect/landmark/ccpost_gorlex_extraction/Initialize(mapload)
	. = ..()
	GLOB.ccpost_gorlex_extraction_landmarks |= src

/obj/effect/landmark/ccpost_gorlex_extraction/Destroy()
	GLOB.ccpost_gorlex_extraction_landmarks -= src
	return ..()

/obj/effect/landmark/ccpost_cybersun_insertion
	name = "Cybersun Enforcer insertion (map marker)"

/obj/effect/landmark/ccpost_cybersun_insertion/Initialize(mapload)
	. = ..()
	GLOB.ccpost_cybersun_insertions |= src

/obj/effect/landmark/ccpost_cybersun_insertion/Destroy()
	GLOB.ccpost_cybersun_insertions -= src
	return ..()

/// Unlike is_safe_turf(), this permits vacuum floors: the two factions use EVA MODsuits.
/// Gorlex extraction requires a floor; Cybersun insertion also permits open space. Both reject blocked and station-side turfs.
/obj/effect/landmark/ccpost_gorlex_director/proc/landing_turf_valid(turf/T, allow_space = FALSE)
	if(!T || (!isfloorturf(T) && !(allow_space && isspaceturf(T))) || T.density || is_station_level(T.z) || istype(T, /turf/open/lava))
		return FALSE
	for(var/atom/movable/occupant in T)
		if(occupant.density || isliving(occupant))
			return FALSE
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/pick_landing(list/markers, allow_space = FALSE)
	var/list/eligible = list()
	for(var/obj/effect/landmark/marker as anything in markers)
		if(QDELETED(marker))
			continue
		var/turf/T = get_turf(marker)
		if(landing_turf_valid(T, allow_space))
			eligible |= T
	return length(eligible) ? pick(eligible) : null

/obj/effect/landmark/ccpost_gorlex_director/proc/holds_contract_asset(mob/user)
	var/obj/item/asset = contract_asset()
	if(!user || !asset || QDELETED(asset))
		return FALSE
	if(contract_kind == "data")
		var/obj/item/ccpost_classified_cartridge/cartridge = asset
		if(!istype(cartridge) || !cartridge.data_complete)
			return FALSE
	var/atom/container = asset.loc
	while(container && !isturf(container))
		if(container == user)
			return TRUE
		if(ismob(container))
			return FALSE
		container = container.loc
	return FALSE

/// Latch completion only on real possession of the exact assigned prototype.
/obj/effect/landmark/ccpost_gorlex_director/proc/check_asset_acquired(mob/living/operative)
	if(asset_acquired || contract_kind != "prototype" || !operative || operative.mind != operative_mind_ref?.resolve() || !holds_contract_asset(operative))
		return
	asset_acquired = TRUE
	ccpost_objective_feedback(operative)
	to_chat(operative, span_boldnotice("GORLEX MARAUDERS: [contract_asset_name] recovered. Proceed to NT-ADP-7. You may instead abandon your contract by leaving the operational level with this asset without authorized retrieval. A Black Warrant permanently activates your explosive implant countdown."))
	log_game("CCPost Gorlex: assigned prototype acquired by [key_name(operative)].")

/obj/effect/landmark/ccpost_gorlex_director/proc/is_operational_turf(turf/T)
	if(!T || is_station_level(T.z))
		return FALSE
	if(istype(get_area(T), /area/ruin/space/has_grav/ccpost))
		return TRUE
	var/turf/center = get_turf(src)
	if(center && T.z == center.z && get_dist(T, center) <= max(1, operational_radius))
		return TRUE
	// Insertion sites are also designated operational areas, even on another Z-level.
	for(var/obj/effect/landmark/ccpost_gorlex_insertion/marker as anything in GLOB.ccpost_gorlex_insertions)
		var/turf/insertion = get_turf(marker)
		if(insertion && T.z == insertion.z && get_dist(T, insertion) <= max(1, operational_radius))
			return TRUE
	return FALSE

/obj/effect/landmark/ccpost_gorlex_director/proc/can_request_extraction(mob/user)
	return event_started && !black_warrant && !gorlex_victory && !extraction_deadline && !extraction_pod_ref?.resolve() && user && get_turf(user) && user.stat == CONSCIOUS && !HAS_TRAIT(user, TRAIT_INCAPACITATED) && user == operative_ref?.resolve() && user.mind == operative_mind_ref?.resolve() && user.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) && asset_acquired && nuke_ever_armed && holds_contract_asset(user) && is_operational_turf(get_turf(user))

/obj/effect/landmark/ccpost_gorlex_director/proc/request_extraction(mob/user)
	if(!can_request_extraction(user))
		to_chat(user, span_warning("GORLEX COMMAND: Retrieval authorization denied. Complete assigned asset acquisition and NT-ADP-7 authorization; retain the original asset."))
		return FALSE
	var/turf/landing = pick_landing(GLOB.ccpost_gorlex_extraction_landmarks)
	if(!landing)
		to_chat(user, span_warning("GORLEX COMMAND: No safe retrieval landing site available."))
		return FALSE
	extraction_turf = landing
	extraction_deadline = world.time + CCPOST_GORLEX_EXTRACTION_TIME
	extraction_status = "EN ROUTE"
	var/obj/effect/ccpost_retrieval_marker/marker = new(landing)
	extraction_marker_ref = WEAKREF(marker)
	to_chat(user, span_boldnotice("GORLEX COMMAND: Retrieval authorized. Arrival in 80 seconds at [AREACOORD(landing)]."))
	log_game("Operation Severance: retrieval requested at [AREACOORD(landing)].")
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/process_contract()
	var/mob/living/operative = operative_ref?.resolve()
	if(black_warrant)
		refresh_warrant_target()
		if(warrant_target_dead && !enforcer_termination_cue_sent && !enforcer_recalled && !enforcer_forced_withdrawal && !enforcer_forced_pending)
			var/mob/living/enforcer = enforcer_mind?.current
			if(isliving(enforcer) && enforcer.stat != DEAD && enforcer.client)
				enforcer_termination_cue_sent = TRUE
				ccpost_objective_feedback(enforcer)
		process_pursuit()
	if((extraction_status in list("LANDED - BOARD POD", "LANDING", "DEPARTING")) && !extraction_pod_ref?.resolve() && !gorlex_victory)
		extraction_status = "POD LOST - REQUEST AGAIN"
		extraction_departing = FALSE
		extraction_turf = null
	if(extraction_deadline && (!operative || operative.stat == DEAD))
		extraction_deadline = 0
		clear_landing_marker()
		extraction_status = "CANCELLED"
	if(extraction_deadline && world.time >= extraction_deadline)
		extraction_deadline = 0
		clear_landing_marker()
		if(!operative || operative.stat == DEAD || black_warrant || gorlex_victory)
			extraction_status = "CANCELLED"
		else if(!landing_turf_valid(extraction_turf))
			extraction_status = "LANDING OBSTRUCTED - REQUEST AGAIN"
			extraction_turf = null
			to_chat(operative, span_warning("GORLEX COMMAND: Landing site obstructed. Request retrieval again."))
		else
			var/obj/structure/ccpost_gorlex_retrieval_pod/pod = new(extraction_turf)
			pod.director_ref = WEAKREF(src)
			extraction_pod_ref = WEAKREF(pod)
			extraction_status = "LANDING"
			pod.pixel_z = 400
			pod.alpha = 0
			animate(pod, pixel_z = 0, alpha = 255, time = 10)
			playsound(extraction_turf, 'sound/items/weapons/mortar_long_whistle.ogg', 65, TRUE)
			addtimer(CALLBACK(src, PROC_REF(finish_landing), pod), 10)
			pod.visible_message(span_notice("[pod] descends onto the designated landing point."))
			to_chat(operative, span_notice("GORLEX COMMAND: Retrieval pod on final approach. Stand clear."))
	check_contract_boundary(operative)

/// Called on movement and by the director as a fallback for nested storage/transport.
/obj/effect/landmark/ccpost_gorlex_director/proc/check_contract_boundary(mob/living/operative)
	if(black_warrant || gorlex_victory || !operative || QDELETED(operative) || operative.stat == DEAD || operative.mind != operative_mind_ref?.resolve())
		if(warrant_deadline)
			clear_warrant_warning()
		return
	check_asset_acquired(operative)
	var/turf/current = get_turf(operative)
	if(!current)
		return
	if(is_authorized_contract_turf(current))
		if(warrant_deadline)
			rescind_warrant_warning(operative)
		return
	// Station entry is separately blocked by the antagonist movement handler.
	if(is_station_level(current.z))
		return
	// Once a departure with the asset has started the warning, dropping the item
	// cannot cancel it. Only a return to authorized space can restore compliance.
	if(warrant_deadline)
		if(world.time >= warrant_deadline)
			issue_black_warrant(operative)
		return
	if(asset_acquired && holds_contract_asset(operative))
		start_warrant_warning(operative)
		return
	if(!last_boundary_reminder || world.time >= last_boundary_reminder + 30 SECONDS)
		last_boundary_reminder = world.time
		to_chat(operative, span_notice("GORLEX COMMAND: You have left the operational level. Return to the Liaison Outpost and use your pinpointer or uplink tracking to locate your assigned objective."))

/// The operational Z level is the outpost's level, not an arbitrary radius.
/// Authorized retrieval adds its own designated landing zone; the station stays prohibited.
/obj/effect/landmark/ccpost_gorlex_director/proc/is_authorized_contract_turf(turf/current)
	if(!current || is_station_level(current.z))
		return FALSE
	var/turf/origin = get_turf(src)
	if(origin && current.z == origin.z)
		return TRUE
	return !!((extraction_deadline || extraction_pod_ref?.resolve()) && extraction_turf && current.z == extraction_turf.z && get_dist(current, extraction_turf) <= max(1, operational_radius))

/obj/effect/landmark/ccpost_gorlex_director/proc/start_warrant_warning(mob/living/operative)
	if(warrant_deadline || black_warrant || gorlex_victory)
		return
	warrant_deadline = world.time + CCPOST_GORLEX_WARRANT_GRACE
	warrant_warning_generation++
	// A reserved channel lets us silence the last beep without touching unrelated sounds.
	warrant_warning_channel = SSsounds.reserve_sound_channel()
	to_chat(operative, span_bolddanger("CYBERSUN CONTRACT CONTROL: Unauthorized withdrawal detected. Return to the operational area within 15 seconds or face a Black Warrant."))
	play_warrant_warning_audio(operative, 'sound/machines/beep/twobeep.ogg', 35)
	addtimer(CALLBACK(src, PROC_REF(warrant_warning_beep), warrant_warning_generation), 1 SECONDS)

/obj/effect/landmark/ccpost_gorlex_director/proc/play_warrant_warning_audio(mob/living/operative, sound_file, volume)
	if(!warrant_warning_channel || !operative?.client || QDELETED(operative))
		return
	if(warrant_warning_listener != operative.client)
		warrant_warning_listener?.mob?.stop_sound_channel(warrant_warning_channel)
		warrant_warning_listener = operative.client
	operative.playsound_local(null, sound_file, volume, FALSE, channel = warrant_warning_channel, pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_SOUND_EFFECTS)

/obj/effect/landmark/ccpost_gorlex_director/proc/clear_warrant_warning()
	warrant_deadline = 0
	warrant_warning_generation++
	if(warrant_warning_channel)
		warrant_warning_listener?.mob?.stop_sound_channel(warrant_warning_channel)
		SSsounds.free_sound_channel(warrant_warning_channel)
		warrant_warning_channel = 0
	warrant_warning_listener = null

/obj/effect/landmark/ccpost_gorlex_director/proc/rescind_warrant_warning(mob/living/operative)
	if(!warrant_deadline)
		return
	clear_warrant_warning()
	to_chat(operative, span_notice("GORLEX COMMAND: Contract compliance restored. Warning rescinded."))

/obj/effect/landmark/ccpost_gorlex_director/proc/warrant_warning_beep(generation)
	// An old callback must never affect a later warning or play after the warrant is issued.
	if(generation != warrant_warning_generation || !warrant_deadline)
		return
	var/mob/living/operative = operative_ref?.resolve()
	var/turf/current = get_turf(operative)
	if(black_warrant || gorlex_victory || !asset_acquired || !operative || QDELETED(operative) || operative.stat == DEAD || !current)
		clear_warrant_warning()
		return
	if(is_authorized_contract_turf(current))
		rescind_warrant_warning(operative)
		return
	var/remaining = warrant_deadline - world.time
	if(remaining <= 0)
		issue_black_warrant(operative)
		return
	var/interval = 1 SECONDS
	var/volume = 35
	if(remaining <= 2 SECONDS)
		interval = 0.25 SECONDS
		volume = 55
	else if(remaining <= 5 SECONDS)
		interval = 0.5 SECONDS
		volume = 45
	play_warrant_warning_audio(operative, 'sound/machines/beep/beep.ogg', volume)
	// Never schedule beyond the deadline; align the transitions to the absolute clock.
	addtimer(CALLBACK(src, PROC_REF(warrant_warning_beep), generation), min(interval, remaining))

/obj/effect/landmark/ccpost_gorlex_director/proc/issue_black_warrant(mob/living/operative)
	if(black_warrant || gorlex_victory || !asset_acquired || !operative)
		return FALSE
	black_warrant = TRUE
	implant_deadline = world.time + CCPOST_GORLEX_FAILSAFE_TIME
	addtimer(CALLBACK(src, PROC_REF(start_failsafe_beeps)), CCPOST_GORLEX_FAILSAFE_TIME - 10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(expire_failsafe)), CCPOST_GORLEX_FAILSAFE_TIME)
	clear_warrant_warning()
	warrant_target_dead = (operative.stat == DEAD)
	warrant_target_name = operative.real_name
	extraction_deadline = 0
	clear_landing_marker()
	extraction_status = "REVOKED - BLACK WARRANT"
	var/obj/structure/ccpost_gorlex_retrieval_pod/pod = extraction_pod_ref?.resolve()
	if(pod)
		qdel(pod)
	ccpost_private_feedback(operative, 'sound/effects/alert.ogg', 65)
	to_chat(operative, span_bolddanger("CYBERSUN INDUSTRIES: BLACK WARRANT ISSUED. Your contract is terminated. Lethal corporate enforcement authorized."))
	to_chat(operative, span_bolddanger("CYBERSUN: Corporate failsafe armed. Detonation in [CCPOST_GORLEX_FAILSAFE_TIME / (1 MINUTES)] minutes. All requisitions revoked."))
	message_admins("Operation Severance: Black Warrant issued for [ADMIN_LOOKUPFLW(operative)].")
	log_game("Operation Severance: Black Warrant issued for [key_name(operative)].")
	if(!warrant_poll_started)
		warrant_poll_started = TRUE
		INVOKE_ASYNC(src, PROC_REF(poll_enforcers), TRUE)
	return TRUE

/// Death signal is latched across gibbing; revival of the contract mind cancels the death confirmation.
/obj/effect/landmark/ccpost_gorlex_director/proc/refresh_warrant_target()
	if(!black_warrant)
		return FALSE
	if(enforcer_recalled)
		return TRUE
	var/datum/mind/contract_mind = operative_mind_ref?.resolve()
	var/mob/living/current_body = contract_mind?.current
	if(isliving(current_body) && !QDELETED(current_body))
		warrant_target_dead = (current_body.stat == DEAD)
	return warrant_target_dead

/// Only the initial automatic poll can schedule a retry; manual polls do not extend the schedule.
/obj/effect/landmark/ccpost_gorlex_director/proc/schedule_enforcer_retry()
	if(enforcer_retry_scheduled || !can_recruit_enforcer())
		return
	enforcer_retry_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(retry_enforcer_poll)), CCPOST_CYBERSUN_RETRY_DELAY)

/obj/effect/landmark/ccpost_gorlex_director/proc/retry_enforcer_poll()
	if(QDELETED(src) || !can_recruit_enforcer() || enforcer_poll_active)
		return
	poll_enforcers()

/obj/effect/landmark/ccpost_gorlex_director/proc/poll_enforcers(allow_auto_retry = FALSE)
	if(!can_recruit_enforcer() || enforcer_poll_active)
		return FALSE
	if(!pick_landing(GLOB.ccpost_cybersun_insertions, TRUE))
		log_game("Operation Severance: no eligible Cybersun insertion landmark; poll not started.")
		if(allow_auto_retry)
			schedule_enforcer_retry()
		return FALSE
	enforcer_poll_active = TRUE
	var/icon/faction_icon = ccpost_poll_faction_icon(TRUE)
	var/list/candidates = SSpolling.poll_ghost_candidates(
		"Accept a Cybersun Black Warrant? Eliminate [warrant_target_name] and recover [contract_asset_name].",
		check_jobban = ROLE_OPERATIVE,
		role = ROLE_LONE_OPERATIVE,
		alert_pic = faction_icon,
		chat_text_border_icon = image(faction_icon),
		role_name_text = "Cybersun Enforcer"
	)
	enforcer_poll_active = FALSE
	if(QDELETED(src) || !can_recruit_enforcer())
		return FALSE
	while(length(candidates))
		var/mob/dead/observer/selected = pick(candidates)
		candidates -= selected
		if(deploy_enforcer_ghost(selected))
			return TRUE
	if(allow_auto_retry)
		schedule_enforcer_retry()
	log_game("Operation Severance: Cybersun poll ended without deployment; admin retry available.")
	return FALSE

/obj/effect/landmark/ccpost_gorlex_director/proc/deploy_enforcer_ghost(mob/dead/observer/selected)
	if(!can_recruit_enforcer() || !selected?.client || !selected.key || selected.mind == operative_mind_ref?.resolve())
		return FALSE
	var/turf/T = pick_landing(GLOB.ccpost_cybersun_insertions, TRUE)
	if(!T)
		return FALSE
	var/mob/living/carbon/human/enforcer = new(T)
	enforcer.randomize_human_appearance(~RANDOMIZE_SPECIES)
	enforcer.dna.update_dna_identity()
	var/datum/mind/new_mind = new /datum/mind(selected.key)
	new_mind.set_assigned_role(SSjob.GetJobType(/datum/job/ghost_role))
	new_mind.special_role = "Cybersun Enforcer"
	new_mind.active = TRUE
	new_mind.transfer_to(enforcer)
	if(enforcer.mind != new_mind)
		qdel(enforcer)
		return FALSE
	enforcer_mind = new_mind
	new_mind.add_antag_datum(/datum/antagonist/ccpost_cybersun)
	message_admins("[ADMIN_LOOKUPFLW(enforcer)] deployed as Cybersun Enforcer.")
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/clear_landing_marker()
	var/obj/effect/ccpost_retrieval_marker/marker = extraction_marker_ref?.resolve()
	if(marker)
		qdel(marker)
	extraction_marker_ref = null

/obj/effect/landmark/ccpost_gorlex_director/proc/finish_landing(obj/structure/ccpost_gorlex_retrieval_pod/pod)
	if(QDELETED(pod) || extraction_pod_ref?.resolve() != pod || black_warrant)
		return
	// The landing tile may have become occupied during the visual descent.
	var/turf/landing = get_turf(pod)
	if(!landing || !isfloorturf(landing) || landing.density || istype(landing, /turf/open/lava))
		qdel(pod)
		extraction_status = "LANDING OBSTRUCTED - REQUEST AGAIN"
		extraction_turf = null
		return
	for(var/atom/movable/occupant in landing)
		if(occupant != pod && (occupant.density || isliving(occupant)))
			qdel(pod)
			extraction_status = "LANDING OBSTRUCTED - REQUEST AGAIN"
			extraction_turf = null
			return
	playsound(get_turf(pod), SFX_EXPLOSION, 40, TRUE)
	pod.set_hatch(TRUE)
	extraction_status = "LANDED - BOARD POD"
	var/mob/living/operative = operative_ref?.resolve()
	if(operative)
		to_chat(operative, span_boldnotice("GORLEX COMMAND: Retrieval pod landed at [AREACOORD(landing)]. Board with the original [contract_asset_name]."))

/obj/effect/ccpost_retrieval_marker
	name = "Landing Zone Indicator"
	desc = "A holographic projection marking an inbound retrieval pod."
	icon = 'icons/obj/supplypods_32x32.dmi'
	icon_state = "LZ"
	anchored = TRUE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER

/obj/structure/ccpost_gorlex_retrieval_pod
	name = "Gorlex retrieval pod"
	desc = "An armored extraction vehicle. Its authorization scanner accepts only the assigned Gorlex contractor."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "darkpod"
	pixel_x = -16
	anchored = TRUE
	density = FALSE
	can_buckle = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | UNACIDABLE
	var/datum/weakref/director_ref
	var/hatch_open = FALSE
	var/reversed = FALSE

/obj/structure/ccpost_gorlex_retrieval_pod/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/ccpost_gorlex_retrieval_pod/update_overlays()
	. = ..()
	// Match native supplypod masking: open pods reveal the interior; fins stay in front of the door.
	var/icon/door_icon = new(icon, "darkpod_door")
	if(hatch_open)
		var/icon/masked_decal = new(icon, "syndicate")
		door_icon.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 1,1,1,0, 0,0,0,1)
		door_icon.SwapColor("#ffffffff", null)
		door_icon.Blend("#000000", ICON_SUBTRACT)
		masked_decal.Blend(door_icon, ICON_ADD)
		. += masked_decal
		return
	var/icon/fin_masker = new(icon, reversed ? "mask_bottomfin" : "mask_topfin")
	fin_masker.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 1,1,1,0, 0,0,0,1)
	fin_masker.SwapColor("#ffffffff", null)
	fin_masker.Blend("#000000", ICON_SUBTRACT)
	door_icon.Blend(fin_masker, ICON_ADD)
	. += door_icon
	. += "syndicate"

/obj/structure/ccpost_gorlex_retrieval_pod/proc/set_hatch(open_hatch)
	if(hatch_open == open_hatch)
		return
	hatch_open = open_hatch
	update_appearance()
	if(hatch_open)
		playsound(src, 'sound/machines/closet/closet_open.ogg', 35, TRUE, -3)
	else
		playsound(src, 'sound/machines/closet/closet_close.ogg', 50, TRUE, -3)

/obj/structure/ccpost_gorlex_retrieval_pod/proc/set_departure_orientation()
	reversed = TRUE
	icon_state = "darkpod_reverse"
	update_appearance()

/obj/structure/ccpost_gorlex_retrieval_pod/examine(mob/user)
	. = ..()
	. += span_notice("Use an empty hand on the boarding hatch to buckle in and depart. Only the designated Gorlex operative carrying the original designated asset may depart.")

/obj/structure/ccpost_gorlex_retrieval_pod/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!force || !hatch_open)
		return FALSE
	return ..()

/obj/structure/ccpost_gorlex_retrieval_pod/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/obj/effect/landmark/ccpost_gorlex_director/director = director_ref?.resolve()
	if(director)
		director.board_retrieval(user, src)
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/board_retrieval(mob/living/user, obj/structure/ccpost_gorlex_retrieval_pod/pod)
	if(!user || !get_turf(user) || user != operative_ref?.resolve() || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_INCAPACITATED) || user.mind != operative_mind_ref?.resolve() || !user.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) || !user.Adjacent(pod) || black_warrant || gorlex_victory || extraction_pod_ref?.resolve() != pod || !holds_contract_asset(user) || extraction_status != "LANDED - BOARD POD" || extraction_departing || !pod.hatch_open)
		to_chat(user, span_warning("GORLEX RETRIEVAL: Boarding denied. Assigned operative and original designated asset required."))
		return FALSE
	if(!pod.buckle_mob(user, force = TRUE, check_loc = FALSE))
		return FALSE
	extraction_departing = TRUE
	extraction_status = "DEPARTING"
	INVOKE_ASYNC(src, PROC_REF(depart_retrieval), user, pod)
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/depart_retrieval(mob/living/user, obj/structure/ccpost_gorlex_retrieval_pod/pod)
	if(!do_after(user, 2 SECONDS, target = pod, timed_action_flags = IGNORE_HELD_ITEM|IGNORE_SLOWDOWNS) || QDELETED(pod) || QDELETED(user) || user.buckled != pod || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_INCAPACITATED) || black_warrant || gorlex_victory || GLOB.ccpost_gorlex_director != src || extraction_pod_ref?.resolve() != pod || user != operative_ref?.resolve() || user.mind != operative_mind_ref?.resolve() || !user.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) || !holds_contract_asset(user))
		extraction_departing = FALSE
		if(!black_warrant && !gorlex_victory && !QDELETED(pod) && extraction_pod_ref?.resolve() == pod)
			pod.set_hatch(TRUE)
			extraction_status = "LANDED - BOARD POD"
			if(!QDELETED(user) && user.buckled == pod)
				pod.unbuckle_mob(user)
		return
	gorlex_victory = TRUE
	extraction_status = "EXTRACTED"
	clear_warrant_warning()
	var/datum/antagonist/ccpost_gorlex/antag = user.mind.has_antag_datum(/datum/antagonist/ccpost_gorlex)
	antag.withdrawal_identity = ccpost_withdrawal_identity(user, "extraction")
	ccpost_objective_feedback(user)
	to_chat(user, span_boldnotice("GORLEX COMMAND: Retrieval confirmed. Operation Severance contract fulfilled."))
	log_game("Operation Severance: authorized Gorlex extraction by [key_name(user)].")
	pod.set_hatch(FALSE)
	pod.set_departure_orientation()
	playsound(get_turf(pod), 'sound/effects/podwoosh.ogg', 65, TRUE)
	pod.unbuckle_mob(user)
	qdel(contract_asset())
	var/mob/dead/observer/withdrawn_ghost = ccpost_remove_withdrawn_body(user)
	if(withdrawn_ghost)
		gorlex_withdrawn_ghost_ref = WEAKREF(withdrawn_ghost)
	animate(pod, pixel_z = 400, alpha = 0, time = 10)
	QDEL_IN(pod, 15)

/// Keep native ckey privacy, character identity and survival/body-destruction formatting.
/// Substitute the faction designation only; do not change the mind's assigned job.
/proc/ccpost_roundend_identity(datum/mind/subject, faction_role)
	var/identity = printplayer(subject)
	if(!is_unassigned_job(subject.assigned_role))
		identity = replacetext(identity, " the <b>[subject.assigned_role.title]</b>", " the <b>[faction_role]</b>")
	return identity

/proc/ccpost_withdrawal_identity(mob/living/user, withdrawal_method)
	var/faction_role = withdrawal_method == "extraction" ? "Gorlex Operative" : "Cybersun Enforcer"
	return "[ccpost_roundend_identity(user.mind, faction_role)] through authorized [withdrawal_method]."

/// Preserve the original antagonist mind on the round's mind list, remove the physical actor and inventory.
/proc/ccpost_remove_withdrawn_body(mob/living/user)
	for(var/obj/item/implant/explosive/microbomb in user.implants?.Copy())
		qdel(microbomb)
	var/mob/dead/observer/withdrawn_ghost = user.ghostize(FALSE)
	user.moveToNullspace()
	qdel(user)
	return withdrawn_ghost

/datum/antagonist/ccpost_cybersun
	name = "Cybersun Enforcer"
	roundend_category = "Cybersun Enforcers"
	antagpanel_category = ANTAG_GROUP_SYNDICATE
	antag_hud_name = "synd"
	show_to_ghosts = TRUE
	remove_from_manifest = TRUE
	stinger_sound = 'sound/music/antag/traitor/tatoralert.ogg'
	var/turf/insertion_turf
	var/recall_pending = FALSE
	var/withdrawal_identity

/datum/antagonist/ccpost_cybersun/forge_objectives()
	if(length(objectives))
		return
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	var/datum/objective/ccpost_cybersun_terminate/terminate = new
	terminate.owner = owner
	terminate.explanation_text = "Eliminate the Black Warrant subject, [director?.warrant_target_name || "the rogue Gorlex operative"]."
	objectives += terminate
	var/datum/objective/ccpost_cybersun_recover/recover = new
	recover.owner = owner
	recover.explanation_text = "Recover the original [director?.contract_asset_name || "designated asset"] and complete authorized recall."
	objectives += recover
	var/datum/objective/ccpost_cybersun_recall/recall = new
	recall.owner = owner
	objectives += recall

/datum/objective/ccpost_cybersun_terminate
	name = "Black Warrant termination"
	explanation_text = "Eliminate the designated rogue Gorlex operative."
/datum/objective/ccpost_cybersun_terminate/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director?.enforcer_forced_withdrawal)
		return director.enforcer_termination_at_withdrawal
	return !!director?.refresh_warrant_target()

/datum/objective/ccpost_cybersun_recover
	name = "corporate asset recovery"
	explanation_text = "Recover the classified data cartridge containing the downloaded Liaison Outpost records."
/datum/objective/ccpost_cybersun_recover/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	return !!director?.cybersun_recovered

/datum/objective/ccpost_cybersun_recall
	name = "authorized corporate recall"
	explanation_text = "Return to Cybersun Headquarters via bluespace recall."
/datum/objective/ccpost_cybersun_recall/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	return director && (owner == director.enforcer_mind && director.enforcer_recalled)

/datum/antagonist/ccpost_cybersun/on_gain()
	forge_objectives()
	. = ..()
	var/mob/living/carbon/human/enforcer = owner.current
	if(!ishuman(enforcer))
		return
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director && !director.enforcer_mind)
		director.enforcer_mind = owner
	insertion_turf = get_turf(enforcer)
	enforcer.equipOutfit(/datum/outfit/ccpost_cybersun)
	if(director && director.enforcer_mind == owner)
		director.start_enforcer_timer(enforcer)
	RegisterSignal(enforcer, COMSIG_MOVABLE_MOVED, PROC_REF(on_enforcer_moved))
	RegisterSignal(enforcer, COMSIG_LIVING_DEATH, PROC_REF(on_enforcer_death))

/datum/antagonist/ccpost_cybersun/on_removal()
	if(owner?.current)
		UnregisterSignal(owner.current, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH))
	return ..()

/datum/antagonist/ccpost_cybersun/proc/on_enforcer_death(datum/source)
	SIGNAL_HANDLER
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director && director.enforcer_mind == owner)
		var/mob/living/enforcer = source
		director.release_contract_asset(enforcer)
		var/obj/effect/ccpost_recall_charge/manual_charge = director.manual_charge_ref?.resolve()
		var/obj/effect/ccpost_recall_charge/forced_charge = director.forced_charge_ref?.resolve()
		if(manual_charge)
			qdel(manual_charge)
		if(forced_charge)
			qdel(forced_charge)

/datum/antagonist/ccpost_cybersun/greet()
	. = ..() // Native antagonist greeting plays stinger_sound privately.
	to_chat(owner.current, span_boldwarning("CYBERSUN INDUSTRIES // BLACK WARRANT ENFORCEMENT"))
	to_chat(owner.current, span_notice("Terminate the designated rogue contractor and recover the original assigned asset. Unrelated personnel are not valid targets. Consult your uplink for directive details and recall authorization. The main station and unrelated personnel are outside your jurisdiction."))
	owner.announce_objectives()

/datum/antagonist/ccpost_cybersun/roundend_report()
	var/list/result = list()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	result += withdrawal_identity ? withdrawal_identity : ccpost_roundend_identity(owner, "Cybersun Enforcer")
	result += "<b>Black Warrant subject:</b> [html_encode(director?.warrant_target_name || "Unassigned")]"
	if(director?.enforcer_forced_withdrawal)
		result += "<b>Operational status:</b> Authorization expired. Compulsory bluespace withdrawal executed."
	result += printobjectives(objectives)
	if(director?.enforcer_recalled && director.cybersun_recovered && director.refresh_warrant_target())
		result += "<span class='greentext big'>Black Warrant fulfilled!</span>"
	else
		result += "<span class='redtext big'>Black Warrant unfulfilled.</span>"
	return result.Join("<br>")

/datum/antagonist/ccpost_cybersun/proc/on_enforcer_moved(datum/source)
	SIGNAL_HANDLER
	var/mob/living/enforcer = source
	if(enforcer && get_turf(enforcer) && is_station_level(enforcer.z) && insertion_turf && !is_station_level(insertion_turf.z))
		enforcer.forceMove(insertion_turf)
		to_chat(enforcer, span_warning("CYBERSUN: Main station access is outside your enforcement jurisdiction."))

/// Enforcement-only variant: preserve all native modes, capacity and damage.
/obj/item/gun/energy/modular_laser_rifle/ccpost_cybersun
	name = "\improper Cybersun Hyeseong modular laser rifle"
	desc = "An enforcement-grade Hyeseong with an internal regenerative power system. Its charge replenishes slowly between engagements."
	selfcharge = TRUE
	// Energy-gun process() accumulates seconds_per_tick, not world-time deciseconds.
	charge_delay = 2
	self_charge_amount = STANDARD_ENERGY_GUN_SELF_CHARGE_RATE * 0.1

/datum/outfit/ccpost_cybersun
	name = "Cybersun Enforcement Operative"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	mask = /obj/item/clothing/mask/gas/syndicate
	id = /obj/item/card/id/advanced/chameleon
	back = /obj/item/mod/control/pre_equipped/ccpost_cybersun
	belt = /obj/item/storage/belt/military
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	r_hand = /obj/item/gun/energy/modular_laser_rifle/ccpost_cybersun
	box = /obj/item/storage/box/survival/syndie

/datum/outfit/ccpost_cybersun/post_equip(mob/living/carbon/human/enforcer, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/ccpost_gorlex_uplink/cybersun/uplink = new(enforcer)
	uplink.owner_mind = enforcer.mind
	ccpost_issue_gear(enforcer, uplink)
	ccpost_install_microbomb(enforcer)
	var/obj/item/pinpointer/ccpost_warrant/tracker = new(enforcer)
	tracker.owner_mind = enforcer.mind
	ccpost_issue_gear(enforcer, tracker)
	ccpost_issue_gear(enforcer, new /obj/item/storage/medkit/combat(enforcer))
	ccpost_issue_gear(enforcer, new /obj/item/card/emag/doorjack(enforcer))
	for(var/path in list(/obj/item/organ/internal/cyberimp/chest/sandevistan, /obj/item/organ/internal/cyberimp/arm/item_set/toolset/l, /obj/item/organ/internal/cyberimp/brain/anti_stun/syndicate, /obj/item/organ/internal/cyberimp/brain/anti_drop/syndicate, /obj/item/organ/internal/eyes/robotic/ccpost_optics, /obj/item/organ/internal/cyberimp/eyes/hud/medical, /obj/item/organ/internal/cyberimp/mouth/breathing_tube))
		ccpost_install_augment(enforcer, path)
	ccpost_prepare_mod(enforcer)
	var/obj/item/radio/radio = enforcer.ears
	if(radio)
		radio.set_frequency(FREQ_SYNDICATE)

/obj/item/organ/internal/eyes/robotic/ccpost_optics
	name = "Cybersun tactical optics"
	desc = "Corporate combat optics with low-light enhancement and reactive flash shielding."
	eye_color_left = "FF7300"
	eye_color_right = "FF7300"
	color_cutoffs = list(25, 12, 8)
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/control/pre_equipped/ccpost_cybersun
	name = "Cybersun enforcement MODsuit"
	desc = "An EVA-capable corporate enforcement suit."
	theme = /datum/mod_theme/syndicate
	applied_skin = "cybersun"
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/bluespace
	applied_modules = list(/obj/item/mod/module/storage/syndicate, /obj/item/mod/module/jetpack/advanced, /obj/item/mod/module/flashlight, /obj/item/mod/module/dna_lock, /obj/item/mod/module/emp_shield/advanced, /obj/item/mod/module/magnetic_harness)

/obj/item/pinpointer/ccpost_warrant
	name = "Cybersun warrant tracker"
	desc = "A secure tracker calibrated to the Black Warrant subject. Alt-click to switch between subject and assigned asset recovery."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"
	minimum_range = 15
	var/datum/mind/owner_mind
	process_scan = TRUE
	var/track_asset = FALSE

/obj/item/pinpointer/ccpost_warrant/attack_self(mob/living/user)
	if(user.mind != owner_mind)
		return
	return ..()

/obj/item/pinpointer/ccpost_warrant/click_alt(mob/user)
	if(user.mind != owner_mind)
		return CLICK_ACTION_BLOCKING
	track_asset = !track_asset
	scan_for_target()
	update_appearance()
	to_chat(user, span_notice("Warrant tracker: [track_asset ? "Asset recovery" : "Warrant subject"] mode."))
	return CLICK_ACTION_SUCCESS

/obj/item/pinpointer/ccpost_warrant/proc/warrant_tracking_target()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!director?.black_warrant || director.enforcer_recalled || director.enforcer_forced_withdrawal || director.enforcer_mind != owner_mind)
		return null
	if(track_asset)
		return director.contract_asset()
	var/datum/mind/subject = director.operative_mind_ref?.resolve()
	var/mob/living/body = subject?.current
	return isliving(body) ? body : director.operative_ref?.resolve()

/obj/item/pinpointer/ccpost_warrant/scan_for_target()
	target = null
	var/atom/signal_target = warrant_tracking_target()
	var/turf/destination = get_turf(signal_target)
	var/turf/origin = get_turf(src)
	if(destination && origin && !is_station_level(destination.z) && destination.z == origin.z)
		target = signal_target

/obj/item/pinpointer/ccpost_warrant/examine(mob/user)
	. = ..()
	if(user.mind != owner_mind || !active)
		return
	var/list/readout = ccpost_tracking_readout(warrant_tracking_target(), user, track_asset ? "Assigned asset" : "Warrant subject")
	if(readout["signal"] != "ACQUIRED")
		. += span_warning("No authorized signal detected.")
	else if(!readout["same_level"])
		. += span_notice("Remote signal: [readout["label"]] is on z-level [readout["sector"]]. Consult your uplink for live tracking.")
	else
		. += span_notice("[readout["label"]] signal acquired on this z-level.")

/obj/effect/landmark/ccpost_gorlex_director/proc/can_recall(mob/user, allow_pending = FALSE)
	if(!black_warrant || !refresh_warrant_target() || !user || !get_turf(user) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_INCAPACITATED) || is_station_level(user.z) || user.mind != enforcer_mind || enforcer_recalled || enforcer_forced_pending || enforcer_forced_withdrawal || (enforcer_mission_deadline && world.time >= enforcer_mission_deadline))
		return FALSE
	var/datum/antagonist/ccpost_cybersun/enforcer = user.mind?.has_antag_datum(/datum/antagonist/ccpost_cybersun)
	return enforcer && (allow_pending || !enforcer.recall_pending) && holds_contract_asset(user)

/obj/effect/landmark/ccpost_gorlex_director/proc/recall_still_valid(mob/living/user, turf/start_turf, atom/start_loc)
	return !QDELETED(src) && !QDELETED(user) && get_turf(user) == start_turf && user.loc == start_loc && can_recall(user, TRUE)

/obj/effect/landmark/ccpost_gorlex_director/proc/request_recall(mob/living/user)
	if(!can_recall(user))
		to_chat(user, span_warning("CYBERSUN: Recall denied. Terminate the warrant subject and secure the original assigned asset."))
		return FALSE
	var/datum/antagonist/ccpost_cybersun/enforcer = user.mind.has_antag_datum(/datum/antagonist/ccpost_cybersun)
	enforcer.recall_pending = TRUE
	INVOKE_ASYNC(src, PROC_REF(perform_recall), user, enforcer)
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/perform_recall(mob/living/user, datum/antagonist/ccpost_cybersun/enforcer)
	to_chat(user, span_notice("CYBERSUN: Bluespace recall preparing. Remain stationary for 15 seconds."))
	var/turf/start_turf = get_turf(user)
	var/atom/start_loc = user.loc
	var/obj/effect/ccpost_recall_charge/charge = new(start_turf, user)
	manual_charge_ref = WEAKREF(charge)
	var/success = do_after(user, CCPOST_CYBERSUN_RECALL_TIME, target = user, timed_action_flags = IGNORE_SLOWDOWNS | IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(recall_still_valid), user, start_turf, start_loc))
	if(!QDELETED(charge))
		qdel(charge)
	manual_charge_ref = null
	if(!QDELETED(enforcer))
		enforcer.recall_pending = FALSE
	if(!success || QDELETED(src) || QDELETED(user) || !recall_still_valid(user, start_turf, start_loc))
		if(!QDELETED(user) && !enforcer_forced_pending && !enforcer_forced_withdrawal)
			to_chat(user, span_warning("CYBERSUN: Recall interrupted or authorization lost."))
			if(user.stat != DEAD)
				playsound(user, 'sound/machines/terminal/terminal_error.ogg', 35, FALSE, -3, pressure_affected = FALSE)
		return
	cybersun_recovered = TRUE
	enforcer_recalled = TRUE
	enforcer.withdrawal_identity = ccpost_withdrawal_identity(user, "recall")
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(start_turf)
	playsound(start_turf, SFX_PORTAL_ENTER, 60, TRUE, pressure_affected = FALSE)
	// Recovery and recall complete together; one cue avoids overlapping sounds.
	ccpost_objective_feedback(user)
	to_chat(user, span_boldnotice("CYBERSUN: Authorized recall complete."))
	log_game("Operation Severance: Cybersun recall complete for [key_name(user)].")
	qdel(contract_asset())
	ccpost_remove_withdrawn_body(user)

/obj/effect/ccpost_recall_charge
	name = "bluespace recall field"
	icon = 'icons/obj/supplypods_32x32.dmi'
	icon_state = "LZ"
	color = "#78AFFF"
	anchored = TRUE
	alpha = 100
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/datum/weakref/subject_ref
	var/obj/effect/ccpost_recall_aura/aura
	/// One reserved channel per charge, so stopping recall silences only its own audio.
	var/charge_audio_channel
	var/list/charge_audio_clients = list()
	var/charge_audio_timer
	var/short_charge_audio = FALSE

/obj/effect/ccpost_recall_charge/Initialize(mapload, mob/living/subject, forced = FALSE)
	. = ..()
	if(!subject || QDELETED(subject))
		return INITIALIZE_HINT_QDEL
	subject_ref = WEAKREF(subject)
	aura = new(null)
	subject.vis_contents += aura
	set_light(l_outer_range = 2, l_power = 0.6, l_color = "#75BFFF")
	short_charge_audio = forced
	charge_audio_channel = SSsounds.reserve_sound_channel()
	if(charge_audio_channel)
		advance_charge_audio(0)
	if(forced)
		animate(src, alpha = 255, transform = matrix().Scale(1.4), time = CCPOST_CYBERSUN_FORCED_RECALL_TIME)
		animate(aura, alpha = 255, transform = matrix().Scale(1.4), time = CCPOST_CYBERSUN_FORCED_RECALL_TIME)
		QDEL_IN(src, CCPOST_CYBERSUN_FORCED_RECALL_TIME + 2 SECONDS)
		return
	// A steady ground pulse and a body-attached energy field share the recall timer.
	animate(src, alpha = 190, transform = matrix().Scale(1.12), time = 2 SECONDS)
	animate(alpha = 100, transform = matrix(), time = 2 SECONDS)
	animate(alpha = 210, transform = matrix().Scale(1.2), time = 2 SECONDS)
	animate(alpha = 120, transform = matrix(), time = 2 SECONDS)
	animate(alpha = 230, transform = matrix().Scale(1.25), time = 2 SECONDS)
	animate(alpha = 150, transform = matrix(), time = 1 SECONDS)
	animate(alpha = 240, transform = matrix().Scale(1.3), time = 1 SECONDS)
	animate(alpha = 160, transform = matrix(), time = 1 SECONDS)
	animate(alpha = 255, transform = matrix().Scale(1.4), time = 2 SECONDS)
	aura.begin_charge()
	QDEL_IN(src, CCPOST_CYBERSUN_RECALL_TIME + 2 SECONDS)

/// Play the next short phase on the same channel; track clients even if their body changes.
/obj/effect/ccpost_recall_charge/proc/play_charge_audio(sound_file, volume, pitch = 1)
	var/mob/living/subject = subject_ref?.resolve()
	if(!charge_audio_channel || !subject || QDELETED(subject) || subject.stat == DEAD || !get_turf(subject))
		return FALSE
	clear_charge_listeners()
	// The field is audible in a small radius, including through the wearer's sealed suit in vacuum.
	var/list/hearers = playsound(subject, sound_file, volume, TRUE, -3, frequency = pitch, channel = charge_audio_channel, pressure_affected = FALSE, falloff_distance = 1, use_reverb = FALSE, mixer_channel = CHANNEL_SOUND_EFFECTS)
	for(var/mob/hearer as anything in hearers)
		if(hearer?.client)
			charge_audio_clients |= hearer.client
	if(subject.client && !(subject.client in charge_audio_clients))
		subject.playsound_local(get_turf(subject), sound_file, volume, TRUE, pitch, channel = charge_audio_channel, pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_SOUND_EFFECTS)
		charge_audio_clients |= subject.client
	return TRUE

/obj/effect/ccpost_recall_charge/proc/clear_charge_listeners()
	if(charge_audio_channel)
		for(var/client/listener as anything in charge_audio_clients)
			if(listener?.mob)
				listener.mob.stop_sound_channel(charge_audio_channel)
	charge_audio_clients.Cut()

/// Manual: 0, 1, 6, 11 and 13.5 seconds. Forced: 0 and 0.5 seconds.
/obj/effect/ccpost_recall_charge/proc/advance_charge_audio(stage)
	charge_audio_timer = null
	if(QDELETED(src) || !charge_audio_channel)
		return
	var/next_delay = 0
	switch(stage)
		if(0)
			if(!play_charge_audio('sound/machines/beep/twobeep.ogg', 30))
				return
			next_delay = short_charge_audio ? 0.5 SECONDS : 1 SECONDS
		if(1)
			if(!play_charge_audio('sound/effects/magic/lightning_chargeup.ogg', short_charge_audio ? 52 : 30, short_charge_audio ? 1.25 : 0.85))
				return
			if(!short_charge_audio)
				next_delay = 5 SECONDS
		if(2)
			if(!play_charge_audio('sound/effects/magic/lightning_chargeup.ogg', 40, 1))
				return
			next_delay = 5 SECONDS
		if(3)
			if(!play_charge_audio('sound/effects/magic/lightning_chargeup.ogg', 52, 1.2))
				return
			next_delay = 2.5 SECONDS
		if(4)
			play_charge_audio('sound/machines/terminal/terminal_prompt_confirm.ogg', 40)
	if(next_delay)
		charge_audio_timer = addtimer(CALLBACK(src, PROC_REF(advance_charge_audio), stage + 1), next_delay, TIMER_STOPPABLE)

/obj/effect/ccpost_recall_charge/Destroy()
	if(charge_audio_timer)
		deltimer(charge_audio_timer)
		charge_audio_timer = null
	clear_charge_listeners()
	if(charge_audio_channel)
		SSsounds.free_sound_channel(charge_audio_channel)
		charge_audio_channel = null
	var/mob/living/subject = subject_ref?.resolve()
	if(subject && aura)
		subject.vis_contents -= aura
	QDEL_NULL(aura)
	return ..()

/obj/effect/ccpost_recall_aura
	name = "bluespace distortion"
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "teleport"
	color = "#91D5FF"
	alpha = 35
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	vis_flags = VIS_INHERIT_PLANE

/obj/effect/ccpost_recall_aura/proc/begin_charge()
	// No change to the wearer's alpha, color or transform (including MODsuit overlays).
	animate(src, alpha = 120, transform = matrix().Scale(1.12), time = 2 SECONDS)
	animate(alpha = 65, transform = matrix(), time = 2 SECONDS)
	animate(alpha = 155, transform = matrix().Scale(1.18), time = 2 SECONDS)
	animate(alpha = 85, transform = matrix(), time = 2 SECONDS)
	animate(alpha = 190, transform = matrix().Scale(1.24), time = 2 SECONDS)
	animate(alpha = 110, transform = matrix(), time = 1 SECONDS)
	animate(alpha = 215, transform = matrix().Scale(1.3), time = 1 SECONDS)
	animate(alpha = 140, transform = matrix(), time = 1 SECONDS)
	animate(alpha = 255, transform = matrix().Scale(1.4), time = 2 SECONDS)




// Corporate pursuit and contractual failsafe.
/obj/effect/landmark/ccpost_gorlex_director/proc/can_recruit_enforcer()
	return black_warrant && !enforcer_mind && implant_deadline && world.time < implant_deadline

/obj/effect/landmark/ccpost_gorlex_director/proc/start_enforcer_timer(mob/living/enforcer)
	if(enforcer_mission_deadline || !enforcer || enforcer.mind != enforcer_mind)
		return
	enforcer_mission_deadline = world.time + CCPOST_CYBERSUN_MISSION_TIME
	addtimer(CALLBACK(src, PROC_REF(expire_enforcer_mission)), CCPOST_CYBERSUN_MISSION_TIME)
	to_chat(enforcer, span_boldnotice("CYBERSUN: Operational authorization granted for [CCPOST_CYBERSUN_MISSION_TIME / (1 MINUTES)] minutes. Complete your directives and recall before expiration."))

/// Retain the original object even when the carrier is gibbed or removed. No replacement cartridge is created.
/obj/effect/landmark/ccpost_gorlex_director/proc/release_contract_asset(mob/living/carrier)
	var/obj/item/asset = contract_asset()
	if(!carrier || !asset || QDELETED(asset) || gorlex_victory || cybersun_recovered)
		return
	var/atom/container = asset.loc
	while(container && !isturf(container) && container != carrier)
		container = container.loc
	if(container != carrier)
		return
	var/turf/drop_turf = get_turf(carrier)
	if(!drop_turf || is_station_level(drop_turf.z))
		drop_turf = (contract_kind == "prototype" ? last_valid_prototype_turf : last_valid_cartridge_turf)
	if(!drop_turf || is_station_level(drop_turf.z))
		drop_turf = get_return_turf()
	if(!drop_turf)
		return
	if(asset.loc == carrier)
		carrier.dropItemToGround(asset, force = TRUE)
	if(asset.loc != drop_turf)
		asset.forceMove(drop_turf)

/// Native microbomb behavior, with the contract's cartridge protected before its explosion.
/obj/item/implant/explosive/ccpost
	name = "microbomb implant"

/obj/item/implant/explosive/ccpost/activate(cause)
	if(!cause || !imp_in || active || QDELETED(src))
		return FALSE
	if(locate(/obj/item/implant/fakemacro) in imp_in.implants)
		return FALSE
	if(cause == "death" && HAS_TRAIT(imp_in, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION))
		return FALSE
	// Preserve the native confirmation; release only after the operator confirms.
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/mob/living/subject = imp_in
		var/response = tgui_alert(subject, "Are you sure you want to activate your [name]? This will cause you to explode!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes" || QDELETED(src) || QDELETED(subject) || imp_in != subject || active)
			return FALSE
		cause = "confirmed manual activation"
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director)
		director.release_contract_asset(imp_in)
	return ..(cause)

/obj/item/implant/explosive/ccpost/gorlex
	name = "microbomb implant"

/proc/ccpost_install_microbomb(mob/living/subject, gorlex_failsafe = FALSE)
	if(!subject || QDELETED(subject))
		return
	var/obj/item/implant/explosive/existing = locate(/obj/item/implant/explosive) in subject.implants
	if(existing)
		return existing
	var/obj/item/implant/explosive/ccpost/microbomb
	if(gorlex_failsafe)
		microbomb = new /obj/item/implant/explosive/ccpost/gorlex(subject)
	else
		microbomb = new /obj/item/implant/explosive/ccpost(subject)
	if(!microbomb.implant(subject, silent = TRUE, force = TRUE))
		qdel(microbomb)
		return
	return microbomb

/obj/effect/landmark/ccpost_gorlex_director/proc/process_pursuit()
	var/datum/mind/contract_mind = operative_mind_ref?.resolve()
	var/mob/living/operative = contract_mind?.current
	if(isliving(operative) && !QDELETED(operative) && operative.stat != DEAD && !implant_detonated && implant_deadline)
		// The contractual failsafe belongs to the mind. Surgery or body replacement cannot disarm it.
		ccpost_install_microbomb(operative, TRUE)
		var/remaining = max(0, implant_deadline - world.time)
		for(var/threshold in list(10 MINUTES, 5 MINUTES, 1 MINUTES, 30 SECONDS, 10 SECONDS))
			if(last_implant_remaining > threshold && remaining <= threshold)
				to_chat(operative, span_bolddanger("CYBERSUN: Corporate failsafe detonation in [round(remaining / 10)] seconds."))
		last_implant_remaining = remaining
		if(remaining > 0 && remaining <= 10 SECONDS)
			start_failsafe_beeps()
		if(!remaining)
			expire_failsafe()
	var/mob/living/enforcer = enforcer_mind?.current
	if(isliving(enforcer) && !QDELETED(enforcer) && enforcer.stat != DEAD && enforcer_mission_deadline && !enforcer_recalled && !enforcer_forced_withdrawal && !enforcer_forced_pending)
		var/enforcer_remaining = max(0, enforcer_mission_deadline - world.time)
		for(var/threshold in list(10 MINUTES, 5 MINUTES, 1 MINUTES, 30 SECONDS, 10 SECONDS))
			if(last_enforcer_remaining > threshold && enforcer_remaining <= threshold)
				to_chat(enforcer, span_warning("CYBERSUN: Operational authorization expires in [round(enforcer_remaining / 10)] seconds."))
		last_enforcer_remaining = enforcer_remaining
		if(!enforcer_remaining)
			expire_enforcer_mission()

/obj/effect/landmark/ccpost_gorlex_director/proc/start_failsafe_beeps()
	if(failsafe_beeps_started || implant_detonated || !implant_deadline || world.time >= implant_deadline || implant_deadline - world.time > 10 SECONDS)
		return
	failsafe_beeps_started = TRUE
	failsafe_beep()

/obj/effect/landmark/ccpost_gorlex_director/proc/failsafe_beep()
	if(!black_warrant || !implant_deadline || implant_detonated || world.time >= implant_deadline)
		return
	var/datum/mind/contract_mind = operative_mind_ref?.resolve()
	var/mob/living/operative = contract_mind?.current
	var/remaining = implant_deadline - world.time
	if(isliving(operative) && !QDELETED(operative) && operative.stat != DEAD)
		playsound(operative, 'sound/items/timer.ogg', remaining <= 5 SECONDS ? 55 : 35, FALSE, -2, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(failsafe_beep)), remaining <= 5 SECONDS ? 0.5 SECONDS : 1 SECONDS)

/obj/effect/landmark/ccpost_gorlex_director/proc/expire_failsafe()
	if(!black_warrant || !implant_deadline || implant_detonated || world.time < implant_deadline)
		return
	var/datum/mind/contract_mind = operative_mind_ref?.resolve()
	var/mob/living/operative = contract_mind?.current
	if(!isliving(operative) || QDELETED(operative) || operative.stat == DEAD)
		return
	var/obj/item/implant/explosive/microbomb = ccpost_install_microbomb(operative, TRUE)
	if(!microbomb || QDELETED(microbomb))
		return
	// A fake macrobomb cannot veto a remote contractual detonation.
	for(var/obj/item/implant/fakemacro/fake in operative.implants)
		qdel(fake)
	if(microbomb.active)
		return // An already activated native implant owns this detonation.
	implant_detonated = TRUE
	warrant_target_dead = TRUE
	microbomb.delay = 0
	microbomb.instant_explosion = TRUE
	release_contract_asset(operative)
	to_chat(operative, span_bolddanger("CYBERSUN: Corporate failsafe detonation authorized."))
	microbomb.activate("corporate failsafe")

/obj/effect/landmark/ccpost_gorlex_director/proc/expire_enforcer_mission()
	if(!enforcer_mission_deadline || world.time < enforcer_mission_deadline || enforcer_recalled || enforcer_forced_withdrawal || enforcer_forced_pending)
		return
	var/mob/living/enforcer = enforcer_mind?.current
	if(!isliving(enforcer) || QDELETED(enforcer) || enforcer.stat == DEAD || !get_turf(enforcer))
		return
	enforcer_forced_pending = TRUE
	// Freeze eligibility at expiration, not at the end of the three-second visual.
	enforcer_termination_at_withdrawal = refresh_warrant_target()
	if(enforcer_termination_at_withdrawal && !enforcer_termination_cue_sent)
		enforcer_termination_cue_sent = TRUE
		ccpost_objective_feedback(enforcer)
	enforcer_recovery_at_expiry = enforcer_termination_at_withdrawal && holds_contract_asset(enforcer)
	var/obj/effect/ccpost_recall_charge/old_charge = manual_charge_ref?.resolve()
	if(old_charge)
		qdel(old_charge)
	to_chat(enforcer, span_bolddanger("CYBERSUN: Authorization expired. Compulsory bluespace withdrawal initiated."))
	var/obj/effect/ccpost_recall_charge/charge = new(get_turf(enforcer), enforcer, TRUE)
	forced_charge_ref = WEAKREF(charge)
	addtimer(CALLBACK(src, PROC_REF(finish_forced_recall)), CCPOST_CYBERSUN_FORCED_RECALL_TIME)

/obj/effect/landmark/ccpost_gorlex_director/proc/finish_forced_recall()
	var/obj/effect/ccpost_recall_charge/charge = forced_charge_ref?.resolve()
	if(charge)
		qdel(charge)
	forced_charge_ref = null
	if(!enforcer_forced_pending || enforcer_recalled || enforcer_forced_withdrawal)
		return
	enforcer_forced_pending = FALSE
	var/mob/living/enforcer = enforcer_mind?.current
	if(!isliving(enforcer) || QDELETED(enforcer) || enforcer.stat == DEAD || !get_turf(enforcer))
		return
	var/datum/antagonist/ccpost_cybersun/antag = enforcer_mind.has_antag_datum(/datum/antagonist/ccpost_cybersun)
	if(!antag)
		return
	var/turf/landing = get_turf(enforcer)
	// Recovery can be credited only if both directives were met. Forced recall never fulfills recall itself.
	if(enforcer_recovery_at_expiry && holds_contract_asset(enforcer))
		cybersun_recovered = TRUE
		ccpost_objective_feedback(enforcer)
		qdel(contract_asset())
	else
		release_contract_asset(enforcer)
	enforcer_forced_withdrawal = TRUE
	antag.recall_pending = FALSE
	antag.withdrawal_identity = "[ccpost_roundend_identity(enforcer.mind, "Cybersun Enforcer")] through compulsory bluespace withdrawal."
	new /obj/effect/temp_visual/teleport_abductor/syndi_teleporter(landing)
	playsound(landing, SFX_PORTAL_ENTER, 60, TRUE, pressure_affected = FALSE)
	to_chat(enforcer, span_boldnotice("CYBERSUN: Compulsory withdrawal complete. Black Warrant unfulfilled."))
	log_game("Operation Severance: compulsory Cybersun withdrawal for [key_name(enforcer)].")
	ccpost_remove_withdrawn_body(enforcer)

#undef CCPOST_GORLEX_FAILSAFE_TIME
#undef CCPOST_CYBERSUN_MISSION_TIME
#undef CCPOST_CYBERSUN_FORCED_RECALL_TIME
#undef CCPOST_GORLEX_EXTRACTION_TIME
#undef CCPOST_GORLEX_WARRANT_GRACE
#undef CCPOST_CYBERSUN_RECALL_TIME
#undef CCPOST_GORLEX_OPERATION_RADIUS
#undef CCPOST_GORLEX_TC
#undef CCPOST_CYBERSUN_TC
#undef CCPOST_GORLEX_NEGLECT_WINDOW
#undef CCPOST_GORLEX_NEGLECT_ESCALATION
#undef CCPOST_GORLEX_NEGLECT_MAX
#undef CCPOST_GORLEX_FIRST_GUARDED_CHECK
#undef CCPOST_GORLEX_ROLL_COOLDOWN
#undef CCPOST_GORLEX_MAX_GUARDED_ROLLS
#undef CCPOST_GORLEX_RECRUITMENT_RETRY_DELAY
#undef CCPOST_GORLEX_PREPARATION_TIME
#undef CCPOST_GORLEX_MAX_RECRUITMENT_ATTEMPTS
#undef CCPOST_GORLEX_SECURITY_POLL
#undef CCPOST_GORLEX_PROTOTYPE_NEGLECT
#undef CCPOST_GORLEX_PROTOTYPE_ESCALATION

#undef CCPOST_GORLEX_PLASTIC_LIMIT
#undef CCPOST_CYBERSUN_RETRY_DELAY

// Admin-only native event controls. No storyteller track; natural recruitment remains director-owned.
/datum/round_event_control/ccpost_gorlex_deployment
	name = "Operation Severance: Gorlex Deployment"
	description = "Initiates Gorlex recruitment at an operational Liaison Outpost after a two-minute security advisory window, bypassing automatic deployment rolls and staffing."
	typepath = /datum/round_event/ccpost_gorlex_deployment
	track = null
	max_occurrences = 0

/datum/round_event/ccpost_gorlex_deployment
	fakeable = FALSE
	announce_when = -1
	end_when = 1

/datum/round_event/ccpost_gorlex_deployment/start()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(QDELETED(director) || !director.start_gorlex_poll(TRUE))
		message_admins("Operation Severance: Gorlex deployment unavailable (outpost, disk, insertion or existing contract/poll).")
		return
	message_admins("Operation Severance: Gorlex recruitment initiated by event trigger (first poll follows the two-minute advisory window).")

/datum/round_event_control/ccpost_cybersun_intervention
	name = "Operation Severance: Cybersun Intervention"
	description = "Polls for a Cybersun Enforcer when a valid Black Warrant is active."
	typepath = /datum/round_event/ccpost_cybersun_intervention
	track = null
	max_occurrences = 0

/datum/round_event/ccpost_cybersun_intervention
	fakeable = FALSE
	announce_when = -1
	end_when = 1

/datum/round_event/ccpost_cybersun_intervention/start()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(QDELETED(director) || GLOB.ccpost_outpost_signal_lost || !director.can_recruit_enforcer() || director.enforcer_poll_active || !director.pick_landing(GLOB.ccpost_cybersun_insertions, TRUE))
		message_admins("Operation Severance: Cybersun intervention unavailable (active warrant and eligible insertion required; no duplicate polls).")
		return
	INVOKE_ASYNC(director, TYPE_PROC_REF(/obj/effect/landmark/ccpost_gorlex_director, poll_enforcers))
	message_admins("Operation Severance: Cybersun recruitment initiated by event trigger.")
