// replay_recorder.dm is copied from byond-re's crates/replay-recorder, copy it again to update

GLOBAL_VAR_INIT(replay_recorder_running, FALSE)

/// Hides every ckey in a recording behind an alias. The replay viewer shows them again once it is
/// given this same key. Leave it out and ckeys are written as they are.
/datum/config_entry/string/replay_ckey_key
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/proc/replay_recorder_begin()
	if(GLOB.replay_recorder_running)
		return "already recording"
	// a failed call_ext is a runtime, and one at the top of /world/New would
	// keep the server from booting
	if(!fexists(REPLAY_RECORDER_DLL))
		return "not starting, [REPLAY_RECORDER_DLL] is missing"
	// no database means no round id, so the time is all that tells files apart
	var/name = GLOB.round_id ? "round-[GLOB.round_id]" : "[rustg_unix_timestamp()]"
	var/path = "[REPLAY_RECORDER_DIR][name].replay"
	// stopping and starting again in one round must not overwrite the first file
	var/copy = 1
	while(fexists(path))
		path = "[REPLAY_RECORDER_DIR][name]-[++copy].replay"
	var/failure
	try
		failure = replay_recorder_start(path, "monkestation", ckey_key = CONFIG_GET(string/replay_ckey_key))
	catch(var/exception/error)
		return "FAILED to load: [error]"
	if(failure)
		return "FAILED to start: [failure]"
	GLOB.replay_recorder_running = TRUE
	for(var/client/client as anything in GLOB.clients)
		replay_record_client("login", client.ckey)
		replay_record_client("mob", client.ckey, client.mob)
	return "recording to [path]"

/proc/replay_recorder_end()
	if(!GLOB.replay_recorder_running)
		return "not recording"
	GLOB.replay_recorder_running = FALSE
	return replay_recorder_stop() || "recording written"

/// Puts `html` in the replay's feed that everyone can read, for messages that
/// go to every player one to_chat at a time (OOC, station announcements).
/proc/replay_record_global_chat(html, type)
	if(!GLOB.replay_recorder_running)
		return
	replay_recorder_chat(null, type, "", html, TRUE)

/// Tells the recorder which resource an asset URL is, so chat showing it (icon2html) gets its
/// picture in a replay. Runs whether or not anything records: most assets are registered before a
/// recording starts.
/proc/replay_record_asset(url, resource)
	var/static/dll_present
	// a failed call_ext is a runtime, and assets get registered from the first ticks of init
	if(isnull(dll_present))
		dll_present = !!fexists(REPLAY_RECORDER_DLL)
	if(dll_present)
		replay_recorder_asset(url, resource)

/// `event` is "login", "logout" or "mob", which says `ckey` now controls `mob`.
/proc/replay_record_client(event, ckey, mob/mob)
	if(!GLOB.replay_recorder_running)
		return
	var/failure = replay_recorder_client(event, ckey, mob)
	if(failure)
		stack_trace("replay recorder: [failure]")

ADMIN_VERB(replay_start_verb, R_DEBUG, FALSE, "replay recorder: start", "Record what the map looks like every tick, plus chat, into data/replay/.", ADMIN_CATEGORY_DEBUG)
	var/result = replay_recorder_begin()
	message_admins("replay recorder: [key_name_admin(user)] started it - [result]")
	SEND_TEXT(world.log, "replay recorder: [result]")

ADMIN_VERB(replay_stop_verb, R_DEBUG, FALSE, "replay recorder: stop", "Finish the replay recording and write the file.", ADMIN_CATEGORY_DEBUG)
	var/result = replay_recorder_end()
	message_admins("replay recorder: [key_name_admin(user)] stopped it - [result]")
	SEND_TEXT(world.log, "replay recorder: [result]")

ADMIN_VERB(replay_status_verb, R_DEBUG, FALSE, "replay recorder: status", "Show whether the replay recorder is recording, and how far behind it is.", ADMIN_CATEGORY_DEBUG)
	if(!GLOB.replay_recorder_running)
		to_chat(user, span_notice("replay recorder: not recording"), confidential = TRUE)
		return
	var/status = json_encode(replay_recorder_status(), JSON_PRETTY_PRINT)
	to_chat(user, boxed_message("<pre>[html_encode(status)]</pre>"), confidential = TRUE)
