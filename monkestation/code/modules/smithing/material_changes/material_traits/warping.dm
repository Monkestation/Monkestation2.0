/datum/material_trait/warping
	name = "Warping"
	desc = "Randomly teleports around, if you are holding it you also teleport."
	trait_flags = MT_PROCESSES | MT_NO_STACK_PROCESS
	reforges = 2

/datum/material_trait/warping/on_process(atom/movable/parent, datum/material_stats/host)
	. = ..()
	if(prob(90))
		return

	var/list/turfs = list()
	for(var/turf/turf in view(7,get_turf(parent)))
		turfs |= turf

	var/turf/picked = pick(turfs)
	if(isturf(parent.loc))
		do_teleport(parent, picked)

	else
		if(ismob(parent.loc))
			var/mob/living/location = parent.loc
			do_teleport(location, picked)
