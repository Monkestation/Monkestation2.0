/datum/design/nanites/sensor_health
	name = "Health Sensor"
	desc = "The nanites receive a signal when the host's health is above/below a certain percentage."
	id = "sensor_health_nanites"
	category = list(NANITES_CATEGORY_SENSOR)
	program_type = /datum/nanite_program/sensor/health

/datum/design/nanites/sensor_damage
	name = "Damage Sensor"
	desc = "The nanites receive a signal when a host's specific damage type is above/below a target value."
	id = "sensor_damage_nanites"
	category = list(NANITES_CATEGORY_SENSOR)
	program_type = /datum/nanite_program/sensor/damage

/datum/design/nanites/sensor_crit
	name = "Critical Health Sensor"
	desc = "The nanites receive a signal when the host first reaches critical health."
	id = "sensor_crit_nanites"
	category = list(NANITES_CATEGORY_SENSOR)
	program_type = /datum/nanite_program/sensor/crit

/datum/design/nanites/sensor_death
	name = "Death Sensor"
	desc = "The nanites receive a signal when they detect the host is dead."
	id = "sensor_death_nanites"
	category = list(NANITES_CATEGORY_SENSOR)
	program_type = /datum/nanite_program/sensor/death

/datum/design/nanites/sensor_voice
	name = "Voice Sensor"
	desc = "Sends a signal when the nanites hear a determined word or sentence."
	id = "sensor_voice_nanites"
	category = list(NANITES_CATEGORY_SENSOR)
	program_type = /datum/nanite_program/sensor/voice

/datum/design/nanites/sensor_nanite_volume
	name = "Nanite Volume Sensor"
	desc = "The nanites receive a signal when the nanite supply is above/below a certain percentage."
	id = "sensor_nanite_volume"
	category = list(NANITES_CATEGORY_SENSOR)
	program_type = /datum/nanite_program/sensor/nanite_volume

/datum/design/nanites/sensor_species
	name = "Species Sensor"
	desc = "When triggered, the nanites scan the host to determine their species and output a signal depending on the conditions set in the settings."
	id = "sensor_species_nanites"
	category = list(NANITES_CATEGORY_SENSOR)
	program_type = /datum/nanite_program/sensor/species
