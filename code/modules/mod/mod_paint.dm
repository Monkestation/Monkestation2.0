#define MODPAINT_MAX_COLOR_VALUE 1.25
#define MODPAINT_MIN_COLOR_VALUE 0
#define MODPAINT_MAX_SECTION_COLORS 2
#define MODPAINT_MIN_SECTION_COLORS 0.25
#define MODPAINT_MAX_OVERALL_COLORS 4
#define MODPAINT_MIN_OVERALL_COLORS 1.5

/obj/item/mod/paint
	name = "Robotics paint kit"
	desc = "This kit will allow you to repaint IPCs, robotic limbs, and MODsuits into something unique."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "paintkit"
	var/obj/item/mod/control/editing_mod
	var/atom/movable/screen/map_view/proxy_view
	var/list/current_color

/obj/item/mod/paint/Initialize(mapload)
	. = ..()
	current_color = COLOR_MATRIX_IDENTITY

/obj/item/mod/paint/examine(mob/user)
	. = ..()

	. += span_notice("<b>Left-click</b> a MODsuit.")
	. += span_notice("<b>Right-click</b> a MODsuit or robotic limb to recolor.")

/obj/item/mod/paint/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers) //do stuff before attackby!
	if((user.istate & ISTATE_HARM))
		return ..()
	if(isipc(target))
		color_ipc(target, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/mod/paint/pre_attack_secondary(atom/target, mob/living/user, params)
	if((user.istate & ISTATE_HARM))
		return ..()
	if(isbodypart(target))
		if(color_limb(target, user))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/mod/paint/ui_interact(mob/user, datum/tgui/ui)
	if(!editing_mod)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODpaint", name)
		ui.open()
		proxy_view.display_to(user, ui.window)

/obj/item/mod/paint/ui_host()
	return editing_mod

/obj/item/mod/paint/ui_close(mob/user)
	. = ..()
	editing_mod = null
	QDEL_NULL(proxy_view)
	current_color = COLOR_MATRIX_IDENTITY

/obj/item/mod/paint/ui_status(mob/user)
	if(check_menu(editing_mod, user))
		return ..()
	return UI_CLOSE

/obj/item/mod/paint/ui_static_data(mob/user)
	var/list/data = list()
	data["mapRef"] = proxy_view.assigned_map
	return data

/obj/item/mod/paint/ui_data(mob/user)
	var/list/data = list()
	data["currentColor"] = current_color
	return data

/obj/item/mod/paint/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("transition_color")
			current_color = params["color"]
			animate(proxy_view, time = 0.5 SECONDS, color = current_color)
		if("confirm")
			if(length(current_color) != 20) //20 is the length of a matrix identity list
				return
			for(var/color_value in current_color)
				if(isnum(color_value))
					continue
				return
			var/total_color_value = 0
			var/list/total_colors = current_color.Copy()
			total_colors.Cut(13, length(total_colors)) // 13 to 20 are just a and c, dont want to count them
			var/red_value = current_color[1] + current_color[5] + current_color[9] //rr + gr + br
			var/green_value = current_color[2] + current_color[6] + current_color[10] //rg + gg + bg
			var/blue_value = current_color[3] + current_color[7] + current_color[11] //rb + gb + bb
			if(red_value > MODPAINT_MAX_SECTION_COLORS)
				balloon_alert(usr, "total red too high! ([red_value*100]%/[MODPAINT_MAX_SECTION_COLORS*100]%)")
				return
			else if(red_value < MODPAINT_MIN_SECTION_COLORS)
				balloon_alert(usr, "total red too low! ([red_value*100]%/[MODPAINT_MIN_SECTION_COLORS*100]%)")
				return
			if(green_value > MODPAINT_MAX_SECTION_COLORS)
				balloon_alert(usr, "total green too high! ([green_value*100]%/[MODPAINT_MAX_SECTION_COLORS*100]%)")
				return
			else if(green_value < MODPAINT_MIN_SECTION_COLORS)
				balloon_alert(usr, "total green too low! ([green_value*100]%/[MODPAINT_MIN_SECTION_COLORS*100]%)")
				return
			if(blue_value > MODPAINT_MAX_SECTION_COLORS)
				balloon_alert(usr, "total blue too high! ([blue_value*100]%/[MODPAINT_MAX_SECTION_COLORS*100]%)")
				return
			else if(blue_value < MODPAINT_MIN_SECTION_COLORS)
				balloon_alert(usr, "total blue too low! ([blue_value*100]%/[MODPAINT_MIN_SECTION_COLORS*100]%)")
				return
			for(var/color_value in total_colors)
				total_color_value += color_value
				if(color_value > MODPAINT_MAX_COLOR_VALUE)
					balloon_alert(usr, "one of colors too high! ([color_value*100]%/[MODPAINT_MAX_COLOR_VALUE*100]%")
					return
				else if(color_value < MODPAINT_MIN_COLOR_VALUE)
					balloon_alert(usr, "one of colors too low! ([color_value*100]%/[MODPAINT_MIN_COLOR_VALUE*100]%")
					return
			if(total_color_value > MODPAINT_MAX_OVERALL_COLORS)
				balloon_alert(usr, "total colors too high! ([total_color_value*100]%/[MODPAINT_MAX_OVERALL_COLORS*100]%)")
				return
			else if(total_color_value < MODPAINT_MIN_OVERALL_COLORS)
				balloon_alert(usr, "total colors too low! ([total_color_value*100]%/[MODPAINT_MIN_OVERALL_COLORS*100]%)")
				return
			editing_mod.set_mod_color(current_color)
			SStgui.close_uis(src)

/obj/item/mod/paint/proc/paint_skin(obj/item/mod/control/mod, mob/user)
	if(length(mod.theme.skins) <= 1)
		balloon_alert(user, "no alternate skins!")
		return
	var/list/skins = list()
	for(var/mod_skin in mod.theme.skins)
		skins[mod_skin] = image(icon = mod.icon, icon_state = "[mod_skin]-control")
	var/pick = show_radial_menu(user, mod, skins, custom_check = CALLBACK(src, PROC_REF(check_menu), mod, user), require_near = TRUE)
	if(!pick)
		balloon_alert(user, "no skin picked!")
		return
	mod.set_mod_skin(pick)

/obj/item/mod/paint/proc/check_menu(obj/item/mod/control/mod, mob/user)
	if(user.incapacitated() || !user.is_holding(src) || !mod || mod.active || mod.activating)
		return FALSE
	return TRUE

/obj/item/mod/paint/proc/color_limb(obj/item/bodypart/limb, mob/living/user)
	if(!IS_ROBOTIC_LIMB(limb))
		return FALSE

	var/list/skins = list()
	var/static/list/style_list_icons = list(
		"standard" = 'icons/mob/augmentation/augments.dmi',
		"engineer" = 'icons/mob/augmentation/augments_engineer.dmi',
		"security" = 'icons/mob/augmentation/augments_security.dmi',
		"mining" = 'icons/mob/augmentation/augments_mining.dmi',
		)

	for(var/skin_option in style_list_icons)
		var/image/part_image = image(icon = style_list_icons[skin_option], icon_state = "[limb.limb_id]_[limb.body_zone]")
		if(limb.aux_zone) //Hands
			part_image.overlays += image(icon = style_list_icons[skin_option], icon_state = "[limb.limb_id]_[limb.aux_zone]")
		skins += list("[skin_option]" = part_image)
	var/choice = show_radial_menu(user, src, skins, require_near = TRUE)
	if(choice)
		playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)
		limb.change_appearance(style_list_icons[choice], greyscale = FALSE)
	return TRUE

/obj/item/mod/paint/proc/color_ipc(mob/living/carbon/target, mob/living/user)
	var/reskin = tgui_input_list(user, "Which chassis do you want to use?", "Chassis Change", GLOB.ipc_chassis_list)
	var/color_choice = tgui_color_picker(user, "Which color do you want your Chassis to be", "Color Change")
	if(!reskin)
		return
	if(!color_choice)
		return
	target.dna.features["ipc_chassis"] = reskin
	for(var/obj/item/bodypart/bodypart as anything in target.bodyparts) //Override bodypart data as necessary
		if(QDELETED(bodypart))
			return
		bodypart.update_limb()

#undef MODPAINT_MAX_COLOR_VALUE
#undef MODPAINT_MIN_COLOR_VALUE
#undef MODPAINT_MAX_SECTION_COLORS
#undef MODPAINT_MIN_SECTION_COLORS
#undef MODPAINT_MAX_OVERALL_COLORS
#undef MODPAINT_MIN_OVERALL_COLORS

/obj/item/mod/skin_applier
	name = "MOD skin applier"
	desc = "This one-use skin applier will add a skin to MODsuits of a specific type."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"
	var/compatible_theme = /datum/mod_theme

/obj/item/mod/skin_applier/Initialize(mapload)
	. = ..()
	name = "MOD [skin] skin applier"

/obj/item/mod/skin_applier/interact_with_atom(atom/attacked_atom, mob/living/user, params)
	if(!istype(attacked_atom, /obj/item/mod/control))
		return NONE
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "unit active!")
		return ITEM_INTERACT_BLOCKING
	if(!istype(mod.theme, compatible_theme))
		balloon_alert(user, "incompatible theme!")
		return ITEM_INTERACT_BLOCKING
	mod.set_mod_skin(skin)
	balloon_alert(user, "skin applied")
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/mod/skin_applier/honkerative
	skin = "honkerative"
	compatible_theme = /datum/mod_theme/syndicate
