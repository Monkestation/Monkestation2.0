/datum/instant
	parent_type = /datum/aneri

/datum/instant/New()
	. = ..()
	ANERI_CALL(instant_new, src)

/datum/instant/Destroy()
	ANERI_CALL(instant_del, src)
	return ..()

/datum/instant/proc/reset()
	return ANERI_CALL(instant_reset, src)

/datum/instant/proc/microseconds()
	return ANERI_CALL(instant_microseconds, src)

/datum/instant/proc/nanoseconds()
	return ANERI_CALL(instant_nanoseconds, src)

/datum/instant/proc/milliseconds()
	return ANERI_CALL(instant_milliseconds, src)

/datum/instant/proc/seconds()
	return ANERI_CALL(instant_seconds, src)
