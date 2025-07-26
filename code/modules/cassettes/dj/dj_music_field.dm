/// A proximity monitor field that allows mobs near objects to hear DJ music.
/datum/proximity_monitor/advanced/dj_music
	edge_is_a_field = TRUE
	/// List of mobs that can currently hear music from this field.
	var/list/mob/listeners

/datum/proximity_monitor/advanced/dj_music/Destroy()
	for(var/mob/listener as anything in listeners)
		remove_mob(listener)
	return ..()

/datum/proximity_monitor/advanced/dj_music/field_turf_crossed(atom/movable/crosser, turf/old_location, turf/new_location)
	if(isliving(crosser))
		add_mob(crosser)
	var/list/hearing_contents = crosser.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]
	for(var/mob/living/target in hearing_contents)
		add_mob(target)

/datum/proximity_monitor/advanced/dj_music/field_turf_uncrossed(atom/movable/crosser, turf/old_location, turf/new_location)
	if(isliving(crosser))
		remove_mob(crosser)
	var/list/hearing_contents = crosser.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]
	for(var/mob/living/target in hearing_contents)
		remove_mob(target)

/datum/proximity_monitor/advanced/dj_music/setup_field_turf(turf/target)
	for(var/atom/movable/thing in target)
		if(isliving(thing) || length(thing.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			field_turf_crossed(thing)

/datum/proximity_monitor/advanced/dj_music/cleanup_field_turf(turf/target)
	for(var/atom/movable/thing in target)
		if(isliving(thing) || length(thing.important_recursive_contents?[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			field_turf_uncrossed(thing)

/datum/proximity_monitor/advanced/dj_music/proc/add_mob(mob/living/target)
	if(QDELING(src) || !isliving(target) || QDELING(target) || HAS_TRAIT_FROM(target, TRAIT_CAN_HEAR_MUSIC, INNATE_TRAIT) || (target in listeners))
		return
	LAZYADD(listeners, target)
	ADD_TRAIT(target, TRAIT_CAN_HEAR_MUSIC, REF(src))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_mob))

/datum/proximity_monitor/advanced/dj_music/proc/remove_mob(mob/living/target)
	if(!isliving(target) || !(target in listeners))
		return
	LAZYREMOVE(listeners, target)
	REMOVE_TRAIT(target, TRAIT_CAN_HEAR_MUSIC, REF(src))
	UnregisterSignal(target, COMSIG_QDELETING)
