
/datum/techweb_node/imp_wt_surgery
	id = "imp_wt_surgery"
	display_name = "Improved Wound-Tending Surgery"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list("biotech")
	design_ids = list(
		"surgery_heal_brute_upgrade",
		"surgery_heal_burn_upgrade",
		"surgery_filter_upgrade", // monke edit: improved blood filter surgery
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)


/datum/techweb_node/adv_surgery
	id = "adv_surgery"
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list("imp_wt_surgery")
	design_ids = list(
		"surgery_heal_brute_upgrade_femto",
		"surgery_heal_burn_upgrade_femto",
		"surgery_heal_combo",
		"surgery_lobotomy",
		"surgery_wing_reconstruction",
		"surgery_filter_upgrade_femto", // monkestation edit: advanced blood filter surgery
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/exp_surgery
	id = "exp_surgery"
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list("adv_surgery")
	design_ids = list(
		"surgery_cortex_folding",
		"surgery_cortex_imprint",
		"surgery_heal_combo_upgrade",
		"surgery_ligament_hook",
		"surgery_ligament_reinforcement",
		"surgery_muscled_veins",
		"surgery_nerve_ground",
		"surgery_nerve_splice",
		"surgery_pacify",
		"surgery_vein_thread",
		"surgery_viral_bond",
		"surgery_dna_recovery", // monkestation edit: dna recovery surgery
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/alien_surgery
	id = "alien_surgery"
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list("exp_surgery", "alientech")
	design_ids = list(
		"surgery_brainwashing",
		"surgery_heal_combo_upgrade_femto",
		"surgery_zombie",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
