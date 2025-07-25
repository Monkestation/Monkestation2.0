#define DLL_PATH (world.system_type == MS_WINDOWS ? "pick_weight_test.dll" : __detect_auxtools("pick_weight_test"))

/proc/experimental_pick_weight(list/things)
	var/static/loaded
	if(isnull(loaded))
		loaded = load_ext(DLL_PATH, "byond:pick_weight")
	return call_ext(loaded)(things)

/proc/experimental_pick(list/things)
	var/static/loaded
	if(isnull(loaded))
		loaded = load_ext(DLL_PATH, "byond:pick")
	return call_ext(loaded)(things)

#undef DLL_PATH
