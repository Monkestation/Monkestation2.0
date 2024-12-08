///
// PORTED FROM PARADISE STATION
///
#define DISCOMBOBULATE "DG"
#define EYE_POKE "HD"
#define JUDO_THROW "GD"
#define ARMBAR "DDG"
#define WHEEL_THROW "GDH"
#define GOLDEN_BLAST1 "EDEGDD"
#define GOLDEN_BLAST2 "GEDDGE"

//Don't know how a human would get a borg/stun but the cyberimp item sets worried me. So just in case.
#define BANNEDTYPES list(/obj/item/melee/baton, /obj/item/borg/stun)

///
// ITEM INFORMATION
///
/obj/item/storage/belt/security/blueshield/corpjudo
	name = "\improper Corporate Judo Belt"
	desc = "You could learn Judo the hard way, but at NT money can buy you everything."
	icon_state = "judobelt"
	worn_icon_state = "judo"
	inhand_icon_state = "judo"

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
	QDEL_NULL(style)
	. = ..()

/obj/item/storage/belt/security/blueshield/corpjudo/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user))
		if(slot & ITEM_SLOT_BELT)
			style.teach(user, TRUE)
			style.blaststage = 0
			ADD_TRAIT(user, TRAIT_NO_WEAPONTYPE, src)

/obj/item/storage/belt/security/blueshield/corpjudo/dropped(mob/user)
	. = ..()
	if(ishuman(user))
		if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
			style.remove(user)
			style.blaststage = 0
			REMOVE_TRAIT(user, TRAIT_NO_WEAPONTYPE, src)


/mob/living/proc/is_weapon_restricted(mob/living/defender, obj/item/weapon, mob/living/attacker)
	if(HAS_TRAIT(attacker, TRAIT_NO_WEAPONTYPE))
		for(var/type in BANNEDTYPES)
			if(istype(weapon, type))
				if(attacker == defender)
					to_chat(attacker, "<span class='warning'>Remember, the path of Corporate Judo is strength through balance and increased market share—not the folly of striking yourself with crude implements.</span>")
				else
					defender.visible_message("<span class='warning'>[attacker] remembers their Sensei's words: &quot;There is a time and place for everything...&quot; WAIT, YOU DON'T HAVE A SENSEI!</span>", \
							"<span class='userdanger'>[attacker] freezes before striking, [attacker.p_their()] face giving off a pained expression!</span>")
				return TRUE
	return FALSE

/mob/living/attackby(obj/item/weapon, mob/living/user)
	if(ishuman(user))
		if(is_weapon_restricted(src, weapon, user))
			return
	..()

/mob/living/attackby_secondary(obj/item/weapon, mob/living/user)
	if(ishuman(user))
		if(is_weapon_restricted(src, weapon, user))
			return
	..()
///
// MARTIAL ART STYLE
///
/datum/martial_art/corpjudo
	name = "Corporate Judo"
	id = MARTIALART_JUDO
	display_combos = TRUE
	max_streak_length = 6
	combo_timer = 7 SECONDS

	var/blaststage = 0

/datum/martial_art/corpjudo/teach(mob/living/owner, make_temporary=FALSE)
	if(..())
		to_chat(owner, span_userdanger("You suddenly feel like you could negotiate with gravity itself... well at least your Boss."))

/datum/martial_art/corpjudo/on_remove(mob/living/owner)
	to_chat(owner, span_userdanger("As the belt leaves your waist, the secrets of Judo vanish like quarterly profits."))

///
// MARTIAL ART STYLE: EFFECTS
///
/datum/status_effect/judo_armbar // Used to proc Judo: WHEEL THROW
	id = "armbar"
	alert_type = /atom/movable/screen/alert/status_effect/judo_armbar
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/atom/movable/screen/alert/status_effect/judo_armbar
	name = "Armbar Pin"
	desc = "Your arm is pinned in an unyielding lock, leaving you unsteady and vulnerable!"
	icon_state = "debilitated"

///
// MARTIAL ART STYLE: ABILITIES
///
/datum/martial_art/corpjudo/proc/discombobulate(mob/living/carbon/human/attacker, mob/living/defender)
	defender.visible_message("<span class='warning'>[attacker] strikes [defender] in the head with [attacker.p_their()] palm!</span>", \
						"<span class='userdanger'>[attacker] strikes you with [attacker.p_their()] palm!</span>")
	playsound(get_turf(attacker), 'sound/weapons/slap.ogg', 40, TRUE, -1)
	defender.apply_damage(25, STAMINA)
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
	defender.apply_damage(62, STAMINA)
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
	defender.apply_damage(112, STAMINA)
	defender.apply_status_effect(/datum/status_effect/judo_armbar)
	defender.Knockdown(5 SECONDS)
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Armbar")
	return TRUE

/datum/martial_art/corpjudo/proc/wheel_throw/(mob/living/carbon/human/attacker, mob/living/defender)
	if((defender.body_position == STANDING_UP) || !defender.has_status_effect(/datum/status_effect/judo_armbar))
		return FALSE
	reset_streak() // Don't reset combo unless it met the first requirements.
	blaststage = 0
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
	log_combat(attacker, defender, "Melee attacked with martial-art [src] : Wheel Throw / Floor Pin")
	return TRUE

/datum/martial_art/corpjudo/proc/goldenblast(mob/living/carbon/human/attacker, mob/living/defender)
	if(!blaststage)
		return
	blaststage = 0
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
	return TRUE

///
// Combo Adders
///
/datum/martial_art/corpjudo/help_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	add_to_streak("E", defender)
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
	to_chat(world, "Do they have armbarpin:[defender.has_status_effect(/datum/status_effect/judo_armbar)], their current combot: [streak]")
	if(!can_use(attacker))
		return FALSE
	if(streak == WHEEL_THROW)
		//reset_streak()
		return wheel_throw(attacker, defender)
	if(streak == DISCOMBOBULATE)
		reset_streak()
		blaststage = 0
		return discombobulate(attacker, defender)
	if(streak == EYE_POKE)
		reset_streak()
		blaststage = 0
		return eye_poke(attacker, defender)
	if(streak == JUDO_THROW && !defender.has_status_effect(/datum/status_effect/judo_armbar))
		reset_streak()
		blaststage = 0
		return judothrow(attacker, defender)
	if(streak == ARMBAR)
		reset_streak()
		blaststage = 0
		return armbar(attacker, defender)
	if(streak == GOLDEN_BLAST1)
		reset_streak()
		blaststage = 1
		return TRUE
	if(streak == GOLDEN_BLAST2)
		reset_streak()
		return goldenblast(attacker, defender)
	return FALSE

#undef DISCOMBOBULATE
#undef EYE_POKE
#undef JUDO_THROW
#undef ARMBAR
#undef WHEEL_THROW
#undef GOLDEN_BLAST1
#undef GOLDEN_BLAST2
#undef BANNEDTYPES
