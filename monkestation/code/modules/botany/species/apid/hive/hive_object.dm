GLOBAL_LIST_INIT(hive_exits, list())

/obj/structure/beebox/hive
	name = "generic hive"
	desc = "A generic hive without an owner."

	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "hive"

	var/obj/structure/hive_exit/linked_exit
	var/stored_honey = 0
	var/current_stat = "potency"

/obj/structure/beebox/hive/Initialize(mapload, created_name)
	. = ..()
	ADD_TRAIT(src, TRAIT_BANNED_FROM_CARGO_SHUTTLE, INNATE_TRAIT) // womp womp

	name = "[created_name]'s hive"
	for(var/i = 1 to 3)
		var/obj/item/honey_frame/HF = new(src)
		honey_frames += HF

	for(var/obj/structure/hive_exit/exit as anything in GLOB.hive_exits)
		if(!QDELETED(exit.linked_hive))
			continue
		exit.linked_hive = src
		linked_exit = exit
		linked_exit.name = "[created_name]'s hive exit"
		break

	if(QDELETED(linked_exit))
		var/datum/map_template/hive/hive = new()
		var/datum/turf_reservation/roomReservation = SSmapping.request_turf_block_reservation(hive.width, hive.height, 1)
		var/turf/bottom_left = roomReservation.bottom_left_turfs[1]
		var/datum/map_template/load_from = hive

		load_from.load(bottom_left)
		for(var/obj/structure/hive_exit/exit as anything in GLOB.hive_exits)
			if(!QDELETED(exit.linked_hive))
				continue
			exit.linked_hive = src
			linked_exit = exit
			break

/obj/structure/beebox/hive/Destroy()
	. = ..()
	if(linked_exit?.linked_hive == src)
		var/drop_loc = drop_location() || get_turf(src)
		if(!isnull(drop_loc))
			for(var/atom/movable/listed as anything in linked_exit.atoms_inside)
				if(QDELETED(listed))
					continue
				listed.forceMove(drop_loc)
			linked_exit.atoms_inside.Cut()
			var/area/area = get_area(linked_exit)
			for(var/turf/hive_turf as anything in area?.get_turfs_from_all_zlevels())
				for(var/atom/movable/movable as anything in hive_turf)
					if(QDELETED(movable))
						continue
					movable.forceMove(drop_loc)
		linked_exit.linked_hive = null
		linked_exit.name = "generic hive exit"
	linked_exit = null

/obj/structure/beebox/hive/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!linked_exit)
		return

	var/enter_time = 4 SECONDS
	if(is_species(user, /datum/species/apid))
		enter_time = 2 SECONDS

	if(!do_after(user, enter_time, src))
		return

	if(user.pulling && user.pulling != src)
		do_teleport(user.pulling, get_step(linked_exit, EAST), no_effects = TRUE, forced = TRUE)
	do_teleport(user, get_step(linked_exit, EAST), no_effects = TRUE, forced = TRUE)


/obj/structure/hive_exit
	name = "generic hive exit"
	desc = "A generic hive exit without an owner"

	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "hive_exit"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	move_resist = INFINITY
	var/obj/structure/beebox/hive/linked_hive
	var/list/atoms_inside = list()

/obj/structure/hive_exit/Initialize(mapload)
	. = ..()
	GLOB.hive_exits += src
	var/area/our_area = get_area(src)
	RegisterSignal(our_area, COMSIG_AREA_EXITED, PROC_REF(exit_area))
	RegisterSignal(our_area, COMSIG_AREA_ENTERED, PROC_REF(enter_area))

/obj/structure/hive_exit/Destroy()
	GLOB.hive_exits -= src
	var/area/our_area = get_area(src)
	UnregisterSignal(our_area, list(COMSIG_AREA_EXITED, COMSIG_AREA_ENTERED))
	if(linked_hive?.linked_exit == src)
		var/turf/drop_loc = linked_hive.drop_location() || get_turf(linked_hive)
		if(!isnull(drop_loc))
			for(var/atom/movable/listed as anything in atoms_inside)
				if(QDELETED(listed))
					continue
				listed.forceMove(drop_loc)
			for(var/turf/hive_turf as anything in our_area?.get_turfs_from_all_zlevels())
				for(var/atom/movable/movable as anything in hive_turf.contents)
					if(QDELETED(movable))
						continue
					movable.forceMove(drop_loc)
		linked_hive.linked_exit = null
	atoms_inside.Cut()
	linked_hive = null
	return ..()

/obj/structure/hive_exit/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!linked_hive)
		return

	var/enter_time = 4 SECONDS
	if(is_species(user, /datum/species/apid))
		enter_time = 2 SECONDS

	if(!do_after(user, enter_time, src))
		return
	if(user.pulling)
		do_teleport(user.pulling, get_turf(linked_hive), no_effects = TRUE, forced = TRUE)
	do_teleport(user, get_turf(linked_hive), no_effects = TRUE, forced = TRUE)

/obj/structure/hive_exit/proc/exit_area(datum/source, atom/removed)
	if(!isturf(removed))
		atoms_inside -= removed

/obj/structure/hive_exit/proc/enter_area(datum/source, atom/added)
	if(!isturf(added))
		atoms_inside += added


/datum/map_template/hive
	name = "Hive Template"
	width = 15
	height = 15
	mappath = "_maps/~monkestation/templates/hives.dmm"
