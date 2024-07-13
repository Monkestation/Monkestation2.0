/datum/aneri
	var/__aneri_key_low
	var/__aneri_key_high

/datum/aneri/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, __aneri_key_low) || var_name == NAMEOF(src, __aneri_key_high))
		return FALSE // DO. NOT. TOUCH.
	return ..()

// contained in its own proc to prevent runtime shittery
/proc/aneri_startup_log()
	log_world("Aneri version [aneri_version()] loaded")
	log_world("Aneri features: [aneri_features()]")

/proc/assoc_to_weights(list/list_to_pick) as /list
	. = list()
	for(var/item in list_to_pick)
		. += list_to_pick[item]

/proc/_aneri_pick(list/choices, secure = FALSE)
	var/choices_len = length(choices)
	switch(choices_len)
		if(0)
			return null
		if(1)
			return choices[1]
		else
			var/idx = ANERI_CALL("random_range_int_unsigned", 1, choices_len, secure)
			return choices[idx]

/proc/_aneri_pick_weighted(list/list_to_pick, secure = FALSE)
	if(!islist(list_to_pick))
		stack_trace("Attempted to do a weighted pick from a non-list")
		return null
	if(!length(list_to_pick))
		return null
	var/chosen_idx = ANERI_CALL("pick_weighted", assoc_to_weights(list_to_pick), secure)
	return list_to_pick[chosen_idx]

