/proc/aneri_audio_length(path, round_to = 5)
	if(istype(path, /sound))
		var/sound/soundin = path
		path = "[soundin.file]"
	return ANERI_CALL("audio_length", "[path]", round_to)
