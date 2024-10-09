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

/datum/internet_audio/New(url)
	var/wrapper_url = CONFIG_GET(string/invoke_youtubedl)
	if(!wrapper_url)
		error = "yt-dlp not configured!"
		CRASH("yt-dlp not configured!")
	if(!istext(url))
		error = "Internet audio initialized with invalid URL: [url]"
		CRASH("/datum/internet_audio initialize with invalid URL: [url]")
	url = trimtext(url)
	if(!length(url))
		error = "Internet audio initialized with blank URL"
		CRASH("/datum/internet_audio initialized with blank URL")

/datum/internet_audio/proc/fetch(url)
	if(error)
		return FALSE
	var/yt_dlp = CONFIG_GET(string/invoke_youtubedl)
	var/list/output = world.shelleo("[yt_dlp] --geo-bypass --extractor-args \"youtube:lang=en,skip=translated_subs\" --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height <= 360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_url_scrub(url)]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = trimtext(output[SHELLEO_STDOUT])
	var/stderr = trimtext(output[SHELLEO_STDERR])
	if(errorlevel)
		error = "[stderr || "(null)"]"
		return FALSE
	var/list/data
	try
		data = json_decode(stdout)
	catch(var/exception/e)
		error = "[e]: [stdout]"
		return FALSE

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

