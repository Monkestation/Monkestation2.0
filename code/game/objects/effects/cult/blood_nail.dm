
/obj/effect/rooting_trap/bloodnail
	name = "blood nail"
	desc = "A pointy red nail, appearing to pierce not through what it rests upon, but through the fabric of reality itself."
	icon_state = "bloodnail"
	icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi'

/obj/effect/rooting_trap/bloodnail/New()
	..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/effect/rooting_trap/bloodnail/stick_to(atom/A, side = null)
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)
	var/turf/T = get_turf(A)
	. = ..()
	if (.)
		visible_message(span_warning("\The [src] nails \the [A] to \the [T].") )
