// Crew has to build a bluespace cannon
// Cargo orders part for high price
// Requires high amount of power
// Requires high level stock parts
/datum/station_goal/bluespace_cannon
	name = "Bluespace Artillery"

/datum/station_goal/bluespace_cannon/get_report()
	return list(
		"<blockquote>Our military presence is inadequate in your sector.",
		"We need you to construct BSA-[rand(1,99)] Artillery position aboard your station,",
		"and test-fire it to ensure it is fully functional.",
		"",
		"Base parts are available for shipping via cargo.",
		"-Nanotrasen Naval Command</blockquote>",
	).Join("\n")

/datum/station_goal/bluespace_cannon/on_report()
	//Unlock BSA parts
	var/datum/supply_pack/engineering/bsa/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/bsa]
	P.special_enabled = TRUE

/obj/machinery/bsa
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	density = TRUE
	anchored = TRUE

/obj/machinery/bsa/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/bsa/back
	name = "Bluespace Artillery Generator"
	desc = "Generates cannon pulse. Needs to be linked with a fusor."
	icon_state = "power_box"

/obj/machinery/bsa/back/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/bsa/back/multitool_act(mob/living/user, obj/item/multitool/M)
	M.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/bsa/front
	name = "Bluespace Artillery Bore"
	desc = "Do not stand in front of cannon during operation. Needs to be linked with a fusor."
	icon_state = "emitter_center"

/obj/machinery/bsa/front/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/bsa/front/multitool_act(mob/living/user, obj/item/multitool/M)
	M.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/bsa/middle
	name = "Bluespace Artillery Fusor"
	desc = "Contents classified by Nanotrasen Naval Command. Needs to be linked with the other BSA parts using a multitool."
	icon_state = "fuel_chamber"
	var/datum/weakref/back_ref
	var/datum/weakref/front_ref

/obj/machinery/bsa/middle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/bsa/middle/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = NONE

	if(istype(tool.buffer, /obj/machinery/bsa/back))
		back_ref = WEAKREF(tool.buffer)
		to_chat(user, span_notice("You link [src] with [tool.buffer]."))
		tool.set_buffer(null)
		return ITEM_INTERACT_SUCCESS
	else if(istype(tool.buffer, /obj/machinery/bsa/front))
		front_ref = WEAKREF(tool.buffer)
		to_chat(user, span_notice("You link [src] with [tool.buffer]."))
		tool.set_buffer(null)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/bsa/middle/proc/check_completion()
	var/obj/machinery/bsa/front/front = front_ref?.resolve()
	var/obj/machinery/bsa/back/back = back_ref?.resolve()
	if(!front || !back)
		return "No linked parts detected!"
	if(!front.anchored || !back.anchored || !anchored)
		return "Linked parts unwrenched!"
	if(front.y != y || back.y != y || !(front.x > x && back.x < x || front.x < x && back.x > x) || front.z != z || back.z != z)
		return "Parts misaligned!"
	if(!has_space())
		return "Not enough free space!"

/obj/machinery/bsa/middle/proc/has_space()
	var/cannon_dir = get_cannon_direction()
	var/width = 10
	var/offset
	switch(cannon_dir)
		if(EAST)
			offset = -4
		if(WEST)
			offset = -6
		else
			return FALSE

	var/turf/base = get_turf(src)
	for(var/turf/T as anything in CORNER_BLOCK_OFFSET(base, width, 3, offset, -1))
		if(T.density || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/bsa/middle/proc/get_cannon_direction()
	var/obj/machinery/bsa/front/front = front_ref?.resolve()
	var/obj/machinery/bsa/back/back = back_ref?.resolve()
	if(!front || !back)
		return
	if(front.x > x && back.x < x)
		return EAST
	else if(front.x < x && back.x > x)
		return WEST


/obj/machinery/bsa/full
	name = "Bluespace Artillery"
	desc = "Long range bluespace artillery."
	icon = 'icons/obj/lavaland/cannon.dmi'
	icon_state = "cannon_west"
	var/static/mutable_appearance/top_layer
	var/ex_power = 3
	var/power_used_per_shot = 2000000 //enough to kil standard apc - todo : make this use wires instead and scale explosion power with it
	var/ready
	/// How long the beam is. Is actually 6 tiles less than what is put here since we count from the center of the BSA.
	var/beam_length = 26 //Enough to cover an entire screen.
	pixel_y = -32
	pixel_x = -192
	bound_width = 352
	bound_x = -192
	appearance_flags = LONG_GLIDE //Removes default TILE_BOUND

/obj/machinery/bsa/full/wrench_act(mob/living/user, obj/item/I)
	return FALSE

/obj/machinery/bsa/full/proc/get_front_turf()
	switch(dir)
		if(WEST)
			return locate(x - 7,y,z)
		if(EAST)
			return locate(x + 7,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_back_turf()
	switch(dir)
		if(WEST)
			return locate(x + 5,y,z)
		if(EAST)
			return locate(x - 5,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_target_turf()
	/// The x value of where the beam will end up at.
	var/x_value
	switch(dir)
		if(WEST)
			x_value = max(1,x - beam_length)
			return locate(x_value,y,z)
		if(EAST)
			x_value = min(world.maxx, x + beam_length)
			return locate(x_value,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/Initialize(mapload, cannon_direction = WEST)
	. = ..()
	switch(cannon_direction)
		if(WEST)
			setDir(WEST)
			icon_state = "cannon_west"
		if(EAST)
			setDir(EAST)
			pixel_x = -128
			bound_x = -128
			icon_state = "cannon_east"
	get_layer()
	reload()

/obj/machinery/bsa/full/proc/get_layer()
	top_layer = mutable_appearance(icon, layer = ABOVE_MOB_LAYER)
	SET_PLANE_EXPLICIT(top_layer, GAME_PLANE_UPPER, src)
	switch(dir)
		if(WEST)
			top_layer.icon_state = "top_west"
		if(EAST)
			top_layer.icon_state = "top_east"
	add_overlay(top_layer)

/obj/machinery/bsa/full/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(same_z_layer)
		return ..()
	cut_overlay(top_layer)
	get_layer()
	return ..()

/obj/machinery/bsa/full/proc/fire(mob/user, turf/bullseye)
	reload()

	var/turf/point = get_front_turf()
	var/turf/target = get_target_turf()
	var/atom/movable/blocker

	for(var/mob/living/mob in point) //The tile next to the cannon will not destroy turfs/objects, (so you can put a holobarrier) but WILL gib everyone on that tile.
		mob.gib()
	for(var/T in get_line(get_step(point, dir), target))
		var/turf/tile = T
		if(SEND_SIGNAL(tile, COMSIG_ATOM_BSA_BEAM) & COMSIG_ATOM_BLOCKS_BSA_BEAM)
			blocker = tile
		else
			for(var/AM in tile)
				var/atom/movable/stuff = AM
				if(SEND_SIGNAL(stuff, COMSIG_ATOM_BSA_BEAM) & COMSIG_ATOM_BLOCKS_BSA_BEAM)
					blocker = stuff
					break
		if(blocker)
			target = tile
			break
		else
			SSexplosions.highturf += tile //also fucks everything else on the turf
	point.Beam(target, icon_state = "bsa_beam", time = 5 SECONDS, maxdistance = beam_length) //ZZZAP
	new /obj/effect/temp_visual/bsa_splash(point, dir)

	notify_ghosts(
		"The Bluespace Artillery has been fired!",
		source = bullseye,
		header = "KABOOM!",
	)

	if(!blocker)
		message_admins("[ADMIN_LOOKUPFLW(user)] has launched a bluespace artillery strike targeting [ADMIN_VERBOSEJMP(bullseye)].")
		user.log_message("has launched a bluespace artillery strike targeting [AREACOORD(bullseye)].", LOG_GAME)
		explosion(bullseye, devastation_range = ex_power, heavy_impact_range = ex_power*2, light_impact_range = ex_power*4, explosion_cause = src)
		new /obj/effect/temp_visual/bsa_impact(bullseye)
	else
		message_admins("[ADMIN_LOOKUPFLW(user)] has launched a bluespace artillery strike targeting [ADMIN_VERBOSEJMP(bullseye)] but it was blocked by [blocker] at [ADMIN_VERBOSEJMP(target)].")
		user.log_message("has launched a bluespace artillery strike targeting [AREACOORD(bullseye)] but it was blocked by [blocker] at [AREACOORD(target)].", LOG_GAME)

	complete_goal()

/// Marks the BSA station goal as completed.
/obj/machinery/bsa/full/proc/complete_goal()
	var/datum/station_goal/bluespace_cannon/bsa_goal = locate() in GLOB.station_goals
	bsa_goal?.completed = TRUE

/obj/machinery/bsa/full/proc/reload()
	ready = FALSE
	use_energy(power_used_per_shot)
	addtimer(CALLBACK(src,"ready_cannon"),600)

/obj/machinery/bsa/full/proc/ready_cannon()
	ready = TRUE

/obj/structure/filler
	name = "big machinery part"
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	var/obj/machinery/parent

/obj/structure/filler/ex_act()
	return FALSE

/obj/machinery/computer/bsa_control
	name = "bluespace artillery control"
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/computer/bsa_control
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp"
	icon_keyboard = null
	icon_screen = null

	/// Is the BSA unlocked?
	var/bsa_unlock = FALSE
	/// Will the BSA target itself when it's fired?
	var/rigged_to_blow = FALSE
	var/datum/weakref/cannon_ref
	var/notice
	var/target
	var/area_aim = FALSE //should also show areas for targeting
	COOLDOWN_DECLARE(fire_cooldown) //the "cooldown" for firing the BSA normally is it consuming a absolutely absurd amount of power.
	var/fire_cooldown_length = 5 SECONDS // (duration the beam exists) When this is (very easily) circumvented, then shit becomes an issue.

/obj/machinery/computer/bsa_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceArtillery", name)
		ui.open()

/obj/machinery/computer/bsa_control/ui_data()
	var/obj/machinery/bsa/full/cannon = cannon_ref?.resolve()
	var/list/data = list()
	data["ready"] = cannon ? cannon.ready : FALSE
	data["connected"] = cannon
	data["notice"] = notice
	data["unlocked"] = bsa_unlock
	if(target)
		data["target"] = get_target_name()
	return data

/obj/machinery/computer/bsa_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("build")
			cannon_ref = WEAKREF(deploy())
			. = TRUE
		if("fire")
			fire(usr)
			. = TRUE
		if("recalibrate")
			calibrate(usr)
			. = TRUE
	update_appearance()

/obj/machinery/computer/bsa_control/proc/calibrate(mob/user)
	if(!bsa_unlock)
		return
	var/list/gps_locators = list()
	for(var/datum/component/gps/G in GLOB.GPS_list) //nulls on the list somehow
		if(G.tracking && G.bsa_targetable) // monkestation edit: bsa_targetable
			gps_locators[G.gpstag] = G

	var/list/options = gps_locators
	if(area_aim)
		options += GLOB.teleportlocs
	var/victim = tgui_input_list(user, "Select target", "Artillery Targeting", options)
	if(isnull(victim))
		return
	if(isnull(options[victim]))
		return
	target = options[victim]
	log_game("[key_name(user)] has aimed the bluespace artillery strike at [target].")


/obj/machinery/computer/bsa_control/proc/get_target_name()
	if(istype(target, /area))
		return get_area_name(target, TRUE)
	else if(istype(target, /datum/component/gps))
		var/datum/component/gps/G = target
		return G.gpstag

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	if(rigged_to_blow)
		return get_turf(src)
	else if(istype(target, /area))
		return pick(get_area_turfs(target))
	else if(istype(target, /datum/component/gps))
		var/datum/component/gps/G = target
		// monkestation start: bsa_targetable sanity check
		if(!G.bsa_targetable)
			CRASH("BSA tried to fire at [G.gpstag] ([G.parent]), despite bsa_targetable being set to false")
		// monkestation end
		return get_turf(G.parent)

/obj/machinery/computer/bsa_control/proc/fire(mob/user)
	var/obj/machinery/bsa/full/cannon = cannon_ref?.resolve()
	var/datum/component/gps/G = target
	if(!cannon)
		notice = "No Cannon Exists!"
		return
	if(cannon.machine_stat)
		notice = "Cannon unpowered!"
		return
	if(QDELETED(G.parent) && !rigged_to_blow) // Makes sure the signal isn't deleted. If rigged to blow, will still blow up the BSA.
		notice = "Target does not exist! Select a new target!"
		return
	notice = null
	if(!COOLDOWN_FINISHED(src, fire_cooldown) && fire_cooldown_length)
		notice = "Cannon overheated!"
		return
	COOLDOWN_START(src, fire_cooldown, fire_cooldown_length)
	var/turf/target_turf = get_impact_turf()
	cannon.fire(user, target_turf)

/obj/machinery/computer/bsa_control/proc/deploy(force=FALSE)
	var/obj/machinery/bsa/full/prebuilt = locate() in range(7) //In case of adminspawn
	if(prebuilt)
		return prebuilt

	var/obj/machinery/bsa/middle/centerpiece = locate() in range(7)
	if(!centerpiece)
		notice = "No BSA parts detected nearby."
		return null
	notice = centerpiece.check_completion()
	if(notice)
		return null
	//Totally nanite construction system not an immersion breaking spawning
	var/datum/effect_system/fluid_spread/smoke/fourth_wall_guard = new
	fourth_wall_guard.set_up(4, holder = src, location = get_turf(centerpiece))
	fourth_wall_guard.start()
	var/obj/machinery/bsa/full/cannon = new(get_turf(centerpiece),centerpiece.get_cannon_direction())
	QDEL_NULL(centerpiece.front_ref)
	QDEL_NULL(centerpiece.back_ref)
	qdel(centerpiece)
	return cannon

/obj/machinery/computer/bsa_control/item_interaction(mob/living/user, obj/item/tool,  list/modifiers)
	var/obj/item/card/id/card = tool.GetID()
	if(card)
		if(obj_flags & EMAGGED)
			to_chat(user, span_warning("The authentification slot spits sparks at you and the display reads scrambled text!"))
			do_sparks(1, FALSE, src)
			bsa_unlock = TRUE // just in case it wasn't already for some reason. keycard reader is busted.
			return ITEM_INTERACT_SUCCESS
		if((ACCESS_COMMAND in card.access))
			if(!bsa_unlock)
				bsa_unlock = TRUE
				to_chat(user, span_notice("[src] firing protocols have been unlocked."))	//I copied this function from mechfab code, maybe could use rewording.
				user.log_message("has unlocked [src].", LOG_GAME)
			else
				bsa_unlock = FALSE
				to_chat(user, span_notice("[src] firing protocols have been locked."))
				user.log_message("has locked [src].", LOG_GAME)
			update_static_data_for_all_viewers()
			return ITEM_INTERACT_SUCCESS
	return NONE

/obj/machinery/computer/bsa_control/multitool_act(mob/living/user, obj/item/multitool/M)
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_SUCCESS
	if(!rigged_to_blow)
		balloon_alert(user, "rigged to explode")
		to_chat(user, span_warning("You pulse [src] and hear the focusing crystal short out. You get the feeling it wouldn't be wise to stand near [src] when the BSA fires..."))
		user.log_message("has rigged [src] to detonate itself.", LOG_GAME)
		rigged_to_blow = TRUE
	else
		balloon_alert(user, "safeties restored")
		to_chat(user, span_warning("You pulse [src] and restore the focusing crystal. It appears someone had rigged the BSA to explode..."))
		user.log_message("has restored the safeties of [src].", LOG_GAME)
		rigged_to_blow = FALSE
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/bsa_control/emp_act(severity)
	. = ..()
	rigged_to_blow = TRUE	//EMPs will make the BSA fire on itself if you don't check with multitool.
	log_game("An EMP has rigged [src] to detonate itself.")

/obj/machinery/computer/bsa_control/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	bsa_unlock = TRUE
	balloon_alert(user, "unlocked")
	to_chat(user, span_warning("You emag [src] bypass the authentication lock."))
	user.log_message("has unlocked [src] with an emag.", LOG_GAME)
	return TRUE
