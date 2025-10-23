/// Called when alt clicked and the item has unique reskin options
/obj/item/proc/on_click_alt_reskin(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return NONE

	if(!(item_flags  & INFINITE_RESKIN) && current_skin)
		return NONE

	INVOKE_ASYNC(src, PROC_REF(reskin_obj), user)
	return CLICK_ACTION_SUCCESS

/**
 * Checks if we should set up reskinning,
 * by default if unique_reskin is set.
 *
 * Called on setup_reskinning().
 * Inheritors should override this to add their own checks.
 */
/obj/item/proc/check_setup_reskinning()
	SHOULD_CALL_PARENT(TRUE)
	if(unique_reskin)
		return TRUE

	return FALSE

/**
 * Registers signals and context for reskinning,
 * if check_setup_reskinning() passes.
 *
 * Called on Initialize(...).
 * Inheritors should override this to add their own setup steps,
 * or to avoid double calling register_context().
 */
/obj/item/proc/setup_reskinning()
	SHOULD_CALL_PARENT(FALSE)
	if(!check_setup_reskinning())
		return

	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(on_click_alt_reskin))
	register_context()

/**
 * Reskins object based on a user's choice
 *
 * Arguments:
 * * user The mob choosing a reskin option
 */
/obj/item/proc/reskin_obj(mob/user)
	if(!LAZYLEN(unique_reskin))
		return

	var/list/items = list()
	for(var/reskin_option in unique_reskin)
		var/image/item_image = image(icon = src.icon, icon_state = unique_reskin[reskin_option])
		items += list("[reskin_option]" = item_image)
	sort_list(items)

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	if(!pick)
		return
	if(!unique_reskin[pick])
		return
	current_skin = pick
	icon_state = unique_reskin[pick]

	if (unique_reskin_changes_base_icon_state)
		base_icon_state = icon_state

	if (unique_reskin_changes_inhand)
		inhand_icon_state = icon_state

	update_appearance()

	to_chat(user, "[src] is now skinned as '[pick].'")
	SEND_SIGNAL(src, COMSIG_OBJ_RESKIN, user, pick)

/obj/item/reskin_obj(mob/user)
	if(!uses_advanced_reskins)
		return ..()

	if(!LAZYLEN(unique_reskin))
		return

	/// Is the obj a glasses icon with swappable item states?
	var/is_swappable = FALSE
	/// if the item are glasses, this variable stores the item.
	var/obj/item/clothing/glasses/reskinned_glasses

	if(istype(src, /obj/item/clothing/glasses)) // TODO - Remove this mess about glasses, it shouldn't be necessary anymore.
		reskinned_glasses = src
		if(reskinned_glasses.can_switch_eye)
			is_swappable = TRUE

	var/list/items = list()

	for(var/reskin_option in unique_reskin)
		var/image/item_image = image(icon = unique_reskin[reskin_option][RESKIN_ICON] ? unique_reskin[reskin_option][RESKIN_ICON] : icon, icon_state = "[unique_reskin[reskin_option][RESKIN_ICON_STATE]]")
		items += list("[reskin_option]" = item_image)
	sort_list(items)

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	if(!pick)
		return
	if(!unique_reskin[pick])
		return

	current_skin = pick

	if(unique_reskin[pick][RESKIN_ICON])
		icon = unique_reskin[pick][RESKIN_ICON]

	if(unique_reskin[pick][RESKIN_ICON_STATE])
		if(is_swappable)
			base_icon_state = unique_reskin[pick][RESKIN_ICON_STATE]
			icon_state = base_icon_state
		else
			icon_state = unique_reskin[pick][RESKIN_ICON_STATE]

	if(unique_reskin[pick][RESKIN_WORN_ICON])
		worn_icon = unique_reskin[pick][RESKIN_WORN_ICON]

	if(unique_reskin[pick][RESKIN_WORN_ICON_STATE])
		worn_icon_state = unique_reskin[pick][RESKIN_WORN_ICON_STATE]

	if(unique_reskin[pick][RESKIN_INHAND_L])
		lefthand_file = unique_reskin[pick][RESKIN_INHAND_L]
	if(unique_reskin[pick][RESKIN_INHAND_R])
		righthand_file = unique_reskin[pick][RESKIN_INHAND_R]
	if(unique_reskin[pick][RESKIN_INHAND_STATE])
		inhand_icon_state = unique_reskin[pick][RESKIN_INHAND_STATE]
	if(unique_reskin[pick][RESKIN_SUPPORTS_VARIATIONS_FLAGS])
		supports_variations_flags = unique_reskin[pick][RESKIN_SUPPORTS_VARIATIONS_FLAGS]
	if(ishuman(user))
		var/mob/living/carbon/human/wearer = user
		wearer.regenerate_icons() // update that mf

	to_chat(user, "[src] is now skinned as '[pick].'")
	post_reskin(user)


	update_appearance()

	SEND_SIGNAL(src, COMSIG_OBJ_RESKIN, user, pick)

// MONKE EDIT: Post reskin
/// Automatically called after a reskin, for any extra variable changes.
/obj/item/proc/post_reskin(mob/our_mob)
	return

/**
 * Checks if we are allowed to interact with a radial menu for reskins
 *
 * Arguments:
 * * user The mob interacting with the menu
 */
/obj/item/proc/check_reskin_menu(mob/user)
	if(QDELETED(src))
		return FALSE
	if(!(item_flags  & INFINITE_RESKIN) && current_skin)
		return FALSE
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE
