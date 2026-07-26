/obj/machinery/door/firedoor/window
	name = "window shutter"
	icon = 'icons/obj/doors/doorfirewindow.dmi'
	desc = "A second window that slides in when the original window is broken, designed to protect against hull breaches. Truly a work of genius by NT engineers, however it was abandoned in a week due to budget cuts."
	glass = TRUE
	explosion_block = 0
	max_integrity = 50
	resistance_flags = 0 // Not fireproof
	heat_proof = FALSE

/obj/machinery/door/firedoor/window/bumpopen(mob/user)
	if(panel_open || operating || welded || !powered())
		return FALSE
	add_fingerprint(user)
	open()
	return TRUE
