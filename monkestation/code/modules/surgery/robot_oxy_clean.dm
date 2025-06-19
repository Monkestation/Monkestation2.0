/datum/surgery/robot_oxy_clean  // HI BILLY MAYS HERE WITH...
	name = "Clean Components of Debris (Repair Suffocation)"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	surgery_flags = SURGERY_REQUIRE_LIMB
	possible_locs = list(BODY_ZONE_CHEST)
	desc = "A procedure that clears the debris from ventilation and temperature regulation systems in a deactivated mechanical chassis."
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/clear_debris,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/robot_oxy_clean/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_NOBREATH) && (target.stat == DEAD) && (target.getOxyLoss() > 0)) // Have you somehow accumulated OxyDamage while being TRAIT_NOBREATH and are dead with it? Boy do I have a deal for you!
		return TRUE
	return FALSE

/datum/surgery_step/clear_debris
	name = "Clear debris from components (hand)"
	accept_hand = TRUE
	repeatable = FALSE
	time = 50

/datum/surgery_step/clear_debris/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to clear the dust and debris inside of [target]'s [parse_zone(target_zone)] components..."),
		span_notice("[user] begins to clear the dust and debris inside of [target]'s [parse_zone(target_zone)] components."),
		span_notice("[user] begins to clear the dust and debris inside of [target]'s [parse_zone(target_zone)] components."),
	)
	display_pain(target, "You feel someone reaching around inside of your [parse_zone(target_zone)] as debris is removed from your components.", TRUE)

/datum/surgery_step/clear_debris/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	target.setOxyLoss(0, TRUE, TRUE) // Bam! Just like that!
	display_results(
		user,
		target,
		span_notice("You clear debris out of [target]'s [parse_zone(target_zone)] components."),
		span_notice("[user] clear the debris out of [target]'s [parse_zone(target_zone)] components."),
		span_notice("[user] clear the debris out of [target]'s [parse_zone(target_zone)] components."),
	)
	return TRUE
