/datum/techweb_node/ntlink_low
	id = "ntlink_low"
	display_name = "Cybernetic Application"
	description = "Creation of NT-secure basic cyberlinks for low-grade cybernetic augmentation"
	prereq_ids = list("adv_biotech","adv_biotech", "datatheory")
	design_ids = list("ci-nt_low", "ci-set-connector", "nif_standard")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)

/datum/techweb_node/ntlink_low/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR)

/datum/techweb_node/ntlink_high
	id = "ntlink_high"
	display_name = "Advanced Cybernetic Application"
	description = "Creation of NT-secure advanced cyberlinks for high-grade cybernetic augmentation"
	prereq_ids = list("ntlink_low", "adv_cyber_implants","high_efficiency")
	design_ids = list("ci-nt_high", "ci-tg", "ci-cyberconnector")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/job_approved_item_set
	id = "job_itemsets"
	display_name = "NT Approved Job Item Sets"
	description = "A list of approved item sets that can be implanted into the crew to allow easier access to their tools."
	prereq_ids = list("adv_biotech","adv_biotech", "datatheory")
	design_ids = list(
		"ci-set-cook",
		"ci-set-janitor",
		"ci-set-detective",
		"ci-set-paramedic",
		"ci-set-atmospherics",
		"ci-set-botany",
		"ci-set-mining",
		"ci-set-barber",
		"ci-set-flash",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/job_approved_item_set/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/security_authorized_implants
	id = "job_itemsets-sec"
	display_name = "NT Approved Security Implants"
	description = "A list of approved implants for security officers."
	prereq_ids = list("ntlink_high")
	design_ids = list(
		"ci-set-mantis",
		"ci-set-combat",
		"ci-set-taser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/ntlink_low/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
