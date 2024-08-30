/obj/item/artifact_item
	//This is literally just an artifact, but s m o l for item generation of traits that require it.

	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	icon = 'icons/obj/artifacts.dmi'
	inhand_icon_state = "plasmashiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	var/datum/component/artifact/assoc_comp = /datum/component/artifact

ARTIFACT_SETUP(/obj/item/artifact_item, SSobj, null, null, ARTIFACT_SIZE_SMALL)
