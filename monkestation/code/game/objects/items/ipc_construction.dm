/// IPC Building
/obj/item/ipc_chest
	name = "ipc chest (ipc assembly)"
	desc = "A complex metal chest cavity with standard limb sockets and pseudomuscle anchors."
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_state = "synth_chest"

/obj/item/ipc_chest/Initialize(mapload)
	. = ..()
	var/mob/living/carbon/human/species/ipc/ipc_body = new /mob/living/carbon/human/species/ipc(get_turf(src))
	/// Remove those bodyparts
	for(var/ipc_body_parts in ipc_body.bodyparts)
		var/obj/item/bodypart/bodypart = ipc_body_parts
		if(bodypart.body_part != CHEST)
			QDEL_NULL(bodypart)
	/// Remove those organs
	for (var/ipc_organ in ipc_body.organs)
		qdel(ipc_organ)

	/// Update current body to be limbless
	ipc_body.update_icon()
	ADD_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)
	ipc_body.death()
	REMOVE_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)
	ADD_TRAIT(ipc_body, TRAIT_PACIFISM, type)
	/// Remove placeholder ipc_chest
	qdel(src)
