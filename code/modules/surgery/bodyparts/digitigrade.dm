/obj/item/bodypart/leg/get_bodypart_damage_state()
	if(!(bodytype & BODYTYPE_DIGITIGRADE))
		return ..()
	. = ..()
	for(var/mutable_appearance/appearance in .)
		apply_digitigrade_filters(appearance, owner)
	return .


/obj/item/proc/apply_digitigrade_filters(mutable_appearance/appearance, mob/living/carbon/wearer = loc)
	if(!istype(wearer) || !(wearer.dna.species.bodytype & BODYTYPE_DIGITIGRADE))
		return

	var/static/list/masks_and_shading
	if(isnull(masks_and_shading))
		masks_and_shading = list(
			"[NORTH]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", NORTH),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", NORTH),
				"size"  = 1,
			),
			"[SOUTH]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", SOUTH),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", SOUTH),
				"size"  = 1,
			),
			"[EAST]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", EAST),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", EAST),
				"size" = 127,
			),
			"[WEST]" = list(
				"mask" = icon('icons/effects/digi_filters.dmi', "digi", WEST),
				"shading" = icon('icons/effects/digi_filters.dmi', "digi_shading", WEST),
				"size" = 127,
			),
		)

	var/dir_to_use = ISDIAGONALDIR(wearer.dir) ? (wearer.dir & (EAST|WEST)) : wearer.dir
	var/icon/icon_to_use = masks_and_shading["[dir_to_use]"]["mask"]
	var/icon/shading_to_use = masks_and_shading["[dir_to_use]"]["shading"]
	var/size = masks_and_shading["[dir_to_use]"]["size"]

	appearance.add_filter("Digitigrade", 1, displacement_map_filter(icon = icon_to_use, size = size))
	appearance.add_filter("Digitigrade_shading", 1, layering_filter(icon = shading_to_use, blend_mode = BLEND_MULTIPLY))
