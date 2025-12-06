// Blob Overmind Controls

/mob/eye/blob/ClickOn(atom/clicked_on, params) //Expand blob
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(clicked_on, params)
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		ShiftClickOn(clicked_on)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
		AltClickOn(clicked_on)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(clicked_on)
		return
	var/turf/clicked_turf = get_turf(clicked_on)
	if(clicked_turf)
		expand_blob(clicked_turf)

/mob/eye/blob/MiddleClickOn(atom/middle_clicked_on) //Rally spores
	. = ..()
	var/turf/clicked_turf = get_turf(middle_clicked_on)
	if(clicked_turf)
		rally_spores(clicked_turf)

/mob/eye/blob/CtrlClickOn(atom/ctrl_clicked_on) //Do Ctrl click logic
	var/turf/clicked_turf = get_turf(ctrl_clicked_on)
	if(clicked_turf)
		var/obj/structure/blob/clicked_blob = locate() in clicked_turf
		clicked_blob?.handle_ctrl_click(src)

/mob/eye/blob/AltClickOn(atom/alt_clicked_on) //Remove a blob
	if(istype(src, /mob/eye/blob/lesser)) //might want to make this only be for structures
		return
	var/turf/clicked_turf = get_turf(alt_clicked_on)
	if(clicked_turf)
		remove_blob(clicked_turf)
