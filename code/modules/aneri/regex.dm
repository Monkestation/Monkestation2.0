/datum/regex
	parent_type = /datum/aneri

/datum/regex/New(regex_value, modifiers)
	if(!istext(regex_value))
		CRASH("attempted to create regex with non-text value: [regex_value]")
	if(istext(modifiers))
		regex_value = "(?[modifiers])[regex_value]"
	var/err = ANERI_CALL("regex_new", regex_value)
	// returns null if everything was fine, else returns error info
	if(err)
		log_runtime("failed to create regex [regex_value]: [err]")
		CRASH("failed to create regex [regex_value]: [err]")

/datum/regex/Destroy()
	if(!ANERI_CALL("regex_del", src))
		log_runtime("attempted to delete nonexistent regex instance")
		stack_trace("attempted to delete nonexistent regex instance")
	return ..()

/datum/regex/proc/is_match(haystack)
	. = ANERI_CALL("instanced_regex_is_match", src, haystack)
	if(istext(.))
		log_runtime("regex match errored: [.]")
		CRASH("regex match errored: [.]")

/datum/regex/proc/find(haystack)
	. = ANERI_CALL("instanced_regex_find", src, haystack)
	if(istext(.))
		log_runtime("regex find errored: [.]")
		CRASH("regex find errored: [.]")

/datum/regex/proc/find_all(haystack)
	. = ANERI_CALL("instanced_regex_find_all", src, haystack)
	if(istext(.))
		log_runtime("regex find_all errored: [.]")
		CRASH("regex find_all errored: [.]")
