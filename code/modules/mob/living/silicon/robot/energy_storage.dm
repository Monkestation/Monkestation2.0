/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy
	///Whether this resource should refill from the aether inside a charging station.
	var/renewable = TRUE
	var/datum/material/mat_type

/datum/robot_energy_storage/New(datum/robot_model/model)
	energy = max_energy
	if(model)
		model.energy_storages |= src
		RegisterSignal(model.cyborg_owner, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))
		RegisterSignal(model, COMSIG_QDELETING, PROC_REF(unregister_from_model))

/datum/robot_energy_storage/proc/unregister_from_model(datum/robot_model/model)
	SIGNAL_HANDLER
	if(model)
		model.energy_storages -= src
		UnregisterSignal(model.cyborg_owner, COMSIG_MOB_GET_STATUS_TAB_ITEMS)

/datum/robot_energy_storage/proc/get_status_tab_item(mob/living/silicon/robot/source, list/items)
	SIGNAL_HANDLER
	items += "[name]: [energy]/[max_energy]"

/datum/robot_energy_storage/proc/use_charge(amount)
	if(energy < amount)
		return FALSE
	energy = clamp(energy, 0, energy - amount)
	return TRUE

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/iron
	name = "Iron Synthesizer"
	renewable = FALSE
	mat_type = /datum/material/iron

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"
	renewable = FALSE
	mat_type = /datum/material/glass

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"

/datum/robot_energy_storage/medical
	max_energy = 2500
	recharge_rate = 250
	name = "Medical Synthesizer"

/datum/robot_energy_storage/beacon
	max_energy = 30
	recharge_rate = 1
	name = "Marker Beacon Storage"

/datum/robot_energy_storage/pipe_cleaner
	max_energy = 50
	recharge_rate = 2
	name = "Pipe Cleaner Synthesizer"

/datum/robot_energy_storage/package_wrap
	name ="package wrapper synthetizer"
	max_energy = 25
	recharge_rate = 2

/datum/robot_energy_storage/wrapping_paper
	name ="wrapping paper synthetizer"
	max_energy = 25
	recharge_rate = 2
