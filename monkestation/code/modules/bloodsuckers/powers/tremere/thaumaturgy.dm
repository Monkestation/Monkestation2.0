/**
 *	# Thaumaturgy
 *
 *	Level 1 - One shot bloodbeam spell
 *	Level 3 - Bloodbeam spell - Gives them a Blood shield until they use Bloodbeam
 *	Level 4 - Bloodbeam spell that breaks open lockers - Gives them a Blood shield until they use Bloodbeam
 *	Level 5 - Bloodbeam spell that breaks open lockers + double damage to victims - Gives them a Blood shield until they use Bloodbeam
 *	Level 6 - Bloodbeam spell that breaks open lockers + double damage & steals blood - Gives them a Blood shield until they use Bloodbeam
 */

#define BLOOD_SHIELD_BLOCK_CHANCE 50
#define BLOOD_SHIELD_BLOOD_COST 15
#define THAUMATURGY_BLOOD_COST_PER_CHARGE 5
#define THAUMATURGY_COOLDOWN_PER_CHARGE 5 SECONDS

#define THAUMATURGY_SHIELD_LEVEL 3
#define THAUMATURGY_CLOSET_BREAK_LEVEL 4
#define THAUMATURGY_EXTRA_DAMAGE_LEVEL 5
#define THAUMATURGY_BLOOD_STEAL_LEVEL 6

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy
	name = "Thaumaturgy"
	level_current = 1
	button_icon_state = "power_thaumaturgy"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	purchase_flags = TREMERE_CAN_BUY
	// custom cooldown handling based on charges
	power_flags = BP_AM_STATIC_COOLDOWN
	bloodcost = 5
	// 5 seconds per charge
	cooldown_time = 10 SECONDS
	prefire_message = "Right click where you wish to fire."
	click_to_activate = TRUE // you pay to replenish charges
	power_activates_immediately = FALSE
	unset_after_click = FALSE // Lets us cast multiple times
	/// How many times you can shoot before you need to recast
	var/charges = 0
	/// How long it takes before you can shoot again
	var/shot_cooldown = 0
	var/datum/weakref/blood_shield
	var/obj/projectile/magic/arcane_barrage/bloodsucker/magic_9ball
	var/speed = 1
	var/pixel_speed = 0.3

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/Grant()
	charges = get_max_charges()
	. = ..()

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/Remove()
	. = ..()
	QDEL_NULL(blood_shield)
/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/on_power_upgrade()
	cooldown_time = get_max_charges() * THAUMATURGY_COOLDOWN_PER_CHARGE
	bloodcost = get_max_charges() * THAUMATURGY_BLOOD_COST_PER_CHARGE
	// just in case you somehow level up while the power is active
	charges = get_max_charges()
	. = ..()

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/get_power_desc_extended()
	. = "<br>Projectile can seek for [get_shot_range()] tiles.<br>"
	. += "Fire a slow seeking blood bolt at your enemy.<br>"
	if(level_current >= THAUMATURGY_SHIELD_LEVEL)
		. += "Right click the button to create a blood shield<br>"
	if(level_current >= THAUMATURGY_CLOSET_BREAK_LEVEL)
		. += "The projectile will open lockers"
	if(level_current >= THAUMATURGY_BLOOD_STEAL_LEVEL)
		. += " and steal blood from the target"

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/get_power_explanation_extended()
	. = list()
	. += "Thaumaturgy grants you the ability to cast and shoot a slow moving target seeking blood projectile."
	. += "The projectile will auto aim to a nearby mob if you aim at the ground."
	. += "If the Blood blast hits a person, it will deal [get_blood_bolt_damage()] [initial(magic_9ball.damage_type)] damage, and is blocked by [initial(magic_9ball.armor_flag)] armor."
	. += "You can use Blood blast [get_max_charges()] times before needing to recast Thaumaturgy. After each shot you will have to wait [DisplayTimeText(get_shot_cooldown())]."
	. += "At level [THAUMATURGY_SHIELD_LEVEL] it will grant you a shield that will block [BLOOD_SHIELD_BLOCK_CHANCE]% of incoming damage, costing you [THAUMATURGY_BLOOD_COST_PER_CHARGE] blood each time."
	. += "To activate the shield, right click the action button."
	. += "At level [THAUMATURGY_CLOSET_BREAK_LEVEL], it will also break open lockers."
	. += "At level [THAUMATURGY_BLOOD_STEAL_LEVEL], it will also steal blood to feed yourself, just as much as each charge costs."
	. += "The cooldown increases by [DisplayTimeText(THAUMATURGY_COOLDOWN_PER_CHARGE)] per charge used, and each blast costs [THAUMATURGY_BLOOD_COST_PER_CHARGE] blood."

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/ActivatePower(mob/target)
	. = ..()
	charges = get_max_charges()
	toggle_blood_shield(TRUE)

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/proc/toggle_blood_shield(toggle)
	if(level_current < THAUMATURGY_SHIELD_LEVEL)
		return
	// don't toggle if we're already in the state we want to be in
	if(toggle == !!blood_shield)
		return

	if(blood_shield)
		var/shield = blood_shield?.resolve()
		owner.visible_message(
			span_warning("[owner]\'s [shield] loses its form and disappears into [owner.p_their()] hands!"),
			span_warning("We unform our Blood shield!"),
			span_hear("You hear liquids sloshing around."),
		)
		owner.balloon_alert(owner, "you unform the [shield]")
		qdel(shield)
		blood_shield = null
	else
		var/obj/item/shield/bloodsucker/new_shield = new
		blood_shield = WEAKREF(new_shield)
		if(!owner.put_in_inactive_hand(new_shield))
			QDEL_NULL(new_shield)
			owner.balloon_alert(owner, "off hand is full!")
			to_chat(owner, span_notice("[capitalize(src)] couldn't be activated as your off hand is full."))
			return FALSE
		owner.balloon_alert(owner, "you form the [new_shield]")
		owner.visible_message(
			span_warning("[owner]\'s hands begins to bleed and forms into a [new_shield]!"),
			span_warning("We form our [new_shield]!"),
			span_hear("You hear liquids forming together."),
		)

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/DeactivatePower(deactivate_flags)
	..()
	var/used_charges = get_max_charges() - charges
	toggle_blood_shield(FALSE)
	if(used_charges > 0)
		StartCooldown()

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/StartCooldown(override_cooldown_time, override_melee_cooldown_time)
	var/used_charges = get_max_charges() - charges
	// no cooldown if we didn't use any charges
	if(used_charges <= 0)
		return
	charges = get_max_charges()
	return ..(used_charges * THAUMATURGY_COOLDOWN_PER_CHARGE, override_melee_cooldown_time)

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/proc/get_blood_bolt_damage()
	if(level_current >= THAUMATURGY_EXTRA_DAMAGE_LEVEL)
		return 25
	return 15

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/proc/get_max_charges()
	return level_current * 2

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/proc/get_shot_cooldown()
	return max(1.5 - (level_current * 0.1), 0) SECONDS

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/proc/get_shot_range()
	return initial(magic_9ball.range) + level_current * 5

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/update_button_status(atom/movable/screen/movable/action_button/button, force)
	. = ..()
	var/time_left = max(next_use_time - world.time, 0)
	if(time_left == 0 && next_use_time - world.time <= 0)
		button.maptext = MAPTEXT_TINY_UNICODE(span_center("[charges]/[get_max_charges()]"))
		button.maptext_x = -5
	else
		button.maptext_x = 4

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/FireTargetedPower(atom/target_atom)
	return FALSE

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/FireSecondaryTargetedPower(atom/target, params)
	if(shot_cooldown > world.time)
		return TRUE
	if(!can_pay_cost(THAUMATURGY_BLOOD_COST_PER_CHARGE))
		owner.balloon_alert(owner, "not enough blood!")
		DeactivatePower()
		return TRUE
	shot_cooldown = world.time + get_shot_cooldown()
	var/mob/living/user = owner
	owner.balloon_alert(owner, "you fire a blood bolt!")
	owner.visible_message(
		span_warning("[owner] fires a blood bolt at [target]!"),
		span_warning("You fire a blood bolt at [target]!"),
		span_hear("You hear a loud crackling sound."),
	)
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target, user))
	user.face_atom(target)
	handle_shot(user, target)

	pay_cost(THAUMATURGY_BLOOD_COST_PER_CHARGE)
	playsound(user, 'sound/magic/wand_teleport.ogg', 60, TRUE)
	charges -= 1
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	if(charges <= 0)
		// delay the message so it doesn't overlap with the cooldown message
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, balloon_alert), owner, "no charges left!"), 0.5 SECONDS)
		power_activated_sucessfully(cost_override = 0)
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/proc/handle_shot(mob/user, atom/target)
	magic_9ball = new(get_turf(user))
	magic_9ball.speed = speed
	magic_9ball.pixel_speed_multiplier = pixel_speed
	magic_9ball.firer = user
	magic_9ball.power_ref = WEAKREF(src)
	magic_9ball.damage = get_blood_bolt_damage()
	magic_9ball.def_zone = ran_zone(user.zone_selected, min(level_current * 10, 90))
	magic_9ball.preparePixelProjectile(target, user)
	// autotarget if we aim at a turf
	if(isturf(target))
		var/list/targets = list()
		for(var/mob/living/possible_target in range(1, target) - user)
			if(possible_target.stat == DEAD)
				continue
			var/datum/antagonist/vassal/vassal = IS_VASSAL(possible_target)
			if(vassal && (vassal in bloodsuckerdatum_power?.vassals))
				continue
			targets += possible_target
		if(length(targets))
			magic_9ball.set_homing_target(pick(targets))
	else
		magic_9ball.homing_target = target
	magic_9ball.homing_turn_speed = min(10 * level_current, 90)
	magic_9ball.range = get_shot_range()
	INVOKE_ASYNC(magic_9ball, TYPE_PROC_REF(/obj/projectile, fire))
	// ditch the pointer to reduce harddels
	magic_9ball = null
/**
 * 	# Blood Bolt
 *
 *	This is the projectile this Power will fire.
 */
/obj/projectile/magic/arcane_barrage/bloodsucker
	name = "blood bolt"
	icon_state = "mini_leaper"
	damage = 1
	wound_bonus = 20
	armour_penetration = 30
	speed = 3
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	range = 30
	armor_flag = LASER
	var/datum/weakref/power_ref

/obj/projectile/magic/arcane_barrage/bloodsucker/on_hit(target, blocked = 0, pierce_hit)
	var/datum/action/cooldown/bloodsucker/targeted/tremere/thaumaturgy/bloodsucker_power = power_ref?.resolve()
	if(!bloodsucker_power)
		return ..()
	if(bloodsucker_power.level_current >= THAUMATURGY_CLOSET_BREAK_LEVEL)
		if(istype(target, /obj/structure/closet))
			var/obj/structure/closet/hit_closet = target
			hit_closet.welded = FALSE
			hit_closet.locked = FALSE
			hit_closet.broken = TRUE
			hit_closet.update_appearance()
	if(isliving(target) && bloodsucker_power.level_current >= THAUMATURGY_BLOOD_STEAL_LEVEL)
		var/mob/living/person_hit = target
		person_hit.blood_volume -= THAUMATURGY_BLOOD_COST_PER_CHARGE
		var/datum/antagonist/bloodsucker/bloodsucker = bloodsucker_power.bloodsuckerdatum_power
		if(bloodsucker)
			bloodsucker.bloodsucker_blood_volume += min(THAUMATURGY_BLOOD_COST_PER_CHARGE, bloodsucker.max_blood_volume)
	return ..()

/**
 *	# Blood Shield
 *
 *	The shield spawned when using Thaumaturgy when strong enough.
 *	Copied mostly from '/obj/item/shield/changeling'
 */

/obj/item/shield/bloodsucker
	name = "blood shield"
	desc = "A shield made out of blood, requiring blood to sustain hits."
	item_flags = ABSTRACT | DROPDEL
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	icon_state = "blood_shield"
	lefthand_file = 'monkestation/icons/bloodsuckers/bloodsucker_lefthand.dmi'
	righthand_file = 'monkestation/icons/bloodsuckers/bloodsucker_righthand.dmi'
	block_chance = BLOOD_SHIELD_BLOCK_CHANCE

/obj/item/shield/bloodsucker/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)

/obj/item/shield/bloodsucker/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(owner)
	if(bloodsuckerdatum)
		bloodsuckerdatum.bloodsucker_blood_volume -= max(BLOOD_SHIELD_BLOOD_COST, 0)
	return ..()

#undef BLOOD_SHIELD_BLOCK_CHANCE
#undef BLOOD_SHIELD_BLOOD_COST
#undef THAUMATURGY_BLOOD_COST_PER_CHARGE
#undef THAUMATURGY_COOLDOWN_PER_CHARGE

#undef THAUMATURGY_SHIELD_LEVEL
#undef THAUMATURGY_CLOSET_BREAK_LEVEL
#undef THAUMATURGY_BLOOD_STEAL_LEVEL
#undef THAUMATURGY_EXTRA_DAMAGE_LEVEL
