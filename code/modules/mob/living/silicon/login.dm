/mob/living/silicon/Login()
	if(mind)
		mind?.remove_antags_for_borging()
	if(SStts.tts_enabled)
		var/voice_to_use = client?.prefs.read_preference(/datum/preference/choiced/voice)
		var/pitch_to_use = client?.prefs.read_preference(/datum/preference/numeric/tts_voice_pitch)
		var/blip_base_to_use = client?.prefs.read_preference(/datum/preference/choiced/tts_blip_base)
		if(voice_to_use)
			voice = voice_to_use
		if(pitch_to_use)
			pitch = pitch_to_use
		switch(blip_base_to_use)
			if(TTS_BLIPS_VOICE_PACK)
				blip_base = TTS_BLIP_BASE_VOICE_PACK
			if(TTS_BLIPS_MASCULINE)
				blip_base = "male"
			if(TTS_BLIPS_FEMININE)
				blip_base = "female"
	return ..()


/mob/living/silicon/auto_deadmin_on_login()
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_silicons) || (client.prefs?.toggles & DEADMIN_POSITION_SILICON))
		return client.holder.auto_deadmin()
	return ..()
