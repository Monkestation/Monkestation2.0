///
// PORTED FROM PARADISE STATION
///
#define MIN_COMBO 2

///
// ITEM INFORMATION
///
/obj/item/storage/belt/security/blueshield/corpjudo
	name = "\improper Corporate Judo Belt"
	desc = "You could learn Judo the hard way, but at NT money can buy you everything."
	icon_state = "judobelt"
	worn_icon_state = "judo"
	inhand_icon_state = "judo"

	custom_premium_price = PAYCHECK_COMMAND * 2
	w_class = WEIGHT_CLASS_BULKY

	var/datum/martial_art/corpjudo/style

/obj/item/storage/belt/security/blueshield/corpjudo/PopulateContents()
	// Can fill with new /obj/item to fill with items
	return

/obj/item/storage/belt/security/blueshield/corpjudo/Initialize(mapload)
	. = ..()
	style = new /datum/martial_art/corpjudo
	atom_storage.max_slots = 3
	atom_storage.remove_all()
	atom_storage.set_holdable(list(
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash/handheld,
		/obj/item/food/donut,
		/obj/item/flashlight/seclite,
		/obj/item/holosign_creator/security,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/detective_scanner,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/citationinator, //monkestation edit
		/obj/item/food/spaghetti/security, //monkestation change: tactical belt
		/obj/item/radio,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/gps,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/taperecorder,
	))
	PopulateContents()

/obj/item/storage/belt/security/blueshield/corpjudo/Destroy()
	. = ..()
	QDEL_NULL(style)

/obj/item/storage/belt/security/blueshield/corpjudo/equipped(mob/living/user, slot)
	. = ..()
	if(!QDELETED(style) && ishuman(user) && slot & ITEM_SLOT_BELT)
		style.teach(user, TRUE)

/obj/item/storage/belt/security/blueshield/corpjudo/dropped(mob/living/user)
	. = ..()
	if(!QDELETED(style) && ishuman(user) && user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(user)

///
// MARTIAL ART STYLE
///
/datum/martial_art/corpjudo
	name = "Corporate Judo"
	id = MARTIALART_JUDO
	display_combos = TRUE
	max_streak_length = 12
	combo_timer = 3.5  SECONDS

	var/datum/action/jigotai/jigotai = new()
	var/datum/action/cooldown/golden_bolt/bolt = new()

	help_verb = /mob/living/carbon/human/proc/judo_help

	var/list/combo_moves = list(
		"DG" = PROC_REF(discombobulate),
		"HD" = PROC_REF(eye_poke),
		"GD" = PROC_REF(judo_throw),
		"DDG" = PROC_REF(armbar),
		"DDGGDH" = PROC_REF(wheel_throw),
		"EDEGDDGEDDGE" = PROC_REF(golden_blast),
	)

/datum/martial_art/corpjudo/teach(mob/living/owner, make_temporary=FALSE)
	. = ..()
	if(.)
		to_chat(owner, span_userdanger("You suddenly feel like you could negotiate with gravity itself... well at least your Boss."))
		owner.apply_status_effect(/datum/status_effect/weapon_lock)
		jigotai.Grant(owner)
		bolt.Grant(owner)

/datum/martial_art/corpjudo/remove(mob/living/owner)
	. = ..()
	owner.remove_status_effect(/datum/status_effect/weapon_lock)
	jigotai.Remove(owner)
	bolt.Remove(owner)
	if(.)
		to_chat(owner, span_userdanger("As the belt leaves your waist, the secrets of Judo vanish like quarterly profits."))

/mob/living/carbon/human/proc/judo_help()
	set name = "Recall Teachings"
	set desc = "Focus on your Sensi's words and remember your training."
	set category = "Corporate Judo"

	to_chat(usr, "<b><i>An old wise voice echos your mind, it's voice distance and calm. You focus on the voice; the world falls silent. With a satisfied treble, it begins to teach.</i></b>")

	var/list/teach_msg = list()

	teach_msg += span_notice("Upgraded Punch") + ": " + span_memo("Your punches strike harder than normal.")
	teach_msg += span_notice("Discomboulate") + ": " + span_memo("Disarm Grab.") + " Gentle key strikes to the temple; drains some of the opponents stamina, and confuses them for a moment."
	teach_msg += span_notice("Eye Poke") + ": " + span_memo("Harm Disarm.") + " Masterfully jab your fingers into your opponents eyes. Causes harm and makes it increasingly hard to see."
	teach_msg += span_notice("Judo Throw") + ": " + span_memo("Grab Disarm.") + " You and your opponent must not be on the floor. With a gentle maintained grasp, throw them to the floor draining their stamina and ability to stand up."
	teach_msg += span_notice("Armbar") + ": " + span_memo("Disarm Disarm Grab.") + " Twist the arm of a laying opponent causing them heavy exhaustion and knocking them into the floor. Standing leverage causes the opponent to drop their held possesions."
	teach_msg += span_notice("Wheel Throw") + ": " + span_memo("Armbar->Grab Disarm Harm.") + " Continuing from Armbar this dance will throw a laying opponent over your body and back into the ground. Heavy exhaustion, confusion, and loss of balance will follow."
	teach_msg += span_notice("Golden Blast") + ": " + span_memo("Help Disarm Help-Grab Disarm Disarm-Grab Help Disarm-Disarm Grab Help.") + " An absurdly intricate fighting move to demonstrate your mastery of the Judo arts. Hits opponent with golden energy. Knocks them down heavily causing confusion, exhaustion, balance loss."
	to_chat(usr, teach_msg.Join("\n"))

/datum/martial_art/corpjudo/Destroy()
	if(holder)
		var/mob/living/owner = holder.resolve()
		if(owner)
			remove(owner) // Clean up the martial art effects from the owner
	combo_moves = null
	QDEL_NULL(jigotai)
	return ..()

///
// MARTIAL ART STYLE: ABILITIES
///
/datum/martial_art/corpjudo/proc/discombobulate(mob/living/carbon/human/attacker, mob/living/defender)
	reset_streak(defender)
	defender.visible_message("<span class='warning'>[attacker] strikes [defender] in the head with [attacker.p_their()] palm!</span>", \
						"<span class='userdanger'>[attacker] strikes you with [attacker.p_their()] palm!</span>")
	playsound(get_turf(attacker), 'sound/items/weapons/slap.ogg', 40, TRUE, -1)
	defender.apply_damage(25, STAMINA)
	defender.adjust_confusion(5 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Discombobulate")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/eye_poke(mob/living/attacker, mob/living/defender)
	reset_streak(defender)
	if(defender.is_eyes_covered())
		to_chat(span_warning("[defender] has [defender.p_their()] eyes covered."))
		return MARTIAL_ATTACK_FAIL
	defender.visible_message("<span class='warning'>[attacker] jabs [defender] in [attacker.p_their()] eyes!</span>", \
						"<span class='userdanger'>[attacker] jabs you in the eyes!</span>")
	playsound(get_turf(attacker), 'sound/items/weapons/whip.ogg', 40, TRUE, -1)
	defender.apply_damage(10, BRUTE)
	defender.adjust_eye_blur_up_to(5,30)
	defender.set_temp_blindness(2 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Eye Poke")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/judo_throw(mob/living/carbon/human/attacker, mob/living/defender)
	reset_streak(defender)
	if(!attacker.body_position == STANDING_UP || !defender.body_position == STANDING_UP)
		return MARTIAL_ATTACK_INVALID

	if(defender.pulledby != attacker)
		defender.visible_message("<span class='warning'>[defender] managed to struggle out of [attacker]'s throw.</span>", \
						"<span class='userdanger'>You wrestle out of [attacker]'s grip!</span>")
		return MARTIAL_ATTACK_INVALID
	defender.visible_message("<span class='warning'>[attacker] judo throws [defender] to ground!</span>", \
						"<span class='userdanger'>[attacker] judo throws you to the ground!</span>")
	playsound(get_turf(attacker), 'sound/items/weapons/slam.ogg', 40, TRUE, -1)
	defender.apply_damage(25, STAMINA)
	defender.Knockdown(7 SECONDS, prevent_drop = TRUE)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Judo Throw")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/armbar(mob/living/carbon/human/attacker, mob/living/defender)
	if(defender.body_position == STANDING_UP)
		reset_streak(defender)
		return MARTIAL_ATTACK_INVALID
	defender.visible_message("<span class='warning'>[attacker] puts [defender] into an armbar!</span>", \
						"<span class='userdanger'>[attacker] wrestles you into an armbar!</span>")
	playsound(get_turf(attacker), 'sound/items/weapons/slashmiss.ogg', 40, TRUE, -1)
	if(attacker.body_position == STANDING_UP)
		defender.drop_all_held_items()
	defender.apply_damage(45, STAMINA)
	defender.Knockdown(5 SECONDS)
	combo_refresh() // Flow combos need to refresh the chain.
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Armbar")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/wheel_throw(mob/living/carbon/human/attacker, mob/living/defender)
	reset_streak(defender)
	if(defender.body_position == STANDING_UP)
		return MARTIAL_ATTACK_INVALID
	if(attacker.body_position == STANDING_UP)
		defender.visible_message("<span class='warning'>[attacker] raises [defender] over [attacker.p_their()] shoulder, and slams [defender.p_them()] into the ground!</span>", \
							"<span class='userdanger'>[attacker] throws you over [attacker.p_their()] shoulder, slamming you into the ground!</span>")
		playsound(get_turf(attacker), 'sound/effects/magic/tail_swing.ogg', 40, TRUE, -1)
		defender.SpinAnimation(10, 1)
	else
		defender.visible_message("<span class='warning'>[attacker] manages to get a hold onto [defender], and pinning [defender.p_them()] to the ground!</span>", \
							"<span class='userdanger'>[attacker] throws you over [attacker.p_their()] shoulder, slamming you into the ground!</span>")
		playsound(get_turf(attacker), 'sound/items/weapons/slam.ogg', 40, TRUE, -1)
	defender.apply_damage(120, STAMINA)
	defender.Knockdown(15 SECONDS)
	defender.set_confusion(10 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Wheel Throw")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/golden_blast(mob/living/carbon/human/attacker, mob/living/defender)
	reset_streak(defender)
	defender.visible_message("<span class='warning'>[attacker] blasts [defender] with energy, sending [defender.p_them()] to the ground!</span>", \
						"<span class='userdanger'>[attacker] makes strange hand gestures, screams wildly and prods you directly in the chest! You feel the wrath of the GOLDEN BOLT surge through your body! You've been utterly robusted!</span>")
	playsound(get_turf(defender), 'sound/items/weapons/taser.ogg', 55, TRUE, -1)
	playsound(get_turf(defender), 'sound/items/weapons/taserhit.ogg', 55, TRUE, -1)
	defender.SpinAnimation(10, 1)
	do_sparks(5, FALSE, defender)
	attacker.say("GOLDEN BLAST!")
	playsound(get_turf(defender), 'sound/items/weapons/goldenblast.ogg', 60, TRUE, -1)
	defender.apply_damage(120, STAMINA)
	defender.Knockdown(30 SECONDS)
	defender.set_confusion(30 SECONDS)
	//says this causes a full stun not sure if that is something wanted.
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Golden Blast")
	return MARTIAL_ATTACK_SUCCESS

///
// Combo Adders
///
/datum/martial_art/corpjudo/help_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender || !can_use(attacker))
		return MARTIAL_ATTACK_INVALID

	add_to_streak("E", defender)
	return check_streak(attacker, defender)

/datum/martial_art/corpjudo/harm_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender || !can_use(attacker))
		return MARTIAL_ATTACK_INVALID
	add_to_streak("H", defender)

	if(check_streak(attacker, defender) == MARTIAL_ATTACK_SUCCESS)
		return MARTIAL_ATTACK_SUCCESS

	var/picked_hit_type = pick("chops", "slices", "strikes")
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.apply_damage(10, BRUTE)
	playsound(get_turf(defender), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.visible_message("<span class='danger'>[attacker] [picked_hit_type] [defender]!</span>", \
					"<span class='userdanger'>[attacker] [picked_hit_type] you!</span>")
	log_combat(attacker, defender, "Melee attacked with [src]")
	return MARTIAL_ATTACK_SUCCESS // If we applied our buffed damage don't allow normal punches.

/datum/martial_art/corpjudo/disarm_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender || !can_use(attacker))
		return MARTIAL_ATTACK_INVALID

	add_to_streak("D", defender)
	return check_streak(attacker, defender)

/datum/martial_art/corpjudo/grab_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender || !can_use(attacker))
		return MARTIAL_ATTACK_INVALID

	add_to_streak("G", defender)
	return check_streak(attacker, defender)

/datum/martial_art/corpjudo/proc/combo_refresh()
	// Since combo is continuing, refresh our timer sorta like DMC.
	if(timerid)
		deltimer(timerid)
	if (display_combos)
		var/mob/living/holder_living = holder.resolve()
		timerid = addtimer(CALLBACK(src, PROC_REF(reset_streak), null, FALSE), combo_timer, TIMER_UNIQUE | TIMER_STOPPABLE)
		holder_living?.hud_used?.combo_display.update_icon_state(streak, combo_timer - 2 SECONDS)

/datum/martial_art/corpjudo/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(length(streak) < MIN_COMBO)
		combo_refresh()
		return MARTIAL_ATTACK_INVALID
	else
		var/combo_action = combo_moves[streak] // Check for exact matches and fires ability.
		if(combo_action)
			return call(src, combo_action)(attacker, defender)

		for(var/combo in combo_moves) // Check for partial combos so we can refresh our timer.
			if(length(streak) < length(combo) && copytext(combo, 1, (length(streak) + 1)) == streak)
				combo_refresh()
				return MARTIAL_ATTACK_INVALID

		var/last_move = copytext(streak, -1, 0) // Not building to a valid combo reset and carry over combo breaking move.
		reset_streak(defender)
		add_to_streak(last_move, defender)
		return MARTIAL_ATTACK_INVALID

#undef MIN_COMBO

///
// Judo Abilities
///
/datum/action/jigotai
	name = "Jigotai"
	desc = "Enter a defensive stance, readying yourself for an opponent's strike. If struck, use their own force against them to throw them to the ground."
	button_icon = 'icons/hud/stances.dmi'
	button_icon_state = "jigotai"

	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_LYING

	var/active = FALSE
	//RegisterSignal(owner, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/action/jigotai/Remove(mob/remove_from)
	..()
	deactivate(remove_from)

/datum/action/jigotai/Trigger(trigger_flags)
	if(active) // Can deactivate while stunned and what not.
		deactivate(owner)
		return TRUE
	. = ..()
	if(!.)
		return .
	if(DOING_INTERACTION(owner, "doafter_jigotai"))
		return FALSE
	if(!do_after(owner, 1 SECONDS, interaction_key = "doafter_jigotai", extra_checks = CALLBACK(src, PROC_REF(IsAvailable))))
		return FALSE
	owner.visible_message(span_danger("[owner] assumes a defensive posture."), "<b><i>Your body is ready for an attack. You will counter if struck.</i></b>")
	active = TRUE
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(move_cancel))
	RegisterSignal(owner, COMSIG_ATOM_CAN_BE_PULLED, PROC_REF(grab_attempted))

/datum/action/jigotai/proc/deactivate(mob/deactivate_from)
	var/mob/deactivater = deactivate_from
	if(!istype(deactivate_from))
		deactivater = owner

	if(active)
		deactivate_from.visible_message(span_danger("[deactivate_from] drops their defensive stance."), "<b><i>You lose your defensive stance.</i></b>")

	active = FALSE
	UnregisterSignal(deactivater, list(COMSIG_LIVING_CHECK_BLOCK, COMSIG_MOVABLE_PRE_MOVE, COMSIG_ATOM_CAN_BE_PULLED))

/datum/action/jigotai/proc/check_block(mob/living/carbon/human/source,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE,)

	SIGNAL_HANDLER

	if(attack_type != MELEE_ATTACK && attack_type != UNARMED_ATTACK)
		if(attack_type == THROWN_PROJECTILE_ATTACK)
			if(hitby.throwforce > 7)
				deactivate(source)
		else if(attack_type == PROJECTILE_ATTACK || attack_type == LEAP_ATTACK)
			deactivate(source)
		return FAILED_BLOCK
	if(!IsAvailable())
		deactivate(source)
		return FAILED_BLOCK

	if(!active)
		return FAILED_BLOCK

	var/mob/living/carbon/human/attacker = GET_ASSAILANT(hitby)
	if(!ishuman(attacker) || !source.Adjacent(attacker))
		return FAILED_BLOCK

	deactivate(source)
	//attacker.apply_damage(15+damage, STAMINA)
	INVOKE_ASYNC(src, PROC_REF(counter_throw), source, attacker)
	return SUCCESSFUL_BLOCK

/datum/action/jigotai/proc/move_cancel(atom/movable/mover, turf/target)
	SIGNAL_HANDLER

	deactivate(mover)

/datum/action/jigotai/proc/grab_attempted(mob/living/judo_user, mob/living/puller)
	SIGNAL_HANDLER

	if(!ishuman(puller))
		return
	if(!IsAvailable())
		deactivate(judo_user)
		return
	if(!active)
		return
	if(!judo_user.Adjacent(puller))
		return
	deactivate(judo_user)
	INVOKE_ASYNC(src, PROC_REF(counter_throw), judo_user, puller)
	return COMSIG_ATOM_CANT_PULL

/datum/action/jigotai/proc/counter_throw(mob/living/carbon/human/defender, mob/living/carbon/human/attacker)
	if(!defender.Adjacent(attacker))
		return
	defender.grab(attacker)

	if(QDELETED(defender) || QDELETED(attacker))
		return
	var/datum/martial_art/corpjudo/judo_user = astype(defender.mind?.martial_art)
	if(QDELETED(judo_user))
		return
	judo_user.judo_throw(defender, attacker)

///datum/action/jigotai/proc/on_attackby(mob/living/carbon/human/carp_user, obj/item/melee/touch_attack/touch_weapon, mob/attacker, params)
//	SIGNAL_HANDLER //Used if we want to counter touch_attack weapons and even cause them to be applied to attacker. Hold for now
//	to_chat(owner, "hit")

/datum/action/cooldown/golden_bolt
	name = "Golden Bolt"
	desc = "Use the belts Nanites to summon an electric bolt. Those struck feel their muscles tense up slowing them down."
	button_icon = 'icons/hud/stances.dmi'
	button_icon_state = "golden_bolt"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_LYING

	var/fired_cooldown = 30 SECONDS
	var/obj/item/hand_item/golden_bolt/hand_bolt

//COMSIG_PROJECTILE_FIRER_BEFORE_FIRE
/datum/action/cooldown/golden_bolt/Grant(mob/grant_to)
	. = ..()
	if(!isnull(owner))
		RegisterSignal(owner, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE, PROC_REF(activate_cooldown))

/datum/action/cooldown/golden_bolt/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE)
	QDEL_NULL(hand_bolt)

/datum/action/cooldown/golden_bolt/Activate(atom/target)
	if(QDELETED(hand_bolt))
		hand_bolt = null
	if(istype(hand_bolt))
		QDEL_NULL(hand_bolt)
		return
	hand_bolt = new /obj/item/hand_item/golden_bolt(owner)
	if(owner.put_in_active_hand(hand_bolt))
		owner.visible_message("[owner] summons a ball of energy into [owner.p_Their()] hand.",
		"Your hand now crackles with the belt's energy."
		)
	else
		QDEL_NULL(hand_bolt)
	return .

/datum/action/cooldown/golden_bolt/proc/activate_cooldown(datum/source, obj/projectile/bullet, atom/firer, atom/original_target)
	SIGNAL_HANDLER
	if((firer == owner) && istype(bullet, /obj/projectile/golden_bolt))
		StartCooldown(fired_cooldown)

/obj/item/hand_item/golden_bolt
	name = "\improper golden bolt"
	desc = "Take all the energy you collected and fire it at your opponent."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "Golden_Bolt"
	lefthand_file = 'icons/mob/inhands/items/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/touchspell_righthand.dmi'
	inhand_icon_state = "duffelcurse"

	var/bolt_projectile = /obj/projectile/golden_bolt

/obj/item/hand_item/golden_bolt/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/hand_item/golden_bolt/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	var/obj/projectile/fired_bolt = new /obj/projectile/golden_bolt(get_turf(user))

	//Shooting Code:
	fired_bolt.original = target
	fired_bolt.fired_from = user
	fired_bolt.firer = user // don't hit ourself that would be really annoying
	fired_bolt.impacted = list(WEAKREF(user) = TRUE) // just to make sure we don't hit the wearer
	fired_bolt.aim_projectile(target, user)
	fired_bolt.fire()
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/projectile/golden_bolt
	name = "Golden Bolt"
	icon_state = "Golden_Bolt"
	hitsound = 'sound/items/weapons/taser3.ogg'
	hitsound_wall = 'sound/items/weapons/taser3.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	speed = 1.6
	damage_type = BRUTE
	damage = 0 // Meant to slow does no damage
	armour_penetration = 100 // Do I need this?

/obj/projectile/golden_bolt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parriable_projectile)

/obj/projectile/golden_bolt/fire(angle, atom/direct_target)
	if(firer && ishuman(firer))
		var/mob/living/carbon/human/ryu = firer
		if(prob(10))
			icon_state = "hadouken"
			ryu.say("Hadouken!!!")
		else
			ryu.say("Golden Bolt!!!")
	return ..()

/obj/projectile/golden_bolt/impact(atom/A)
	def_zone = BODY_ZONE_CHEST
	return ..()

/obj/projectile/golden_bolt/on_hit(atom/target, blocked, pierce_hit)
	. = ..()

	if(. == BULLET_ACT_BLOCK)
		return .

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		try_slow(human_target)

/obj/projectile/golden_bolt/proc/try_slow(mob/living/carbon/human/living_target)
	living_target.apply_status_effect(/datum/status_effect/judo_slow)
	playsound(living_target, 'sound/items/weapons/taserhit.ogg', clamp(vol_by_damage() + (suppressed ? 0 : 20), 0, 100), TRUE, -1,  mixer_channel = mixer_channel)
	living_target.visible_message("<b>[living_target] looks like they are struggling to move.",
	span_userdanger("Your muscles are extremely tense making moving more difficult.")
	)
