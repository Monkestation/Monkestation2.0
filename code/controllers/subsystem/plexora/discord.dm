// Procs transferred from the previous Discord subsystem

/**
 * Given a ckey, look up the discord user id attached to the user, if any
 *
 * This gets the most recent entry from the discord link table that is associated with the given ckey
 *
 * Arguments:
 * * lookup_ckey A string representing the ckey to search on
 */
/datum/controller/subsystem/plexora/proc/lookup_id(lookup_ckey)
	var/datum/discord_link_record/link = find_discord_link_by_ckey(lookup_ckey, only_valid = TRUE)
	if(link)
		return link.discord_id

/**
 * Given a discord id as a string, look up the ckey attached to that account, if any
 *
 * This gets the most recent entry from the discord_link table that is associated with this discord id snowflake
 *
 * Arguments:
 * * lookup_id The discord id as a string
 */
/datum/controller/subsystem/plexora/proc/lookup_ckey(lookup_id)
	var/datum/discord_link_record/link = find_discord_link_by_discord_id(lookup_id, only_valid = TRUE)
	if(link)
		return link.ckey

/datum/controller/subsystem/plexora/proc/get_or_generate_one_time_token_for_ckey(ckey)
	// Is there an existing valid one time token
	var/datum/discord_link_record/link = find_discord_link_by_ckey(ckey)
	if(link)
		return link.one_time_token

	// Otherwise we make one
	return generate_one_time_token(ckey)

/**
 * Generate a token for discord verification
 *
 * This uses the common word list to generate a six word random token, this token can then be fed to a discord bot that has access
 * to the same database, and it can use it to link a ckey to a discord id, with minimal user effort
 *
 * It returns the token to the calling proc, after inserting an entry into the discord_link table of the following form
 *
 * ```
 * (unique_id, ckey, null, the current time, the one time token generated)
 * the null value will be filled out with the discord id by the integrated discord bot when a user verifies
 * ```
 *
 * Notes:
 * * The token is guaranteed to be unique during it's validity period
 * * ~~The validity period is currently set at 4 hours~~
 * * ~~a token may not be unique outside it's validity window (to reduce conflicts)~~
 *
 * Arguments:
 * * ckey_for a string representing the ckey this token is for
 *
 * Returns a string representing the one time token
 */
/datum/controller/subsystem/plexora/proc/generate_one_time_token(ckey_for)

	var/not_unique = TRUE
	var/one_time_token = ""
	// While there's a collision in the token, generate a new one (should rarely happen)
	while(not_unique)
		//Column is varchar 100, so we trim just in case someone does us the dirty later
		one_time_token = trim(uppertext("PLX-VERIFY-[trim(ckey_for, 5)]-[random_string(4, GLOB.hex_characters)]-[random_string(4, GLOB.hex_characters)]"), 100)

		not_unique = find_discord_link_by_token(one_time_token)

	// Insert into the table, null in the discord id, id and timestamp and valid fields so the db fills them out where needed
	var/datum/db_query/query_insert_link_record = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("discord_links")] (ckey, one_time_token) VALUES(:ckey, :token)",
		list("ckey" = ckey_for, "token" = one_time_token)
	)

	if(!query_insert_link_record.Execute())
		qdel(query_insert_link_record)
		return ""

	//Cleanup
	qdel(query_insert_link_record)
	return one_time_token

/**
 * Find discord link entry by the passed in user token
 *
 * This will look into the discord link table and return the *first* entry that matches the given one time token
 *
 * Remember, multiple entries can exist, as they are only guaranteed to be unique for their validity period
 *
 * Arguments:
 * * one_time_token the string of words representing the one time token
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/plexora/proc/find_discord_link_by_token(one_time_token)
	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE one_time_token = :one_time_token GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("one_time_token" = one_time_token)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return
	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)

/**
 * Find discord link entry by the passed in user ckey
 *
 * This will look into the discord link table and return the *first* entry that matches the given ckey
 *
 * Remember, multiple entries can exist
 *
 * Arguments:
 * * ckey the users ckey as a string
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/plexora/proc/find_discord_link_by_ckey(ckey, only_valid = FALSE)
	var/validsql = ""
	if(only_valid)
		validsql = "AND valid = 1"

	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE ckey = :ckey [validsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("ckey" = ckey)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return

	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)


/**
 * Find discord link entry by the passed in user ckey
 *
 * This will look into the discord link table and return the *first* entry that matches the given ckey
 *
 * Remember, multiple entries can exist
 *
 * Arguments:
 * * discord_id The users discord id (string)
 *
 * Returns a [/datum/discord_link_record]
 */
/datum/controller/subsystem/plexora/proc/find_discord_link_by_discord_id(discord_id, only_valid = FALSE)
	var/validsql = ""
	if(only_valid)
		validsql = "AND valid = 1"

	var/query = "SELECT CAST(discord_id AS CHAR(25)), ckey, MAX(timestamp), one_time_token FROM [format_table_name("discord_links")] WHERE discord_id = :discord_id [validsql] GROUP BY ckey, discord_id, one_time_token LIMIT 1"
	var/datum/db_query/query_get_discord_link_record = SSdbcore.NewQuery(
		query,
		list("discord_id" = discord_id)
	)
	if(!query_get_discord_link_record.Execute())
		qdel(query_get_discord_link_record)
		return

	if(query_get_discord_link_record.NextRow())
		var/result = query_get_discord_link_record.item
		. = new /datum/discord_link_record(result[2], result[1], result[4], result[3])

	//Make sure we clean up the query
	qdel(query_get_discord_link_record)


/**
 * Extract a discord id from a mention string
 *
 * This will regex out the mention <@num> block to extract the discord id
 *
 * Arguments:
 * * discord_id The users discord mention string (string)
 *
 * Returns a text string with the discord id or null
 */
/datum/controller/subsystem/plexora/proc/get_discord_id_from_mention(mention)
	var/static/regex/discord_mention_extraction_regex = regex(@"<@([0-9]+)>")
	discord_mention_extraction_regex.Find(mention)
	if (length(discord_mention_extraction_regex.group) == 1)
		return discord_mention_extraction_regex.group[1]
	return null
