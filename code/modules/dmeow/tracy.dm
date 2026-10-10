// byond_tracy is linked into dmeow, so dmeow_init() already installed its hooks.
// Never load a second byond_tracy beside it (/datum/tracy included) - both
// install the same detours.

/// matches the default in the DLL's own capture.rs - change one and change the other.
#define DMEOW_TRACY_DIR "data/profiler/"

/proc/byond_tracy_start(path = "", ring_mib = "")
	return call_ext(DMEOW_DLL, "byond_tracy_start")("[path]", "[ring_mib]")

/proc/byond_tracy_flush()
	return call_ext(DMEOW_DLL, "byond_tracy_flush")()

/proc/byond_tracy_stop()
	return call_ext(DMEOW_DLL, "byond_tracy_stop")()

/proc/byond_tracy_status()
	return json_decode(call_ext(DMEOW_DLL, "byond_tracy_status")())

/// only starts when nothing has been captured yet, so a server that reboots all
/// day records its first round and then leaves the disk alone.
/proc/dmeow_tracy_autostart()
	var/list/existing = flist(DMEOW_TRACY_DIR)
	if(length(existing))
		return "skipped: [DMEOW_TRACY_DIR] already holds [length(existing)] capture(s)"
	var/failure = byond_tracy_start()
	if(failure)
		return "FAILED to start: [failure]"
	return "recording to [DMEOW_TRACY_DIR]"

ADMIN_VERB(dmeow_tracy_begin, R_DEBUG, FALSE, "dmeow tracy: start capture", "Start a byond_tracy capture. Costs time on every proc call while it runs.", ADMIN_CATEGORY_DEBUG)
	var/failure = byond_tracy_start()
	var/result = failure || "recording to [DMEOW_TRACY_DIR]"
	message_admins("dmeow tracy: [key_name_admin(user)] started a capture - [result]")
	world.log << "dmeow tracy: [result]"

ADMIN_VERB(dmeow_tracy_end, R_DEBUG, FALSE, "dmeow tracy: stop capture", "Finish the running byond_tracy capture and write the file.", ADMIN_CATEGORY_DEBUG)
	var/failure = byond_tracy_stop()
	var/result = failure || "capture written"
	message_admins("dmeow tracy: [key_name_admin(user)] stopped the capture - [result]")
	world.log << "dmeow tracy: [result]"

ADMIN_VERB(dmeow_tracy_state, R_DEBUG, FALSE, "dmeow tracy: status", "Show whether byond_tracy is recording, and what it has dropped.", ADMIN_CATEGORY_DEBUG)
	var/status = json_encode(byond_tracy_status(), JSON_PRETTY_PRINT)
	to_chat(user, fieldset_block("byond_tracy status", "[status]", "boxed_message"))

#undef DMEOW_TRACY_DIR
