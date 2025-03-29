/datum/techweb_node/sec_basic
	id = "sec_basic"
	display_name = "Basic Security Equipment"
	description = "Standard equipment used by security."
	prereq_ids = list("base")
	design_ids = list(
		"bola_energy",
		"evidencebag",
		"pepperspray",
		"seclite",
		"zipties",
		"dragnet_beacon",
		"inspector",
		"rubber_c35", //monkestation edit: taco sec
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)

/datum/techweb_node/weaponry
	id = "weaponry"
	display_name = "Weapon Development Technology"
	description = "Our researchers have found new ways to weaponize just about everything now."
	prereq_ids = list("engineering")
	design_ids = list(
		"pin_testing",
		"tele_shield",
		"mag_autorifle_rub", //monkestation edit: autorifles
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/ordnance/explosive/pressurebomb = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/adv_weaponry
	id = "adv_weaponry"
	display_name = "Advanced Weapon Development Technology"
	description = "Our weapons are breaking the rules of reality by now."
	prereq_ids = list("adv_engi", "weaponry")
	design_ids = list(
		"pin_loyalty",
		"lethal_c35", //monkestation edit: paco sec
		"mag_autorifle", //monkestation edit: autorifles
		"mag_autorifle_salt", //monkestation edit: autorifles
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/explosive_weapons
	id = "explosive_weapons"
	display_name = "Explosive & Pyrotechnical Weaponry"
	description = "If the light stuff just won't do it."
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"adv_grenade",
		"large_grenade",
		"pyro_grenade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/exotic_ammo
	id = "exotic_ammo"
	display_name = "Exotic Ammunition"
	description = "They won't know what hit em."
	prereq_ids = list("weaponry")
	design_ids = list(
		"c38_hotshot",
		"c38_iceblox",
		"techshotshell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	display_name = "Electric Weapons"
	description = "Weapons using electric technology"
	prereq_ids = list("weaponry", "adv_power"  , "emp_basic")
	design_ids = list(
		"ioncarbine",
		"stunrevolver",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	display_name = "Beam Weaponry"
	description = "Various basic beam weapons"
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"temp_gun",
		"xray_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_beam_weapons
	id = "adv_beam_weapons"
	display_name = "Advanced Beam Weaponry"
	description = "Various advanced beam weapons"
	prereq_ids = list("beam_weapons")
	design_ids = list(
		"beamrifle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/radioactive_weapons
	id = "radioactive_weapons"
	display_name = "Radioactive Weaponry"
	description = "Weapons using radioactive technology."
	prereq_ids = list("adv_engi", "adv_weaponry")
	design_ids = list(
		"nuclear_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
