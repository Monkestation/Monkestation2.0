/datum/design/shield_belt
	name = "Shield Belt"
	desc = "A prototype energy shield belt that can deflect ranged projectiles, requires a flux core to operate."
	id = "shield_belt"
	build_type = PROTOLATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/shield_belt
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_MELEE,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
