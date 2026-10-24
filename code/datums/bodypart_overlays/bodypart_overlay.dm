///Bodypart ovarlay datum. These can be added to any limb to give them a proper overlay, that'll even stay if the limb gets removed
///This is the abstract parent, don't use it!!
/datum/bodypart_overlay
	/**
	 * Assoc list [icon state postfix] to [layer of overlay].
	 *
	 * For simple overlays this will be a list of one element,
	 * but for more complicated overlays, this can be any number of component layers.
	 *
	 * Example:
	 * layers = list("front" = BODY_LAYER_FRONT) // - one layer, with icon state "[iconstate]_front"
	 * layers = list("adjacent" = BODY_LAYER_ADJACENT, "behind" = BODY_LAYER_BEHIND) // - two layers, one is "[iconstate]_adjacent", the other is "[iconstate]_behind"
	 * layers = list("layer1" = BODY_LAYER_ADJACENT, "layer2" = BODY_LAYER_BEHIND) // - two layers, with icon states "[iconstate]_layer1" and "[iconstate]_layer2"
	 * layers = list("" = BODY_LAYER_FRONT) // - one layer, with icon state "[iconstate]"
	 *
	 * This is cached, so be careful editing it at runtime (use the helpers!)
	 */
	VAR_PROTECTED/list/layers
	/// Flags that determine how the overlay is handled by the bodypart.
	var/overlay_flags = LIMB_OVERLAY_TEXTURED

	///Key of the icon states of all the sprite_datums for easy caching
	var/cache_key = ""
	///our color palette
	var/datum/color_palette/palette
	///our palette key
	var/palette_key
	///our fallback key
	var/fallback_key
	///list of palette keys to colors used if the accessory says it needs multiple colors
	var/list/color_keys

/datum/bodypart_overlay/New()
	. = ..()
	set_layers(layers)

/// Used for adding a layer at runtime
/datum/bodypart_overlay/proc/set_layer(layer_postfix, layer_number)
	var/list/existing_layers = LAZYCOPY(layers)
	existing_layers[layer_postfix] = layer_number
	layers = string_assoc_list(existing_layers)

/// Used for adding a layer at runtime without replacing existing layers
/datum/bodypart_overlay/proc/add_layer(layer_postfix, layer_number)
	if(isnull(LAZYACCESS(layers, layer_postfix)))
		set_layer(layer_postfix, layer_number)

/// Used for adding layers at runtime
/datum/bodypart_overlay/proc/set_layers(list/layer_list)
	if(!length(layer_list))
		return

	layers = string_assoc_list(layer_list)

/// Used for removing layers at runtime
/datum/bodypart_overlay/proc/clear_layer(layer_postfix)
	var/list/existing_layers = LAZYCOPY(layers)
	existing_layers -= layer_postfix
	if(!length(existing_layers))
		layers = null
		return

	layers = string_assoc_list(existing_layers)

/**
 * Returns a list of overlays that this overlay datum draws
 *
 * * limb: the limb we're drawing onto
 *
 * Returns an assoc list of images/mutable appearances to their overlay flags
 */
/datum/bodypart_overlay/proc/get_all_overlays(obj/item/bodypart/limb)
	var/list/overlays = list()
	for(var/overlay_postfix, overlay_layer in layers)
		overlays[get_overlay(limb, overlay_postfix, -overlay_layer)] = overlay_flags
		var/emissive_overlay = get_emissive_overlay(limb, overlay_postfix, -overlay_layer)
		if(emissive_overlay)
			overlays[emissive_overlay] = LIMB_OVERLAY_META
		var/secondary_overlay = get_secondary_overlay(limb, overlay_postfix, -overlay_layer)
		if(secondary_overlay)
			overlays[secondary_overlay] = overlay_flags
		for(var/image/extended_overlay as anything in get_extended_overlay(limb, overlay_postfix, -overlay_layer))
			overlays[extended_overlay] = PLANE_TO_TRUE(extended_overlay.plane) == EMISSIVE_PLANE ? LIMB_OVERLAY_META : overlay_flags
	return overlays

/**
 * Handles generating an individual overlay
 *
 * * limb: the limb we're drawing onto, can be null if we're just drawing a general overlay for the mob and not a specific limb
 * * layer_index: the index of the layer we're drawing on, used for generating the image
 * * layer_real: the actual layer we're drawing on, used for generating the image
 *
 * Returns an image/mutable appearance
 */
/datum/bodypart_overlay/proc/get_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	PROTECTED_PROC(TRUE)
	. = get_image(limb, layer_index, layer_real)
	color_image(., limb, layer_index)

/// Returns an emissive overlay to draw along with the main one, if we have one
/datum/bodypart_overlay/proc/get_emissive_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	PROTECTED_PROC(TRUE)
	return

/// Returns a secondary overlay to draw along with the main one, like inner ears, if we have one
/datum/bodypart_overlay/proc/get_secondary_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	PROTECTED_PROC(TRUE)
	. = get_image_inner(limb, layer_index, layer_real)

/// Returns a list of extra overlays to draw along with the main one, if we have any
/datum/bodypart_overlay/proc/get_extended_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	PROTECTED_PROC(TRUE)
	return

/**
 * The actual proc where images / mutable appearances are generated for get_overlay
 * Must be implemented by subtypes, at its simplest it should just return an image
 *
 * * limb: the limb we're drawing onto, can be null if we're just drawing a general overlay for the mob and not a specific limb
 * * layer_index: the index of the layer we're drawing on.
 * Typically some postfix for an icon state ie. "front" or "behind" (Used like "overlay_front" or "overlay_behind"
 * * layer_real: the actual layer we're drawing on, used for generating the image.
 * Some (negative) number like -10 to -30. (Used like layer = layer_real, you shouldn't need to mess with it.)
 *
 * Returns an image/mutable appearance to draw on the mob.
 */
/datum/bodypart_overlay/proc/get_image(obj/item/bodypart/limb, layer_index, layer_real)
	CRASH("Get image needs to be overridden")

/// Generates the image for get_secondary_overlay, FALSE if we don't have one
/datum/bodypart_overlay/proc/get_image_inner(obj/item/bodypart/limb, layer_index, layer_real)
	return FALSE

/**
 * Used to color the image, if necessary.
 * By default it does nothing.
 *
 * * image: the image generated by get_image() that we want to color
 * * limb: the limb we're drawing onto, can be null if we're just drawing a general overlay for the mob and not a specific limb.
 * * layer_index: the index of the layer we're drawing on, used for generating the image.
 */
/datum/bodypart_overlay/proc/color_image(image/overlay, obj/item/bodypart/limb, layer_index)
	return

/// Called on being added to a limb.
/datum/bodypart_overlay/proc/added_to_limb(obj/item/bodypart/limb)
	return

/// Called on being removed from a limb.
/datum/bodypart_overlay/proc/removed_from_limb(obj/item/bodypart/limb)
	return

/**
 * Used by subtypes to change the appearance of the overlay.
 * Typically implemented in tandem with a sprite accessory.
 */
/datum/bodypart_overlay/proc/set_appearance()
	CRASH("Update appearance needs to be overridden")

///Check whether we can draw the overlays. You generally don't want lizard snouts to draw over an EVA suit
/datum/bodypart_overlay/proc/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	return TRUE

///Colorizes the limb it's inserted to, if required.
/datum/bodypart_overlay/proc/override_color(obj/item/bodypart/bodypart_owner)
	CRASH("External organ color set to override with no override proc.")

///Generate a unique identifier to cache with. If you change something about the image, but the icon cache stays the same, it'll simply pull the unchanged image out of the cache
/datum/bodypart_overlay/proc/generate_icon_cache()
	return list()
