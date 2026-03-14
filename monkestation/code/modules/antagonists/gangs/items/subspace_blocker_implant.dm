/obj/item/implant/subspace_blocker
	name = "subspace blocker implant"
	desc = "Emits a low range field preventing the use of concealed long range communication devices."

/obj/item/implant/subspace_blocker/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(!.)
		return

	ADD_TRAIT(target, TRAIT_UPLINK_USE_BLOCKED, REF(src))

/obj/item/implant/subspace_blocker/removed(mob/living/source, silent, special, forced)
	. = ..()
	if(!.)
		return

	REMOVE_TRAIT(source, TRAIT_UPLINK_USE_BLOCKED, REF(src))

/obj/item/implantcase/subspace_blocker
	name = "implant case - 'Subspace Blocker'"
	desc = "A glass case containing a subspace blocker implant."
	imp_type = /obj/item/implant/subspace_blocker

/obj/item/implanter/subspace_blocker
	name = "implanter (subspace blocker)"
	imp_type = /obj/item/implant/subspace_blocker

/obj/item/storage/lockbox/subspace_blocker
	name = "lockbox of subspace blocker implants"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/subspace_blocker/PopulateContents()
	new /obj/item/implanter/subspace_blocker(src)
	for(var/i in 1 to 4)
		new /obj/item/implantcase/subspace_blocker(src)

/datum/supply_pack/security/subspace_blocker
	name = "Subspace Blocker Implants Crate"
	desc = "Prevent against the use of concealed long range communication with this implant."
	cost = CARGO_CRATE_VALUE * 25 //expensive and only buyable in bulk, should only be bought when needed
	contains = list(/obj/item/storage/lockbox/subspace_blocker)
	crate_name = "subspace blocker implants crate"
