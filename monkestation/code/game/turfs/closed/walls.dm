/turf/closed/wall/material/silk
	name = "silk wall"
	desc = "A silk wall reinforced with iron, still weaker than an iron wall."
	icon = 'monkestation/icons/turf/walls/silk_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	sheet_type = /obj/item/stack/sheet/silk
	hardness = 80
	explosive_resistance = 0
	max_integrity = 100
	damage_deflection = 5
	custom_materials = list(/datum/material/silk = SHEET_MATERIAL_AMOUNT*2)
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SILK_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SILK_WALLS

/obj/structure/falsewall/silk
	name = "silk wall"
	desc = "A silk wall reinforced with iron, still weaker than an iron wall."
	icon = 'monkestation/icons/turf/walls/silk_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	mineral = /obj/item/stack/sheet/silk
	walltype = /turf/closed/wall/material/silk
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SILK_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SILK_WALLS
