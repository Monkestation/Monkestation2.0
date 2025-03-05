/datum/surgery/organ_extraction
	name = "Experimental organ replacement"
	possible_locs = list(BODY_ZONE_CHEST)
	surgery_flags = SURGERY_SELF_OPERABLE | SURGERY_IGNORE_CLOTHES | SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB
	steps = list(
		/datum/surgery_step/incise/nobleed,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/extract_organ,
		/datum/surgery_step/gland_insert,
	)
