/obj/item/bodypart/leg/proc/set_digitigrade(is_digi)
	if(is_digi)
		if(!can_be_digitigrade)
			return FALSE

		bodytype |= BODYTYPE_DIGITIGRADE
		. = TRUE
	else
		if(!(bodytype & BODYTYPE_DIGITIGRADE))
			return FALSE

		bodytype &= ~BODYTYPE_DIGITIGRADE
		if(old_limb_id)
			limb_id = old_limb_id
		. = TRUE

	if(.)
		if(owner)
			synchronize_bodytypes(owner)
			owner.update_body_parts()
		else
			update_icon_dropped()


/obj/item/bodypart/leg/update_limb(dropping_limb, is_creating)
	. = ..()
	if(!ishuman(owner) || !(bodytype & BODYTYPE_DIGITIGRADE))
		return

	var/mob/living/carbon/human/human_owner = owner
	var/uniform_compatible = FALSE
	var/suit_compatible = FALSE
	if(!(human_owner.w_uniform) || (human_owner.w_uniform.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON))) //Checks uniform compatibility
		uniform_compatible = TRUE
	if((!human_owner.wear_suit) || (human_owner.wear_suit.supports_variations_flags & (CLOTHING_DIGITIGRADE_VARIATION|CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON)) || !(human_owner.wear_suit.body_parts_covered & LEGS)) //Checks suit compatability
		suit_compatible = TRUE

	if((uniform_compatible && suit_compatible) || (suit_compatible && human_owner.wear_suit?.flags_inv & HIDEJUMPSUIT)) //If the uniform is hidden, it doesnt matter if its compatible
		old_limb_id = limb_id
		limb_id = digitigrade_id
	else
		limb_id = old_limb_id

/obj/item/bodypart/leg/get_bodypart_damage_state()
	if(!(bodytype & BODYTYPE_DIGITIGRADE))
		return ..()
	. = ..()
	for(var/mutable_appearance/appearance in .)
		apply_digitigrade_filters(appearance, owner, bodytype)
	return .


/obj/item/proc/apply_digitigrade_filters(mutable_appearance/appearance, mob/living/carbon/wearer = loc, bodytype)
	if(!istype(wearer) || !(bodytype & BODYTYPE_DIGITIGRADE))
		return

	var/static/list/icon/masks_and_shading
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
