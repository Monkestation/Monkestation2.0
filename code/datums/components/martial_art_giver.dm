/// when equipped and unequipped this item gives a martial art
/datum/component/martial_art_giver
	/// the style we give
	var/datum/martial_art/style

/datum/component/martial_art_giver/Initialize(style_type)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	style = new style_type()
	style.allow_temp_override = FALSE

/datum/component/martial_art_giver/Destroy()
	var/obj/item/item = parent
	if(isliving(item?.loc))
		forget(item.loc)
	QDEL_NULL(style)
	return ..()

/datum/component/martial_art_giver/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))

	var/obj/item/item = parent
	var/mob/living/wearer = item.loc
	if(istype(wearer))
		equipped(item, wearer, wearer.get_slot_by_item(item))

/datum/component/martial_art_giver/UnregisterFromParent(datum/source)
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	var/obj/item/parent_item = parent
	if(ismob(parent_item?.loc))
		UnregisterSignal(parent_item.loc, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF))

/datum/component/martial_art_giver/proc/equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(!(source.slot_flags & slot))
		return
	RegisterSignals(user, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED), PROC_REF(teach))
	RegisterSignal(user, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF, PROC_REF(forget))
	teach(user)

/datum/component/martial_art_giver/proc/dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	forget(user)
	UnregisterSignal(user, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF))

/datum/component/martial_art_giver/proc/teach(mob/source)
	SIGNAL_HANDLER
	if(isnull(style))
		return
	style.teach(source, TRUE)

/datum/component/martial_art_giver/proc/forget(mob/source)
	SIGNAL_HANDLER
	if(isnull(style))
		return
	style.fully_remove(source)
