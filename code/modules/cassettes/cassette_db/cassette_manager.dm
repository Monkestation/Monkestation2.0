SUBSYSTEM_DEF(cassettes)
	name = "Cassettes"
	init_order = INIT_ORDER_CASSETTES
	flags = SS_NO_FIRE
	/// An associative list of IDs to cassette data.
	var/list/datum/cassette/cassettes = list()

/datum/controller/subsystem/cassettes/Initialize()
	. = SS_INIT_FAILURE
	if(!load_all_cassettes_from_json())
		CRASH("Failed to load all cassettes from data folder!")
	return SS_INIT_SUCCESS

/datum/controller/subsystem/cassettes/Recover()
	flags |= SS_NO_INIT
	cassettes = SScassettes.cassettes

/// Loads the cassette with the given ID.
/datum/controller/subsystem/cassettes/proc/load_cassette(id) as /datum/cassette
	if(!id)
		return null
	else if(istype(id, /datum/cassette)) // so i can be lazy
		return id
	if(id in cassettes)
		return cassettes[id]
	var/datum/cassette/cassette_data = load_cassette_from_json_raw(id)
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
