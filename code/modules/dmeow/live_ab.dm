// always compiled, like killswitch.dm. flips the JIT on and off by itself on a
// live server, so one round gives many paired on/off windows to compare tick
// time across. a DLL built with the live-ab feature (production builds) starts
// it on its own.

/// 277 seconds, on purpose not 300: some subsystems and events run on 5 or 10
/// minute periods, and a window that matched one would always catch it in the
/// same arm.
#define DMEOW_LIVE_AB_WINDOW (277 SECONDS)

/* bypass linters idk */ var/static/dmeow_live_ab_running = FALSE

/// what world.dm calls once dmeow is up. does nothing in a DLL built without live-ab.
/proc/dmeow_live_ab_maybe_start()
	if(!dmeow_live_ab_default())
		return
	if(dmeow_live_ab_running)
		return
	dmeow_live_ab_running = TRUE
	spawn(0)
		dmeow_live_ab_loop()

/// one call for the whole round and never compiled: it calls dmeow_toggle_hooks()
/// directly instead of through a helper, so no other proc can reach the compile
/// threshold from here and end up flipping dispatch from inside compiled code.
///
/// the first window is a plain on one, so the JIT gets to compile before anything
/// is measured. after that each pair of windows is on/off in a random order. it
/// stops when the killswitch clears dmeow_live_ab_running, or when somebody else
/// changed the hooks (the panel's toggle): a manual choice wins.
/proc/dmeow_live_ab_loop()
	var/on = TRUE
	sleep(DMEOW_LIVE_AB_WINDOW)
	while(dmeow_live_ab_running)
		var/want = prob(50)
		for(var/i in 1 to 2)
			if(!dmeow_live_ab_running || dmeow_hooks_enabled != on)
				return
			if(want != on)
				on = !!dmeow_toggle_hooks()
				dmeow_hooks_enabled = on
				if(on)
					dmeow_enable_counting(DMEOW_PERF_DEFAULT_THRESHOLD)
					dmeow_counting_threshold = DMEOW_PERF_DEFAULT_THRESHOLD
				else
					dmeow_disable_counting()
					dmeow_counting_threshold = 0
			log_world("DMEOW_LIVE_AB: jit [on ? "on" : "off"]")
			sleep(DMEOW_LIVE_AB_WINDOW)
			want = !want
	return
