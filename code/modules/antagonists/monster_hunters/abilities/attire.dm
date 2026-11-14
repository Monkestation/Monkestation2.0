/datum/action/cooldown/spell/huntsman_attire
	name = "Follow Suit"
	desc = "You are of my suit now, and you will look it. \
		Call, and my livery dresses you. \
		Call again, and you may have your rags back. \
		Do not ask where they go in the meantime."
	background_icon_state = "bg_wonderland"
	overlay_icon_state = null
	active_overlay_icon_state = null
	button_icon = 'icons/obj/clothing/suits/armor.dmi'
	button_icon_state = "queens_huntsman"
	cooldown_time = 30 SECONDS
	invocation = "Buttons done. Shoulders back. Heads off."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_CASTABLE_WITHOUT_INVOCATION
	/// Suit first, so a hood or hardsuit helmet is put away before the head slot gets read.
	var/list/obj/item/clothing/pieces
	/// The item each piece replaced, keyed by piece.
	var/list/obj/item/stashed = list()

/datum/action/cooldown/spell/huntsman_attire/New(Target, original = TRUE)
	. = ..()
	var/glove_type = pick(/obj/item/clothing/gloves/queens_huntsman, /obj/item/clothing/gloves/queens_huntsman/red)
	pieces = list(
		new /obj/item/clothing/suit/armor/queens_huntsman,
		new /obj/item/clothing/head/hats/queens_huntsman,
		new /obj/item/clothing/under/costume/queens_huntsman,
		new glove_type,
		new /obj/item/clothing/shoes/queens_huntsman,
	)

/datum/action/cooldown/spell/huntsman_attire/Destroy()
	var/turf/drop_turf = get_turf(owner)
	. = ..()
	for(var/obj/item/clothing/piece as anything in pieces)
		piece.atom_storage?.remove_all(drop_turf)
	QDEL_LIST(pieces)

/datum/action/cooldown/spell/huntsman_attire/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_owner_death))

/datum/action/cooldown/spell/huntsman_attire/Remove(mob/living/remove_from)
	UnregisterSignal(remove_from, COMSIG_LIVING_DEATH)
	if(ishuman(remove_from))
		dismiss(remove_from)
	return ..()

/datum/action/cooldown/spell/huntsman_attire/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(length(pieces & cast_on.contents))
		dismiss(cast_on)
	else
		manifest(cast_on)
	playsound(cast_on, 'sound/effects/magic/paradoxskip.ogg', vol = 50, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, pressure_affected = FALSE)
	var/atom/movable/warp_effect/ripple = new(get_turf(cast_on))
	ripple.transform = matrix().Scale(0.1)
	animate(ripple, transform = matrix().Scale(1), alpha = 0, time = 0.6 SECONDS, easing = CUBIC_EASING | EASE_OUT)
	QDEL_IN(ripple, 0.6 SECONDS)
	cast_on.add_filter("attire_flare", 2, outline_filter(size = 2, color = "#c4143c"))
	cast_on.transition_filter("attire_flare", outline_filter(size = 0), 0.4 SECONDS)
	addtimer(CALLBACK(cast_on, TYPE_PROC_REF(/datum, remove_filter), "attire_flare"), 0.4 SECONDS)

/datum/action/cooldown/spell/huntsman_attire/proc/manifest(mob/living/carbon/human/human)
	var/obj/item/mod/control/modsuit = locate() in human.get_equipped_items()
	if(modsuit?.wearer == human && !modsuit.activating)
		for(var/obj/item/part as anything in modsuit.get_parts())
			if(part.loc != modsuit)
				modsuit.retract(null, part, instant = TRUE)
	for(var/obj/item/clothing/piece as anything in pieces)
		var/obj/item/old = human.get_item_by_slot(piece.slot_flags)
		if(old && !human.canUnEquip(old))
			continue
		if(old)
			human.temporarilyRemoveItemFromInventory(old, idrop = FALSE)
			old.moveToNullspace()
		if(!human.equip_to_slot_if_possible(piece, piece.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
			if(old)
				human.equip_to_slot_if_possible(old, piece.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE, bypass_equip_delay_self = TRUE)
			continue
		ADD_TRAIT(piece, TRAIT_NODROP, HUNTER_TRAIT)
		RegisterSignal(piece, COMSIG_ITEM_DROPPED, PROC_REF(on_piece_dropped))
		if(old)
			stashed[piece] = old
	rehome_suit_storage(human)

/datum/action/cooldown/spell/huntsman_attire/proc/dismiss(mob/living/carbon/human/human)
	for(var/obj/item/clothing/piece as anything in pieces)
		if(piece.loc != human)
			continue
		UnregisterSignal(piece, COMSIG_ITEM_DROPPED)
		REMOVE_TRAIT(piece, TRAIT_NODROP, HUNTER_TRAIT)
		var/obj/item/old = stashed[piece]
		stashed -= piece
		human.temporarilyRemoveItemFromInventory(piece, force = TRUE, idrop = !old)
		piece.moveToNullspace()
		if(!old)
			continue
		if(!human.equip_to_slot_if_possible(old, piece.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
			old.forceMove(human.drop_location())
	rehome_suit_storage(human)

/// Taking a suit off with invdrop disabled leaves its suit storage item behind, even if the next suit can't hold it
/datum/action/cooldown/spell/huntsman_attire/proc/rehome_suit_storage(mob/living/carbon/human/human)
	var/obj/item/stored = human.s_store
	if(!stored || human.can_equip(stored, ITEM_SLOT_SUITSTORE, TRUE, ignore_equipped = TRUE))
		return
	var/list/empty_hands = human.get_empty_held_indexes()
	if(length(empty_hands) && human.putItemFromInventoryInHandIfPossible(stored, empty_hands[1], force_removal = TRUE))
		return
	human.dropItemToGround(stored, force = TRUE)

/datum/action/cooldown/spell/huntsman_attire/proc/on_owner_death(mob/living/source)
	SIGNAL_HANDLER
	if(ishuman(source))
		INVOKE_ASYNC(src, PROC_REF(dismiss), source)

/// Fires mid-unequip, before the slot var is cleared, so the old item can't be re-equipped here
/datum/action/cooldown/spell/huntsman_attire/proc/on_piece_dropped(obj/item/clothing/piece, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(piece, COMSIG_ITEM_DROPPED)
	REMOVE_TRAIT(piece, TRAIT_NODROP, HUNTER_TRAIT)
	piece.moveToNullspace()
	var/obj/item/old = stashed[piece]
	stashed -= piece
	old?.forceMove(user.drop_location())
