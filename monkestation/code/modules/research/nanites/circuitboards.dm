/obj/item/circuitboard/computer/nanite_chamber_control
	name = "Nanite Chamber Control"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/nanite_chamber_control

/obj/item/circuitboard/computer/nanite_cloud_controller
	name = "Nanite Cloud Control"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/computer/nanite_cloud_controller

/obj/item/circuitboard/machine/nanite_chamber
	name = "Nanite Chamber"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_chamber
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/machine/nanite_program_hub
	name = "Nanite Program Hub"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_program_hub
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/machine/nanite_programmer
	name = "Nanite Programmer"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/nanite_programmer
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/scanning_module = 1,
	)
