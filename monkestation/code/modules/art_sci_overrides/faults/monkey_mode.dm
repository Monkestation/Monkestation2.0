/// Maximum amount of monkeys that can be spawned by a monkey fault.
#define MAX_FAULT_MONKEYS 20

/datum/artifact_fault/monkey_mode
	name = "Simian Spawner Fault"
	trigger_chance = 5
	visible_message = "summons a mass of simians!"

	research_value = TECHWEB_DISCOUNT_MINOR

	weight = ARTIFACT_VERYUNCOMMON

	/// Lazylist of spawned apes.
	var/list/spawned_monkeys

/datum/artifact_fault/monkey_mode/Destroy(force)
	for(var/mob/living/monke as anything in spawned_monkeys)
		UnregisterSignal(monke, COMSIG_QDELETING)
	LAZYNULL(spawned_monkeys)
	return ..()

/datum/artifact_fault/monkey_mode/on_trigger()
	if(LAZYLEN(spawned_monkeys) >= MAX_FAULT_MONKEYS)
		return
	var/monkeys_to_spawn = rand(1, 4)
	var/center_turf = get_turf(our_artifact.parent)
	var/list/turf/valid_turfs = list()
	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")
	for(var/turf/open/boi in range(rand(3, 6), center_turf))
		if(boi.is_blocked_turf(source_atom = our_artifact.parent))
			continue
		valid_turfs += boi
	for(var/i in 1 to min(monkeys_to_spawn, length(valid_turfs), MAX_FAULT_MONKEYS - LAZYLEN(spawned_monkeys)))
		var/turf/spawnon = pick_n_take(valid_turfs)
		switch(rand(1, 100))
			if(1 to 75)
				create_monke(/mob/living/carbon/human/species/monkey/angry, spawnon)
			if(75 to 95)
				create_monke(/mob/living/basic/gorilla, spawnon)
			if(95 to 100)
				create_monke(/mob/living/basic/gorilla/lesser, spawnon)//OH GOD ITS TINY

/datum/artifact_fault/monkey_mode/proc/create_monke(monke_type, turf/spawn_loc)
	var/mob/living/monke = new monke_type(spawn_loc)
	RegisterSignal(monke, COMSIG_QDELETING, PROC_REF(untrack_monke))
	LAZYADD(spawned_monkeys, monke)

/datum/artifact_fault/monkey_mode/proc/untrack_monke(mob/living/monke)
	UnregisterSignal(monke, COMSIG_QDELETING)
	LAZYREMOVE(spawned_monkeys, monke)

/datum/artifact_fault/monkey_mode/proc/count_monkeys()
	. = 0
	for(var/mob/living/monke as anything in spawned_monkeys)
		if(QDELETED(monke))
			continue
		if(monke.stat == DEAD) // dead monkeys only count half
			. += 0.5
		else
			.++

#undef MAX_FAULT_MONKEYS
