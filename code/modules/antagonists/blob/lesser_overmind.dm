/mob/eye/blob/lesser
	blob_points = 20
	max_blob_points = 60
	placed = TRUE

/mob/eye/blob/lesser/Destroy()
	var/list/factories = antag_team.all_blobs_by_type[/obj/structure/blob/special/resource]
	if(length(factories))
		for(var/obj/structure/blob/special/resource/node in factories)
			if(node.give_to)
				node.give_to -= src
	return ..()
