/// Makes any heretic blade the parent holds channel the moon amulet's effect instead of doing damage
/datum/component/moon_blade_channel
	dupe_mode = COMPONENT_DUPE_SOURCES
	var/static/list/possible_sounds = list(
		'sound/items/SitcomLaugh1.ogg',
		'sound/items/SitcomLaugh2.ogg',
		'sound/items/SitcomLaugh3.ogg',
	)

/datum/component/moon_blade_channel/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/moon_blade_channel/RegisterWithParent()
	. = ..()
	var/mob/living/user = parent
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(blade_channel))
	RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equip_item))
	RegisterSignal(user, COMSIG_MOB_DROPPED_ITEM, PROC_REF(on_dropped_item))
	on_equip_item(user, user.get_active_held_item(), ITEM_SLOT_HANDS)
	on_equip_item(user, user.get_inactive_held_item(), ITEM_SLOT_HANDS)

/datum/component/moon_blade_channel/UnregisterFromParent()
	var/mob/living/user = parent
	on_dropped_item(user, user.get_active_held_item())
	on_dropped_item(user, user.get_inactive_held_item())
	UnregisterSignal(user, list(COMSIG_HERETIC_BLADE_ATTACK, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_DROPPED_ITEM))
	return ..()

/datum/component/moon_blade_channel/proc/blade_channel(mob/living/attacker, mob/living/victim)
	SIGNAL_HANDLER
	channel_moon_amulet(attacker, victim)

/// Modifies any blades that we equip while channeling
/datum/component/moon_blade_channel/proc/on_equip_item(mob/user, obj/item/blade, slot)
	SIGNAL_HANDLER
	if(!istype(blade, /obj/item/melee/sickly_blade))
		return // We only care about modifying blades
	if(slot & ITEM_SLOT_HANDS)
		blade.force = 0
		blade.wound_bonus = 0
		blade.bare_wound_bonus = 0
		blade.armour_penetration = 200
		blade.hitsound = null
		ADD_TRAIT(blade, TRAIT_CUSTOM_TAP_SOUND, REF(src))
		RegisterSignal(blade, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT, PROC_REF(modify_attack_message))
		return
	blade.force = initial(blade.force)
	blade.wound_bonus = initial(blade.wound_bonus)
	blade.bare_wound_bonus = initial(blade.bare_wound_bonus)
	blade.armour_penetration = initial(blade.armour_penetration)
	blade.hitsound = initial(blade.hitsound)
	REMOVE_TRAIT(blade, TRAIT_CUSTOM_TAP_SOUND, REF(src))
	UnregisterSignal(blade, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT)

/datum/component/moon_blade_channel/proc/modify_attack_message(obj/item/weapon, mob/living/victim, mob/living/attacker)
	SIGNAL_HANDLER

	var/list/attack_list = list(
		"You sweep [weapon] towards [victim], splitting [victim.p_Their()] image in two.",
		"You strike [victim] with [weapon], spilling forth a cascade from within. Immaculate.",
		"As it bite deep, your [weapon] unburdens [victim] of unneeded thought.",
	)
	to_chat(attacker, span_danger(pick(attack_list)))

	var/list/victim_list = list(
		"You are struck by [attacker], but the [weapon] tears away something more than parts of your body.",
		"You see an arch of light as [attacker]'s [weapon] twists towards you, and you see the world briefly in tetrachrome.",
		"As [attacker] carves into you with [weapon], you lose something deep within. The agony is worse than any wound.",
	)
	to_chat(victim, span_userdanger(pick(victim_list)))
	playsound(attacker, pick(possible_sounds), 40, TRUE)
	return SIGNAL_MESSAGE_MODIFIED

/// Modifies any blades that we drop while channeling
/datum/component/moon_blade_channel/proc/on_dropped_item(mob/user, obj/item/dropped_item)
	SIGNAL_HANDLER
	if(!istype(dropped_item, /obj/item/melee/sickly_blade))
		return // We only care about modifying blades
	dropped_item.force = initial(dropped_item.force)
	dropped_item.wound_bonus = initial(dropped_item.wound_bonus)
	dropped_item.bare_wound_bonus = initial(dropped_item.bare_wound_bonus)
	dropped_item.armour_penetration = initial(dropped_item.armour_penetration)
	dropped_item.hitsound = initial(dropped_item.hitsound)
	REMOVE_TRAIT(dropped_item, TRAIT_CUSTOM_TAP_SOUND, REF(src))
	UnregisterSignal(dropped_item, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT)
