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
		/obj/item/grenade/flashbang,
		/obj/item/grenade/chem_grenade/teargas,
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
		/obj/item/radio
	))
	PopulateContents()

/obj/item/storage/belt/security/blueshield/corpjudo/Destroy()
	. = ..()
	QDEL_NULL(style)

/obj/item/storage/belt/security/blueshield/corpjudo/equipped(mob/living/user, slot)
	. = ..()
	if(ishuman(user) && slot & ITEM_SLOT_BELT)
		style.teach(user, TRUE)
		user.apply_status_effect(/datum/status_effect/weapon_lock)

/obj/item/storage/belt/security/blueshield/corpjudo/dropped(mob/living/user)
	. = ..()
	if(ishuman(user) && user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(user)
		user.remove_status_effect(/datum/status_effect/weapon_lock)

///
// MARTIAL ART STYLE
///
/datum/martial_art/corpjudo
	name = "Corporate Judo"
	id = MARTIALART_JUDO
	display_combos = TRUE
	max_streak_length = 12
	combo_timer = 2.5  SECONDS

	help_verb = /mob/living/carbon/human/proc/judo_help

	var/list/combo_moves = list(
		"DG" = /datum/martial_art/corpjudo/proc/discombobulate,
		"HD" = /datum/martial_art/corpjudo/proc/eye_poke,
		"GD" = /datum/martial_art/corpjudo/proc/judo_throw,
		"DDG" = /datum/martial_art/corpjudo/proc/armbar,
		"DDGGDH" = /datum/martial_art/corpjudo/proc/wheel_throw,
		"EDEGDDGEDDGE" = /datum/martial_art/corpjudo/proc/golden_blast,
	)

/datum/martial_art/corpjudo/teach(mob/living/owner, make_temporary=FALSE)
	. = ..()
	if(.)
		to_chat(owner, span_userdanger("You suddenly feel like you could negotiate with gravity itself... well at least your Boss."))

/datum/martial_art/corpjudo/remove(mob/living/owner)
	. = ..()
	if(.)
		to_chat(owner, span_userdanger("As the belt leaves your waist, the secrets of Judo vanish like quarterly profits."))

/mob/living/carbon/human/proc/judo_help()
	set name = "Recall Teachings"
	set desc = "Focus on your Sensi's words and remember your training."
	set category = "Corporate Judo"

	to_chat(usr, "<b><i>An old wise voice echos your mind, it's voice distance and calm. You focus on voice; the world falls silent. With a satisfied treble, it begins to teach.</i></b>")

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
	//some how need to call remove here
	QDEL_NULL(combo_moves)
	return ..()

///
// MARTIAL ART STYLE: ABILITIES
///
/datum/martial_art/corpjudo/proc/discombobulate(mob/living/carbon/human/attacker, mob/living/defender)
	reset_streak(defender)
	defender.visible_message("<span class='warning'>[attacker] strikes [defender] in the head with [attacker.p_their()] palm!</span>", \
						"<span class='userdanger'>[attacker] strikes you with [attacker.p_their()] palm!</span>")
	playsound(get_turf(attacker), 'sound/weapons/slap.ogg', 40, TRUE, -1)
	defender.apply_damage(25, STAMINA)
	defender.adjust_confusion(5 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Discombobulate")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/eye_poke(mob/living/attacker, mob/living/defender)
	reset_streak(defender)
	defender.visible_message("<span class='warning'>[attacker] jabs [defender] in [attacker.p_their()] eyes!</span>", \
						"<span class='userdanger'>[attacker] jabs you in the eyes!</span>")
	playsound(get_turf(attacker), 'sound/weapons/whip.ogg', 40, TRUE, -1)
	defender.apply_damage(10, BRUTE)
	defender.adjust_eye_blur_up_to(5,30)
	defender.set_temp_blindness(2 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Eye Poke")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/judo_throw(mob/living/carbon/human/attacker, mob/living/defender)
	reset_streak(defender)
	if(!attacker.body_position == STANDING_UP || !defender.body_position == STANDING_UP)
		return MARTIAL_ATTACK_INVALID

	if(!defender.pulledby || !(defender.pulledby == attacker))
		defender.visible_message("<span class='warning'>[defender] managed to struggle out of [attacker]'s throw.</span>", \
						"<span class='userdanger'>You wrestle out of [attacker]'s grip!</span>")
		return MARTIAL_ATTACK_INVALID
	defender.visible_message("<span class='warning'>[attacker] judo throws [defender] to ground!</span>", \
						"<span class='userdanger'>[attacker] judo throws you to the ground!</span>")
	playsound(get_turf(attacker), 'sound/weapons/slam.ogg', 40, TRUE, -1)
	defender.apply_damage(62, STAMINA)
	defender.Knockdown(7 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Judo Throw")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/armbar(mob/living/carbon/human/attacker, mob/living/defender)
	if(defender.body_position == STANDING_UP)
		reset_streak(defender)
		return MARTIAL_ATTACK_INVALID
	defender.visible_message("<span class='warning'>[attacker] puts [defender] into an armbar!</span>", \
						"<span class='userdanger'>[attacker] wrestles you into an armbar!</span>")
	playsound(get_turf(attacker), 'sound/weapons/slashmiss.ogg', 40, TRUE, -1)
	if(attacker.body_position == STANDING_UP)
		defender.drop_all_held_items()
	defender.apply_damage(112, STAMINA)
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
		playsound(get_turf(attacker), 'sound/magic/tail_swing.ogg', 40, TRUE, -1)
		defender.SpinAnimation(10, 1)
	else
		defender.visible_message("<span class='warning'>[attacker] manages to get a hold onto [defender], and pinning [defender.p_them()] to the ground!</span>", \
							"<span class='userdanger'>[attacker] throws you over [attacker.p_their()] shoulder, slamming you into the ground!</span>")
		playsound(get_turf(attacker), 'sound/weapons/slam.ogg', 40, TRUE, -1)
	defender.apply_damage(250, STAMINA)
	defender.Knockdown(15 SECONDS)
	defender.set_confusion(10 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Wheel Throw")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/proc/golden_blast(mob/living/carbon/human/attacker, mob/living/defender)
	reset_streak(defender)
	defender.visible_message("<span class='warning'>[attacker] blasts [defender] with energy, sending [defender.p_them()] to the ground!</span>", \
						"<span class='userdanger'>[attacker] makes strange hand gestures, screams wildly and prods you directly in the chest! You feel the wrath of the GOLDEN BOLT surge through your body! You've been utterly robusted!</span>")
	playsound(get_turf(defender), 'sound/weapons/taser.ogg', 55, TRUE, -1)
	playsound(get_turf(defender), 'sound/weapons/taserhit.ogg', 55, TRUE, -1)
	defender.SpinAnimation(10, 1)
	do_sparks(5, FALSE, defender)
	attacker.say("GOLDEN BLAST!")
	playsound(get_turf(defender), 'sound/weapons/goldenblast.ogg', 60, TRUE, -1)
	defender.apply_damage(250, STAMINA)
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
	check_streak(attacker, defender)

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
