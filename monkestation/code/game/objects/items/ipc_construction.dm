/// IPC Building
/obj/item/ipc_core
	name = "ipc core"
	desc = "A complex metal chest cavity with standard limb sockets and pseudomuscle anchors."
	icon = 'monkestation/icons/mob/species/ipc/bodyparts.dmi'
	icon_state = "synth_chest"

/obj/item/ipc_core/Initialize(mapload)
	. = ..()
	var/mob/living/carbon/human/species/ipc/ipc_body = new /mob/living/carbon/human/species/ipc(get_turf(src))
	/// Remove those bodyparts
	for(var/ipc_body_parts in ipc_body.bodyparts)
		var/obj/item/bodypart/bodypart = ipc_body_parts
		if(bodypart.body_part != CHEST)
			QDEL_NULL(bodypart)
	/// Remove those organs
	for (var/obj/item/organ/internal/organs in ipc_body.organs)
		qdel(organs)
	/// We have to manually blind it, because qdel'ing the eyes doesn't trigger the organ loss proc tha blinds.
	ipc_body.become_blind(NO_EYES)
	/// Remove clothes, facial hair, features.
	ipc_body.undershirt = null
	ipc_body.underwear = null
	ipc_body.socks = null
	ipc_body.facial_hairstyle = null
	ipc_body.hairstyle = null
	ipc_body.dna.features["ipc_screen"] = null
	/// Null deathsound and emote ability
	ipc_body.death_sound = null
	ADD_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)
	ipc_body.death()
	/// Reapply deathsound and emote ability
	ipc_body.death_sound = 'sound/voice/borg_deathsound.ogg'
	REMOVE_TRAIT(ipc_body, TRAIT_EMOTEMUTE, type)
	/// Remove placeholder ipc_core
	qdel(src)
	/// Update current body to be limbless
	ipc_body.regenerate_icons()
