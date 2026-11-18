/// Behaves similar to connect_loc_behalf, but hooks into signals on items in the user's inventory
/datum/component/connect_inventory
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// An assoc list of signal -> procpath to register to the items in the tracked inventory
	var/list/connections

	/// The mob whose inventory we are watching
	var/mob/living/tracked

	/// Bitfield of the slots items have to be in to get the signals registered
	var/allowed_slots

/datum/component/connect_inventory/Initialize(mob/living/tracked, connections, allowed_slots = ALL)
	. = ..()
	if(!istype(tracked))
		return COMPONENT_INCOMPATIBLE
	src.connections = connections
	src.tracked = tracked
	src.allowed_slots = allowed_slots

/datum/component/connect_inventory/RegisterWithParent()
	RegisterSignal(tracked, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))
	RegisterSignal(tracked, COMSIG_QDELETING, PROC_REF(handle_tracked_qdel))
	update_signals()

/datum/component/connect_inventory/UnregisterFromParent()
	unregister_signals()
	UnregisterSignal(tracked, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM))

/// Deletes the component when the tracked mob gets deleted
/datum/component/connect_inventory/proc/handle_tracked_qdel()
	SIGNAL_HANDLER
	qdel(src)

/// Registers the connections to every item currently in an allowed slot
/datum/component/connect_inventory/proc/update_signals()
	unregister_signals()

	for(var/obj/item/item as anything in tracked.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		if(!(allowed_slots & tracked.get_slot_by_item(item)))
			continue
		RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(on_unequipped_item))
		for(var/signal in connections)
			parent.RegisterSignal(item, signal, connections[signal])

/// Unregisters the connections from every item the tracked mob has equipped
/datum/component/connect_inventory/proc/unregister_signals()
	for(var/obj/item/item as anything in tracked.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		UnregisterSignal(item, COMSIG_ITEM_DROPPED)
		parent.UnregisterSignal(item, connections)

/// Registers the connections to a newly equipped item if it went into an allowed slot
/datum/component/connect_inventory/proc/on_equipped_item(datum/source, obj/item/equipped, slot)
	SIGNAL_HANDLER
	if(!(allowed_slots & slot))
		return
	// This handler has to be registered on the component itself because users may have their own COMSIG_ITEM_DROPPED handler for the equipped item
	RegisterSignal(equipped, COMSIG_ITEM_DROPPED, PROC_REF(on_unequipped_item))
	for(var/signal in connections)
		parent.RegisterSignal(equipped, signal, connections[signal])

/// Unregisters the connections from an item once it is dropped
/datum/component/connect_inventory/proc/on_unequipped_item(obj/item/unequipped)
	SIGNAL_HANDLER
	UnregisterSignal(unequipped, COMSIG_ITEM_DROPPED)
	parent.UnregisterSignal(unequipped, connections)
