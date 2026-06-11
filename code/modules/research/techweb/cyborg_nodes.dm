/datum/techweb_node/cyborg
	id = "cyborg"
	starting_node = TRUE
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	design_ids = list(
		"borg_chest",
		"borg_head",
		"borg_l_arm",
		"borg_l_leg",
		"borg_r_arm",
		"borg_r_leg",
		"borg_suit",
		"borg_upgrade_rename",
		"borg_upgrade_restart",
		"cyborgrecharger",
		"mmi",
		"robocontrol",
		"sflash",
	)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

//
// Cyborg Upgrades
//

/datum/techweb_node/cyborg_upgrades_mining
	id = "cyborg_upgrades_mining"
	display_name = "Cyborg Upgrades: Mining"
	description = "Enabling compatibility of our mining technology for usage within cyborgs."
	prereq_ids = list(
		"adv_mining",
		"adv_robotics"
	)
	design_ids = list(
		"borg_upgrade_diamonddrill",
		"borg_upgrade_lavaproof",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2) // Very few upgrades shall be cheap.
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_engineering
	id = "cyborg_upgrades_engineering"
	display_name = "Cyborg Upgrades: Engineering"
	description =  "Enabling compatibility of our engineering technology for usage within cyborgs."
	prereq_ids = list(
		"adv_engi",
		"adv_robotics"
	)
	design_ids = list(
		"borg_upgrade_charger",
		"borg_upgrade_extra_sheet_manipulator",
		"borg_upgrade_ranged_analyzer"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_medical
	id = "cyborg_upgrades_medical"
	display_name = "Cyborg Upgrades: Medical"
	description = "Enabling compatibility of our medical technology for usage within cyborgs."
	prereq_ids = list(
		"adv_biotech",
		"adv_robotics"
	)
	design_ids = list(
		"borg_upgrade_advanalyzer",
		"borg_upgrade_beakerapp",
		"borg_upgrade_iv_drip",
		"borg_upgrade_defibrillator",
		"borg_upgrade_expandedsynthesiser",
		"borg_upgrade_piercinghypospray",
		"borg_upgrade_pinpointer",
		"borg_upgrade_surgical_database",
		"borg_upgrade_surgicalomnitool"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS) // Lots of upgrades shall be regular cost.
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_utility
	id = "cyborg_upgrades_utility"
	display_name = "Cyborg Upgrades: Utility"
	description = "Enabling compatibility of our most basic technology for usage within cyborgs."
	prereq_ids = list(
		"cyborg",
		"adv_robotics"
	)
	design_ids = list(
		"borg_upgrade_selfrepair",
		"borg_upgrade_thrusters",
		"borg_upgrade_expand",
		"borg_upgrade_clamp", // Cargo is so lacking that they don't get their own techweb node.
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_science
	id = "cyborg_upgrades_science"
	display_name = "Cyborg Upgrades: Science"
	description = "They're taking our jobs!"
	prereq_ids = list("cyborg_upgrades_utility")
	design_ids = list(
		"borg_upgrade_science_apparatus_improvement_robotics",
		"borg_upgrade_science_apparatus_improvement_ordnance",
		"borg_upgrade_science_apparatus_improvement_circuits",
		"borg_upgrade_science_xenobiology"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_security
	id = "cyborg_upgrades_security"
	display_name = "Cyborg Upgrades: Security"
	description =  "Enabling compatibility of our weaponry technology for usage within cyborgs."
	prereq_ids = list(
		"weaponry",
		"adv_robotics"
	)
	design_ids = list(
		"borg_upgrade_disablercooler"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_security/New()
	. = ..()
	if(CONFIG_GET(flag/disable_secborg))
		hidden = TRUE // Node begone!

/datum/techweb_node/cyborg_upgrades_janitor
	id = "cyborg_upgrades_janitor"
	display_name = "Cyborg Upgrades: Janitorial"
	description = "Enabling compatibility of our janitorial technology for usage within cyborgs."
	prereq_ids = list(
		"janitor",
		"adv_robotics"
	)
	design_ids = list(
		"borg_upgrade_advancedmop",
		"borg_upgrade_prt",
		"borg_upgrade_trashofholding"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_service
	id = "cyborg_upgrades_service"
	display_name = "Cyborg Upgrades: Service"
	description = "Enabling compatibility of our service technology for usage within cyborgs."
	prereq_ids = list(
		"bio_process",
		"adv_robotics"
	)
	design_ids = list(
		"borg_upgrade_condiment_synthesizer"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_bluespace
	id = "cyborg_upgrades_bluespace"
	display_name = "Cyborg Upgrades: Bluespace"
	description = "Enabling compatibility of our bluespace technology for usage within cyborgs."
	prereq_ids = list(
		"cyborg_upgrades_engineering",
		"cyborg_upgrades_mining",
		"practical_bluespace"
	)
	design_ids = list(
		"borg_upgrade_bs_rped",
		"borg_upgrade_holding"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/cyborg_upgrades_nightvision
	id = "cyborg_upgrades_nightvision"
	display_name = "Cyborg Upgrades: Nightvision"
	description = "Enabling compatibility of our night vision technology for usage within cyborgs."
	prereq_ids = list(
		"adv_robotics",
		"NVGtech"
	)
	design_ids = list(
		"borg_upgrade_nvmeson"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

//
// Implants
//

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech")
	design_ids = list(
		"c38_trac",
		"implant_chem",
		"implant_tracking",
		"implant_exile",
		"implant_bluespace",
		"implantcase",
		"implanter",
		"locator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SECURITY)

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list("adv_biotech", "datatheory")
	design_ids = list(
		"ci-breather",
		"ci-diaghud",
		"ci-gloweyes",
		"ci-medhud",
		"ci-meson",
		"ci-nutriment",
		"ci-pathohud",
		"ci-scihud",
		"ci-sechud",
		"ci-welding",
		"nif_standard",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/cyber_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list("adv_cyber_implants","weaponry","NVGtech","high_efficiency")
	design_ids = list(
		"ci-antidrop",
		"ci-antistun",
		"ci-thrusters"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/combat_cyber_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR * 2.5)

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list("neural_programming", "cyber_implants","integrated_HUDs")
	design_ids = list(
		"ci-nutrimentplus",
		"ci-reviver",
		"ci-surgery",
		"ci-toolset",
		"ci-sprinter", //monkestation addition:
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/adv_cyber_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR * 2.5)

/datum/techweb_node/illegal_combat_implants
	id = "illegal_combat_implants"
	display_name = "Illegal Combat Cybernetic Implants"
	description = "Illegal military grade combat implants to improve performance."
	prereq_ids = list("combat_cyber_implants", "syndicate_basic")
	design_ids = list(
		"ci-thermals",
		"ci-xray"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/illegal_combat_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR)

//
// Organs
//

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("biotech")
	design_ids = list(
		"cybernetic_ears_u",
		"cybernetic_eyes_improved",
		"cybernetic_heart_tier2",
		"cybernetic_liver_tier2",
		"cybernetic_lungs_tier2",
		"cybernetic_stomach_tier2",
		"cybernetic_spleen_tier2",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber_organs/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR)

/datum/techweb_node/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list("adv_biotech", "cyber_organs")
	design_ids = list(
		"cybernetic_ears_whisper",
		"cybernetic_ears_xray",
		"cybernetic_heart_tier3",
		"cybernetic_liver_tier3",
		"cybernetic_lungs_tier3",
		"cybernetic_stomach_tier3",
		"cybernetic_spleen_tier3"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber_organs_upgraded/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR)

//
// Limbs
//

/datum/techweb_node/augmentation
	id = "augmentation"
	display_name = "Advanced Prosthetics"
	description = "Designs for some one of the most enhanced prosthetic set's on the market. They harden in response to physical trauma."
	prereq_ids = list("ipc_parts")
	design_ids = list(
		"advanced_l_arm",
		"advanced_r_arm",
		"advanced_l_leg",
		"advanced_r_leg"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)
