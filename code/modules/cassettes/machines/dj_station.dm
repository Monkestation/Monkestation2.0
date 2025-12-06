#define PLAY_CASSETTE_SOUND(sfx) playsound(src, ##sfx, vol = 90, vary = FALSE, mixer_channel = CHANNEL_MACHINERY)

GLOBAL_DATUM(dj_booth, /obj/machinery/dj_station)

/obj/item/clothing/ears
	//can we be used to listen to radio?
	var/radio_compat = FALSE

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

	var/is_ejecting = FALSE
	var/broadcasting = FALSE
	/// Are we currently switching tracks?
	var/switching_tracks = FALSE
	/// The currently inserted cassette, if any.
	var/obj/item/cassette_tape/inserted_tape
	/// The song currently being played, if any.
	var/datum/cassette_song/playing
	/// The direct URL endpoint of the song being played.
	var/music_endpoint
	/// The REALTIMEOFDAY that the current song was started.
	var/song_start_time
	/// Looping sound used when switching cassette tracks.
	var/datum/looping_sound/cassette_track_switch/switch_sound

	COOLDOWN_DECLARE(next_song_timer)

/obj/machinery/dj_station/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	register_context()
	if(QDELETED(GLOB.dj_booth))
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
		for(var/mob/listener as anything in GLOB.music_listeners)
			if(QDELETED(listener))
				continue
			listener.client?.tgui_panel?.stop_music()
		GLOB.dj_booth = null
	return ..()

/obj/machinery/dj_station/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(istype(held_item, /obj/item/cassette_tape))
		context[SCREENTIP_CONTEXT_LMB] = inserted_tape ? "Swap Tape" : "Insert Tape"
	else if(!held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Open UI"

	if(inserted_tape)
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Eject Tape"

/obj/machinery/dj_station/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/cassette_tape))
		return NONE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	if(is_ejecting)
		balloon_alert(user, "already inserting/ejecting")
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
		balloon_alert(user, "already ejecting!")
		return
	if(!inserted_tape)
		balloon_alert(user, "no tape inserted!")
		return
	is_ejecting = TRUE
	PLAY_CASSETTE_SOUND(SFX_DJSTATION_OPENTAKEOUTANDCLOSE)
	if (!do_after(user, 1.5 SECONDS, src))
		is_ejecting = FALSE
		return
	inserted_tape.forceMove(drop_location())
	is_ejecting = FALSE
	if(user)
		balloon_alert(user, "tape ejected")
		user.put_in_hands(inserted_tape)
		inserted_tape = null
		update_static_data_for_all_viewers()

/obj/machinery/dj_station/click_ctrl(mob/user)
	if(!can_interact(user))
		return NONE
	if(is_ejecting)
		balloon_alert(user, "busy ejecting tape!")
		return CLICK_ACTION_BLOCKING
	if(switching_tracks)
		balloon_alert(user, "busy switching tracks!")
		return CLICK_ACTION_BLOCKING
	eject_tape(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/dj_station/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DjStation")
		ui.open()

/obj/machinery/dj_station/ui_data(mob/user)
	return list(
		"broadcasting" = broadcasting,
		"song_cooldown" = COOLDOWN_TIMELEFT(src, next_song_timer),
		"progress" = (song_start_time && playing?.duration) ? ((REALTIMEOFDAY - song_start_time) / (playing.duration * 1 SECONDS)) : 0,
		"side" = inserted_tape?.flipped,
		"current_song" = switching_tracks ? null : (inserted_tape?.cassette_data ? inserted_tape.cassette_data.get_side(!inserted_tape.flipped).songs.Find(playing) - 1 : null),
		"switching_tracks" = switching_tracks,
	)

/obj/machinery/dj_station/ui_static_data(mob/user)
	. = list("cassette" = null)
	var/datum/cassette/cassette = inserted_tape?.cassette_data
	if(cassette)
		var/datum/cassette_side/side = cassette.get_side()
		.["cassette"] = list(
			"name" = cassette.name,
			"desc" = cassette.desc,
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
			PLAY_CASSETTE_SOUND(SFX_DJSTATION_PLAY)
			if(!playing || !music_endpoint)
				balloon_alert(user, "no track set!")
				return
			song_start_time = REALTIMEOFDAY
			broadcasting = TRUE
			INVOKE_ASYNC(src, PROC_REF(play_to_all_listeners))
			SStgui.update_uis(src)
		if("stop")
			. = TRUE
			PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
			if(!playing || !broadcasting)
				balloon_alert(user, "not playing!")
				return
			PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
			broadcasting = FALSE
			song_start_time = 0
			INVOKE_ASYNC(src, PROC_REF(stop_for_all_listeners))
			SStgui.update_uis(src)
		if("set_track")
			. = TRUE
			if(switching_tracks)
				balloon_alert(user, "already switching tracks!")
				return
			var/index = params["index"]
			if(!isnum(index))
				CRASH("tried to pass non-number index ([index]) to set_track??? this is prolly a bug.")
			index++
			if(!inserted_tape)
				balloon_alert(user, "no cassette tape inserted!")
				return

			// switch(inserted_tape.cassette_data.status)
			// 	if (CASSETTE_STATUS_UNAPPROVED)

			// Are both sides blank
			if(!length(inserted_tape.cassette_data?.front?.songs) || !length(inserted_tape.cassette_data?.back?.songs))
				balloon_alert(user, "this cassette is blank!")
				return
			var/list/cassette_songs = inserted_tape.cassette_data.get_side(!inserted_tape.flipped).songs

			var/song_count = length(cassette_songs)
			if(!song_count)
				balloon_alert(user, "no tracks on this side!")
				return
			if (!inserted_tape)
				balloon_alert(user, "no tape inserted!")
				return
			var/datum/cassette_song/found_track = cassette_songs[index]
			if(!found_track)
				balloon_alert(user, "that track doesnt exist!")
				return
			if(playing && (cassette_songs.Find(playing) == index))
				PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
				balloon_alert(user, "already on that track!")
				return
			switching_tracks = TRUE
			if(broadcasting)
				broadcasting = FALSE
				song_start_time = 0
				INVOKE_ASYNC(src, PROC_REF(stop_for_all_listeners))
			if(playing)
				PLAY_CASSETTE_SOUND(SFX_DJSTATION_STOP)
				sleep(0.2 SECONDS)
			switch_sound.start()
			SStgui.update_uis(src)
			var/list/info = SSfloxy.download_and_wait(found_track.url, timeout = 30 SECONDS, discard_failed = TRUE)
			testing(fieldset_block("info for [html_encode(found_track.url)]", html_encode(json_encode(info, JSON_PRETTY_PRINT)), "boxed_message purple_box"))
			if(info)
				playing = found_track
				if(length(info["endpoints"]))
					music_endpoint = info["endpoints"][1]
				else
					log_floxy("Floxy did not return a music endpoint for [found_track.url]")
					stack_trace("Floxy did not return a music endpoint for [found_track.url]")
				var/list/metadata = info["metadata"]
				if(playing.duration <= 0 && metadata?["duration"])
					playing.duration = metadata["duration"]
			else
				playing = null
				music_endpoint = null
				song_start_time = 0
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
	hitting_projectile.debilitating = FALSE
	hitting_projectile.reflect(src)
	return BULLET_ACT_FORCE_PIERCE

/obj/machinery/dj_station/proc/play_to_all_listeners()
	if(GLOB.dj_booth != src || !broadcasting || !music_endpoint || !playing)
		return
	var/list/extra_data = list(
		"title" = playing.name,
		"link" = playing.url,
		"artist" = playing.artist,
		"album" = playing.album,
	)
	if(playing.duration > 0)
		extra_data["duration"] = DisplayTimeText(playing.duration * 1 SECONDS)
	for(var/mob/listener as anything in GLOB.music_listeners)
		if(QDELETED(listener) || !listener.client?.fully_created)
			continue
		listener.client?.tgui_panel?.play_music(music_endpoint, extra_data)

/obj/machinery/dj_station/proc/stop_for_all_listeners()
	if(GLOB.dj_booth != src)
		return
	for(var/mob/listener as anything in GLOB.music_listeners)
		if(QDELETED(listener))
			continue
		listener.client?.tgui_panel?.stop_music()

/obj/machinery/dj_station/proc/on_add_listener(datum/source, mob/listener)
	SIGNAL_HANDLER
	if(GLOB.dj_booth != src || !broadcasting || !playing || !music_endpoint)
		return
	var/list/extra_data = list(
		"title" = playing.name,
		"link" = playing.url,
		"artist" = playing.artist,
		"album" = playing.album,
	)
	var/start = floor((REALTIMEOFDAY - song_start_time) / 10)
	if(start > 0)
		extra_data["start"] = start
	if(playing.duration > 0)
		extra_data["duration"] = DisplayTimeText(playing.duration * 1 SECONDS)
	listener.client?.tgui_panel?.play_music(music_endpoint, extra_data)

/obj/machinery/dj_station/proc/on_remove_listener(datum/source, mob/listener)
	SIGNAL_HANDLER
	if(GLOB.dj_booth == src)
		listener.client?.tgui_panel?.stop_music()

#undef PLAY_CASSETTE_SOUND
