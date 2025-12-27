/datum/cassette
	/// The unique ID of the cassette.
	var/id
	/// The name of the cassette.
	var/name
	/// The description of the cassette.
	var/desc
	/// The status of this cassette.
	var/status = CASSETTE_STATUS_UNAPPROVED
	/// Information about the author of this cassette.
	var/datum/cassette_author/author

	/// The front side of the cassette.
	var/datum/cassette_side/front
	/// The back side of the cassette.
	var/datum/cassette_side/back

/datum/cassette/New()
	. = ..()
	author = new
	front = new
	back = new

/datum/cassette/Destroy(force)
	QDEL_NULL(author)
	QDEL_NULL(front)
	QDEL_NULL(back)
	return ..()

/// Create a copy of this cassette.
/datum/cassette/proc/copy() as /datum/cassette
	var/datum/cassette/cassette = new
	cassette.import(export()) // lazy
	return cassette

/// Imports cassette data from JSON/list.
/datum/cassette/proc/import(list/data)
	if("id" in data)
		id = data["id"]
	name = data["name"]
	desc = data["desc"]
	if("status" in data)
		status = data["status"]
	else
		status = data["approved"] ? CASSETTE_STATUS_APPROVED : CASSETTE_STATUS_UNAPPROVED

	author.name = data["author_name"]
	author.ckey = ckey(data["author_ckey"])

	for(var/side_name, side_data in data["songs"])
		var/datum/cassette_side/side
		if(side_name == "side1")
			side = front
		else if(side_name == "side2")
			side = back
		else
			stack_trace("Unexpected side name '[side_name]' in cassette [name]")
			continue
		side.design = side_data["icon"] || /datum/cassette_side::design
		for(var/list/track as anything in side_data["tracks"])
			side.songs += new /datum/cassette_song(track["title"], track["url"], track["duration"], track["artist"], track["album"])

/// Exports cassette date in the old format.
/datum/cassette/proc/export() as /list
	. = list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"status" = status,
		"author_name" = author.name,
		"author_ckey" = author.ckey,
		"songs" = list(
			"side1" = list(),
			"side2" = list(),
		),
	)
	for(var/i in 1 to 2)
		var/datum/cassette_side/side = get_side(i % 2) // side2 = 0, side1 = 1
		.["songs"]["side[i]"] = side.export()

/// Saves the cassette to the data folder, in JSON format.
/datum/cassette/proc/save_to_file()
	if(!id)
		CRASH("Attempted to save cassette without an ID to disk")
	log_music("Saving cassette [id] to [CASSETTE_FILE(id)]")
	rustg_file_write(json_encode(export(), JSON_PRETTY_PRINT), CASSETTE_FILE(id))
	if(!rustg_file_exists(CASSETTE_FILE(id)))
		CRASH("okay wtf we failed to save cassette [id], check folder permissions!!")

/// Saves the cassette to the database.
/// Returns TRUE if successful, FALSE otherwise.
/datum/cassette/proc/save_to_db()
	. = FALSE
	if(!id)
		CRASH("Attempted to save cassette without an ID to database")
	if(!SSdbcore.Connect())
		CRASH("Could not save cassette [id], database not connected")
	var/datum/db_query/query_save_cassette = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("cassettes")]
			(id, name, desc, status, author_name, author_ckey, front, back)
		VALUES
			(:id, :name, :desc, :status, :author_name, :author_ckey, :front, :back)
		ON DUPLICATE KEY UPDATE
			name = VALUES(name),
			desc = VALUES(desc),
			status = VALUES(status),
			author_name = VALUES(author_name),
			author_ckey = VALUES(author_ckey),
			front = VALUES(front),
			back = VALUES(back)
	"}, list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"status" = status,
		"author_name" = author.name,
		"author_name" = ckey(author.ckey),
		"front" = json_encode(front.export()),
		"back" = json_encode(back.export()),
	))
	if(!query_save_cassette.warn_execute())
		qdel(query_save_cassette)
		CRASH("Failed to save cassette [id] to database")
	qdel(query_save_cassette)
	return TRUE


/// Simple helper to get a side of the cassette.
/// TRUE is front side, FALSE is back side.
/datum/cassette/proc/get_side(front_side = TRUE) as /datum/cassette_side
	return front_side ? front : back

/// Returns a list of all the song names in this cassette.
/// Really only useful for searching for cassettes via contained song names.
/datum/cassette/proc/list_song_names() as /list
	. = list()
	for(var/datum/cassette_song/song as anything in front.songs + back.songs)
		. |= song.name

/datum/cassette_author
	/// The character name of the cassette author.
	var/name
	/// The ckey of the cassette author.
	var/ckey

/datum/cassette_side
	/// The design of this side of the cassette.
	var/design = "cassette_flip"
	/// The songs on this side of the cassette.
	var/list/datum/cassette_song/songs = list()

/// Imports data for this cassette side to the JSON format used by the database.
/datum/cassette_side/proc/import(list/data)
	design = data["icon"]
	for(var/list/song_data as anything in data["tracks"])
		var/datum/cassette_song/song = new
		song.import(song_data)
		songs += song

/// Exports data from this cassette side in the JSON format used by the database.
/datum/cassette_side/proc/export()
	. = list("icon" = design, "tracks" = list())
	for(var/datum/cassette_song/song as anything in songs)
		.["tracks"] += list(song.export())

/datum/cassette_side/Destroy(force)
	QDEL_LIST(songs)
	return ..()

/datum/cassette_song
	/// The name of the song.
	var/name
	/// The URL of the song.
	var/url
	/// The duration of the song (in seconds)
	var/duration = 0
	var/artist
	var/album

/datum/cassette_song/New(name, url, duration, artist, album)
	. = ..()
	src.name = name
	src.url = url
	src.duration = isnum(duration) ? max(duration, 0) : 0
	src.artist = artist
	src.album = album

/datum/cassette_song/proc/import(list/data)
	name = data["title"]
	url = data["url"]
	duration = data["duration"]
	artist = data["artist"]
	album = data["album"]

/datum/cassette_song/proc/export()
	return list(
		"title" = name,
		"url" = url,
		"duration" = duration,
		"artist" = artist,
		"album" = album,
	)

/datum/cassette_song/proc/operator""()
	return "[name || "Untitled Song"]"
