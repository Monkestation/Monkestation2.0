/datum/supply_pack/security
	group = "Security"
	access = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/ammo
	name = "Ammo Crate"
	desc = "Contains two boxes of beanbag shotgun shells, two boxes \
		of rubbershot shotgun shells, two boxes of buckshot, and one of each special .38 speedloaders."
	cost = CARGO_CRATE_VALUE * 8
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/ammo_box/advanced/s12gauge/bean = 2,
					/obj/item/ammo_box/advanced/s12gauge/rubber = 2,
					/obj/item/ammo_box/advanced/s12gauge/buckshot = 2,
					/obj/item/ammo_box/c38/trac,
					/obj/item/ammo_box/c38/hotshot,
					/obj/item/ammo_box/c38/iceblox,
				)
	crate_name = "ammo crate"

/datum/supply_pack/security/armor
	name = "Armor Crate"
	desc = "Three sets of well-rounded, decently-protective armor."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/suit/armor/vest = 3,
					/obj/item/clothing/head/helmet/sec = 3,
				)
	crate_name = "armor crate"

/datum/supply_pack/security/disabler
	name = "Disabler Crate"
	desc = "Three stamina-draining disabler weapons."
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/gun/energy/disabler = 3)
	crate_name = "disabler crate"

/datum/supply_pack/security/forensics
	name = "Forensics Crate"
	desc = "Stay hot on the criminal's heels with Nanotrasen's Detective Essentials™. \
		Contains a forensics scanner, six evidence bags, camera, special board for evidences, tape recorder, stick of chalk, \
		and of course, a fedora."
	cost = CARGO_CRATE_VALUE * 2.5
	access_view = ACCESS_MORGUE
	contains = list(/obj/item/detective_scanner,
					/obj/item/storage/box/evidence,
					/obj/item/camera,
					/obj/item/taperecorder,
					/obj/item/toy/crayon/white,
					/obj/item/clothing/head/fedora/det_hat,
				)
	crate_name = "forensics crate"

/datum/supply_pack/security/laser
	name = "Lasers Crate"
	desc = "Contains three lethal, high-energy laser guns."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/gun/energy/laser = 3)
	crate_name = "laser crate"

/datum/supply_pack/security/securitybarriers
	name = "Security Barrier Grenades"
	desc = "Stem the tide with four Security Barrier grenades."
	access_view = ACCESS_BRIG
	contains = list(/obj/item/grenade/barrier = 4)
	cost = CARGO_CRATE_VALUE * 2
	crate_name = "security barriers crate"

/datum/supply_pack/security/securityclothes
	name = "Security Clothing Crate"
	desc = "Contains appropriate outfits for the station's private security force. \
		Contains outfits for the Warden, Head of Security, and two Security Officers. \
		Each outfit comes with a rank-appropriate jumpsuit, suit, and beret."
	cost = CARGO_CRATE_VALUE * 3
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/under/rank/security/officer/formal = 2,
					/obj/item/clothing/suit/jacket/officer/blue = 2,
					/obj/item/clothing/head/beret/sec/navyofficer = 2,
					/obj/item/clothing/under/rank/security/warden/formal,
					/obj/item/clothing/suit/jacket/warden/blue,
					/obj/item/clothing/head/beret/sec/navywarden,
					/obj/item/clothing/under/rank/security/head_of_security/formal,
					/obj/item/clothing/suit/jacket/hos/blue,
					/obj/item/clothing/head/hats/hos/beret/navyhos,
				)
	crate_name = "security clothing crate"

/datum/supply_pack/security/stingpack
	name = "Stingbang Grenade Pack"
	desc = "Contains five \"stingbang\" grenades, perfect for stopping \
		riots and playing morally unthinkable pranks."
	cost = CARGO_CRATE_VALUE * 5
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/stingbangs)
	crate_name = "stingbang grenade pack crate"

/datum/supply_pack/security/supplies
	name = "Security Supplies Crate"
	desc = "Contains seven flashbangs, seven smoke bombs, seven teargas grenades, six flashes, seven handcuffs, and two security utility vouchers." //monkestation edit
	cost = CARGO_CRATE_VALUE * 3.5
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/sec_smokebomb, //monkestation edit
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs,
					/obj/item/security_voucher/utility = 2, //monkestation edit
				)
	crate_name = "security supply crate"

/datum/supply_pack/security/firingpins
	name = "Standard Firing Pins Crate"
	desc = "Upgrade your arsenal with 10 standard firing pins."
	cost = 5000 //MONKESTATION EDIT: Guncargo nerf
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/firingpins = 2)
	crate_name = "firing pins crate"

/datum/supply_pack/security/firingpins/paywall
	name = "Paywall Firing Pins Crate"
	desc = "Specialized firing pins with a built-in configurable paywall."
	cost = 4000 //MONKESTATION EDIT: Guncargo nerf
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/firingpins/paywall = 2)
	crate_name = "paywall firing pins crate"

/datum/supply_pack/security/justiceinbound
	name = "Standard Justice Enforcer Crate"
	desc = "This is it. The Bee's Knees. The Creme of the Crop. The Pick of the Litter. \
		The best of the best of the best. The Crown Jewel of Nanotrasen. \
		The Alpha and the Omega of security headwear. Guaranteed to strike fear into the hearts \
		of each and every criminal aboard the station. Also comes with a security gasmask."
	cost = CARGO_CRATE_VALUE * 6 //justice comes at a price. An expensive, noisy price.
	contraband = TRUE
	contains = list(/obj/item/clothing/head/helmet/toggleable/justice,
					/obj/item/clothing/mask/gas/sechailer,
				)
	crate_name = "security clothing crate"

/datum/supply_pack/security/baton
	name = "Stun Batons Crate"
	desc = "Arm the Civil Protection Forces with three stun batons. Batteries included."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/melee/baton/security/loaded = 3)
	crate_name = "stun baton crate"

/datum/supply_pack/security/wall_flash
	name = "Wall-Mounted Flash Crate"
	desc = "Contains four wall-mounted flashes."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/box/wall_flash = 4)
	crate_name = "wall-mounted flash crate"

/datum/supply_pack/security/constable
	name = "Traditional Equipment Crate"
	desc = "Spare equipment found in a warehouse. Contains a constable's outfit, \
		whistle, and conversion kit."
	cost = CARGO_CRATE_VALUE * 2.2
	contraband = TRUE
	contains = list(/obj/item/clothing/under/rank/security/constable,
					/obj/item/clothing/head/costume/constable,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/whistle,
					/obj/item/conversion_kit,
				)

/// Armory packs

/datum/supply_pack/security/armory
	group = "Armory"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	desc = "Contains three sets of bulletproof plates and helmets. Guaranteed to reduce a bullet's \
		stopping power by over half."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/clothing/suit/armor/bulletproof = 3,
					/obj/item/clothing/head/helmet/alt = 3,
				)
	crate_name = "bulletproof armor crate"

/datum/supply_pack/security/armory/chemimp
	name = "Chemical Implants Crate"
	desc = "Contains five Remote Chemical implants."
	cost = CARGO_CRATE_VALUE * 3.5
	contains = list(/obj/item/storage/box/chemimp)
	crate_name = "chemical implant crate"

/datum/supply_pack/security/armory/ballistic
	name = "Combat Shotguns Crate"
	desc = "For when the enemy absolutely needs to be replaced with lead. \
		Contains three Aussec-designed Combat Shotguns, and three Shotgun Bandoliers."
	cost = CARGO_CRATE_VALUE * 17.5
	contains = list(/obj/item/gun/ballistic/shotgun/automatic/combat = 3,
					/obj/item/storage/belt/bandolier = 3)
	crate_name = "combat shotguns crate"

/datum/supply_pack/security/armory/dragnet //monkestation edit: dropped the amount to two from three
	name = "DRAGnet Crate"
	desc = "Contains two \"Dynamic Rapid-Apprehension of the Guilty\" netting devices, \
		a recent breakthrough in law enforcement prisoner management technology. Includes a DRAGnet beacon."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/gun/energy/e_gun/dragnet = 2,
		/obj/item/dragnet_beacon = 1,
		)
	crate_name = "\improper DRAGnet crate"

/datum/supply_pack/security/armory/energy
	name = "Energy Guns Crate"
	desc = "Contains two Energy Guns, capable of firing both nonlethal and lethal \
		blasts of light."
	cost = CARGO_CRATE_VALUE * 9
	contains = list(/obj/item/gun/energy/e_gun = 2)
	crate_name = "energy gun crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/laser_carbine
	name = "Laser Carbine Crate"
	desc = "Contains two laser carbines, capable of rapidly firing weak lasers."
	cost = CARGO_CRATE_VALUE * 9
	contains = list(/obj/item/gun/energy/laser/carbine = 2)
	crate_name = "laser carbine crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/disabler_smg //monkestation edit
	name = "Disabler SMG Crate"
	desc = "Contains three disabler SMGs, capable of rapidly firing weak disabler beams."
	cost = CARGO_CRATE_VALUE * 6
	access_view = ACCESS_SECURITY //monkestation edit
	contains = list(/obj/item/gun/energy/disabler/smg = 3)
	crate_name = "disabler smg crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/exileimp
	name = "Exile Implants Crate"
	desc = "Contains five Exile implants."
	cost = CARGO_CRATE_VALUE * 3.5
	contains = list(/obj/item/storage/box/exileimp)
	crate_name = "exile implant crate"

/datum/supply_pack/security/armory/teleport_blocker_imp
	name = "Bluespace Grounding Implants Crate"
	desc = "Contains four Bluespace Grounding implants."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/storage/box/teleport_blocker)
	crate_name = "bluespace grounding implant crate"

/datum/supply_pack/security/armory/fire
	name = "Incendiary Weapons Crate"
	desc = "Burn, baby burn. Contains three incendiary grenades, three plasma canisters, \
		and a flamethrower."
	cost = CARGO_CRATE_VALUE * 7
	access = ACCESS_COMMAND
	contains = list(/obj/item/flamethrower/full,
					/obj/item/tank/internals/plasma = 3,
					/obj/item/grenade/chem_grenade/incendiary = 3,
				)
	crate_name = "incendiary weapons crate"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/supply_pack/security/armory/mindshield
	name = "Mindshield Implants Crate"
	desc = "Prevent against radical thoughts with three Mindshield implants."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/storage/lockbox/loyalty)
	crate_name = "mindshield implant crate"

/datum/supply_pack/security/armory/trackingimp
	name = "Tracking Implants Crate"
	desc = "Contains four tracking implants and three tracking speedloaders of tracing .38 ammo."
	cost = CARGO_CRATE_VALUE * 4.5
	contains = list(/obj/item/storage/box/trackimp,
					/obj/item/ammo_box/c38/trac = 3,
				)
	crate_name = "tracking implant crate"

/datum/supply_pack/security/armory/laserarmor
	name = "Reflector Vest Crate"
	desc = "Contains two vests of highly reflective material. Each armor piece \
		diffuses a laser's energy by over half, as well as offering a good chance \
		to reflect the laser entirely."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/clothing/suit/armor/laserproof = 2)
	crate_name = "reflector vest crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/riotarmor
	name = "Riot Armor Crate"
	desc = "Contains three sets of heavy body armor. Advanced padding protects \
		against close-ranged weaponry, making melee attacks feel only half as \
		potent to the user."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/item/clothing/suit/armor/riot = 3,
					/obj/item/clothing/head/helmet/toggleable/riot = 3,
				)
	crate_name = "riot armor crate"

/datum/supply_pack/security/armory/riotshields
	name = "Riot Shields Crate"
	desc = "For when the greytide gets really uppity. Contains three riot shields."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/shield/riot = 3)
	crate_name = "riot shields crate"

/datum/supply_pack/security/armory/swat
	name = "SWAT Crate"
	desc = "Contains two fullbody sets of tough, fireproof suits designed in a joint \
		effort by IS-ERI and Nanotrasen. Each set contains a suit, helmet, mask, combat belt, \
		and combat gloves."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/clothing/head/helmet/swat/nanotrasen = 2,
					/obj/item/clothing/suit/armor/swat = 2,
					/obj/item/clothing/mask/gas/sechailer/swat = 2,
					/obj/item/storage/belt/military/assault = 2,
					/obj/item/clothing/gloves/tackler/combat = 2,
				)
	crate_name = "swat crate"

/datum/supply_pack/security/armory/thermal
	name = "Thermal Pistol Crate"
	desc = "Contains a pair of holsters each with two experimental thermal pistols, \
		using nanites as the basis for their ammo."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/storage/belt/holster/energy/thermal = 2)
	crate_name = "thermal pistol crate"

/datum/supply_pack/security/armory/rifle
	name = "Sol Autorifle Crate"
	desc = "For when the enemy only somewhat requires flesh to be displaced by lead. \
		Contains 2 Carwo-Cawil Autorifles and a single magazine for each"
	cost = CARGO_CRATE_VALUE * 17.5
	contains = list(/obj/item/gun/ballistic/automatic/sol_rifle = 2,
					/obj/item/ammo_box/magazine/c40sol_rifle/standard = 2)
	crate_name = "autorifle crate"

/datum/supply_pack/security/armory/marksman
	name = "Sol Marksman Crate"
	desc = "For accurate lead application. \
		Contains a single Cawil Marksman rifle and 3 spare magazines."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/item/gun/ballistic/automatic/sol_rifle/marksman/no_mag = 1,
					/obj/item/ammo_box/magazine/c40sol_rifle = 3)
	crate_name = "marksman rifle crate"

/datum/supply_pack/security/armory/battlerifle
	name = "Lanca Heavy Rifle Crate"
	desc = "For when they are just too far away to use a shotgun. \
		Contains 2 Lanca marksman rifles and a spare magazine for each."
	cost = CARGO_CRATE_VALUE * 17.5
	contains = list(/obj/item/gun/ballistic/automatic/lanca = 2,
					/obj/item/ammo_box/magazine/lanca = 2)
	crate_name = "battle rifle crate"
	contraband = TRUE

/datum/supply_pack/security/armory/lasrifle
	name = "Heavy Laser Crate"
	desc = "Contains 2 heavy laser rifles to replace the ones that YOU LOST"
	cost = CARGO_CRATE_VALUE * 20
	contains = list(/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano = 2)
	crate_name = "smg crate"

/datum/supply_pack/security/armory/sindano
	name = "Sindano Submachinegun Crate"
	desc = "Two entirely proprietary Sindano kits, chambered in .35 Sol Short. Each kit contains three empty magazines and a box each of incapacitator and lethal rounds."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/sindano = 2,
	)
	crate_name = "Sindano Submachinegun Crate"

/datum/supply_pack/security/armory/renoster
	name = "Renoster Riot Shotgun Crate"
	desc = "Three Renoster 12ga riot shotguns, with matching bandoliers for each."
	cost = CARGO_CRATE_VALUE * 17.5
	contains = list(
		/obj/item/gun/ballistic/shotgun/riot/sol = 3,
		/obj/item/storage/belt/bandolier = 3,
	)
	crate_name = "Renoster Riot Shotgun Crate"

/datum/supply_pack/security/armory/kiboko
	name = "Kiboko Grenade Launcher Crate"
	desc = "Contains a single Kiboko grenade launcher for replacing the one found in the armory, alongside the equipment that comes with it."
	cost = CARGO_CRATE_VALUE * 30
	contains = list(
		/obj/item/storage/toolbox/guncase/skyrat/carwo_large_case/kiboko_magless = 1,
		/obj/item/ammo_box/c980grenade = 2,
		/obj/item/ammo_box/c980grenade/smoke = 1,
		/obj/item/ammo_box/c980grenade/riot = 1,
	)
	crate_name = "Kiboko Grenade Launcher Crate"

/datum/supply_pack/security/armory/short_mod_laser
	name = "Modular Laser Carbine Crate"
	desc = "Five 'Hoshi' modular laser carbines, compact energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
		/obj/item/gun/energy/modular_laser_rifle/carbine,
	)
	crate_name = "\improper Modular Laser Carbine Crate"

/datum/supply_pack/security/armory/big_mod_laser
	name = "Modular Laser Rifle Crate"
	desc = "Three 'Hyeseong' modular laser rifles, bulky energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle,
		/obj/item/gun/energy/modular_laser_rifle,
		/obj/item/gun/energy/modular_laser_rifle,
	)
	crate_name = "\improper Modular Laser Rifle Crate"

/datum/supply_pack/security/armory/bobr
	name = "Tactical Bóbr Crate"
	desc = "Two Bóbr shotgun revolvers, with matching Tutel ballistic shields and ammo for each."
	cost = CARGO_CRATE_VALUE * 20
	contains = list(
		/obj/item/gun/ballistic/revolver/shotgun_revolver = 2,
		/obj/item/ammo_box/tacshield/tutel/ = 2,
		/obj/item/ammo_box/advanced/s12gauge = 2,
	)
	crate_name = "Tactical Bóbr Crate"

/datum/supply_pack/security/armory/antitank
	name = "Disposable Anti-Tank Rocket Crate"
	desc = "Contains a singular antiquated anti-tank rocket."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/gun/ballistic/ignifist
				)
	crate_name = "Anti-Tank Rocket crate"
	dangerous = TRUE
