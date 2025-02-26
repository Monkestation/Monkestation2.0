/// Represents a record from the discord link table in a nicer format
/datum/discord_link_record
	var/ckey
	var/discord_id
	var/one_time_token
	var/timestamp
	var/cached_state
	var/cached_timestamp
	var/cached_username

/**
 * Generate a discord link datum from the values
 *
 * This is only used by SSplexora wrapper functions for now, so you can reference the fields
 * slightly easier
 *
 * Arguments:
 * * ckey Ckey as a string
 * * discord_id Discord id as a string
 * * one_time_token as a string
 * * timestamp as a string
 * * cached_state as a number (0-255)
 * * cached_date
 */
/datum/discord_link_record/New(ckey, discord_id, one_time_token, timestamp, cached_state, cached_timestamp, cached_username)
	src.ckey = ckey
	src.discord_id = discord_id
	src.one_time_token = one_time_token
	src.timestamp = timestamp
	src.cached_state = cached_state
	src.cached_timestamp = cached_timestamp
	src.cached_username = cached_username
