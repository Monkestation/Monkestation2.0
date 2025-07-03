
/mob/living/silicon/grippedby(mob/living/user, instant = FALSE)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection()//no ears
	return 2

/mob/living/silicon/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	if(..()) //if harm or disarm intent
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		if (prob(90))
			log_combat(user, src, "attacked")
			playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user] slashes at [src]!"), \
							span_userdanger("[user] slashes at you!"), null, null, user)
			to_chat(user, span_danger("You slash at [src]!"))
			if(prob(8))
				flash_act(affect_silicon = 1)
			log_combat(user, src, "attacked")
			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE, -1)
			visible_message(span_danger("[user]'s swipe misses [src]!"), \
							span_danger("You avoid [user]'s swipe!"), null, null, user)
			to_chat(user, span_warning("Your swipe misses [src]!"))

/mob/living/silicon/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	if(.)
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		if(prob(damage))
			for(var/mob/living/buckled in buckled_mobs)
				buckled.Paralyze(20)
				unbuckle_mob(buckled)
				buckled.visible_message(span_danger("[buckled] is knocked off of [src] by [user]!"), \
								span_userdanger("You're knocked off of [src] by [user]!"), null, null, user)
				to_chat(user, span_danger("You knock [buckled] off of [src]!"))
		switch(user.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)

/mob/living/silicon/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(!(L.istate & ISTATE_HARM))
		visible_message(span_notice("[L.name] rubs its head against [src]."))

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(rand(10, 15))
	playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	visible_message(span_danger("[user] punches [src]!"), \
					span_userdanger("[user] punches you!"), null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You punch [src]!"))

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	if(has_buckled_mobs() && !(user.istate & ISTATE_HARM))
		user_unbuckle_mob(buckled_mobs[1], user)
	else
		if((user.istate & ISTATE_HARM))
			if(!try_punch_borg(user))
				user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
				playsound(src.loc, 'sound/effects/bang.ogg', 10, TRUE)
				visible_message(span_danger("[user] punches [src], but doesn't leave a dent!"), \
								span_warning("[user] punches you, but doesn't leave a dent!"), null, COMBAT_MESSAGE_RANGE, user)
				to_chat(user, span_danger("You punch [src], but don't leave a dent!"))
		else
			visible_message(span_notice("[user] pets [src]."), \
							span_notice("[user] pets you."), null, null, user)
			to_chat(user, span_notice("You pet [src]."))
			user.add_mood_event("pet_borg", /datum/mood_event/pet_borg)

/mob/living/silicon/proc/try_punch_borg(mob/living/carbon/human/attacker)
	if(HAS_TRAIT(attacker, TRAIT_FEEBLE))
		return FALSE

	var/obj/item/bodypart/attacking_bodypart = astype(attacker.get_organ_slot(ORGAN_SLOT_BRAIN), /obj/item/organ/internal/brain)?.get_attacking_limb(src) || attacker.get_active_hand()
	if(!attacking_bodypart)
		return FALSE

	// You either need a robotic arm (metal can punch metal), able to deal enough damage to knockdown, or have the TRAIT_BORG_PUNCHER trait on yourself or the attacking limb.
	if((attacking_bodypart.unarmed_damage_high < attacking_bodypart.unarmed_stun_threshold) && !(attacking_bodypart.bodytype & BODYTYPE_ROBOTIC) && !HAS_TRAIT(attacking_bodypart, TRAIT_BORG_PUNCHER) && !HAS_TRAIT(attacker, TRAIT_BORG_PUNCHER))
		return FALSE

	. = TRUE

	var/atk_verb = attacking_bodypart.unarmed_attack_verb
	var/atk_effect = attacking_bodypart.unarmed_attack_effect

	if(atk_effect == ATTACK_EFFECT_BITE && attacker.is_mouth_covered(ITEM_SLOT_MASK))
		to_chat(attacker, span_warning("You can't [atk_verb] with your mouth covered!"))
		return FALSE
	attacker.do_attack_animation(src, atk_effect)

	var/damage = rand(attacking_bodypart.unarmed_damage_low, attacking_bodypart.unarmed_damage_high)
	var/armor_block = run_armor_check(attack_flag = MELEE)

	playsound(src, 'monkestation/sound/weapons/bat_hit.ogg', 15, TRUE)
	visible_message(
		span_danger("[attacker] [atk_verb]ed [src]!"),
		span_userdanger("You're [atk_verb]ed by [attacker]!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = attacker,
	)
	to_chat(attacker, span_danger("You [atk_verb] [src]!"), type = MESSAGE_TYPE_COMBAT)

	lastattacker = attacker.real_name
	lastattackerckey = attacker.ckey

	var/attack_direction = get_dir(attacker, src)

	var/log_what = "punched"
	if(atk_effect == ATTACK_EFFECT_KICK) //kicks deal 1.5x raw damage
		log_what = "kicked"
		damage *= 1.5
	apply_damage(damage, attacking_bodypart.attack_type, blocked = armor_block, attack_direction = attack_direction)
	log_combat(attacker, src, log_what)

/mob/living/silicon/attack_drone(mob/living/basic/drone/user)
	if((user.istate & ISTATE_HARM))
		return
	return ..()

/mob/living/silicon/attack_drone_secondary(mob/living/basic/drone/user)
	if((user.istate & ISTATE_HARM))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/silicon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	if(buckled_mobs)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.electrocute_act(shock_damage/100, source, siemens_coeff, flags) //Hard metal shell conducts!
	return 0 //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	. = ..()
	to_chat(src, span_danger("Warning: Electromagnetic pulse detected."))
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			src.take_bodypart_damage(20)
		if(2)
			src.take_bodypart_damage(10)
	to_chat(src, span_userdanger("*BZZZT*"))
	for(var/mob/living/M in buckled_mobs)
		if(prob(severity*50))
			unbuckle_mob(M)
			M.Paralyze(40)
			M.visible_message(span_boldwarning("[M] is thrown off of [src]!"))
	flash_act(affect_silicon = 1)

/mob/living/silicon/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	. = ..()
	if(. != BULLET_ACT_HIT)
		return .

	var/prob_of_knocking_dudes_off = 0
	if(hitting_projectile.damage_type == BRUTE || hitting_projectile.damage_type == BURN)
		prob_of_knocking_dudes_off = hitting_projectile.damage * 1.5
	if(hitting_projectile.stun || hitting_projectile.knockdown || hitting_projectile.paralyze)
		prob_of_knocking_dudes_off = 100

	if(prob(prob_of_knocking_dudes_off))
		for(var/mob/living/buckled in buckled_mobs)
			buckled.visible_message(span_boldwarning("[buckled] is knocked off of [src] by [hitting_projectile]!"))
			unbuckle_mob(buckled)
			buckled.Paralyze(4 SECONDS)

/mob/living/silicon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/static, length = 25)
	if(affect_silicon)
		return ..()
