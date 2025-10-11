/datum/action/cooldown/slasher/blood_walk
	name = "Blood Trail"
	desc = "You can tell by the way i use my walk im a spooky man, no time to talk."
	button_icon_state = "trail_blood"

	cooldown_time = 30 SECONDS

/datum/action/cooldown/slasher/blood_walk/Activate(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/mob_target = target
		var/datum/component/blood_trail/trail = mob_target.AddComponent(/datum/component/blood_trail)
		addtimer(CALLBACK(src, PROC_REF(remove_trail), mob_target, trail), 15 SECONDS)

/datum/action/cooldown/slasher/blood_walk/proc/remove_trail(mob/living/target, datum/component/blood_trail/trail)
	if(QDELETED(target) || QDELETED(trail))
		return
	qdel(trail)

/datum/component/blood_trail
    /// Duration of the trail, if temporary
    var/duration
    /// Timer ID for cleanup if temporary
    var/timer_id

/datum/component/blood_trail/Initialize(duration = null)
    if(!ismovable(parent))
        return COMPONENT_INCOMPATIBLE

    src.duration = duration
    RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
    if(duration)
        timer_id = addtimer(CALLBACK(src, PROC_REF(end_trail)), duration, TIMER_STOPPABLE)

/datum/component/blood_trail/UnregisterFromParent()
    UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
    if(timer_id)
        deltimer(timer_id)

/datum/component/blood_trail/proc/end_trail()
    qdel(src)

/datum/component/blood_trail/proc/find_pool_by_blood_state(turf/turfLoc, typeFilter = null)
    for(var/obj/effect/decal/cleanable/blood/pool in turfLoc)
        if(pool.blood_state == BLOOD_STATE_HUMAN && (!typeFilter || istype(pool, typeFilter)))
            return pool

/datum/component/blood_trail/proc/on_move(atom/movable/mover, turf/old_loc)
    var/turf/oldLocTurf = get_turf(old_loc)

    var/obj/effect/decal/cleanable/blood/footprints/oldLocFP = find_pool_by_blood_state(oldLocTurf, /obj/effect/decal/cleanable/blood/footprints)
    if(oldLocFP)
        if(!(oldLocFP.exited_dirs & mover.dir))
            oldLocFP.exited_dirs |= mover.dir
            oldLocFP.update_appearance()
    else
        oldLocFP = new(oldLocTurf)
        if(!QDELETED(oldLocFP))
            oldLocFP.blood_state = BLOOD_STATE_HUMAN
            oldLocFP.exited_dirs |= mover.dir
            oldLocFP.bloodiness = 100
            oldLocFP.update_appearance()

    var/obj/effect/decal/cleanable/blood/footprints/FP = new(get_turf(mover))
    if(!QDELETED(FP))
        FP.blood_state = BLOOD_STATE_HUMAN
        FP.entered_dirs |= mover.dir
        FP.bloodiness = 100
        FP.update_appearance()

