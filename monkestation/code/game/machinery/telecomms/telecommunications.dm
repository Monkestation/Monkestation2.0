/obj/machinery/telecomms/ui_interact(mob/user)
	if(isganymede(user))
		to_chat(user, "<span class='warning'>Your enormous hands can't possibly fiddle with that!</span>")
		return
	return ..()
