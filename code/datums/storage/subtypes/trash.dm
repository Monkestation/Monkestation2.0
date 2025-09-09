/datum/storage/trash

/datum/storage/trash/remove_single(mob/removing, obj/item/thing, atom/newLoc, silent)

	real_location.visible_message(span_notice("[removing] starts fishing around inside \the [real_location]."),
		span_notice("You start digging around in \the [real_location] to try and pull something out."))
	if(!do_after(removing, 1.5 SECONDS, real_location))
		return

	return ..()

