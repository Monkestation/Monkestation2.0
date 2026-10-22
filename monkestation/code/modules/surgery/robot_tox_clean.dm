/datum/surgery/robot_tox_clean
	name = "Clear Corrosive Buildup (Repair Toxins)"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	surgery_flags = SURGERY_REQUIRE_LIMB
	possible_locs = list(BODY_ZONE_CHEST)
	desc = "A procedure that removes corrosion and chemical buildup on mechanical components inside of a deactivated synthetic chassis."
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/clean_corrosion,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/robot_tox_clean/can_start(mob/user, mob/living/carbon/target)
	if((target.has_dna()?.species?.reagent_tag & PROCESS_SYNTHETIC) && target.stat == DEAD && (target.getToxLoss() > 0)) // This surgery is only available if you can't process most Toxin-clearing chems and you're not alive to process system cleaner.
		return TRUE
	return FALSE

/datum/surgery_step/clean_corrosion
	name = "Remove corrosion (Soap/Crowbar/Scalpel)"
	repeatable = FALSE
	implements = list(
		/obj/item/soap = 100,
		TOOL_CROWBAR = 75,
		TOOL_SCALPEL = 50,
		)
	time = 50
	preop_sound = 'sound/items/unsheath.ogg'
	success_sound = 'sound/items/unsheath.ogg'

/datum/surgery_step/clean_corrosion/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to clear the corrosion inside of [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to clear the corrosion inside of [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to clear the corrosion inside of [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "You feel an unpleasant scraping in your [parse_zone(target_zone)] as the corrosion is removed.", TRUE)

/datum/surgery_step/clean_corrosion/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	target.setToxLoss(0, TRUE, TRUE)
	display_results(
		user,
		target,
		span_notice("You clear the corrosion off of [target]'s [parse_zone(target_zone)] components."),
		span_notice("[user] clear the corrosion off of [target]'s [parse_zone(target_zone)] components."),
		span_notice("[user] clear the corrosion off of [target]'s [parse_zone(target_zone)] components."),
	)
	return TRUE
