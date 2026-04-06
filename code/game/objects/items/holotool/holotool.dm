/obj/item/holotool
	name = "experimental holotool"
	desc = "A highly experimental holographic tool projector. Less efficient than its physical counterparts."
	icon = 'icons/obj/holotool.dmi'
	icon_state = "holotool"
	inhand_icon_state = "holotool"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/pshoom.ogg'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	actions_types = list(/datum/action/item_action/change_tool, /datum/action/item_action/change_ht_color)
	action_slots = ITEM_SLOT_HANDS | ITEM_SLOT_BELT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	light_system = OVERLAY_LIGHT
	light_outer_range = 3
	light_on = FALSE

	///List of all modes this holotool can use.
	var/static/list/datum/holotool_mode/possible_modes = list()
	///List of all emagged modes.
	var/static/list/datum/holotool_mode/emagged_modes = list()
	/// The current mode
	var/datum/holotool_mode/current_tool
	var/current_light_color = "#48D1CC" //mediumturquoise
	/// Buffer used by the multitool mode
	var/datum/weakref/buffer
	/// Component buffer
	var/datum/weakref/comp_buffer

/obj/item/holotool/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS|ITEM_SLOT_BELT)
	if(!length(possible_modes))
		build_listing()

/obj/item/holotool/proc/build_listing()
	for(var/datum/holotool_mode/mode as anything in subtypesof(/datum/holotool_mode))
		mode = new mode()
		var/image/holotool_img = image(icon = icon, icon_state = icon_state)
		var/image/tool_img = image(icon = icon, icon_state = mode::name)
		tool_img.color = current_light_color
		holotool_img.overlays += tool_img
		if(mode.requires_emag)
			emagged_modes[mode] = holotool_img
		else
			possible_modes[mode] = holotool_img

/obj/item/holotool/examine(mob/user)
	. = ..()
	. += span_notice("It is currently set to the [current_tool ? current_tool.name : "off"] mode.")
	if(tool_behaviour == TOOL_MULTITOOL)
		. += span_notice("Its buffer [buffer?.resolve() ? "contains [buffer.resolve()]." : "is empty."]")
	. += span_info("Attack self to select tool modes.")

// Welding tool repair is currently hardcoded and not based on tool behavior
/obj/item/holotool/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with) || user.istate & ISTATE_HARM)
		return NONE

	if(tool_behaviour == TOOL_WELDER)
		return try_heal_loop(interacting_with, user)

	return NONE

/obj/item/holotool/proc/try_heal_loop(atom/interacting_with, mob/living/user, repeating = FALSE)
	var/mob/living/carbon/human/attacked_humanoid = interacting_with
	var/obj/item/bodypart/affecting = attacked_humanoid.get_bodypart(check_zone(user.zone_selected))
	if(isnull(affecting) || !IS_ROBOTIC_LIMB(affecting))
		return NONE

	if (!affecting.brute_dam)
		balloon_alert(user, "limb not damaged")
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user] starts to fix some of the dents on [attacked_humanoid == user ? user.p_their() : "[attacked_humanoid]'s"] [affecting.name]."),
		span_notice("You start fixing some of the dents on [attacked_humanoid == user ? "your" : "[attacked_humanoid]'s"] [affecting.name]."))
	var/use_delay = repeating ? 1 SECONDS : 0
	if(user == attacked_humanoid)
		use_delay = 5 SECONDS

	if(!use_tool(attacked_humanoid, user, use_delay, volume=50, amount=1))
		return ITEM_INTERACT_BLOCKING

	if(!item_heal_robotic(attacked_humanoid, user, brute_heal = 15, burn_heal = 0))
		return ITEM_INTERACT_BLOCKING

	INVOKE_ASYNC(src, PROC_REF(try_heal_loop), interacting_with, user, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/holotool/use(used)
	SHOULD_CALL_PARENT(FALSE)
	return TRUE //it just always works, capiche!?

/obj/item/holotool/tool_use_check(mob/living/user, amount)
	return TRUE	//always has enough "fuel"

/obj/item/holotool/ui_action_click(mob/user, datum/action/action)
	if(istype(action, /datum/action/item_action/change_tool))
		return ..()
	else if(istype(action, /datum/action/item_action/change_ht_color))
		var/chosen_color = tgui_color_picker(user, "Select Color", "[src]", "#48D1CC")
		if(!chosen_color || QDELETED(src) || IS_DEAD_OR_INCAP(user) || !user.is_holding(src))
			return
		current_light_color = chosen_color
		set_light_color(current_light_color)
		update_appearance(UPDATE_ICON)

/obj/item/holotool/proc/switch_tool(mob/user, datum/holotool_mode/mode)
	if(!istype(mode))
		return
	current_tool?.on_unset(src)
	current_tool = mode
	current_tool.on_set(src)
	playsound(loc, 'sound/items/holotool.ogg', 100, 1, -1)
	update_appearance(UPDATE_ICON)

/obj/item/holotool/proc/return_usable_modes()
	return (obj_flags & EMAGGED) ? possible_modes + emagged_modes : possible_modes

// Handles color overlay of current holotool mode
/obj/item/holotool/update_overlays()
	. = ..()
	if(current_tool)
		var/mutable_appearance/holo_item = mutable_appearance(icon, current_tool.name)
		holo_item.color = current_light_color
		. += holo_item

/obj/item/holotool/update_icon_state()
	if(current_tool)
		inhand_icon_state = current_tool.name
	else
		inhand_icon_state = initial(inhand_icon_state)
	return ..()

/obj/item/holotool/update_icon(updates=ALL)
	. = ..()
	if(current_tool && !istype(current_tool, /datum/holotool_mode/off))
		set_light_on(TRUE)
	else
		set_light_on(FALSE)

	for(var/datum/action/A as anything in actions)
		A.build_all_button_icons()

/obj/item/holotool/proc/check_menu(mob/living/user)
	if(!istype(user) || user.incapacitated())
		return FALSE
	return TRUE

/obj/item/holotool/attack_self(mob/user)
	var/list/possible_choices = return_usable_modes()
	var/datum/holotool_mode/chosen = show_radial_menu(
		user = user,
		anchor = src,
		choices = possible_choices,
		custom_check = CALLBACK(src, PROC_REF(check_menu), user),
		require_near = TRUE,
	)
	if(isnull(chosen))
		return
	switch_tool(user, chosen)

/obj/item/holotool/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	to_chat(user, span_danger("ZZT- ILLEGAL BLUEPRINT UNLOCKED- CONTACT !#$@^%$# NANOTRASEN SUPPORT-@*%$^%!"))
	do_sparks(5, 0, src)
	obj_flags |= EMAGGED
	return TRUE

/*
 * Sets the multitool internal object buffer
 *
 * Arguments:
 * * buffer - the new object to assign to the multitool's buffer
 */
/obj/item/holotool/proc/set_buffer(datum/buffer)
	src.buffer = WEAKREF(buffer)

/**
 * Sets the holotool component buffer
 *
 * Arguments:
 * * buffer - the new object to assign to the holotool's component buffer
 */
/obj/item/holotool/proc/set_comp_buffer(datum/comp_buffer)
	src.comp_buffer = WEAKREF(comp_buffer)
