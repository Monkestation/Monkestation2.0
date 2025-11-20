/image/Destroy(force)
	if(force)
		return ..()

	. = QDEL_HINT_LETMELIVE
	CRASH("Something tried to qdel a [type], which shouldn't happen! (icon: [icon] - icon_state: [icon_state] [loc ? "loc: [loc] ([loc.x],[loc.y],[loc.z])" : ""])")
