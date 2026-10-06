/// compiled code stays installed but unused, so this is instant and reversible.
/proc/dmeow_pull_the_plug()
	if(!dmeow_loaded)
		return "dmeow was never loaded"
	dmeow_disable_counting()
	dmeow_counting_threshold = 0
	dmeow_set_hooks(FALSE)
	if(dmeow_hooks_enabled)
		return "FAILED to disable dmeow hooks - it is still running compiled code"
	return "dmeow disabled: everything is back on the interpreter"

/proc/dmeow_rearm()
	if(!dmeow_loaded)
		return "dmeow was never loaded"
	if(!dmeow_armed)
		return "the JIT never armed this round, so there is nothing to re-enable"
	dmeow_set_hooks(TRUE)
	if(!dmeow_hooks_enabled)
		return "FAILED to enable dmeow hooks"
	dmeow_enable_counting(DMEOW_PERF_DEFAULT_THRESHOLD)
	dmeow_counting_threshold = DMEOW_PERF_DEFAULT_THRESHOLD
	return "dmeow re-enabled"

ADMIN_VERB(dmeow_killswitch, R_DEBUG, FALSE, "dmeow: pull the plug", "Turn the dmeow JIT off for the rest of the round. Everything goes back to the interpreter.", ADMIN_CATEGORY_DEBUG)
	var/result = dmeow_pull_the_plug()
	message_admins("dmeow: [key_name_admin(user)] pulled the plug - [result]")
	log_admin("[key_name(user)] disabled dmeow: [result]")
	world.log << "dmeow: [result]"

ADMIN_VERB(dmeow_rearm_verb, R_DEBUG, FALSE, "dmeow: re-arm", "Turn the dmeow JIT back on after pulling the plug.", ADMIN_CATEGORY_DEBUG)
	var/result = dmeow_rearm()
	message_admins("dmeow: [key_name_admin(user)] re-armed - [result]")
	log_admin("[key_name(user)] re-enabled dmeow: [result]")
	world.log << "dmeow: [result]"
