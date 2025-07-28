/datum/techweb_node/mech
	id = "mecha"
	starting_node = TRUE
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	design_ids = list(
		"mech_hydraulic_clamp",
		"mech_recharger",
		"mecha_tracking",
		"mechacontrol",
		"mechapower",
		"ripley_chassis",
		"ripley_left_arm",
		"ripley_left_leg",
		"ripley_main",
		"ripley_peri",
		"ripley_right_arm",
		"ripley_right_leg",
		"ripley_torso",
		"ripleyupgrade",
	)

/datum/techweb_node/mech_tools
	id = "mech_tools"
	starting_node = TRUE
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	design_ids = list(
		"mech_drill",
		"mech_extinguisher",
		"mech_mscanner",
	)

/datum/techweb_node/clown
	id = "clown"
	display_name = "Clown Technology"
	description = "Honk?!"
	prereq_ids = list("base")
	design_ids = list(
		"air_horn",
		"borg_transform_clown",
		"honk_chassis",
		"honk_head",
		"honk_left_arm",
		"honk_left_leg",
		"honk_right_arm",
		"honk_right_leg",
		"honk_torso",
		"honker_main",
		"honker_peri",
		"honker_targ",
		"implant_trombone",
		"mech_banana_mortar",
		"mech_honker",
		"mech_mousetrap_mortar",
		"mech_punching_face",
		"clown_firing_pin",
		"borg_upgrade_cringe",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/odysseus
	id = "mecha_odysseus"
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prereq_ids = list("base")
	design_ids = list(
		"odysseus_chassis",
		"odysseus_head",
		"odysseus_left_arm",
		"odysseus_left_leg",
		"odysseus_main",
		"odysseus_peri",
		"odysseus_right_arm",
		"odysseus_right_leg",
		"odysseus_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)


/datum/techweb_node/clarke
	id = "mecha_clarke"
	display_name = "EXOSUIT: Clarke"
	description = "Clarke exosuit designs"
	prereq_ids = list("engineering")
	design_ids = list(
		"clarke_chassis",
		"clarke_head",
		"clarke_left_arm",
		"clarke_main",
		"clarke_peri",
		"clarke_right_arm",
		"clarke_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_mecha
	id = "adv_mecha"
	display_name = "Advanced Exosuits"
	description = "For when you just aren't Gundam enough."
	prereq_ids = list("adv_robotics")
	design_ids = list(
		"mech_repair_droid",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/material/medium/three = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/gygax
	id = "mech_gygax"
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prereq_ids = list("adv_mecha", "adv_mecha_armor")
	design_ids = list(
		"gygax_armor",
		"gygax_chassis",
		"gygax_head",
		"gygax_left_arm",
		"gygax_left_leg",
		"gygax_main",
		"gygax_peri",
		"gygax_right_arm",
		"gygax_right_leg",
		"gygax_targ",
		"gygax_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/durand
	id = "mech_durand"
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prereq_ids = list("adv_mecha", "adv_mecha_armor")
	design_ids = list(
		"durand_armor",
		"durand_chassis",
		"durand_head",
		"durand_left_arm",
		"durand_left_leg",
		"durand_main",
		"durand_peri",
		"durand_right_arm",
		"durand_right_leg",
		"durand_targ",
		"durand_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/phazon
	id = "mecha_phazon"
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	prereq_ids = list("adv_mecha", "adv_mecha_armor" , "micro_bluespace")
	design_ids = list(
		"phazon_armor",
		"phazon_chassis",
		"phazon_head",
		"phazon_left_arm",
		"phazon_left_leg",
		"phazon_main",
		"phazon_peri",
		"phazon_right_arm",
		"phazon_right_leg",
		"phazon_targ",
		"phazon_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/savannah_ivanov
	id = "mecha_savannah_ivanov"
	display_name = "EXOSUIT: Savannah-Ivanov"
	description = "Savannah-Ivanov exosuit designs"
	prereq_ids = list("adv_mecha", "weaponry", "exp_tools")
	design_ids = list(
		"savannah_ivanov_armor",
		"savannah_ivanov_chassis",
		"savannah_ivanov_head",
		"savannah_ivanov_left_arm",
		"savannah_ivanov_left_leg",
		"savannah_ivanov_main",
		"savannah_ivanov_peri",
		"savannah_ivanov_right_arm",
		"savannah_ivanov_right_leg",
		"savannah_ivanov_targ",
		"savannah_ivanov_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/basic_plasma
	id = "basic_plasma"
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prereq_ids = list("engineering")
	design_ids = list(
		"mech_generator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_plasma
	id = "adv_plasma"
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prereq_ids = list("basic_plasma")
	design_ids = list(
		"mech_plasma_cutter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/adv_mecha_tools
	id = "adv_mecha_tools"
	display_name = "Advanced Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_rcd",
		"mech_thrusters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/med_mech_tools
	id = "med_mech_tools"
	display_name = "Medical Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_biotech", "mecha_odysseus")
	design_ids = list(
		"mech_medi_beam",
		"mech_sleeper",
		"mech_syringe_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_armor
	id = "adv_mecha_armor"
	display_name = "Exosuit Heavy Armor Research"
	description = "Recreating heavy armor with new rapid fabrication techniques."
	prereq_ids = list("adv_mecha", "bluespace_power")
	design_ids = list(
		"mech_ccw_armor",
		"mech_proj_armor",
	)
	discount_experiments = list(/datum/experiment/scanning/random/mecha_destroyed_scan = TECHWEB_TIER_2_POINTS,
								/datum/experiment/scanning/random/mecha_damage_scan = TECHWEB_TIER_1_POINTS)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)

/datum/techweb_node/mech_scattershot
	id = "mecha_tools"
	display_name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_scattershot",
		"mech_scattershot_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_carbine
	id = "mech_carbine"
	display_name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("exotic_ammo")
	design_ids = list(
		"mech_carbine",
		"mech_carbine_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_ion
	id = "mmech_ion"
	display_name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("electronic_weapons", "emp_adv")
	design_ids = list(
		"mech_ion",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_tesla
	id = "mech_tesla"
	display_name = "Exosuit Weapon (MKI Tesla Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("electronic_weapons", "adv_power")
	design_ids = list(
		"mech_tesla",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_laser
	id = "mech_laser"
	display_name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("beam_weapons")
	design_ids = list(
		"mech_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_laser_heavy
	id = "mech_laser_heavy"
	display_name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_beam_weapons")
	design_ids = list(
		"mech_laser_heavy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_disabler
	id = "mech_disabler"
	display_name = "Exosuit Weapon (CH-DS \"Peacemaker\" Mounted Disabler)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_disabler",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_grenade_launcher
	id = "mech_grenade_launcher"
	display_name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list(
		"mech_grenade_launcher",
		"mech_grenade_launcher_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_missile_rack
	id = "mech_missile_rack"
	display_name = "Exosuit Weapon (BRM-6 Missile Rack)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list(
		"mech_missile_rack",
		"mech_missile_rack_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/clusterbang_launcher
	id = "clusterbang_launcher"
	display_name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list(
		"clusterbang_launcher",
		"clusterbang_launcher_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_teleporter
	id = "mech_teleporter"
	display_name = "Exosuit Module (Teleporter Module)"
	description = "An advanced piece of mech Equipment"
	prereq_ids = list("micro_bluespace")
	design_ids = list(
		"mech_teleporter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_wormhole_gen
	id = "mech_wormhole_gen"
	display_name = "Exosuit Module (Localized Wormhole Generator)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("bluespace_travel")
	design_ids = list(
		"mech_wormhole_gen",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_lmg
	id = "mech_lmg"
	display_name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_lmg",
		"mech_lmg_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mech_diamond_drill
	id = "mech_diamond_drill"
	display_name = "Exosuit Diamond Drill"
	description = "A diamond drill fit for a large exosuit"
	prereq_ids = list("adv_mining")
	design_ids = list(
		"mech_diamond_drill",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

