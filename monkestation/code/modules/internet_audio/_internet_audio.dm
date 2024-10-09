GLOBAL_DATUM(current_global_audio, /datum/internet_audio)
GLOBAL_LIST_EMPTY_TYPED(cached_internet_audio, /datum/internet_audio)

/datum/internet_audio
	/// The title of the original audio, if available.
	var/title
	/// The original (user-facing) webpage of the audio.
	var/webpage_url
	/// The URL to the audio to be played itself.
	var/sound_url
	/// The duration of the audio, in deciseconds.
	var/duration
	/// How far into the audio should it start playing, in deciseconds.
	/// Defaults to 0, playing from the beginning.
	var/start = 0
	/// Where the audio should end, in deciseconds.
	/// Defaults to the duration.
	var/end
	/// The upload date of the audio, in human-readable format.
	var/upload_date
	/// The uploading channel of the audio, if provided.
	var/channel
	/// The artist(s) of the audio, if provided.
	var/artist
	/// The album of the audio, if provided.
	var/album
	/// The track of the audio, if provided.
	var/track
	/// Set to TRUE whenever the data has been successfully fetched and the variables set.
	var/success = FALSE
	/// If fetching results in an error, this will be set to the error data.
	var/error
	/// The time this audio started playing.
	var/started_at
	/// The HTTP request job used when fetching the audio data.
	VAR_PRIVATE/datum/http_request/request

/datum/internet_audio/New(url)
	var/wrapper_url = CONFIG_GET(string/yt_wrap_url)
	if(!wrapper_url)
		error = "ss13-yt-wrap not configured!"
		CRASH("ss13-yt-wrap not configured!")
	if(!istext(url))
		error = "Internet audio initialized with invalid URL: [url]"
		CRASH("/datum/internet_audio initialize with invalid URL: [url]")
	url = trimtext(url)
	if(!length(url))
		error = "Internet audio initialized with blank URL"
		CRASH("/datum/internet_audio initialized with blank URL")
	request = new
	request.prepare(RUSTG_HTTP_METHOD_GET, "[wrapper_url]/get", json_encode(list("url" = url)))
	request.begin_async()

/datum/internet_audio/Destroy(force)
	if(GLOB.current_global_audio == src)
		GLOB.current_global_audio = null
	for(var/id in GLOB.cached_internet_audio)
		if(GLOB.cached_internet_audio[id] == src)
			GLOB.cached_internet_audio -= id
	QDEL_NULL(request)
	return ..()

/datum/internet_audio/proc/wait(timeout = 15 SECONDS)
	if(success)
		return TRUE
	else if(error)
		return FALSE
	else if(!request)
		CRASH("/datum/internet_audio tried to wait, even tho we never initiated a request")
	var/end_time = REALTIMEOFDAY + timeout
	while(!request.is_complete())
		if(REALTIMEOFDAY > end_time)
			error = "Timed out after [DisplayTimeText(timeout)]"
			return FALSE
		stoplag()
	var/datum/http_response/response = request.into_response()
	if(response.errored)
		error = response.error
		CRASH("Retrieving internet audio errored: [response.error]")
	else if(response.status_code != 200)
		error = response.body
		CRASH("Retrieving internet audio returned non-200 status code ([response.status_code]): [response.body]")
	else if(!rustg_json_is_valid(response.body))
		var/body = response.body || "(null)"
		error = "invalid JSON: [body]"
		CRASH("Retrieving internet audio returned invalid JSON: [body]")
	set_media_info(json_decode(response.body))
	if(!GLOB.cached_internet_audio[webpage_url] || GLOB.cached_internet_audio[webpage_url].error)
		GLOB.cached_internet_audio[webpage_url] = src
	return TRUE

/datum/internet_audio/proc/set_media_info(list/media_info)
	PRIVATE_PROC(TRUE)
	title = media_info["title"]
	webpage_url = media_info["webpage_url"]
	sound_url = media_info["sound_url"]
	duration = media_info["duration"] * 1 SECONDS
	start = media_info["start"] * 1 SECONDS
	end = media_info["end"] * 1 SECONDS
	upload_date = media_info["upload_date"]
	channel = media_info["channel"] || "N/A"
	artist = media_info["artist"] || "N/A"
	album = media_info["album"] || "N/A"
	track = media_info["track"] || "N/A"
	success = TRUE

/datum/internet_audio/proc/current_playtime()
	if(!started_at)
		return 0
	return clamp(REALTIMEOFDAY - started_at, 0, end - start)

/datum/internet_audio/proc/get_time_left()
	var/true_duration = end - start
	if(!started_at)
		return true_duration
	return clamp((started_at + true_duration) - REALTIMEOFDAY, 0, true_duration)

/datum/internet_audio/proc/play_to_client(client/client, show_info = TRUE)
	if(!success)
		CRASH("Tried to play internet audio to client, even though it failed to successfully fetch media info!")
	if(!istype(client) || QDELING(client))
		return FALSE
	var/list/media_data = list(
		"title" = show_info ? title : "Song Title Hidden",
		"link" = show_info ? webpage_url : "Song Link Hidden",
		"start" = (current_playtime() + start) / 10,
		"end" = end / 10,
		"duration" = DisplayTimeText(duration),
		"upload_date" = upload_date || "Unknown Date",
	)
	client.tgui_panel?.play_music(sound_url, media_data)

/proc/fetch_internet_audio_cached(url) as /datum/internet_audio
	RETURN_TYPE(/datum/internet_audio)
	if(!istext(url))
		CRASH("Passed invalid non-text url: [url]")
	url = trimtext(url)
	if(GLOB.cached_internet_audio[url])
		var/datum/internet_audio/cached_audio = GLOB.cached_internet_audio[url]
		if(!cached_audio.error)
			return cached_audio
	return GLOB.cached_internet_audio[url] = new /datum/internet_audio(url)

