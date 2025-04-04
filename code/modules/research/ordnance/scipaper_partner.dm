/datum/scientific_partner/mining
	name = "Mining Corps"
	flufftext = "A local group of miners are looking for ways to improve their mining output. They are interested in smaller scale explosives."
	accepted_experiments = list(/datum/experiment/ordnance/explosive/lowyieldbomb)
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.75, SCIPAPER_FUNDING_INDEX = 0.75)
	boosted_nodes = list(
		"bluespace_basic" = TECHWEB_DISCOUNT_MINOR * 3,
		"NVGtech" = TECHWEB_DISCOUNT_MINOR * 2.5,
		"practical_bluespace" = TECHWEB_TIER_1_POINTS,
		"basic_plasma" = TECHWEB_DISCOUNT_MINOR * 3,
		"basic_mining" = TECHWEB_DISCOUNT_MINOR * 3,
		"adv_mining" = TECHWEB_DISCOUNT_MINOR * 3,
	)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext = "A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX = 2)
	boosted_nodes = list(
		"comp_recordkeeping" = TECHWEB_DISCOUNT_MINOR,
		"computer_data_disks" = TECHWEB_DISCOUNT_MINOR,
	)

/datum/scientific_partner/defense
	name = "Defense Partnership"
	flufftext = "We can work directly for Nanotrasen's \[REDACTED\] division, potentially providing us access with advanced defensive gadgets."
	accepted_experiments = list(
		/datum/experiment/ordnance/explosive/highyieldbomb,
		/datum/experiment/ordnance/explosive/pressurebomb,
		/datum/experiment/ordnance/explosive/hydrogenbomb,
	)
	boosted_nodes = list(
		"adv_weaponry" = TECHWEB_TIER_2_POINTS,
		"weaponry" = TECHWEB_TIER_1_POINTS,
		"sec_basic" = TECHWEB_DISCOUNT_MINOR * 2,
		"explosive_weapons" = TECHWEB_DISCOUNT_MINOR * 2,
		"electronic_weapons" = TECHWEB_DISCOUNT_MINOR * 2,
		"radioactive_weapons" = TECHWEB_DISCOUNT_MINOR * 2,
		"beam_weapons" = TECHWEB_DISCOUNT_MINOR * 2,
		"explosive_weapons" = TECHWEB_DISCOUNT_MINOR * 2,
	)

/datum/scientific_partner/medical
	name = "Biological Research Division"
	flufftext = "A collegiate of the best medical researchers Nanotrasen employs. They seem to be interested in the biological effects of some more exotic gases. Especially stimulants and neurosupressants."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/nitrous_oxide,
		/datum/experiment/ordnance/gaseous/bz,
	)
	boosted_nodes = list(
		"cyber_organs" = TECHWEB_DISCOUNT_MINOR * 2,
		"cyber_organs_upgraded" = TECHWEB_DISCOUNT_MINOR * 2,
		"genetics" = TECHWEB_DISCOUNT_MINOR ,
		"subdermal_implants" = TECHWEB_DISCOUNT_MINOR * 2,
		"adv_biotech" = TECHWEB_DISCOUNT_MINOR * 2,
		"biotech" = TECHWEB_DISCOUNT_MINOR * 2,
	)

/datum/scientific_partner/physics
	name = "NT Physics Quarterly"
	flufftext = "A prestigious physics journal managed by Nanotrasen. The main journal for publishing cutting-edge physics research conducted by Nanotrasen, given that they aren't classified."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/noblium,
		/datum/experiment/ordnance/explosive/nobliumbomb,
	)
	boosted_nodes = list(
		"engineering" = TECHWEB_TIER_2_POINTS,
		"adv_engi" = TECHWEB_TIER_2_POINTS,
		"emp_super" = TECHWEB_TIER_1_POINTS,
		"emp_adv" = TECHWEB_DISCOUNT_MINOR * 2.5,
		"high_efficiency" = TECHWEB_TIER_2_POINTS,
		"micro_bluespace" = TECHWEB_TIER_2_POINTS,
		"adv_power" = TECHWEB_DISCOUNT_MINOR * 2.5,
	)
