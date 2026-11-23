/*

BLOOD-DRUNK MINER

Effectively a highly aggressive miner, the blood-drunk miner has very few attacks but compensates by being highly aggressive in its AI as well as damage.

The blood-drunk miner's attacks are as follows
- If not in KA range, it will rapidly dash at its target
- If in KA range, it will fire its kinetic accelerator
- If in melee range, will rapidly attack, akin to an actual player
- After any of these attacks, may transform its cleaving saw:
	Untransformed, it attacks very rapidly for smaller amounts of damage
	Transformed, it attacks at normal speed for higher damage and cleaves enemies hit

When the blood-drunk miner dies, it leaves behind the cleaving saw it was using and its kinetic accelerator.

Difficulty: Medium

*/
/mob/living/basic/boss/blood_drunk_miner
	name = "blood-drunk miner"
	desc = "A miner destined to wander forever, engaged in an endless hunt."
	health = 900
	maxHealth = 900
	icon_state = "miner"
	icon_living = "miner"
	base_icon_state = "miner"
	icon = 'icons/mob/simple/broadMobs.dmi'
	health_doll_icon = "miner"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_SPECIAL|MOB_MINING
	light_color = COLOR_LIGHT_GRAYISH_RED
	speak_emote = list("roars")
	speed = 3
	pixel_x = -16
	base_pixel_x = -16
	basic_mob_flags = DEL_ON_DEATH
	blood_volume = BLOOD_VOLUME_NORMAL
	gps_name = "Resonant Signal"
	death_message = "falls to the ground, decaying into glowing particles."
	death_sound = SFX_BODYFALL
	move_force = MOVE_FORCE_NORMAL //Miner beeing able to just move structures like bolted doors and glass looks kinda strange
	rawr_sound = 'sound/effects/magic/demon_dies.ogg'

	ai_controller = /datum/ai_controller/blood_drunk_miner

	achievements = list(
		/datum/award/achievement/boss/blood_miner_kill,
		/datum/award/achievement/boss/boss_killer,
		/datum/award/score/blood_miner_score,
		/datum/award/score/boss_score,
	)
	crusher_achievement_type = /datum/award/achievement/boss/blood_miner_crusher
	victor_memory_type = /datum/memory/megafauna_slayer

	crusher_loot = list(/obj/item/crusher_trophy/miner_eye)
	regular_loot = list(/obj/item/melee/cleaving_saw, /obj/item/gun/energy/recharge/kinetic_accelerator/bdm, /obj/item/disk/design_disk/modkit_disc/blood_drunk_group)

	/// Their little saw
	var/obj/item/melee/cleaving_saw/miner/miner_saw
	/// How many hits of our saw we inflict on the target when we melee on them. Get mutated via the transform weapon ability.
	var/rapid_melee_hits = 5
	/// How long must we wait between ranged attacks
	var/ranged_attack_cooldown_duration = 1.6 SECONDS
	/// extra healing on devour, as a fraction of the victim's max health
	var/devour_heal_bonus = 0.5
	/// health restored on every saw hit
	var/heal_per_hit = 0

/mob/living/basic/boss/blood_drunk_miner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_premove))
	AddElement(/datum/element/relay_attackers)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_HEAVY)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(attack_override))

	miner_saw = new(src)
	RegisterSignal(miner_saw, COMSIG_PREQDELETED, PROC_REF(on_saw_deleted))
	RegisterSignal(miner_saw, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_saw_premove))

	grant_actions_by_list(get_innate_actions())
	var/datum/action/cooldown/kinetic_accelerator = ai_controller.blackboard[BB_BDM_KINETIC_ACCELERATOR_ABILITY]
	kinetic_accelerator?.cooldown_time = ranged_attack_cooldown_duration

/// Block deletion of their saw under normal circumstances. It is fused to their hands as far as we're concerned.
/mob/living/basic/boss/blood_drunk_miner/proc/on_saw_deleted(datum/source, force)
	SIGNAL_HANDLER

	if(!force)
		return TRUE

/mob/living/basic/boss/blood_drunk_miner/Destroy(force)
	UnregisterSignal(miner_saw, list(COMSIG_PREQDELETED, COMSIG_MOVABLE_PRE_MOVE)) // unblock deletion, we are dead.
	QDEL_NULL(miner_saw)
	return ..()

/// Returns a list of innate actions for the blood-drunk miner.
/mob/living/basic/boss/blood_drunk_miner/proc/get_innate_actions()
	var/static/list/innate_abilities = list(
		/datum/action/cooldown/mob_cooldown/dash = BB_BDM_DASH_ABILITY,
		/datum/action/cooldown/mob_cooldown/projectile_attack/kinetic_accelerator = BB_BDM_KINETIC_ACCELERATOR_ABILITY,
		/datum/action/cooldown/mob_cooldown/dash_attack = BB_BDM_DASH_ATTACK_ABILITY,
		/datum/action/cooldown/mob_cooldown/transform_weapon = BB_BDM_TRANSFORM_WEAPON_ABILITY,
	)
	return innate_abilities

/mob/living/basic/boss/blood_drunk_miner/proc/transform_saw()
	miner_saw.attack_self(src)
	var/saw_open = HAS_TRAIT(miner_saw, TRAIT_TRANSFORM_ACTIVE)
	rapid_melee_hits = saw_open ? 3 : 5
	icon_state = "[base_icon_state][saw_open ? "_transformed":""]"
	icon_living = "[base_icon_state][saw_open ? "_transformed":""]"

/mob/living/basic/boss/blood_drunk_miner/ex_act(severity, target)
	var/datum/action/cooldown/mob_cooldown/dash_ability = ai_controller?.blackboard[BB_BDM_DASH_ABILITY]
	if(dash_ability?.Trigger(target = target))
		return FALSE
	return ..()

/mob/living/basic/boss/blood_drunk_miner/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(attacked_atom))
		used_item = miner_saw
	return ..()

/mob/living/basic/boss/blood_drunk_miner/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	var/adjustment_amount = amount * 0.1
	if(world.time + adjustment_amount > next_move)
		changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	return ..()

/mob/living/basic/boss/blood_drunk_miner/death(gibbed)
	var/turf/death_turf = get_turf(src)
	var/death_dir = dir
	. = ..()
	if(stat == DEAD && death_turf)
		new /obj/effect/temp_visual/dir_setting/miner_death(death_turf, death_dir)

/mob/living/basic/boss/blood_drunk_miner/devour(mob/living/victim)
	. = ..()
	if(. && (!is_station_level(z) || client))
		heal_overall_damage(victim.maxHealth * devour_heal_bonus)

/// Prevent running into a chasm and other undesirable movements.
/mob/living/basic/boss/blood_drunk_miner/proc/on_premove(datum/source, atom/new_location)
	SIGNAL_HANDLER
	if(isnull(new_location))
		return

	if(new_location.z != z)
		return

	var/turf/open/locus = get_turf(new_location)
	if(!ischasm(locus) || locus.can_cross_safely(src)) // if it's not a chasm we don't care to check the proc.
		return

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Prevent their saw from being moved at all
/mob/living/basic/boss/blood_drunk_miner/proc/on_saw_premove(datum/source, atom/new_location)
	SIGNAL_HANDLER
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// Handles our attack behavior when we're doing melee attacks to override the default basic melee attack behavior when our AI calls upon us to use it.
/// Namely, we just use the miner saw to rapidly hit the target multiple times
/mob/living/basic/boss/blood_drunk_miner/proc/attack_override(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!isliving(target))
		return

	var/mob/living/victim = target
	if(should_devour(victim))
		devour(victim)
		return COMPONENT_HOSTILE_NO_ATTACK

	do_chain_attack(victim, modifiers)
	return COMPONENT_HOSTILE_NO_ATTACK

/// Hits the victim with the saw, then queues the next hit of the combo. The combo stops once they get away from us.
/mob/living/basic/boss/blood_drunk_miner/proc/do_chain_attack(mob/living/victim, modifiers, sequence_hit = 1)
	if(QDELETED(src) || QDELETED(victim) || stat == DEAD)
		return
	if(!Adjacent(victim))
		post_attack_effects(victim, modifiers)
		return

	changeNext_move(CLICK_CD_MELEE)
	victim.visible_message(
		span_danger("[src] slashes at [victim] with [p_their()] cleaving saw!"),
		span_userdanger("You are slashed at by [src]'s cleaving saw!"),
	)
	INVOKE_ASYNC(miner_saw, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, victim, modifiers)
	if(heal_per_hit)
		adjust_health(-heal_per_hit)

	if(sequence_hit >= rapid_melee_hits)
		post_attack_effects(victim, modifiers)
		return

	// the whole combo takes two seconds no matter how many hits it has
	addtimer(CALLBACK(src, PROC_REF(do_chain_attack), victim, modifiers, sequence_hit + 1), 2 SECONDS / rapid_melee_hits)

/// Hook for potential additional behaviors after attacking
/mob/living/basic/boss/blood_drunk_miner/proc/post_attack_effects(mob/living/victim, list/modifiers)
	return
