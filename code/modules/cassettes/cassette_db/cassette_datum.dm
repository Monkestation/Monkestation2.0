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

/// Imports cassette date from the old format.
/datum/cassette/proc/import_old_format(list/data)
	name = data["name"]
	desc = data["desc"]
	if("status" in data)
		status = data["status"]
	else
		status = data["approved"] ? CASSETTE_STATUS_APPROVED : CASSETTE_STATUS_UNAPPROVED

	author.name = data["author_name"]
	author.ckey = ckey(data["author_ckey"])

	for(var/i in 1 to 2)
		var/datum/cassette_side/side = get_side(i % 2) // side2 = 0, side1 = 1
		var/side_name = "side[i]"
		var/list/song_urls = data["songs"][side_name]
		var/list/song_names = data["song_names"][side_name]
		if(length(song_urls) != length(song_names))
			stack_trace("amount of song urls for [side_name] ([length(song_urls)]) did not match amount of song names for [side_name] ([length(song_names)])")
			continue
		side.design = data["[side_name]_icon"]
		for(var/idx in 1 to length(song_urls))
			side.songs += new /datum/cassette_song(song_names[idx], song_urls[idx])

/// Exports cassette date in the old format.
/datum/cassette/proc/export_old_format() as /list
	. = list(
		"name" = name,
		"desc" = desc,
		"side1_icon" = /datum/cassette_side::design,
		"side2_icon" = /datum/cassette_side::design,
		"author_name" = author.name,
		"author_ckey" = ckey(author.ckey),
		"approved" = status == CASSETTE_STATUS_APPROVED,
		"status" = status,
		"songs" = list(
			"side1" = list(),
			"side2" = list(),
		),
		"song_names" = list(
			"side1" = list(),
			"side2" = list(),
		),
	)
	for(var/i in 1 to 2)
		var/datum/cassette_side/side = get_side(i % 2) // side2 = 0, side1 = 1
		var/side_name = "side[i]"
		var/list/names = list()
		var/list/urls = list()
		.["[side_name]_icon"] = side.design
		for(var/datum/cassette_song/song as anything in side.songs)
			names += song.name
			urls += song.url
		.["song_names"][side_name] = names
		.["songs"][side_name] = urls

/// Saves the cassette to the data folder, in JSON format.
/datum/cassette/proc/save_to_file()
	if(!id)
		CRASH("Attempted to save cassette without an ID to disk")
	rustg_file_write(json_encode(export_old_format(), JSON_PRETTY_PRINT), CASSETTE_FILE(id))

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
		"front" = json_encode(front.export_for_db()),
		"back" = json_encode(back.export_for_db()),
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
/datum/cassette_side/proc/import_from_db(list/data)
	design = data["design"]
	for(var/list/song as anything in data["songs"])
		songs += new /datum/cassette_song(song["name"], song["url"], song["length"])

/// Exports data from this cassette side in the JSON format used by the database.
/datum/cassette_side/proc/export_for_db()
	. = list("design" = design, "songs" = list())
	for(var/datum/cassette_song/song as anything in songs)
		.["songs"] += list(list("name" = song.name, "url" = song.url, "length" = song.length))

/datum/cassette_side/Destroy(force)
	QDEL_LIST(songs)
	return ..()

/datum/cassette_song
	/// The name of the song.
	var/name
	/// The URL of the song.
	var/url
	/// The length of the song (in seconds)
	var/length

/datum/cassette_song/New(name, url, length)
	. = ..()
	src.name = name
	src.url = url
	src.length = isnum(length) ? max(length, 0) : 0
