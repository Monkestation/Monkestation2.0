/// Macro for getting the auxtools library file
#define AUXLUA (world.system_type == MS_WINDOWS ? "auxlua.dll" : __detect_auxtools("auxlua"))

/proc/__detect_auxtools(library)
	if(IsAdminAdvancedProcCall())
		return
	if (fexists("./lib[library].so"))
		return "./lib[library].so"
	else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"))
		return "[world.GetConfig("env", "HOME")]/.byond/bin/lib[library].so"
	else
		CRASH("Could not find lib[library].so")



#define AUXCPU_DLL (world.system_type == MS_WINDOWS ? "auxcpu_byondapi.dll" : __detect_auxtools("auxcpu_byondapi"))

// uncomment the define below if you want support for "true" world.map_cpu (true_maptick)
//#define MAPTICK_HOOK

/// Set by setup_external_cpu(), everything below falls back to world.cpu while this is FALSE
GLOBAL_REAL_VAR(auxcpu_loaded = FALSE)
/// Set by setup_external_cpu(), the map send signatures are found separately and can miss on their own
GLOBAL_REAL_VAR(auxcpu_map_loaded = FALSE)

/proc/current_true_cpu()
#if defined(USE_AUXCPU) && !defined(OPENDREAM)
	if(auxcpu_loaded)
		var/static/__current_true_cpu
		__current_true_cpu ||= load_ext(AUXCPU_DLL, "byond:current_true_cpu")
		return call_ext(__current_true_cpu)()
#endif
	return world.cpu

/// world.map_cpu for just the last tick instead of a 16 tick average
/proc/current_true_map_cpu()
#if defined(USE_AUXCPU) && !defined(OPENDREAM)
	if(auxcpu_map_loaded)
		var/static/__current_true_map_cpu
		__current_true_map_cpu ||= load_ext(AUXCPU_DLL, "byond:current_true_map_cpu")
		return call_ext(__current_true_map_cpu)()
#endif
	return world.map_cpu

/proc/current_cpu_index()
#if defined(USE_AUXCPU) && !defined(OPENDREAM)
	if(auxcpu_loaded)
		var/static/__current_cpu_index
		__current_cpu_index ||= load_ext(AUXCPU_DLL, "byond:current_cpu_index")
		var/actual_index = call_ext(__current_cpu_index)()
		return WRAP(actual_index + 1, 1, INTERNAL_CPU_SIZE + 1)
#endif
	return WRAP(world.time, 1, INTERNAL_CPU_SIZE + 1)

/proc/true_cpu_at_index(index)
#if defined(USE_AUXCPU) && !defined(OPENDREAM)
	if(auxcpu_loaded)
		var/static/__true_cpu_at_index
		var/actual_index = WRAP(index - 1, 0, INTERNAL_CPU_SIZE)
		__true_cpu_at_index ||= load_ext(AUXCPU_DLL, "byond:true_cpu_at_index")
		return call_ext(__true_cpu_at_index)(actual_index)
#endif
	if(index == current_cpu_index())
		return current_true_cpu()
	return 0

/proc/cpu_values()
#if defined(USE_AUXCPU) && !defined(OPENDREAM)
	if(auxcpu_loaded)
		var/static/__cpu_values
		__cpu_values ||= load_ext(AUXCPU_DLL, "byond:cpu_values")
		return call_ext(__cpu_values)()
#endif
	var/list/values = list()
	for(var/i in 1 to INTERNAL_CPU_SIZE)
		values += true_cpu_at_index(i)
	return values

// NOTE: THIS IS IN DECISECONDS
/proc/true_maptick()
#if defined(USE_AUXCPU) && defined(MAPTICK_HOOK) && !defined(OPENDREAM)
	if(auxcpu_loaded)
		var/static/__true_maptick
		__true_maptick ||= load_ext(AUXCPU_DLL, "byond:maptick")
		return call_ext(__true_maptick)()
#endif
	return world.map_cpu

/world/proc/setup_external_cpu()
#if defined(USE_AUXCPU) && !defined(OPENDREAM)
	try
		if(!call_ext(AUXCPU_DLL, "byond:find_signatures")())
			world.log << "auxcpu failed to find signatures"
			return FALSE
	catch(var/exception/error)
		world.log << "auxcpu failed to load: [error]"
		return FALSE
	world.log << "auxcpu signatures found"
	auxcpu_map_loaded = call_ext(AUXCPU_DLL, "byond:map_cpu_signatures_found")()
	if(!auxcpu_map_loaded)
		world.log << "auxcpu failed to find map cpu signatures, map cpu will be averaged"

#ifdef MAPTICK_HOOK
	var/maptick_err = call_ext(AUXCPU_DLL, "byond:maptick_init")()
	if(maptick_err)
		world.log << "auxcpu failed to hook maptick: [maptick_err]"
		return FALSE
	world.log << "auxcpu hooked maptick"
#endif
	auxcpu_loaded = TRUE
	return TRUE
#else
	return FALSE
#endif

/world/proc/cleanup_external_cpu()
	auxcpu_loaded = FALSE
	auxcpu_map_loaded = FALSE

/proc/meowtonin_stack_trace(message, source, line, full_info)
	var/list/info = list("[message || "N/A"]")
	if(istext(source))
		info += "\tsource: [source]"
		if(line)
			info += "\tline: [line]"
	if(full_info)
		world.log << "\n=== (panic start) ===\n[full_info]\n=== (panic end) ===\n"
	CRASH(jointext(info, "\n"))
