/datum/supply_pack/security/armory/eva
	name = "Security Hardsuit Crate"
	desc = "Contains two security hardsuits and two security jetpacks."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(
		/obj/item/clothing/suit/space/hardsuit/sec = 2,
		/obj/item/tank/jetpack/security = 2,
	)
	crate_name = "security hardsuit crate"
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/engineering/eva
	name = "Engineering Hardsuit Crate"
	desc = "Contains two engineering hardsuits and two oxygen jetpacks."
	cost = CARGO_CRATE_VALUE * 10
	access = ACCESS_CE
	contains = list(
		/obj/item/clothing/suit/space/hardsuit/engine = 2,
		/obj/item/tank/jetpack/oxygen = 2,
	)
	crate_name = "hardsuit crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/engineering/eva/atmos
	name = "Atmos Hardsuit Crate"
	desc = "Contains two atmospheric hardsuits and two oxygen jetpacks."
	cost = CARGO_CRATE_VALUE * 10
	access = ACCESS_CE
	contains = list(
		/obj/item/clothing/suit/space/hardsuit/atmos = 2,
		/obj/item/tank/jetpack/oxygen = 2,
	)
	crate_name = "hardsuit crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/misc/hardsuit_jetpack_upgrade
	name = "Hardsuit Jetpack Uprade"
	desc = "Contains an upgrade module which allows you to attach any jetpack to any hardsuit"
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/jetpack_module)
	crate_name = "hardsuit jetpack upgrade"
