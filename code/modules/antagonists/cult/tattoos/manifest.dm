
/datum/cult_tattoo/manifest
	name = TATTOO_MANIFEST
	desc = "Acquire a new, fully healed body that cannot feel pain."
	icon_state = "manifest"
	tier = 3


/datum/cult_tattoo/manifest/getTattoo(mob/M)
	..()
	var/mob/living/carbon/human/H = bearer
	if (!istype(H))
		return
	H.revive(0)
	H.status_flags &= ~CANSTUN
	H.status_flags &= ~CANKNOCKDOWN
	H.regenerate_icons()
