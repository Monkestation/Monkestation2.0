/datum/design/nanites/flesh_eating
	name = "Cellular Breakdown"
	desc = "The nanites destroy cellular structures in the host's body, causing 1 brute damage per second."
	id = "flesheating_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/flesh_eating

/datum/design/nanites/poison
	name = "Poisoning"
	desc = "The nanites deliver poisonous chemicals to the host's internal organs, causing 1 toxin damage per second, as well as vomiting."
	id = "poison_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/poison

/datum/design/nanites/memory_leak
	name = "Memory Leak"
	desc = "This program invades the memory space used by other programs, causing frequent corruptions and errors."
	id = "memleak_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/memory_leak

/datum/design/nanites/aggressive_replication
	name = "Aggressive Replication"
	desc = "Nanites will consume organic matter to improve their replication rate, damaging the host. The efficiency increases with the volume of nanites, requiring 200 to break even, \
		and scaling linearly for a net positive of 0.1 production rate per 20 nanite volume beyond that. Deals 0.5 brute damage per nanite produced this way."
	id = "aggressive_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/aggressive_replication

/datum/design/nanites/meltdown
	name = "Meltdown"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host which deal 3.5 burn damage per second.\
			Sets the nanites' safety threshold to 0 when activated."
	id = "meltdown_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/meltdown

/datum/design/nanites/cryo
	name = "Cryogenic Treatment"
	desc = "The nanites rapidly sink heat through the host's skin, lowering their body temperature by around 20 Kelvin per second. This stops at a minimum of 50 Kelvin."
	id = "cryo_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/cryo

/datum/design/nanites/pyro
	name = "Sub-Dermal Combustion"
	desc = "The nanites cause buildup of flammable fluids under the host's skin, then ignites them."
	id = "pyro_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/pyro

/datum/design/nanites/heart_stop
	name = "Heart-Stopper"
	desc = "When triggered, stops the host's heart if it's beating and restarts it if it's not."
	id = "heartstop_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/heart_stop

/datum/design/nanites/explosive
	name = "Chain Detonation"
	desc = "Detonates all the nanites inside the host in a chain reaction when triggered. \
		The power of the resultant explosion is determined by the number of nanites detonated."
	id = "explosive_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/explosive

/datum/design/nanites/mind_control
	name = "Mind Control"
	desc = "The nanites imprint an absolute directive onto the host's brain for five minutes when triggered."
	id = "mindcontrol_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/comm/mind_control
