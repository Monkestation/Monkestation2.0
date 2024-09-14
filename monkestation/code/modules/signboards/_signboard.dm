#define SIGNBOARD_WIDTH		(world.icon_size * 3.5)
#define SIGNBOARD_HEIGHT	(world.icon_size * 2.5)

/obj/structure/signboard
	name = "sign"
	desc = "A foldable sign."
	icon = 'monkestation/icons/obj/structures/signboards.dmi'
	icon_state = "sign_blank"
	base_icon_state = "sign"
	density = TRUE
	anchored = TRUE
	interaction_flags_atom  = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_REQUIRES_DEXTERITY
	/// The current text written on the sign.
	var/sign_text
	/// The maximum length of text that can be input onto the sign.
	var/max_length = MAX_PLAQUE_LEN
	/// If true, the text cannot be changed by players.
	var/locked = FALSE
	/// If text should be shown while unanchored.
	var/show_while_unanchored = TRUE
	/// If TRUE, the sign can be edited without a pen.
	var/edit_by_hand = FALSE
	/// Lazy assoc list of clients to images
	VAR_PROTECTED/list/client_maptext_images

/obj/structure/signboard/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(on_mob_login))
	if(sign_text)
		set_text(sign_text, force = TRUE)
		investigate_log("had its text set on load to \"[sign_text]\"", INVESTIGATE_SIGNBOARD)
	update_appearance()
	register_context()

/obj/structure/signboard/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN)
	remove_from_all_clients()
	return ..()

/obj/structure/signboard/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!locked && (edit_by_hand || istype(held_item, /obj/item/pen)) && (anchored || show_while_unanchored))
		context[SCREENTIP_CONTEXT_LMB] = "Set Displayed Text"
		if(sign_text)
			context[SCREENTIP_CONTEXT_ALT_RMB] = "Clear Sign"
		. = CONTEXTUAL_SCREENTIP_SET

/obj/structure/signboard/examine(mob/user)
	. = ..()
	if(!edit_by_hand)
		. += span_info("You need a <b>pen</b> to write on the sign!")
	if(sign_text)
		. += span_boldnotice("\nIt currently displays the following:")
		. += span_info(html_encode(sign_text))
	else
		. += span_info("\nIt is blank!")

/obj/structure/signboard/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][sign_text ? "" : "_blank"]"

/obj/structure/signboard/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, sign_text))
		if(!set_text(var_value, force = TRUE))
			return FALSE
		datum_flags |= DF_VAR_EDITED
		return TRUE
	return ..()

/obj/structure/signboard/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/pen))
		return ..()
	try_set_text(user)

/obj/structure/signboard/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!edit_by_hand && !user.is_holding_item_of_type(/obj/item/pen))
		balloon_alert(user, "need a pen!")
		return TRUE
	if(try_set_text(user))
		return TRUE

/obj/structure/signboard/proc/try_set_text(mob/living/user)
	. = FALSE
	if(!anchored && !show_while_unanchored)
		return FALSE
	if(check_locked(user))
		return FALSE
	var/new_text = tgui_input_text(
		user,
		message = "What would you like to set this sign's text to?",
		title = full_capitalize(name),
		default = sign_text,
		max_length = max_length,
		multiline = TRUE,
		encode = FALSE
	)
	if(QDELETED(src) || !new_text || check_locked(user))
		return FALSE
	var/list/filter_result = CAN_BYPASS_FILTER(user) ? null : is_ic_filtered(new_text)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		return FALSE
	var/list/soft_filter_result = CAN_BYPASS_FILTER(user) ? null : is_soft_ic_filtered(new_text)
	if(soft_filter_result)
		if(tgui_alert(user, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return FALSE
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" when writing to the sign at [ADMIN_VERBOSEJMP(src)], they may be using a disallowed term. Sign text: \"[html_encode(new_text)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" when writing to the sign at [loc_name(src)], they may be using a disallowed term. Sign text: \"[new_text]\"")
	if(set_text(new_text))
		balloon_alert(user, "set text")
		investigate_log("([key_name(user)]) set text to \"[sign_text || "(none)"]\"", INVESTIGATE_SIGNBOARD)
		return TRUE

/obj/structure/signboard/alt_click_secondary(mob/user)
	. = ..()
	if(!sign_text || !can_interact(user) || !user.can_perform_action(src, NEED_DEXTERITY))
		return
	if(!edit_by_hand && !user.is_holding_item_of_type(/obj/item/pen))
		balloon_alert(user, "need a pen!")
		return
	if(check_locked(user))
		return
	if(set_text(null))
		balloon_alert(user, "cleared text")
		investigate_log("([key_name(user)]) cleared the text", INVESTIGATE_SIGNBOARD)

/obj/structure/signboard/proc/try_clear_sign(mob/user)
	. = TRUE

/obj/structure/signboard/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/signboard/set_anchored(anchorvalue)
	. = ..()
	add_to_all_clients()

/obj/structure/signboard/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!isturf(old_loc) || !isturf(loc))
		add_to_all_clients()

/obj/structure/signboard/proc/is_locked(mob/user)
	. = locked
	if(isAdminGhostAI(user))
		return FALSE

/obj/structure/signboard/proc/check_locked(mob/user, silent = FALSE)
	. = is_locked(user)
	if(. && !silent)
		balloon_alert(user, "locked!")

/obj/structure/signboard/proc/should_display_text()
	if(QDELETED(src) || !isturf(loc) || !sign_text)
		return FALSE
	if(!anchored && !show_while_unanchored)
		return FALSE
	return TRUE

/obj/structure/signboard/proc/on_mob_login(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(add_client), user?.client)

/obj/structure/signboard/proc/add_client(client/user)
	if(QDELETED(user) || !should_display_text())
		return
	if(LAZYACCESS(client_maptext_images, user))
		remove_client(user)
	var/image/client_image = create_image_for_client(user)
	if(!client_image || QDELETED(user))
		return
	LAZYSET(client_maptext_images, user, client_image)
	LAZYADD(update_on_z, client_image)
	user.images |= client_image
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(remove_client))

/obj/structure/signboard/proc/remove_client(client/user)
	SIGNAL_HANDLER
	if(isnull(user))
		return
	UnregisterSignal(user, COMSIG_QDELETING)
	var/image/client_image = LAZYACCESS(client_maptext_images, user)
	if(!client_image)
		return
	user.images -= client_image
	LAZYREMOVE(client_maptext_images, user)
	LAZYREMOVE(update_on_z, client_image)

/obj/structure/signboard/proc/add_to_all_clients()
	if(QDELETED(src))
		return
	remove_from_all_clients()
	if(!should_display_text())
		return
	for(var/client/client as anything in GLOB.clients)
		if(QDELETED(client))
			continue
		add_client(client)

/obj/structure/signboard/proc/remove_from_all_clients()
	for(var/client/client as anything in client_maptext_images)
		remove_client(client)
	LAZYNULL(client_maptext_images)

/obj/structure/signboard/proc/create_image_for_client(client/user) as /image
	RETURN_TYPE(/image)
	if(QDELETED(user) || !sign_text)
		return
	var/bwidth = src.bound_width || world.icon_size
	var/bheight = src.bound_height || world.icon_size
	var/text_html = MAPTEXT_GRAND9K("<span style='text-align: center'>[html_encode(sign_text)]</span>")
	var/mheight
	WXH_TO_HEIGHT(user.MeasureText(text_html, null, SIGNBOARD_WIDTH), mheight)
	var/image/maptext_holder = image(loc = src, layer = CHAT_LAYER + 0.1)
	SET_PLANE_EXPLICIT(maptext_holder, HUD_PLANE, src)
	maptext_holder.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	maptext_holder.alpha = 160
	maptext_holder.maptext = text_html
	maptext_holder.maptext_x = (SIGNBOARD_WIDTH - bwidth) * -0.5
	maptext_holder.maptext_y = bheight
	maptext_holder.maptext_width = SIGNBOARD_WIDTH
	maptext_holder.maptext_height = mheight
	return maptext_holder

/obj/structure/signboard/proc/set_text(new_text, force = FALSE)
	. = FALSE
	if(QDELETED(src) || (locked && !force))
		return
	if(!istext(new_text) && !isnull(new_text))
		CRASH("Attempted to set invalid signtext: [new_text]")
	. = TRUE
	new_text = trimtext(copytext_char(new_text, 1, max_length))
	if(length(new_text))
		sign_text = new_text
		add_to_all_clients()
	else
		sign_text = null
		remove_from_all_clients()
	update_appearance()

#undef SIGNBOARD_HEIGHT
#undef SIGNBOARD_WIDTH
