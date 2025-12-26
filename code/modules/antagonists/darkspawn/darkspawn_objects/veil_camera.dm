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
	networks = list(CAMERANET_NETWORK_DARKSPAWN)
	clicksound = "crawling_shadows_walk"
	jump_action = /datum/action/innate/camera_jump/darkspawn

/obj/machinery/computer/camera_advanced/darkspawn/Initialize(mapload)
	. = ..()
	src.set_light(l_power = light_power, l_color = light_color)

/obj/machinery/computer/camera_advanced/darkspawn/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return

/obj/machinery/computer/camera_advanced/darkspawn/remove_eye_control(mob/living/user)
	. = ..()
	playsound(src, "crawling_shadows_walk", 35, FALSE)

//special ability to replace sound effects
/datum/action/innate/camera_jump/darkspawn
	name = "Jump To Ally"

/datum/action/innate/camera_jump/darkspawn/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/eye/camera/remote/remote_eye = owner.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin_ref.resolve()

	var/list/cameras_by_tag = SScameras.get_available_camera_by_tag_list(origin.networks, origin.z_lock)

	playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
	var/camera = tgui_input_list(usr, "Ally to view", "Cameras", cameras_by_tag)
	if(isnull(camera))
		return

	playsound(src, SFX_TERMINAL_TYPE, 25, FALSE)

	var/obj/machinery/camera/chosen_camera = cameras_by_tag[camera]
	if(isnull(chosen_camera))
		playsound(origin, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)
		return

	playsound(origin, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
	remote_eye.setLoc(get_turf(chosen_camera))
	owner.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
	owner.clear_fullscreen("flash", 3) //Shorter flash than normal since it's an ~~advanced~~ console!

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
	network = list(CAMERANET_NETWORK_DARKSPAWN)
	view_range = 10

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
