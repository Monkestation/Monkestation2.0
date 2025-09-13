/datum/design/nanites/flesh_eating
	name = "Cellular Breakdown"
	desc = "The nanites destroy cellular structures in the host's body, causing brute damage."
	id = "flesheating_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/flesh_eating

/datum/design/nanites/poison
	name = "Poisoning"
	desc = "The nanites deliver poisonous chemicals to the host's internal organs, causing toxin damage and vomiting."
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
	desc = "Nanites will consume organic matter to improve their replication rate, damaging the host."
	id = "aggressive_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/aggressive_replication

/datum/design/nanites/meltdown
	name = "Meltdown"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host as well as rapidly destroying the nanite population.\
			Sets the nanites' safety threshold to 0 when activated."
	id = "meltdown_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/meltdown

/datum/design/nanites/cryo
	name = "Cryogenic Treatment"
	desc = "The nanites rapidly skin heat through the host's skin, lowering their temperature."
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
	desc = "Stops the host's heart when triggered; restarts it if triggered again."
	id = "heartstop_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/heart_stop

/datum/design/nanites/explosive
	name = "Chain Detonation"
	desc = "Blows up all the nanites inside the host in a chain reaction when triggered."
	id = "explosive_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/explosive

/datum/design/nanites/mind_control
	name = "Mind Control"
	desc = "The nanites imprint an absolute directive onto the host's brain while they're active."
	id = "mindcontrol_nanites"
	category = list(NANITES_CATEGORY_WEAPONIZED)
	program_type = /datum/nanite_program/comm/mind_control
