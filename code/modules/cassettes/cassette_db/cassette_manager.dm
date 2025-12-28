SUBSYSTEM_DEF(cassettes)
	name = "Cassettes"
	init_order = INIT_ORDER_CASSETTES
	flags = SS_NO_FIRE
	/// An associative list of IDs to cassette data.
	var/list/datum/cassette/cassettes = list()

/datum/controller/subsystem/cassettes/Initialize()
	. = SS_INIT_FAILURE
	if(CONFIG_GET(flag/cassettes_in_db) && !CONFIG_GET(flag/sql_enabled))
		stack_trace("CASSETTES_IN_DB was enabled, despite the SQL database not being enabled! Disabling CASSETTES_IN_DB.")
		CONFIG_SET(flag/cassettes_in_db, FALSE)
	if(CONFIG_GET(flag/cassettes_in_db))
		if(!SSdbcore.Connect())
			CRASH("Database-based cassettes are enabled, but a connection to the database could not be established!")
		if(!load_all_cassettes_from_db())
			CRASH("Failed to load all cassettes from database!")
	else
		if(!load_all_cassettes_from_json())
			CRASH("Failed to load all cassettes from data folder!")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/cassettes/Recover()
	flags |= SS_NO_INIT
	cassettes = SScassettes.cassettes

/// Loads the cassette with the given ID.
/// If `db` is TRUE, it will load the cassette from the database.
/// If `db` is FALSE, the cassette will be loaded from a JSON in the `data/cassette_storage` folder.
/// If `db` is null (the default), it will load from the database if the `CASSETTES_IN_DB` config option is set, otherwise it will load from the JSON files.
/datum/controller/subsystem/cassettes/proc/load_cassette(id, db = null) as /datum/cassette
	if(!id)
		return null
	else if(istype(id, /datum/cassette)) // so i can be lazy
		return id
	if(id in cassettes)
		return cassettes[id]
	if(isnull(db))
		db = CONFIG_GET(flag/cassettes_in_db)
	var/datum/cassette/cassette_data = db ? load_cassette_from_db_raw(id) : load_cassette_from_json_raw(id)
	if(cassette_data)
		cassettes[id] = cassette_data
		return cassette_data

/// Loads the cassette with the given ID from a JSON in the `data/cassette_storage` folder.
/// This does not check the SScassettes.cassettes cache, and you should not use this - this is only used to initialize SScassettes.cassettes
/datum/controller/subsystem/cassettes/proc/load_cassette_from_json_raw(id) as /datum/cassette
	var/cassette_file = CASSETTE_FILE(id)
	if(!rustg_file_exists(cassette_file))
		return null
	var/cassette_file_data = rustg_file_read(cassette_file)
	if(!rustg_json_is_valid(cassette_file_data))
		CRASH("Cassette file [cassette_file] had invalid JSON!")
	var/list/cassette_json = json_decode(cassette_file_data)
	var/datum/cassette/cassette_data = new
	cassette_data.import(cassette_json)
	cassette_data.id = id
	return cassette_data

/// Loads the cassette with the given ID from the database.
/datum/controller/subsystem/cassettes/proc/load_cassette_from_db_raw(id) as /datum/cassette
	if(!SSdbcore.Connect() || !id)
		return
	var/datum/db_query/query_cassette = SSdbcore.NewQuery("SELECT `name`, `desc`, `status`, `author_name`, `author_ckey`, `front`, `back` FROM [format_table_name("cassettes")] WHERE `id` = :id", list("id" = id))
	if(!query_cassette.Execute() || !query_cassette.NextRow())
		qdel(query_cassette)
		return
	var/name = query_cassette.item[1]
	var/desc = query_cassette.item[2]
	var/status = query_cassette.item[3]
	var/author_name = query_cassette.item[4]
	var/author_ckey = query_cassette.item[5]
	var/list/front = json_decode(query_cassette.item[6])
	var/list/back = json_decode(query_cassette.item[7])
	qdel(query_cassette)

	var/datum/cassette/cassette = new
	cassette.id = id
	cassette.name = name
	cassette.desc = desc
	cassette.status = status
	cassette.author.name = author_name
	cassette.author.ckey = author_ckey
	cassette.front.import(front)
	cassette.back.import(back)
	return cassette

/// Returns an associative list of id to cassette datums, of all existing saved cassettes.
/// This uses the database.
/datum/controller/subsystem/cassettes/proc/load_all_cassettes_from_db()
	. = FALSE
	if(!SSdbcore.Connect())
		CRASH("Failed to connect to database")
	var/datum/db_query/query_cassettes = SSdbcore.NewQuery("SELECT `id`, `name`, `desc`, `status`, `author_name`, `author_ckey`, `front`, `back` FROM [format_table_name("cassettes")]")
	if(!query_cassettes.Execute())
		qdel(query_cassettes)
		CRASH("Failed to load cassettes from database")
	var/loaded = 0
	while(query_cassettes.NextRow())
		var/id = query_cassettes.item[1]
		var/name = query_cassettes.item[2]
		var/desc = query_cassettes.item[3]
		var/status = query_cassettes.item[4]
		var/author_name = query_cassettes.item[5]
		var/author_ckey = query_cassettes.item[6]
		var/list/front = json_decode(query_cassettes.item[7])
		var/list/back = json_decode(query_cassettes.item[8])

		var/datum/cassette/cassette = new
		cassette.id = id
		cassette.name = name
		cassette.desc = desc
		cassette.status = status
		cassette.author.name = author_name
		cassette.author.ckey = author_ckey
		cassette.front.import(front)
		cassette.back.import(back)

		cassettes[id] = cassette
		loaded++
	qdel(query_cassettes)
	log_music("Loaded [loaded] cassettes from the database!")
	return TRUE

/// Returns an associative list of id to cassette datums, of all existing saved cassettes.
/// This uses JSON files.
/datum/controller/subsystem/cassettes/proc/load_all_cassettes_from_json()
	. = FALSE
	if(!rustg_file_exists(CASSETTE_ID_FILE)) // this just means there's no cassettes at all i guess? which is valid.
		return TRUE
	var/list/ids = json_decode(rustg_file_read(CASSETTE_ID_FILE))
	for(var/id in ids)
		if(!ids)
			continue
		var/datum/cassette/cassette_data = load_cassette_from_json_raw(id)
		if(isnull(cassette_data))
			stack_trace("Failed to load cassette [id]")
			continue
		cassettes[id] = cassette_data
	return TRUE

/// Updates the ids.json file on-disk.
/datum/controller/subsystem/cassettes/proc/save_ids_json()
	var/list/ids = list()
	if(rustg_file_exists(CASSETTE_ID_FILE))
		// Verify that each cassette ID still exists and is still considered "approved" before adding them to the list.
		for(var/id in json_decode(rustg_file_read(CASSETTE_ID_FILE)))
			if(!rustg_file_exists(CASSETTE_FILE(id)))
				continue
			ids += id
	for(var/id, value in cassettes)
		var/datum/cassette/cassette = value
		if(cassette.status != CASSETTE_STATUS_APPROVED)
			ids -= id
		else
			ids |= id
	rustg_file_write(json_encode(ids), CASSETTE_ID_FILE)

/// Returns all the cassettes that match the given arguments.
/datum/controller/subsystem/cassettes/proc/filtered_cassettes(status, user_ckey, list/id_blacklist) as /list
	RETURN_TYPE(/list/datum/cassette)
	. = list()
	if(!isnull(user_ckey))
		user_ckey = ckey(user_ckey)
	for(var/id, value in cassettes)
		var/datum/cassette/cassette = value
		if(!isnull(id_blacklist) && (id in id_blacklist))
			continue
		if(!isnull(user_ckey) && ckey(cassette.author.ckey) != user_ckey)
			continue
		if(!isnull(status) && cassette.status != status)
			continue
		. += cassette

/// Returns a list containing up to the specified amount of random, unique cassettes that match the given arguments.
/datum/controller/subsystem/cassettes/proc/unique_random_cassettes(amount = 1, status = CASSETTE_STATUS_APPROVED, user_ckey, list/id_blacklist) as /list
	RETURN_TYPE(/list/datum/cassette)
	. = list()
	var/list/cassettes = filtered_cassettes(status, user_ckey, id_blacklist)
	for(var/i in 1 to min(amount, length(cassettes)))
		. += pick_n_take(cassettes)
