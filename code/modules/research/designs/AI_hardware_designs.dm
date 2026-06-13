/datum/design/ram
	name = "RAM design"
	desc = "This is a bug!"
	id = "default_ram"
	build_type = RACK_CREATOR
	category = list()
	research_icon ='icons/obj/module.dmi'
	research_icon_state = "std_mod"
	materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT)

	var/capacity = 0

/datum/design/ram/ram1
	name = "standard memory"
	desc = "Salvaged from decommisioned experiments at NT-CONLAB."
	id = "ram1"
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 1

/datum/design/ram/ram2
	name = "high-capacity memory"
	desc = "Further refinements allow high-capacity memory at normal performance."
	id = "ram2"
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 2

/datum/design/ram/ram3
	name = "hyper-capacity memory"
	desc = "Understanding and manipulation of near-atomic matter allows increased capacity with no noticeable performance degradation."
	id = "ram3"
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 3

/datum/design/ram/ram4
	name = "bluespace memory"
	desc = "Using bluespace based technology it's possible to make increase RAM capacity without decreasing speed."
	id = "ram4"
	materials = list(
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 8,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/bluespace = SHEET_MATERIAL_AMOUNT,
	)
	capacity = 4

/datum/design/cpu_basic
	name = "neural processing unit"
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
	name = "advanced neural processing unit"
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
	name = "bluespace neural processing unit"
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
	name = "experimental neural processing unit"
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
