#define ICARUS_IGNITION_TIME (180 SECONDS)

/**
 * GoldenEye defence network
 *
 * Contains: Subsystem, Keycard, Terminal and Objective
 *
 * 5/11/2025 GOLDENEYE keycards removed entirely in favor of soley 'abduct' objectives.
 */

SUBSYSTEM_DEF(goldeneye)
	name = "GoldenEye"
	flags = SS_NO_INIT | SS_NO_FIRE
	/// A tracked list of all our keys.
	var/list/goldeneye_minds = list()
	/// A list of minds that have been extracted and thus cannot be extracted again.
	var/list/goldeneye_extracted_minds = list()
	/// We are removing keycards, so uploaded minds instead.
	var/uploaded_minds = 0
	/// How many keys do we need to activate GoldenEye? Can be overriden by Dynamic if there aren't enough heads of staff.
	var/required_minds = GOLDENEYE_REQUIRED_MINDS_MAXIMUM
	/// Have we been activated?
	var/goldeneye_activated = FALSE
	/// How long until ICARUS fires?
	var/ignition_time = ICARUS_IGNITION_TIME
	//if the goldeneye console is destroyed or not
	var/console_status = TRUE

/datum/controller/subsystem/goldeneye/Recover()
	goldeneye_minds = SSgoldeneye.goldeneye_minds
	goldeneye_extracted_minds = SSgoldeneye.goldeneye_extracted_minds
	uploaded_minds = SSgoldeneye.uploaded_minds
	required_minds = SSgoldeneye.required_minds
	goldeneye_activated = SSgoldeneye.goldeneye_activated
	ignition_time = SSgoldeneye.ignition_time

/// A safe proc for adding a targets mind to the tracked extracted minds and incrementing the uploaded minds counter.
/datum/controller/subsystem/goldeneye/proc/extract_mind(datum/mind/target_mind)
	goldeneye_extracted_minds += target_mind
	uploaded_minds++
	check_condition()

/// Checks our activation condition after an upload has occured.
/datum/controller/subsystem/goldeneye/proc/check_condition()
	if(uploaded_minds >= required_minds)
		goldeneye_activated = TRUE
		return
	priority_announce("SYNDICATE MENTAL PROBING SEQUENCE UNDER WAY. [uploaded_minds]/[required_minds] MINDS UPLOADED.", "GoldenEye Defence Network")

/// Activates goldeneye.
/datum/controller/subsystem/goldeneye/proc/activate()
	var/message = "/// GOLDENEYE DEFENCE NETWORK BREACHED /// \n \
	Unauthorised GoldenEye Defence Network access detected. \n \
	ICARUS online. \n \
	Targeting system override detected... \n \
	New target: /NTSS13/ \n \
	ICARUS firing protocols activated. \n \
	ETA to fire: [ignition_time / 60] minutes."

	//priority_announce(message, "GoldenEye Defence Network", ANNOUNCER_ICARUS)
	// Set delta alert, wait a few minutes, fire multiple lasers
	priority_announce(message, "GoldenEye Defence Network", ANNOUNCER_ICARUS)
	SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	addtimer(CALLBACK(src, PROC_REF(fire_icarus)), ignition_time) //fire icarus multiple times?
	//waits 3 minutes before firing. sets a gps signal to the goldeneye console. if the console is destroyed, it will not fire
	var/obj/item/gps/goldeneye_gps = new /obj/item/gps
	goldeneye_gps.gpstag = "GoldenEye Console"
	goldeneye_gps.forceMove(locate(/obj/machinery/goldeneye_upload_terminal))

/datum/controller/subsystem/goldeneye/proc/fire_icarus()
	var/datum/round_event_control/icarus_sunbeam/event_to_start = new()
	event_to_start.run_event()

/// Checks if a mind(target_mind) is a head and if they aren't in the goldeneye_extracted_minds list.
/datum/controller/subsystem/goldeneye/proc/check_goldeneye_target(datum/mind/target_mind)
	var/list/heads_list = SSjob.get_all_heads()
	for(var/datum/mind/iterating_mind as anything in heads_list)
		if(target_mind == iterating_mind) // We have a match, let's check if they've already been extracted.
			if(target_mind in goldeneye_extracted_minds) // They've already been extracted, no double extracts!
				return FALSE
			return TRUE
	return FALSE

/obj/machinery/goldeneye_upload_terminal
	name = "\improper GoldenEye Defnet Upload Terminal"
	desc = "An ominous terminal with some ports and keypads, the screen is scrolling with illegible nonsense. It has a strange marking on the side, a red ring with a gold circle within."
	icon = 'monkestation/code/modules/assault_ops/icons/goldeneye.dmi'
	icon_state = "goldeneye_terminal"
	density = TRUE
	/// Is the system currently in use? Used to prevent spam and abuse.
	var/uploading = FALSE
/obj/machinery/goldeneye_upload_terminal/attackby(obj/item/weapon, mob/user, params) //attack by an empty hand
	. = ..()
	if(uploading)
		return
	if(SSgoldeneye.goldeneye_activated)
		SSgoldeneye.activate()
/obj/machinery/goldeneye_upload_terminal/Destroy()
	. = ..()
	SSgoldeneye.console_status = FALSE
	priority_announce("GoldenEye Defence Network Link Destroyed- System Offline", "Goldeneye Defense Network", ANNOUNCER_ICARUS)
	SSsecurity_level.set_level(SEC_LEVEL_BLUE)
	GLOB.machines.Remove(src)
	SSmachines.unregister_machine(src)

//objective
/datum/objective/goldeneye
	name = "subvert goldeneye"
	objective_name = "Subvert GoldenEye"
	explanation_text = "Steal key information from the heads of staff and activate GoldenEye."
	martyr_compatible = TRUE

/datum/objective/goldeneye/check_completion()
	return ..() || SSgoldeneye.goldeneye_activated

// Variant of stationloving that also allows it to be at the assop base, used by the goldeneye keycards.
/datum/component/stationloving/goldeneye
	inform_admins = TRUE

/datum/component/stationloving/goldeneye/atom_in_bounds(atom/atom_to_check)
	if(istype(get_area(atom_to_check), /area/cruiser_dock))
		return TRUE
	return ..()

#undef ICARUS_IGNITION_TIME
