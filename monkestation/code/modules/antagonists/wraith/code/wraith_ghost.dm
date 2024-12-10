/**
 * This file contains everything that makes our wraith a "ghost"
 * And by that, i mean its copy-paste from the undead ghost mob in order to give the illusion of us being a ghost
 */
/mob/living/basic/wraith
	/// is the wraith able to see things humans and revenants can't?
	var/ghostvision = TRUE

	/// The target mob that the ghost is observing. Used as a reference in logout()
	var/mob/observetarget = null

	/// Are data HUDs currently enabled?
	var/data_huds_on = FALSE
	/// list of data HUDs shown to ghosts.
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED)

	/// Are health scans currently enabled?
	var/health_scan = FALSE
	/// Are chem scans currently enabled?
	var/chem_scan = FALSE
	/// Are gas scans currently enabled?
	var/gas_scan = FALSE

	/// We store copies of the ghost display preferences locally so they can be referred to even if no client is connected.
	/// If there's a bug with changing your ghost settings, it's probably related to this.
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	/// Stores the last setting that ghost_others was set to, for a little more efficiency when we update ghost images. Null means no update is necessary
	var/lastsetting = null

	var/list/atom/allowed_ghost_attack_objects = list(
		/obj/machinery/ecto_sniffer,
		/obj/structure/spirit_board,
	)

/// Okay this might be a bit scary but is probably the best way to implement this for health/chem/gas scans
/mob/living/basic/wraith/ClickOn(atom/A, params)
	..()
	if(isturf(A) || isliving(A))
		A.attack_ghost(src)

/mob/living/basic/wraith/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"
	if(!iswraith(usr))
		return
	if(density)
		to_chat(usr, span_warning("Your physical form is too weak to support teleportation!"))
		return

	var/list/filtered = list()
	for(var/area/A as anything in get_sorted_areas())
		if(!(A.area_flags & HIDDEN_AREA) && !(A.area_flags & NOTELEPORT))
			filtered += A
	var/area/thearea = tgui_input_list(usr, "Area to jump to", "BOOYEA", filtered)
	if(isnull(thearea))
		return

	if(!iswraith(usr))
		return
	if(density)
		to_chat(usr, span_warning("Your physical form is too weak to support teleportation!"))
		return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L += T

	if(!L || !length(L))
		to_chat(usr, span_warning("No area available."))
		return

	usr.forceMove(pick(L))
	update_parallax_contents()

/mob/living/basic/wraith/verb/follow()
	set category = "Ghost"
	set name = "Orbit" // "Haunt"
	set desc = "Follow and orbit a mob."

	GLOB.orbit_menu.show(src)

// This is the ghost's follow verb with an argument
/mob/living/basic/wraith/proc/ManualFollow(atom/movable/target)
	if(!istype(target) || (is_secret_level(target.z) && !client?.holder))
		return
	if(density)
		to_chat(usr, span_warning("Your physical form is too weak to support teleportation!"))
		return

	var/icon/I = icon(target.icon, target.icon_state, target.dir)

	var/orbitsize = (I.Width() + I.Height()) * 0.5
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)

	orbit(target, orbitsize)

/mob/living/basic/wraith/orbit()
	setDir(2)//reset dir so the right directional sprites show up
	return ..()

/mob/living/basic/wraith/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	//restart our floating animation after orbit is done.
	pixel_y = base_pixel_y

/mob/living/basic/wraith/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(!iswraith(usr)) //Make sure they're a wraith!
		return
	if(density)
		to_chat(usr, span_warning("Your physical form is too weak to support teleportation!"))
		return

	var/list/possible_destinations = SSpoints_of_interest.get_mob_pois()
	var/target = null

	target = tgui_input_list(usr, "Please, select a player!", "Jump to Mob", possible_destinations)
	if(isnull(target))
		return
	if(!iswraith(usr))
		return
	if(density)
		to_chat(usr, span_warning("Your physical form is too weak to support teleportation!"))
		return

	var/mob/destination_mob = possible_destinations[target] //Destination mob

	// During the break between opening the input menu and selecting our target, has this become an invalid option?
	if(!SSpoints_of_interest.is_valid_poi(destination_mob))
		return

	var/mob/source_mob = src  //Source mob
	var/turf/destination_turf = get_turf(destination_mob) //Turf of the destination mob

	if(isturf(destination_turf))
		source_mob.forceMove(destination_turf)
		source_mob.update_parallax_contents()
	else
		to_chat(source_mob, span_danger("This mob is not located in the game world."))

/mob/living/basic/wraith/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	update_sight()
	to_chat(usr, span_boldnotice("You [(ghostvision?"now":"no longer")] have ghost vision."))

/mob/living/basic/wraith/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"
	lighting_cutoff++
	switch(lighting_cutoff)
		if(1) // very slightly visible
			lighting_cutoff_red = 10
			lighting_cutoff_green = 8
			lighting_cutoff_blue = 16

		if(2) // basically normal revenant vision
			lighting_cutoff_red = 20
			lighting_cutoff_green = 16
			lighting_cutoff_blue = 32

		if(3) // as close to full-bright as we can let you get whilst keeping orple
			lighting_cutoff_red = 60
			lighting_cutoff_green = 48
			lighting_cutoff_blue = 96

		else // normal, for sneak 100
			lighting_cutoff_red = 0
			lighting_cutoff_green = 0
			lighting_cutoff_blue = 0
			lighting_cutoff = 0

	update_sight()

/mob/living/basic/wraith/update_sight()
	if(client)
		ghost_others = client.prefs.read_preference(/datum/preference/choiced/ghost_others) //A quick update just in case this setting was changed right before calling the proc

	if(!ghostvision)
		set_invis_see(SEE_INVISIBLE_LIVING)
	else
		set_invis_see(SEE_INVISIBLE_OBSERVER)

	updateghostimages()
	return ..()

/mob/living/basic/wraith/proc/updateghostimages()
	if(!client)
		return

	if(lastsetting)
		switch(lastsetting) //checks the setting we last came from, for a little efficiency so we don't try to delete images from the client that it doesn't have anyway
			if(GHOST_OTHERS_DEFAULT_SPRITE)
				client?.images -= GLOB.ghost_images_default
			if(GHOST_OTHERS_SIMPLE)
				client?.images -= GLOB.ghost_images_simple
	lastsetting = client?.prefs.read_preference(/datum/preference/choiced/ghost_others)

/*
/mob/living/basic/wraith/_pointed(atom/pointed_at)
	if(!..())
		return FALSE

	visible_message(span_deadsay("<b>[src]</b> points to [pointed_at]."))
*/

/mob/living/basic/wraith/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Ghost"

	if(!client)
		return
	if(world.time < client.crew_manifest_delay)
		return
	client.crew_manifest_delay = world.time + (1 SECONDS)

	if(!GLOB.crew_manifest_tgui)
		GLOB.crew_manifest_tgui = new /datum/crew_manifest(src)

	GLOB.crew_manifest_tgui.ui_interact(src)

/mob/living/basic/wraith/Topic(href, href_list)
	..()
	if(usr != src)
		return

	if(href_list["follow"])
		var/atom/movable/target = locate(href_list["follow"])
		if(istype(target) && (target != src))
			ManualFollow(target)

	if(href_list["x"] && href_list["y"] && href_list["z"])
		var/tx = text2num(href_list["x"])
		var/ty = text2num(href_list["y"])
		var/tz = text2num(href_list["z"])
		var/turf/target = locate(tx, ty, tz)
		if(istype(target))
			forceMove(target)
			return

	if(href_list["jump"])
		if(density)
			to_chat(usr, span_warning("Your physical form is too weak to support teleportation!"))
			return

		var/atom/movable/target = locate(href_list["jump"])
		var/turf/target_turf = get_turf(target)
		if(target_turf && isturf(target_turf))
			forceMove(target_turf)

/mob/living/basic/wraith/proc/show_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/data_hud = GLOB.huds[hudtype]
		data_hud.show_to(src)

/mob/living/basic/wraith/proc/remove_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/data_hud = GLOB.huds[hudtype]
		data_hud.hide_from(src)

/mob/living/basic/wraith/verb/toggle_data_huds()
	set name = "Toggle Sec/Med/Diag HUD"
	set desc = "Toggles whether you see medical/security/diagnostic HUDs"
	set category = "Ghost"

	data_huds_on = !(data_huds_on)
	if(!data_huds_on) //remove old huds
		remove_data_huds()
		to_chat(src, span_notice("Data HUDs disabled."))
	else
		show_data_huds()
		to_chat(src, span_notice("Data HUDs enabled."))

/mob/living/basic/wraith/verb/toggle_health_scan()
	set name = "Toggle Health Scan"
	set desc = "Toggles whether you health-scan living beings on click"
	set category = "Ghost"

	health_scan = !(health_scan)
	to_chat(src, span_notice("Health scan [health_scan ? "enabled" : "disabled"]."))

/mob/living/basic/wraith/verb/toggle_chem_scan()
	set name = "Toggle Chem Scan"
	set desc = "Toggles whether you scan living beings for chemicals and addictions on click"
	set category = "Ghost"

	chem_scan = !(chem_scan)
	to_chat(src, span_notice("Chem scan [chem_scan ? "enabled" : "disabled"]."))

/mob/living/basic/wraith/verb/toggle_gas_scan()
	set name = "Toggle Gas Scan"
	set desc = "Toggles whether you analyze gas contents on click"
	set category = "Ghost"

	gas_scan = !(gas_scan)
	to_chat(src, span_notice("Gas scan [gas_scan ? "enabled" : "disabled"]."))

/mob/living/basic/wraith/is_literate()
	return TRUE

/mob/living/basic/wraith/can_read(atom/viewed_atom, reading_check_flags, silent)
	return TRUE // we want to bypass all the checks

/mob/living/basic/wraith/reset_perspective(atom/A)
	if(client)
		if(ismob(client.eye) && (client.eye != src))
			cleanup_observe()
	. = ..()
	if(. && hud_used)
		client.clear_screen()
		hud_used.show_hud(hud_used.hud_version)

/mob/living/basic/wraith/proc/cleanup_observe()
	if(isnull(observetarget))
		return

	var/mob/target = observetarget
	observetarget = null
	client?.perspective = initial(client.perspective)
	set_sight(initial(sight))
	if(target)
		UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)
		hide_other_mob_action_buttons(target)
		LAZYREMOVE(target.observers, src)

/mob/living/basic/wraith/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	if(!iswraith(usr)) //Make sure they're a wraith!
		return

	reset_perspective(null)

	var/list/possible_destinations = SSpoints_of_interest.get_mob_pois()
	var/target = null

	target = tgui_input_list(usr, "Please, select a player!", "Jump to Mob", possible_destinations)
	if(isnull(target))
		return
	if(!iswraith(usr))
		return

	reset_perspective(null) // Reset again for sanity

	var/mob/chosen_target = possible_destinations[target]

	// During the break between opening the input menu and selecting our target, has this become an invalid option?
	if(!SSpoints_of_interest.is_valid_poi(chosen_target))
		return

	do_observe(chosen_target)

/mob/living/basic/wraith/proc/do_observe(mob/mob_eye)
	if(isnewplayer(mob_eye))
		stack_trace("/mob/dead/new_player: \[[mob_eye]\] is being observed by [key_name(src)]. This should never happen and has been blocked.")
		message_admins("[ADMIN_LOOKUPFLW(src)] attempted to observe someone in the lobby: [ADMIN_LOOKUPFLW(mob_eye)]. This should not be possible and has been blocked.")
		return

	if(!isnull(observetarget))
		stack_trace("do_observe called on an observer ([src]) who was already observing something! (observing: [observetarget], new target: [mob_eye])")
		message_admins("[ADMIN_LOOKUPFLW(src)] attempted to observe someone while already observing someone, \
			this is a bug (and a past exploit) and should be investigated.")
		return

	//Istype so we filter out points of interest that are not mobs
	if(!client || !mob_eye || !istype(mob_eye))
		return

	client.set_eye(mob_eye)
	client.perspective = EYE_PERSPECTIVE
	if(is_secret_level(mob_eye.z) && !client?.holder)
		set_sight(null) //we dont want ghosts to see through walls in secret areas

	RegisterSignal(mob_eye, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_observing_z_changed))
	if(mob_eye.hud_used)
		client.clear_screen()
		LAZYOR(mob_eye.observers, src)
		mob_eye.hud_used.show_hud(mob_eye.hud_used.hud_version, src)
		observetarget = mob_eye

/mob/living/basic/wraith/proc/on_observing_z_changed(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(is_secret_level(new_turf.z) && !client?.holder)
		set_sight(null) //we dont want ghosts to see through walls in secret areas
	else
		set_sight(initial(sight))

/mob/living/basic/wraith/proc/tray_view()
	set category = "Ghost"
	set name = "T-ray view"
	set desc = "Toggles a view of sub-floor objects"

	var/static/t_ray_view = FALSE
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !client?.holder && !t_ray_view)
		to_chat(usr, span_notice("That verb is currently globally disabled."))
		return
	t_ray_view = !t_ray_view

	var/list/t_ray_images = list()
	var/static/list/stored_t_ray_images = list()
	for(var/obj/O in orange(client.view, src) )
		if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I

	stored_t_ray_images += t_ray_images
	if(length(t_ray_images))
		if(t_ray_view)
			client.images += t_ray_images
		else
			client.images -= stored_t_ray_images
