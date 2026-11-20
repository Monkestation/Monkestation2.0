/*
Slimecrossing Armor
	Armor added by the slimecrossing system.
	Collected here for clarity.
*/

//Rebreather mask - Chilling Blue
/obj/item/clothing/mask/nobreath
	name = "rebreather mask"
	desc = "A transparent mask, resembling a conventional breath mask, but made of bluish slime. Seems to lack any air supply tube, though."
	icon_state = "slime"
	inhand_icon_state = "b_mask"
	body_parts_covered = NONE
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/mask_nobreath
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE
	interaction_flags_mouse_drop = NEED_HANDS

/datum/armor/mask_nobreath
	bio = 50

/obj/item/clothing/mask/nobreath/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rebreather)

/obj/item/clothing/mask/nobreath/examine(mob/user)
	. = ..()
	. += span_notice("You could work it into a plain mask with no internals or armor, to give that mask the same trick.")

/obj/item/clothing/mask/nobreath/proc/can_embed_into(obj/item/clothing/mask/mask)
	var/static/list/combat_ratings = list(MELEE, BULLET, LASER, ENERGY, BOMB)
	if((mask.clothing_flags | mask.visor_flags) & MASKINTERNALS)
		return FALSE
	if(HAS_TRAIT(mask, TRAIT_SLIME_REBREATHER))
		return FALSE
	if(istype(mask, /obj/item/clothing/mask/cigarette) || istype(mask, /obj/item/clothing/mask/vape))
		return FALSE
	if(mask.item_flags & (ABSTRACT | DROPDEL))
		return FALSE
	var/datum/armor/armor = mask.get_armor()
	for(var/rating in combat_ratings)
		if(armor.get_rating(rating))
			return FALSE
	return TRUE

/obj/item/clothing/mask/nobreath/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	var/obj/item/clothing/mask/mask = interacting_with
	if(!istype(mask))
		return NONE
	if(!can_embed_into(mask))
		to_chat(user, span_warning("[mask] won't take it. It has to be a plain mask with no internals and no armor."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You work [src] into [mask]. It should keep you breathing now."))
	mask.name = "rebreathing [mask.name]"
	mask.AddElement(/datum/element/rebreather)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Keeps the wearer breathing with no air while the mask is on their face.
/datum/element/rebreather

/datum/element/rebreather/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/clothing/mask))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_SLIME_REBREATHER, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	var/obj/item/clothing/mask/mask = target
	var/mob/living/carbon/wearer = mask.loc
	if(iscarbon(wearer) && wearer.wear_mask == mask)
		on_equipped(mask, wearer, ITEM_SLOT_MASK)

/datum/element/rebreather/Detach(datum/target)
	. = ..()
	REMOVE_TRAIT(target, TRAIT_SLIME_REBREATHER, ELEMENT_TRAIT(type))
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ATOM_EXAMINE))

/datum/element/rebreather/proc/on_equipped(obj/item/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_MASK) || !iscarbon(user))
		return
	ADD_TRAIT(user, TRAIT_NOBREATH, "[CLOTHING_TRAIT]_[REF(source)]")
	user.failed_last_breath = FALSE
	user.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
	user.apply_status_effect(/datum/status_effect/rebreathing)

/datum/element/rebreather/proc/on_dropped(obj/item/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	// wear_mask is only cleared after dropped() runs, and a spare rebreather in a hand shouldn't strip the one on your face
	if(!iscarbon(user) || user.wear_mask != source)
		return
	REMOVE_TRAIT(user, TRAIT_NOBREATH, "[CLOTHING_TRAIT]_[REF(source)]")
	user.remove_status_effect(/datum/status_effect/rebreathing)

/datum/element/rebreather/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("While worn as a mask, it keeps you breathing without any air.")

/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "prismglasses"
	actions_types = list(/datum/action/item_action/change_prism_color,/datum/action/item_action/place_light_prism)
	var/glasses_color = "#FFFFFF"

/obj/structure/light_prism
	name = "light prism"
	desc = "A shining crystal of semi-solid light. Looks fragile."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	max_integrity = 10

/obj/structure/light_prism/Initialize(mapload, newcolor = COLOR_WHITE)
	. = ..()
	color = newcolor
	set_light_color(newcolor)
	set_light(5)

/obj/structure/light_prism/attack_hand(mob/user, list/modifiers)
	to_chat(user, span_notice("You dispel [src]."))
	qdel(src)

/datum/action/item_action/change_prism_color
	name = "Adjust Prismatic Lens"
	button_icon = 'icons/obj/science/slimecrossing.dmi'
	button_icon_state = "prismcolor"

/datum/action/item_action/change_prism_color/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = tgui_color_picker(owner, "Choose the lens color:", "Color change", glasses.glasses_color)
	if(!new_color)
		return
	glasses.glasses_color = new_color

/datum/action/item_action/place_light_prism
	name = "Fabricate Light Prism"
	button_icon = 'icons/obj/science/slimecrossing.dmi'
	button_icon_state = "lightprism"

/datum/action/item_action/place_light_prism/Trigger(trigger_flags)
	if(!IsAvailable(feedback = TRUE))
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	if(locate(/obj/structure/light_prism) in get_turf(owner))
		to_chat(owner, span_warning("There isn't enough ambient energy to fabricate another light prism here."))
		return
	if(istype(glasses))
		if(!glasses.glasses_color)
			to_chat(owner, span_warning("The lens is oddly opaque..."))
			return
		to_chat(owner, span_notice("You channel nearby light into a glowing, ethereal prism."))
		new /obj/structure/light_prism(get_turf(owner), glasses.glasses_color)

/obj/item/clothing/head/peaceflower
	name = "heroine bud"
	desc = "An extremely addictive flower, full of peace magic."
	icon = 'icons/obj/science/slimecrossing.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "peaceflower"
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_HEAD
	clothing_traits = list(TRAIT_PACIFISM)
	body_parts_covered = NONE
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/clothing/head/peaceflower/can_mob_unequip(mob/user)
	if(user.get_item_by_slot(slot_flags) == src)
		to_chat(user, span_warning("You feel at peace. <b style='color:pink'>Why would you want anything else?</b>"))
		return FALSE
	return ..()

/obj/item/clothing/suit/armor/heavy/adamantine
	name = "adamantine armor"
	desc = "A full suit of adamantine plate armor. Impressively resistant to damage, but weighs about as much as you do."
	icon_state = "adamsuit"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = null
	flags_inv = NONE
	item_flags = IMMUTABLE_SLOW
	slowdown = 4
	var/hit_reflect_chance = 40
	texture_type = /datum/bodypart_texture/mesh/biosuit_dark

/obj/item/clothing/suit/armor/heavy/adamantine/IsReflect(def_zone)
	if((def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)) && prob(hit_reflect_chance))
		return TRUE
	else
		return FALSE
