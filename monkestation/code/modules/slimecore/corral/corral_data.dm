//this is just a doc comment but currently the max interior size is 9x9 so 11x11 if you include the corral walls
/datum/corral_data
	///list of all managed slimes
	var/list/managed_slimes = list()
	///the installed corral upgrades
	var/list/corral_upgrades = list()

	///the turfs inside the corral
	var/list/corral_turfs = list()
	///our corral corners
	var/list/corral_corners = list()
	///the corral connecter effects
	var/list/corral_connectors = list()

	var/max_capacity = 20

/datum/corral_data/proc/setup_pen()
	var/list/edge_turfs = list()
	for(var/obj/thing as anything in corral_corners | corral_connectors)
		edge_turfs |= get_turf(thing)

	max_capacity = max(CEILING(length(corral_turfs - edge_turfs) * 2, 5), initial(max_capacity))

	for(var/turf/turf as anything in corral_turfs)
		turf.air_update_turf(update = TRUE, remove = FALSE)
		RegisterSignals(turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(check_entered))
		RegisterSignal(turf, COMSIG_ATOM_EXITED, PROC_REF(check_exited))

		for(var/mob/living/basic/slime/slime in turf.contents)
			if(length(managed_slimes) >= max_capacity)
				slime.death()
				slime.visible_message(span_warning("[slime] dies from being crowded in with so many other slimes!"))
				continue

			managed_slimes |= slime
			RegisterSignal(slime, COMSIG_ATOM_SUCKED, PROC_REF(remove_cause_sucked))
			RegisterSignal(slime, COMSIG_LIVING_DEATH, PROC_REF(remove_cause_sucked))
			RegisterSignals(slime, list(COMSIG_PREQDELETED, COMSIG_QDELETING), PROC_REF(try_remove))

	for(var/obj/machinery/corral_corner/corner as anything in corral_corners)
		RegisterSignal(corner, COMSIG_QDELETING, PROC_REF(start_break))

/datum/corral_data/New()
	. = ..()
	START_PROCESSING(SSxenobio, src)

/datum/corral_data/Destroy(force)
	STOP_PROCESSING(SSxenobio, src)
	QDEL_LIST(corral_connectors)
	for(var/turf/turf as anything in corral_turfs)
		UnregisterSignal(turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, COMSIG_ATOM_EXITED))
		turf.air_update_turf(update = TRUE, remove = FALSE)
	corral_turfs = null

	for(var/obj/machinery/corral_corner/corner as anything in corral_corners)
		corner.connected_data = null
		UnregisterSignal(corner, COMSIG_QDELETING)
		corral_corners -= corner
	corral_corners = null

	for(var/mob/living/basic/slime/slime as anything in managed_slimes)
		UnregisterSignal(slime, list(COMSIG_ATOM_SUCKED, COMSIG_LIVING_DEATH))
	managed_slimes = null

	. = ..()

/datum/corral_data/process(seconds_per_tick)
	for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
		upgrade.process(seconds_per_tick)
	for(var/turf/turf as anything in corral_turfs)
		for(var/mob/living/carbon/human/monke in turf)
			if(!ismonkeybasic(monke) || monke.stat != DEAD || monke.ckey || monke.mind || monke.pulledby)
				continue
			if((monke.timeofdeath + (5 MINUTES)) <= world.time && !monke.get_filter("dust_animation")) // stupid janky way of avoiding dusting the same chimp repeatedly while the dusting animation is ongoing
				monke.visible_message(span_warning("[monke] is automatically dissolved by the slime corral."))
				monke.dust(just_ash = TRUE, drop_items = TRUE)

/datum/corral_data/proc/check_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!isslime(arrived))
		return

	if(isliving(arrived))
		var/mob/living/living = arrived
		if(living.stat == DEAD)
			return

	if(arrived in managed_slimes)
		return

	if(length(managed_slimes) >= max_capacity)
		var/mob/living/living = arrived
		living.visible_message(span_warning("[arrived] dies from being crowded in with so many other slimes!"))
		living.death()
		return

	RegisterSignal(arrived, COMSIG_ATOM_SUCKED, PROC_REF(remove_cause_sucked))
	RegisterSignal(arrived, COMSIG_LIVING_DEATH, PROC_REF(remove_cause_sucked))
	RegisterSignals(arrived, list(COMSIG_PREQDELETED, COMSIG_QDELETING), PROC_REF(try_remove))
	managed_slimes |= arrived
	for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
		upgrade.on_slime_entered(arrived, src)
	update_slimes()

/datum/corral_data/proc/check_exited(turf/source, atom/movable/gone, direction)
	if(!isslime(gone))
		return

	var/turf/turf = get_step(source, direction)
	if(turf in corral_turfs)
		return

	UnregisterSignal(gone, list(COMSIG_ATOM_SUCKED, COMSIG_LIVING_DEATH, COMSIG_PREQDELETED, COMSIG_QDELETING))
	managed_slimes -= gone
	for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
		upgrade.on_slime_exited(gone)
	update_slimes()

/datum/corral_data/proc/remove_cause_sucked(atom/movable/gone)

	UnregisterSignal(gone, list(COMSIG_ATOM_SUCKED, COMSIG_LIVING_DEATH, COMSIG_PREQDELETED, COMSIG_QDELETING))
	managed_slimes -= gone
	for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
		upgrade.on_slime_exited(gone)
	update_slimes()

/datum/corral_data/proc/try_remove(mob/living/basic/slime/source)
	managed_slimes -= source
	update_slimes()

/datum/corral_data/proc/update_slimes()
	for(var/mob/living/basic/slime/slime as anything in managed_slimes)
		if(QDELETED(slime) || !(get_turf(slime) in corral_turfs))
			managed_slimes -= slime
			UnregisterSignal(slime, list(COMSIG_ATOM_SUCKED, COMSIG_LIVING_DEATH, COMSIG_PREQDELETED, COMSIG_QDELETING))
			if(!QDELETED(slime))
				for(var/datum/corral_upgrade/upgrade as anything in corral_upgrades)
					upgrade.on_slime_exited(slime)

/datum/corral_data/proc/start_break()
	qdel(src)
