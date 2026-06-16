/datum/design/ram
	id = DESIGN_ID_IGNORE
	build_type = RACK_CREATOR
	category = list()
	research_icon ='icons/obj/module.dmi'
	research_icon_state = "std_mod"
	materials = list()
	var/capacity = 0
	var/list/ram_materials

/datum/design/ram/ram1
	name = "Standard Memory"
	desc = "Salvaged from decommisioned experiments at NT-CONLAB."
	id = "ram1"
	ram_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 1

/datum/design/ram/ram2
	name = "High-capacity Memory"
	desc = "Further refinements allow high-capacity memory at normal performance."
	id = "ram2"
	ram_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 2

/datum/design/ram/ram3
	name = "Hyper-capacity Memory"
	desc = "Understanding and manipulation of near-atomic matter allows increased capacity with no noticeable performance degradation."
	id = "ram3"
	ram_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 3

/datum/design/ram/ram4
	name = "Bluespace Memory"
	desc = "Using bluespace based technology it's possible to make increase RAM capacity without decreasing speed."
	id = "ram4"
	ram_materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 4

/datum/design/cpu_basic
	name = "Neural Processing Unit"
	id = "basic_ai_cpu"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ai_cpu
	construction_time = 5 SECONDS
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENTAL_BITFLAG_NETMIN

/datum/design/cpu_advanced
	name = "Advanced Neural Processing Unit"
	id = "advanced_ai_cpu"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ai_cpu/advanced
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENTAL_BITFLAG_NETMIN

/datum/design/cpu_bluespace
	name = "Bluespace Neural Processing Unit"
	id = "bluespace_ai_cpu"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/ai_cpu/bluespace
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENTAL_BITFLAG_NETMIN

/datum/design/cpu_experimental
	name = "Experimental Neural Processing Unit"
	id = "experimental_ai_cpu"
	build_type = IMPRINTER
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 6,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 6,
	)
	build_path = /obj/item/ai_cpu/experimental
	construction_time = 7.5 SECONDS
	category = list(
		RND_CATEGORY_MODULAR_COMPUTERS + RND_SUBCATEGORY_MODULAR_COMPUTERS_PARTS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENTAL_BITFLAG_NETMIN
