GLOBAL_LIST_INIT(strippable_slime_items, create_strippable_list(list(
	/datum/strippable_item/slime_head,
)))

/mob/living/basic/slime/Exited(atom/movable/gone, direction)
	if(gone == equipped_hat)
		equipped_hat = null
		update_appearance(UPDATE_OVERLAYS)
	return ..()

/// Puts the item on the slime's head.
/mob/living/basic/slime/proc/equip_hat(obj/item/item, mob/living/user)
	if(user)
		if(!user.transferItemToLoc(item, src))
			return
		user.visible_message(
			span_notice("[user] puts [item] on [name]'s head."),
			span_notice("You put [item] on [name]'s head."),
		)
	else
		item.forceMove(src)
	equipped_hat = item
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/// The strip menu slot for a slime's hat.
/datum/strippable_item/slime_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/slime_head/get_item(atom/source)
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return

	return slime.equipped_hat

/datum/strippable_item/slime_head/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return FALSE

	if(slime.stat == DEAD)
		to_chat(user, span_warning("You can't put a hat on a dead slime."))
		return FALSE
	if(slime.equipped_hat)
		user.balloon_alert(user, "already wearing a hat!")
		return FALSE

/datum/strippable_item/slime_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return

	slime.equip_hat(equipping, user)

/datum/strippable_item/slime_head/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/slime/slime = source
	if(!istype(slime))
		return

	user.put_in_hands(slime.equipped_hat)
	slime.equipped_hat = null
	slime.update_appearance(UPDATE_OVERLAYS)
