
/// Pop splitting. Divides the current population to another server

/datum/config_entry/flag/pop_split
	protection = CONFIG_ENTRY_LOCKED

/// Target server to send players to when pop splitting. This should exclude byond://. Example: "blhblah.coolserver.net:port"
/datum/config_entry/string/pop_split_target
	protection = CONFIG_ENTRY_LOCKED

// Name of the server, used for messaging
/datum/config_entry/string/pop_split_target_name
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/pop_split_exclude_admins
	protection = CONFIG_ENTRY_LOCKED
	default = TRUE

/datum/config_entry/string/pop_split_sort_method
	protection = CONFIG_ENTRY_LOCKED
	default = POP_SPLIT_SORT_LEAST_PLAYTIME

/datum/config_entry/string/pop_split_sort_method/ValidateAndSet(str_val)
	. = ..()
	var/list/possible_methods = list(
		POP_SPLIT_SORT_RANDOM,
		POP_SPLIT_SORT_MOST_CONNECTION_TIME,
		POP_SPLIT_SORT_LEAST_CONNECTION_TIME,
		POP_SPLIT_SORT_MOST_PLAYTIME,
		POP_SPLIT_SORT_LEAST_PLAYTIME,
	)
	if(lowertext(trim(str_val)) in possible_methods)
		return TRUE
	return FALSE


// Number of players needed to trigger pop splitting at round end.
/datum/config_entry/number/pop_split_threshold
	protection = CONFIG_ENTRY_LOCKED
	default = 100
	min_val = 5

// Number of players to go below to bail out of splitting
// This means once the amount of players go below this number right before reboot, it will cancel pop split.
/datum/config_entry/number/pop_split_bailout_threshold
	protection = CONFIG_ENTRY_LOCKED
	default = 80
	min_val = 5

