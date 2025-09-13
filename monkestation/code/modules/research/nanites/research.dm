// See code\__DEFINES\research\techweb_nodes.dm
#define TECHWEB_NODE_NANITE_BASE "nanite_base"
#define TECHWEB_NODE_NANITE_SMART "nanite_smart"
#define TECHWEB_NODE_NANITE_MESH "nanite_mesh"
#define TECHWEB_NODE_NANITE_BIO "nanite_bio"
#define TECHWEB_NODE_NANITE_NEURAL "nanite_neural"
#define TECHWEB_NODE_NANITE_SYNAPTIC "nanite_synaptic"
#define TECHWEB_NODE_NANITE_HARMONIC "nanite_harmonic"
#define TECHWEB_NODE_NANITE_MILITARY "nanite_military"
#define TECHWEB_NODE_NANITE_HAZARD "nanite_hazard"
#define TECHWEB_NODE_NANITE_REPLICATION "nanite_replication_protocols"
#define TECHWEB_NODE_NANITE_STORAGE "nanite_storage_protocols"

/datum/techweb_node/nanite_base
	id = TECHWEB_NODE_NANITE_BASE
	starting_node = TRUE
	display_name = "Basic Nanite Programming"
	description = "The basics of nanite construction and programming."
	design_ids = list(
		"nanite_disk",
		"nanite_remote",
		"nanite_comm_remote",
		"nanite_scanner",
		"nanite_chamber",
		"nanite_chamber_control",
		"nanite_programmer",
		"nanite_program_hub",
		"nanite_cloud_control",
		"relay_nanites",
		"access_nanites",
		"repairing_nanites",
		"sensor_nanite_volume",
		"repeater_nanites",
		"relay_repeater_nanites",
		"red_diag_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS,
	)

/datum/techweb_node/nanite_smart
	id = TECHWEB_NODE_NANITE_SMART
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prereq_ids = list(TECHWEB_NODE_NANITE_BASE, TECHWEB_NODE_ROBOTICS)
	design_ids = list(
		"purging_nanites",
		"metabolic_nanites",
		"stealth_nanites",
		"memleak_nanites",
		"sensor_voice_nanites",
		"voice_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_1_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_mesh
	id = TECHWEB_NODE_NANITE_MESH
	display_name = "Mesh Nanite Programming"
	description = "Nanite programs that require static structures and membranes."
	prereq_ids = list(TECHWEB_NODE_NANITE_BASE, TECHWEB_NODE_PARTS_ADV)
	design_ids = list(
		"hardening_nanites",
		"dermal_button_nanites",
		"refractive_nanites",
		"cryo_nanites",
		"conductive_nanites",
		"shock_nanites",
		"emp_nanites",
		"temperature_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_1_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_bio
	id = TECHWEB_NODE_NANITE_BIO
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prereq_ids = list(TECHWEB_NODE_NANITE_BASE, TECHWEB_NODE_MEDBAY_EQUIP)
	design_ids = list(
		"regenerative_nanites",
		"bloodheal_nanites",
		"coagulating_nanites",
		"poison_nanites",
		"flesheating_nanites",
		"sensor_crit_nanites",
		"sensor_death_nanites",
		"sensor_health_nanites",
		"sensor_damage_nanites",
		"sensor_species_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_1_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_neural
	id = TECHWEB_NODE_NANITE_NEURAL
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prereq_ids = list(TECHWEB_NODE_NANITE_BIO)
	design_ids = list(
		"nervous_nanites",
		"brainheal_nanites",
		"paralyzing_nanites",
		"stun_nanites",
		"selfscan_nanites",
		"good_mood_nanites",
		"bad_mood_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_2_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_synaptic
	id = TECHWEB_NODE_NANITE_SYNAPTIC
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prereq_ids = list(TECHWEB_NODE_NANITE_NEURAL, TECHWEB_NODE_PASSIVE_IMPLANTS)
	design_ids = list(
		"mindshield_nanites",
		"pacifying_nanites",
		"blinding_nanites",
		"sleep_nanites",
		"mute_nanites",
		"speech_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_2_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_harmonic
	id = TECHWEB_NODE_NANITE_HARMONIC
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology."
	prereq_ids = list(TECHWEB_NODE_NANITE_BIO, TECHWEB_NODE_NANITE_SMART, TECHWEB_NODE_NANITE_MESH)
	design_ids = list(
		"fakedeath_nanites",
		"aggressive_nanites",
		"defib_nanites",
		"regenerative_plus_nanites",
		"brainheal_plus_nanites",
		"purging_plus_nanites",
		"adrenaline_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_4_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_combat
	id = TECHWEB_NODE_NANITE_MILITARY
	display_name = "Military Nanite Programming"
	description = "Nanite programs that perform military-grade functions."
	prereq_ids = list(TECHWEB_NODE_NANITE_HARMONIC, TECHWEB_NODE_SYNDICATE_BASIC)
	design_ids = list(
		"explosive_nanites",
		"pyro_nanites",
		"meltdown_nanites",
		"viral_nanites",
		"nanite_sting_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_hazard
	id = TECHWEB_NODE_NANITE_HAZARD
	display_name = "Hazard Nanite Programs"
	description = "Extremely advanced Nanite programs with the potential of being extremely dangerous."
	prereq_ids = list(TECHWEB_NODE_NANITE_HARMONIC, TECHWEB_NODE_ALIENTECH)
	design_ids = list(
		"spreading_nanites",
		"mindcontrol_nanites",
		"mitosis_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_5_POINTS*NANITE_POINT_CONVERSION_RATE,
	)

/datum/techweb_node/nanite_replication_protocols
	id = TECHWEB_NODE_NANITE_REPLICATION
	display_name = "Nanite Replication Protocols"
	description = "Advanced behaviours that allow nanites to exploit certain circumstances to replicate faster."
	prereq_ids = list(TECHWEB_NODE_NANITE_SMART)
	design_ids = list(
		"kickstart_nanites",
		"factory_nanites",
		"tinker_nanites",
		"offline_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS*NANITE_POINT_CONVERSION_RATE,
	)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/nanite_storage_protocols
	id = TECHWEB_NODE_NANITE_STORAGE
	display_name = "Nanite Storage Protocols"
	description = "Protocols that overwrite the default nanite storage routine to achieve more efficiency or greater capacity."
	prereq_ids = list(TECHWEB_NODE_NANITE_SMART)
	design_ids = list(
		"free_range_nanites",
		"hive_nanites",
		"unsafe_storage_nanites",
		"zip_nanites",
	)
	research_costs = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS,
		TECHWEB_POINT_TYPE_NANITES = TECHWEB_TIER_3_POINTS*NANITE_POINT_CONVERSION_RATE,
	)
	hidden = TRUE
	experimental = TRUE
