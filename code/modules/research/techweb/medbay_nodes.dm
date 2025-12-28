/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick." //the MC, silly!
	prereq_ids = list("basic_medical")
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	discount_experiments = list(/datum/experiment/autopsy/human = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list(
		"autopsyscanner",
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
		"surgical_gloves",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/material/meat = TECHWEB_DISCOUNT_MINOR * 3,
								/datum/experiment/autopsy/nonhuman = TECHWEB_DISCOUNT_MINOR * 3)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_vitals_monitoring
	id = "adv_vitals_monitoring"
	display_name = "Advanced Vitals Monitoring"
	description = "Various experimental handheld crew monitors allowing remote connection to nearby5 suit sensors without a console."
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"sensor_device",
		"sensor_device_security",
		"sensor_device_command",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_COMMAND)

/datum/techweb_node/xenoorgan_biotech
	id = "xenoorgan_bio"
	display_name = "Xeno-organ Biology"
	description = "Plasmaman, Ethereals, Lizardpeople... What makes our non-human crewmembers tick?"
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"limbdesign_ethereal",
		"limbdesign_lizard",
		"limbdesign_plasmaman",
		"limbdesign_other",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(
		/datum/experiment/scanning/random/cytology/easy = TECHWEB_DISCOUNT_MINOR * 3,
		/datum/experiment/scanning/points/slime/hard = TECHWEB_TIER_2_POINTS,
		/datum/experiment/autopsy/xenomorph = TECHWEB_TIER_2_POINTS,
	)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)
