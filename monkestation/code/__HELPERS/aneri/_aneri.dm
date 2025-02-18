// contained in its own proc to prevent runtime shittery
/proc/aneri_startup_log()
	log_world("Aneri version [aneri_version()] loaded")
	log_world("Aneri features: [aneri_features()]")

/datum/aneri
	VAR_FINAL/__aneri_key_low
	VAR_FINAL/__aneri_key_high

/datum/aneri/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, __aneri_key_low) || var_name == NAMEOF(src, __aneri_key_high))
		return FALSE // DO. NOT. TOUCH.
	return ..()

/proc/meowtonin_stack_trace(message, file, line, panic_info_json)
	message ||= "(no message provided)"
	file = istext(file) ? "byondapi:[file]" : "unknown"
	line ||= 0
	/*
	if(!isnull(panic_info_json))
		try
			var/list/panic_info = json_decode(panic_info_json)
			var/list/backtrace = panic_info["backtrace"]
			if(length(backtrace))
		catch
			// meh
	*/
	CRASH("[message][WORKAROUND_IDENTIFIER][json_encode(list(file, line))][WORKAROUND_IDENTIFIER]")
