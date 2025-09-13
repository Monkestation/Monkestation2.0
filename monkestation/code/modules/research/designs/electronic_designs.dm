/datum/design/pocket_heater
	name = "Pocket Heater"
	desc = "A highly compact electronic heater that fits in your pocket."
	id = "pocket_heater"
	build_path = /obj/item/pocket_heater
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/gold = SMALL_MATERIAL_AMOUNT*5)
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MISC,
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO
