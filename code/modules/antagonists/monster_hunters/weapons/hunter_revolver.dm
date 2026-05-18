/obj/item/gun/ballistic/revolver/hunter_revolver
	name = "\improper Hunter's Revolver"
	desc = "While doing minimal physical damage, the bullets will force a monster to carry the weight of their impure sins for a short while, greatly slowing them down."
	icon = 'monkestation/icons/obj/guns/redeemer.dmi'
	icon_state = "redeemer"
	inhand_icon_state = "redeemer"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	base_pixel_x = -8
	pixel_x = -8
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	initial_caliber = CALIBER_BLOODSILVER
	force = 18
	armour_penetration = 50
	armour_ignorance = 5
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_KNIFE
	can_hold_up = FALSE // no need, really
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/gun/ballistic/revolver/hunter_revolver/examine(mob/user)
	. = ..()
	if(IS_MONSTERHUNTER(user))
		. += span_info("Right click with it in order to attack with its powerful knife.")

/obj/item/gun/ballistic/revolver/hunter_revolver/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if(is_monster_hunter_prey(target_mob))
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, get_damage_multiplier(target_mob, user.zone_selected))
	return ..()

// always skip to attack if we're right clicking
/obj/item/gun/ballistic/revolver/hunter_revolver/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return ITEM_INTERACT_SKIP_TO_ATTACK

/obj/item/gun/ballistic/revolver/hunter_revolver/proc/get_damage_multiplier(mob/living/victim, def_zone)
	. = 1.2
	// negate physiology damage modifiers (i.e fortitude)
	var/datum/physiology/physiology = astype(victim, /mob/living/carbon/human)?.physiology
	if(physiology)
		var/phys_mod = physiology.brute_mod
		if(phys_mod < 1)
			. /= phys_mod

	// negate bodypart damage modifiers
	var/obj/item/bodypart/affecting = victim.get_bodypart(check_zone(def_zone))
	if(affecting)
		var/part_mod = affecting.brute_modifier
		if(part_mod < 1)
			. /= part_mod

/obj/item/gun/ballistic/revolver/hunter_revolver/can_trigger_gun(mob/living/user, akimbo_usage)
	if(IS_MONSTERHUNTER(user))
		return TRUE
	to_chat(user, span_warning("You can't figure out how to fire \the [src], pricking your hand on its sharp blade!"))
	var/hand_zone = ((user.get_held_index_of_item(src) || user.active_hand_index) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
	user.apply_damage(force / 2, def_zone = hand_zone, sharpness = SHARP_EDGED)
	return FALSE

/datum/movespeed_modifier/silver_bullet
	multiplicative_slowdown = 4
	flags = IGNORE_NOSLOW

/obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	name = "redeemer revolver cylinder"
	ammo_type = /obj/item/ammo_casing/silver
	caliber = CALIBER_BLOODSILVER
	max_ammo = 2

/obj/item/ammo_casing/silver
	name = "bloodsilver casing"
	desc = "A bloodsilver bullet casing."
	icon_state = "redeemer"
	icon = 'monkestation/icons/obj/guns/ammo.dmi'
	projectile_type = /obj/projectile/bullet/bloodsilver
	caliber = CALIBER_BLOODSILVER

/obj/projectile/bullet/bloodsilver
	name = "bloodsilver bullet"
	damage = 3
	ricochets_max = 4
	ricochet_chance = 50
	ricochet_auto_aim_range = 5
	ricochet_shoots_firer = FALSE

/obj/projectile/bullet/bloodsilver/on_hit(mob/living/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target) || QDELING(target) || !is_monster_hunter_prey(target))
		return
	target.apply_status_effect(/datum/status_effect/silver_bullet)

/datum/status_effect/silver_bullet
	id = "silver_bullet"
	duration = 8 SECONDS
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/silver_bullet

	/// Types of status effects to remove.
	/// We're just gonna remove them every tick instead of tediously adding COMSIG_LIVING_BLOODSILVER_HIT to every effect.
	var/list/effects_to_remove = list(
		/datum/status_effect/fleshmend,
		/datum/status_effect/changeling_adrenaline,
		/datum/status_effect/changeling_muscles,
		/datum/status_effect/caretaker_refuge,
	)

/datum/status_effect/silver_bullet/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)
	owner.apply_status_effect(/datum/status_effect/wonderland_district/bloodsilver)
	to_chat(owner, span_userdanger("Your body suddenly feels impossibly heavy, you can barely move!"), type = MESSAGE_TYPE_COMBAT)
	SEND_SIGNAL(owner, COMSIG_LIVING_BLOODSILVER_HIT)
	remove_effects()
	RegisterSignal(owner, COMSIG_MOB_PRE_JAUNT, PROC_REF(on_jaunt))
	return TRUE

/datum/status_effect/silver_bullet/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)
	owner.remove_status_effect(/datum/status_effect/wonderland_district/bloodsilver)
	UnregisterSignal(owner, COMSIG_MOB_PRE_JAUNT)
	to_chat(owner, span_notice("The impossible weight fades away, allowing you to move normally once more."), type = MESSAGE_TYPE_COMBAT)

/datum/status_effect/silver_bullet/tick(seconds_between_ticks)
	remove_effects()

/datum/status_effect/silver_bullet/refresh(effect, ...)
	. = ..()
	SEND_SIGNAL(owner, COMSIG_LIVING_BLOODSILVER_HIT)

/datum/status_effect/silver_bullet/proc/remove_effects(datum/source)
	for(var/effect_type in effects_to_remove)
		owner.remove_status_effect(effect_type)

/datum/status_effect/silver_bullet/proc/on_jaunt(mob/living/jaunter)
	SIGNAL_HANDLER

	to_chat(jaunter, span_userdanger("As you try to jaunt, a hidden beast drags you down, keeping you anchored to this plane of existence!"), type = MESSAGE_TYPE_WARNING)
	duration += 1.5 SECONDS // punishment!!
	return COMPONENT_BLOCK_JAUNT

/atom/movable/screen/alert/status_effect/silver_bullet
	name = "Bloodsilver Curse"
	desc = "You can feel your sins crawling on your back, weighing you down immensely."
	icon_state = "weaken"
