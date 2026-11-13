/// Makes a bunch of mobs move around together: every so often it picks a turf and sends the whole group there
/datum/group_planning
	///when our next move is done
	var/next_action = 0
	///our cooldown time of moves
	var/cooldown_time = 10 SECONDS
	///list of mobs in our group
	var/list/group_mobs = list()
	///list of mobs still moving to our target
	var/list/in_progress_mobs = list()
	///list of finished mobs
	var/list/finished_mobs = list()
	///our current_target
	var/atom/target

/datum/group_planning/Destroy(force)
	. = ..()
	finished_mobs = null
	in_progress_mobs = null
	group_mobs = null
	target = null

/datum/group_planning/proc/check_mobs()
	for(var/mob/living/mob as anything in group_mobs)
		if(!QDELETED(mob) && mob.stat != DEAD && mob.ai_controller)
			continue
		group_mobs -= mob
		in_progress_mobs -= mob
		finished_mobs -= mob
	if(!length(group_mobs))
		qdel(src)

/// Called by every member's AI, starts the next move once the last one is over and the cooldown is up
/datum/group_planning/proc/update(datum/ai_controller/controller)
	check_mobs()
	if(QDELETED(src))
		return
	if(length(in_progress_mobs))
		if(target && !(controller.pawn in in_progress_mobs) && !(controller.pawn in finished_mobs))
			send_on_action(controller)
		return
	if(next_action > world.time)
		return
	decide_next_action()
	if(!target)
		return
	for(var/mob/living/listed as anything in group_mobs)
		send_on_action(listed.ai_controller)

/// Picks our next target
/datum/group_planning/proc/decide_next_action()
	return

/datum/group_planning/proc/send_on_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_GROUP_MOVE_TARGET, target)
	in_progress_mobs |= controller.pawn

/datum/group_planning/proc/finish_action(datum/ai_controller/controller)
	check_mobs()
	if(QDELETED(src))
		return
	if(controller.pawn in in_progress_mobs)
		in_progress_mobs -= controller.pawn
		finished_mobs += controller.pawn
	if(!length(in_progress_mobs))
		next_action = world.time + cooldown_time
		finished_mobs = list()
		target = null

/datum/group_planning/fish
	cooldown_time = 25 SECONDS

/datum/group_planning/fish/decide_next_action()
	var/mob/living/basic/picked_mob = pick(group_mobs)

	var/list/turfs = view(7, picked_mob)
	var/turf/picked
	var/sanity = 25

	while(!isopenturf(picked) && sanity > 0)
		sanity--
		picked = get_turf(pick(turfs))
	target = picked
