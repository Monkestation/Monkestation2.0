#ifdef AI_VOX
/// Maps which words each VOX voice supports
/datum/asset/json/vox_voices
	name = "vox_voices"

/datum/asset/json/vox_voices/generate()
	. = list()
	for(var/voice_name in GLOB.vox_voices) // change this to k,v list once dreamchecker/langserver support that
		var/datum/vox_voice/voice = GLOB.vox_voices[voice_name]
		.[voice_name] = voice.words
#endif
