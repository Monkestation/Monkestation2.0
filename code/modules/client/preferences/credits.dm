GLOBAL_DATUM_INIT(roundend_hidden_ckeys, /alist, alist())

/datum/preference/toggle/feature_key_credits
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "feature_key_credits"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/feature_key_credits/apply_to_client(client/client, value)
	GLOB.roundend_hidden_ckeys[client.ckey] = value
