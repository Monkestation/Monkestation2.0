/// The byond-tracy instance.
/// This is a GLOBAL_REAL because it is the VERY FIRST THING to initialize, even before the MC or GLOB.
GLOBAL_REAL(Tracy, /datum/tracy)

/datum/tracy
	/// Is byond-tracy enabled and running?
	VAR_FINAL/enabled = FALSE
	/// The error text, if initializing byond-tracy errored.
	VAR_FINAL/error
	/// A description of what / who enabled byond-tracy.
	VAR_FINAL/init_reason
	/// A path to the file containing the output trace, if any.
	VAR_FINAL/trace_path

/datum/tracy/New()
	if(!isnull(Tracy))
		CRASH("Attempted to initialize /datum/tracy when global.Tracy is already set!")
	Tracy = src

/datum/tracy/Destroy()
#ifndef OPENDREAM_REAL
	if(enabled)
		byond_tracy_stop()
#endif
	return ..()

/// Tries to initialize byond-tracy.
/datum/tracy/proc/enable(init_reason)
#ifndef OPENDREAM_REAL
	if(enabled)
		return TRUE
	src.init_reason = init_reason
	if(!fexists(TRACY_DLL_PATH))
		error = "[TRACY_DLL_PATH] not found"
		SEND_TEXT(world.log, "Error initializing byond-tracy: [error]")
		return FALSE

	// byond-tracy is built into dmeow, and this can run from Genesis, well before world/New would load dmeow.
	if(!dmeow_loaded && !dmeow_init())
		error = "dmeow failed to load"
		SEND_TEXT(world.log, "Error initializing byond-tracy: [error]")
		return FALSE

	var/list/status = byond_tracy_status()
	// dmeow's autostart can already be recording by the time an admin asks.
	if(!(status["state"] in list("armed", "recording")))
		var/start_failure = byond_tracy_start()
		if(start_failure)
			error = start_failure
			SEND_TEXT(world.log, "Error initializing byond-tracy: [error]")
			return FALSE
		status = byond_tracy_status()
	enabled = TRUE
	trace_path = status["path"]
	SEND_TEXT(world.log, "byond-tracy initialized (logfile: [trace_path])")
	move_to_round(GLOB?.round_id)
	return TRUE
#else
	error = "OpenDream not supported"
	return FALSE
#endif

/// Moves the capture to data/profiler/round_[round_id].utracy, so it can be told apart from other rounds' captures.
/// It starts in Genesis, long before there is a round ID, so this runs again once SetupLogs has one.
/// A server with no database never gets a round ID, and its capture stays where it started.
/datum/tracy/proc/move_to_round(round_id)
	if(!enabled || !round_id)
		return
	var/failure = byond_tracy_move("data/profiler/round_[round_id].utracy")
	if(failure)
		SEND_TEXT(world.log, "Error moving byond-tracy log: [failure]")
	// A move that couldn't delete the old file still moved, so ask where the capture is rather than guessing.
	trace_path = byond_tracy_status()["path"]

/datum/tracy/proc/flush()
	if(!enabled)
		return
	SEND_TEXT(world.log, "Flushing byond-tracy log")
	var/failure = byond_tracy_flush()
	if(failure)
		SEND_TEXT(world.log, "Error flushing byond-tracy log: [failure]")
		CRASH("Error flushing byond-tracy log: [failure]")
	SEND_TEXT(world.log, "Flushed byond-tracy log")

/datum/tracy/vv_edit_var(var_name, var_value)
	return FALSE // no.

/datum/tracy/CanProcCall(procname)
	return FALSE // double no.
