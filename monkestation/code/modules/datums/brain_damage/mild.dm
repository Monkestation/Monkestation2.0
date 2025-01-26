/datum/brain_trauma/mild/kleptomania
	name = "Kleptomania"
	desc = "Patient has a fixation of small objects and may involuntarily pick them up."
	scan_desc = "kleptomania"
	gain_text = span_warning("You feel a strong urge to grab things.")
	lose_text = span_notice("You no longer feel the urge to grab things.")
	// The percent chance for kleptomania to actually activate every tick
	var/kleptomania_chance = 2.5
	// The percent chance to pickpocket from someone, instead of from the ground.
	var/pickpocket_chance = 25

/datum/brain_trauma/mild/kleptomania/on_life(seconds_per_tick, times_fired)
	if(owner.incapacitated())
		return
	if(!prob(kleptomania_chance))
		return
	if(!owner.has_active_hand())
		return
	if(owner.get_active_held_item())
		return

	if(prob(pickpocket_chance))
		steal_from_someone()
	else
		steal_from_ground()

/datum/brain_trauma/mild/kleptomania/proc/steal_from_someone()
	var/list/potential_victims = list()
	for(var/mob/living/carbon/human/potential_victim in view(1, owner))
		if(potential_victim == owner)
			continue
		var/list/items_in_pockets = potential_victim.get_pockets()
		if(!length(items_in_pockets))
			return
		potential_victims += potential_victim

	if(!length(potential_victims))
		return

	var/mob/living/carbon/human/victim = pick(potential_victims)

	// `items_in_pockets` should never be empty, given that we excluded them above. If it *is*
	// empty, something is horribly wrong!
	var/list/items_in_pockets = victim.get_pockets()
	var/obj/item/item_to_steal = pick(items_in_pockets)
	owner.visible_message(
		span_warning("[owner] attempts to remove [item_to_steal] from [victim]'s pocket!"),
		span_warning("You attempt to remove [item_to_steal] from [victim]'s pocket."),
		span_warning("You hear someone rummaging through pockets.")
	)

	owner.log_message("is pickpocketed [item_to_steal] out of [key_name(victim)]'s pockets (kleptomania).", LOG_ATTACK, color = "red")
	victim.log_message("is having [item_to_steal] pickpocketed by [key_name(owner)] (kleptomania).", LOG_VICTIM, color = "orange", log_globally = FALSE)
	if(!do_after(owner, item_to_steal.strip_delay, victim) || !victim.temporarilyRemoveItemFromInventory(item_to_steal))
		owner.visible_message(
			span_warning("[owner] fails to pickpocket [victim]."),
			span_warning("You fail to pick [victim]'s pocket."),
			null
		)
		return

	owner.log_message("has pickpocketed [key_name(victim)] of [item_to_steal] (kleptomania).", LOG_ATTACK, color = "red")
	victim.log_message("has been pickpocketed of [item_to_steal] by [key_name(owner)] (kleptomania).", LOG_VICTIM, color = "orange", log_globally = FALSE)

	owner.visible_message(
		span_warning("[owner] removes [item_to_steal] from [victim]'s pocket!"),
		span_warning("You remove [item_to_steal] from [victim]'s pocket."),
		null
	)

	if(QDELETED(item_to_steal))
		return
	if(!owner.putItemFromInventoryInHandIfPossible(item_to_steal, owner.active_hand_index, TRUE))
		item_to_steal.forceMove(owner.drop_location())

/datum/brain_trauma/mild/kleptomania/proc/steal_from_ground()
	// Get a list of anything that's not nailed down or already worn by the brain trauma's owner.
	var/list/stealables = list()
	var/list/currently_worn_gear = owner.get_all_gear()
	for(var/obj/item/potential_stealable in oview(1, owner))
		if(potential_stealable.anchored)
			continue
		if(potential_stealable in currently_worn_gear)
			continue
		if(!potential_stealable.Adjacent(owner))
			continue
		stealables += potential_stealable

	// Shuffle the list of stealables, then loop through it until we find an item to grab.
	for(var/obj/item/stealable as anything in shuffle(stealables))
		if(!owner.CanReach(stealable, view_only = TRUE))
			continue

		owner.log_message("attempted to pick up (kleptomania) [stealable]", LOG_ATTACK, color = "orange")
		stealable.attack_hand(owner)
		break

/mob/living/carbon/human/proc/get_pockets()
	var/list/pockets = list()
	if(l_store)
		pockets += l_store
	if(r_store)
		pockets += r_store
	if(s_store)
		pockets += s_store
	return pockets
