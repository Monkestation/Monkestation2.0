// byond_tracy interface
//
// Usage:
//   1. byond_tracy_init()   - standalone DLL only, once at startup. Linked into
//                             dmeow, dmeow's own init already did it
//   2. byond_tracy_start()  - begin a capture to a .utracy file
//   3. byond_tracy_stop()   - finish the file
//
// Never load the standalone DLL into a world that also loads dmeow built with
// its tracy feature: both install the same hooks.
//
// Replay a capture into Tracy with rtracy. File format: profiling/utracy_v3.md
// in byond-re.

// Define BYOND_TRACY_DLL before including this to point at another library,
// such as dmeow's.
#ifndef BYOND_TRACY_DLL
#define BYOND_TRACY_DLL _byond_tracy_dll_name()
#endif

/proc/_byond_tracy_dll_name()
	var/static/cached
	if(cached)
		return cached
	cached = world.GetConfig("env", "BYOND_TRACY_DLL")
	if(!cached)
		// the ./ makes Linux look in the world's folder rather than the system's
		cached = (world.system_type == MS_WINDOWS) ? "byond_tracy.dll" : "./libbyond_tracy.so"
	return cached

// Returns "SUCCESS" or why it failed.
/proc/byond_tracy_init()
	return call_ext(BYOND_TRACY_DLL, "auxtools_init")()

// Both arguments are optional. `path` defaults to
// data/profiler/<unix ms>.utracy and is never overwritten. `ring_mib` is the
// memory for events waiting to be written, 64 by default; when it fills,
// events are dropped and the file records a gap. Recording begins at the next
// tick that starts with no proc running.
// Timestamps use the CPU's TSC; BYOND_TRACY_CLOCK=os in DreamDaemon's
// environment switches to the OS clock. byond_tracy_status()["clock"] says which.
// Returns "" or why it failed.
/proc/byond_tracy_start(path = "", ring_mib = "")
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_start")("[path]", "[ring_mib]")

// Blocks until everything recorded so far is written. Returns "" or why it
// failed.
/proc/byond_tracy_flush()
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_flush")()

// Writes out everything recorded so far, moves the file to `path` and keeps
// recording there, so a capture that started at the default path can be given
// a real name later. Works across drives. `path` is never overwritten. A failed
// move leaves the capture running at its old path. Returns "" or why it failed.
/proc/byond_tracy_move(path)
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_move")("[path]")

// Finishes the file and blocks until it is written. A later start works.
// Returns "" or why it failed.
/proc/byond_tracy_stop()
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_stop")()

// Graphs `value` against `name` under the Tracy timeline. Does nothing while
// no capture is recording. One caller per name: samples for one plot have to
// arrive in increasing time order. Returns "" or why it failed.
/proc/byond_tracy_plot(name, value)
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_plot")("[name]", "[value]")

// How a plot is drawn. `format` is "number", "memory" or "percentage"; `color`
// is 0xRRGGBB, 0 letting Tracy pick. Call it before the first sample.
// Returns "" or why it failed.
/proc/byond_tracy_plot_config(name, format = "number", steps = 0, fill = 1, color = 0)
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_plot_config")("[name]", "[format]", "[steps]", "[fill]", "[color]")

// Draws a named band above the zones. Entering a band leaves whatever band
// `category` already held, so bands in one category cannot nest; different
// categories overlap freely.
/proc/byond_tracy_section(category, text)
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_section")("[category]", "[text]")

// Ends `category`'s live band without starting another.
/proc/byond_tracy_section_end(category)
	return call_ext(BYOND_TRACY_DLL, "byond_tracy_section_end")("[category]")

// An assoc list: "state" ("idle", "armed", "recording", "stopped"), "path",
// "stop_reason" ("stopped", "shutdown", "writer_error" or null), "dropped",
// "ring_capacity" and "ring_high_water" (in events), "writer_error", and
// "skipped_hooks": why each optional hook (the hard-delete zones) was left out,
// an empty list when none was. It is there in the idle state too.
/proc/byond_tracy_status()
	return json_decode(call_ext(BYOND_TRACY_DLL, "byond_tracy_status")())
