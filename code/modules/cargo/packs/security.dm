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
	contains = list(/obj/item/storage/box/beanbag = 2,
					/obj/item/storage/box/rubbershot = 2,
					/obj/item/storage/box/lethalshot = 2,
					/obj/item/ammo_box/c38/trac,
					/obj/item/ammo_box/c38/hotshot,
					/obj/item/ammo_box/c38/iceblox,
				)
	crate_name = "ammo crate"

/datum/supply_pack/security/armor
	name = "Armor Crate"
	desc = "Three vests of well-rounded, decently-protective armor."
	cost = CARGO_CRATE_VALUE * 2
	access_view = ACCESS_SECURITY
	contains = list(/obj/item/clothing/suit/armor/vest = 3)
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
		Contains a forensics scanner, six evidence bags, camera, tape recorder, white crayon, \
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

/datum/supply_pack/security/helmets
	name = "Helmets Crate"
	desc = "Contains three standard-issue brain buckets."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/clothing/head/helmet/sec = 3)
	crate_name = "helmet crate"

/datum/supply_pack/security/laser
	name = "Lasers Crate"
	desc = "Contains three lethal, high-energy laser guns."
	cost = CARGO_CRATE_VALUE * 4
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
	desc = "Contains seven flashbangs, seven teargas grenades, six flashes, and seven handcuffs."
	cost = CARGO_CRATE_VALUE * 3.5
	access_view = ACCESS_ARMORY
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs,
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

/datum/supply_pack/security/mini_egun
	name = "Miniature Energy Gun Crate"
	desc = "Contains three miniature energy guns, a popular choice for security personnel in on-world Nanotransen facilities, \
		has slightly less charge capacity than a normal lazer gun"
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/gun/energy/e_gun/mini = 3)
	crate_name = "miniature energy gun crate"

/datum/supply_pack/security/ammobenchsupport
	name = "Ammunition Workbench Care Package"
	desc = "Engineers are vaporized?  Cargo Technicians blew the budget on cats and pizza? \
		This is the crate for you, containing the necessary supplies to create a complete \
		ammunition production platform!"
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/circuitboard/machine/ammo_workbench,
					/obj/item/disk/ammo_workbench/advanced,
					/obj/item/circuitboard/machine/dish_drive/bullet,
					/obj/item/stack/sheet/iron = 10,
					/obj/item/stack/cable_coil = 30,
					/obj/item/stock_parts/manipulator = 3,
					/obj/item/stock_parts/matter_bin = 4,
					/obj/item/stock_parts/micro_laser = 2,
					/obj/item/stack/sheet/glass = 1,
					/obj/item/wrench,
					/obj/item/screwdriver,
					/obj/item/paper/fluff{
	default_raw_text = "To set up your ammo platform, you'll need to crawl before you can shoot! \
	After setting up your Ammo Workbench, insert the Advanced Munitions Disk and go to the designs tab in the bench. \
	Finally, finalize the connection between the disk and computer by pressing 'upload', and there you have it!  Git' some!";
	name = "Notice from Ammunation"
	},
				)
	crate_name = "Ammunition Workbench Care Package"

/// Armory packs

/datum/supply_pack/security/armory
	group = "Armory"
	access = ACCESS_ARMORY
	access_view = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/supply_pack/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	desc = "Contains three sets of bulletproof armor. Guaranteed to reduce a bullet's \
		stopping power by over half."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/clothing/suit/armor/bulletproof = 3)
	crate_name = "bulletproof armor crate"

/datum/supply_pack/security/armory/bullethelmets
	name = "Bulletproof Helmets Crate"
	desc = "Contains three bulletproof helmets."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/clothing/head/helmet/alt = 3)
	crate_name = "bulletproof helmets crate"

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

/datum/supply_pack/security/armory/dragnet
	name = "DRAGnet Crate"
	desc = "Contains three \"Dynamic Rapid-Apprehension of the Guilty\" netting devices, \
		a recent breakthrough in law enforcement prisoner management technology."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/gun/energy/e_gun/dragnet = 3)
	crate_name = "\improper DRAGnet crate"

/datum/supply_pack/security/armory/energy
	name = "Energy Guns Crate"
	desc = "Contains two Energy Guns, capable of firing both nonlethal and lethal \
		blasts of light."
	cost = CARGO_CRATE_VALUE * 18
	contains = list(/obj/item/gun/energy/e_gun = 2)
	crate_name = "energy gun crate"
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/supply_pack/security/armory/exileimp
	name = "Exile Implants Crate"
	desc = "Contains five Exile implants."
	cost = CARGO_CRATE_VALUE * 3.5
	contains = list(/obj/item/storage/box/exileimp)
	crate_name = "exile implant crate"

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
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/clothing/suit/armor/riot = 3)
	crate_name = "riot armor crate"

/datum/supply_pack/security/armory/riothelmets
	name = "Riot Helmets Crate"
	desc = "Contains three riot helmets."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/clothing/head/helmet/toggleable/riot = 3)
	crate_name = "riot helmets crate"

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

/datum/supply_pack/security/armory/qarad
	name = "Elite Import Weapon:  Qarad Light Machinegun"
	desc = "Heavy duty, heavy kicking, heavy penetration weapon, \
		normally reserved for all out warfare, comes with a gun case \
		and spare magazines."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/gun/ballistic/automatic/sol_rifle/machinegun,
					/obj/item/storage/toolbox/guncase/skyrat/empty,
					/obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty = 2,
				)
	crate_name = "elite import qarad light machine gun crate"

/datum/supply_pack/security/armory/lancabrifle
	name = "Elite Import Weapon:  Lanca Battle Rifle"
	desc = "Sleek, scoped, special operatives rifle, \
		now in your own hands!  Caseless ammunition \
		will additionally keep your foes guessing!"
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/gun/ballistic/automatic/lanca,
					/obj/item/storage/toolbox/guncase/skyrat/empty,
					/obj/item/ammo_box/magazine/lanca/spawns_empty = 2,
				)
	crate_name = "elite import lanca battle rifle"

/datum/supply_pack/security/armory/bogseo
	name = "Elite Import Weapon: Bogseo Submachinegun"
	desc = "Among the Honor Guard, training oneself to handle this monster is a test, \
		though it is more an inside joke regarding its brief high-caliber \
		chambering run."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/gun/ballistic/automatic/xhihao_smg,
					/obj/item/storage/toolbox/guncase/skyrat/empty,
					/obj/item/ammo_box/magazine/miecz/spawns_empty = 2,
				)
	crate_name = "elite import bogseo submachinegun"

/datum/supply_pack/security/armory/cawomarksman
	name = "Elite Import Weapon: Cawil Marksman"
	desc = "Though many soldiers trained in long range ballistics prefer to hold their breath, \
		the Cawil Marksman's excellent recoil pattern makes it practical in the hands of any \
		SolFed Cadet."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/gun/ballistic/automatic/sol_rifle/marksman,
					/obj/item/storage/toolbox/guncase/skyrat/empty,
					/obj/item/ammo_box/magazine/c40sol_rifle/starts_empty = 2,
				)
	crate_name = "elite import cawil marksman"

/datum/supply_pack/security/armory/cawobattlerifle
	name = "Elite Import Weapon: Carwo-Cawil Battle Rifle"
	desc = "Standard among SolFed troopers, furious all the same, sometimes rarity \
		doesn't need to constitute robustness."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/gun/ballistic/automatic/sol_rifle,
					/obj/item/storage/toolbox/guncase/skyrat/empty,
					/obj/item/ammo_box/magazine/c40sol_rifle/standard/starts_empty = 2,
				)
	crate_name = "elite import carwo-cawil battle rifle"

/datum/supply_pack/security/armory/mieczsmg
	name = "Miecz Submachinegun Crate"
	desc = "Two Miecz subemachineguns now available for purchase, a direct competitor to \
		the Sindano SolFed SMG, comes in a two pack, considered better value by \
		P.M.C companies across the Spinward."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/item/gun/ballistic/automatic/miecz = 2)
	crate_name = "Miecz Submachinegun Crate"

/datum/supply_pack/security/armory/ion_carbine
	name = "Ion Carbine Special Crate"
	desc = "Perhaps some rogue Spinward pirates have stolen your ion rifle, or the \
		clown has taken it for a joy ride?  This ion carbine is a compact solution to \
		any robotic foes or electronic issues!  Warranty void if used to cook food."
	cost = CARGO_CRATE_VALUE * 20
	contains = list(/obj/item/gun/energy/ionrifle/carbine)
	crate_name = "Ion Carbine Special Crate"

/datum/supply_pack/security/armory/wylomantimat
	name = "Elite Import:  Wylom Anti-Material Rifle"
	desc = "Do you really want everything in one direction to not be seen? \
		We have the weapon for you!  No matter the case, a rogue HONK-mech, \
		an annoying assistant, or even small space pods, Wylom is here for you!"
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/gun/ballistic/automatic/wylom,
					/obj/item/ammo_box/magazine/wylom = 2,
					/obj/item/storage/toolbox/guncase/skyrat/empty,
				)
	crate_name = "elite import wylom anti-material rifle"
