// replay_recorder interface
//
// Usage:
//   1. replay_recorder_start(path, codebase) - record what the map looks like every tick
//   2. replay_recorder_stop()      - finish the file
//
// Call replay_recorder_stop() from /world/Del(). That also runs on
// world.Reboot(), which frees every appearance and string id without telling
// the recorder, so a recording left running past a reboot is wrong from then
// on.
//
// Read a recording with replay-dump. File format: demowriter/replay_format.md
// in byond-re.

// `path` must not exist yet. `codebase` names the game, e.g. "tgstation": the
// replay viewer draws a tick nobody was online for through that game's plane
// masters. `budget_mib` (default 64) is how much may wait for the writer
// thread before the recording ends itself. The first tick writes the whole
// map. A non-empty `ckey_key` hides every ckey behind an alias; the replay
// viewer shows them again once it is given the same key, so make it long and
// random. Returns "" or why it failed.
/proc/replay_recorder_start(path, codebase = "", budget_mib = "", ckey_key = "")
	return call_ext(REPLAY_RECORDER_DLL, "replay_recorder_start")("[path]", "[codebase]", "[budget_mib]", "[ckey_key]")

// Finishes the file and blocks until it is written. Returns "" or why it
// failed.
/proc/replay_recorder_stop()
	return call_ext(REPLAY_RECORDER_DLL, "replay_recorder_stop")()

// Puts `text` into the next recorded tick. Does nothing while not recording.
/proc/replay_recorder_mark(text)
	return call_ext(REPLAY_RECORDER_DLL, "replay_recorder_mark")("[text]")

// Puts one chat message into the next recorded tick. `ckeys` is who got it;
// `is_global` puts it in the feed everyone can read. An <img> whose src is
// "\ref[obj or mob]", "\ref[icon file]" or an asset URL given to
// replay_recorder_asset() gets its picture recorded as it is right now. Does
// nothing while not recording.
/proc/replay_recorder_chat(list/ckeys, type, text, html, is_global = FALSE)
	return call_ext(REPLAY_RECORDER_DLL, "replay_recorder_chat")(jointext(ckeys || list(), ","), "[type]", "[text]", "[html]", is_global ? "1" : "")

// Says which icon resource a browser asset's URL is (`url` exactly as an <img>
// src will have it), so chat that shows it gets its picture. Call it whether or
// not anything records. A `resource` not in the resource cache (a file() on
// disk) is ignored.
/proc/replay_recorder_asset(url, resource)
	return call_ext(REPLAY_RECORDER_DLL, "replay_recorder_asset")("[url]", "\ref[resource]")

// Puts a client event into the next recorded tick: `event` is "login",
// "logout" or "mob" (the client now controls `mob`). Does nothing while not
// recording. Returns "" or why it failed.
/proc/replay_recorder_client(event, ckey, mob/mob)
	return call_ext(REPLAY_RECORDER_DLL, "replay_recorder_client")("[event]", "[ckey]", mob ? "\ref[mob]" : "")

// A list: state ("idle", "recording", "stopped"), path, ticks, last_tick_ns,
// max_tick_ns, queued_bytes, off_thread_releases, off_thread_ticks,
// bad_flicks, bad_animate_targets, stop_reason, error.
/proc/replay_recorder_status()
	return json_decode(call_ext(REPLAY_RECORDER_DLL, "replay_recorder_status")())
