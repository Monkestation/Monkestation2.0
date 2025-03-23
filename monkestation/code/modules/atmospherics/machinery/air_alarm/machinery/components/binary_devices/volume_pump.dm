/obj/machinery/atmospherics/components/binary/volume_pump/CtrlClick(mob/user)
	if(isganymede(user))
		to_chat(user, "<span class='danger'>\The [src] is too small for your big hands to adjust!</span>")
		return
	return ..()

/obj/machinery/atmospherics/components/binary/volume_pump/AltClick(mob/user)
	if(isganymede(user))
		to_chat(user, "<span class='danger'>\The [src] is too small for your big hands to adjust!</span>")
		return
	return ..()

/obj/machinery/atmospherics/components/binary/volume_pump/ui_interact(mob/user, datum/tgui/ui)
	if(isganymede(user))
		to_chat(user, "<span class='danger'>\The [src] is too small for your big hands to adjust!</span>")
		return
	return ..()
