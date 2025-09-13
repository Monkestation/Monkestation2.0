/datum/design/nanites/regenerative
	name = "Accelerated Regeneration"
	desc = "The nanites boost the host's natural regeneration, healing 0.5 brute and 0.5 burn damage per second. \
		Will not consume nanites while the host is unharmed, and works better in low-pressure environments."
	id = "regenerative_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/regenerative

/datum/design/nanites/regenerative_advanced
	name = "Bio-Reconstruction"
	desc = "The nanites manually repair and replace organic cells, healing 2 brute damage and 2 burn damage per second. \
			However, this program cannot detect the difference between harmed and unharmed, causing it to consume nanites even if it has no effect."
	id = "regenerative_plus_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/regenerative_advanced

/datum/design/nanites/oxygen_rush
	name = "Alveolic Deoxidation"
	desc = "The nanites deoxidze the carbon dioxide carried within the blood inside of the host's lungs through rapid electrical stimulus, healing 10 oxygen damage per second. \
			However, this process is extremely dangerous, leaving carbon deposits within the lungs and thus causing 4 points of lung damage per second."
	id = "oxygen_rush_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/oxygen_rush

/datum/design/nanites/temperature
	name = "Temperature Adjustment"
	desc = "The nanites adjust the host's internal temperature to an ideal level at a rate of 10 Kelvin per second. Will not consume nanites while the host is at a normal body temperature."
	id = "temperature_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/temperature

/datum/design/nanites/purging
	name = "Blood Purification"
	desc = "The nanites purge toxins and chemicals from the host's bloodstream, healing 1 toxin damage and removing 1 unit of each chemical per second. \
		Consumes nanites even if it has no effect. Ineffective against Radiomagnetic Disruptor."
	id = "purging_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/purging

/datum/design/nanites/purging_advanced
	name = "Selective Blood Purification"
	desc = "The nanites purge toxins (healing one point of toxin damage per second) and toxic chemicals (purging 1 unit of toxins per second) from the host's bloodstream, while ignoring other chemicals. \
			The added processing power required to analyze the chemicals severely increases the nanite consumption rate. Consumes nanites even if it has no effect."
	id = "purging_plus_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/purging_advanced

/datum/design/nanites/brain_heal
	name = "Neural Regeneration"
	desc = "The nanites fix neural connections in the host's brain, reversing 1 point of brain damage per second with a 10% chance to fix minor traumas. \
		Will not consume nanites while it would not have an effect."
	id = "brainheal_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/brain_heal

/datum/design/nanites/brain_heal_advanced
	name = "Neural Reimaging"
	desc = "The nanites are able to backup and restore the host's neural connections, removing 2 points of brain damage per second with a 10% chance to heal deep-rooted traumas. \
		Consumes nanites even if it has no effect."
	id = "brainheal_plus_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/brain_heal_advanced

/datum/design/nanites/blood_restoring
	name = "Blood Regeneration"
	desc = "The nanites stimulate and boost blood cell production in the host, regenerating their blood at a rate of 2 units per second. \
		Will not consume nanites while the host has a safe blood level."
	id = "bloodheal_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/blood_restoring

/datum/design/nanites/repairing
	name = "Mechanical Repair"
	desc = "The nanites fix damage in the host's mechanical limbs, healing 1 brute and 1 burn per second. \
		Will not consume nanites while the host's mechanical limbs are undamaged, or while the host has no mechanical limbs."
	id = "repairing_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/repairing

/datum/design/nanites/defib
	name = "Defibrillation"
	desc = "The nanites, when triggered, send a defibrillating shock to the host's heart."
	id = "defib_nanites"
	category = list(NANITE_CATEGORY_MEDICAL)
	program_type = /datum/nanite_program/defib
