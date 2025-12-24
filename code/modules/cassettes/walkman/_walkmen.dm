

/obj/item/walkman
	name = "walkman"
	desc = "A cassette player that first hit the market over 200 years ago. Crazy how these never went out of style."
	icon = 'icons/obj/cassettes/walkman.dmi'
	icon_state = "walkman"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	custom_price = PAYCHECK_CREW * 6 // walkman crate is a better deal
	custom_premium_price = PAYCHECK_CREW * 6
	actions_types = list(/datum/action/item_action/walkman/play_pause, /datum/action/item_action/walkman/next_song, /datum/action/item_action/walkman/restart_song)
	/// The currently inserted cassette, if any.
	var/obj/item/cassette_tape/inserted_tape
	/// The song currently selected if any.
	var/datum/cassette_song/current_song
	/// Is a song currently playing?
	var/playing = FALSE
	/// Extra metadata sent to the tgui panel.
	var/list/playing_extra_data
	/// The direct URL endpoint of the song being played.
	var/music_endpoint
	/// The REALTIMEOFDAY that the current song was started.
	var/song_start_time
	/// What kind of walkman design style to use.
	var/design = 1
	/// Are we busy fetching a song?
	var/busy = FALSE
	/// The mob currently listening
	var/mob/living/current_listener

/obj/item/walkman/Initialize(mapload)
	. = ..()
	design = rand(1, 5)
	register_context()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/walkman/Destroy(force)
	stop_listening()
	if(!QDELETED(inserted_tape))
		inserted_tape.forceMove(drop_location())
	inserted_tape = null
	return ..()

/obj/item/walkman/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"
		return CONTEXTUAL_SCREENTIP_SET
	else if(istype(held_item, /obj/item/cassette_tape))
		context[SCREENTIP_CONTEXT_LMB] = "Insert Tape"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/walkman/examine(mob/user)
	. = ..()
	if(inserted_tape)
		. += span_info("The \"<b>[inserted_tape.cassette_data.name]</b>\" cassette is inserted.")
		if(current_song)
			. += span_info("The track \"<b>[current_song.name]</b>\" is [playing ? "playing" : "selected"].")
		. += span_info("<b>Ctrl-Click</b> to eject the tape.")
	else
		. += span_info("No tape is inserted.")

/obj/item/walkman/ui_action_click(mob/user, actiontype)
	if(busy)
		user.balloon_alert(user, "walkman busy!")
		return
	if(!inserted_tape)
		user.balloon_alert(user, "no tape inserted!")
		return
	if(istype(actiontype, /datum/action/item_action/walkman/next_song))
		next_song(user)
	else if(istype(actiontype, /datum/action/item_action/walkman/restart_song))
		if(playing)
			song_start_time = REALTIMEOFDAY
			play_for_listener(user)
			user.balloon_alert(user, "song restarted")
		else
			user.balloon_alert(user, "no song playing!")
	else
		return ..()

/obj/item/walkman/attack_self(mob/user, modifiers)
	if(busy)
		user.balloon_alert(user, "walkman busy!")
		return
	if(!inserted_tape)
		user.balloon_alert(user, "no tape inserted!")
		return
	if(playing)
		stop_listening(user)
		user.balloon_alert(user, "stopped song")
	else if(music_endpoint)
		playing = TRUE
		start_listening(user)
		user.balloon_alert(user, "played song")
	else
		user.balloon_alert(user, "no track loaded!")

/obj/item/walkman/update_overlays()
	. = ..()
	. += "+[design]"
	if(inserted_tape)
		if(playing && music_endpoint)
			. += "+playing"
	else
		. += "+empty"

/obj/item/walkman/item_interaction(mob/living/user, obj/item/cassette_tape/tape, list/modifiers)
	if(!istype(tape, /obj/item/cassette_tape))
		return NONE
	if(busy)
		user.balloon_alert(user, "walkman busy!")
		return ITEM_INTERACT_BLOCKING
	if(inserted_tape)
		user.balloon_alert(user, "already a tape inserted!")
		return ITEM_INTERACT_BLOCKING
	if(busy)
		user.balloon_alert(user, "walkman busy!")
		return CLICK_ACTION_BLOCKING
	if(!user.transferItemToLoc(tape, src))
		user.balloon_alert(user, "failed to insert tape!")
		return ITEM_INTERACT_BLOCKING
	inserted_tape = tape
	user.balloon_alert(user, "inserted tape")
	update_appearance(UPDATE_OVERLAYS)
	// preemptively queue the first song
	var/list/songs = inserted_tape.get_current_side()?.songs
	if(length(songs) > 0)
		var/datum/cassette_song/first_song = songs[1]
		SSfloxy.queue_media(first_song.url)
	return ITEM_INTERACT_SUCCESS

/obj/item/walkman/item_ctrl_click(mob/user)
	if(!can_interact(user))
		return NONE
	if(!inserted_tape)
		user.balloon_alert(user, "no tape inserted!")
		return CLICK_ACTION_BLOCKING
	if(busy)
		user.balloon_alert(user, "walkman busy!")
		return CLICK_ACTION_BLOCKING
	stop_listening()
	inserted_tape.forceMove(drop_location())
	user.put_in_hands(inserted_tape)
	user.balloon_alert(user, "ejected tape")
	inserted_tape = null
	update_appearance(UPDATE_OVERLAYS)
	return CLICK_ACTION_SUCCESS

/obj/item/walkman/process(seconds_per_tick)
	if(!playing || !current_song?.duration || !song_start_time)
		return PROCESS_KILL
	if(REALTIMEOFDAY > (song_start_time + (current_song.duration * 1 SECONDS)))
		PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
		stop_listening()

/obj/item/walkman/proc/start_listening(mob/living/listener)
	if(!playing || !current_song || !music_endpoint || QDELETED(listener))
		return
	if(current_listener)
		stop_listening()

	current_listener = listener
	RegisterSignal(current_listener, COMSIG_QDELETING, PROC_REF(stop_listening))
	RegisterSignal(current_listener, COMSIG_TGUI_PANEL_READY, PROC_REF(play_for_listener))
	ADD_TRAIT(current_listener, TRAIT_LISTENING_TO_WALKMAN, REF(src))

	song_start_time = REALTIMEOFDAY
	play_for_listener(current_listener)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/walkman/proc/stop_listening()
	current_song = null
	playing = FALSE
	playing_extra_data = null
	music_endpoint = null
	song_start_time = 0
	STOP_PROCESSING(SSprocessing, src)
	update_appearance(UPDATE_OVERLAYS)
	if(!current_listener)
		return
	UnregisterSignal(current_listener, list(COMSIG_QDELETING, COMSIG_TGUI_PANEL_READY))
	current_listener.client?.tgui_panel?.stop_music()
	REMOVE_TRAIT(current_listener, TRAIT_LISTENING_TO_WALKMAN, REF(src))
	current_listener = null

/obj/item/walkman/proc/play_for_listener(mob/living/listener)
	if(!music_endpoint || !current_song || QDELETED(listener))
		return
	var/list/extra_data = playing_extra_data.Copy()
	var/start = floor((REALTIMEOFDAY - song_start_time) / 10)
	if(start > 0)
		extra_data["start"] = start
	playing = TRUE
	listener.client?.tgui_panel?.play_music(music_endpoint, extra_data)
	START_PROCESSING(SSobj, src)

/obj/item/walkman/dropped(mob/user, silent)
	. = ..()
	stop_listening()

/obj/item/walkman/proc/next_song(mob/user)
	if(!inserted_tape)
		user.balloon_alert(user, "no tape inserted!")
		return
	var/datum/cassette_side/side = inserted_tape.get_current_side()
	var/song_amt = length(side?.songs)
	if(!song_amt)
		user.balloon_alert(user, "no tracks to play!")
		return
	var/new_idx = WRAP_UP(current_song ? side.songs.Find(current_song) : 0, song_amt)
	var/datum/cassette_song/new_track = side.songs[new_idx]
	busy = TRUE
	var/list/info = SSfloxy.download_and_wait(new_track.url, timeout = 30 SECONDS, discard_failed = TRUE)
	busy = FALSE
	if(!info || info["status"] == FLOXY_STATUS_FAILED)
		user.balloon_alert(user, "failed to select track #[new_idx]")
		return
	current_song = new_track
	if(length(info["endpoints"]))
		music_endpoint = info["endpoints"][1]
	else
		log_floxy("Floxy did not return a music endpoint for [new_track.url]")
		stack_trace("Floxy did not return a music endpoint for [new_track.url]")
		balloon_alert(user, "the loader mechanism malfunctioned!")
		return
	var/list/metadata = info["metadata"]
	if(metadata)
		if(metadata["title"])
			current_song.name = metadata["title"]
		if(metadata["artist"])
			current_song.artist = metadata["artist"]
		if(metadata["album"])
			current_song.album = metadata["album"]
		if(current_song.duration <= 0 && metadata["duration"])
			current_song.duration = metadata["duration"]
	playing_extra_data = list(
		"title" = current_song.name,
		"link" = current_song.url,
		"artist" = current_song.artist,
		"album" = current_song.album,
	)
	if(current_song.duration > 0)
		playing_extra_data["duration"] = DisplayTimeText(current_song.duration * 1 SECONDS)
	user.balloon_alert(user, "track #[new_idx] selected")
	to_chat(user, span_notice("Selected track <b>\"[current_song.name]\"</b>."))

/*
	ACTION BUTTONS
*/

/datum/action/item_action/walkman
	button_icon = 'icons/obj/cassettes/walkman.dmi'
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/walkman/play_pause
	name = "Play/Pause"
	button_icon_state = "walkman_playpause"

/datum/action/item_action/walkman/next_song
	name = "Next song"
	button_icon_state = "walkman_next"

/datum/action/item_action/walkman/restart_song
	name = "Restart song"
	button_icon_state = "walkman_restart"
