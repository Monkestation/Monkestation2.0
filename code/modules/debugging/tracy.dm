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
		var/stop_result = byond_tracy_stop()
		if(stop_result)
			SEND_TEXT(world.log, "Error stopping byond-tracy: [stop_result]")
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

	var/init_result = byond_tracy_init()
	if(init_result != "SUCCESS")
		error = init_result
		SEND_TEXT(world.log, "Error initializing byond-tracy: [init_result]")
		return FALSE
	var/start_result = byond_tracy_start()
	if(start_result)
		error = start_result
		SEND_TEXT(world.log, "Error starting byond-tracy: [start_result]")
		return FALSE
	enabled = TRUE
	trace_path = byond_tracy_status()["path"]
	SEND_TEXT(world.log, "byond-tracy initialized (logfile: [trace_path])")
	return TRUE
#else
	error = "OpenDream not supported"
	return FALSE
#endif

/datum/tracy/proc/flush()
	if(!enabled)
		return
	SEND_TEXT(world.log, "Flushing byond-tracy log")
	var/flush_result = byond_tracy_flush()
	if(flush_result)
		SEND_TEXT(world.log, "Error flushing byond-tracy log: [flush_result]")
		CRASH("Error flushing byond-tracy log: [flush_result]")
	SEND_TEXT(world.log, "Flushed byond-tracy log")

/datum/tracy/vv_edit_var(var_name, var_value)
	return FALSE // no.

/datum/tracy/CanProcCall(procname)
	return FALSE // double no.
