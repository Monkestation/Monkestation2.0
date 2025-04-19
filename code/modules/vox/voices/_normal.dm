#ifdef AI_VOX
// This file is prefixed with a _ so it's always the first in the list.

/datum/vox_voice/normal
	name = VOX_NORMAL

/datum/vox_voice/normal/New()
	sounds = GLOB.vox_sounds
	return ..()
#endif
