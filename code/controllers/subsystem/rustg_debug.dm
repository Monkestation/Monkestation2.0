SUBSYSTEM_DEF(rustg_debug)
	name = "rust-g debugging"
	wait = 1 MINUTES
	init_order = INIT_ORDER_DBCORE + 1
	init_stage = INITSTAGE_EARLY
	flags = SS_KEEP_TIMING
	runlevels = ALL
	var/loaded
	var/last_info
	var/shutting_down = FALSE

/datum/controller/subsystem/rustg_debug/PreInit()
#if !defined(OPENDREAM) && !defined(SPACEMAN_DMM) && DM_VERSION > 515
	loaded = load_ext(RUST_G, "rg_debug_info")
#endif

/datum/controller/subsystem/rustg_debug/Initialize(start_timeofday)
	log_rustg_debug("INIT: [debug_info()]")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/rustg_debug/Shutdown()
	shutting_down = TRUE
	log_rustg_debug("SHUTDOWN: [debug_info()]")
	RUSTG_CALL(RUST_G, "stop_dhat")()

/datum/controller/subsystem/rustg_debug/fire(resumed)
	if(!shutting_down) // extra safety measure
		log_rustg_debug(debug_info())

/datum/controller/subsystem/rustg_debug/stat_entry(msg)
	msg = "[last_info]"
	return ..()

/datum/controller/subsystem/rustg_debug/proc/debug_info()
#if !defined(OPENDREAM) && !defined(SPACEMAN_DMM)
	last_info = call_ext(loaded)()
#else
	last_info = RUSTG_CALL(RUST_G, "rg_debug_info")()
#endif
	return last_info
