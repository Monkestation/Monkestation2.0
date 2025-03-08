/// A (non-cryptographic) PRNG instance, using WyRand.
/datum/rng
	parent_type = /datum/aneri

/datum/rng/New(secure = FALSE, seed = null)
	. = ..()
	var/err = ANERI_CALL(rng_new, src, secure, seed)
	// returns null if everything was fine, else returns error info
	if(err)
		CRASH("failed to initialize rng: [err]")

/datum/rng/Destroy()
	if(!ANERI_CALL(rng_del, src))
		stack_trace("attempted to delete nonexistent rng instance")
	return ..()

/datum/rng/proc/byte() as num
	return ANERI_CALL(instanced_random_byte, src)

/datum/rng/proc/float() as num
	return ANERI_CALL(instanced_random_float, src)

/datum/rng/proc/uint() as num
	return ANERI_CALL(instanced_random_int_unsigned, src)

/datum/rng/proc/int() as num
	return ANERI_CALL(instanced_random_int_signed, src)

/datum/rng/proc/ranged_uint(min = 0, max) as num
	if(!isnum(min) || !isnum(max))
		CRASH("invalid arguments to /datum/rng/proc/ranged_uint")
	return ANERI_CALL(instanced_random_range_int_unsigned, src, min, max)

/datum/rng/proc/ranged_int(min = 0, max)
	if(!isnum(min) || !isnum(max))
		CRASH("invalid arguments to /datum/rng/proc/ranged_int")
	return ANERI_CALL(instanced_random_range_int_signed, src, min, max)

/datum/rng/proc/pick_from(list/choices)
	RETURN_TYPE(choices[_].type)
	if(!islist(choices))
		CRASH("Attempted to do a pick from a non-list")
	return ANERI_CALL(instanced_pick, src, choices)

/datum/rng/proc/pick_weighted(list/choices)
	RETURN_TYPE(choices[_].type)
	if(!islist(choices))
		CRASH("Attempted to do a weighted pick from a non-list")
	return ANERI_CALL(instanced_pick_weighted, src, choices)

/datum/rng/proc/chance(percent) // "prob" is a reserved word, so we do "chance" instead
	return ANERI_CALL(instanced_prob, src, percent)

/datum/rng/proc/prob_ratio(numerator, denominator)
	return ANERI_CALL(instanced_prob_ratio, src, numerator, denominator)

/datum/rng/proc/string(length = 16) as text
	return ANERI_CALL(instanced_random_string_alphanumeric, src, length)

/datum/rng/proc/replace_chars_prob(input, replacement, probability = 25, skip_whitespace = FALSE) as text
	return ANERI_CALL(instnaced_replace_chars_prob, src, input, replacement, probability, skip_whitespace)
