/datum/techweb_node/robotics
	id = "robotics"
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list(
		"paicard",
		"mecha_camera",
		"botnavbeacon",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_robotics
	id = "adv_robotics"
	display_name = "Advanced Robotics Research"
	description = "Machines using actual neural networks to simulate human lives."
	prereq_ids = list("neural_programming", "robotics")
	design_ids = list(
		"mmi_posi",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/exodrone_tech
	id = "exodrone"
	display_name = "Exploration Drone Research"
	description = "Technology for exploring far away locations."
	prereq_ids = list("robotics")
	design_ids = list(
		"exodrone_console",
		"exodrone_launcher",
		"exoscanner",
		"exoscanner_console",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_bots
	id = "adv_bots"
	display_name = "Advanced Bots Research"
	description = "Grants access to a special launchpad designed for bots."
	prereq_ids = list("robotics")
	design_ids = list(
		"botpad",
		"botpad_remote",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/neural_programming
	id = "neural_programming"
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list("biotech", "datatheory")
	design_ids = list(
		"skill_station",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

// AI root node
/datum/techweb_node/ai_basic
	id = "ai_basic"
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prereq_ids = list("adv_robotics")
	design_ids = list(
		"aicore",
		"borg_ai_control",
		"intellicard",
		"mecha_tracking_ai_control",
		"aifixer",
		"aiupload",
		"reset_module",
		"asimov_module",
		"default_module",
		"nutimov_module",
		"paladin_module",
		"robocop_module",
		"corporate_module",
		"drone_module",
		"oxygen_module",
		"safeguard_module",
		"protectstation_module",
		"quarantine_module",
		"freeform_module",
		"remove_module",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/ai_adv
	id = "ai_adv"
	display_name = "Advanced Artificial Intelligence"
	description = "State of the art lawsets to be used for AI research."
	prereq_ids = list("ai_basic")
	design_ids = list(
		"asimovpp_module",
		"paladin_devotion_module",
		"dungeon_master_module",
		"painter_module",
		"ten_commandments_module",
		"hippocratic_module",
		"maintain_module",
		"liveandletlive_module",
		"reporter_module",
		"hulkamania_module",
		"peacekeeper_module",
		"overlord_module",
		"tyrant_module",
		"antimov_module",
		"balance_module",
		"thermurderdynamic_module",
		"damaged_module",
		"freeformcore_module",
		"onehuman_module",
		"purge_module",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

//Any kind of point adjustment needs to happen before SSresearch sets up the whole node tree, it gets cached
/datum/techweb_node/ai/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		research_costs[TECHWEB_POINT_TYPE_GENERIC] *= 3
