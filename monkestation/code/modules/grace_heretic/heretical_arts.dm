#define COMB1 "HH"
#define COMB2 "DH"
#define COMB3 "HD"
#define HEADKICK "GD"

/datum/martial_art/grace
	name = "Grace"
	id = MARTIALART_GRACE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/grace_help
	var/list/grace_traits = list(TRAIT_HARDLY_WOUNDED, TRAIT_PERFECT_ATTACKER, TRAIT_NOGUNS, TRAIT_THROW_GUNS)

	smashes_tables = TRUE //:3
	display_combos = TRUE

	block_chance = 50  //you can use throw mode to block melee attacks...

	//stuff for heretic growth

/datum/martial_art/grace/teach(mob/living/carbon/human/target, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	target.add_traits(grace_traits)
	target.set_armor(target.get_armor().add_other_armor(/datum/armor/scales))

/datum/martial_art/grace/on_remove(mob/living/carbon/human/target)
	target.set_armor(target.get_armor().subtract_other_armor(/datum/armor/scales))
	REMOVE_TRAITS_IN(target, grace_traits)
	. = ..()

/datum/martial_art/grace/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, COMB1))
		//reset_streak()
		comb1(attacker, defender)
		return TRUE
	if(findtext(streak, COMB2))
		//reset_streak()
		//faceScratch(attacker, defender)
		return TRUE
	if(findtext(streak, COMB3))
		//reset_streak()
		//jugularCut(attacker, defender)
		return TRUE
	if(findtext(streak, HEADKICK))
		reset_streak()
		headkick(attacker, defender)
		return TRUE
	return FALSE

/datum/martial_art/grace/proc/comb1(mob/living/attacker, mob/living/defender)

/datum/martial_art/grace/proc/comb2(mob/living/attacker, mob/living/defender)

/datum/martial_art/grace/proc/comb3(mob/living/attacker, mob/living/defender)

/datum/martial_art/grace/proc/headkick(mob/living/attacker, mob/living/defender)
	if(HAS_TRAIT(attacker, TRAIT_ELDRITCH_STRENGTH))
		defender.soundbang_act(5, 30, 5, 5)
		defender.apply_damage(15, BRUTE, BODY_ZONE_HEAD)
		defender.drop_all_held_items()

		attacker.spin(4, 1)
		attacker.Move(get_turf(defender), get_dir(get_turf(attacker), get_turf(defender)))

		playsound(defender, 'sound/effects/wounds/pierce2.ogg', 50)
		log_combat(attacker, defender, "strong headkicked (Grace Heretic)", name)

		defender.visible_message(
			span_warning("[attacker] kicks [defender] squarely in the face!"), \
			span_userdanger("[attacker] kicks you square in the head!"))

	else
		defender.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		defender.Knockdown(5)
		defender.drop_all_held_items()

		attacker.spin(4, 1)
		attacker.Move(get_turf(defender), get_dir(get_turf(attacker), get_turf(defender)))

		playsound(defender, 'sound/effects/wounds/pierce1.ogg', 50)
		log_combat(attacker, defender, "headkicked (Grace Heretic)", name)

		defender.visible_message(
			span_warning("[attacker] kicks [defender] squarely in the face!"), \
			span_userdanger("[attacker] kicks you square in the head!"))



/datum/martial_art/grace/harm_act(mob/living/attacker, mob/living/defender)
	var/critical_wound_type = /datum/wound/blunt/bone/critical
	var/datum/wound/blunt/bone/rib_smash = new critical_wound_type()
	var/obj/item/bodypart/chest = defender.get_bodypart(BODY_ZONE_CHEST)

	var/mark = defender.has_status_effect(/datum/status_effect/eldritch/grace)

	var/is_smashed = FALSE
	if(mark)
		if(LAZYLEN(chest?.wounds))
			var/datum/wound/blunt/bone/critical/ribs = locate() in chest.wounds
			if(ribs)
				is_smashed = TRUE

		if(is_smashed == FALSE)
			rib_smash.apply_wound(chest)
			defender.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
			defender.Paralyze(1 SECONDS)
			if(attacker.pulling == defender)
				attacker.stop_pulling()
		else
			var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
			defender.apply_damage(30, BRUTE, BODY_ZONE_CHEST)
			if(defender.losebreath <= 10)
				defender.losebreath = clamp(defender.losebreath + 2, 0, 10)
			defender.Knockdown(1 SECONDS)
			defender.Paralyze(2 SECONDS)
			defender.throw_at(throw_target, 2, 4, attacker)

		qdel(mark)
		log_combat(attacker, defender, "gut punched (Grace Heretic)", name)

	add_to_streak("H",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/grace/disarm_act(mob/living/attacker, mob/living/defender)
	var/mark = defender.has_status_effect(/datum/status_effect/eldritch/grace)

	if(mark)
		var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
		defender.Knockdown(2 SECONDS)
		defender.throw_at(throw_target, 5, 4, attacker)
		defender.adjust_dizzy(5 SECONDS)
		defender.adjust_temp_blindness(2 SECONDS)

		qdel(mark)
		log_combat(attacker, defender, "threw (Grace Heretic)", name)

	add_to_streak("D",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/grace/grab_act(mob/living/attacker, mob/living/defender)
	var/mark = defender.has_status_effect(/datum/status_effect/eldritch/grace)

	if(mark)
		defender.Paralyze(5 SECONDS)
		defender.Knockdown(5 SECONDS)
		attacker.buckle_mob(defender, TRUE, TRUE, CARRIER_NEEDS_ARM)

		qdel(mark)
		log_combat(attacker, defender, "snatched (Grace Heretic)", name)

	add_to_streak("G",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/grace/help_act(mob/living/attacker, mob/living/defender)
	var/mark = defender.has_status_effect(/datum/status_effect/eldritch/grace)

	if(mark && attacker != defender)
		defender.heal_overall_damage(30, 20, 80)
		defender.SetKnockdown(0)
		defender.apply_status_effect(/datum/status_effect/pacify/grace_honor)
		attacker.emote("handshake [defender]")
		if(attacker.pulling != defender)
			attacker.stop_pulling()
			defender.grabbedby(attacker, TRUE)
			attacker.setGrabState(GRAB_PASSIVE)

		defender.balloon_alert(defender, "healed")
		defender.balloon_alert(attacker, "power gifted")

		qdel(mark)
		log_combat(attacker, defender, "armstronged (Grace Heretic)", name)

	add_to_streak("E",defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/grace_help()
	set name = "Pierce the Veil"
	set desc = "Recall the Grail's power"
	set category = "Grail"

	to_chat(usr, "<b><i>You pierce the Veil of the Mansus to </i></b>")
	if(HAS_TRAIT(usr, TRAIT_ELDRITCH_STRENGTH))
		to_chat(usr, "the thingy works")

#undef COMB1
#undef COMB2
#undef COMB3
#undef HEADKICK
