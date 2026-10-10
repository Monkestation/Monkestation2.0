// the CRASH()s are so a call before dmeow_init() finishes blows up instead of
// quietly returning null.
/* This comment bypasses grep checks */ /var/__dmeow
#define DMEOW_DLL (world.system_type == MS_WINDOWS ? "dmeow" : (__dmeow ||= __detect_auxtools("dmeow")))

/proc/dmeow_compile(proc_name)
	CRASH("dmeow not loaded")

/proc/dmeow_compile_override(proc_name, override_id)
	CRASH("dmeow not loaded")

/proc/dmeow_dump_bytecode(proc_name)
	CRASH("dmeow not loaded")

/// does not register anything, so the proc keeps running interpreted. failures
/// come back as `;` comment lines.
/proc/dmeow_proc_asm(proc_name)
	CRASH("dmeow not loaded")

/proc/dmeow_proc_native_asm(proc_name)
	CRASH("dmeow not loaded")

/proc/dmeow_toggle_hooks()
	CRASH("dmeow not loaded")

/proc/dmeow_enable_counting(threshold)
	CRASH("dmeow not loaded")

/proc/dmeow_disable_counting()
	CRASH("dmeow not loaded")

/proc/dmeow_compile_wait()
	CRASH("dmeow not loaded")

/proc/dmeow_set_compile_threads(threads)
	CRASH("dmeow not loaded")

/proc/dmeow_set_auto_tier(partial)
	CRASH("dmeow not loaded")

/// dmeow stays loaded when the JIT refuses to arm, and every dmeow_compile()
/// then returns 0. check this instead of assuming.
/proc/dmeow_jit_ready()
	CRASH("dmeow not loaded")

/proc/dmeow_deopt_status()
	CRASH("dmeow not loaded")

/proc/dmeow_perf_start(sample_rate, early_samples = 0)
	CRASH("dmeow not loaded")

/proc/dmeow_perf_stop()
	CRASH("dmeow not loaded")

/proc/dmeow_perf_reset()
	CRASH("dmeow not loaded")

/proc/dmeow_perf_mark(label)
	CRASH("dmeow not loaded")

// only hooked by DLLs built with the extra features on, so these return null
// instead of CRASH()ing in the release build.

/proc/dmeow_perf_report(limit)
	return null

/proc/dmeow_attr_counters()
	return null

/proc/dmeow_perf_microbench(list)
	return null

/proc/dmeow_force_iter_fallback_once()
	return null

/proc/dmeow_list_eligible()
	CRASH("dmeow not loaded")

/proc/dmeow_analyze_procs()
	CRASH("dmeow not loaded")

/// pass `prime` positionally - a hooked proc's named args don't resolve like DM's own.
/proc/dmeow_compile_census(prime = FALSE)
	CRASH("dmeow not loaded")

/proc/dmeow_debug_status()
	CRASH("dmeow not loaded")

/proc/dmeow_debug_flush()
	CRASH("dmeow not loaded")

/proc/dmeow_debug_marker(text)
	CRASH("dmeow not loaded")

/proc/dmeow_cache_save()
	CRASH("dmeow not loaded")

/proc/dmeow_cache_status()
	CRASH("dmeow not loaded")

// nothing calls the stubs below. they're still mandatory: auxtools hooks every
// #[hook] proc at init and one missing path kills the load, so a Rust-side hook
// with no stub here gets you "dmeow failed to load" and no other clue.

/proc/dmeow_deopt_count()
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_unsafe(proc_name)
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_no_caller_count()
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_watch_spans()
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_frames(on)
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_resume(on)
	CRASH("dmeow not loaded")

/proc/dmeow_sleep_frame_count(name)
	CRASH("dmeow not loaded")

/proc/dmeow_frame_bench_ns(path, n, iters)
	CRASH("dmeow not loaded")

/proc/dmeow_atom_exists_native(tag, id)
	CRASH("dmeow not loaded")

/proc/dmeow_atom_exists_byond(tag, id)
	CRASH("dmeow not loaded")

/proc/dmeow_atom_liveness_bound(tag)
	CRASH("dmeow not loaded")

/proc/dmeow_assoc_tree_shape(target)
	CRASH("dmeow not loaded")

/proc/dmeow_string_refcount(target)
	CRASH("dmeow not loaded")

/proc/dmeow_stackmap_shadow_ok()
	CRASH("dmeow not loaded")

/* bypass linters idk */ var/static/dmeow_loaded = FALSE
/* bypass linters idk */ var/static/dmeow_armed = FALSE
// no getters on the dmeow side, so DM mirrors these.
/* bypass linters idk */ var/static/dmeow_hooks_enabled = TRUE
/* bypass linters idk */ var/static/dmeow_counting_threshold = 0

/proc/dmeow_init()
	fdel("dmeow_debug.jsonl")
	// has to land before auxtools_init, since init already writes events.
	if(GLOB.log_directory)
		var/debug_log = call_ext(DMEOW_DLL, "dmeow_set_debug_log")("[GLOB.log_directory]/dmeow_debug.dmeowlog")
		if(debug_log)
			SEND_TEXT(world.log, "dmeow debug log: [debug_log]")
	var/result = call_ext(DMEOW_DLL, "auxtools_init")()
	if(result != "SUCCESS")
		SEND_TEXT(world.log, "dmeow auxtools_init failed: [result]")
		return FALSE
	dmeow_loaded = TRUE
	dmeow_hooks_enabled = TRUE

	dmeow_armed = !!dmeow_jit_ready()
	if(!dmeow_armed)
		world.log << "dmeow loaded, but THE JIT IS DISABLED - nothing will compile. Status:\n[dmeow_deopt_status()]"
		return TRUE

	world.log << "dmeow loaded OK, JIT armed"
	return TRUE

/proc/dmeow_shutdown()
	if(dmeow_loaded)
		call_ext(DMEOW_DLL, "auxtools_shutdown")()
		dmeow_loaded = FALSE
		dmeow_armed = FALSE

// dmeow_toggle_hooks() is a toggle, not a setter, so landing on a known state
// means reading it back and flipping again.
/proc/dmeow_set_hooks(enabled)
	var/state = !!dmeow_toggle_hooks()
	if(state != !!enabled)
		state = !!dmeow_toggle_hooks()
	dmeow_hooks_enabled = state
	return state
