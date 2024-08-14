/datum/round_event_control/scrubber_overflow
	shared_occurence_type = SHARED_SCRUBBERS

/datum/round_event/scrubber_overflow
	reagents_amount = 100

/datum/round_event/scrubber_overflow/start()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/vent as anything in scrubbers)
		if(QDELETED(vent) || vent.welded) // in case it was welded after setup() but before we got to it here
			continue
		var/turf/vent_turf = get_turf(vent)
		if(!isopenturf(vent_turf) || QDELING(vent_turf))
			continue
		var/dangerous = prob(danger_chance)
		var/reagent_type = forced_reagent_type || get_overflowing_reagent(dangerous)
		if(dangerous)
			new /mob/living/basic/cockroach(vent_turf)
			new /mob/living/basic/cockroach(vent_turf)
		vent_turf.add_liquid(reagent_type, reagents_amount, no_react = TRUE)
		CHECK_TICK

/datum/round_event/scrubber_overflow/threatening
	reagents_amount = 150

/datum/round_event/scrubber_overflow/catastrophic
	reagents_amount = 200

/datum/round_event/scrubber_overflow/every_vent
	reagents_amount = 150
