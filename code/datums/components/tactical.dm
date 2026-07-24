/// A simple component that replaces the user's appearance with that of the parent item when equipped.
/datum/component/tactical
	/// The allowed slot(s) for the effect.
	var/allowed_slot
	/// The slot the item is currently equipped in.
	var/current_slot

/datum/component/tactical/Initialize(allowed_slot)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_slot = allowed_slot

/datum/component/tactical/Destroy()
	unmodify()
	return ..()

/datum/component/tactical/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(modify))
	var/obj/item/item = parent
	if(ismob(item.loc))
		var/mob/holder = item.loc
		modify(item, holder, holder.get_slot_by_item(item))

/datum/component/tactical/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
	unmodify()

/datum/component/tactical/proc/modify(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(current_slot == slot)
		return

	if(allowed_slot && !(slot & allowed_slot))
		if(current_slot)
			unmodify(source, user)
		return

	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(tactical_update))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(unmodify))
	RegisterSignal(parent, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_icon_update))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(user, COMSIG_HUMAN_GET_VISIBLE_NAME, PROC_REF(on_name_inquiry))
	RegisterSignal(user, COMSIG_HUMAN_GET_FORCED_NAME, PROC_REF(on_name_inquiry))
	ADD_TRAIT(user, TRAIT_UNKNOWN, REF(src))

	current_slot = slot
	on_icon_update(source)

/datum/component/tactical/proc/on_icon_update(obj/item/source)
	SIGNAL_HANDLER
	var/mob/user = source.loc
	if(!istype(user))
		return

	user.remove_alt_appearance("sneaking_mission[REF(src)]")
	var/obj/item/master = parent
	var/image/item_image = image(master, loc = user)
	item_image.copy_overlays(master)
	item_image.override = TRUE
	item_image.layer = ABOVE_MOB_LAYER
	item_image.plane = FLOAT_PLANE
	user.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission[REF(src)]", item_image)

/// Replaces the holder's visible identity with the tactical item's name.
/datum/component/tactical/proc/on_name_inquiry(datum/source, list/identity)
	SIGNAL_HANDLER

	var/tactical_disguise_priority = INFINITY
	if(identity[VISIBLE_NAME_FORCED])
		if(identity[VISIBLE_NAME_FORCED] >= tactical_disguise_priority)
			stack_trace("A name-forcing signal ([identity[VISIBLE_NAME_FACE]]) has a priority collision with [src].")
			return

	identity[VISIBLE_NAME_FORCED] = tactical_disguise_priority
	var/obj/item/flawless_disguise = parent
	identity[VISIBLE_NAME_FACE] = flawless_disguise.name
	identity[VISIBLE_NAME_ID] = flawless_disguise.name

/datum/component/tactical/proc/unmodify(obj/item/source, mob/user)
	SIGNAL_HANDLER
	if(!source)
		source = parent
	if(!user)
		user = source.loc
	if(!istype(user))
		return

	UnregisterSignal(source, list(
		COMSIG_MOVABLE_Z_CHANGED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_UPDATED_ICON,
		COMSIG_MOVABLE_MOVED,
	))
	// These signals are registered on the holder, not the tactical item.
	UnregisterSignal(user, list(
		COMSIG_HUMAN_GET_VISIBLE_NAME,
		COMSIG_HUMAN_GET_FORCED_NAME,
	))
	current_slot = null
	user.remove_alt_appearance("sneaking_mission[REF(src)]")
	REMOVE_TRAIT(user, TRAIT_UNKNOWN, REF(src))

/// Checks if a mob is holding us, and if so updates our appearance to match the item.
/datum/component/tactical/proc/tactical_update(obj/item/source)
	SIGNAL_HANDLER
	if(!ismob(source.loc))
		return
	modify(source, source.loc, current_slot)

/// Ensures forced moves still remove the tactical appearance from the previous holder.
/datum/component/tactical/proc/on_moved(obj/item/source, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	unmodify(source, oldloc)
