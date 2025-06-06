/image/Destroy(force)
	if(force)
		return ..()

	. = QDEL_HINT_LETMELIVE
	CRASH("Image Destroy() invoked. (icon: [icon] - icon_state: [icon_state] [loc ? "loc: [loc] ([loc.x],[loc.y],[loc.z])" : ""])")
