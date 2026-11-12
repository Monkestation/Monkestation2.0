/datum/bodypart_overlay/mutant/get_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	inherit_color(limb)
	if(sprite_datum.layers)
		var/mutable_appearance/MA = mutable_appearance(layer = layer_real)
		for(var/state in sprite_datum.layers)
			var/mutable_appearance/returned = get_image(limb, layer_index, layer_real, state)
			color_image(returned, limb, layer_index, sprite_datum.layers[state])
			MA.overlays += returned
		return MA
	else
		. = get_image(limb, layer_index, layer_real)
		color_image(., limb, layer_index)

///Get the image we need to draw on the person. Called from get_overlay() which is called from _bodyparts.dm. Limb can be null
/datum/bodypart_overlay/mutant/get_image(obj/item/bodypart/limb, layer_index, layer_real, layer_name)
	if(!sprite_datum)
		CRASH("Trying to call get_image() on [type] while it didn't have a sprite_datum. This shouldn't happen, report it as soon as possible.")

	var/gender = (limb?.limb_gender == FEMALE) ? "f" : "m"
	var/list/icon_state_builder = list()
	icon_state_builder += sprite_datum.gender_specific ? gender : "m" //Male is default because sprite accessories are so ancient they predate the concept of not hardcoding gender
	if(layer_name)
		icon_state_builder += layer_name
	icon_state_builder += feature_key
	icon_state_builder += get_base_icon_state()
	icon_state_builder += layer_index

	var/finished_icon_state = icon_state_builder.Join("_")

	var/mutable_appearance/appearance = mutable_appearance(sprite_datum.icon, finished_icon_state, layer = layer_real)

	if(sprite_datum.center)
		center_image(appearance, sprite_datum.dimension_x, sprite_datum.dimension_y)

	return appearance

/datum/bodypart_overlay/mutant/color_image(image/overlay, obj/item/bodypart/limb, layer_index, key_name)
	if(!key_name)
		overlay.color = sprite_datum.color_src ? draw_color : null
	else
		var/datum/color_palette/located = limb?.owner?.dna?.color_palettes[palette]
		overlay.color = located.return_color(key_name, fallback_key)
