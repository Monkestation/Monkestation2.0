/datum/techweb_node/job_approved_item_set
	id = "job_itemsets"
	display_name = "NT Approved Job Item Sets"
	description = "A list of approved item sets that can be implanted into the crew to allow easier access to their tools."
	prereq_ids = list("adv_biotech","basic_tools", "datatheory")
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
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SECURITY)

/datum/techweb_node/job_approved_item_set/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_DISCOUNT_MINOR * 2)

/datum/techweb_node/security_authorized_implants
	id = "job_itemsets-sec"
	display_name = "NT Approved Security Implants"
	description = "A list of approved implants for security officers."
	prereq_ids = list("adv_cyber_implants", "high_efficiency")
	design_ids = list(
		"ci-set-mantis",
		"ci-set-combat",
		"ci-set-taser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SECURITY)


/datum/techweb_node/security_authorized_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
