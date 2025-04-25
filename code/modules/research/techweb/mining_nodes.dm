
/datum/techweb_node/basic_mining
	id = "basic_mining"
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list("engineering", "basic_plasma")
	design_ids = list(
		"borg_upgrade_cooldownmod",
		"borg_upgrade_damagemod",
		"borg_upgrade_rangemod",
		"cargoexpress",
		"b_smelter",
		"b_refinery",
		"brm",
		"cooldownmod",
		"damagemod",
		"drill",
		"mecha_kineticgun",
		"mining_equipment_vendor",
		"ore_redemption",
		"plasmacutter",
		"rangemod",
		"superresonator",
		"triggermod",
		"mining_scanner",
		"mat_analyzer",
		"pocket_heater", // monkestation edit
	)//e a r l y    g a  m e)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/bitrunning
	id = "bitrunning"
	display_name = "Bitrunning Technology"
	description = "Bluespace technology has led to the development of quantum-scale computing, which unlocks the means to materialize atomic structures while executing advanced programs."
	prereq_ids = list("practical_bluespace")
	design_ids = list(
		"byteforge",
		"quantum_console",
		"netpod",
		"bitrunning_order", //MONKESTATION ADDITION
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_mining
	id = "adv_mining"
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127" //dumb mc references
	prereq_ids = list("basic_mining", "adv_power", "adv_plasma")
	design_ids = list(
		"drill_diamond",
		"hypermod",
		"jackhammer",
		"plasmacutter_adv",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/material/hard/one = TECHWEB_TIER_2_POINTS)
