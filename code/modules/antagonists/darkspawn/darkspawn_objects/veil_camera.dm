GLOBAL_DATUM(thrallnet, /datum/cameranet)
//////////////////////////////////////////////////////////////////////////
//-------------------------Access the veilnet---------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/machinery/computer/camera_advanced/darkspawn
	name = "dark orb"
	desc = "An unsettling swirling mass of darkness. Gazing into it seems to reveal forbidden knowledge."
	icon = 'icons/obj/darkspawn_items.dmi'
	icon_state = "panopticon"
	special_appearance = TRUE
	use_power = NO_POWER_USE
	flags_1 = NODECONSTRUCT_1
	max_integrity = 200
	integrity_failure = 0
	light_power = -1
	light_color = COLOR_VELVET
	networks = list(ROLE_DARKSPAWN)
	clicksound = "crawling_shadows_walk"
	jump_action = /datum/action/innate/camera_jump/darkspawn

/obj/machinery/computer/camera_advanced/darkspawn/Initialize(mapload)
	. = ..()
	camnet = GLOB.thrallnet
	src.set_light(l_power = light_power, l_color = light_color)
	interaction_flags_machine |= INTERACT_MACHINE_OFFLINE
	actions += new /datum/action/innate/camera_jump/darkspawn/void_eye(src)

/obj/machinery/computer/camera_advanced/darkspawn/on_set_is_operational(old_value)
	return

/obj/machinery/computer/camera_advanced/darkspawn/CreateEye()
	if(eyeobj)
		CRASH("Tried to make another eyeobj for some reason. Why?")
	eyeobj = new /mob/eye/camera/remote/darkspawn(get_turf(src), src)
	eyeobj.camnet = camnet
	return TRUE

/mob/eye/camera/remote/darkspawn/update_remote_sight(mob/living/user)
	user.set_invis_see(SEE_INVISIBLE_LIVING) //can't see ghosts through cameras
	user.set_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
	return TRUE

/obj/machinery/computer/camera_advanced/darkspawn/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return

/obj/machinery/computer/camera_advanced/darkspawn/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	return

/obj/machinery/computer/camera_advanced/darkspawn/remove_eye_control(mob/living/user)
	. = ..()
	playsound(src, "crawling_shadows_walk", 35, FALSE)

//special ability to replace sound effects
/datum/action/innate/camera_jump/darkspawn
	name = "Jump To Ally"
	/// Header for the selection list.
	var/menu_title = "Allies"
	/// Prompt for the selection list.
	var/menu_prompt = "Ally to view"

/// Whether [netcam] belongs in this jump action's list. Allies are thrall bodycams; void eyes are filtered out.
/datum/action/innate/camera_jump/darkspawn/proc/valid_target(obj/machinery/camera/netcam)
	return !istype(netcam, /obj/machinery/camera/darkspawn)

/datum/action/innate/camera_jump/darkspawn/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin_ref?.resolve()
	if(!origin)
		return

	var/list/T = list()
	for(var/obj/machinery/camera/netcam as anything in origin.camnet.cameras)
		if(length(origin.z_lock) && !(netcam.z in origin.z_lock))
			continue
		if(!netcam.c_tag)
			continue
		if(!valid_target(netcam))
			continue
		if(!length(netcam.network & origin.networks))
			continue
		T["[netcam.c_tag][netcam.can_use() ? null : " (Deactivated)"]"] = netcam

	playsound(origin, "crawling_shadows_walk", 25, FALSE)
	var/camera = tgui_input_list(usr, menu_prompt, menu_title, T)
	if(isnull(camera))
		return
	var/obj/machinery/camera/final = T[camera]
	if(isnull(final))
		return
	playsound(origin, "crawling_shadows_walk", 25, FALSE)
	remote_eye.setLoc(get_turf(final))
	owner.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
	owner.clear_fullscreen("flash", 1) //Shorter flash than normal since it's an ~~advanced~~ console!

/datum/action/innate/camera_jump/darkspawn/void_eye
	name = "Jump To Void Eye"
	menu_title = "Void Eyes"
	menu_prompt = "Eye to view"

/datum/action/innate/camera_jump/darkspawn/void_eye/valid_target(obj/machinery/camera/netcam)
	return istype(netcam, /obj/machinery/camera/darkspawn)

//////////////////////////////////////////////////////////////////////////
//-------------------------Expand the veilnet---------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/machinery/camera/darkspawn
	name = "void eye"
	use_power = NO_POWER_USE
	max_integrity = 20
	integrity_failure = 20
	icon = 'icons/obj/darkspawn_items.dmi'
	icon_state = "camera"
	special_camera = TRUE
	internal_light = FALSE
	armor_type = /datum/armor/machinery_camera
	flags_1 = NODECONSTRUCT_1
	network = list(ROLE_DARKSPAWN)
	view_range = MAX_CAMERA_RANGE

/obj/machinery/camera/darkspawn/Initialize(mapload)
	. = ..()
	var/static/list/eyes_per_area = list()
	var/area/eye_area = get_area(src)
	var/number = eyes_per_area[eye_area] + 1
	eyes_per_area[eye_area] = number
	c_tag = "[format_text(eye_area.name)] #[number]"

/obj/machinery/camera/darkspawn/default_camera_net()
	return GLOB.thrallnet

/obj/machinery/camera/darkspawn/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	return

/obj/machinery/camera/darkspawn/emp_act(severity, reset_time = 10)
	return

/obj/machinery/camera/darkspawn/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/wirecutter_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/multitool_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/welder_act(mob/living/user, obj/item/I)
	return

/obj/machinery/camera/darkspawn/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)
