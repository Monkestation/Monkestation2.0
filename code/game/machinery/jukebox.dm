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

/obj/machinery/jukebox/Destroy()
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

/obj/machinery/jukebox/ui_data(mob/user)
	return list(
		"playing" = playing,
		"loop_mode" = loop_mode,
		"volume" = volume,
		"progress" = (playing && current_track) ? min(100, round(REALTIMEOFDAY - media_start_time) / current_track.duration) : 0,
		"current_track" = current_track?.get_data(),
	)

/obj/machinery/jukebox/ui_static_data(mob/user)
	var/list/tracks = list()
	for(var/datum/media_track/track as anything in available_tracks())
		tracks += list(track.get_data())
	return list("tracks" = tracks)

/obj/machinery/jukebox/proc/available_tracks() as /list
	RETURN_TYPE(/list/datum/media_track)
	SHOULD_BE_PURE(TRUE)

	if(obj_flags & EMAGGED)
		return SSmedia_tracks.all_tracks
	else
		return SSmedia_tracks.jukebox_tracks

#undef JUKEMODE_PLAY_ONCE
#undef JUKEMODE_REPEAT_SONG
#undef JUKEMODE_RANDOM
#undef JUKEMODE_NEXT
