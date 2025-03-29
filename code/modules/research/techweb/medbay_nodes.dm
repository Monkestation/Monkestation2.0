/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick." //the MC, silly!
	prereq_ids = list("base")
	design_ids = list(
		"beer_dispenser",
		"blood_pack",
		"chem_dispenser",
		"chem_heater",
		"chem_mass_spec",
		"chem_master",
		"chem_pack",
		"defibmount",
		"defibrillator",
		"genescanner",
		"healthanalyzer",
		"scanning_pad",
		"vitals_monitor",
		"antibodyscanner",
		"med_spray_bottle",
		"medical_kiosk",
		"medigel",
		"medipen_refiller",
		"soda_dispenser",
		"extrapolator",
		"diseasesplicer",
		"incubator",
		"diseaseanalyzer",
		"centrifuge",
		"path_data",
		"heat_pack",
		"cold_pack",
		"medical_crutch",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	discount_experiments = list(/datum/experiment/dissection/human = 1000)

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list(
		"crewpinpointer",
		"vitals_monitor_advanced",
		"defibrillator_compact",
		"harvester",
		"healthanalyzer_advanced",
		"holobarrier_med",
		"limbgrower",
		"meta_beaker",
		"ph_meter",
		"medicalbed_emergency",
		"piercesyringe",
		"plasmarefiller",
		"smoke_machine",
		"sleeper",
		"surgical_gloves", //Monkestation Addition
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(/datum/experiment/scanning/random/material/meat = 2000,
								/datum/experiment/dissection/nonhuman = 2000)

/datum/techweb_node/xenoorgan_biotech
	id = "xenoorgan_bio"
	display_name = "Xeno-organ Biology"
	description = "Plasmaman, Ethereals, Lizardpeople... What makes our non-human crewmembers tick?"
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"limbdesign_ethereal",
		"limbdesign_lizard",
		"limbdesign_plasmaman",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 6500)
	discount_experiments = list(
		/datum/experiment/scanning/random/cytology/easy = 1000,
		/datum/experiment/scanning/points/slime/hard = 5000,
		/datum/experiment/dissection/xenomorph = 5000,
	)

/datum/techweb_node/cryotech
	id = "cryotech"
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list(
		"cryo_grenade",
		"cryotube",
		"splitbeaker",
		"stasis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
