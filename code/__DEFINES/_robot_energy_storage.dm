/// Stub datum for removed cyborg energy storage system - pre-defined for stack.dm compilation
/datum/robot_energy_storage
    var/energy = 0
    var/max_energy = 0

/datum/robot_energy_storage/proc/use_charge(amount)
    return FALSE

/datum/robot_energy_storage/proc/add_charge(amount)
    return

/datum/robot_energy_storage/iron
    max_energy = 5000

/datum/robot_energy_storage/glass
    max_energy = 5000

/datum/robot_energy_storage/medical
    max_energy = 5000

/datum/robot_energy_storage/wire
    max_energy = 5000

/datum/robot_energy_storage/beacon
    max_energy = 5000

/datum/robot_energy_storage/pipe_cleaner
    max_energy = 5000
