/datum/component/garys_item
	///the gary that created us
	var/datum/weakref/attached_gary

/datum/component/garys_item/Initialize(mob/living/basic/chicken/gary/gary)
	. = ..()
	src.attached_gary = WEAKREF(gary)
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(looter))
	SEND_SIGNAL(parent, COMSIG_ITEM_GARY_STASHED, gary)

/datum/component/garys_item/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)

/datum/component/garys_item/proc/looter(datum/source, mob/taker)
	var/obj/item/source_item = parent
	var/mob/living/basic/chicken/gary/gary = attached_gary.resolve()
	gary.held_shinies -= source_item.type
	gary.hideout.remove_item(source_item)
	gary.adjust_happiness(-5, taker)
	SEND_SIGNAL(parent, COMSIG_ITEM_GARY_LOOTED, gary)
	SEND_SIGNAL(gary, COMSIG_FRIENDSHIP_CHANGE, taker, -50)// womp womp
