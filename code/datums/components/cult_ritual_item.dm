/*
 * Component for items that are used by cultists to conduct rituals.
 *
 * - Draws runes, including the rune to summon Nar'sie.
 * - Purges cultists of holy water on attack.
 * - (Un/re)anchors cult structures when hit.
 * - Instantly destroys cult girders on hit.
 */
/datum/component/cult_ritual_item
	/// Whether we are currently being used to draw a rune.
	var/drawing_a_rune = FALSE
	/// The message displayed when the parent is examined, if supplied.
	var/examine_message
	/// A list of turfs that we scribe runes at double speed on.
	var/list/turfs_that_boost_us
	/// A list of all shields surrounding us while drawing certain runes (Nar'sie).
	var/list/obj/structure/emergency_shield/cult/narsie/shields
	/// Weakref to an action added to our parent item that allows for quick drawing runes
	var/datum/weakref/linked_action_ref

/datum/component/cult_ritual_item/Initialize(
	examine_message,
	action = null,
	turfs_that_boost_us = /turf/open/floor/engine/cult,
	)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.examine_message = examine_message

	if(islist(turfs_that_boost_us))
		src.turfs_that_boost_us = turfs_that_boost_us
	else if(ispath(turfs_that_boost_us))
		src.turfs_that_boost_us = list(turfs_that_boost_us)

	if(ispath(action))
		var/obj/item/item_parent = parent
		var/datum/action/added_action = item_parent.add_item_action(action)
		linked_action_ref = WEAKREF(added_action)

/datum/component/cult_ritual_item/Destroy(force)
	cleanup_shields()
	QDEL_NULL(linked_action_ref)
	return ..()

/datum/component/cult_ritual_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(try_purge_holywater))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(try_hit_object))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_EFFECT, PROC_REF(try_clear_rune))

	if(examine_message)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/cult_ritual_item/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_OBJ,
		COMSIG_ITEM_ATTACK_EFFECT,
		COMSIG_ATOM_EXAMINE,
		))

/*
 * Signal proc for [COMSIG_ATOM_EXAMINE].
 * Gives the examiner, if they're a cultist, our set examine message.
 * Usually, this will include various instructions on how to use the thing.
 */
/datum/component/cult_ritual_item/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(!IS_CULTIST(examiner))
		return

	examine_text += examine_message

/*
 * Signal proc for [COMSIG_ITEM_ATTACK].
 * Allows for a cultist (user) to hit another cultist (target)
 * to purge them of all holy water in their system, transforming it into unholy water.
 */
/datum/component/cult_ritual_item/proc/try_purge_holywater(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	if(!IS_CULTIST(user) || !IS_CULTIST(target))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN // No hurting other cultists.

	if(!target.has_reagent(/datum/reagent/water/holywater))
		return

	INVOKE_ASYNC(src, PROC_REF(do_purge_holywater), target, user)

/*
 * Signal proc for [COMSIG_ITEM_ATTACK_OBJ].
 * Allows the ritual items to unanchor cult buildings or destroy rune girders.
 */
/datum/component/cult_ritual_item/proc/try_hit_object(datum/source, obj/structure/target, mob/cultist)
	SIGNAL_HANDLER

	if(!isliving(cultist) || !IS_CULTIST(cultist))
		return

	if(istype(target, /obj/structure/girder/cult))
		INVOKE_ASYNC(src, PROC_REF(do_destroy_girder), target, cultist)
		return COMPONENT_NO_AFTERATTACK

	if(istype(target, /obj/structure/destructible/cult))
		INVOKE_ASYNC(src, PROC_REF(do_unanchor_structure), target, cultist)
		return COMPONENT_NO_AFTERATTACK

/*
 * Signal proc for [COMSIG_ITEM_ATTACK_EFFECT].
 * Allows the ritual items to remove runes.
 */
/datum/component/cult_ritual_item/proc/try_clear_rune(datum/source, obj/effect/target, mob/living/cultist, params)
	SIGNAL_HANDLER

	if(!isliving(cultist) || !IS_CULTIST(cultist))
		return

	if(istype(target, /obj/effect/rune))
		INVOKE_ASYNC(src, PROC_REF(do_scrape_rune), target, cultist)
		return COMPONENT_NO_AFTERATTACK


/*
 * Actually go through and remove all holy water from [target] and convert it to unholy water.
 *
 * target - the target being hit, and having their holywater converted
 * cultist - the target doing the hitting, can be the same as target
 */
/datum/component/cult_ritual_item/proc/do_purge_holywater(mob/living/target, mob/living/cultist)
	// Allows cultists to be rescued from the clutches of ordained religion
	to_chat(cultist, span_cult("You remove the taint from [target] using [parent]."))
	var/holy_to_unholy = target.reagents.get_reagent_amount(/datum/reagent/water/holywater)
	target.reagents.del_reagent(/datum/reagent/water/holywater)
	// For carbonss we also want to clear out the stomach of any holywater
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/obj/item/organ/internal/stomach/belly = carbon_target.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(belly)
			holy_to_unholy += belly.reagents.get_reagent_amount(/datum/reagent/water/holywater)
			belly.reagents.del_reagent(/datum/reagent/water/holywater)
	target.reagents.add_reagent(/datum/reagent/fuel/unholywater, holy_to_unholy)
	log_combat(cultist, target, "smacked", parent, " removing the holy water from them")

/*
 * Destoys the target cult girder [cult_girder], acted upon by [cultist].
 *
 * cult_girder - the girder being destoyed
 * cultist - the mob doing the destroying
 */
/datum/component/cult_ritual_item/proc/do_destroy_girder(obj/structure/girder/cult/cult_girder, mob/living/cultist)
	playsound(cult_girder, 'sound/weapons/resonator_blast.ogg', 40, TRUE, ignore_walls = FALSE)
	cultist.visible_message(
		span_warning("[cultist] strikes [cult_girder] with [parent]!"),
		span_notice("You demolish [cult_girder].")
		)
	new /obj/item/stack/sheet/runed_metal(cult_girder.drop_location(), 1)
	qdel(cult_girder)

/*
 * Unanchors the target cult building.
 *
 * cult_structure - the structure being unanchored or reanchored.
 * cultist - the mob doing the unanchoring.
 */
/datum/component/cult_ritual_item/proc/do_unanchor_structure(obj/structure/cult_structure, mob/living/cultist)
	playsound(cult_structure, 'sound/items/deconstruct.ogg', 30, TRUE, ignore_walls = FALSE)
	cult_structure.set_anchored(!cult_structure.anchored)
	to_chat(cultist, span_notice("You [cult_structure.anchored ? "":"un"]secure \the [cult_structure] [cult_structure.anchored ? "to":"from"] the floor."))

/*
 * Removes the targeted rune. If the rune is important, asks for confirmation and logs it.
 *
 * rune - the rune being deleted. Instance of a rune.
 * cultist - the mob deleting the rune
 */
/datum/component/cult_ritual_item/proc/do_scrape_rune(obj/effect/rune/rune, mob/living/cultist)
	if(rune.log_when_erased)
		var/confirm = tgui_alert(cultist, "Erasing this [rune.cultist_name] rune may work against your goals.", "Begin to erase the [rune.cultist_name] rune?", list("Proceed", "Abort"))
		if(confirm != "Proceed")
			return

		// Gee, good thing we made sure cultists can't input stall to grief their team and get banned anyway
		if(!can_scrape_rune(rune, cultist))
			return

	SEND_SOUND(cultist, 'sound/items/sheath.ogg')
	if(!do_after(cultist, rune.erase_time, target = rune))
		return

	if(!can_scrape_rune(rune, cultist))
		return

	if(rune.log_when_erased)
		cultist.log_message("erased a [rune.cultist_name] rune with [parent].", LOG_GAME)
		message_admins("[ADMIN_LOOKUPFLW(cultist)] erased a [rune.cultist_name] rune with [parent].")

	to_chat(cultist, span_notice("You carefully erase the [lowertext(rune.cultist_name)] rune."))
	qdel(rune)


/*
 * Helper to check if a rune can be scraped by a cultist.
 * Used in between inputs of [do_scrape_rune] for sanity checking.
 *
 * rune - the rune being deleted. Instance of a rune.
 * cultist - the mob deleting the rune
 */
/datum/component/cult_ritual_item/proc/can_scrape_rune(obj/effect/rune/rune, mob/living/cultist)
	if(!IS_CULTIST(cultist))
		return FALSE

	if(!cultist.is_holding(parent))
		return FALSE

	if(!rune.Adjacent(cultist))
		return FALSE

	if(cultist.incapacitated())
		return FALSE

	if(cultist.stat == DEAD)
		return FALSE

	return TRUE

/*
 * Helper to check if a rune can be scribed by a cultist.
 * Used in between inputs of [do_scribe_rune] for sanity checking.
 *
 * tool - the parent - the item being used to scribe the rune, casted to item
 * cultist - the mob making the rune
 */
/datum/component/cult_ritual_item/proc/can_scribe_rune(obj/item/tool, mob/living/cultist)
	if(!IS_CULTIST(cultist))
		to_chat(cultist, span_warning("[tool] is covered in unintelligible shapes and markings."))
		return FALSE

	if(QDELETED(tool) || !cultist.is_holding(tool))
		return FALSE

	if(cultist.incapacitated() || cultist.stat == DEAD)
		to_chat(cultist, span_warning("You can't draw a rune right now."))
		return FALSE

	if(!check_rune_turf(get_turf(cultist), cultist))
		return FALSE

	return TRUE

/*
 * Checks if a turf is valid for having a rune placed there.
 *
 * target - the turf being checked
 * cultist - the mob placing the rune
 */
/datum/component/cult_ritual_item/proc/check_rune_turf(turf/target, mob/living/cultist)
	if(isspaceturf(target))
		to_chat(cultist, span_warning("You cannot scribe runes in space!"))
		return FALSE

	if(locate(/obj/effect/rune) in target)
		to_chat(cultist, span_cult("There is already a rune here."))
		return FALSE

	var/area/our_area = get_area(target)
	if((!is_station_level(target.z) && !is_mining_level(target.z)) || (our_area && !(our_area.area_flags & CULT_PERMITTED)))
		to_chat(cultist, span_warning("The veil is not weak enough here."))
		return FALSE

	return TRUE

/*
 * Removes all shields from the shields list.
 */
/datum/component/cult_ritual_item/proc/cleanup_shields()
	for(var/obj/structure/emergency_shield/cult/narsie/shield as anything in shields)
		LAZYREMOVE(shields, shield)
		if(!QDELETED(shield))
			qdel(shield)
