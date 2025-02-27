/proc/aneri_audio_length(path, round_up = 0.5 SECONDS)
	if(istype(path, /sound))
		var/sound/soundin = path
		path = "[soundin.file]"
	if(!path)
		return
	. = ANERI_CALL(audio_length, "[path]")
	if(. && round_up)
		return CEILING(., round_up)
