#ifdef AI_VOX
/// A list of all files of the sounds of all VOX voices.
/// This list is populated by [/datum/vox_voice/New()]
GLOBAL_LIST_EMPTY(all_vox_sounds)
/// An associative list of voice names to /datum/vox_voice instances.
GLOBAL_LIST_INIT(vox_voices, initialize_vox_voices())

/// An voice used by the VOX speech system.
/datum/vox_voice
	/// The name/ID of the voice.
	var/name
	/// The default volume of the voice.
	var/volume = 100
	/// An associative list of words to their respective sound file.
	var/list/sounds

/datum/vox_voice/New()
	var/list/all_vox_sounds = GLOB.all_vox_sounds
	for(var/name in sounds)
		var/file = sounds[name]
		all_vox_sounds += file

/datum/vox_voice/Destroy(force)
	if(!force)
		. = QDEL_HINT_LETMELIVE
		CRASH("Tried to delete a /datum/vox_voice, this should not happen!")
	return ..()

/proc/initialize_vox_voices()
	. = list()
	for(var/datum/vox_voice/voice_type as anything in subtypesof(/datum/vox_voice))
		var/name = voice_type::name
		if(!name)
			continue
		.[name] = new voice_type
#endif
