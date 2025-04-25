
/datum/techweb_node/janitor
	id = "janitor"
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list("adv_engi")
	design_ids = list(
		"advmop",
		"beartrap",
		"blutrash",
		"buffer",
		"vacuum",
		"holobarrier_jani",
		"light_replacer_blue",
		"paint_remover",
		"spraybottle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/janitor_trash = TECHWEB_TIER_2_POINTS)
/datum/techweb_node/comptech
	id = "comptech"
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prereq_ids = list("datatheory")
	design_ids = list(
		"cargo",
		"cargorequest",
		"comconsole",
		"crewconsole",
		"idcard",
		"libraryconsole",
		"mining",
		"photobooth",
		"rdcamera",
		"seccamera",
		"security_photobooth",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/datatheory //Computer science
	id = "datatheory"
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	design_ids = list(
		"bounty_pad",
		"bounty_pad_control",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list("comptech")
	design_ids = list(
		"account_console",
		"automated_announcement",
		"med_data",
		"prisonmanage",
		"secdata",
		"vendor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prereq_ids = list("comptech")
	design_ids = list(
		"arcade_battle",
		"arcade_orion",
		"slotmachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	discount_experiments = list(/datum/experiment/physical/arcade_winner = TECHWEB_TIER_1_POINTS)

// Kitchen root node
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/cytology = TECHWEB_TIER_2_POINTS) //Big discount to reinforce doing it.

// Fishing root node
/datum/techweb_node/fishing
	id = "fishing"
	display_name = "Fishing Technology"
	description = "Cutting edge fishing advancements."
	prereq_ids = list("base")
	design_ids = list(
		"fishing_rod_tech",
		"stabilized_hook",
		"fish_analyzer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	required_experiments = list(/datum/experiment/scanning/fish)
