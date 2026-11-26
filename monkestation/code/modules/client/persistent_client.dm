/datum/persistent_client
	/// Patreon data for this player.
	var/datum/patreon_data/patreon
	/// Twitch subscription data for this player.
	var/datum/twitch_data/twitch
	/// Discord linking details for this player.
	var/datum/discord_details/discord_details
	/// Currently active challenges.
	var/list/datum/challenge/active_challenges
	/// Currently applied challenges.
	var/list/datum/challenge/applied_challenges
	/// The challenge menu for this mob.
	var/datum/challenge_selector/challenge_menu
	/// Bonus monkecoins to reward this player at roundend.
	var/roundend_monkecoin_bonus = 0

/datum/persistent_client/New(ckey, client)
	. = ..()
	var/stored_patreon_key
	var/stored_patreon_rank
	var/stored_twitch_rank
	if(SSdbcore.IsConnected())
		var/datum/db_query/query_get_ranks = SSdbcore.NewQuery(
			"SELECT patreon_key, patreon_rank, twitch_rank FROM [format_table_name("player")] WHERE ckey = :ckey",
			list("ckey" = ckey)
		)
		if(query_get_ranks.warn_execute() && query_get_ranks.NextRow())
			stored_patreon_key = query_get_ranks.item[1]
			stored_patreon_rank = query_get_ranks.item[2]
			stored_twitch_rank = query_get_ranks.item[3]
		qdel(query_get_ranks)
	patreon = new(ckey, src, stored_patreon_key, stored_patreon_rank)
	twitch = new(ckey, src, stored_twitch_rank)

/datum/persistent_client/proc/remove_challenge(datum/challenge/challenge_type, silent = FALSE)
	. = FALSE
	if(!challenge_type)
		return FALSE
	if(challenge_type in active_challenges)
		LAZYREMOVE(active_challenges, challenge_type)
		. = TRUE
	if(LAZYLEN(applied_challenges))
		var/datum/challenge/applied_challenge = locate(challenge_type) in applied_challenges
		if(applied_challenge)
			qdel(applied_challenge)
			. = TRUE
	if(. && !silent)
		to_chat(mob, span_boldnotice("The [challenge_type::challenge_name] challenge has been removed from you."), type = MESSAGE_TYPE_INFO)
