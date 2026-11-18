/datum/supply_pack/security
	group = "Security"
	access = ACCESS_SECURITY
	access_view = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/supply_pack/security/ammo
	name = "Ammo Crate"
	desc = "Contains two boxes of beanbag shotgun shells, two boxes \
		of rubbershot shotgun shells, two boxes of buckshot, two boxes of slugs, and one of each special .38 speedloaders."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/item/ammo_box/advanced/s12gauge/bean = 2,
					/obj/item/ammo_box/advanced/s12gauge/rubber = 2,
					/obj/item/ammo_box/advanced/s12gauge/buckshot = 2,
					/obj/item/ammo_box/advanced/s12gauge = 2,
					/obj/item/ammo_box/c38/trac,
					/obj/item/ammo_box/c38/hotshot,
					/obj/item/ammo_box/c38/iceblox,
				)
	crate_name = "ammo crate"

/datum/supply_pack/security/armor
	name = "Armor Crate"
	desc = "Three sets of well-rounded, decently-protective armor."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/clothing/suit/armor/vest = 3,
					/obj/item/clothing/head/helmet/sec = 3,
				)
	crate_name = "armor crate"

/datum/supply_pack/security/disabler
	name = "Disabler Crate"
	desc = "Three stamina-draining disabler weapons."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/gun/energy/disabler = 3)
	crate_name = "disabler crate"

/datum/supply_pack/security/laser_carbine
	name = "Laser Carbine Crate"
	desc = "Contains three laser carbines, capable of rapidly firing weak lasers."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/gun/energy/laser/carbine = 3)
	crate_name = "laser carbine crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/disabler_smg
	name = "Disabler SMG Crate"
	desc = "Contains three disabler SMGs, capable of rapidly firing weak disabler beams."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/gun/energy/disabler/smg = 3)
	crate_name = "disabler smg crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/forensics
	name = "Forensics Crate"
	desc = "Stay hot on the criminal's heels with Nanotrasen's Detective Essentials™. \
		Contains a forensics scanner, six evidence bags, camera, special board for evidences, tape recorder, stick of chalk, \
		and of course, a fedora."
	cost = CARGO_CRATE_VALUE * 2.5
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
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/gun/energy/laser = 3)
	crate_name = "laser crate"

/datum/supply_pack/security/securitybarriers
	name = "Security Barrier Grenades"
	desc = "Stem the tide with six Security Barrier grenades."
	contains = list(/obj/item/grenade/barrier = 6)
	cost = CARGO_CRATE_VALUE * 3
	crate_name = "security barriers crate"

/datum/supply_pack/security/securityclothes
	name = "Security Clothing Crate"
	desc = "Contains appropriate outfits for the station's private security force. \
		Contains outfits for the Warden, Head of Security, and two Security Officers. \
		Each outfit comes with a rank-appropriate jumpsuit, suit, and beret."
	cost = CARGO_CRATE_VALUE * 3
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
	desc = "Contains ten \"stingbang\" grenades, perfect for stopping \
		riots and playing morally unthinkable pranks."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/storage/box/stingbangs = 2)
	crate_name = "stingbang grenade pack crate"

/datum/supply_pack/security/supplies
	name = "Security Supplies Crate"
	desc = "Contains seven flashbangs, seven smoke bombs, seven teargas grenades, six flashes, seven handcuffs, and two security utility vouchers." //monkestation edit
	cost = CARGO_CRATE_VALUE * 3.5
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/sec_smokebomb,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs,
					/obj/item/security_voucher/utility = 2,
				)
	crate_name = "security supply crate"

/datum/supply_pack/security/firingpins
	name = "Standard Firing Pins Crate"
	desc = "Upgrade your arsenal with 10 standard firing pins."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/storage/box/firingpins = 2)
	crate_name = "firing pins crate"

/datum/supply_pack/security/firingpins/paywall
	name = "Paywall Firing Pins Crate"
	desc = "Specialized firing pins with a built-in configurable paywall."
	cost = CARGO_CRATE_VALUE * 3
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
	contains = list(/obj/item/melee/baton/security/loaded = 3)
	crate_name = "stun baton crate"

/datum/supply_pack/security/wall_flash
	name = "Wall-Mounted Flash Crate"
	desc = "Contains four wall-mounted flashes."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/box/wall_flash = 4)
	crate_name = "wall-mounted flash crate"

/datum/supply_pack/security/portable_flasher
	name = "Portable Flasher Crate"
	desc = "Contains one portable flasher."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/machinery/flasher/portable)
	crate_name = "portable flasher crate"
	crate_type = /obj/structure/closet/crate/large

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

/datum/supply_pack/security/blueshirt
	name = "Blue Shirt Uniform Crate"
	desc = "Contains an alternative outfit for the station's private security force. Has enough outfits for five security officers. Originally produced for a now defunct research station."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/clothing/head/helmet/blueshirt = 5,
		/obj/item/clothing/suit/armor/vest/blueshirt = 5,
		/obj/item/clothing/under/rank/security/officer/blueshirt = 5,
	)
	crate_name = "\improper Blue Shirt uniform crate"

/datum/supply_pack/security/taser
	name = "Taser Crate"
	desc = "Contains three tasers, ready to tase criminals."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/gun/energy/taser = 3)
	crate_name = "taser crate"

/datum/supply_pack/security/advtaser
	name = "Hybrid Taser Crate"
	desc = "Contains three hybrid tasers, ready for tase and stun action!"
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/gun/energy/e_gun/advtaser= 3)
	crate_name = "hybrid taser crate"

/datum/supply_pack/security/combatknives
	name = "Combat Knives Crate"
	desc = "Three combat knives guaranteed to fit snugly inide any Nanotrasen standard boot. Warranty void if you stab your own ankle."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/knife/combat = 3)
	crate_name = "combat knife crate"

/datum/supply_pack/security/paco
	name = "FS HG .35 Auto \"Paco\" weapon crate"
	desc = "Did security slip and lose their handguns? in that case, this crate contains three \"Paco\" handguns with three magazines of rubber."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/paco/no_mag = 3,
		/obj/item/ammo_box/magazine/m35/rubber = 3,
		)
	crate_name = "\improper \"Paco\" handgun crate"

/datum/supply_pack/security/pacoammo
	name = "FS HG .35 Auto \"Paco\" non-lethal ammo crate"
	desc = "Short on ammo? No worries, this crate contains three .35 Auto rubber magazines, and the respective ammunition packet."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(
		/obj/item/ammo_box/magazine/m35/rubber = 3,
		/obj/item/ammo_box/c35/rubber,
		)
	crate_name = ".35 Auto Non-Lethal Ammo crate"

/datum/supply_pack/security/bio
	name = "Biological Containment Gear Crate"
	desc = "This crate holds 3 full security bio suits which will protect you from viruses along with 3 viral analyzer goggles and PENLITE barrier projectors to stop the spread."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(/obj/item/clothing/head/bio_hood/security = 3,
					/obj/item/clothing/suit/bio_suit/security = 3,
					/obj/item/reagent_containers/syringe/antiviral = 3,
					/obj/item/clothing/gloves/latex/nitrile = 3,
					/obj/item/clothing/glasses/pathology = 3,
					/obj/item/holosign_creator/medical = 3,
				)
	crate_name = "biological containment gear crate"

/datum/supply_pack/security/grenadelauncher
	name = "Riot Grenade Launcher Crate"
	desc = "Local revolution banging on your doorstep? Suppress the masses with this swanky riot control crate. Contains one grenade launcher and one box each of flashbangs and teargas grenades. Teargas protection included."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(
		/obj/item/gun/grenadelauncher,
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/box/teargas,
		/obj/item/clothing/mask/gas/sechailer/swat,
		)
	crate_name = "riot grenade launcher crate"

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
		/obj/item/dragnet_beacon,
		)
	crate_name = "\improper DRAGnet crate"

/datum/supply_pack/security/armory/energy
	name = "Energy Guns Crate"
	desc = "Contains three Energy Guns, capable of firing both nonlethal and lethal \
		blasts of light."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/gun/energy/e_gun = 3)
	crate_name = "energy gun crate"
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
	cost = CARGO_CRATE_VALUE * 4.5
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
	name = "Reflector Armor Crate"
	desc = "Contains three helmets and vests made of highly reflective material. Each armor piece \
		diffuses a laser's energy by over half, as well as offering a good chance \
		to reflect the laser entirely."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/clothing/suit/armor/laserproof = 3,
					/obj/item/clothing/head/helmet/laserproof = 3)
	crate_name = "reflector armor crate"
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
	desc = "Contains three fullbody sets of tough, fireproof suits designed in a joint \
		effort by IS-ERI and Nanotrasen. Each set contains a suit, helmet, mask, combat belt, \
		and combat gloves."
	cost = CARGO_CRATE_VALUE * 12 // three times more expensive than regular armor
	contains = list(/obj/item/clothing/head/helmet/swat/nanotrasen = 3,
					/obj/item/clothing/suit/armor/swat = 3,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat/alt,
					/obj/item/clothing/mask/gas/sechailer/swat/alt/pig,
					/obj/item/storage/belt/military/assault = 3,
					/obj/item/clothing/gloves/tackler/combat = 3,
				)
	crate_name = "swat crate"

/datum/supply_pack/security/armory/thermal
	name = "Thermal Pistol Crate"
	desc = "Contains a pair of holsters each with two experimental thermal pistols, \
		using nanites as the basis for their ammo."
	cost = CARGO_CRATE_VALUE * 7
	contains = list(/obj/item/storage/belt/holster/energy/thermal = 2)
	crate_name = "thermal pistol crate"

/datum/supply_pack/security/armory/ballisticmeleeweapons
	name = "Riot Shotgun Crate"
	desc = "Three 12ga riot shotguns, with matching bandoliers for each."
	cost = CARGO_CRATE_VALUE * 17.5
	contains = list(
		/obj/item/gun/ballistic/shotgun/riot = 3,
		/obj/item/storage/belt/bandolier = 3,
	)
	crate_name = "riot shotgun crate"

// these are here now, worst part is they used to sexually harass you
/datum/supply_pack/security/armory/short_mod_laser
	name = "Modular Laser Carbine Crate"
	desc = "Five 'Hoshi' modular laser carbines, compact energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle/carbine = 5,
	)
	crate_name = "\improper Modular Laser Carbine Crate"

/datum/supply_pack/security/armory/big_mod_laser
	name = "Modular Laser Rifle Crate"
	desc = "Three 'Hyeseong' modular laser rifles, bulky energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle = 3,
	)
	crate_name = "\improper Modular Laser Rifle Crate"

/datum/supply_pack/security/armory/bobr
	name = "Tactical Bóbr Crate"
	desc = "Two Bóbr shotgun revolvers, with matching Tutel ballistic shields and ammo for each."
	cost = CARGO_CRATE_VALUE * 20
	contains = list(
		/obj/item/gun/ballistic/revolver/shotgun_revolver = 2,
		/obj/item/ammo_box/tacshield/tutel = 2,
		/obj/item/ammo_box/advanced/s12gauge = 2,
	)
	crate_name = "Tactical Bóbr Crate"

/datum/supply_pack/security/armory/secway
	name = "Secway Crate"
	desc = "Sail through the halls like the badass mallcop of your dreams with the finest in overweight officer transportation technology!"
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/vehicle/ridden/secway,
					/obj/item/key/security)
	crate_name = "secway crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/security/armory/pacoammo
	name = "FS HG .35 Auto \"Paco\" lethal ammo crate"
	desc = "Short on ammo? No worries, this crate contains three lethally loaded .35 Auto magazines, and the respective ammunition packet."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/ammo_box/magazine/m35 = 3,
		/obj/item/ammo_box/c35,
		)
	crate_name = ".35 auto lethal ammo crate"

/datum/supply_pack/security/armory/wt550
	name = "WT-550 Autorifle Crate"
	desc = "A proper ballistic option for a proper ballistic officer. Contains three WT-550 autorifles and six spare rubber autorifle magazines."
	cost = CARGO_CRATE_VALUE * 20
	contains = list(
		/obj/item/gun/ballistic/automatic/wt550/no_mag = 3,
		/obj/item/ammo_box/magazine/wt550m9/wtrub = 6,
	)
	crate_name = "autorifle crate"
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/armory/wt550ammo/nonlethal
	name = "WT-550 Non-Lethal Ammo Crate"
	desc = "A supply of non-lethal ammunition for the WT-550 autorifle."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9/wtrub = 3,
		/obj/item/ammo_box/magazine/wt550m9/wtsalt = 3,
	)
	crate_name = "wt-550 non-lethal ammo crate"
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/armory/wt550ammo
	name = "WT-550 Ammo Crate"
	desc = "A supply of spare and exotic lethal ammunition for the WT-550 autorifle."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9 = 3,
		/obj/item/ammo_box/magazine/wt550m9/wtap = 3,
		/obj/item/ammo_box/magazine/wt550m9/wtic = 3,
	)
	crate_name = "wt-550 ammo crate"
	crate_type = /obj/structure/closet/crate/secure/weapon

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

/// Weapons that research unlocks for purchase, replacing the old gun part kits.
/// Hidden until the station researches the matching schematics, see /datum/design/cargo_weapon.
/datum/supply_pack/security/armory/requisition
	group = "Requisitions"
	special = TRUE

/datum/supply_pack/security/armory/requisition/aeg
	name = "Advanced Energy Gun Requisition"
	desc = "Contains an Advanced Energy Gun, which fires both disabling and lethal shots like a standard energy gun. \
		However, it also contains a miniature nuclear reactor that recharges the gun's energy cells over time."
	cost = CARGO_CRATE_VALUE * 16
	contains = list(/obj/item/gun/energy/e_gun/nuclear = 1)
	crate_name = "advanced energy gun crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/aeg/three_pack
	name = "Advanced Energy Gun Requisition (x3)"
	desc = "A bulk order of three Advanced Energy Guns, each with a miniature nuclear reactor that recharges it over time. Enough to arm a small strike team, at a discount over ordering them one at a time."
	cost = CARGO_CRATE_VALUE * 16 * 2.9
	contains = list(/obj/item/gun/energy/e_gun/nuclear = 3)
	no_departmental_order = FALSE

/datum/supply_pack/security/armory/requisition/xray
	name = "X-ray Laser Gun Requisition"
	desc = "Contains an X-ray Laser Gun, an atypical energy gun that fires radioactive-infused laser beams, \
		which are capable of penetrating most forms of armor and even walls."
	cost = CARGO_CRATE_VALUE * 20
	contains = list(/obj/item/gun/energy/xray = 1)
	crate_name = "x-ray gun crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/xray/three_pack
	name = "X-ray Laser Gun Requisition (x3)"
	desc = "A bulk order of three X-ray Laser Guns, whose radioactive beams punch through armor and walls alike. Cheaper than ordering them one at a time."
	cost = CARGO_CRATE_VALUE * 20 * 2.9
	contains = list(/obj/item/gun/energy/xray = 3)
	no_departmental_order = FALSE

/datum/supply_pack/security/armory/requisition/tempgun
	name = "Temperature Gun Requisition"
	desc = "Contains a Temperature Gun, a debatably useful weapon designed to rapidly heat or cool targets."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/gun/energy/temperature = 1)
	crate_name = "temperature gun crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/tempgun/three_pack
	name = "Temperature Gun Requisition (x3)"
	desc = "A bulk order of three Temperature Guns. Nobody is quite sure why you would need this many, so Central Command is practically giving them away."
	cost = CARGO_CRATE_VALUE * 4 * 2.75 // it's so bad it gets a better discount
	contains = list(/obj/item/gun/energy/temperature = 3)
	no_departmental_order = FALSE

/datum/supply_pack/security/armory/requisition/tesla
	name = "Tesla Cannon Requisition"
	desc = "Contains a Tesla Cannon, a fully automatic weapon that fires a rapid stream of electrified orbs."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/item/gun/energy/tesla_cannon = 1)
	crate_name = "tesla cannon crate"

/datum/supply_pack/security/armory/requisition/ion
	name = "Ion Carbine Requisition"
	desc = "Contains an Ion Carbine, a more portable form of the more unwieldy Ion Rifle. \
		Fires electromagnetic pulses that can disable electronics."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/gun/energy/ionrifle/carbine = 1)
	crate_name = "ion carbine crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/ion/three_pack
	name = "Ion Carbine Requisition (x3)"
	desc = "A bulk order of three Ion Carbines, perfect for a team that needs to shut down borgs, mechs and electronics in a hurry. Cheaper than ordering them one at a time."
	cost = CARGO_CRATE_VALUE * 6 * 2.9
	contains = list(/obj/item/gun/energy/ionrifle/carbine = 3)
	no_departmental_order = FALSE

/datum/supply_pack/security/armory/requisition/ebow
	name = "Energy Crossbow Requisition"
	desc = "Contains a reverse engineered Syndicate Energy Crossbow. Though less compact than the original, \
		the projectiles it fires are just as capable of downing targets in a single shot."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/item/gun/energy/recharge/ebow/large = 1)
	crate_name = "energy crossbow crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/ebow/three_pack
	name = "Energy Crossbow Requisition (x3)"
	desc = "A bulk order of three reverse engineered Energy Crossbows, for when one silent takedown just isn't enough. Cheaper than ordering them one at a time."
	cost = CARGO_CRATE_VALUE * 10 * 2.9
	contains = list(/obj/item/gun/energy/recharge/ebow/large = 3)
	no_departmental_order = FALSE

/datum/supply_pack/security/armory/requisition/laser_cannon
	name = "Laser Cannon Requisition"
	desc = "Contains a Laser Cannon, an advanced energy weapon that fires heavily concentrated beams of light \
		which pass through glass and thin metal."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/gun/energy/laser/cannon = 1)
	crate_name = "laser cannon crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/laser_cannon/three_pack
	name = "Laser Cannon Requisition (x3)"
	desc = "A bulk order of three Laser Cannons, heavy hitters for when the whole department needs to bring down something big. Cheaper than ordering them one at a time."
	cost = CARGO_CRATE_VALUE * 15 * 2.9
	contains = list(/obj/item/gun/energy/laser/cannon = 3)
	no_departmental_order = FALSE

/datum/supply_pack/security/armory/requisition/decloner
	name = "Decloner Requisition"
	desc = "Contains a Biological Demolecularisor, a baffling energy weapon that breaks down its targets on a cellular level."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(/obj/item/gun/energy/decloner = 1)
	crate_name = "decloner crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/decloner/three_pack
	name = "Decloner Requisition (x3)"
	desc = "A bulk order of three Biological Demolecularisors. Three times the cellular breakdown, at a discount over ordering them one at a time."
	cost = CARGO_CRATE_VALUE * 12 * 2.9
	contains = list(/obj/item/gun/energy/decloner = 3)
	no_departmental_order = FALSE

// Specialty shotgun shells, unlocked by researching the matching schematics (see /datum/design/cargo_weapon).
/datum/supply_pack/security/armory/requisition/pulse_shells
	name = "Pulse Slug Requisition"
	desc = "Contains a box of pulse slugs, shotgun shells that fire a weakened pulse bolt capable of armour penetration and blasting apart weak structures."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(/obj/item/storage/box/pulseslug)
	crate_name = "pulse slug crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/ion_shells
	name = "Ion Scatter Requisition"
	desc = "Contains a box of ion scatter shells, shotgun shells that spread electromagnetic pulses. Ideal against borgs, mechs and electronics."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/obj/item/storage/box/ionslug)
	crate_name = "ion scatter crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/meteor_shells
	name = "Meteorslug Requisition"
	desc = "Contains a box of meteorslugs, shotgun shells that fire a miniature meteor. Anything it hits is knocked flat and possibly broken."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/item/storage/box/meteorslug)
	crate_name = "meteorslug crate"
	no_departmental_order = TRUE

/datum/supply_pack/security/armory/requisition/frag_shells
	name = "FRAG-12 Requisition"
	desc = "Contains a box of FRAG-12 shells, explosive shotgun shells that detonate on impact."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(/obj/item/storage/box/frag12)
	crate_name = "FRAG-12 crate"
	no_departmental_order = TRUE
