/datum/supply_pack/imports/servicepistol
	name = "Service pistol crate"
	desc = "!&@#Some classic pistols for the classic spaceman.!%!$#"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/gun/ballistic/revolver/nagant = 2,
					/obj/item/ammo_box/n762 = 2)
	crate_name = "Emergency Crate"

/datum/supply_pack/imports/pistolmags
	name = "Service pistol ammo"
	desc = "%$!#More ammo for your beloved antique.%!#@"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/ammo_box/n762 = 6)
	crate_name = "Emergency Crate"

/datum/supply_pack/imports/Lrevolvercrate
	name = "Long Revolver Crate"
	desc = "We got these old revolvers from a unnamed man, enjoy them"
	cost = CARGO_CRATE_VALUE * 10
	contains = list(
		/obj/item/gun/ballistic/revolver/r45l = 2,
		/obj/item/ammo_box/g45l = 1,
		/obj/item/ammo_box/g45l/rubber = 1,
	)
	crate_name = "Long Revolver crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/Briflecrate
	name = "Bush Rifle Crate"
	desc = "These old rifles were sold to us by a unnamed man, quite the bargin"
	cost = CARGO_CRATE_VALUE * 7
	contains = list(
		/obj/item/gun/ballistic/rifle/leveraction = 3,
		/obj/item/ammo_box/g45l = 2,
		/obj/item/ammo_box/g45l/rubber = 1,
	)
	crate_name = "Bush Rifle crate"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/imports/fss
	name = "FSS-550 Design Disk"
	desc = "Do you hate gun control? So do I! This will let any autolathe produce more guns than security can keep track of!"
	cost = CARGO_CRATE_VALUE * 10
	hidden = TRUE
	contains = list(/obj/item/disk/design_disk/fss)
	crate_name = "Emergency Crate"
