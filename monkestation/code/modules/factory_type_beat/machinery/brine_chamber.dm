/obj/structure/brine_chamber
	name = "brine chamber"
	desc = "Converts water into brine."
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "brine_chamber"
	density = TRUE
	anchored = TRUE
	can_atmos_pass = ATMOS_PASS_NO


/obj/structure/brine_chamber/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_BLOCK_LIQUID_SPREAD)))

/obj/structure/brine_chamber/controller
	icon_state = "brine_chamber_controller"

	var/list/turfs = list()
	var/list/walls = list()
	var/process_count = 0

/obj/structure/brine_chamber/controller/Initialize(mapload)
	. = ..()
	var/turf/our_turf = get_turf(src)
	var/turf/inner_turf = get_step(src, NORTH)
	inner_turf = get_step(inner_turf, EAST)
	var/list/spawn_turfs = CORNER_OUTLINE(inner_turf, 3, 3)
	var/list/full_turfs = CORNER_BLOCK(our_turf, 5, 5)
	turfs = full_turfs - spawn_turfs

	for(var/turf/spawned_turf in spawn_turfs)
		if(spawned_turf == our_turf)
			continue
		if(spawned_turf.is_blocked_turf(TRUE))
			repack()
			break
		var/obj/structure/brine_chamber/new_piece = new (spawned_turf)
		walls += new_piece

	create_reagents(3000, TRANSPARENT)
	AddComponent(/datum/component/plumbing/brine_controller)
	AddComponent(/datum/component/plumbing/chemical_washer_water)
	AddElement(/datum/element/repackable, item_to_pack_into = /obj/item/flatpacked_machine/generic, repacking_time = 3 SECONDS, generic_repack = TRUE)

	START_PROCESSING(SSobj, src)

/obj/structure/brine_chamber/controller/Destroy()
	. = ..()
	repack(TRUE)

/obj/structure/brine_chamber/controller/process(seconds_per_tick)
	if(process_count < 10)
		process_count++
		return
	process_count = 0

	var/turf/inside_turf = pick(turfs)
	if(reagents.total_volume)
		inside_turf.add_liquid_from_reagents(reagents, FALSE, reagents.chem_temp, reagents.total_volume)
		reagents.remove_all(reagents.total_volume)
	if(!inside_turf.liquids)
		return
	var/water_volume = inside_turf.liquids.liquid_group.reagents.get_reagent_amount(/datum/reagent/water)
	inside_turf.liquids.liquid_group.reagents.remove_all_type(/datum/reagent/water, water_volume * 0.1)
	inside_turf.add_liquid(/datum/reagent/brine, water_volume * 0.1, FALSE, 300)


/obj/structure/brine_chamber/controller/proc/repack(from_destroy = FALSE)
	for(var/atom/movable/wall as anything in walls)
		walls -= wall
		qdel(wall)
	if(!from_destroy)
		var/obj/item/flatpacked_machine/generic/new_pack = new /obj/item/flatpacked_machine/generic(src.drop_location())
		new_pack.type_to_deploy = src.type
		new_pack.after_set()
	turfs = null


/datum/component/plumbing/brine_controller
	supply_connects = SOUTH
	supply_color = COLOR_GREEN

	ducting_layer = FOURTH_DUCT_LAYER


///returns TRUE when they can give the specified amount and reagent. called by process request
/datum/component/plumbing/brine_controller/can_give(amount, reagent, datum/ductnet/net)
	if(amount <= 0)
		return
	var/obj/structure/brine_chamber/controller/host = parent
	var/turf/inside_turf = pick(host.turfs)
	if(!inside_turf.liquids)
		return

	if(reagent) //only asked for one type of reagent
		for(var/datum/reagent/contained_reagent as anything in inside_turf.liquids.liquid_group.reagents.reagent_list)
			if(contained_reagent.type == reagent)
				return TRUE
	else if(inside_turf.liquids.liquid_group.reagents.total_volume) //take whatever
		return TRUE

	return FALSE

///this is where the reagent is actually transferred and is thus the finish point of our process()
/datum/component/plumbing/brine_controller/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net)
	if(!target || !target.reagents)
		return FALSE
	var/obj/structure/brine_chamber/controller/host = parent
	var/turf/inside_turf = pick(host.turfs)
	if(!inside_turf.liquids)
		return

	if(reagent)
		inside_turf.liquids.liquid_group.transfer_specific_reagents(target.recipient_reagents_holder, amount, reagent)
	else
		inside_turf.liquids.liquid_group.transfer_specific_reagents(target.recipient_reagents_holder, amount, reagents_to_check = list(/datum/reagent/brine))
