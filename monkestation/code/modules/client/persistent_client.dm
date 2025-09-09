/datum/persistent_client
	/// Patreon data for this player.
	var/datum/patreon_data/patreon
	/// Twitch subscription data for this player.
	var/datum/twitch_data/twitch
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
	patreon = new(ckey, src)
	twitch = new(ckey, src)

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
