/datum/techweb_node/xenomorph_lifecycle
	id = "xenomorph_lifecycle"
	display_name = "Xenomorph Lifecycle Research"
	prereq_ids = list("base")
	description = "The lifecycle of the xenomorphs is a complex and fascinating process. We have to learn more about their lifecycle from start to finish."
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	required_experiments = list(/datum/experiment/scanning/xenomorph)

/datum/techweb_node/xenomorph_hivenode //probably the last experiment?
	id = "xenomorph_hivenode"
	display_name = "Xenomorph Hivenode Scanning"
	prereq_ids = list("xenomorph_lifecycle")
	description = "The xenomorph hive node is the psionic link between xenomorphs. If we can hijack it, we should be able to subjugate the xenomorph subjects."
	design_ids = list(
		"hivenode_hijacker",
	)

/datum/techweb_node/delivery_confirmation //first node in xeno tech tree
	id = "xeno_delivery"
	display_name = "Xenomorph Sample Delivery Confirmation"
	prereq_ids = list("base")
	description = "We need to confirm that the xenomorph samples are delivered to the correct location. We send an egg most shifts but only occasionally get a sample back. \
	 We need to confirm that youre actually getting these sampkes"
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	required_experiments = list(/datum/experiment/scanning/xeno_egg)

/datum/techweb_node/offspring_scanning //after the initial embryo scan, another embryo scan

/datum/techweb_node/gestation_scan //scan of a crew member with an embryo inside them
