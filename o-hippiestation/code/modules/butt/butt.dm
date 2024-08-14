/obj/item/organ/internal/butt/proc/open_butt_pocket(mob/living/carbon/user)
	if(!owner)
		return
	if(!atom_storage)
		create_storage(storage_type = /datum/storage/pockets/, attack_hand_interact = FALSE)
		loc = owner
	if(atom_storage.is_using.len != 0)
		balloon_alert(user, "already open")
		return FALSE
	atom_storage.open_storage(user)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_butt_moved))
	return TRUE

/obj/item/organ/internal/butt/proc/on_butt_moved()
	SIGNAL_HANDLER
	if(atom_storage.is_using.len != 0)
		atom_storage.close_all()

	for(var/obj/item/I in contents)
		if(I.sharpness == SHARP_EDGED)
			owner.bleed(4)

/obj/item/organ/internal/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_MOVABLE_MOVED)
	if(atom_storage)
		atom_storage?.remove_all(organ_owner.loc)
		qdel(atom_storage)


