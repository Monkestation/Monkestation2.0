#define ACTIVATION_COST (0.3 * STANDARD_CELL_CHARGE)
#define ACTIVATION_UP_KEEP (0.025 * STANDARD_CELL_RATE)

/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// The cyborg that is currently disguised.
	var/mob/living/silicon/robot/disguised_cyborg
	/// The typepath of the robot model that we will be using as a disguise.
	var/obj/item/robot_model/disguise_model_type = /obj/item/robot_model/engineering
	/// The details of the disguised skin.
	var/list/disguised_skin_details
	/// When the disguise is applied, this is the new name the the cyborg will get.
	var/disguised_name
	/// When the disguise is removed, this is the old name that the cyborg will revert back to.
	var/original_name
	/// List of signals that should break the disguise.
	var/static/list/signal_cache = list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_MOVABLE_IMPACT_ZONE,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_EX_ACT,
		COMSIG_ATOM_FIRE_ACT,
		COMSIG_ATOM_EMP_ACT
	)

/obj/item/borg_chameleon/Initialize(mapload)
	. = ..()
	disguised_name = pick(GLOB.ai_names)

/obj/item/borg_chameleon/Destroy()
	disguised_cyborg = null
	disguised_skin_details = null
	return ..()

/obj/item/borg_chameleon/process(seconds_per_tick)
	if(QDELETED(disguised_cyborg))
		return PROCESS_KILL
	if(disguised_cyborg.cell?.use(ACTIVATION_UP_KEEP * seconds_per_tick))
		return
	disrupt()

/obj/item/borg_chameleon/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Left-click")] the item to [disguised_cyborg ? "drop your disguise" : "begin disguising"]." )
	. += span_notice("[EXAMINE_HINT("Right-click")] the item to set your next disguise's model and its skin.")
	. += span_notice("[EXAMINE_HINT("Ctrl-click")] the item to randomize your next disguise's name.")

/obj/item/borg_chameleon/dropped(mob/user)
	. = ..()
	disrupt()

/obj/item/borg_chameleon/equipped(mob/user)
	. = ..()
	disrupt()

/obj/item/borg_chameleon/attack_self(mob/user, modifiers)
	if(!iscyborg(user))
		to_chat(user, span_notice("This device doesn't seem to work for non-cyborgs."))
		return
	var/mob/living/silicon/robot/cyborg_user = user
	if(!cyborg_user.cell || cyborg_user.cell.charge <= ACTIVATION_COST)
		to_chat(cyborg_user, span_warning("You need at least [display_energy(ACTIVATION_COST)] charge in your cell to use [src]!"))
		return
	if(!isturf(cyborg_user.loc))
		to_chat(cyborg_user, span_warning("You can't use [src] while inside something!"))
		return
	toggle(cyborg_user)

/obj/item/borg_chameleon/attack_self_secondary(mob/user, modifiers)
	initialize_cyborg_model_lists()
	var/input_model = show_radial_menu(user, src, GLOB.cyborg_base_models_icon_list, radius = 42, require_near = TRUE)
	if(!input_model)
		return
	var/obj/item/robot_model/selected_model = GLOB.cyborg_model_list[input_model]
	if(!selected_model)
		return
	disguised_skin_details = prompt_skin_details(user, selected_model)
	disguise_model_type = selected_model
	to_chat(user, span_notice("The next disguised model will be: [initial(disguise_model_type.name)]."))

/obj/item/borg_chameleon/item_ctrl_click(mob/user)
	disguised_name = pick(GLOB.ai_names)
	to_chat(user, span_notice("The next disguised name will be: [disguised_name]."))
	return CLICK_ACTION_SUCCESS

/// Offers a radial wheel to the user and tells them to pick and choose one of the cyborg model's skin.
/obj/item/borg_chameleon/proc/prompt_skin_details(mob/user, obj/item/robot_model/skin_model_type)
	var/obj/item/robot_model/skin_model = new skin_model_type()
	if(length(skin_model.borg_skins))
		var/list/reskin_icons = list()
			for(var/borg_skin in skin_model.borg_skins)
				var/list/skin_details = skin_model.borg_skins[borg_skin]
				reskin_icons[borg_skin] = image(icon = skin_details[SKIN_ICON] || 'icons/mob/silicon/robots.dmi', icon_state = skin_details[SKIN_ICON_STATE])
			var/skin_name = show_radial_menu(user, src, reskin_icons, radius = 42, require_near = TRUE)
			if(skin_name)
				. = skin_model.borg_skins[skin_name].Copy()
	qdel(skin_model)

/// Applies the default appearance of a model. If provided, will apply skin details as well.
/obj/item/borg_chameleon/proc/disguise_as_model(mob/living/silicon/robot/cyborg_user, obj/item/robot_model/skin_model_type, list/skin_details)
	cyborg_user.model.name = initial(skin_model_type.name)
	cyborg_user.model.cyborg_base_icon = initial(skin_model_type.cyborg_base_icon)
	cyborg_user.icon = initial(cyborg_user.icon)
	cyborg_user.base_pixel_x = initial(skin_model_type.base_pixel_x)
	cyborg_user.base_pixel_y = initial(skin_model_type.base_pixel_y)
	cyborg_user.model.special_light_key = initial(skin_model_type.special_light_key)
	cyborg_user.model.hat_offset = initial(skin_model_type.hat_offset)
	cyborg_user.model.badge_offset = initial(skin_model_type.badge_offset)
	REMOVE_TRAITS_IN(cyborg_user, REF(src))
	if(islist(skin_details))
		if(!isnull(skin_details[SKIN_ICON_STATE]))
			cyborg_user.model.cyborg_base_icon = skin_details[SKIN_ICON_STATE]
		if(!isnull(skin_details[SKIN_ICON]))
			cyborg_user.icon = skin_details[SKIN_ICON]
		if(!isnull(skin_details[SKIN_PIXEL_X]))
			cyborg_user.base_pixel_x = skin_details[SKIN_PIXEL_X]
		if(!isnull(skin_details[SKIN_PIXEL_Y]))
			cyborg_user.base_pixel_y = skin_details[SKIN_PIXEL_Y]
		if(!isnull(skin_details[SKIN_LIGHT_KEY]))
			cyborg_user.model.special_light_key = skin_details[SKIN_LIGHT_KEY]
		if(!isnull(skin_details[SKIN_HAT_OFFSET]))
			cyborg_user.model.hat_offset = skin_details[SKIN_HAT_OFFSET]
		if(!isnull(skin_details[SKIN_BADGE_OFFSET]))
			cyborg_user.model.badge_offset = skin_details[SKIN_BADGE_OFFSET]
		if(!isnull(skin_details[SKIN_TRAITS])) // Skin traits are comestic in general.
			cyborg_user.add_traits(skin_details[SKIN_TRAITS], REF(src))
	disguised_cyborg.update_icons() // Icon state is handled here.

/**
 * Toggles the item. It will either:
 *
 * A. Remove the active disguise.
 *
 * B. Begin the process of putting on a disguise.
 */
/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/cyborg_user)
	if(LAZYACCESS(cyborg_user.do_afters, REF(src)))
		return
	if(disguised_cyborg)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, -6)
		to_chat(cyborg_user, span_notice("You deactivate \the [src]."))
		deactivate()
		return
	to_chat(cyborg_user, span_notice("You activate \the [src]."))
	playsound(src, 'sound/effects/seedling_chargeup.ogg', 100, TRUE, -6)
	apply_wibbly_filters(cyborg_user)
	if(do_after(cyborg_user, 5 SECONDS, cyborg_user, interaction_key = REF(src), hidden = TRUE) && cyborg_user.cell.use(ACTIVATION_COST))
		playsound(src, 'sound/effects/bamf.ogg', 100, TRUE, -6)
		to_chat(cyborg_user, span_notice("You are now disguised as the Nanotrasen [initial(disguise_model_type.name)] borg \"[disguised_name]\"."))
		activate(cyborg_user)
	else
		to_chat(cyborg_user, span_warning("The chameleon field fizzles."))
		do_sparks(3, FALSE, cyborg_user)
	remove_wibbly_filters(cyborg_user)

/// Applies the disguise and its skin.
/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/cyborg_user)
	START_PROCESSING(SSobj, src)
	if(disguised_cyborg)
		return
	original_name = cyborg_user.name
	disguised_cyborg = cyborg_user
	disguised_cyborg.name = disguised_name
	disguised_cyborg.bubble_icon = "robot"
	disguise_as_model(disguised_cyborg, disguise_model_type, disguised_skin_details)
	RegisterSignals(disguised_cyborg, signal_cache, PROC_REF(disrupt))

/// Removes the disguise.
/obj/item/borg_chameleon/proc/deactivate()
	STOP_PROCESSING(SSobj, src)
	if(!disguised_cyborg)
		return
	UnregisterSignal(disguised_cyborg, signal_cache)
	do_sparks(5, FALSE, disguised_cyborg)
	disguised_cyborg.name = original_name
	disguised_cyborg.bubble_icon = "syndibot"
	disguise_as_model(disguised_cyborg, disguised_cyborg.model.type) // Syndicate Saboteurs do not have skins that we care about.
	disguised_cyborg = null
	original_name = null

/// Removes the disguise and tells the cyborg that it happened.
/obj/item/borg_chameleon/proc/disrupt()
	SIGNAL_HANDLER
	if(QDELETED(disguised_cyborg))
		return
	to_chat(disguised_cyborg, span_danger("Your chameleon field deactivates."))
	deactivate()

#undef ACTIVATION_COST
#undef ACTIVATION_UP_KEEP
