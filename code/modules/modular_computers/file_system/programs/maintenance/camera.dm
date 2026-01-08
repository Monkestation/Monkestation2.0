/datum/computer_file/program/maintenance/camera
	filename = "camera_app"
	filedesc = "Camera"
	program_open_overlay = "camera"
	downloader_category = PROGRAM_CATEGORY_EQUIPMENT
	extended_desc = "This program allows the taking of pictures."
	size = 4
	can_run_on_flags = PROGRAM_PDA
	tgui_id = "NtosCamera"
	program_icon = "camera"

	/// Camera built-into the tablet.
	var/obj/item/camera/internal_camera
	/// Latest picture taken by the app.
	var/datum/picture/internal_picture
	/// How many pictures were taken already, used for the camera's TGUI photo display
	var/picture_number = 1

/datum/computer_file/program/maintenance/camera/on_install()
	. = ..()
	internal_camera = new(computer)
	internal_camera.print_picture_on_snap = FALSE
	RegisterSignal(internal_camera, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(save_picture))

/datum/computer_file/program/maintenance/camera/Destroy()
	QDEL_NULL(internal_camera)
	QDEL_NULL(internal_picture)
	return ..()

/datum/computer_file/program/maintenance/camera/tap(atom/tapped_atom, mob/living/user, params)
	. = ..()
	QDEL_NULL(internal_picture)
	if(internal_camera.blending)
		user.balloon_alert(user, "still blending!")
		return
	var/turf/our_turf = get_turf(tapped_atom)
	INVOKE_ASYNC(internal_camera, TYPE_PROC_REF(/obj/item/camera, captureimage), our_turf, user, internal_camera.picture_size_x + 1, internal_camera.picture_size_y + 1)

/datum/computer_file/program/maintenance/camera/proc/save_picture(cam, target, user, datum/picture/picture)
	SIGNAL_HANDLER

	internal_picture = picture
	picture_number++
	computer.save_photo(internal_picture.picture_image)

/datum/computer_file/program/maintenance/camera/ui_data(mob/user)
	var/list/data = list()

	if(!isnull(internal_picture))
		user << browse_rsc(internal_picture.picture_image, "tmp_photo[picture_number].png")
		data["photo"] = "tmp_photo[picture_number].png"

	data["paper_left"] = computer.stored_paper

	return data

/datum/computer_file/program/maintenance/camera/ui_act(action, params, datum/tgui/ui)
	var/mob/living/user = usr
	switch(action)
		if("print_photo")
			if(computer.stored_paper <= 0)
				to_chat(ui.user, span_notice("Hardware error: Printer out of paper."))
				return
			internal_camera.printpicture(user, internal_picture)
			computer.stored_paper--
			computer.visible_message(span_notice("\The [computer] prints out a paper."))
