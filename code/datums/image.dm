/image/Destroy(force, ...)
	if(force)
		return ..()

	. = QDEL_HINT_LETMELIVE
	CRASH("Image Destroy() invoked.")
