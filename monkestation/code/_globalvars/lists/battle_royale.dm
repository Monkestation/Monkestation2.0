//Battle royale weighted loot tables go here, if something in a table is a list then all things in the list will be spawned when picked,
//spawned amount being equal to their value within the sub list

///common items, you will mostly be seeing things from this table
GLOBAL_LIST_INIT(royale_common_loot, list(
		/obj/item/soap = 3,
		/obj/item/a_gift/anything/wiz_name = 3, //lootbox inside the lootbox
		/obj/item/book/granter/action/spell/sacredflame = 1, //this goes in common because I think its funny
		/obj/item/book/granter/action/spell/smoke = 1, //also pretty funny
		/obj/item/book/granter/chuunibyou = 1,
		/obj/item/choice_beacon/holy = 1,
		/obj/item/choice_beacon/hero = 1,
		/obj/item/circular_saw/alien = 1,
		/obj/item/clothing/glasses/welding = 3,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/clothing/gloves/color/yellow = 3, //insuls
		/obj/item/clothing/gloves/rapid = 1,
		/obj/item/clothing/gloves/tackler/rocket = 1, //these are funny
		/obj/item/clothing/head/beanie/durathread = 1, //the start of the random armored clothing spam
		/obj/item/clothing/head/hats/hos/beret/syndicate = 1,
		/obj/item/clothing/head/hats/centcom_cap = 1,
		/obj/item/clothing/head/helmet/abductor = 1,
		/obj/item/clothing/head/utility/welding = 2,
		list(/obj/item/clothing/head/wizard = 1, /obj/item/clothing/suit/wizrobe = 1) = 1, //these all have minor armor
		list(/obj/item/clothing/head/wizard/marisa = 1, /obj/item/clothing/suit/wizrobe/marisa = 1) = 1,
		/obj/item/clothing/shoes/galoshes = 3,
		list(/obj/item/clothing/head/helmet/space/eva = 1, /obj/item/clothing/suit/space/eva = 1) = 3,
		/obj/item/storage/box/syndie_kit/space = 3,
		/obj/item/clothing/suit/armor/hos = 1,
		/obj/item/clothing/suit/armor/laserproof = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/syndicate = 1,
		/obj/item/clothing/suit/armor/vest/russian_coat = 1,
		/obj/item/clothing/suit/hooded/ablative = 1,
		/obj/item/clothing/suit/space/hardsuit/medical = 1,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/obj/item/clothing/suit/space/hardsuit/atmos = 1,
		/obj/item/clothing/suit/space/hardsuit/toxins = 1,
		/obj/item/clothing/under/syndicate = 3,
		/obj/item/extinguisher = 3,
		/obj/item/grenade/chem_grenade/clf3 = 1,
		/obj/item/grenade/mirage = 2,
		/obj/item/grenade/spawnergrenade/spesscarp = 1,
		/obj/item/grenade/spawnergrenade/clown = 1,
		/obj/item/grenade/spawnergrenade/clown_broken = 1,
		/obj/item/grenade/syndieminibomb = 1,
		/obj/item/gun/energy/disabler = 2,
		/obj/item/gun/energy/laser/musket/prime = 1,
		/obj/item/gun/energy/plasmacutter/adv = 2,
		/obj/item/gun/ballistic/rifle/boltaction/prime = 1,
		/obj/item/gun/ballistic/automatic/plastikov = 1,
		/obj/item/hatchet = 2,
		/obj/item/hot_potato = 2,
		/obj/item/knife/kitchen = 2,
		/obj/item/knife/rainbowknife = 1,
		/obj/item/knife/shiv = 3,
		/obj/item/knife/combat = 1,
		/obj/item/knife/shiv/plastitanium = 2,
		/obj/item/knife/butcher = 1,
		/obj/item/lead_pipe = 3,
		/obj/item/melee/baseball_bat/ablative = 1,
		/obj/item/melee/baton/security/loaded = 1,
		/obj/item/melee/chainofcommand = 1,
		/obj/item/melee/curator_whip = 1,
		/obj/item/nullrod/fedora = 1,
		/obj/item/reagent_containers/hypospray/cmo = 1,
		/obj/item/reagent_containers/hypospray/medipen/stimulants = 2,
		/obj/item/shield/riot/tele = 2,
		/obj/item/spear = 2,
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/storage/backpack/duffelbag/syndie/x4 = 1,
		/obj/item/storage/belt/utility/syndicate = 2,
		/obj/item/storage/belt/military = 1,
		/obj/item/storage/box/gorillacubes = 1,
		/obj/item/storage/box/syndie_kit/chameleon = 2,
		/obj/item/storage/box/syndie_kit/emp = 1,
		/obj/item/storage/box/syndie_kit/imp_hard_spear = 1,
		/obj/item/storage/box/syndie_kit/origami_bundle = 1,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 2,
		/obj/item/storage/medkit/regular = 3,
		/obj/item/storage/medkit/toxin = 2,
		/obj/item/storage/medkit/fire = 3,
		/obj/item/storage/medkit/brute = 3,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/toolbox/syndicate = 1,
		/obj/item/storage/toolbox/mechanical = 3,
		/obj/item/storage/toolbox/emergency = 3,
		/obj/item/storage/toolbox/electrical = 3,
		/obj/item/tailclub = 3,
		/obj/structure/mystery_box/guns = 3,
		/obj/structure/mystery_box/tdome = 3,
))

///utility things, very common at the start with a steep weight decrease in the mid game
GLOBAL_LIST_INIT(royale_utility_loot, list(
		/obj/item/autosurgeon/medical_hud = 2,
		/obj/item/barriercube = 2,
		/obj/item/book/granter/action/spell/charge = 1,
		/obj/item/book/granter/action/spell/knock = 2,
		/obj/item/book/granter/action/spell/summonitem = 2,
		/obj/item/card/emag/doorjack = 2,
		/obj/item/card/emag = 3,
		/obj/item/chameleon = 1,
		/obj/item/clothing/accessory/pandora_hope = 2, //gives a mood boost
		/obj/item/clothing/glasses/hud/health/sunglasses = 2,
		/obj/item/clothing/glasses/hud/security/sunglasses = 2,
		/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 2,
		/obj/item/clothing/glasses/meson/night = 2,
		/obj/item/clothing/glasses/night = 2,
		/obj/item/clothing/glasses/sunglasses = 3,
		/obj/item/clothing/glasses/thermal = 2,
		/obj/item/clothing/glasses/debug = 1, //all the HUDs
		/obj/item/clothing/gloves/combat = 2,
		/obj/item/clothing/gloves/combat/wizard = 1,
		/obj/item/clothing/mask/nobreath = 1, //never run out of oxy
		/obj/item/clothing/shoes/bhop = 1,
		/obj/item/clothing/shoes/combat/swat = 1,
		/obj/item/clothing/shoes/chameleon/noslip = 2,
		/obj/item/clothing/shoes/magboots/advance = 1,
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/crowbar/power = 3,
		/obj/item/desynchronizer = 1,
		/obj/item/dnainjector/dwarf = 1,
		/obj/item/dnainjector/chameleonmut = 1,
		/obj/item/dnainjector/cryokinesis = 1,
		/obj/item/dnainjector/insulated = 1,
		/obj/item/dnainjector/telemut = 1,
		/obj/item/flashlight/emp/debug = 1,
		/obj/item/gun/chem = 1,
		/obj/item/hand_tele = 1,
		/obj/item/mod/module/dispenser/ninja = 1,
		/obj/item/mod/module/holster = 1,
		/obj/item/mod/module/noslip = 1,
		/obj/item/mod/module/stealth/ninja = 1,
		/obj/item/sharpener = 1,
		/obj/item/slimecross/regenerative/rainbow = 1,
		/obj/item/slimepotion/speed = 2,
		/obj/item/slimepotion/spaceproof = 3,
		/obj/item/storage/backpack/holding = 1,
		/obj/item/storage/backpack/duffelbag/syndie/surgery = 1,
		/obj/item/storage/backpack/duffelbag/syndie/sabotage = 1,
		/obj/item/storage/belt/military/abductor/full = 1,
		/obj/item/storage/box/syndie_kit/chemical = 1,
		/obj/item/storage/box/syndie_kit/imp_stealth = 1,
		/obj/item/storage/box/syndie_kit/imp_storage = 2,
		/obj/item/storage/box/syndie_kit/syndicate_teleporter = 2,
		/obj/item/syndie_glue = 2,
		/obj/item/warp_whistle = 1, //this will probably just put you in the storm if you dont get it early but you know
		/obj/structure/mirror/magic = 1, //lets you set your species
))

///rare loot, annouced drops will pick from here, also gets more common the longer the royale lasts
GLOBAL_LIST_INIT(royale_rare_loot, list(
		/obj/item/card/id/advanced/highlander = 2, //AA
		/obj/item/card/emag/bluespace = 1,
		/obj/item/book/granter/martial/plasma_fist = 1, //this will end great im sure
		/obj/item/book/granter/martial/cqc = 1,
		/obj/item/autosurgeon/syndicate/anti_stun = 1,
		/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset = 2,
		/obj/item/autosurgeon/syndicate/laser_arm = 1,
		/obj/item/autosurgeon/syndicate/reviver = 1,
		/obj/item/autosurgeon/syndicate/thermal_eyes = 2,
		/obj/item/autosurgeon/syndicate/xray_eyes = 1,
		/obj/item/claymore = 1,
		/obj/item/clothing/glasses/godeye = 2,
		/obj/item/clothing/glasses/thermal/xray = 2,
		/obj/item/clothing/gloves/krav_maga/combatglovesplus = 2,
		/obj/item/clothing/gloves/tackler/combat/insulated = 2,
		/obj/item/clothing/neck/cloak/herald_cloak = 1,
		/obj/item/clothing/shoes/clown_shoes/banana_shoes/combat = 1,
		/obj/item/clothing/shoes/gunboots = 1,
		/obj/item/clothing/shoes/gunboots/disabler = 2,
		/obj/item/clothing/shoes/jackboots/fast = 2, //these give you a free speedboost
		/obj/item/construction/rcd/arcd = 1, //ranged, unlimited, and with a faster speed. literally better then the admin RCD
		/obj/item/debug/omnitool = 1,
		/obj/item/defibrillator/compact/combat/loaded = 1,
		/obj/item/dnainjector/lasereyesmut = 1,
		/obj/item/door_remote/omni = 1,
		/obj/item/fireaxe = 2,
		list(/obj/item/grenade/frag/mega = 1, /obj/item/grenade/stingbang/mega = 1, /obj/item/grenade/primer = 1) = 1,
		/obj/item/gun/magic/hook = 1,
		/obj/item/gun/magic/staff/chaos/unrestricted = 1,
		/obj/item/gun/energy/e_gun/advtaser = 1,
		/obj/item/gun/energy/e_gun/nuclear = 1,
		/obj/item/gun/energy/e_gun = 3,
		/obj/item/gun/energy/laser/captain/scattershot = 1,
		/obj/item/gun/energy/laser/captain = 1,
		/obj/item/gun/energy/lasercannon = 1,
		/obj/item/gun/energy/mindflayer = 1,
		/obj/item/gun/energy/recharge/ebow = 2,
		/obj/item/gun/energy/tesla_cannon = 1,
		/obj/item/gun/ballistic/revolver/syndicate = 1,
		/obj/item/gun/ballistic/revolver/c38 = 3,
		/obj/item/gun/ballistic/rocketlauncher/unrestricted = 1, //only 1 shot
		/obj/item/gun/ballistic/shotgun/automatic/dual_tube = 1,
		/obj/item/gun/ballistic/shotgun/bulldog/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 1,
		/obj/item/gun/ballistic/automatic/mini_uzi = 1,
		/obj/item/gun/ballistic/automatic/pistol = 3,
		/obj/item/gun/ballistic/automatic/tommygun = 1,
		/obj/item/gun/ballistic/automatic/wt550 = 3,
		/obj/item/implanter/uplink/precharged = 1,
		/obj/item/katana = 1,
		list(/obj/item/melee/energy/sword = 1, /obj/item/shield/energy = 1) = 1,
		/obj/item/mod/module/energy_shield = 1,
		list(/obj/item/reagent_containers/hypospray/combat = 1, /obj/item/storage/medkit/tactical/premium = 1) = 2,
		/obj/item/scrying = 1,
		/obj/item/singularityhammer = 1,
		/obj/item/spear/grey_tide = 1,
		/obj/item/storage/backpack/duffelbag/syndie/firestarter = 1,
		/obj/item/storage/belt/grenade/full = 1,
		/obj/item/storage/box/stabilized = 1, //might be too much
		/obj/item/storage/box/syndicate/bundle_a = 3,
		/obj/item/storage/box/syndicate/bundle_b = 3,
		/obj/item/teleportation_scroll = 1,
		list(/obj/item/pneumatic_cannon/pie/selfcharge = 1, /obj/item/syndie_glue = 1) = 1,
))

///very rare loot, only spawned from super drops
GLOBAL_LIST_INIT(royale_super_rare_loot, list(
		/obj/item/chainsaw/doomslayer = 1, //very strong melee that blocks all ranged attacks
		list(/obj/item/antag_spawner/contract = 1, /obj/item/slimepotion/spaceproof = 2) = 1, //gives you your own wizard apprentice(also space proofing for their robe)
		/obj/item/energy_katana = 1, //gamer katana
		/obj/item/melee/baseball_bat/homerun = 1, //nearly 1 shots if charged
		/obj/item/gun/energy/pulse = 1,
		/obj/item/gun/energy/marksman_revolver = 1,
		list(/obj/item/minigunpack = 1, /obj/item/slimepotion/spaceproof = 2) = 1, //laser minigun and spaceproofing so you can use it safely
		list(/obj/item/mod/control/pre_equipped/enchanted = 1, /obj/item/wizard_armour_charge = 1) = 1, //wizard MODsuit and an armor charge for it, might need to take the charge out
		/obj/item/storage/belt/wands/full = 1,
		list(/obj/item/uplink/nuclear = 1, /obj/item/stack/telecrystal/twenty = 2) = 1,
		list(/obj/vehicle/sealed/mecha/gygax/dark/loaded = 1, /obj/item/card/id/advanced/chameleon = 1) = 1,
		/obj/item/highfrequencyblade = 1,
))

///misc loot, things that are not useful on their own/are jokes
GLOBAL_LIST_INIT(royale_misc_loot, list(
		/obj/item/banhammer = 1,
		/obj/item/ai_module/zeroth/automalf = 1,
		/obj/item/bedsheet/random = 1,
		/obj/item/bikehorn/golden = 1,
		/obj/item/bikehorn/airhorn = 1,
		/obj/item/book_of_babel = 1,
		/obj/item/book/granter/action/spell/barnyard = 1,
		/obj/item/choice_beacon/augments = 1, //putting this here as you need an autosurgeon for it to be useful
		/obj/item/choice_beacon/pet = 1,
		/obj/item/clothing/glasses/salesman = 1,
		/obj/item/clothing/gloves/boxing = 1,
		/obj/item/clothing/shoes/bhop/rocket = 1, //these launch you 20 tiles
		/obj/item/clothing/suit/armor/reactive/table = 1,
		/obj/item/crowbar/mechremoval = 1,
		/obj/item/debug/human_spawner = 1, //not very useful, might be too much power to give to players
		/obj/item/deployable_turret_folded = 1, //I really dont know where to put this due to how situational it is, so it goes here
		/obj/item/dice/d20/fate/cursed = 1, //cowards way out
		/obj/item/dnainjector/clumsymut = 1, //honk
		/obj/item/dnainjector/h2m = 1,
		/obj/item/dragons_blood = 1,
		/obj/item/encryptionkey/binary = 1,
		/obj/item/flamethrower/full/tank = 1, //using this would be a very bad idea for your health
		/obj/item/food/burger/roburger/big = 1,
		/obj/item/freeze_cube = 1,
		/obj/item/grenade/clusterbuster/slime/volatile = 1,
		/obj/item/grenade/clusterbuster/random = 1, //most of these will do nothing or have a large amount of friendly fire
		/obj/item/grenade/monkey_barrel = 1,
		/obj/item/lava_staff = 1,
		/obj/item/megaphone/clown = 1, //comms still work so annoy everyone
		/obj/item/melee/beesword = 1,
		/obj/item/melee/powerfist = 1,
		/obj/item/reagent_containers/borghypo/syndicate = 1, //usable by non-borgs, it just wont recharge
		list(/obj/item/robot_suit/prebuilt = 1, /obj/item/mmi/posibrain = 1) = 1,
		/obj/item/sbeacondrop/clownbomb = 1,
		/obj/item/storage/backpack/duffelbag/clown/syndie = 1,
		/obj/item/storage/backpack/duffelbag/clown/cream_pie = 1,
		/obj/item/storage/box/syndie_kit/bee_grenades = 1,
		/obj/item/storage/box/syndie_kit/imp_macrobomb = 1, //take them with you
		/obj/item/storage/pill_bottle/maintenance_pill/full = 1,
		/obj/item/storage/toolbox/haunted = 1,
		list(/obj/item/stack/cannonball/the_big_one = 1, /obj/structure/cannon = 1, /obj/item/reagent_containers/cup/bucket/wooden = 1, /obj/structure/fermenting_barrel/gunpowder = 1) = 1,
		/obj/vehicle/ridden/monkey_ball = 1,
		/obj/structure/healingfountain = 1,
		/obj/structure/mystery_box = 3,
		/obj/structure/pinata/syndie = 1,
))

///things in this table have a chance to be spawned in addition to something from another table
GLOBAL_LIST_INIT(royale_extra_loot, list(
		/obj/item/stack/telecrystal/five = 3,
		list(/obj/item/stack/telecrystal/five = 2) = 2,
		/obj/item/ammo_box/a357 = 3,
		/obj/item/ammo_box/c38 = 3,
		/obj/item/ammo_box/magazine/m9mm/ap = 1,
		/obj/item/ammo_box/magazine/m9mm/fire = 1,
		/obj/item/ammo_box/magazine/m9mm/hp = 1,
		/obj/item/storage/box/lethalshot = 3,
		/obj/item/ammo_box/magazine/m556 = 3,
		/obj/item/ammo_box/magazine/uzim9mm = 3,
		/obj/item/ammo_box/magazine/tommygunm45 = 3,
		/obj/item/ammo_box/magazine/wt550m9 = 1,
		/obj/item/ammo_box/magazine/wt550m9/wtap = 1,
		/obj/item/ammo_box/magazine/wt550m9/wtic = 1,
))
