/obj/item/clothing/head/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/service/janitor.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "cone"
	inhand_icon_state = null
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("warns", "cautions", "smashes")
	attack_verb_simple = list("warn", "caution", "smash")
	resistance_flags = NONE
	hat_stack_name = FALSE
	random_hat_stack_x_offset = FALSE
	hat_stack_y_offset_modifier = 0.33

/obj/item/clothing/head/cone/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

/obj/item/clothing/head/cone/interact_with_atom(atom/movable/interacting_with, mob/living/user, list/modifiers)
	if(!isturf(interacting_with) || isgroundlessturf(interacting_with))
		return NONE
	var/turf/zoned_turf = interacting_with

	if(zoned_turf.density)
		return NONE

	var/obj/item/clothing/head/cone/selected_cone = locate() in contents
	if(!selected_cone)
		selected_cone = src
	if(!(user.dropItemToGround(selected_cone)))
		return NONE
	var/clickx
	var/clicky

	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		clickx = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X/2), ICON_SIZE_X/2)
		clicky = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(ICON_SIZE_Y/2), ICON_SIZE_Y/2)

	selected_cone.forceMove(zoned_turf)
	selected_cone.pixel_x = clickx
	selected_cone.pixel_y = clicky
	update_hats()

	playsound(selected_cone, 'sound/items/cardboard_tube.ogg', 100, TRUE, -3)
	return ITEM_INTERACT_SUCCESS
