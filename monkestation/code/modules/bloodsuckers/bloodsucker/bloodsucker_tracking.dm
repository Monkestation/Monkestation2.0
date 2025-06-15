/datum/antagonist/bloodsucker/proc/setup_tracker(mob/living/body)
	cleanup_tracker()
	tracker = new(body, REF(src))
	for(var/datum/antagonist/vassal/vassal in vassals)
		vassal.monitor?.add_to_tracking_network(tracker.tracking_beacon)
	tracker.tracking_beacon.toggle_visibility(TRUE)

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

/obj/effect/abstract/bloodsucker_tracker_holder/Initialize(mapload, key)
	. = ..()
	tracking_beacon = AddComponent( \
		/datum/component/tracking_beacon, \
		_frequency_key = key, \
		_colour = "#960000", \
		_global = TRUE, \
		_always_update = TRUE, \
	)

/obj/effect/abstract/bloodsucker_tracker_holder/Destroy(force)
	tracking_beacon.toggle_visibility(FALSE)
	QDEL_NULL(tracking_beacon)
	return ..()
