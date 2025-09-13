/datum/design/nanites/metabolic_synthesis
	name = "Metabolic Synthesis"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel."
	id = "metabolic_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/metabolic_synthesis

/datum/design/nanites/viral
	name = "Viral Replica"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters."
	id = "viral_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/viral

/datum/design/nanites/self_scan
	name = "Host Scan"
	desc = "The nanites display a detailed readout of a body scan to the host."
	id = "selfscan_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/self_scan

/datum/design/nanites/dermal_button
	name = "Dermal Button"
	desc = "Displays a button on the host's skin, which can be used to send a signal to the nanites."
	id = "dermal_button_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/dermal_button

/datum/design/nanites/stealth
	name = "Stealth"
	desc = "The nanites hide their activity and programming from superficial scans."
	id = "stealth_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/stealth

/datum/design/nanites/reduced_diagnostics
	name = "Reduced Diagnostics"
	desc = "Disables some high-cost diagnostics in the nanites, making them unable to communicate their program list to portable scanners. \
	Doing so saves some power, slightly increasing their replication speed."
	id = "red_diag_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/reduced_diagnostics

/datum/design/nanites/access
	name = "Subdermal ID"
	desc = "The nanites store the host's ID access rights in a subdermal magnetic strip. Updates when triggered, copying the host's current access."
	id = "access_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/access

/datum/design/nanites/relay
	name = "Relay"
	desc = "The nanites receive and relay long-range nanite signals."
	id = "relay_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/relay

/datum/design/nanites/repeater
	name = "Signal Repeater"
	desc = "When triggered, sends another signal to the nanites, optionally with a delay."
	id = "repeater_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/sensor/repeat

/datum/design/nanites/relay_repeater
	name = "Relay Signal Repeater"
	desc = "When triggered, sends another signal to a relay channel, optionally with a delay."
	id = "relay_repeater_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/sensor/relay_repeat

/datum/design/nanites/emp
	name = "Electromagnetic Resonance"
	desc = "The nanites cause an electromagnetic pulse around the host when triggered. Will corrupt other nanite programs!"
	id = "emp_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/emp

/datum/design/nanites/spreading
	name = "Infective Exo-Locomotion"
	desc = "The nanites gain the ability to survive for brief periods outside of the human body, as well as the ability to start new colonies without an integration process; \
			resulting in an extremely infective strain of nanites."
	id = "spreading_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/spreading

/datum/design/nanites/nanite_sting
	name = "Nanite Sting"
	desc = "When triggered, projects a nearly invisible spike of nanites that attempts to infect a nearby non-host with a copy of the host's nanites cluster."
	id = "nanite_sting_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/nanite_sting

/datum/design/nanites/mitosis
	name = "Mitosis"
	desc = "The nanites gain the ability to self-replicate, using bluespace to power the process, instead of drawing from a template. This rapidly speeds up the replication rate,\
			but it causes occasional software errors due to faulty copies. Not compatible with cloud sync."
	id = "mitosis_nanites"
	category = list(NANITE_CATEGORY_UTILITIES)
	program_type = /datum/nanite_program/mitosis
