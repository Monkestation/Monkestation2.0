//its for april fools im not organizaing this well, also to insure things are still somewhat playable cargo orders should remain untouched
/datum/controller/subsystem/atoms
	var/list/swap_paths = list()
	var/list/list/paths_to_swap = list(/obj/effect/spawner/random = list(), /obj/item = list())
	var/list/qued_swap_atoms = list()

/datum/controller/subsystem/atoms/proc/get_extra_swap_paths()
	var/list/items_ref = paths_to_swap[/obj/item]
	for(var/datum/design/des as anything in typesof(/datum/design))
		var/created = des::build_path
		if(ispath(created, /obj/item))
			items_ref |= created

	for(var/datum/uplink_item/link_item as anything in typesof(/datum/uplink_item))
		var/created = link_item::item
		if(ispath(created, /obj/item))
			items_ref |= created

	items_ref |= GLOB.summoned_guns
	items_ref |= GLOB.summoned_magic

/datum/controller/subsystem/atoms/proc/compile_swap_paths()
	for(var/parent, path_list in paths_to_swap)
		var/list/paths = path_list
		paths -= swap_paths //dont do things that have already been assigned
		if(!length(paths))
			continue

		var/list/assignable_to = paths.Copy()
		while(length(paths) && length(assignable_to))
			var/swap_source = pick_n_take(paths)
			var/swap_target = pick_n_take(assignable_to)
			swap_paths[swap_source] = swap_target

/datum/controller/subsystem/atoms/proc/do_atom_swap()
	for(var/atom/swapped in qued_swap_atoms)
		qued_swap_atoms -= swapped
		if(!isdatum(swapped))
			continue
		var/swap_to = swap_paths[swapped.type]
		if(!swap_to)
			stack_trace("atom([swapped]) tried to swap without an assigned path.")
			continue
		var/atom/spawn_loc = swapped.loc
		qdel(swapped)
		new swap_to(spawn_loc)
