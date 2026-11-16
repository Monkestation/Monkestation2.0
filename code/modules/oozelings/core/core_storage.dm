/obj/item/organ/internal/brain/slime/proc/drop_items(mob/living/user, list/items_to_drop)
	if(user.get_active_held_item() != src)
		to_chat(user, span_userdanger("Hold [src] in your hand to extract items from it!"))
		return
	if(DOING_INTERACTION_WITH_TARGET(user, src) || !length(items_to_drop))
		return

	var/our_name = brainmob ? key_name(brainmob) : name
	user.log_message("is stripping [our_name] of [english_list(items_to_drop)].", LOG_ATTACK, color="red")
	log_message("is being stripped of [english_list(items_to_drop)] by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)
	brainmob?.log_message("is being stripped of [english_list(items_to_drop)] by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)

	user.visible_message(
		span_warning("[user] begins jamming [user.p_their()] hand into [src]! Slime goes everywhere!"),
		span_notice("You jam your hand into [src], feeling for the densest point, your prize!"),
		span_notice("You hear an obscene squelching sound.")
	)
	playsound(user, 'sound/items/handling/surgery/organ1.ogg', 80, TRUE)

	if(!do_after(user, 15 SECONDS, src))
		user.visible_message(
			span_warning("[user]'s hand slips out of [src] before [user.p_they()] can cause any harm!"),
			span_notice("Your hand slips out of the goopy core before you could find find anything."),
			span_notice("You hear a resounding plop.")
		)
		return
	user.visible_message(
			span_warning("[user] forcefully extracts items from [src]!"),
			span_notice("You managed to find what you were looking for, and it falls to the ground."),
			span_notice("You hear a wet squelching sounds.")
		)
	playsound(user, 'sound/effects/wounds/crackandbleed.ogg', 80, TRUE)
	drop_items_to_ground(user.drop_location(), dropping = items_to_drop)

	user.log_message("has stripped [our_name] of [english_list(items_to_drop)].", LOG_ATTACK, color="red")
	log_message("has been stripped of [english_list(items_to_drop)] by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)
	brainmob?.log_message("has been stripped of [english_list(items_to_drop)] by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)

/obj/item/organ/internal/brain/slime/proc/process_items(mob/living/carbon/human/victim) // Handle all items to be stored into core.
	var/list/focus_slots = list(
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_BELT,
		ITEM_SLOT_ID,
		ITEM_SLOT_LPOCKET,
		ITEM_SLOT_RPOCKET
	)
	for(var/islot in focus_slots) // Focus on storage items and any others that drop when uniform is unequiped
		var/obj/item/item = victim.get_item_by_slot(islot)
		if(QDELETED(item))
			continue
		victim.temporarilyRemoveItemFromInventory(item, force = TRUE, idrop = FALSE)
		process_and_store_item(item, victim)

	var/obj/item/back_item = victim.get_item_by_slot(ITEM_SLOT_BACK)
	if(!QDELETED(back_item))
		victim.temporarilyRemoveItemFromInventory(back_item, force = TRUE, idrop = FALSE)
		process_and_store_item(back_item, victim) // Jank to handle modsuit covering items, so it's removed first. Fix this.

	var/obj/item/bodypart/chest/target_chest = victim.get_bodypart(BODY_ZONE_CHEST) // Store chest cavity item
	if(istype(target_chest))
		process_and_store_item(target_chest.cavity_item, victim)
		target_chest.cavity_item = null

	for(var/obj/item/item as anything in victim.get_equipped_items(INCLUDE_POCKETS)) // Store rest of equipment
		if(QDELETED(item))
			continue
		victim.temporarilyRemoveItemFromInventory(item, force = TRUE, idrop = FALSE)
		process_and_store_item(item, victim)

	for(var/datum/action/item_action/hands_free/activate_pill/pill_action in victim.actions) // Store dental implants
		pill_action.Remove(victim)
		var/obj/pill = pill_action.target
		if(istype(pill))
			process_and_store_item(pill, victim)

	for(var/obj/item/implant/curimplant in victim.implants) // Process and store implants
		if(!is_type_in_typecache(curimplant, allowed_implants))
			continue
		if(curimplant.removed(victim))
			var/obj/item/implantcase/case =  new /obj/item/implantcase
			case.imp = curimplant
			curimplant.forceMove(case) //Recase implant it doesn't like to be moved without it.
			case.update_appearance()
			process_and_store_item(case, victim)

	for(var/obj/item/organ/organ in victim.organs) // Process and store organ implants and related organs
		if(is_type_in_typecache(organ, allowed_organ_types))
			organ.Remove(victim)
			process_and_store_item(organ, victim)

/obj/item/organ/internal/brain/slime/proc/process_and_store_item(atom/movable/item, mob/living/carbon/human/victim) // Helper proc to finally move items
	if(QDELETED(item))
		return
	for(var/atom/movable/content_item as anything in item.get_all_contents())
		if(is_type_in_typecache(content_item, bannedcore))
			content_item.forceMove(victim.drop_location()) // Move item from container to victims turf if banned
	if(is_type_in_typecache(item, bannedcore))
		item.forceMove(victim.drop_location()) // Move banned item from victim to the victim's turf if banned.
	else
		item.forceMove(src)
		stored_items |= item

/obj/item/organ/internal/brain/slime/proc/drop_items_to_ground(turf/turf, list/dropping = stored_items, explode = FALSE)
	for(var/atom/movable/item as anything in dropping)
		if(!(item in stored_items))
			continue
		if(istype(item, /obj/item/implantcase)) // Delete implants that aren't re-implanted. For now.
			qdel(item)
		else if(explode && brainmob)
			brainmob.dropItemToGround(item, violent = TRUE)
		else
			item.forceMove(turf)
		stored_items -= item
		for(var/slot, slot_item in items_per_slot)
			if(slot_item == item)
				items_per_slot -= slot_item

/obj/item/organ/internal/brain/slime/proc/reequip_items(mob/living/carbon/human/body)
	for(var/i, slot in items_per_slot)
		var/obj/item/item = i
		if(QDELETED(item) || !(item in stored_items))
			continue
		body.equip_to_slot(item, slot)
		if(body.get_item_by_slot(slot) == item)
			stored_items -= item
	items_per_slot.Cut()

/obj/item/organ/internal/brain/slime/proc/readd_to_body(mob/living/carbon/human/new_body)
	if(QDELETED(new_body) || QDELETED(src))
		return
	for(var/obj/item/implantcase/case in stored_items)
		if(!is_type_in_typecache(case.imp, allowed_implants))
			continue
		case.imp.implant(new_body, new_body, silent = TRUE)
		stored_items -= case
		qdel(case)
