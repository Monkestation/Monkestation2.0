/obj/item/implant/sponsorship
	name = "sponsorship implant"
	actions_types = null
	allow_multiple = TRUE

/obj/item/implant/sponsorship/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	target.AddComponentFrom(src, /datum/component/advert_force_speak)
	ADD_TRAIT(target, TRAIT_SPONSOR_IMPLANT, REF(src))
	return TRUE

/obj/item/implant/sponsorship/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(!.)
		return FALSE
	target.RemoveComponentSource(src, /datum/component/advert_force_speak)
	REMOVE_TRAIT(target, TRAIT_SPONSOR_IMPLANT, REF(src))
	return TRUE

// Gear

/obj/item/implanter/sponsorship
	name = "implanter (sponsorship)"
	desc = "Creates a neural connection directly from the NT Advertisement Network to the target's mouth or an implanted speaker. \
		Each ad is roughly 5 mins apart and has a revenue of 5 credits."
	imp_type = /obj/item/implant/sponsorship

/obj/item/implantcase/sponsorship
	name = "implant case - 'Sponsorship'"
	desc = "Creates a neural connection directly from the NT Advertisement Network to the target's mouth or an implanted speaker. \
		Each ad is roughly 5 mins apart and has a revenue of 5 credits."
	imp_type = /obj/item/implant/sponsorship

/obj/item/storage/briefcase/sponsorship
	name = "sponsorship implant briefcase"

/obj/item/storage/briefcase/sponsorship/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/sponsorship(src)
	new /obj/item/implanter/sponsorship(src)
