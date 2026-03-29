//stuff relating to movement, includes core movement includes structure movement so as to reduce the size of that file for readabilty

/// Jumps to a node
/mob/eye/blob/proc/jump_to_node()
	if(!length(GLOB.blob_nodes))
		return FALSE

	var/list/nodes = list()
	for(var/index in 1 to length(GLOB.blob_nodes))
		var/obj/structure/blob/special/node/blob = GLOB.blob_nodes[index]
		nodes["Blob Node #[index] ([get_area_name(blob)])"] = blob

	var/node_name = tgui_input_list(src, "Choose a node to jump to", "Node Jump", nodes)
	if(isnull(node_name) || isnull(nodes[node_name]))
		return FALSE

	var/obj/structure/blob/special/node/chosen_node = nodes[node_name]
	if(chosen_node)
		forceMove(chosen_node.loc)

/// Moves the core
/mob/eye/blob/proc/relocate_core()
	var/turf/tile = get_turf(src)
	var/obj/structure/blob/special/node/blob = locate(/obj/structure/blob/special/node) in tile

	if(!blob)
		to_chat(src, span_warning("You must be on a blob node!"))
		return FALSE

	if(!blob_core)
		to_chat(src, span_userdanger("You have no core and are about to die! May you rest in peace."))
		return FALSE

	var/area/area = get_area(tile)
	if(isspaceturf(tile) || area && !(area.area_flags & BLOBS_ALLOWED))
		to_chat(src, span_warning("You cannot relocate your core here!"))
		return FALSE

	if(!buy(BLOB_POWER_RELOCATE_COST))
		return FALSE

	var/turf/old_turf = get_turf(blob_core)
	var/old_dir = blob_core.dir
	blob_core.forceMove(tile)
	blob_core.setDir(blob.dir)
	blob.forceMove(old_turf)
	blob.setDir(old_dir)

/// Moves the core elsewhere.
/mob/eye/blob/proc/transport_core()
	if(blob_core)
		forceMove(blob_core.drop_location())
