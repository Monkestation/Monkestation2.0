/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list("biotech","engineering")
	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/cautery/alien,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	design_ids = list(
		"alienalloy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	hidden = TRUE

/datum/techweb_node/alientech/on_research() //Unlocks the Zeta shuttle for purchase
		SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_ALIENTECH] = TRUE

/datum/techweb_node/alien_bio
	id = "alien_bio"
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prereq_ids = list("alientech", "adv_biotech")
	design_ids = list(
		"alien_cautery",
		"alien_drill",
		"alien_hemostat",
		"alien_retractor",
		"alien_saw",
		"alien_scalpel",
	)

	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/cautery/alien,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/circular_saw/alien,
		// Monkestation edit start: Removing Alien tools from biotech
		// /obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		// /obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		// /obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/* /obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,*/
		// Monkestation edit End: Removing Alien tools from biotech
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/slime/hard = TECHWEB_TIER_4_POINTS)
	hidden = TRUE

/datum/techweb_node/alien_engi
	id = "alien_engi"
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list("alientech", "adv_engi")

	design_ids = list(
		"alien_crowbar",
		"alien_multitool",
		"alien_screwdriver",
		"alien_welder",
		"alien_wirecutters",
		"alien_wrench",
	)

	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
