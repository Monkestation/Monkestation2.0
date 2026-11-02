
/datum/action/minimap
	name = "Toggle Minimap"
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "minimap"
	/// Mob currently bound to z-change signal handling for auto-hide behavior.
	var/mob/tracked_owner
	/// Optional fixed z-level that anchors this action's minimap stack and permission checks.
	var/fixed_z_level
	/// Optional minimap blip tags to render on the rewrite minimap display.
	var/list/minimap_blip_tags = list()
	/// Optional annotation sharing tag for minimap drawings/labels.
	var/annotation_share_tag
	/// Whether this action's minimap display should allow drawing tools.
	var/can_draw = FALSE
	/// list of hud elements we add and remove and check for when this action is triggered
	var/list/huds = list(
		HUD_TAC_MINIMAP_DIMMER = /atom/movable/screen/fullscreen/dimmer/minimap,
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down
	)

/datum/action/minimap/Trigger(trigger_flags)
	. = ..()
	var/mob/clicker = owner
	var/datum/hud/hud = clicker.hud_used
	// Toggle off if already visible.
	if(has_minimap_huds(hud))
		remove_huds(hud)
		to_chat(clicker, span_notice("Minimap hidden."))
		return

	if(SEND_SIGNAL(clicker, COMSIG_MINIMAP_ACTION_TRIGGER) & COMSIG_MINIMAP_ACTION_TRIGGER_CANCEL)
		return

	var/anchor_z = get_anchor_z_level(clicker?.z)
	if(is_forbidden_minimap_z(anchor_z))
		to_chat(clicker, span_warning("The minimap cannot be used on this z-level."))
		clicker.balloon_alert(clicker, "invalid z-level!")
		return
	var/display_z = get_opening_display_z_level(anchor_z, clicker?.z)

	var/datum/minimap/minimap = get_minimap_for_z(display_z)
	if(isnull(minimap))
		clicker.balloon_alert(clicker, "no minimap generated")
		return
	add_huds(hud, minimap, isnull(fixed_z_level) ? null : display_z)
	to_chat(clicker, span_notice("Minimap shown."))

/datum/action/minimap/Grant(mob/grant_to)
	. = ..()
	set_tracked_owner(grant_to)

/datum/action/minimap/Remove(mob/remove_from)
	set_tracked_owner(null)
	return ..()

/// Returns TRUE if any of our minimap hud elements are on the passed hud
/datum/action/minimap/proc/has_minimap_huds(datum/hud/hud)
	for(var/element in huds)
		if(hud.screen_objects[element])
			return TRUE
	return FALSE

/// Returns the minimap display on the passed hud if it is open
/datum/action/minimap/proc/get_open_minimap_display(datum/hud/hud)
	if(isnull(hud) || !has_minimap_huds(hud))
		return null
	return hud.screen_objects[HUD_TAC_MINIMAP]

/// Creates our minimap hud elements and adds them to the passed hud
/datum/action/minimap/proc/add_huds(datum/hud/hud, datum/minimap/minimap, initial_display_z_level)
	for(var/element in huds)
		var/hud_element_type = huds[element]
		var/instanced = new hud_element_type(null, hud, minimap, minimap_blip_tags, initial_display_z_level, annotation_share_tag, can_draw)
		hud.add_screen_object(instanced, element, HUD_GROUP_STATIC, update_screen = TRUE)

/// Sets the mob we watch for z-level changes
/datum/action/minimap/proc/set_tracked_owner(mob/new_owner)
	if(tracked_owner == new_owner)
		return
	if(!isnull(tracked_owner))
		UnregisterSignal(tracked_owner, COMSIG_MOVABLE_Z_CHANGED)
	tracked_owner = new_owner
	if(!isnull(tracked_owner))
		RegisterSignal(tracked_owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_changed))

/// Returns our fixed z-level if we have one, or the passed one otherwise
/datum/action/minimap/proc/get_anchor_z_level(current_z_level)
	return isnull(fixed_z_level) ? current_z_level : fixed_z_level


/// Returns the z-level the minimap should open on, the current one if it is connected to the anchor one
/datum/action/minimap/proc/get_opening_display_z_level(anchor_z_level, current_z_level)
	var/list/connected_levels = SSmapping.get_connected_levels(anchor_z_level)
	if(length(connected_levels) && connected_levels.Find(current_z_level))
		return current_z_level
	return (length(connected_levels) ? connected_levels[1] : anchor_z_level)

/// Returns TRUE if the minimap can not be used on the passed z-level
/datum/action/minimap/proc/is_forbidden_minimap_z(z_level)
	if(isnull(z_level))
		return FALSE
	return is_centcom_level(z_level) || is_reserved_level(z_level)

/// Called when our owner changes z-level
/datum/action/minimap/proc/on_owner_z_changed(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(handle_owner_z_changed), source, new_turf?.z)

/// Closes the minimap on forbidden z-levels, or moves a fixed minimap to the new z-level if it is connected
/datum/action/minimap/proc/handle_owner_z_changed(mob/owner_mob, new_z_level)
	var/datum/hud/owner_hud = owner_mob?.hud_used
	if(isnull(get_open_minimap_display(owner_hud)))
		return

	var/anchor_z = get_anchor_z_level(new_z_level)
	if(is_forbidden_minimap_z(anchor_z))
		remove_huds(owner_hud)
		to_chat(owner_mob, span_warning("The minimap closes on this z-level."))
		return
	if(isnull(fixed_z_level))
		return

	var/display_z = get_opening_display_z_level(anchor_z, new_z_level)
	var/atom/movable/screen/minimap_display/display = get_open_minimap_display(owner_hud)
	if(isnull(display) || display.get_viewed_z_level() == display_z)
		return
	var/datum/minimap/minimap = get_minimap_for_z(display_z)
	if(QDELETED(src) || isnull(minimap))
		return
	display = get_open_minimap_display(owner_hud)
	if(isnull(display) || display.get_viewed_z_level() == display_z)
		return
	display.change_z_level(display_z, minimap)

/datum/action/minimap/nuclear
	annotation_share_tag = MINIMAP_ANNOTATION_TAG_NUCLEAR
	huds = list(
		HUD_TAC_MINIMAP_DIMMER = /atom/movable/screen/fullscreen/dimmer/minimap,
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display/nuclear,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down
	)

/// Removes our minimap hud elements from the passed hud
/datum/action/minimap/proc/remove_huds(datum/hud/hud)
	for(var/element in huds)
		hud.remove_screen_object(element)
