/obj/item/organ/internal/brain/shadow/nightmare/on_insert(mob/living/carbon/brain_owner)
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))

/obj/item/organ/internal/brain/shadow/nightmare/on_life(seconds_per_tick, times_fired)
	check_passive_nightmare_snuff(owner)
	return ..()

/obj/item/organ/internal/brain/shadow/nightmare/proc/on_owner_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	check_passive_nightmare_snuff(owner)
