/datum/techweb_node/genetics
	id = "genetics"
	display_name = "Genetic Engineering"
	description = "We have the technology to change him."
	prereq_ids = list("biotech")
	design_ids = list(
		"dna_disk",
		"dnainfuser",
		"dnascanner",
		"scan_console",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

// Botany root node

/datum/techweb_node/botany
	id = "botany"
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prereq_ids = list("biotech")
	design_ids = list(
		/* "diskplantgene", */ // monkestation edit: move to roundstart tech
		"biogenerator",
		"flora_gun",
		"gene_shears",
		"hydro_tray",
		"portaseeder",
		"seed_extractor",
		"adv_watering_can",
		"plantgenes",
		// monkestation edit: our hydroponics stuff
		"composters",
		"splicer",
		// monkestation end
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = TECHWEB_DISCOUNT_MINOR * 3,
								/datum/experiment/scanning/random/plants/wild = TECHWEB_DISCOUNT_MINOR * 3)
