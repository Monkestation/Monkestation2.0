/datum/disease/acute/premade/fungal_tb
	name = "Tubercle Bacillus Cosmosis Microbes"
	form = "Fungal Spores"
	origin = "Active fungal spores"
	category = DISEASE_FUNGUS

	symptoms = list(
		new /datum/symptom/fungal_tb,
	)
	spread_flags = DISEASE_SPREAD_BLOOD|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_AIRBORNE
	robustness = 100
	strength = 100
	cures = list(/datum/reagent/medicine/antipathogenic/spaceacillin, /datum/reagent/medicine/c2/convermol)
	cure_chance = 5

	infectionchance = 75
	infectionchance_base = 75
	severity = DISEASE_SEVERITY_BIOHAZARD
	required_organ = ORGAN_SLOT_LUNGS
	bypasses_immunity = TRUE // TB primarily impacts the lungs; it's also bacterial or fungal in nature; viral immunity should do nothing.

/datum/disease/acute/premade/fungal_tb/after_add()
	. = ..()
	antigen = list(ANTIGEN_IG)
	stage = 4
