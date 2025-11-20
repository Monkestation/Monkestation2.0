/datum/antagonist/bloodsucker/proc/setup_tracker(mob/living/body)
	if (tracker?.tracking_beacon)
		cleanup_beacon()
	if (tracker)
		cleanup_tracker()
	tracker = new(body)
	tracker.make_beacon(REF(src))

/datum/antagonist/bloodsucker/proc/cleanup_beacon()
	if (tracker)
		QDEL_NULL(tracker.tracking_beacon)

/datum/antagonist/bloodsucker/proc/cleanup_tracker()
	QDEL_NULL(tracker)

/**
 * An abstract object contained within the bloodsucker, used to host the team_monitor component.
 */
/obj/effect/abstract/bloodsucker_tracker_holder
	name = "bloodsucker tracker holder"
	desc = span_danger("You <b>REALLY</b> shouldn't be seeing this!")
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1
	var/datum/component/tracking_beacon/tracking_beacon

/obj/effect/abstract/bloodsucker_tracker_holder/proc/make_beacon(key)
	tracking_beacon = AddComponent( \
		/datum/component/tracking_beacon, \
		_frequency_key = key, \
		_colour = "#960000", \
		_global = TRUE, \
		_always_update = TRUE, \
	)
