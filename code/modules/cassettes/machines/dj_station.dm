GLOBAL_DATUM(dj_booth, /obj/machinery/dj_station)

/obj/machinery/dj_station
	name = "Cassette Player"
	desc = "Plays Space Music Board approved cassettes for anyone in the station to listen to."

	icon = 'icons/obj/cassettes/radio_station.dmi'
	icon_state = "cassette_player"

	use_power = NO_POWER_USE
	processing_flags = NONE

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	interaction_flags_machine = INTERACT_MACHINE_SET_MACHINE

	anchored = TRUE
	density = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING

	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess // to try to keep it as seamless as possible when the song ends

	/// Is someone currently ejecting the tape?
	var/is_ejecting = FALSE
	/// Are we currently broadcasting a song?
	var/broadcasting = FALSE
	/// Are we currently switching tracks?
	var/switching_tracks = FALSE
	/// The currently inserted cassette, if any.
	var/obj/item/cassette_tape/inserted_tape
	/// The song currently being played, if any.
	var/datum/cassette_song/playing
	/// Extra metadata sent to the tgui panel.
	var/list/playing_extra_data
	/// The direct URL endpoint of the song being played.
	var/music_endpoint
	/// The REALTIMEOFDAY that the current song was started.
	var/song_start_time
	/// Looping sound used when switching cassette tracks.
	var/datum/looping_sound/cassette_track_switch/switch_sound
	/// If this can play bootleg tapes or not.
	var/can_play_bootlegs = FALSE

	/// How long of a cooldown between playing two songs.
	var/song_cooldown = 2 MINUTES

	COOLDOWN_DECLARE(next_song_timer)
	COOLDOWN_DECLARE(fake_loading_time)

/obj/machinery/dj_station/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	register_context()
	if(QDELETED(GLOB.dj_booth) && (!mapload || is_station_level(loc?.z)))
		GLOB.dj_booth = src
	ADD_TRAIT(src, TRAIT_ALT_CLICK_BLOCKER, INNATE_TRAIT)
	switch_sound = new(src)
	RegisterSignal(SSdcs, COMSIG_GLOB_ADD_MUSIC_LISTENER, PROC_REF(on_add_listener))
	RegisterSignal(SSdcs, COMSIG_GLOB_REMOVE_MUSIC_LISTENER, PROC_REF(on_remove_listener))

/obj/machinery/dj_station/Destroy()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_ADD_MUSIC_LISTENER, COMSIG_GLOB_REMOVE_MUSIC_LISTENER))
	QDEL_NULL(switch_sound)
	if(!QDELETED(inserted_tape))
		inserted_tape.forceMove(drop_location())
	inserted_tape = null
	playing = null
	if(GLOB.dj_booth == src)
		GLOB.dj_booth = null
		for(var/mob/listener in GLOB.music_listeners)
			UnregisterSignal(listener, COMSIG_TGUI_PANEL_READY)
			listener.client?.tgui_panel?.stop_music()
	return ..()

/obj/machinery/dj_station/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(istype(held_item, /obj/item/cassette_tape))
		context[SCREENTIP_CONTEXT_LMB] = inserted_tape ? "Swap Tape" : "Insert Tape"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(!held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Open UI"
		. = CONTEXTUAL_SCREENTIP_SET

	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/machinery/dj_station/examine(mob/user)
	. = ..()
	if(inserted_tape)
		. += span_notice("It currently has a tape inserted.")
	if(!COOLDOWN_FINISHED(src, next_song_timer))
		. += span_notice("It's currently on cooldown, it will be able to play another song in <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, next_song_timer))]</b>.")

/obj/machinery/dj_station/update_overlays()
	. = ..()
	if(broadcasting)
		. += mutable_appearance(icon, "[icon_state]_on")
		. += emissive_appearance(icon, "[icon_state]_on_e", src, alpha = src.alpha)

/obj/machinery/dj_station/process()
	if(!playing?.duration || !broadcasting || !song_start_time)
		return PROCESS_KILL
	if(REALTIMEOFDAY > (song_start_time + (playing.duration * 1 SECONDS)))
		end_processing() // doing this instead of PROCESS_KILL because i think there's a possibility of this sleeping?
		log_music("Song \"[playing.name]\" from [inserted_tape.name] ([inserted_tape.cassette_data?.id || "no cassette id"]) finished playing at [AREACOORD(src)]")
		PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
		COOLDOWN_START(src, next_song_timer, song_cooldown)
		broadcasting = FALSE
		song_start_time = 0
		update_appearance(UPDATE_OVERLAYS)
		SStgui.update_uis(src)

/obj/machinery/dj_station/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/cassette_tape))
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	if(is_ejecting)
		balloon_alert(user, "already inserting/ejecting")
		return ITEM_INTERACT_BLOCKING
	if(broadcasting)
		balloon_alert(user, "stop the current track first!")
		return ITEM_INTERACT_BLOCKING

	is_ejecting = TRUE

	var/obj/item/cassette_tape/old_tape = inserted_tape
	if(old_tape)
		PLAY_CASSETTE_SOUND(SFX_DJSTATION_OPENTAKEOUT)
		if (!do_after(user, 1.3 SECONDS, src))
			is_ejecting = FALSE
			return ITEM_INTERACT_BLOCKING
		old_tape.forceMove(drop_location())
		inserted_tape = null

	if (old_tape)
		sleep(0.2 SECONDS)
		PLAY_CASSETTE_SOUND(SFX_DJSTATION_PUTINANDCLOSE)
		if (!do_after(user, 1.3 SECONDS, src))
			is_ejecting = FALSE
			return ITEM_INTERACT_BLOCKING
	else
		PLAY_CASSETTE_SOUND(SFX_DJSTATION_OPENPUTINANDCLOSE)
		if (!do_after(user, 2.2 SECONDS, src))
			is_ejecting = FALSE
			return ITEM_INTERACT_BLOCKING
	if(user.transferItemToLoc(tool, src))
		balloon_alert(user, "inserted tape")
		inserted_tape = tool
		if(old_tape)
			user.put_in_hands(old_tape)
	is_ejecting = FALSE
	update_static_data_for_all_viewers()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/dj_station/proc/eject_tape(mob/user)
	if(is_ejecting)
		balloon_alert(user, "already ejecting tape!")
		return FALSE
	if(!inserted_tape)
		balloon_alert(user, "no tape inserted!")
		return FALSE
	if(switching_tracks)
		balloon_alert(user, "busy switching tracks!")
		return FALSE
	if(broadcasting)
		balloon_alert(user, "stop the current track first!")
		return FALSE
	end_processing()
	is_ejecting = TRUE
	balloon_alert(user, "ejecting tape...")
	PLAY_CASSETTE_SOUND(SFX_DJSTATION_OPENTAKEOUTANDCLOSE)
	if (!do_after(user, 1.5 SECONDS, src))
		is_ejecting = FALSE
		return FALSE
	inserted_tape.forceMove(drop_location())
	is_ejecting = FALSE
	log_music("[key_name(user)] ejected [inserted_tape.name] ([inserted_tape.cassette_data?.id || "no cassette id"]) at [AREACOORD(src)]")
	balloon_alert(user, "tape ejected")
	user.put_in_hands(inserted_tape)
	inserted_tape = null
	update_static_data_for_all_viewers()
	return TRUE

/obj/machinery/dj_station/click_ctrl(mob/user)
	if(!can_interact(user))
		return NONE
	return eject_tape(user) ? CLICK_ACTION_SUCCESS : CLICK_ACTION_BLOCKING

/obj/machinery/dj_station/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DjStation")
		ui.open()

/obj/machinery/dj_station/ui_data(mob/user)
	var/datum/cassette_side/current_side = inserted_tape?.get_current_side()
	return list(
		"broadcasting" = broadcasting,
		"song_cooldown" = COOLDOWN_TIMELEFT(src, next_song_timer),
		"progress" = (song_start_time && playing?.duration) ? ((REALTIMEOFDAY - song_start_time) / (playing.duration * 1 SECONDS)) : 0,
		"side" = inserted_tape?.flipped,
		"current_song" = switching_tracks ? null : (current_side ? current_side.songs.Find(playing) - 1 : null),
		"switching_tracks" = switching_tracks,
	)

/obj/machinery/dj_station/ui_static_data(mob/user)
	. = list("cassette" = null)
	var/datum/cassette/cassette = inserted_tape?.cassette_data
	if(cassette)
		var/datum/cassette_side/side = inserted_tape.get_current_side()
		.["cassette"] = list(
			"name" = html_decode(cassette.name),
			"desc" = html_decode(cassette.desc),
			"author" = cassette.author?.name,
			"design" = side?.design || /datum/cassette_side::design,
			"songs" = list(),
		)
		for(var/datum/cassette_song/song as anything in side?.songs)
			.["cassette"]["songs"] += list(list(
				"name" = song.name,
				"url" = song.url,
				"length" = song.duration * 1 SECONDS, // convert to deciseconds
				"artist" = song.artist,
				"album" = song.album,
			))

/obj/machinery/dj_station/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .

	var/mob/user = ui.user
	testing("dj station [action]([json_encode(params)])")
	switch(action)
		if("eject", "play", "stop")
			if(switching_tracks)
				balloon_alert(user, "busy switching tracks!")
				return TRUE

	switch(action)
		if("eject")
			eject_tape(user)
			return TRUE
		if("play")
			. = TRUE
			if(is_ejecting)
				balloon_alert(user, "currently inserting/ejecting tape!")
				return
			if(!playing || !music_endpoint)
				balloon_alert(user, "no track set!")
				return
			if(broadcasting)
				balloon_alert(user, "song already playing!")
				return
			PLAY_CASSETTE_SOUND(SFX_DJSTATION_PLAY)
			song_start_time = REALTIMEOFDAY
			broadcasting = TRUE
			update_appearance(UPDATE_OVERLAYS)
			INVOKE_ASYNC(src, PROC_REF(play_to_all_listeners))
			SStgui.update_uis(src)
			log_music("[key_name(user)] began playing the track \"[playing.name]\" from [inserted_tape.name] ([inserted_tape.cassette_data?.id || "no cassette id"]) at [AREACOORD(src)]")
			message_admins("[ADMIN_LOOKUPFLW(user)] began playing the track \"[playing.name]\" from [inserted_tape.name] ([inserted_tape.cassette_data?.id || "no cassette id"])")
			begin_processing()
		if("stop")
			. = TRUE
			if(!playing || !broadcasting)
				balloon_alert(user, "not playing!")
				return
			if(is_ejecting)
				balloon_alert(user, "currently inserting/ejecting tape!")
				return
			end_processing()
			PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
			broadcasting = FALSE
			COOLDOWN_START(src, next_song_timer, song_cooldown)
			update_appearance(UPDATE_OVERLAYS)
			song_start_time = 0
			INVOKE_ASYNC(src, PROC_REF(stop_for_all_listeners))
			SStgui.update_uis(src)
			log_music("[key_name(user)] stopped playing song \"[playing.name]\" from [inserted_tape.name] ([inserted_tape.cassette_data?.id || "no cassette id"]) at [AREACOORD(src)]")
		if("set_track")
			. = TRUE
			if(switching_tracks)
				balloon_alert(user, "already switching tracks!")
				return
			if(broadcasting)
				balloon_alert(user, "stop the current track first!")
				return
			var/index = params["index"]
			if(!isnum(index))
				CRASH("tried to pass non-number index ([index]) to set_track??? this is prolly a bug.")
			index++
			if(!inserted_tape)
				balloon_alert(user, "no cassette tape inserted!")
				return

			if(!can_play_bootlegs && inserted_tape.cassette_data?.status != CASSETTE_STATUS_APPROVED)
				balloon_alert(user, "cannot play bootleg tapes!")
				return

			// Are both sides blank
			if(!length(inserted_tape.cassette_data?.front?.songs) && !length(inserted_tape.cassette_data?.back?.songs))
				balloon_alert(user, "this cassette is blank!")
				return
			var/list/cassette_songs = inserted_tape.get_current_side()?.songs

			var/song_count = length(cassette_songs)
			if(!song_count)
				balloon_alert(user, "no tracks on this side!")
				return
			var/datum/cassette_song/found_track = cassette_songs[index]
			if(!found_track)
				balloon_alert(user, "that track doesnt exist!")
				return
			if(playing && (cassette_songs.Find(playing) == index))
				PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
				balloon_alert(user, "already on that track!")
				return
			log_music("[key_name(user)] switched the track to \"[found_track.name]\" from [inserted_tape.name] ([inserted_tape.cassette_data?.id || "no cassette id"]) at [AREACOORD(src)]")
			switching_tracks = TRUE
			if(broadcasting)
				broadcasting = FALSE
				song_start_time = 0
				update_appearance(UPDATE_OVERLAYS)
				INVOKE_ASYNC(src, PROC_REF(stop_for_all_listeners))
			if(playing)
				PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
				sleep(0.2 SECONDS)
			switch_sound.start()
			SStgui.update_uis(src)
			COOLDOWN_START(src, fake_loading_time, 3 SECONDS)
			var/list/info = SSfloxy.download_and_wait(found_track.url, timeout = 30 SECONDS, discard_failed = TRUE)
			testing(fieldset_block("info for [html_encode(found_track.url)]", html_encode(json_encode(info, JSON_PRETTY_PRINT)), "boxed_message purple_box"))
			// fake loading time in case there's already a download cached and it returns immediately
			if(!COOLDOWN_FINISHED(src, fake_loading_time))
				// waow that was fast, are you failed,
				if(info["status"] == FLOXY_STATUS_FAILED)
					SSfloxy.delete_media(info["id"], hard = TRUE, force = TRUE)
					info = SSfloxy.download_and_wait(found_track.url, timeout = 30 SECONDS, discard_failed = TRUE)
				else
					var/remaining = rand(4, 8) SECONDS - COOLDOWN_TIMELEFT(src, fake_loading_time)
					testing("waiting extra [remaining] seconds to simulate loading time")
					sleep(remaining)
			if(info)
				playing = found_track
				if(length(info["endpoints"]))
					music_endpoint = info["endpoints"][1]
				else
					log_floxy("Floxy did not return a music endpoint for [found_track.url]")
					stack_trace("Floxy did not return a music endpoint for [found_track.url]")
					balloon_alert(user, "the loader mechanism malfunctioned!")
				var/list/metadata = info["metadata"]
				if(metadata)
					if(metadata["title"])
						playing.name = metadata["title"]
					if(metadata["artist"])
						playing.artist = metadata["artist"]
					if(metadata["album"])
						playing.album = metadata["album"]
					if(playing.duration <= 0 && metadata["duration"])
						playing.duration = metadata["duration"]
				playing_extra_data = list(
					"title" = playing.name,
					"link" = playing.url,
					"artist" = playing.artist,
					"album" = playing.album,
				)
				if(playing.duration > 0)
					playing_extra_data["duration"] = DisplayTimeText(playing.duration * 1 SECONDS)
			else
				playing = null
				playing_extra_data = null
				music_endpoint = null
				song_start_time = 0
				balloon_alert(user, "it got stuck! try again?")
				INVOKE_ASYNC(src, PROC_REF(stop_for_all_listeners))
			switching_tracks = FALSE
			SStgui.update_uis(src)
			switch_sound.stop()

// It cannot be stopped.
/obj/machinery/dj_station/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	return

/obj/machinery/dj_station/emp_act(severity)
	return

// Funny.
/obj/machinery/dj_station/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	SHOULD_CALL_PARENT(FALSE)
	visible_message(span_warning("[hitting_projectile] bounces harmlessly off of [src]!"))
	// doesn't actually do any damage, this is meant to annoy people when they try to shoot it bc someone played pickle rick
	hitting_projectile.damage = 0
	hitting_projectile.stamina = 0
	hitting_projectile.reflect(src)
	return BULLET_ACT_FORCE_PIERCE

// TODO: clean all of this shit up
/obj/machinery/dj_station/proc/play_to_all_listeners()
	if(GLOB.dj_booth != src || !broadcasting || !music_endpoint || !playing)
		return
	for(var/mob/listener as anything in GLOB.music_listeners)
		if(QDELETED(listener) || !listener.client?.fully_created || HAS_TRAIT(listener, TRAIT_LISTENING_TO_WALKMAN) || !listener.client?.prefs?.read_preference(/datum/preference/toggle/hear_music))
			continue
		listener.client?.tgui_panel?.play_music(music_endpoint, playing_extra_data)

/obj/machinery/dj_station/proc/stop_for_all_listeners()
	if(GLOB.dj_booth != src)
		return
	for(var/mob/listener as anything in GLOB.music_listeners)
		if(QDELETED(listener) || HAS_TRAIT(listener, TRAIT_LISTENING_TO_WALKMAN))
			continue
		listener.client?.tgui_panel?.stop_music()

/obj/machinery/dj_station/proc/on_listener_ready(mob/listener)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(play_for_listener), listener), 0.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/machinery/dj_station/proc/play_for_listener(mob/listener)
	if(GLOB.dj_booth != src || !broadcasting || !music_endpoint || !playing)
		return
	if(QDELETED(listener) || !HAS_TRAIT(listener, TRAIT_CAN_HEAR_MUSIC) || HAS_TRAIT(listener, TRAIT_LISTENING_TO_WALKMAN) || !listener.client?.prefs?.read_preference(/datum/preference/toggle/hear_music))
		return
	var/list/extra_data = playing_extra_data.Copy()
	var/start = floor((REALTIMEOFDAY - song_start_time) / 10)
	if(start > 0)
		extra_data["start"] = start
	listener.client?.tgui_panel?.play_music(music_endpoint, extra_data)

/obj/machinery/dj_station/proc/on_add_listener(datum/source, mob/listener)
	SIGNAL_HANDLER
	if(GLOB.dj_booth != src)
		return
	RegisterSignal(listener, COMSIG_TGUI_PANEL_READY, PROC_REF(on_listener_ready))
	if(!broadcasting || !playing || !music_endpoint || HAS_TRAIT(listener, TRAIT_LISTENING_TO_WALKMAN) || !listener.client?.prefs?.read_preference(/datum/preference/toggle/hear_music))
		return
	var/list/extra_data = playing_extra_data.Copy()
	var/start = floor((REALTIMEOFDAY - song_start_time) / 10)
	if(start > 0)
		extra_data["start"] = start
	listener.client?.tgui_panel?.play_music(music_endpoint, extra_data)

/obj/machinery/dj_station/proc/on_remove_listener(datum/source, mob/listener)
	SIGNAL_HANDLER
	UnregisterSignal(listener, COMSIG_TGUI_PANEL_READY)
	if(GLOB.dj_booth == src)
		listener.client?.tgui_panel?.stop_music()
