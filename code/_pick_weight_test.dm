#define DLL_PATH (world.system_type == MS_WINDOWS ? "pick_weight_test.dll" : __detect_auxtools("pick_weight_test"))

/proc/experimental_pick_weight(list/things)
#if !defined(OPENDREAM) && !defined(SPACEMAN_DMM)
	var/static/loaded
	if(isnull(loaded))
		loaded = load_ext(DLL_PATH, "byond:pick_weight")
	return call_ext(loaded)(things)
#else
	return call_ext(DLL_PATH, "byond:pick_weight")(things)
#endif

/proc/experimental_pick(list/things)
#if !defined(OPENDREAM) && !defined(SPACEMAN_DMM)
	var/static/loaded
	if(isnull(loaded))
		loaded = load_ext(DLL_PATH, "byond:pick")
	return call_ext(loaded)(things)
#else
	return call_ext(DLL_PATH, "byond:pick")(things)
#endif

#undef DLL_PATH
