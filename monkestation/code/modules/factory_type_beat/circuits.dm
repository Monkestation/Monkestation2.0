/obj/item/circuitboard/machine/brm
	name = "Boulder Retrieval Matrix"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/brm
	req_components = list(
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/big_manipulator
	name = "Big Manipulator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/big_manipulator
	req_components = list(
		/datum/stock_part/manipulator = 1,
		)

/obj/item/circuitboard/machine/assembler
	name = "Assembler"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/assembler
	req_components = list(
		/datum/stock_part/manipulator = 1,
		)
