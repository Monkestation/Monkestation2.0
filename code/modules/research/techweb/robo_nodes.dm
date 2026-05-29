/datum/techweb_node/robotics
	id = "robotics"
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list(
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
		"ecto_sniffer",
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
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/adv_bots
	id = "adv_bots"
	display_name = "Advanced Bots Research"
	description = "Grants access to special launchpads designed for bots big and small."
	prereq_ids = list("robotics")
	design_ids = list(
		"botpad",
		"botpad_remote",
		"mechpad",
		"mechpad_console"
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
