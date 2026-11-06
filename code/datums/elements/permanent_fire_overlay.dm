/// When applied to a mob, they will always have a fire overlay regardless of if they are *actually* on fire.
/datum/element/perma_fire_overlay
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/fire_stacks = MAX_FIRE_STACKS
	var/fire_color

/datum/element/perma_fire_overlay/Attach(atom/target, fire_stacks = MAX_FIRE_STACKS, fire_color)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.fire_stacks = fire_stacks
	src.fire_color = fire_color
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_fire_overlay))
	target.update_appearance(UPDATE_OVERLAYS)

/datum/element/perma_fire_overlay/Detach(atom/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS)
	target.update_appearance(UPDATE_OVERLAYS)

/datum/element/perma_fire_overlay/proc/add_fire_overlay(mob/living/source, list/overlays)
	SIGNAL_HANDLER

	var/mutable_appearance/created_overlay = source.get_fire_overlay(stacks = fire_stacks, on_fire = TRUE)
	if(isnull(created_overlay))
		return

	if(fire_color) // fire overlays are cached
		created_overlay = new(created_overlay)
		created_overlay.color = fire_color
	overlays |= created_overlay
