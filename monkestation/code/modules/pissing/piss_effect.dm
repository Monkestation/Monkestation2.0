/obj/effect/decal/cleanable/piss_stain
	name = "piss puddle"
	desc = "Who would piss on the floor?"
	icon = 'icons/effects/effects.dmi'
	icon_state = "piss_puddle"

/obj/effect/decal/cleanable/piss_stain/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 10 MINUTES)
