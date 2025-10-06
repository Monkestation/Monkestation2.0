/obj/item/corral_linker
	name = "corral linker"
	desc = "A useful tool to help link corrals"

	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	icon_state = "corral_linker"

	var/obj/machinery/corral_corner/host
	var/list/corral_corners = list()

/obj/item/corral_linker/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with == host && host.submit_corners(corral_corners))
		qdel(src)
		return ITEM_INTERACT_SUCCESS

	if(length(corral_corners) == 4)
		say("Buffer full!")
		return ITEM_INTERACT_BLOCKING

	if(istype(interacting_with, /obj/machinery/corral_corner))
		if(interacting_with in corral_corners)
			corral_corners -= interacting_with
			say("Removed corner from buffer!")
		else
			corral_corners += interacting_with
			say("Added corner to buffer!")
		return ITEM_INTERACT_SUCCESS

/obj/machinery/corral_corner
	name = "corral fencepost"
	desc = "One of the corners of a corral."

	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	icon_state = "corral_corner"
	circuit = /obj/item/circuitboard/machine/corral_corner
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.25
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5

	density = TRUE
	var/max_range = 9
	var/datum/corral_data/connected_data
	var/mapping_id

/obj/machinery/corral_corner/post_machine_initialize()
	. = ..()

	if(!mapping_id || connected_data)
		return
	var/list/found_corners = list()
	for(var/obj/machinery/corral_corner/main as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/corral_corner))
		if(main.mapping_id != mapping_id)
			continue
		found_corners += main
	submit_corners(found_corners)

	if(connected_data)
		for(var/obj/machinery/slime_pen_controller/controller as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/slime_pen_controller))
			if(controller.mapping_id == mapping_id)
				controller.linked_data = connected_data

/obj/machinery/corral_corner/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(connected_data)
		return
	start_linking_procedure()

/obj/machinery/corral_corner/multitool_act(mob/living/user, obj/item/multitool/multi)
	multi.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/corral_corner/proc/start_linking_procedure()
	var/obj/item/corral_linker/new_linker = new(loc)
	new_linker.host = src
	new_linker.corral_corners += src

/obj/machinery/corral_corner/proc/submit_corners(list/given_corners)
	if(length(given_corners) != 4)
		return
	var/list/steps_and_direction = list()

	var/list/corners = given_corners

	var/list/corners_left = list()
	corners_left += corners

	var/turf/current_turf = loc
	var/turf/last_found_corner_turf = loc
	var/found = FALSE
	for(var/num in 1 to 4)
		found = FALSE
		for(var/direction in GLOB.cardinals)
			if(found)
				break
			current_turf = last_found_corner_turf
			var/steps = 0
			for(var/step in 1 to max_range)
				current_turf = get_step(current_turf, direction)

				if(current_turf.density)
					break
				steps++

				for(var/obj/machinery/corral_corner/found_corner as anything in current_turf.contents)
					if(!istype(found_corner))
						continue

					if(!found_corner)
						continue

					if((found_corner == src) && length(steps_and_direction) < 3)
						continue

					if(!(found_corner in corners_left))
						continue

					steps--

					corners_left -= found_corner
					last_found_corner_turf = current_turf
					found = TRUE
					steps_and_direction += list("[direction]" = steps)
					break

	build_data(steps_and_direction, corners)
	return TRUE

/obj/machinery/corral_corner/proc/build_data(list/steps, list/corners)
	var/turf/current_turf = loc
	var/list/effects = list()
	for(var/step_dir in steps)
		for(var/lengths in 1 to steps[step_dir])
			current_turf = get_step(current_turf, text2num(step_dir))

			var/obj/effect/corral_fence/new_fence = new(current_turf)
			new_fence.dir = text2num(step_dir)
			effects += new_fence
		current_turf = get_step(current_turf, text2num(step_dir))

	var/datum/corral_data/new_data = new

	new_data.corral_connectors += effects
	new_data.corral_corners += corners

	var/turf/last_turf
	for(var/obj/machinery/corral_corner/adder as anything in corners)
		if((adder.x < x && adder.y < y) || (adder.x > x && adder.y > y) || (adder.x > x && adder.y < y) || (adder.x < x && adder.y > y))
			last_turf = get_turf(adder)
		if(adder.connected_data)
			continue
		adder.connected_data = new_data

	var/list/block_turfs = block(get_turf(src), last_turf)
	new_data.corral_turfs += block_turfs
	new_data.setup_pen()

/obj/effect/corral_fence
	name = "corral fence"
	desc = "A holographic fence designed to prevent slimes from leaving."
	anchored = TRUE
	can_be_unanchored = FALSE

	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	icon_state = "corral_fence"
	can_atmos_pass = ATMOS_PASS_NO
	can_astar_pass = CANASTARPASS_ALWAYS_PROC

/obj/effect/corral_fence/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(mover.pulledby)
		return TRUE
	if((istype(mover, /mob/living/basic/slime) || ismonkey(mover) || istype(mover, /mob/living/basic/cockroach) || istype(mover, /mob/living/basic/xenofauna)) && !HAS_TRAIT(mover, VACPACK_THROW))
		return FALSE
	return TRUE


/obj/effect/corral_fence/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(pass_info.xenofauna_or_slime)
		return FALSE
	return TRUE //anything expect slimes can astar pass
