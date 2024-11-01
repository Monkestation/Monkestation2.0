#define HUNTER_MINIMUM_RANGE = 10
#define HUNTER_MAXIMUM_RANGE = 75
//Update time to 10 seconds
#define HUNTER_PING_TIME = 100
#define HUNTER_FUZZ_FACTOR = 10

/atom/movable/screen/alert/status_effect/hunters_sense
	name = "Scent of the prey"
	desc = "Your powerful senses enable you to track your prey by scent"


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
	for(var/datum/objective/assassinate/objective_datums as anything in owner.mind.get_all_objectives())
		if(!objective_datums.target || !objective_datums.target.current || objective_datums.target.current.stat == DEAD)
			continue
		var/mob/tracked_target = objective_datums.target.current
		//JUUUST in case.
		if(!tracked_target)
			continue

		//Catch the first one we find, then stop. We want to point to the most recent one we've got.
		scan_target = tracked_target
		break
