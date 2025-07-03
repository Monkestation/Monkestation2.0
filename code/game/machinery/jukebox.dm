/// Advance to next song in the track list.
#define JUKEMODE_NEXT 1
/// Not shuffle, randomly picks next each time.
#define JUKEMODE_RANDOM 2
/// Play the same song over and over.
#define JUKEMODE_REPEAT_SONG 3
/// Play, then stop.
#define JUKEMODE_PLAY_ONCE 4

/obj/machinery/jukebox
	name = "space jukebox"
	desc = "Filled with songs both past and present!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "jukebox"
	base_icon_state = "jukebox"
	anchored = TRUE
	density = TRUE
	power_channel = AREA_USAGE_EQUIP
	use_power = IDLE_POWER_USE
	processing_flags = START_PROCESSING_MANUALLY
	/// If the jukebox is playing something right now.
	var/playing = FALSE
	/// The [REALTIMEOFDAY] of when the current track started.
	var/media_start_time = 0
	/// Current volume, in a range of 0 to 100.
	var/volume = 100
	/// What to do when a song finishes playing.
	var/loop_mode = JUKEMODE_PLAY_ONCE
	/// The current track being played.
	var/datum/media_track/current_track
	/// The media source tied to this jukebox.
	var/datum/media_source/object/media_source

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	media_source = new(volume = volume, mixer_channel = CHANNEL_JUKEBOX, source = src)

/obj/machinery/jukebox/Destroy()
	stop_playing()
	QDEL_NULL(media_source)
	current_track = null
	return ..()

/obj/machinery/jukebox/examine(mob/user)
	. = ..()
	if(playing && current_track)
		. += span_notice("It is currently playing <b>\"[current_track.title]\"</b>[current_track.artist ? " by <b>[current_track.artist]</b>" : ""].")

/obj/machinery/jukebox/update_icon_state()
	if(machine_stat & (NOPOWER | BROKEN))
		icon_state = "[base_icon_state]-broken"
	else if(playing)
		icon_state = "[base_icon_state]-active"
	else
		icon_state = base_icon_state
	return ..()

/obj/machinery/jukebox/atom_break(damage_flag)
	. = ..()
	if(.)
		stop_playing()

/obj/machinery/jukebox/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		stop_playing()

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MediaJukebox", "RetroBox - Space Style")
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	var/position = (playing && current_track) ? round(REALTIMEOFDAY - media_start_time) : 0
	return list(
		"playing" = playing,
		"loop_mode" = loop_mode,
		"volume" = volume,
		"position" = position,
		"current_track" = current_track?.get_data(),
	)

/obj/machinery/jukebox/ui_static_data(mob/user)
	var/list/tracks = list()
	for(var/datum/media_track/track as anything in available_tracks())
		tracks += list(track.get_data())
	return list("tracks" = tracks)

/obj/machinery/jukebox/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("set_track")
			var/datum/media_track/new_track = locate(params["ref"]) in available_tracks()
			if(istype(new_track) && new_track != current_track)
				start_playing(new_track)
			return TRUE
		if("set_loop_mode")
			var/static/list/valid_loop_modes = list(JUKEMODE_NEXT, JUKEMODE_RANDOM, JUKEMODE_REPEAT_SONG, JUKEMODE_PLAY_ONCE)
			var/new_loop_mode = text2num(params["mode"])
			loop_mode = sanitize_inlist(new_loop_mode, valid_loop_modes, loop_mode)
			return TRUE
		if("set_volume")
			set_volume(text2num(params["volume"]))
			return TRUE
		if("play")
			if(isnull(current_track))
				to_chat(user, span_warning("No track selected."))
			else
				start_playing(current_track)
			return TRUE
		if("stop")
			stop_playing()
			return TRUE

/obj/machinery/jukebox/process()
	if(!playing || !current_track?.url)
		return PROCESS_KILL
	var/end_time = media_start_time + current_track.duration
	if(REALTIMEOFDAY >= end_time)
		pick_next_song()

/obj/machinery/jukebox/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "extra songs unlocked")
	obj_flags |= EMAGGED
	update_static_data_for_all_viewers()
	return TRUE

/obj/machinery/jukebox/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/jukebox/proc/start_playing(datum/media_track/track)
	var/old_track = current_track
	track ||= current_track
	if(isnull(track))
		stop_playing()
		return
	playing = TRUE
	current_track = track
	media_start_time = REALTIMEOFDAY
	media_source.current_track = current_track
	media_source.volume = volume
	media_source.update_for_all_listeners()
	SStgui.update_uis(src)
	update_use_power(ACTIVE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	begin_processing()
	if(old_track != current_track)
		audible_message(span_notice("\The [src] begins to play [current_track.display()]"))

/obj/machinery/jukebox/proc/stop_playing()
	if(!playing)
		return
	end_processing()
	playing = FALSE
	current_track = null
	media_start_time = 0
	media_source.current_track = null
	media_source.update_for_all_listeners()
	SStgui.update_uis(src)
	update_use_power(IDLE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/jukebox/proc/set_volume(new_volume)
	if(!isnum(new_volume) || new_volume == volume)
		return
	volume = clamp(new_volume, 0, 100)
	media_source.volume = volume
	if(playing)
		media_source.update_for_all_listeners()

/obj/machinery/jukebox/proc/pick_next_song()
	var/list/tracks = available_tracks()
	switch(loop_mode)
		if(JUKEMODE_NEXT)
			var/current_track_index = max(1, tracks.Find(current_track))
			var/new_track_index = (current_track_index % length(tracks)) + 1  // Loop back around if past end
			start_playing(tracks[new_track_index])
		if(JUKEMODE_RANDOM)
			var/list/other_tracks = tracks - current_track
			if(length(other_tracks))
				start_playing(pick(other_tracks))
			else
				stop_playing()
		if(JUKEMODE_PLAY_ONCE)
			stop_playing()

/obj/machinery/jukebox/proc/available_tracks() as /list
	RETURN_TYPE(/list/datum/media_track)
	SHOULD_BE_PURE(TRUE)

	if(obj_flags & EMAGGED)
		return SSmedia_tracks.all_tracks
	else
		return SSmedia_tracks.jukebox_tracks

/obj/machinery/jukebox/unlocked
	name = "DRM-free space jukebox"
	desc = "Filled with songs both past and present, unlocked for your convenience!"

/obj/machinery/jukebox/unlocked/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/machinery/jukebox/unlocked/available_tracks()
	return SSmedia_tracks.all_tracks

#undef JUKEMODE_PLAY_ONCE
#undef JUKEMODE_REPEAT_SONG
#undef JUKEMODE_RANDOM
#undef JUKEMODE_NEXT
