/obj/item/modular_computer/pda/security/brig_physician
	name = "brig physician PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#A52F29#0000CC#918F8C"
	starting_programs = list(
		/datum/computer_file/program/records/security,
	/datum/computer_file/program/records/medical,
	/datum/computer_file/program/crew_manifest,
	/datum/computer_file/program/robocontrol,
	/datum/computer_file/program/radar/lifeline // For finding security officers
	)

/obj/item/modular_computer/pda/signal
	name = "signal PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#0EC220#727272"
	starting_programs = list()
