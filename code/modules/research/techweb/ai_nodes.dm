////////////////////////AI Hardware////////////////////////
/datum/techweb_node/ai_cpu_advanced
	id = "ai_cpu_advanced"
	display_name = "Advanced Neural Processing"
	description = "Using breakthroughs in high-efficiency fabrication it should be possible to drastically increase the speed of Neural Processing Units, at the cost of increased power consumption."
	design_ids = list("advanced_ai_cpu")
	prereq_ids = list("high_efficiency", "ai_basic")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_cpu_experimental
	id = "ai_cpu_experimental"
	display_name = "Experimental Neural Processing"
	description = "Previously discarded NPUs could be repurposed with minor tweaks. This comes at the expense of increased powerconsumption, but enhanced overclocking capabilities."
	design_ids = list("experimental_ai_cpu")
	prereq_ids = list("ai_cpu_advanced")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_cpu_bluespace
	id = "ai_cpu_bluespace"
	display_name = "Bluespace Neural Processing"
	description = "Breakthroughts in bluespace allows the fabrication of ultra fast NPUs. This however comes at the expense of greatly higher power consumption."
	design_ids = list("bluespace_ai_cpu")
	prereq_ids = list("ai_cpu_advanced", "practical_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_ram_high_cap
	id = "ai_ram_high_cap"
	display_name = "High Capacity Memory Sticks"
	description = "Further advances in memory production should allow higher density sticks."
	design_ids = list("ram2")
	prereq_ids = list("high_efficiency", "ai_basic")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_ram_hyper
	id = "ai_ram_hyper"
	display_name = "Hyper Capacity Memory Sticks"
	description = "Further refinement of memory technology allows previously unimaginable data-density."
	design_ids = list("ram3")
	prereq_ids = list("ai_ram_high_cap")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_ram_bluespace
	id = "ai_ram_bluespace"
	display_name = "Bluespace Memory Sticks"
	description = "Breakthroughs in bluespace technology allows memory chips to store data in special bluespace pockets. Greatly improves data density at the cost of higher fabrication costs."
	design_ids = list("ram4")
	prereq_ids = list("ai_ram_hyper", "practical_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/**
 * # AI Software
 *
 * Researching these will give extra sockets in the Rack creator
 * This is separate from the RAM and CPU items above, which are the items themselves.
 */
/datum/techweb_node/ai_cpu_2
	id = "ai_cpu_2"
	display_name = "Improved CPU Sockets"
	description = "Refinements in general data theory should allow the mounting of an extra CPU core in each AI server rack."
	design_ids = list("ai_cpu_socket_2")
	prereq_ids = list("ai_basic")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_cpu_3
	id = "ai_cpu_3"
	display_name = "Advanced CPU Sockets"
	description = "256 bit computing allows the introduction of another CPU core."
	design_ids = list("ai_cpu_socket_3")
	prereq_ids = list("ai_arch_256", "ai_cpu_2")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_cpu_4
	id = "ai_cpu_4"
	display_name = "Bluespace CPU Sockets"
	description = "Instant teleportation of data across CPU caches allows the installation of a fourth CPU core."
	design_ids = list("ai_cpu_socket_4")
	prereq_ids = list("ai_arch_bluespace", "ai_cpu_3")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_ram_2
	id = "ai_ram_2"
	display_name = "Improved Memory Bus"
	description = "Refinements in general data theory should allow the addition of another memory stick in each AI server rack."
	design_ids = list("ai_ram_socket_2")
	prereq_ids = list("ai_basic")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_ram_3
	id = "ai_ram_3"
	display_name = "Advanced Memory Bus"
	description = "256 bit computing allows the introduction of another memory module."
	design_ids = list("ai_ram_socket_3")
	prereq_ids = list("ai_arch_256", "ai_ram_2")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai_ram_4
	id = "ai_ram_4"
	display_name = "Bluespace Memory Bus"
	description = "Bluespace teleportation allows the removal of all bottlenecks. Allows for the introduction of a fourth memory module."
	design_ids = list("ai_ram_socket_4")
	prereq_ids = list("ai_ram_3", "ai_arch_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

///This is in between Tier 2 & Tier 3
/datum/techweb_node/ai_architecture_256
	id = "ai_arch_256"
	display_name = "256bit Computing"
	description = "Experience with creating computer hardware highlights the need for additional CPU cores and memory sticks in each rack. This acts as a gateway to those technologies."
	prereq_ids = list("ai_ram_2", "ai_cpu_2")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

///This is in between Tier 3 & Tier 4
/datum/techweb_node/ai_architecture_bluespace
	id = "ai_arch_bluespace"
	display_name = "Bluespace Computing"
	description = "Bluespace advances allow the instant teleportation of data across a server rack. This acts as a gateway to the final tier of computing."
	prereq_ids = list("ai_arch_256", "practical_bluespace")
	research_costs = list(TECHWEB_POINT_TYPE_AI = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
