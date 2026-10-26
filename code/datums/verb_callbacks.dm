///like normal callbacks but they also record their creation time for measurement purposes
/datum/callback/verb_callback
	///the tick this callback datum was created in. used for testing latency
	var/creation_time = 0

/datum/callback/verb_callback/New(thingtocall, proctocall, ...)
	creation_time = DS2TICKS(world.time)
	. = ..()

// queued verbs fire a tick late, whatever they were aimed at might be gone by then
/datum/callback/verb_callback/InvokeAsync(...)
	if(isdatum(object) && QDELETED(object))
		return
	return ..()

/datum/callback/verb_callback/list_args

/datum/callback/verb_callback/list_args/New(thingtocall, proctocall, arguments)
	. = ..()
	src.arguments = arguments
