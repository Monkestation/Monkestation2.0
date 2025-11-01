
/datum/design/board/clonecontrol	//hippie start, re-add cloning
	name = "Cloning Machine Console"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	build_path = /obj/item/circuitboard/computer/cloning
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_GENETICS
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/clonepod
	name = "Clone Pod"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	build_path = /obj/item/circuitboard/machine/clonepod
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_GENETICS
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/clonepod_experimental
	name = "Experimental Clone Pod"
	desc = "Allows for the construction of circuit boards used to build an Experimental Cloning Pod."
	id = "clonepod_experimental"
	build_path = /obj/item/circuitboard/machine/clonepod/experimental
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_GENETICS
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE


/datum/design/board/clonescanner	//hippie end, re-add cloning
	name = "Cloning Scanner"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	build_path = /obj/item/circuitboard/machine/clonescanner
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_GENETICS
	)
	departmental_flags =  DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/bomb_actualizer
	name = "Bomb Actualizer Board"
	desc = "The circuit board for a bomb actualizing machine"
	id = "bomb_actualizer"
	build_path = /obj/item/circuitboard/machine/bomb_actualizer
	category = list(
	RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_RESEARCH
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/composters
	name = "NT-Brand Auto Composter Board"
	desc = "The circuit board for a NT-Brand Auto Composter."
	id = "composters"
	build_path = /obj/item/circuitboard/machine/composters
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_BOTANY
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/splicer
	name = "Splicer Board"
	desc = "The circuit board for a Splicer."
	id = "splicer"
	build_path = /obj/item/circuitboard/machine/splicer
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_BOTANY
	)
	departmental_flags =  DEPARTMENT_BITFLAG_SERVICE | DEPARTMENT_BITFLAG_ENGINEERING
