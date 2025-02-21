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

/obj/item/implant/sponsorship/storage_emagged(mob/user, obj/item/card/emag/emag_card)
	balloon_alert(user, "tuned into the Syndicate Propaganda Network")
	return new /obj/item/implant/syndi_propaganda(src)

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

/obj/item/storage/lockbox/sponsorship
	name = "lockbox of sponsorship implants"
	desc = "Requires command access to open."
	req_access = list(ACCESS_COMMAND)

/obj/item/storage/lockbox/sponsorship/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/sponsorship(src)
	new /obj/item/implanter/sponsorship(src)

// Traitor Variant

/obj/item/implant/syndi_propaganda
	name = "hacked sponsorship implant"
	actions_types = null
	implant_color = "r"
	allow_multiple = TRUE

/obj/item/implant/syndi_propaganda/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return FALSE
	target.AddComponentFrom(src, /datum/component/advert_force_speak, 0.5 MINUTES)
	ADD_TRAIT(target, TRAIT_SPONSOR_IMPLANT_SYNDI, REF(src))
	for (var/datum/component/propaganda_target/objective in target.GetComponents(/datum/component/propaganda_target))
		objective.implanted()
	return TRUE

/obj/item/implant/syndi_propaganda/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(!.)
		return FALSE
	target.AddComponentFrom(src, /datum/component/advert_force_speak)
	REMOVE_TRAIT(target, TRAIT_SPONSOR_IMPLANT_SYNDI, REF(src))
	return TRUE

/obj/item/implant/syndi_propaganda/storage_emagged(mob/user, obj/item/card/emag/emag_card)
	balloon_alert(user, "tuned into the NT Advertisement Network")
	return new /obj/item/implant/sponsorship(src)

// Traitor Gear

/obj/item/implantcase/syndi_propaganda
	name = "implant case - 'syndicate propaganda'"
	desc = "Creates a neural connection directly from the Syndicate Propaganda Network to the target's mouth or an implanted speaker. \
		Each message is roughly 10 mins apart and has a revenue of -40 credits. Emag to retune into the NT Advertisement Network."
	imp_type = /obj/item/implant/syndi_propaganda

/obj/item/implanter/syndi_propaganda
	name = "implanter (relabel with pen)"
	imp_type = /obj/item/implant/syndi_propaganda

/obj/item/storage/box/syndie_kit/syndi_propaganda
	name = "hacked sponsorship implants"

/obj/item/storage/box/syndie_kit/syndi_propaganda/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/syndi_propaganda(src)
	new /obj/item/implanter/syndi_propaganda(src)
