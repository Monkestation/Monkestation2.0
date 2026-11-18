/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with
 */
/datum/element/basic_eating
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Amount to heal
	var/heal_amt
	/// Amount to hurt
	var/damage_amount
	/// Type of hurt to apply
	var/damage_type
	/// Whether to flavor it as drinking rather than eating.
	var/drinking
	/// If true, we put food in our tummy instead of deleting it
	var/add_to_contents
	/// Types the animal can eat.
	var/list/food_types

/datum/element/basic_eating/Attach(datum/target, heal_amt = 0, damage_amount = 0, damage_type = null, drinking = FALSE, add_to_contents = FALSE, food_types = list())
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.heal_amt = heal_amt
	src.damage_amount = damage_amount
	src.damage_type = damage_type
	src.drinking = drinking
	src.add_to_contents = add_to_contents
	src.food_types = food_types

	//this lets players eat
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack))
	//this lets ai eat. yes, i'm serious
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attackingtarget))

/datum/element/basic_eating/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/element/basic_eating/proc/on_unarm_attack(mob/living/eater, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(try_eating(eater, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/datum/element/basic_eating/proc/on_pre_attackingtarget(mob/living/eater, atom/target)
	SIGNAL_HANDLER
	try_eating(eater, target)

/datum/element/basic_eating/proc/try_eating(mob/living/eater, atom/target, mob/living/feeder)
	if(!is_type_in_list(target, food_types))
		return FALSE
	if(SEND_SIGNAL(eater, COMSIG_MOB_PRE_EAT, target, feeder) & COMSIG_MOB_CANCEL_EAT)
		return FALSE
	if(add_to_contents && !ismovable(target))
		return FALSE

	var/eat_verb
	if(drinking)
		eat_verb = pick("slurp","sip","guzzle","drink","quaff","suck")
	else
		eat_verb = pick("bite","chew","nibble","gnaw","gobble","chomp")

	if(heal_amt > 0)
		var/healed = heal_amt && eater.health < eater.maxHealth
		if(heal_amt)
			eater.heal_overall_damage(heal_amt)
		eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target][healed ? ", restoring some health" : ""]."))
		finish_eating(eater, target, feeder)
		return TRUE

	if(damage_amount > 0 && damage_type)
		eater.apply_damage(damage_amount, damage_type)
		eater.visible_message(span_notice("[eater] [eat_verb]s [target], and seems to hurt itself."), span_notice("You [eat_verb] [target], hurting yourself in the process."))
		finish_eating(eater, target, feeder)
		return TRUE

	eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target]."))
	finish_eating(eater, target, feeder)
	return TRUE

/datum/element/basic_eating/proc/finish_eating(mob/living/eater, atom/target, mob/living/feeder)
	if(drinking)
		////playsound(eater.loc,'sound/items/drink.ogg', rand(10,50), TRUE) // monkestation edit original
		playsound(eater.loc,get_drink_sound(eater), rand(10,50), TRUE) // monkestation edit: synthesized drink sounds
	else
		playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)

	SEND_SIGNAL(eater, COMSIG_LIVING_ATE, target)
	SEND_SIGNAL(eater, COMSIG_EMOTION_STORE, null, EMOTION_HAPPY, "I ate [target], I really like [target].")
	if(SEND_SIGNAL(eater, COMSIG_MOB_ATE, target, feeder) & COMSIG_MOB_TERMINATE_EAT)
		return

	var/atom/final_target = target
	if(isstack(target)) //if stack, only consume 1
		var/obj/item/stack/food_stack = target
		if(!add_to_contents)
			food_stack.use(1)
			return
		// monkestation edit: our split_stack can sleep, so make the bite by hand
		final_target = new food_stack.type(eater, 1, FALSE, food_stack.mats_per_unit)
		food_stack.use(1)

	eater.log_message("has eaten [target], [add_to_contents ? "swallowing it" : "destroying it"]!", LOG_ATTACK)

	if(add_to_contents)
		var/atom/movable/movable_target = final_target
		movable_target.forceMove(eater)
	else
		qdel(final_target)

/proc/get_drink_sound(mob/living/drinker, force_enhanced = FALSE)
	. = 'sound/items/drink.ogg'
	if(force_enhanced || (isipc(drinker) || issilicon(drinker)) && (roll(15) >= 15))
		to_chat(drinker, span_notice("Your circuits are rushed with enhanced flavor!"))
		. = 'sound/items/drink_sparkle.ogg'
