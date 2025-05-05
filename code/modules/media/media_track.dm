/// Music track available for playing in a media machine.
/datum/media_track
	/// URL to load song from.
	var/url
	/// The title of the song.
	var/title
	/// The song's length in deciseconds.
	var/duration
	/// The song's creator.
	var/artist
	/// The song's musical genre.
	var/genre
	// Should this show up in the regular playlist or secret playlist?
	var/secret = FALSE
	/// Should this be available as an option for lobby music?
	var/lobby = FALSE

/datum/media_track/New(url, title, duration, artist = "", genre = "", secret = FALSE, lobby = FALSE)
	src.url = url
	src.title = title
	src.artist = artist
	src.genre = genre
	src.duration = duration
	src.secret = secret
	src.lobby = lobby

/datum/media_track/proc/display()
	SHOULD_BE_PURE(TRUE)
	. = "\"[title]\""
	if(artist)
		. += " by [artist]"

/datum/media_track/proc/get_data() as /list
	return list(
		"ref" = REF(src),
		"title" = title,
		"artist" = artist,
		"genre" = genre,
		"duration" = duration,
	)
