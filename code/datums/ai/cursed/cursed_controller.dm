/**
 * # cursed item ai!
 *
 * Haunted AI tries to not be interacted with, and will attack people who do.
 * Cursed AI instead tries to be interacted with, and will attempt to equip itself onto people.
 * Added by /datum/element/cursed, and as such will try to remove this element and go dormant when it finds a victim to curse
 */
/datum/ai_controller/cursed
	movement_delay = 0.4 SECONDS
	blackboard = list(
		BB_CURSE_TARGET,
		BB_TARGET_SLOT,
		BB_CURSED_THROW_ATTEMPT_COUNT
	)
	planning_subtrees = list(/datum/ai_planning_subtree/cursed)
	idle_behavior = /datum/idle_behavior/idle_ghost_item

/datum/ai_controller/cursed/TryPossessPawn(atom/new_pawn)
	if(!isitem(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_hit))
	RegisterSignal(new_pawn, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	return ..() //Run parent at end

/datum/ai_controller/cursed/UnpossessPawn()
	UnregisterSignal(pawn, list(COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_EQUIPPED))
	return ..() //Run parent at end

///signal called by the pawn hitting something after a throw
/datum/ai_controller/cursed/proc/on_throw_hit(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	//equipcode has sleeps all over it.

///signal called by picking up the pawn, will try to equip to where it should actually be and start the curse
/datum/ai_controller/cursed/proc/on_equip(datum/source, mob/equipper, slot)

/**
 * curse of hunger component; for very hungry items.
 *
 * called when someone grabs the cursed item or the cursed item impacts with a mob it's throwing itself at
 * arguments:
 * * curse_victim: whomever we're attaching this to
 * * slot_already_in: the slot the item is already in before this was called, possibly null but at least in hands if picked up
 */
/datum/ai_controller/cursed/proc/try_equipping_to_target_slot(mob/living/carbon/curse_victim, slot_already_in)

///proc called when the cursed object successfully attaches itself to someone, removing the cursed element and by extension the ai itself
/datum/ai_controller/cursed/proc/what_a_horrible_night_to_have_a_curse()
