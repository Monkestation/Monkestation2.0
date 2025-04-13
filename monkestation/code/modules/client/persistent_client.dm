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
