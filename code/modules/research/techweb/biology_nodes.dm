/datum/techweb_node/bio_process
	id = "bio_process"
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prereq_ids = list("biotech")
	design_ids = list(
		"deepfryer",
		"dish_drive",
		"fat_sucker",
		"gibber",
		"griddle",
		"microwave",
		"oven",
		"processor",
		"range", // should be in a further node, probably
		"reagentgrinder",
		"smartfridge",
		"stove",
		"biomass_recycler",
		"corral_corner",
		"slime_extract_requestor",
		"slime_market_pad",
		"slime_market",
		"slimevac",

	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	discount_experiments = list(/datum/experiment/scanning/random/cytology = 3000) //Big discount to reinforce doing it.

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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

