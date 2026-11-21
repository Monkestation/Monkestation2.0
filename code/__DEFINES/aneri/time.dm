/// A stopwatch that starts when created.
/// Once it's deleted, reset() returns FALSE and the other procs return null.
/datum/instant
	parent_type = /datum/aneri

/datum/instant/New()
	. = ..()
	ANERI_CALL(instant_new, src)

/datum/instant/Destroy()
	ANERI_CALL(instant_del, src)
	return ..()

/// Restarts the stopwatch from 0.
/datum/instant/proc/reset()
	return ANERI_CALL(instant_reset, src)

/// Microseconds since the stopwatch started or was reset.
/// A DM number holds about 7 digits, so this loses precision after about 17 seconds.
/datum/instant/proc/microseconds()
	return ANERI_CALL(instant_microseconds, src)

/// Nanoseconds since the stopwatch started or was reset.
/// A DM number holds about 7 digits, so this loses precision after about 17 milliseconds.
/datum/instant/proc/nanoseconds()
	return ANERI_CALL(instant_nanoseconds, src)

/// Milliseconds since the stopwatch started or was reset.
/datum/instant/proc/milliseconds()
	return ANERI_CALL(instant_milliseconds, src)

/// Seconds since the stopwatch started or was reset, with a fraction.
/datum/instant/proc/seconds()
	return ANERI_CALL(instant_seconds, src)
