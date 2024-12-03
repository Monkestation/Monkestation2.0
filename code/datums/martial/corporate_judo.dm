#define DISCOMBOBULATE "DG"
#define EYE_POKE "HD"
#define JUDO_THROW "GD"
#define ARMBAR "DDG"
#define WHEEL_THROW NONE
#define GOLDEN_BLAST "PDPGDDGPDDGP"

/obj/item/storage/belt/security/blueshield/corpjudo
	name = "\improper Corporate Judo Belt"
	desc = "You could learn Judo the hard way, but at NT money can buy you everything."

	var/datum/martial_art/corpjudo/style

/obj/item/storage/belt/security/blueshield/corpjudo/Initialize(mapload)
	. = ..()
	style = new /datum/martial_art/corpjudo

/obj/item/storage/belt/security/blueshield/corpjudo/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_BELT)
		style.teach(user, TRUE)
	return

/obj/item/storage/belt/security/blueshield/corpjudo/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(user)
	return

/datum/martial_art/corpjudo
	name = "Corporate Judo"
	id = MARTIALART_JUDO
	display_combos = TRUE
	max_streak_length = 13
	combo_timer = 15
/datum/martial_art/corpjudo/teach(mob/living/owner, make_temporary=FALSE)
	if(..())
		to_chat(owner, span_userdanger("You suddenly feel like you could negotiate with gravity itself... well at least your Boss."))

/datum/martial_art/corpjudo/on_remove(mob/living/owner)
	to_chat(owner, span_userdanger("As the belt leaves your waist, the secrets of Judo vanish like quarterly profits."))

/datum/martial_art/corpjudo/proc/discombobulate(mob/living/carbon/human/attacker, mob/living/defender)
	defender.visible_message("<span class='warning'>[attacker] strikes [defender] in the head with [attacker.p_their()] palm!</span>", \
						"<span class='userdanger'>[attacker] strikes you with [attacker.p_their()] palm!</span>")
	playsound(get_turf(attacker), 'sound/weapons/slap.ogg', 40, TRUE, -1)
	defender.apply_damage(10, STAMINA)
	defender.adjust_confusion(5 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Discombobulate")
	return TRUE

/datum/martial_art/corpjudo/proc/eye_poke(mob/living/attacker, mob/living/defender)
	defender.visible_message("<span class='warning'>[attacker] jabs [defender] in [attacker.p_their()] eyes!</span>", \
						"<span class='userdanger'>[attacker] jabs you in the eyes!</span>")
	playsound(get_turf(attacker), 'sound/weapons/whip.ogg', 40, TRUE, -1)
	defender.apply_damage(10, BRUTE)
	defender.adjust_eye_blur_up_to(5,30)
	defender.set_temp_blindness(2 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Eye Poke")
	return TRUE

/datum/martial_art/corpjudo/proc/judothrow(mob/living/carbon/human/attacker, mob/living/defender)
	if(!attacker.body_position == STANDING_UP || !defender.body_position == STANDING_UP)
		return FALSE
	defender.visible_message("<span class='warning'>[attacker] judo throws [defender] to ground!</span>", \
						"<span class='userdanger'>[attacker] judo throws you to the ground!</span>")
	playsound(get_turf(attacker), 'sound/weapons/slam.ogg', 40, TRUE, -1)
	defender.apply_damage(25, STAMINA)
	defender.Knockdown(7 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Judo Throw")
	return TRUE

/datum/martial_art/corpjudo/proc/armbar(mob/living/carbon/human/attacker, mob/living/defender)
	if(defender.body_position == STANDING_UP)
		return FALSE
	defender.visible_message("<span class='warning'>[attacker] puts [defender] into an armbar!</span>", \
						"<span class='userdanger'>[attacker] wrestles you into an armbar!</span>")
	playsound(get_turf(attacker), 'sound/weapons/slashmiss.ogg', 40, TRUE, -1)
	if(attacker.body_position == STANDING_UP)
		defender.drop_all_held_items()
	defender.apply_damage(45, STAMINA)
	//target.apply_status_effect(STATUS_EFFECT_ARMBAR)
	defender.Knockdown(5 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Armbar")
	return TRUE

/datum/martial_art/corpjudo/proc/goldenblast(mob/living/carbon/human/attacker, mob/living/defender)
	defender.visible_message("<span class='warning'>[attacker] blasts [defender] with energy, sending [defender.p_them()] to the ground!</span>", \
						"<span class='userdanger'>[attacker] makes strange hand gestures, screams wildly and prods you directly in the chest! You feel the wrath of the GOLDEN BOLT surge through your body! You've been utterly robusted!</span>")
	playsound(get_turf(defender), 'sound/weapons/taser.ogg', 55, TRUE, -1)
	playsound(get_turf(defender), 'sound/weapons/taserhit.ogg', 55, TRUE, -1)
	defender.SpinAnimation(10, 1)
	do_sparks(5, FALSE, defender)
	attacker.say("GOLDEN BLAST!")
	//playsound(get_turf(defender), 'sound/weapons/goldenblast.ogg', 60, TRUE, -1)
	defender.apply_damage(120, STAMINA)
	defender.Knockdown(30 SECONDS)
	defender.set_confusion(30 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Golden Blast")
	return TRUE

/datum/martial_art/corpjudo/help_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	add_to_streak("P", defender)
	if(check_streak(attacker, defender))
		return TRUE

/datum/martial_art/corpjudo/harm_act(mob/living/attacker, mob/living/defender)
	var/picked_hit_type = pick("chops", "slices", "strikes")
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.apply_damage(10, BRUTE)
	playsound(get_turf(defender), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.visible_message("<span class='danger'>[attacker] [picked_hit_type] [defender]!</span>", \
					"<span class='userdanger'>[attacker] [picked_hit_type] you!</span>")
	log_combat(attacker, defender, "Melee attacked with [src]")
	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return TRUE
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/corpjudo/disarm_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	add_to_streak("D", defender)

	if(check_streak(attacker, defender))
		return TRUE

/datum/martial_art/corpjudo/grab_act(mob/living/attacker, mob/living/defender)
	if(attacker != defender && can_use(attacker)) // attacker != defender prevents grabbing yourself
		add_to_streak("G", defender)
	if(check_streak(attacker, defender))
		return TRUE

/datum/martial_art/corpjudo/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	if(streak == DISCOMBOBULATE)
		reset_streak()
		return discombobulate(attacker, defender)
	if(streak == EYE_POKE)
		reset_streak()
		return eye_poke(attacker, defender)
	if(streak == JUDO_THROW)
		reset_streak()
		return judothrow(attacker, defender)
	if(streak == ARMBAR)
		reset_streak()
		return armbar(attacker, defender)
	if(streak == GOLDEN_BLAST)
		reset_streak()
		return goldenblast(attacker, defender)
	return FALSE

#undef DISCOMBOBULATE
#undef EYE_POKE
#undef JUDO_THROW
#undef ARMBAR
#undef WHEEL_THROW
#undef GOLDEN_BLAST
