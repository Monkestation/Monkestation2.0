/datum/twitch_data
	/// The ckey of the linked player.
	var/ckey
	/// The persistent client of the linked player.
	var/datum/persistent_client/owner
	///the stored twitch client key for the information
	var/client_key
	///the stored twitch rank collected from the server
	var/owned_rank = NO_TWITCH_SUB
	///access rank in numbers
	var/access_rank = 0

/datum/twitch_data/New(ckey, datum/persistent_client/owner, stored_rank)
	. = ..()
	if(!owner)
		return
	src.ckey = ckey
	src.owner = owner
	if(!SSdbcore.IsConnected())
		owned_rank = TWITCH_SUB_TIER_3 ///this is a testing variable
		assign_twitch_rank()
		return

	owned_rank = stored_rank || NO_TWITCH_SUB
	assign_twitch_rank()

/datum/twitch_data/proc/assign_twitch_rank()
	switch(owned_rank)
		if(TWITCH_SUB_TIER_1)
			access_rank =  ACCESS_TWITCH_SUB_TIER_1
		if(TWITCH_SUB_TIER_2)
			access_rank =  ACCESS_TWITCH_SUB_TIER_2
		if(TWITCH_SUB_TIER_3)
			access_rank =  ACCESS_TWITCH_SUB_TIER_3

/datum/twitch_data/proc/has_access(rank)
	if(!access_rank)
		assign_twitch_rank()
	if(rank <= access_rank)
		return TRUE
	return FALSE

/datum/twitch_data/proc/is_donator()
	return owned_rank != NO_TWITCH_SUB
