/particles/Destroy(force)
	if(force)
		return ..()

	. = QDEL_HINT_LETMELIVE
	CRASH("Something tried to qdel a [type], which shouldn't happen!")
