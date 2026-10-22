///Acts as a way to give an atom multiple different maptexts without them conflicting, TODO: add an anti text clipping system
/atom/movable/maptext_holder //the logic for this is handled on the component and with the helpers
	density = FALSE
	move_resist = INFINITY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	maptext = ""
	///The atom this holder is attached to
	var/atom/movable/parent
	///Should we qdel with our parent
	var/qdel_with_parent = TRUE
	///The key this has been assigned
	var/key

/atom/movable/maptext_holder/Destroy(force)
	var/datum/maptext_holder_manager/manager = GLOB.maptext_manager
	if(manager)
		manager.holders_by_key -= key
		if(parent)
			manager.set_key_parent(key, null)
	parent = null
	key = null //in case key gets set to an actual ref
	return ..()

///Maptext holder that supports being attached to multiple atoms
/atom/movable/maptext_holder/multi_parent
	qdel_with_parent = FALSE
	///The list of all our parents
	var/list/atom/movable/parents = list()

/atom/movable/maptext_holder/multi_parent/Destroy(force)
	var/datum/maptext_holder_manager/manager = GLOB.maptext_manager
	if(manager)
		for(var/atom/our_parent in parents)
			manager.clear_parent(src, our_parent)
	parents = null
	return ..()
