/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Cloning"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "dnascanner", "dna_disk", "clonepod_experimental")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/adv_ballistics
	id = "adv_ballistics"
	display_name = "Advanced Ballistics"
	description = "The most sophisticated methods of shooting people."
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"mag_autorifle_ap",
		"mag_autorifle_ic",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/linked_surgery
	id = "linked_surgery"
	display_name = "Surgical Serverlink Brain Implant"
	description = "A bluespace implant which a holder can read surgical programs from their server with."
	prereq_ids = list("exp_surgery", "micro_bluespace")
	design_ids = list("linked_surgery")
	required_items_to_unlock = list(/obj/item/organ/internal/cyberimp/brain/linked_surgery)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/serverlink = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/linked_surgery/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/ipc_parts
	id = "ipc_parts"
	display_name = "I.P.C Repair Parts"
	description = "Through purchasing licenses to print IPC Parts, we can rebuild our silicon friends, no, not those silicon friends."
	prereq_ids = list("robotics")
	design_ids = list(
		"ipc_head",
		"ipc_chest",
		"ipc_arm_left",
		"ipc_arm_right",
		"ipc_leg_left",
		"ipc_leg_right",
		"power_cord",
		"ipc_antennae",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/bomb_actualizer
	id = "bomb_actualizer"
	display_name = "Bomb Actualization Technology"
	description = "Using bluespace technology we can increase the actual yield of ordinance to their theoretical maximum on station... to disasterous effect."
	prereq_ids = list("micro_bluespace", "bluespace_storage", "practical_bluespace")
	design_ids = list(
		"bomb_actualizer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_7_POINTS)

// Maint mods
/datum/techweb_node/springlock
	id = "mod_springlock"
	display_name = "MOD Springlock Module"
	description = "A obsolete module decreasing the sealing time of modsuits. A discarded note from the orginal designs was found. 'Try not to nudge or press against ANY of the spring locks inside the suit. Do not touch the spring lock at any time. Do not breathe on a spring lock, as mouisture may loosen them, and cause them to break loose.'"
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_springlock",
	)

	required_items_to_unlock = list(
		/obj/item/mod/module/springlock,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)
	hidden = TRUE

/datum/techweb_node/rave
	id = "mod_rave"
	display_name = "MOD Rave Visor Module"
	description = "Reverse engineering of the Super Cool Awesome Visor for mass production."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_rave",
	)

	required_items_to_unlock = list(
		/obj/item/mod/module/visor/rave,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)
	hidden = TRUE

/datum/techweb_node/tanner
	id = "mod_tanner"
	display_name = "MOD Tanning Module"
	description = "Enjoy all the benifets of vitamin D without a lick of starlight touching you."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_tanner",
	)

	required_items_to_unlock = list(
		/obj/item/mod/module/tanner,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)
	hidden = TRUE

/datum/techweb_node/balloon
	id = "mod_balloon"
	display_name = "MOD Balloon Blower Module"
	description = "Crack the mimes ancestor's secret of balloon blowing."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_balloon",
	)

	required_items_to_unlock = list(
		/obj/item/mod/module/balloon,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)
	hidden = TRUE

/datum/techweb_node/paper_dispenser
	id = "mod_paper_dispenser"
	display_name = "MOD Paper Dispenser Module"
	description = "Become the master of all paperwork, and annoy everyone with ondemand paper airplanes."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_paper_dispenser",
	)

	required_items_to_unlock = list(
		/obj/item/mod/module/paper_dispenser,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)
	hidden = TRUE

/datum/techweb_node/stamp
	id = "mod_stamp"
	display_name = "MOD Stamper Module"
	description = "Forgo the ability to forget your stamp at home. Paper pushers of all kinds, rejoyce."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_stamp",
	)

	required_items_to_unlock = list(
		/obj/item/mod/module/stamp,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)
	hidden = TRUE

/datum/techweb_node/atrocinator
	id = "mod_atrocinator"
	display_name = "MOD Atrocinator Module"
	description = "With this forgotten innovation things will only be looking up from here once."
	prereq_ids = list("mod_advanced")
	design_ids = list(
		"mod_atrocinator",
	)

	required_items_to_unlock = list(
		/obj/item/mod/module/atrocinator,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)
	hidden = TRUE

/datum/techweb_node/improved_robotic_tend_wounds
	id = "improved_robotic_surgery"
	display_name = "Improved Robotic Repair Surgeries"
	description = "As it turns out, you don't actually need to cut out entire support rods if it's just scratched!"
	prereq_ids = list("engineering")
	design_ids = list(
		"surgery_heal_robot_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)

/datum/techweb_node/advanced_robotic_tend_wounds
	id = "advanced_robotic_surgery"
	display_name = "Advanced Robotic Surgeries"
	description = "Did you know Hephaestus actually has a free online tutorial for synthetic trauma repairs? It's true!"
	prereq_ids = list("improved_robotic_surgery")
	design_ids = list(
		"surgery_heal_robot_upgrade_femto",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2) // less expensive than the organic surgery research equivalent since its JUST tend wounds

/datum/techweb_node/chemical_weapons
	discount_experiments = list(/datum/experiment/scanning/random/casing = TECHWEB_DISCOUNT_MINOR * 2.5)

/datum/techweb_node/ai_basic
	discount_experiments = list(/datum/experiment/scanning/random/shell_scan = TECHWEB_DISCOUNT_MINOR)

/datum/techweb_node/ai_adv
	discount_experiments = list(/datum/experiment/scanning/random/shell_scan = TECHWEB_DISCOUNT_MINOR * 3)

/datum/techweb_node/robotics
	discount_experiments = list(/datum/experiment/scanning/random/bot_scan = TECHWEB_DISCOUNT_MINOR * 2.5)

/datum/techweb_node/adv_bots
	discount_experiments = list(/datum/experiment/scanning/random/bot_scan = TECHWEB_DISCOUNT_MINOR * 2.5)

/datum/techweb_node/datatheory
	discount_experiments = list(/datum/experiment/scanning/random/money = TECHWEB_DISCOUNT_MINOR * 2.5)

/datum/techweb_node/comptech
	discount_experiments = list(/datum/experiment/scanning/random/money = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/mod_advanced
	discount_experiments = list(/datum/experiment/scanning/points/modsuit = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/mod_engineering
	discount_experiments = list(/datum/experiment/scanning/points/modsuit = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/mod_medical
	discount_experiments = list(/datum/experiment/scanning/points/modsuit = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/mod_security
	discount_experiments = list(/datum/experiment/scanning/points/modsuit = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/mod_entertainment
	discount_experiments = list(/datum/experiment/scanning/points/modsuit = TECHWEB_DISCOUNT_MINOR * 2)
