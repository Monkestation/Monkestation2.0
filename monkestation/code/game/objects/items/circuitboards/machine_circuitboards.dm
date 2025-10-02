/obj/item/circuitboard/machine/rad_collector
	name = "Radiation Collector (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	desc = "Comes with a small amount solder of arranged in the corner: \"If you can read this, you're too close.\""
	build_path = /obj/machinery/power/rad_collector
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/manipulator = 1)
	needs_anchored = FALSE


/obj/item/circuitboard/machine/clonepod	//hippie start, re-add cloning
	name = "Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/scanning_module = 2,
		/datum/stock_part/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/clonepod/experimental
	name = "Experimental Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod/experimental

/obj/item/circuitboard/machine/clonescanner	//hippie end, re-add cloning
	name = "Cloning Scanner (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bomb_actualizer
	name = "Bomb Actualizer (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/bomb_actualizer
	req_components = list(
		/datum/stock_part/manipulator = 1,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/matter_bin = 5)

/obj/item/circuitboard/machine/composters
	name = "NT-Brand Auto Composter (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/composters
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/manipulator = 1,
	)

/obj/item/circuitboard/machine/splicer
	name = "Splicer (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/splicer
	req_components = list(
		/datum/stock_part/manipulator = 1,
	)

/obj/item/circuitboard/machine/cyborgrecharger/fullupgrade
	name = "Cyborg Recharger"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/recharge_station/fullupgrade
	req_components = list(
		/datum/stock_part/capacitor/tier4 = 2,
		/obj/item/stock_parts/power_store/cell = 1,
		/datum/stock_part/manipulator/tier4 = 1)
	def_components = list(/obj/item/stock_parts/power_store/cell = /obj/item/stock_parts/power_store/cell/bluespace)
