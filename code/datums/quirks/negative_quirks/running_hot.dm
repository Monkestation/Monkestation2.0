/datum/quirk/runninghot
	name = "Running Hot"
	desc = "Your body temperature raises abnormally when you exert yourself, often to dangerous levels."
	icon = FA_ICON_GAUGE_HIGH
	value = -4
	mob_trait = TRAIT_EXERTION_OVERHEAT
	gain_text = span_danger("You feel uncomfortably warm.")
	lose_text = span_notice("You feel cool.")
	medical_record_text = "Patient exibits generalized anhydrosis and is physiologically incapable of sweating." //this is actually a real thing that exists
	hardcore_value = 4
	quirk_flags = QUIRK_HUMAN_ONLY
