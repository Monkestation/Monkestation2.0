/datum/design/nifsoft_hud/cargo
	name = "Permit HUD NIFSoft"
	desc = "A NIFSoft datadisk containing the Permit HUD NIFsoft."
	id = "nifsoft_hud_cargo"
	build_path = /obj/item/disk/nifsoft_uploader/permit_hud
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/nifsoft_money_sense
	name = "Automatic Appraisal NIFSoft"
	desc = "A NIFSoft datadisk containing the Automatic Appraisal NIFsoft."
	id = "nifsoft_money_sense"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/disk/nifsoft_uploader/money_sense
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_CARGO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/design/lavarods
	name = "Lava-Resistant Iron Rods"
	id = "lava_rods"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT, /datum/material/plasma=SMALL_MATERIAL_AMOUNT*5, /datum/material/titanium=SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/rods/lava
	category = list(
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_MATERIALS
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/board/union_stand
	name = "Union Stand Board"
	desc = "The circuit board for a Union Stand."
	id = "union_stand"
	build_path = /obj/item/circuitboard/machine/union_stand
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_ENGINEERING
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO | DEPARTMENT_BITFLAG_ENGINEERING
