#define MAX_NAVIGATE_RANGE 145

/mob/living
	/// Are we currently pathfinding for the navigate verb?
	var/navigating = FALSE
	/// Cooldown of the navigate() verb.
	COOLDOWN_DECLARE(navigate_cooldown)

/client
	/// Images of the path created by navigate().
	var/list/navigation_images = list()

/mob/living/verb/navigate()
	set name = "Navigate"
	set category = "IC"

	if(incapacitated())
		return
	if(length(client.navigation_images))
		addtimer(CALLBACK(src, PROC_REF(cut_navigation)), world.tick_lag)
		balloon_alert(src, "navigation path removed")
		return
	if(navigating)
		balloon_alert(src, "already navigating!")
		return
	if(!COOLDOWN_FINISHED(src, navigate_cooldown))
		balloon_alert(src, "navigation on cooldown!")
		return
	addtimer(CALLBACK(src, PROC_REF(create_navigation)), world.tick_lag)

/mob/living/proc/create_navigation()
	var/list/destination_list = list()
	for(var/atom/destination as anything in GLOB.navigate_destinations)
		if(get_dist(destination, src) > MAX_NAVIGATE_RANGE || !are_zs_connected(destination, src)) // monkestation edit: check to ensure that Z-levels are connected, so we don't get centcom destinations while on station and vice-versa
			continue
		var/destination_name = GLOB.navigate_destinations[destination]
		if(destination.z != z && is_multi_z_level(z)) // up or down is just a good indicator "we're on the station", we don't need to check specifics
			destination_name += ((get_dir_multiz(src, destination) & UP) ? " (Above)" : " (Below)")

		BINARY_INSERT_DEFINE(destination_name, destination_list, SORT_VAR_NO_TYPE, destination_name, SORT_COMPARE_DIRECTLY, COMPARE_KEY)
		destination_list[destination_name] = destination

	if(!length(destination_list))
		balloon_alert(src, "no navigation signals!")
		return

	var/platform_code = tgui_input_list(src, "Select a location", "Navigate", destination_list)
	var/atom/navigate_target = destination_list[platform_code]

	if(isnull(navigate_target) || incapacitated())
		return

	if(!isatom(navigate_target))
		CRASH("Navigate target ([navigate_target]) is not an atom, somehow.")

	navigating = TRUE
	var/datum/callback/await = list(CALLBACK(src, PROC_REF(finish_navigation), navigate_target))
	if(!SSpathfinder.astar_pathfind(src, navigate_target, maxnodes = MAX_NAVIGATE_RANGE, mintargetdist = 1, access = get_access(), smooth_diagonals = FALSE, on_finish = await)) // diagonals look kind of weird when visualized for now
		navigating = FALSE
		balloon_alert(src, "failed to begin navigation!")

/mob/living/proc/finish_navigation(turf/navigate_target, list/path)
	navigating = FALSE
	if(!client)
		return
	if(!length(path))
		balloon_alert(src, "no valid path with current access!")
		return
	path |= get_turf(navigate_target)
	for(var/i in 1 to length(path))
		var/turf/current_turf = path[i]
		var/image/path_image = image(icon = 'icons/effects/navigation.dmi', layer = HIGH_PIPE_LAYER, loc = current_turf)
		SET_PLANE(path_image, GAME_PLANE, current_turf)
		path_image.color = COLOR_CYAN
		path_image.alpha = 0
		var/dir_1 = 0
		var/dir_2 = 0
		if(i == 1)
			dir_2 = turn(angle2dir(get_angle(path[i+1], current_turf)), 180)
		else if(i == length(path))
			dir_2 = turn(angle2dir(get_angle(path[i-1], current_turf)), 180)
		else
			dir_1 = turn(angle2dir(get_angle(path[i+1], current_turf)), 180)
			dir_2 = turn(angle2dir(get_angle(path[i-1], current_turf)), 180)
			if(dir_1 > dir_2)
				dir_1 = dir_2
				dir_2 = turn(angle2dir(get_angle(path[i+1], current_turf)), 180)
		path_image.icon_state = "[dir_1]-[dir_2]"
		client.images += path_image
		client.navigation_images += path_image
		animate(path_image, 0.5 SECONDS, alpha = 150)

	addtimer(CALLBACK(src, PROC_REF(shine_navigation)), 0.5 SECONDS)
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(cut_navigation))
	balloon_alert(src, "navigation path created")
	var/atom/movable/screen/navigate/navigate_hud = locate() in hud_used?.static_inventory
	navigate_hud?.update_icon_state()

/mob/living/proc/shine_navigation()
	for(var/i in 1 to length(client.navigation_images))
		if(!length(client.navigation_images))
			return
		animate(client.navigation_images[i], time = 1 SECONDS, loop = -1, alpha = 200, color = "#bbffff", easing = BACK_EASING | EASE_OUT)
		animate(time = 2 SECONDS, loop = -1, alpha = 150, color = "#00ffff", easing = CUBIC_EASING | EASE_OUT)
		stoplag(0.1 SECONDS)

/mob/living/proc/cut_navigation()
	SIGNAL_HANDLER
	UnregisterSignal(src, list(COMSIG_LIVING_DEATH, COMSIG_MOVABLE_Z_CHANGED))
	if(client?.navigation_images)
		var/list/navigation_images = client.navigation_images
		for(var/image/navigation_path in navigation_images)
			client?.images -= navigation_path
		navigation_images.Cut()
	var/atom/movable/screen/navigate/navigate_hud = locate() in hud_used?.static_inventory
	navigate_hud?.update_icon_state()

/**
 * Finds nearest ladder or staircase either up or down.
 *
 * Arguments:
 * * direction - UP or DOWN.
 */
/mob/living/proc/find_nearest_stair_or_ladder(direction)
	if(!direction)
		return
	if(direction != UP && direction != DOWN)
		return

	var/target
	for(var/obj/structure/ladder/lad in GLOB.ladders)
		if(lad.z != z)
			continue
		if(direction == UP && !lad.up)
			continue
		if(direction == DOWN && !lad.down)
			continue
		if(!target)
			target = lad
			continue
		if(get_dist_euclidean(lad, src) > get_dist_euclidean(target, src))
			continue
		target = lad

	for(var/obj/structure/stairs/stairs_bro in GLOB.stairs)
		if(direction == UP && stairs_bro.z != z) //if we're going up, we need to find stairs on our z level
			continue
		if(direction == DOWN && stairs_bro.z != z - 1) //if we're going down, we need to find stairs on the z level beneath us
			continue
		if(!target)
			target = stairs_bro.z == z ? stairs_bro : get_step_multiz(stairs_bro, UP) //if the stairs aren't on our z level, get the turf above them (on our zlevel) to path to instead
			continue
		if(get_dist_euclidean(stairs_bro, src) > get_dist_euclidean(target, src))
			continue
		target = stairs_bro.z == z ? stairs_bro : get_step_multiz(stairs_bro, UP)

	return target

#undef MAX_NAVIGATE_RANGE
