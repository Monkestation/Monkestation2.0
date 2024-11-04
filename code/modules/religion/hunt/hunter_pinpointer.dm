#define HUNTER_MINIMUM_RANGE = 10
#define HUNTER_MAXIMUM_RANGE = 75
#define HUNTER_PING_TIME = (10 seconds)
#define HUNTER_FUZZ_FACTOR = 10

/atom/movable/screen/alert/status_effect/hunters_sense
	name = "Hunter's Instincts"
	desc = "Your powerful instincts allow you to easily track your prey"


/datum/status_effect/agent_pinpointer/hunters_sense
	id = "agent_pinpointer"
	alert_type = /atom/movable/screen/alert/status_effect/hunters_sense/
	minimum_range = HUNTER_MINIMUM_RANGE
	tick_interval = HUNTER_PING_TIME
	duration = -1
	range_fuzz_factor = HUNTER_FUZZ_FACTOR


///copied wholesale from the agent pinpointer. Something needs to be done here to point towards the prey creature created by the rite
///Attempting to locate a nearby target to scan and point towards.
/datum/status_effect/agent_pinpointer/hunters_sense/scan_for_target()
	scan_target = null
	if(!owner && !owner.mind)
		return

	var/obj/effect/chosen_prey
	for(var/mob/living/basic/deer/located as anything in preys)
		if(get_dist(user, located) < dist)
			dist = get_dist(user, located)
			chosen_prey = located
	if(QDELETED(chosen_prey))
		return
	scan_target = chosen_prey
	break
