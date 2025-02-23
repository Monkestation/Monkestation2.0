/datum/regex
	parent_type = /datum/aneri

/datum/regex/New(pattern)
	var/err = ANERI_CALL(regex_new, src, pattern)
	// returns null if everything was fine, else returns error info
	if(err)
		CRASH("failed to initialize regex: [err]")

/datum/regex/Destroy()
	if(!ANERI_CALL(regex_del, src))
		stack_trace("attempted to delete nonexistent rng instance")
	return ..()

/datum/regex/proc/is_match(haystack)
	return ANERI_CALL(instanced_regex_is_match, src, haystack)

/datum/regex/proc/find(haystack) as /list
	return ANERI_CALL(instanced_regex_find, src, haystack)

/datum/regex/proc/split(haystack)
	return ANERI_CALL(instanced_regex_split, src, haystack)

/datum/regex/proc/splitn(haystack, limit = 1)
	return ANERI_CALL(instanced_regex_splitn, src, haystack, limit)

/datum/regex/proc/replace(haystack, with = "")
	return ANERI_CALL(instanced_regex_replace, src, haystack, with)

/datum/regex/proc/replace_all(haystack, with = "")
	return ANERI_CALL(instanced_regex_replace_all, src, haystack, with)
