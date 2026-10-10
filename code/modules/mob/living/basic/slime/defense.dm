/// How long a slime that got forced off its meal has to wait before it can latch again
#define SLIME_LATCH_COOLDOWN (10 SECONDS)
/// Chance per try to wrestle a slime off yourself
#define SLIME_WRESTLE_SELF_CHANCE 50
/// Chance per try to wrestle a slime off somebody else
#define SLIME_WRESTLE_HELPER_CHANCE 80

/mob/living/basic/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	adjust_power_level(-SLIME_MAX_POWER) // oh no, the power!

///If a slime is attack with an empty hand, shoves included, try to wrestle them off the mob they are on
/mob/living/basic/slime/proc/on_attack_hand(mob/living/basic/slime/defender_slime, mob/living/attacker)
	SIGNAL_HANDLER

	if(!isliving(buckled)) // a slime on a chair has nobody to be wrestled off
		return

	if(!(attacker.istate & ISTATE_HARM) && (attacker in ai_controller?.blackboard[BB_FRIENDS_LIST]))
		apologize_to(buckled, attacker)
		return COMPONENT_CANCEL_ATTACK_CHAIN // otherwise we'll like... either pet or shove the slime right after.

	if(!prob(buckled == attacker ? SLIME_WRESTLE_SELF_CHANCE : SLIME_WRESTLE_HELPER_CHANCE)) // a helper has both hands free and isn't being eaten
		attacker.visible_message(span_warning("[attacker] attempts to wrestle \the [defender_slime.name] off [buckled == attacker ? "" : buckled] !"), \
		span_danger("[buckled == attacker ? "You attempt" : "[attacker] attempts" ] to wrestle \the [defender_slime.name] off [buckled == attacker ? "" : buckled]!"))
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		return

	attacker.visible_message(span_warning("[attacker] manages to wrestle \the [defender_slime.name] off!"), span_notice("You manage to wrestle \the [defender_slime.name] off!"))
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

	defender_slime.discipline_slime()

/mob/living/basic/slime/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	// plasma feeding jumps the queue, ahead of the passthrough roll, so it always lands
	if(istype(tool, /obj/item/stack/sheet/mineral/plasma) && stat == CONSCIOUS)
		use_sheet(tool, user)
		return ITEM_INTERACT_SUCCESS

	if(check_item_passthrough(tool, user))
		return ITEM_INTERACT_SUCCESS

	try_discipline_slime(tool)

	if(!istype(tool, /obj/item/storage/bag/xeno))
		return ..()

	use_xeno_bag(tool, user)
	return ITEM_INTERACT_SUCCESS

///Checks if an item harmlessly passes through the slime
/mob/living/basic/slime/proc/check_item_passthrough(obj/item/attacking_item, mob/living/user)
	if(attacking_item.force <= 0)
		return FALSE

	if(!prob(25))
		return FALSE

	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, span_danger("[attacking_item] passes right through [src]!"))
	return TRUE

///Attempts to use the item to discipline the unruly slime
/mob/living/basic/slime/proc/try_discipline_slime(obj/item/attacking_item)
	if(attacking_item.force < 3)
		return

	var/force_effect = attacking_item.force * (life_stage == SLIME_LIFE_STAGE_BABY ? 2 : 1)
	if(prob(10 + force_effect))
		discipline_slime()

///Handles feeding a sheet of plasma to a slime
/mob/living/basic/slime/proc/use_sheet(obj/item/stack/sheet/mineral/plasma/delicious_sheet, mob/living/user)
	// the orange path wants plasma too, and a plasma sheet is a plasma sheet however it got here
	var/wanted = SEND_SIGNAL(src, COMSIG_SLIME_CHECK_WANTED_ITEM, delicious_sheet) & COMPONENT_SLIME_WANTS_ITEM
	befriend(user)
	to_chat(user, span_notice("You feed the slime the plasma. It chirps happily."))
	delicious_sheet.use(1)
	new /obj/effect/temp_visual/heart(loc)
	if(!wanted)
		return
	SEND_SIGNAL(src, COMSIG_SLIME_ATE_ITEM, /obj/item/stack/sheet/mineral/plasma)
	refresh_wanted_targets()
	if(life_stage == SLIME_LIFE_STAGE_ADULT)
		try_ranch_outcome()

///Handles feeding a slim with a bag full of extracts
/mob/living/basic/slime/proc/use_xeno_bag(obj/item/storage/bag/xeno/xeno_bag, mob/living/user)
	if(!crossbreed_modification)
		to_chat(user, span_warning("The slime is not currently being mutated."))
		return
	var/has_output = FALSE
	var/has_found = FALSE
	for(var/obj/item/slime_extract/extract in xeno_bag.contents)
		if(extract.effectmod == crossbreed_modification)
			xeno_bag.atom_storage.attempt_remove(extract, get_turf(src), silent = TRUE)
			qdel(extract)
			applied_crossbreed_amount++
			has_found = TRUE
		if(applied_crossbreed_amount >= SLIME_EXTRACT_CROSSING_REQUIRED)
			to_chat(user, span_notice("You feed the slime as many of the extracts from the bag as you can, and it mutates!"))
			playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
			spawn_corecross()
			has_output = TRUE
			break

	if(has_output)
		return

	if(!has_found)
		to_chat(user, span_warning("There are no extracts in the bag that this slime will accept!"))
	else
		to_chat(user, span_notice("You feed the slime some extracts from the bag."))
		playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)

///Handles the adverse effects of water on slimes
/mob/living/basic/slime/proc/apply_water()
	adjustBruteLoss(rand(15,20))
	discipline_slime()

///Stops the slime from feeding, and might remove rabidity and targets
/mob/living/basic/slime/proc/discipline_slime()
	var/mob/living/victim = buckled
	if(isliving(victim))
		COOLDOWN_START(src, latch_cooldown, SLIME_LATCH_COOLDOWN)
		// a grudge skips can_feed_on(), so without this we'd just bite whoever we were eating instead of backing off
		var/datum/ai_controller/basic_controller/slime/controller = ai_controller
		if(controller)
			controller.ignore_target(victim, SLIME_LATCH_COOLDOWN)
			for(var/target_key in list(BB_SLIME_EAT_TARGET, BB_BASIC_MOB_CURRENT_TARGET))
				if(controller.blackboard[target_key] == victim)
					controller.clear_blackboard_key(target_key)
	stop_feeding(silent = TRUE)
	if(life_stage == SLIME_LIFE_STAGE_BABY && prob(80))
		ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		ai_controller?.clear_blackboard_key(BB_SLIME_EAT_TARGET)

	if(prob(10))
		ai_controller?.set_blackboard_key(BB_SLIME_RABID, FALSE)
	set_temporary_mood(SLIME_MOOD_POUT)

#undef SLIME_LATCH_COOLDOWN
#undef SLIME_WRESTLE_SELF_CHANCE
#undef SLIME_WRESTLE_HELPER_CHANCE
