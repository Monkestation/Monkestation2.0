/atom/movable/screen/fullscreen/blind/above_hud
	plane = 41

/datum/controller/subsystem/holomaps/proc/generate_cult_maps()
	for(var/z_level in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/icon/map_base = icon(extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[z_level]"])
		if(!map_base)
			continue
		var/icon/canvas = icon('monkestation/code/modules/bloody_cult/icons/cult_map.dmi', "cultmap")
		map_base.Blend("#E30000", ICON_MULTIPLY)
		canvas.Blend(map_base, ICON_OVERLAY)
		extra_holomaps["[HOLOMAP_EXTRA_CULTMAP]_[z_level]"] = canvas

/datum/controller/subsystem/holomaps/proc/update_cult_map(mob/user, atom/source_object)
	if(!("[HOLOMAP_EXTRA_CULTMAP]_[user.z]" in extra_holomaps))
		generate_cult_maps()
	var/image/map_base = image(extra_holomaps["[HOLOMAP_EXTRA_CULTMAP]_[user.z]"])
	if(!map_base)
		return

	map_base.cut_overlays()

	var/datum/holomap_marker/located_marker = source_object.return_attached_holomap_markers()
	for(var/datum/holomap_marker/marker as anything in holomap_markers)
		if(!(marker.filter & HOLOMAP_FILTER_CULT))
			continue
		var/image/marker_image = image(marker.icon, icon_state = marker.icon_state)
		if(located_marker == marker)
			marker_image.icon_state = "[marker.icon_state]-here"
		marker_image.pixel_x = marker.x + HOLOMAP_CENTER_X
		marker_image.pixel_y = marker.y + HOLOMAP_CENTER_Y
		map_base.overlays += marker_image

	var/datum/team/cult/located_cult = locate_team(/datum/team/cult)
	for(var/datum/mind/mind as anything in located_cult?.members)
		var/mob/living/current_mob = mind.current
		if(current_mob.z != user.z)
			continue
		var/image/cultist_image = image('monkestation/code/modules/bloody_cult/icons/holomap_markers.dmi', icon_state = "mau1")
		cultist_image.pixel_x = current_mob.x + HOLOMAP_CENTER_X
		cultist_image.pixel_y = current_mob.y + HOLOMAP_CENTER_Y
		map_base.overlays += cultist_image

	return map_base

/datum/controller/subsystem/holomaps/proc/show_cult_map(mob/user, atom/source_object, break_on_move = TRUE)
	if(user.hud_used.holomap in user.client.screen)
		return
	var/image/cult_map = update_cult_map(user, source_object)
	if(!cult_map)
		return
	user.hud_used.holomap.used_base_map = cult_map


	if(break_on_move)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(hide_cult_map), cult_map)

	user.hud_used.holomap.plane = 41
	cult_map.loc = user.hud_used.holomap
	user.client.screen |= user.hud_used.holomap
	user.client.images |= cult_map
	user.overlay_fullscreen("map_blocker", /atom/movable/screen/fullscreen/blind/above_hud)
	user.update_fullscreen_alpha("map_blocker", 255, 0)

/datum/controller/subsystem/holomaps/proc/hide_cult_map(mob/user, image/cult_map)
	user.client.screen -= user.hud_used.holomap
	user.client.images -= user.hud_used.holomap.used_base_map
	user.hud_used.holomap.used_base_map = cult_map
	user.hud_used.holomap.plane = 40
	user.clear_fullscreen("map_blocker", 10)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/datum/controller/subsystem/holomaps/proc/live_update_cult_map(mob/user)
	var/image/cult_map = update_cult_map(user, null)
	user.client.images -= user.hud_used.holomap.used_base_map
	user.hud_used.holomap.used_base_map = cult_map
	cult_map.loc = user.hud_used.holomap
	user.client.images |= cult_map

/datum/holomap_marker
	var/x
	var/y
	var/z

	///this is a filter used when quickly searching for all matching markers IE FILTER_CULT will bring all cult markers up
	var/filter
	///this is the id we use when locating them inside the list of markers
	var/id

	///this is our map icon
	var/icon
	///this is our map icon_state
	var/icon_state

	var/atom/reference_atom

/datum/holomap_marker/New(atom/host)
	. = ..()
	SSholomaps.holomap_markers |= src
	if(host)
		RegisterSignal(host, COMSIG_QDELETING, PROC_REF(clear_marker))

/datum/holomap_marker/proc/clear_marker()
	SSholomaps.holomap_markers -= src
	reference_atom = null
	qdel(src)

/atom/proc/return_attached_holomap_markers()
	for(var/datum/holomap_marker/marker as anything in SSholomaps.holomap_markers)
		if(!marker.reference_atom)
			continue
		if(marker.reference_atom != src)
			continue
		return marker
	return null
