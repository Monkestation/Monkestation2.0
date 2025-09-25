/obj/item/chasm_filler
	name = "chasm filler capsule"
	desc = "A capsule containing a large amount of compressed dirt, intended to cover chasms. The dirt is slow to walk through, though."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	/// Has this chasm filler been used?
	var/used = FALSE
	/// The range of which it will fill chasms.
	var/range = 5
	/// The typepath of the turf that chasms will be replaced with.
	var/turf_type = /turf/open/misc/dirt/filling

/obj/item/chasm_filler/examine(mob/user)
	. = ..()
	. += span_notice("To use, the capsule must be activated first, and then thrown into a chasm.")

/obj/item/chasm_filler/interact(mob/user)
	. = ..()
	if(.)
		return .
	if(used)
		return FALSE
	loc.visible_message(span_warning("[src] begins to shake, throw it into a chasm now!"))
	used = TRUE
	addtimer(CALLBACK(src, PROC_REF(fill_chasm)), 5 SECONDS)
	return TRUE

/obj/item/chasm_filler/proc/fill_chasm()
	if(!istype(loc, /obj/effect/abstract/chasm_storage))
		used = FALSE
		loc.visible_message(span_warning("[src] is not in a chasm, it has nothing to fill!"))
		return
	for(var/turf/open/chasm/chasm in range(range, get_turf(src)))
		var/turf/open/new_turf = chasm.PlaceOnTop(turf_type, flags = CHANGETURF_INHERIT_AIR)
		playsound(new_turf, 'sound/effects/break_stone.ogg', 20, vary = TRUE) // not too loud, as a lot of these may play at once.
	qdel(src)
