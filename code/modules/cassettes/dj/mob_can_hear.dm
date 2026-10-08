/// A list of all mobs that can hear music.
GLOBAL_LIST_EMPTY_TYPED(music_listeners, /mob)

/mob/Initialize(mapload)
	. = ..()
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_CAN_HEAR_MUSIC), PROC_REF(on_can_hear_music_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_CAN_HEAR_MUSIC), PROC_REF(on_can_hear_music_trait_loss))

	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_LISTENING_TO_WALKMAN), PROC_REF(on_stop_listening_to_walkman))

	// just in case we already have the trait
	if(HAS_TRAIT(src, TRAIT_CAN_HEAR_MUSIC))
		on_can_hear_music_trait_gain(src)

/mob/Destroy(force)
	on_can_hear_music_trait_loss(src)
	return ..()

/mob/proc/on_can_hear_music_trait_gain(datum/source)
	SIGNAL_HANDLER
	if(src in GLOB.music_listeners)
		return
	GLOB.music_listeners += src
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ADD_MUSIC_LISTENER, src)

/mob/proc/on_can_hear_music_trait_loss(datum/source)
	SIGNAL_HANDLER
	if(!(src in GLOB.music_listeners))
		return
	GLOB.music_listeners -= src
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_REMOVE_MUSIC_LISTENER, src)

/mob/proc/on_stop_listening_to_walkman(datum/source)
	SIGNAL_HANDLER
	if(client?.tgui_panel?.is_ready() && !QDELETED(GLOB.dj_booth) && (src in GLOB.music_listeners))
		GLOB.dj_booth.play_for_listener(src)
