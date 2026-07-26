/obj/machinery/modular_computer/preset/mining
	name = "mining console"
	desc = "A stationary computer. This one comes preloaded with programs to monitor the lavaland mining operation."
	starting_programs = list(
		/datum/computer_file/program/secureye/mining,
	)

/obj/machinery/modular_computer/preset/mining/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/secureye/mining/cams = locate() in cpu.stored_files
	cpu.open_program(null, cams, FALSE)

/datum/computer_file/program/secureye/mining
	filename = "mineeye"
	filedesc = "MineEye"
	extended_desc = "This program allows access to the lavaland base networks, discontinued due to its limited uses."
	download_access = list()
	program_flags = NONE
	network = list(
		CAMERANET_NETWORK_MINE,
	)
