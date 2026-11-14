#define REPLAY_RECORDER_DIR "data/replay/"
#define REPLAY_RECORDER_DLL _replay_recorder_dll_name()

/proc/_replay_recorder_dll_name()
	var/static/cached
	if(cached)
		return cached
	cached = world.GetConfig("env", "REPLAY_RECORDER_DLL")
	if(!cached)
		// the ./ makes Linux look in the world's folder rather than the system's
		cached = (world.system_type == MS_WINDOWS) ? "replay_recorder.dll" : "./libreplay_recorder.so"
	return cached
