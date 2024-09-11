/* This comment bypasses grep checks */ /var/__byond_sleeping_procs

/proc/__detect_byond_sleeping_procs()
	if (world.system_type == UNIX)
		if (fexists("./libbyond_sleeping_procs.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __byond_sleeping_procs = "./libbyond_sleeping_procs.so"
		else if (fexists("./byond_sleeping_procs"))
			// Old dumb filename.
			return __byond_sleeping_procs = "./byond_sleeping_procs"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/byond_sleeping_procs"))
			// Old dumb filename in `~/.byond/bin`.
			return __byond_sleeping_procs = "byond_sleeping_procs"
		else
			// It's not in the current directory, so try others
			return __byond_sleeping_procs = "libbyond_sleeping_procs.so"
	else
		CRASH("tried to run __detect_byond_sleeping_procs on [world.system_type]")

#define EEPY_PROCS (__byond_sleeping_procs || __detect_byond_sleeping_procs())

/// Returns the debug status, including sleeping procs.
/proc/byond_status()
#ifdef UNIT_TESTS
	if (world.system_type == UNIX)
		world.log << "eepy procs test 1"
		. = call_ext(EEPY_PROCS, "get_status")()
		world.log << "eepy procs test 2"
	else
		return "byond_status is not supported on [world.system_type]"
#else
	CRASH("Don't use byond_status outside of UNIT_TESTS, you goober!")
#endif

#undef EEPY_PROCS
