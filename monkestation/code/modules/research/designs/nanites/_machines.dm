/datum/design/board/nanite_chamber_control
	name = "Nanite Chamber Control"
	desc = "Allows for the construction of circuit boards used to build a new nanite chamber control console."
	id = "nanite_chamber_control"
	build_path = /obj/item/circuitboard/computer/nanite_chamber_control
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_cloud_control
	name = "Nanite Cloud Control"
	desc = "Allows for the construction of circuit boards used to build a new nanite cloud control console."
	id = "nanite_cloud_control"
	build_path = /obj/item/circuitboard/computer/nanite_cloud_controller
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_RESEARCH
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_chamber
	name = "Machine Design (Nanite Chamber Board)"
	desc = "The circuit board for a Nanite Chamber."
	id = "nanite_chamber"
	build_path = /obj/item/circuitboard/machine/nanite_chamber
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_programmer
	name = "Machine Design (Nanite Programmer Board)"
	desc = "The circuit board for a Nanite Programmer."
	id = "nanite_programmer"
	build_path = /obj/item/circuitboard/machine/nanite_programmer
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/nanite_program_hub
	name = "Machine Design (Nanite Program Hub Board)"
	desc = "The circuit board for a Nanite Program Hub."
	id = "nanite_program_hub"
	build_path = /obj/item/circuitboard/machine/nanite_program_hub
	category = list(RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
