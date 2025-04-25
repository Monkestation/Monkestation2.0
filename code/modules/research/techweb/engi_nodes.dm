/datum/techweb_node/engineering
	id = "engineering"
	display_name = "Industrial Engineering"
	description = "A refresher course on modern engineering technology."
	prereq_ids = list("base")
	design_ids = list(
		"adv_capacitor",
		"adv_matter_bin",
		"adv_scanning",
		"airlock_board_offstation", //MONKESTATION ADDITION - old airlock board for charlie station
		"airalarm_electronics",
		"airlock_board",
		"anomaly_refinery",
		"apc_control",
		"atmos_control",
		"atmos_thermal",
		"atmosalerts",
		"autolathe",
		"cell_charger",
		"crystallizer",
		"electrolyzer",
		"emergency_oxygen_engi",
		"emergency_oxygen",
		"emitter",
		"firealarm_electronics",
		"firelock_board",
		"generic_tank",
		"grounding_rod",
		"high_cell",
		"high_micro_laser",
		"mesons",
		"nano_mani",
		"oxygen_tank",
		"pacman",
		"plasma_tank",
		"plasmaman_tank_belt",
		"pneumatic_seal",
		"power_control",
		"powermonitor",
		"rad_collector",
		"recharger",
		"recycler",
		"rped",
		"scanner_gate",
		"solarcontrol",
		"stack_console",
		"stack_machine",
		"suit_storage_unit",
		"tank_compressor",
		"tesla_coil",
		"thermomachine",
		"w-recycler",
		"welding_goggles",
		"teg",
		"teg-circ",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/material/easy = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/adv_engi
	id = "adv_engi"
	display_name = "Advanced Engineering"
	description = "Pushing the boundaries of physics, one chainsaw-fist at a time."
	prereq_ids = list("engineering", "emp_basic")
	design_ids = list(
		"HFR_core",
		"HFR_corner",
		"HFR_fuel_input",
		"HFR_interface",
		"HFR_moderator_input",
		"HFR_waste_output",
		"engine_goggles",
		"forcefield_projector",
		"magboots",
		"rcd_loaded",
		"rcd_ammo",
		"rpd_loaded",
		"rtd_loaded",
		"sheetifier",
		"weldingmask",
		"bolter_wrench",
		"multi_cell_charger", //Monkestation addition
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_6_POINTS)
	discount_experiments = list(
		/datum/experiment/scanning/random/material/medium/one = TECHWEB_TIER_2_POINTS,
		/datum/experiment/ordnance/gaseous/bz = TECHWEB_TIER_4_POINTS,
	)

/datum/techweb_node/telecomms
	id = "telecomms"
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list("comptech", "bluespace_basic")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	design_ids = list(
		"comm_monitor",
		"comm_server",
		"ntnet_relay",
		"s_amplifier",
		"s_analyzer",
		"s_ansible",
		"s_broadcaster",
		"s_bus",
		"s_crystal",
		"s_filter",
		"s_hub",
		"s_messaging",
		"s_processor",
		"s_receiver",
		"s_relay",
		"s_server",
		"s_transmitter",
		"s_treatment",
		"s_traffic", // MONKESTATION ADDITION -- NTSL -- The board to actually program in NTSL
	)

/datum/techweb_node/emp_basic //EMP tech for some reason
	id = "emp_basic"
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list("base")
	design_ids = list(
		"holosign",
		"holosignsec",
		"holosignengi",
		"holosignatmos",
		"holosignrestaurant",
		"holosignbar",
		"inducer",
		"tray_goggles",
		"holopad",
		"vendatray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/emp_adv
	id = "emp_adv"
	display_name = "Advanced Electromagnetic Theory"
	description = "Determining whether reversing the polarity will actually help in a given situation."
	prereq_ids = list("emp_basic")
	design_ids = list(
		"ultra_micro_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_microlaser = TECHWEB_DISCOUNT_MINOR * 2.5)

/datum/techweb_node/emp_super
	id = "emp_super"
	display_name = "Quantum Electromagnetic Technology" //bs
	description = "Even better electromagnetic technology."
	prereq_ids = list("emp_adv")
	design_ids = list(
		"quadultra_micro_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_6_POINTS)
	discount_experiments = list(
		/datum/experiment/scanning/points/machinery_pinpoint_scan/tier3_microlaser = TECHWEB_TIER_2_POINTS,
		/datum/experiment/ordnance/gaseous/noblium = TECHWEB_TIER_4_POINTS,
	)

/datum/techweb_node/high_efficiency
	id = "high_efficiency"
	display_name = "High Efficiency Parts"
	description = "Finely-tooled manufacturing techniques allowing for picometer-perfect precision levels."
	prereq_ids = list("engineering", "datatheory")
	design_ids = list(
		"pico_mani",
		"super_matter_bin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier2_lathes = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/adv_power
	id = "adv_power"
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prereq_ids = list("engineering")
	design_ids = list(
		"hyper_cell",
		"power_turbine_console",
		"smes",
		"super_capacitor",
		"super_cell",
		"turbine_compressor",
		"turbine_rotor",
		"turbine_stator",
		"modular_shield_generator",
		"modular_shield_node",
		"modular_shield_relay",
		"modular_shield_charger",
		"modular_shield_well",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_capacitors = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/integrated_hud
	id = "integrated_HUDs"
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prereq_ids = list("comp_recordkeeping", "emp_basic")
	design_ids = list(
		"diagnostic_hud",
		"health_hud",
		"scigoggles",
		"pathology_goggles", // monkestation addition
		"security_hud",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/nvg_tech
	id = "NVGtech"
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list("integrated_HUDs", "adv_engi", "emp_adv")
	design_ids = list(
		"diagnostic_hud_night",
		"health_hud_night",
		"night_visision_goggles",
		"nvgmesons",
		"nv_scigoggles",
		"nv_pathology_goggles", // monkestation addition
		"security_hud_night",
		"mech_light_amplification",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
