/mob
	/// The current media source being listened to, if any.
	var/datum/media_source/current_media_source
	/// A list of available media sources.
	var/list/datum/media_source/available_media_sources

/mob/Login()
	. = ..()
	current_media_source?.play_for_listener(src, client?.media_player, update_time = TRUE)

/mob/proc/add_media_source(datum/media_source/media_source)
	LAZYOR(available_media_sources, media_source)
	update_media_source()

/mob/proc/remove_media_source(datum/media_source/media_source)
	LAZYREMOVE(available_media_sources, media_source)
	update_media_source()

/mob/proc/update_media_source(force_update_time = FALSE)
	var/datum/media_player/media_player = client?.media_player
	if(!isnull(current_media_source) && (!LAZYLEN(available_media_sources) || QDELETED(src) || QDELING(current_media_source)))
		media_player?.stop()
		current_media_source.remove_listener(src)
		current_media_source = null
		return
	var/datum/media_source/best_source
	var/best_source_priority
	for(var/datum/media_source/media_source as anything in available_media_sources)
		if(!media_source.current_track?.url)
			continue
		var/priority = media_source.get_priority(src)
		if(priority == INFINITY)
			best_source = media_source
			break
		else if(priority <= 0)
			continue
		if(isnull(best_source) || priority > best_source_priority)
			best_source = media_source
			best_source_priority = priority
	if(isnull(best_source))
		media_player?.stop()
		current_media_source = null
		return
	var/should_update_time = force_update_time || (current_media_source != best_source)
	current_media_source = best_source
	if(!QDELETED(media_player))
		best_source.play_for_listener(src, media_player, should_update_time)

/mob/dead/new_player/Login()
	. = ..()
	GLOB.lobby_media.add_listener(src)

/mob/proc/update_media_volume(channel)
	if(isnull(current_media_source))
		return
	if(channel != CHANNEL_MASTER_VOLUME && (isnull(current_media_source.mixer_channel) || current_media_source.mixer_channel != "[channel]"))
		return
	var/new_volume = current_media_source.get_volume(src)
	client?.media_player?.set_volume(new_volume)
