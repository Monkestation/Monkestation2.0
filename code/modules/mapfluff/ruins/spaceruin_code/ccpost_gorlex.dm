/*
 * Central Command Liaison Outpost - Operation Severance
 * All Gorlex event, antagonist, armament and field-requisition code is here.
 * Does not inherit normal nuclear-operative teams, uplinks or station victory.
 * Map owner places the director, insertion, disk return and retrieval/deployment landmarks.
 */

#define CCPOST_GORLEX_TC 18
#define CCPOST_CYBERSUN_TC 12
#define CCPOST_GORLEX_FIRST_CHECK (15 MINUTES)
#define CCPOST_GORLEX_CHECK_INTERVAL (10 MINUTES)
#define CCPOST_GORLEX_PLASTIC_LIMIT 4
#define CCPOST_CYBERSUN_RETRY_DELAY (5 MINUTES)
#define CCPOST_GORLEX_SECURITY_POLL (5 SECONDS)

GLOBAL_VAR_INIT(ccpost_gorlex_director, null)
GLOBAL_LIST_EMPTY(ccpost_gorlex_disk_returns)
GLOBAL_LIST_EMPTY(ccpost_gorlex_insertions)
GLOBAL_LIST_EMPTY(ccpost_gorlex_extraction_landmarks)
GLOBAL_LIST_EMPTY(ccpost_cybersun_insertions)

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
	var/next_event_check = 0
	var/event_started = FALSE
	var/polling_ghosts = FALSE
	var/armed_by_gorlex = FALSE
	/// Classified records were fully copied from the Central Command Tasking Server.
	var/data_downloaded = FALSE
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
	STOP_PROCESSING(SSobj, src)
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
		if(QDELETED(person) || person.stat == DEAD || !person.client || !person.mind)
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

/// Reset the entire neglect window whenever staffing or disk security is restored.
/obj/effect/landmark/ccpost_gorlex_director/proc/reset_neglect()
	unsecured_since = 0
	next_event_check = 0

/// Shared predicate for the scheduled roll and the end of a recruitment poll.
/obj/effect/landmark/ccpost_gorlex_director/proc/neglect_eligible(obj/item/disk/nuclear/ccpost_nuke/disk)
	if(GLOB.ccpost_outpost_signal_lost || active_outpost_personnel() < 2 || !disk || QDELETED(disk))
		return FALSE
	var/turf/current_location = get_turf(disk)
	return current_location && istype(get_area(current_location), /area/ruin/space/has_grav/ccpost) && !disk_is_actively_guarded(disk)

/obj/effect/landmark/ccpost_gorlex_director/process(seconds_per_tick)
	// Keep the stolen cartridge off the main station even after deployment.
	if(world.time >= last_cartridge_scan + CCPOST_GORLEX_SECURITY_POLL)
		last_cartridge_scan = world.time
		var/obj/item/ccpost_classified_cartridge/contract_cartridge = data_cartridge_ref?.resolve()
		if(contract_cartridge)
			secure_cartridge(contract_cartridge)
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
	if(!neglect_eligible(disk))
		reset_neglect()
		return
	if(!unsecured_since)
		unsecured_since = world.time
		next_event_check = unsecured_since + CCPOST_GORLEX_FIRST_CHECK
	if(polling_ghosts || world.time < next_event_check)
		return
	// First roll at 15 minutes, then every ten minutes; cap at 40%.
	next_event_check = world.time + CCPOST_GORLEX_CHECK_INTERVAL
	var/neglect_minutes = (world.time - unsecured_since) / (1 MINUTES)
	var/chance = neglect_minutes >= 25 ? 40 : 15
	if(prob(chance) && length(GLOB.ccpost_gorlex_insertions))
		start_gorlex_poll()

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

/// Shared entry point; lock before scheduling so two requests cannot start two polls.
/obj/effect/landmark/ccpost_gorlex_director/proc/start_gorlex_poll(admin_forced = FALSE)
	if(event_started || polling_ghosts || GLOB.ccpost_outpost_signal_lost || !pick_landing(GLOB.ccpost_gorlex_insertions, TRUE))
		return FALSE
	if(!get_disk() || (!admin_forced && (!neglect_eligible(get_disk()) || !unsecured_since || world.time - unsecured_since < CCPOST_GORLEX_FIRST_CHECK)))
		return FALSE
	polling_ghosts = TRUE
	INVOKE_ASYNC(src, PROC_REF(poll_and_deploy), admin_forced)
	return TRUE

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
	polling_ghosts = FALSE
	if(QDELETED(src) || event_started || GLOB.ccpost_outpost_signal_lost || !length(candidates))
		return
	if(!get_disk() || (!admin_forced && (!neglect_eligible(get_disk()) || !unsecured_since || world.time - unsecured_since < CCPOST_GORLEX_FIRST_CHECK)))
		return
	var/turf/T = pick_landing(GLOB.ccpost_gorlex_insertions, TRUE)
	if(!T)
		log_game("CCPost Gorlex: no eligible insertion landmark; poll ended without deployment.")
		return
	var/mob/dead/observer/selected = pick(candidates)
	if(!selected?.client || !selected.key)
		return
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
		return
	event_started = TRUE
	operative_ref = WEAKREF(operative)
	operative_mind_ref = WEAKREF(operative_mind)
	operative_mind.add_antag_datum(/datum/antagonist/ccpost_gorlex)
	message_admins("[ADMIN_LOOKUPFLW(operative)] has accepted Operation Severance.")
	log_game("CCPost Gorlex: Operation Severance operative deployed at [AREACOORD(T)].")

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

/// Private feedback works in vacuum and never broadcasts the operative's position.
/proc/ccpost_private_feedback(mob/recipient, sound_file, volume = 35)
	if(!recipient?.client || QDELETED(recipient))
		return
	recipient.playsound_local(null, sound_file, volume, FALSE, pressure_affected = FALSE, use_reverb = FALSE, mixer_channel = CHANNEL_SOUND_EFFECTS)

/proc/ccpost_objective_feedback(mob/recipient)
	ccpost_private_feedback(recipient, 'sound/effects/achievement/beeps_jingle.ogg', 50)

/obj/effect/landmark/ccpost_gorlex_director/proc/note_data_downloaded(datum/mind/downloader, obj/item/ccpost_classified_cartridge/cartridge)
	if(data_downloaded || !downloader || !cartridge || data_cartridge_ref?.resolve() != cartridge)
		return FALSE
	var/mob/living/operative = operative_ref?.resolve()
	if(!operative || operative.mind != downloader)
		return FALSE
	data_downloaded = TRUE
	data_cartridge_ref = WEAKREF(cartridge)
	ccpost_objective_feedback(operative)
	to_chat(operative, span_boldnotice("GORLEX MARAUDERS: Classified tasking data acquired. Retain the physical cartridge and proceed with NT-ADP-7 authorization."))
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

// Genuine objective datums power the antagonist HUD and the round-end report.
// The four objectives are tracked independently by the event director.
/datum/objective/ccpost_gorlex_data
	name = "classified intelligence acquisition"
	explanation_text = "Download classified Central Command Tasking Server records to the physical encrypted data cartridge."

/datum/objective/ccpost_gorlex_data/check_completion()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	return director && director.data_downloaded

/datum/objective/ccpost_gorlex_arm
	name = "NT-ADP-7 authorization"
	explanation_text = "Acquire the NT-ADP-7 disk and authorization code, then arm the Asset Denial Device."

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
	var/datum/objective/ccpost_gorlex_data/steal = new
	steal.owner = owner
	objectives += steal
	var/datum/objective/ccpost_gorlex_arm/arm = new
	arm.owner = owner
	objectives += arm
	var/datum/objective/ccpost_gorlex_extract/escape = new
	escape.owner = owner
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
		director.release_contract_cartridge(operative)
		if(director.black_warrant)
			director.warrant_target_dead = TRUE

/datum/antagonist/ccpost_gorlex/greet()
	. = ..() // Native antagonist greeting plays stinger_sound privately.
	to_chat(owner.current, span_boldwarning("GORLEX MARAUDERS // OPERATION SEVERANCE"))
	to_chat(owner.current, span_boldnotice("Cybersun Industries has authorized your deployment under Operation Severance."))
	to_chat(owner.current, span_notice("Infiltrate the Liaison Outpost, recover its classified Tasking Server data, arm NT-ADP-7 and complete authorized retrieval."))
	to_chat(owner.current, span_notice("Your contract requires extraction with the intelligence. Unauthorized withdrawal after data acquisition constitutes desertion."))
	to_chat(owner.current, span_boldnotice("Consult your Gorlex Marauders uplink for contract details, field requisitions and extraction instructions."))
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
	if(director?.warrant_deadline && director.operative_ref?.resolve() == operative && director.is_authorized_contract_turf(get_turf(operative)))
		director.rescind_warrant_warning(operative)
	if(!operative || !get_turf(operative) || !is_station_level(operative.z))
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

/datum/outfit/ccpost_gorlex
	name = "Gorlex Marauders Field Operative"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	mask = /obj/item/clothing/mask/gas/syndicate
	id = /obj/item/card/id/advanced/chameleon
	back = /obj/item/mod/control/pre_equipped/ccpost_gorlex
	belt = /obj/item/storage/belt/military
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = ITEM_SLOT_RPOCKET
	l_pocket = /obj/item/pinpointer/ccpost_adp7/syndicate
	r_hand = /obj/item/gun/energy/modular_laser_rifle/carbine
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
	var/obj/item/ccpost_classified_cartridge/cartridge = new(operative)
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director && operative.mind && director.operative_mind_ref?.resolve() == operative.mind && director.operative_ref?.resolve() == operative && !director.data_cartridge_ref)
		director.data_cartridge_ref = WEAKREF(cartridge)
		director.last_valid_cartridge_turf = get_turf(operative)
	ccpost_issue_gear(operative, cartridge)
	var/obj/item/ccpost_gorlex_uplink/uplink = new(operative)
	uplink.owner_mind = operative.mind
	ccpost_issue_gear(operative, uplink)
	ccpost_install_microbomb(operative, TRUE)
	for(var/path in list(/obj/item/grenade/empgrenade, /obj/item/grenade/smokebomb))
		var/obj/item/supply = new path(operative)
		ccpost_issue_gear(operative, supply, prefer_belt = TRUE)
	for(var/path in list(/obj/item/organ/internal/cyberimp/brain/anti_stun/syndicate, /obj/item/organ/internal/cyberimp/eyes/hud/medical, /obj/item/organ/internal/cyberimp/mouth/breathing_tube))
		ccpost_install_augment(operative, path)
	ccpost_prepare_mod(operative)
	var/obj/item/radio/radio = operative.ears
	if(radio)
		radio.set_frequency(FREQ_SYNDICATE)

/obj/item/mod/control/pre_equipped/ccpost_gorlex
	name = "Gorlex field operations MODsuit"
	desc = "An EVA-capable field suit with standardized Syndicate hardpoints."
	theme = /datum/mod_theme/syndicate
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/emp_shield,
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
	var/telecrystals = CCPOST_GORLEX_TC
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
/obj/item/ccpost_gorlex_uplink/proc/catalogue()
	return list(
		"jammer" = list("Infiltration", "Radio Jammer", "Local radio interference.", 2, 1, /obj/item/jammer, 1),
		"chameleon" = list("Infiltration", "Chameleon Kit", "Disguise clothing and accessories.", 2, 1, /obj/item/storage/box/syndie_kit/chameleon, 1),
		"doorjack" = list("Infiltration", "Airlock Authentication Override Card", "Airlock access bypass.", 3, 1, /obj/item/card/emag/doorjack, 1),
		"smoke" = list("Infiltration", "Smoke Package", "Two smoke grenades.", 2, 2, /obj/item/grenade/smokebomb, 2),
		"emp_grenade" = list("Infiltration", "EMP Grenade", "Electronic disruption.", 3, 2, /obj/item/grenade/empgrenade, 1),
		"cloak" = list("Infiltration", "Prototype Cloaking Module", "Concealment; high power drain.", 7, 1, /obj/item/mod/module/stealth, 1),

		"pistol" = list("Armaments", "Ansem Pistol", "10mm sidearm; accepts a suppressor.", 4, 1, /obj/item/gun/ballistic/automatic/pistol/clandestine, 1),
		"pistol_mag" = list("Armaments", "10mm Magazine", "Ammunition for the Ansem pistol.", 2, 2, /obj/item/ammo_box/magazine/m10mm, 1),
		"suppressor" = list("Armaments", "Suppressor", "Suppresses compatible firearms, including Ansem.", 1, 1, /obj/item/suppressor, 1),
		"shotgun" = list("Armaments", "Compact Combat Shotgun", "Semi-automatic close-quarters weapon.", 8, 1, /obj/item/gun/ballistic/shotgun/automatic/combat/compact, 1),
		"shotgun_ammo" = list("Armaments", "Shotgun Slugs", "12-gauge ammunition for the combat shotgun.", 2, 2, /obj/item/ammo_box/advanced/s12gauge, 1),
		"edagger" = list("Armaments", "Energy Dagger", "Compact backup melee weapon.", 2, 1, /obj/item/pen/edagger, 1),
		"esword" = list("Armaments", "Energy Sword", "Close quarters armament.", 5, 1, /obj/item/melee/energy/sword, 1),
		"c4" = list("Sabotage", "C-4 Charge", "General demolition; shares stock with X-4.", 2, CCPOST_GORLEX_PLASTIC_LIMIT, /obj/item/grenade/c4, 1),
		"x4" = list("Sabotage", "X-4 Shaped Charge", "Directional breaching; shares stock with C-4.", 4, CCPOST_GORLEX_PLASTIC_LIMIT, /obj/item/grenade/c4/x4, 1),
		"toolbox" = list("Sabotage", "Syndicate Toolbox", "Field engineering tools.", 2, 1, /obj/item/storage/toolbox/syndicate, 1),
		"nodrop" = list("Cybernetics", "Anti-Drop Implant", "Weapon retention.", 3, 1, /obj/item/autosurgeon/syndicate/nodrop, 1),
		"reviver" = list("Cybernetics", "Reviver Implant", "Emergency medical recovery.", 6, 1, /obj/item/autosurgeon/syndicate/reviver, 1),
		"thermal" = list("Cybernetics", "Thermal Eyes", "Enhanced detection.", 6, 1, /obj/item/autosurgeon/syndicate/thermal_eyes, 1),
		"mantis" = list("Cybernetics", "Syndicate Mantis Blade", "Arm-mounted melee weapon.", 6, 1, /obj/item/autosurgeon/syndicate/syndie_mantis, 1),
		"cell" = list("MOD Systems", "Bluespace Power Cell", "Increased power endurance.", 4, 1, /obj/item/stock_parts/power_store/cell/bluespace, 1),
		"noslip" = list("MOD Systems", "Anti-Slip Module", "Prevents ordinary wet-floor slips.", 3, 1, /obj/item/mod/module/noslip, 1),
		"shield" = list("MOD Systems", "Energy Shield Module", "Three rechargeable attack-blocking charges.", 8, 1, /obj/item/mod/module/energy_shield, 1),
		"holster" = list("MOD Systems", "Holster Module", "Rapid weapon storage.", 2, 1, /obj/item/mod/module/holster, 1),
		"medkit" = list("Medical & Survival", "Combat Medical Kit", "Emergency treatment.", 3, 2, /obj/item/storage/medkit/combat, 1),
		"stimulant" = list("Medical & Survival", "Combat Stimulant Injector", "Short-term combat assistance.", 3, 1, /obj/item/reagent_containers/medipen/stimulants, 1),
		"oxygen" = list("Medical & Survival", "Spare Oxygen", "Extended EVA operation.", 1, 2, /obj/item/tank/internals/emergency_oxygen/engi, 1)
	)

/// The same authoritative stock calculation drives the UI and purchase validation.
/obj/item/ccpost_gorlex_uplink/proc/requisition_stock(id, list/entry)
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

/obj/item/ccpost_gorlex_uplink/ui_data(mob/user)
	if(!has_access(user))
		return list("authorized" = FALSE)
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
			"complexity" = module_complexity
		))
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	var/obj/item/ccpost_classified_cartridge/cartridge = director?.data_cartridge_ref?.resolve()
	var/datum/antagonist/ccpost_cybersun/enforcer = user.mind?.has_antag_datum(/datum/antagonist/ccpost_cybersun)
	var/list/stages = list(
		"data" = !!director?.data_downloaded,
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
		"telecrystals" = telecrystals,
		"catalogue" = requisitions_locked ? list() : items,
		"history" = purchase_history,
		"mission" = stages,
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
		"cartridge_held" = !!director?.holds_contract_cartridge(user),
		"recall_ready" = cybersun_brand && !!director?.can_recall(user),
		"cybersun_recovered" = !!director?.cybersun_recovered,
		"recalled" = !!(director && (user.mind == director.enforcer_mind && director.enforcer_recalled)),
		"recall_pending" = !!enforcer?.recall_pending
	)

/obj/item/ccpost_gorlex_uplink/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!(action in list("purchase", "request_extraction", "request_recall")))
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
	var/list/entries = catalogue()
	var/list/entry = entries[id]
	if(!islist(entry))
		return TRUE
	var/cost = entry[4]
	var/used = purchased[id] || 0
	if(cost > telecrystals || requisition_stock(id, entry) <= 0)
		return TRUE
	telecrystals -= cost
	purchased[id] = used + 1
	var/path = entry[6]
	var/amount = entry[7]
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

/obj/effect/landmark/ccpost_gorlex_director/proc/holds_contract_cartridge(mob/user)
	var/obj/item/ccpost_classified_cartridge/cartridge = data_cartridge_ref?.resolve()
	if(!user || !cartridge?.data_complete || QDELETED(cartridge))
		return FALSE
	var/atom/container = cartridge.loc
	while(container && !isturf(container))
		if(container == user)
			return TRUE
		if(ismob(container))
			return FALSE
		container = container.loc
	return FALSE

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
	return event_started && !black_warrant && !gorlex_victory && !extraction_deadline && !extraction_pod_ref?.resolve() && user && get_turf(user) && user.stat == CONSCIOUS && !HAS_TRAIT(user, TRAIT_INCAPACITATED) && user == operative_ref?.resolve() && user.mind == operative_mind_ref?.resolve() && user.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) && data_downloaded && nuke_ever_armed && holds_contract_cartridge(user) && is_operational_turf(get_turf(user))

/obj/effect/landmark/ccpost_gorlex_director/proc/request_extraction(mob/user)
	if(!can_request_extraction(user))
		to_chat(user, span_warning("GORLEX COMMAND: Retrieval authorization denied. Complete data acquisition and NT-ADP-7 authorization; retain the original cartridge."))
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
	if(!data_downloaded || black_warrant || gorlex_victory || !operative || QDELETED(operative) || operative.stat == DEAD)
		if(warrant_deadline)
			clear_warrant_warning()
		return
	var/turf/current = get_turf(operative)
	if(!current)
		if(warrant_deadline)
			clear_warrant_warning()
		return
	if(is_authorized_contract_turf(current))
		if(warrant_deadline)
			rescind_warrant_warning(operative)
		return
	if(!warrant_deadline)
		start_warrant_warning(operative)
	else if(world.time >= warrant_deadline)
		issue_black_warrant(operative)

/// The same operational area and retrieval transit rules govern the warning and its audio.
/obj/effect/landmark/ccpost_gorlex_director/proc/is_authorized_contract_turf(turf/current)
	if(!current)
		return FALSE
	if(is_operational_turf(current))
		return TRUE
	if(is_station_level(current.z))
		return FALSE
	// Retrieval extends authorization only to the selected landing area.
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
	if(black_warrant || gorlex_victory || !data_downloaded || !operative || QDELETED(operative) || operative.stat == DEAD || !current)
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
	if(black_warrant || gorlex_victory || !data_downloaded || !operative)
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
		"Accept a Cybersun Black Warrant? Eliminate [warrant_target_name] and recover classified intelligence.",
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
		to_chat(operative, span_boldnotice("GORLEX COMMAND: Retrieval pod landed at [AREACOORD(landing)]. Board with the classified cartridge."))

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
	. += span_notice("Use an empty hand on the boarding hatch to buckle in and depart. Only the designated Gorlex operative carrying the original completed cartridge may depart.")

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
	if(!user || !get_turf(user) || user != operative_ref?.resolve() || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_INCAPACITATED) || user.mind != operative_mind_ref?.resolve() || !user.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) || !user.Adjacent(pod) || black_warrant || gorlex_victory || extraction_pod_ref?.resolve() != pod || !holds_contract_cartridge(user) || extraction_status != "LANDED - BOARD POD" || extraction_departing || !pod.hatch_open)
		to_chat(user, span_warning("GORLEX RETRIEVAL: Boarding denied. Assigned operative and original completed cartridge required."))
		return FALSE
	if(!pod.buckle_mob(user, force = TRUE, check_loc = FALSE))
		return FALSE
	extraction_departing = TRUE
	extraction_status = "DEPARTING"
	INVOKE_ASYNC(src, PROC_REF(depart_retrieval), user, pod)
	return TRUE

/obj/effect/landmark/ccpost_gorlex_director/proc/depart_retrieval(mob/living/user, obj/structure/ccpost_gorlex_retrieval_pod/pod)
	if(!do_after(user, 2 SECONDS, target = pod, timed_action_flags = IGNORE_HELD_ITEM|IGNORE_SLOWDOWNS) || QDELETED(pod) || QDELETED(user) || user.buckled != pod || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_INCAPACITATED) || black_warrant || gorlex_victory || GLOB.ccpost_gorlex_director != src || extraction_pod_ref?.resolve() != pod || user != operative_ref?.resolve() || user.mind != operative_mind_ref?.resolve() || !user.mind?.has_antag_datum(/datum/antagonist/ccpost_gorlex) || !holds_contract_cartridge(user))
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
	name = "corporate intelligence recovery"
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
		director.release_contract_cartridge(enforcer)
		var/obj/effect/ccpost_recall_charge/manual_charge = director.manual_charge_ref?.resolve()
		var/obj/effect/ccpost_recall_charge/forced_charge = director.forced_charge_ref?.resolve()
		if(manual_charge)
			qdel(manual_charge)
		if(forced_charge)
			qdel(forced_charge)

/datum/antagonist/ccpost_cybersun/greet()
	. = ..() // Native antagonist greeting plays stinger_sound privately.
	to_chat(owner.current, span_boldwarning("CYBERSUN INDUSTRIES // BLACK WARRANT ENFORCEMENT"))
	to_chat(owner.current, span_notice("Terminate the designated rogue contractor and recover the original classified cartridge. Unrelated personnel are not valid targets. Consult your uplink for directive details and recall authorization. The main station and unrelated personnel are outside your jurisdiction."))
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
	desc = "A secure tracker calibrated to the Black Warrant subject. Alt-click to switch between subject and intelligence recovery."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"
	minimum_range = 15
	var/datum/mind/owner_mind
	var/track_cartridge = FALSE

/obj/item/pinpointer/ccpost_warrant/attack_self(mob/living/user)
	if(user.mind != owner_mind)
		return
	return ..()

/obj/item/pinpointer/ccpost_warrant/click_alt(mob/user)
	if(user.mind != owner_mind)
		return CLICK_ACTION_BLOCKING
	track_cartridge = !track_cartridge
	scan_for_target()
	update_appearance()
	to_chat(user, span_notice("Warrant tracker: [track_cartridge ? "Intelligence recovery" : "Warrant subject"] mode."))
	return CLICK_ACTION_SUCCESS

/obj/item/pinpointer/ccpost_warrant/scan_for_target()
	target = null
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!director?.black_warrant || director.enforcer_recalled || director.enforcer_mind != owner_mind)
		return
	if(track_cartridge)
		target = director.data_cartridge_ref?.resolve()
	else
		var/datum/mind/subject = director.operative_mind_ref?.resolve()
		var/mob/living/body = subject?.current
		if(isliving(body))
			target = body
		else
			target = director.operative_ref?.resolve()
	if(QDELETED(target))
		target = null
		return
	var/turf/target_turf = get_turf(target)
	if(!target_turf || is_station_level(target_turf.z))
		target = null

/obj/effect/landmark/ccpost_gorlex_director/proc/can_recall(mob/user, allow_pending = FALSE)
	if(!black_warrant || !refresh_warrant_target() || !user || !get_turf(user) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_INCAPACITATED) || is_station_level(user.z) || user.mind != enforcer_mind || enforcer_recalled || enforcer_forced_pending || enforcer_forced_withdrawal || (enforcer_mission_deadline && world.time >= enforcer_mission_deadline))
		return FALSE
	var/datum/antagonist/ccpost_cybersun/enforcer = user.mind?.has_antag_datum(/datum/antagonist/ccpost_cybersun)
	return enforcer && (allow_pending || !enforcer.recall_pending) && holds_contract_cartridge(user)

/obj/effect/landmark/ccpost_gorlex_director/proc/recall_still_valid(mob/living/user, turf/start_turf, atom/start_loc)
	return !QDELETED(src) && !QDELETED(user) && get_turf(user) == start_turf && user.loc == start_loc && can_recall(user, TRUE)

/obj/effect/landmark/ccpost_gorlex_director/proc/request_recall(mob/living/user)
	if(!can_recall(user))
		to_chat(user, span_warning("CYBERSUN: Recall denied. Terminate the warrant subject and secure the original classified cartridge."))
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
/obj/effect/landmark/ccpost_gorlex_director/proc/release_contract_cartridge(mob/living/carrier)
	var/obj/item/ccpost_classified_cartridge/cartridge = data_cartridge_ref?.resolve()
	if(!carrier || !cartridge || QDELETED(cartridge) || gorlex_victory || cybersun_recovered)
		return
	var/atom/container = cartridge.loc
	while(container && !isturf(container) && container != carrier)
		container = container.loc
	if(container != carrier)
		return
	var/turf/drop_turf = get_turf(carrier)
	if(!drop_turf || is_station_level(drop_turf.z))
		drop_turf = last_valid_cartridge_turf
	if(!drop_turf || is_station_level(drop_turf.z))
		drop_turf = get_return_turf()
	if(!drop_turf)
		return
	if(cartridge.loc == carrier)
		carrier.dropItemToGround(cartridge, force = TRUE)
	if(cartridge.loc != drop_turf)
		cartridge.forceMove(drop_turf)

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
		director.release_contract_cartridge(imp_in)
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
	release_contract_cartridge(operative)
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
	enforcer_recovery_at_expiry = enforcer_termination_at_withdrawal && holds_contract_cartridge(enforcer)
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
	if(enforcer_recovery_at_expiry && holds_contract_cartridge(enforcer))
		cybersun_recovered = TRUE
		ccpost_objective_feedback(enforcer)
	else
		release_contract_cartridge(enforcer)
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
#undef CCPOST_GORLEX_FIRST_CHECK
#undef CCPOST_GORLEX_CHECK_INTERVAL
#undef CCPOST_GORLEX_SECURITY_POLL

#undef CCPOST_GORLEX_PLASTIC_LIMIT
#undef CCPOST_CYBERSUN_RETRY_DELAY

// Admin-only native event controls. No storyteller track; natural recruitment remains director-owned.
/datum/round_event_control/ccpost_gorlex_deployment
	name = "Operation Severance: Gorlex Deployment"
	description = "Polls for a Gorlex operative at an operational Liaison Outpost, bypassing the neglect timer only."
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
	message_admins("Operation Severance: Gorlex recruitment initiated by event trigger.")

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
