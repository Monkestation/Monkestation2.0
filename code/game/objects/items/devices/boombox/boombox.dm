/obj/item/boombox
	name = "\proper Nanomusic boombox"
	desc = "Never quit making all that racket with this booming box."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "boombox"
	inhand_icon_state = "boombox"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_premium_price = PAYCHECK_COMMAND * 7
	interaction_flags_item = parent_type::interaction_flags_item & ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	/// Is the boombox actively playing anything?
	var/active = FALSE
	/// Is the boombox being worn on the holder's shoulder?
	var/swag_mode = FALSE
	/// Reference to the tapedeck that's inserted into the boombox.
	var/obj/item/music_tape/tapedeck = null
	/// Soundloop that's managing our boombox.
	var/datum/looping_sound/boombox_audio = null
	/// A list of all available boombox actions
	var/list/boombox_acts = list()
	/// Icon file for radial objects
	var/radial_icon_file = 'icons/hud/radial_taperecorder.dmi'
	/// Particle holder for music note effect.
	var/obj/effect/abstract/particle_holder/music_particles
	/// Reference to the cassette tape that's inserted into the boombox, if any.
	var/obj/item/cassette_tape/cassette = null
	/// Media source playing the current cassette track to everyone around us.
	var/datum/media_source/object/cassette_media = null
	/// Keeps the cassette media source following us while someone carries us around.
	var/datum/movement_detector/cassette_tracker = null
	/// Index of the cassette track we're on, in the current side of the tape.
	var/cassette_track_index = 0
	/// Are we busy loading a cassette track?
	var/cassette_busy = FALSE

/obj/item/boombox/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	update_available_icons()
	register_context()

/obj/item/boombox/deconstruct(disassembled = TRUE)
	if(tapedeck)
		tapedeck.forceMove(drop_location())
	if(cassette)
		cassette.forceMove(drop_location())
	return ..()

/obj/item/boombox/Destroy(force)
	QDEL_NULL(boombox_audio)
	stop_cassette()
	return ..()

/obj/item/boombox/examine(mob/user)
	. = ..()
	. += span_notice("The boombox can be worn in hand or on your shoulder. Alt-Right-click to toggle.")
	if(tapedeck)
		. += "It has [span_bold("[tapedeck]")] inside."
	else if(cassette)
		. += "It has [span_bold("[cassette]")] inside."
		var/datum/media_track/track = cassette_media?.current_track
		if(active && track)
			. += span_notice("It is playing [span_bold(track.display())].")
	else
		. += "It has no tapedeck inside."

/obj/item/boombox/click_alt_secondary(mob/user)
	swag_mode = !swag_mode
	balloon_alert(user, "wearing [swag_mode ? "on shoulder" : "in hand"]")
	if(loc == user)
		playsound(user, pickup_sound, 30)
	update_appearance()
	user.update_held_items()
	return CLICK_ACTION_SUCCESS

/obj/item/boombox/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/music_tape) || istype(tool, /obj/item/cassette_tape))
		if(tapedeck || cassette)
			balloon_alert(user, "eject first!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		if(istype(tool, /obj/item/cassette_tape))
			cassette = tool
			cassette_track_index = 0
		else
			tapedeck = tool
		balloon_alert(user, "tape inserted")
		playsound(src, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/tape))
		balloon_alert(user, "won't fit!")
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/boombox/attack_hand(mob/user, list/modifiers)
	. = ..()
	update_available_icons()
	if(!check_menu(user))
		return
	display_radial_menu(user)

/obj/item/boombox/attack_self(mob/user, modifiers)
	. = ..()
	update_available_icons()
	if(!check_menu(user))
		return
	display_radial_menu(user)

/obj/item/boombox/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_RMB] = "Control boombox"
	context[SCREENTIP_CONTEXT_LMB] = "Pick up (Drag)"
	context[SCREENTIP_CONTEXT_ALT_RMB] = "Change worn style"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/boombox/update_icon_state()
	inhand_icon_state = swag_mode ? "boombox_swag" : "boombox"
	return ..()

/obj/item/boombox/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	. = ..()
	update_appearance() //Update appearance when dragged for shoulder icon state.

/obj/item/boombox/process(seconds_per_tick)
	var/datum/media_track/track = cassette_media?.current_track
	if(!active || !track?.duration || cassette_busy)
		return PROCESS_KILL
	if(REALTIMEOFDAY >= cassette_media.start_time + track.duration)
		INVOKE_ASYNC(src, PROC_REF(next_cassette_track))
		return PROCESS_KILL

/**
 * Handles the radial menu of the boombox and it's active effects when selected.
 */
/obj/item/boombox/proc/display_radial_menu(mob/living/user)
	if(!user)
		return FALSE
	var/choice = show_radial_menu(user, src, boombox_acts, radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	switch(choice)
		if("Play")
			if(cassette)
				if(!play_cassette(user))
					return
			else
				if(!tapedeck)
					balloon_alert(user, "no tape!")
					return
				boombox_audio = tapedeck.song_inside
				boombox_audio.start()
			music_particles = new (src, /particles/musical_notes, PARTICLE_ATTACH_MOB)
			icon_state = "boombox_on"
			update_appearance()
			active = TRUE

		if("Next")
			if(!active || !cassette)
				return
			next_cassette_track(user)

		if("Stop")
			if(!boombox_audio && !cassette_media)
				balloon_alert(user, "nothing playing!")
				return
			stop_music(user)
			active = FALSE

		if("Eject")
			stop_music(user)
			user.transferItemToLoc(tapedeck || cassette, drop_location())
			tapedeck = null
			cassette = null
			update_available_icons()
			active = FALSE

	playsound(src, 'sound/machines/click.ogg', 40, TRUE)

/// Updates the list of boombox_acts for the radial menu.
/obj/item/boombox/proc/update_available_icons()
	boombox_acts = list()
	if(!active)
		boombox_acts += list("Play" = image(radial_icon_file, "play"))
	else
		boombox_acts += list("Stop" = image(radial_icon_file, "stop"))
		if(cassette)
			boombox_acts += list("Next" = image(radial_icon_file, "input"))
	if(tapedeck || cassette)
		boombox_acts += list("Eject" = image(radial_icon_file, "eject"))

/// Do we meet the requirements to interact with the boombox?
/obj/item/boombox/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/// Stops looping audio, handles particles
/obj/item/boombox/proc/stop_music(mob/user)
	stop_cassette()
	if(boombox_audio)
		boombox_audio.stop()
		boombox_audio = null

	if(music_particles)
		QDEL_NULL(music_particles)
	icon_state = "boombox"
	update_appearance()

/// Starts playing the inserted cassette, from the track we were on. Returns TRUE if it started playing.
/obj/item/boombox/proc/play_cassette(mob/living/user)
	if(cassette_busy)
		balloon_alert(user, "loading track!")
		return FALSE
	// Everyone around us hears this, so only tapes checked by the Space Board of Music can go in.
	if(cassette.cassette_data?.status != CASSETTE_STATUS_APPROVED)
		balloon_alert(user, "tape not approved!")
		return FALSE
	if(!length(cassette.get_current_side()?.songs))
		balloon_alert(user, "no tracks to play!")
		return FALSE
	return load_cassette_track(user, max(cassette_track_index, 1))

/// Skips to the next track on the current side of the cassette, wrapping around at the end.
/obj/item/boombox/proc/next_cassette_track(mob/living/user)
	if(!cassette || cassette_busy)
		return
	var/song_amt = length(cassette.get_current_side()?.songs)
	if(!song_amt)
		stop_music()
		active = FALSE
		return
	if(!load_cassette_track(user, WRAP_UP(cassette_track_index, song_amt)))
		stop_music()
		active = FALSE

/// Fetches a track from the cassette and plays it around the boombox. Sleeps while the track loads. Returns TRUE on success.
/obj/item/boombox/proc/load_cassette_track(mob/living/user, track_index)
	var/obj/item/cassette_tape/loading_tape = cassette
	var/datum/cassette_song/song = loading_tape.get_current_side()?.songs[track_index]
	if(!song?.url)
		return FALSE
	cassette_busy = TRUE
	var/list/info = SSfloxy.download_and_wait(song.url, timeout = 30 SECONDS, discard_failed = TRUE)
	cassette_busy = FALSE
	if(QDELETED(src) || cassette != loading_tape)
		return FALSE
	if(!info || info["status"] == FLOXY_STATUS_FAILED || !length(info["endpoints"]))
		if(user)
			balloon_alert(user, "failed to load track #[track_index]!")
		return FALSE
	var/list/metadata = info["metadata"]
	var/duration = song.duration
	if(duration <= 0 && metadata?["duration"])
		duration = metadata["duration"]
	var/datum/media_track/track = new(info["endpoints"][1], metadata?["title"] || song.name, duration * 1 SECONDS, metadata?["artist"] || song.artist)
	cassette_track_index = track_index
	if(!cassette_media)
		cassette_media = new(volume = 50, mixer_channel = CHANNEL_JUKEBOX, source = src, max_distance = SOUND_RANGE + MEDIUM_RANGE_SOUND_EXTRARANGE)
		cassette_tracker = new(src, CALLBACK(cassette_media, TYPE_PROC_REF(/datum/media_source/object, on_source_moved)))
	cassette_media.current_track = track
	cassette_media.start_time = REALTIMEOFDAY
	cassette_media.update_for_all_listeners(TRUE)
	START_PROCESSING(SSobj, src)
	if(user)
		balloon_alert(user, "track #[track_index]")
	return TRUE

/// Stops any cassette track we're playing.
/obj/item/boombox/proc/stop_cassette()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(cassette_tracker)
	QDEL_NULL(cassette_media)
