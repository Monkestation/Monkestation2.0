GLOBAL_DATUM(maptext_manager, /datum/maptext_holder_manager)

/datum/maptext_holder_manager
	///assoc list of maptext holders by key
	var/list/atom/movable/maptext_holder/holders_by_key = list()
	///assoc nested list of maptext holders keyed to their parent
	var/list/list/atom/movable/maptext_holder/holders_by_parent = list()

///Create a new maptext holder instance assigned to the passed key, if the key already exists we will stack_trace()
/datum/maptext_holder_manager/proc/add_keyed_maptext(key, text, x, y, width, height, atom/movable/maptext_holder/added_holder)
	if(!key)
		return

	if(holders_by_key[key])
		stack_trace("add_keyed_maptext called with an already in use key([key])")
		return holders_by_key[key]

	added_holder ||= new //have to do this here so we dont have a hanging object on no key
	holders_by_key[key] = added_holder
	added_holder.key = key
	set_maptext_values(key, text, x, y, width, height)
	return added_holder

///Set the values of a maptext with an already existing key, if the passed key does not have a value then we simply return
/datum/maptext_holder_manager/proc/set_maptext_values(key, text, x, y, width, height)
	var/atom/movable/maptext_holder/adjusted = holders_by_key[key]
	if(!adjusted)
		return

	if(!isnull(text))
		adjusted.maptext = text
	if(isnum(width))
		adjusted.maptext_width = width
	if(isnum(height))
		adjusted.maptext_height = height
	if(isnum(x))
		adjusted.maptext_x = x
	if(isnum(y))
		adjusted.maptext_y = y
	return adjusted

///Set the parent of of a maptext with an already existing key, we need to ensure key has been set to stop runtimes
/datum/maptext_holder_manager/proc/set_key_parent(key, atom/movable/new_parent)
	var/atom/movable/maptext_holder/adopted = holders_by_key[key]
	if(!adopted)
		return

	var/atom/movable/old_parent = adopted.parent
	if(old_parent)
		clear_parent(adopted, old_parent)
		old_parent.vis_contents -= adopted

	adopted.parent = new_parent
	if(adopted.parent)
		add_parent(adopted, new_parent)
		new_parent.vis_contents += adopted

///Handle all of the manager side stuff for adding a parent, doesnt effect anything on the child
/datum/maptext_holder_manager/proc/add_parent(atom/movable/maptext_holder/child, atom/movable/parent = child.parent)
	var/list/holder_list = holders_by_parent[parent]
	if(!holder_list) //new parent
		holders_by_parent[parent] = list(child)
		RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(parent_qdel))
		return
	holder_list += child

///Handle all of the manager side stuff for removing a parent, doesnt effect anything on the child
/datum/maptext_holder_manager/proc/clear_parent(atom/movable/maptext_holder/child, atom/movable/parent = child.parent)
	var/list/holder_list = holders_by_parent[parent]
	holder_list -= child
	if(!length(holder_list))
		UnregisterSignal(parent, COMSIG_QDELETING)
		holders_by_parent -= parent


/datum/maptext_holder_manager/proc/add_multi_parent(atom/movable/maptext_holder/multi_parent/child, atom/movable/parent = child.parent)
	add_parent(child, parent)
	child.parents += parent
	parent.vis_contents += child

/datum/maptext_holder_manager/proc/remove_multi_parent(atom/movable/maptext_holder/multi_parent/child, atom/movable/parent = child.parent)
	clear_parent(child, parent)
	child.parents -= parent
	parent.vis_contents -= child

///Called when a registered parent qdels
/datum/maptext_holder_manager/proc/parent_qdel(atom/movable/qdeleted)
	SIGNAL_HANDLER
	var/list/holder_list = holders_by_parent[qdeleted]
	for(var/atom/movable/maptext_holder/holder in holder_list)
		if(holder.qdel_with_parent)
			qdel(holder) //the holders should handle their own cleanup
		if(istype(holder, /atom/movable/maptext_holder/multi_parent))
			astype(holder, /atom/movable/maptext_holder/multi_parent).parents -= qdeleted

	holders_by_parent -= qdeleted
	UnregisterSignal(qdeleted, COMSIG_QDELETING)

///Add a NEW managed maptext instance to this atom, this is intended as a creation helper proc, if you want to actually manage the maptext post creation then use the manager
///needs to be on /movable because it uses vis_contents which we cant access on /atom
/atom/movable/proc/add_atom_maptext(key, text, x, y, width, height)
	if(!key)
		CRASH("/atom/movable/add_atom_maptext() called without a set key")

	if(isnull(text))
		return

	var/datum/maptext_holder_manager/manager = GLOB.maptext_manager
	if(!manager)
		manager = new
		GLOB.maptext_manager = manager

	if(manager.holders_by_key[key])
		stack_trace("add_atom_maptext() called with an already in use key([key])")
		return manager.holders_by_key[key]

	var/atom/movable/maptext_holder/new_holder = manager.add_keyed_maptext(key, text, x, y, width, height)
	new_holder.parent = src
	manager.add_parent(new_holder, src)
	vis_contents += new_holder //we do all the logic we would want from set_key_parent()
	return new_holder

///Add a multi parent maptext instance to this atom, unlike add_atom_maptext() this supports using already existing keys
/atom/movable/proc/add_multi_maptext(key, text, x, y, width, height)
	if(!key)
		CRASH("/atom/movable/add_multi_maptext() called without a set key")

	if(isnull(text))
		return

	var/datum/maptext_holder_manager/manager = GLOB.maptext_manager
	if(!manager)
		manager = new
		GLOB.maptext_manager = manager

	var/atom/movable/maptext_holder/multi_parent/new_holder = manager.holders_by_key[key] || manager.add_keyed_maptext(key, text, x, y, width, height, new /atom/movable/maptext_holder/multi_parent)
	manager.add_multi_parent(new_holder, src)
	return new_holder
